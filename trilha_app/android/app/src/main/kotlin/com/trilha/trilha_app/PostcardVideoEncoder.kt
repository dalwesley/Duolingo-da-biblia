package com.trilha.trilha_app

import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * Vídeo do postal (Peregrino+): o Flutter manda quadros RGBA, este encoder
 * converte para YUV e grava H.264 num MP4. Canal `stway/video`:
 * start(path, width, height, fps, bitrate) → frame(bytes)… → finish() → path.
 * Tudo numa thread própria; as respostas voltam na principal.
 */
class PostcardVideoEncoder private constructor() {
    private val worker = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())

    private var codec: MediaCodec? = null
    private var muxer: MediaMuxer? = null
    private var track = -1
    private var muxing = false
    private var path = ""
    private var width = 0
    private var height = 0
    private var fps = 24
    private var index = 0L
    private val info = MediaCodec.BufferInfo()

    companion object {
        fun register(messenger: BinaryMessenger) {
            val encoder = PostcardVideoEncoder()
            MethodChannel(messenger, "stway/video").setMethodCallHandler { call, result ->
                encoder.worker.execute {
                    try {
                        val value: Any? = when (call.method) {
                            "start" -> {
                                encoder.start(
                                    call.argument<String>("path")!!,
                                    call.argument<Int>("width")!!,
                                    call.argument<Int>("height")!!,
                                    call.argument<Int>("fps")!!,
                                    call.argument<Int>("bitrate")!!,
                                )
                                null
                            }
                            "frame" -> {
                                encoder.frame(call.arguments as ByteArray)
                                null
                            }
                            "finish" -> encoder.finish()
                            "cancel" -> {
                                encoder.release()
                                null
                            }
                            else -> {
                                encoder.main.post { result.notImplemented() }
                                return@execute
                            }
                        }
                        encoder.main.post { result.success(value) }
                    } catch (e: Exception) {
                        encoder.release()
                        encoder.main.post { result.error("video", e.message, null) }
                    }
                }
            }
        }
    }

    private fun start(path: String, width: Int, height: Int, fps: Int, bitrate: Int) {
        release()
        this.path = path
        this.width = width
        this.height = height
        this.fps = fps
        index = 0
        java.io.File(path).delete()
        val format = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, width, height).apply {
            setInteger(
                MediaFormat.KEY_COLOR_FORMAT,
                MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Flexible,
            )
            setInteger(MediaFormat.KEY_BIT_RATE, bitrate)
            setInteger(MediaFormat.KEY_FRAME_RATE, fps)
            setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1)
        }
        codec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC).apply {
            configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            start()
        }
        muxer = MediaMuxer(path, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
        track = -1
        muxing = false
    }

    private fun frame(rgba: ByteArray) {
        val codec = codec ?: throw IllegalStateException("encoder não iniciado")
        var slot: Int
        while (true) {
            slot = codec.dequeueInputBuffer(10_000)
            if (slot >= 0) break
            drain(false)
        }
        val image = codec.getInputImage(slot) ?: throw IllegalStateException("sem imagem de entrada")
        writeYuv(image, rgba)
        val pts = index * 1_000_000L / fps
        codec.queueInputBuffer(slot, 0, width * height * 3 / 2, pts, 0)
        index++
        drain(false)
    }

    /** Conversão de cor em faixas de linhas, em paralelo. */
    private val bands = Executors.newFixedThreadPool(4)

    /**
     * RGBA → YUV 4:2:0 (BT.601, faixa limitada) nos planos do codec, em 4
     * faixas de linhas ao mesmo tempo; cada faixa monta a linha num array e
     * grava em bloco (pixel a pixel no ByteBuffer era o gargalo).
     */
    private fun writeYuv(image: android.media.Image, rgba: ByteArray) {
        val planes = image.planes
        val count = 4
        // Faixas com número par de linhas: o croma (2×2) não cruza faixas.
        val step = ((height / count) + 1) and 1.inv()
        val jobs = (0 until count).map { band ->
            val from = band * step
            val to = minOf(height, from + step)
            bands.submit {
                if (from < to) writeBand(planes, rgba, from, to)
            }
        }
        jobs.forEach { it.get() }
    }

    private fun writeBand(
        planes: Array<android.media.Image.Plane>,
        rgba: ByteArray,
        from: Int,
        to: Int,
    ) {
        // duplicate(): posição própria por thread, mesma memória.
        val y = planes[0].buffer.duplicate()
        val u = planes[1].buffer.duplicate()
        val v = planes[2].buffer.duplicate()
        val yStride = planes[0].rowStride
        val yPix = planes[0].pixelStride
        val cStride = planes[1].rowStride
        val cPix = planes[1].pixelStride
        val half = width / 2
        val yRow = ByteArray(width)
        val uRow = ByteArray(half)
        val vRow = ByteArray(half)
        for (row in from until to) {
            var p = row * width * 4
            val chroma = row and 1 == 0
            for (col in 0 until width) {
                val r = rgba[p].toInt() and 0xFF
                val g = rgba[p + 1].toInt() and 0xFF
                val b = rgba[p + 2].toInt() and 0xFF
                yRow[col] = (((66 * r + 129 * g + 25 * b + 128) shr 8) + 16).toByte()
                if (chroma && col and 1 == 0) {
                    val c = col shr 1
                    uRow[c] = (((-38 * r - 74 * g + 112 * b + 128) shr 8) + 128).toByte()
                    vRow[c] = (((112 * r - 94 * g - 18 * b + 128) shr 8) + 128).toByte()
                }
                p += 4
            }
            if (yPix == 1) {
                y.position(row * yStride)
                y.put(yRow)
            } else {
                for (col in 0 until width) y.put(row * yStride + col * yPix, yRow[col])
            }
            if (chroma) {
                val base = (row shr 1) * cStride
                if (cPix == 1) {
                    u.position(base)
                    u.put(uRow)
                    v.position(base)
                    v.put(vRow)
                } else {
                    // Planos intercalados (NV12/NV21): U e V dividem a memória.
                    for (c in 0 until half) {
                        u.put(base + c * cPix, uRow[c])
                        v.put(base + c * cPix, vRow[c])
                    }
                }
            }
        }
    }

    private fun drain(end: Boolean) {
        val codec = codec ?: return
        val muxer = muxer ?: return
        while (true) {
            val out = codec.dequeueOutputBuffer(info, 10_000)
            when {
                out == MediaCodec.INFO_TRY_AGAIN_LATER -> if (!end) return
                out == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                    track = muxer.addTrack(codec.outputFormat)
                    muxer.start()
                    muxing = true
                }
                out >= 0 -> {
                    val buffer = codec.getOutputBuffer(out)!!
                    if (info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0) info.size = 0
                    if (info.size > 0 && muxing) {
                        buffer.position(info.offset)
                        buffer.limit(info.offset + info.size)
                        muxer.writeSampleData(track, buffer, info)
                    }
                    codec.releaseOutputBuffer(out, false)
                    if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) return
                }
            }
        }
    }

    private fun finish(): String {
        val codec = codec ?: throw IllegalStateException("encoder não iniciado")
        var slot: Int
        while (true) {
            slot = codec.dequeueInputBuffer(10_000)
            if (slot >= 0) break
            drain(false)
        }
        codec.queueInputBuffer(slot, 0, 0, index * 1_000_000L / fps, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
        drain(true)
        val done = path
        release()
        return done
    }

    private fun release() {
        try {
            codec?.stop()
        } catch (_: Exception) {
        }
        codec?.release()
        codec = null
        try {
            if (muxing) muxer?.stop()
        } catch (_: Exception) {
        }
        muxer?.release()
        muxer = null
        muxing = false
        track = -1
    }
}
