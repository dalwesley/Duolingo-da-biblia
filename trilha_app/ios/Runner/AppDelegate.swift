import AVFoundation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let ok = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    application.registerForRemoteNotifications()
    return ok
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "PostcardVideoEncoder") {
      PostcardVideoEncoder.register(messenger: registrar.messenger())
    }
  }
}

/// Vídeo do postal (Peregrino+): o Flutter manda quadros RGBA, este encoder
/// grava H.264 num MP4. Canal `stway/video`:
/// start(path, width, height, fps, bitrate) → frame(bytes)… → finish() → path.
final class PostcardVideoEncoder {
  private static var shared: PostcardVideoEncoder?
  private var channel: FlutterMethodChannel?

  private let queue = DispatchQueue(label: "stway.postcard.video")
  private var writer: AVAssetWriter?
  private var input: AVAssetWriterInput?
  private var adaptor: AVAssetWriterInputPixelBufferAdaptor?
  private var path = ""
  private var width = 0
  private var height = 0
  private var fps: Int32 = 24
  private var index: Int64 = 0

  static func register(messenger: FlutterBinaryMessenger) {
    let encoder = PostcardVideoEncoder()
    let channel = FlutterMethodChannel(name: "stway/video", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      encoder.queue.async {
        do {
          let value = try encoder.handle(call)
          DispatchQueue.main.async { result(value) }
        } catch {
          encoder.cancel()
          DispatchQueue.main.async {
            result(FlutterError(code: "video", message: "\(error)", details: nil))
          }
        }
      }
    }
    encoder.channel = channel
    shared = encoder
  }

  private struct Failure: Error, CustomStringConvertible {
    let description: String
  }

  private func handle(_ call: FlutterMethodCall) throws -> Any? {
    switch call.method {
    case "start":
      guard let args = call.arguments as? [String: Any],
        let path = args["path"] as? String,
        let width = args["width"] as? Int,
        let height = args["height"] as? Int,
        let fps = args["fps"] as? Int,
        let bitrate = args["bitrate"] as? Int
      else { throw Failure(description: "argumentos inválidos") }
      try start(path: path, width: width, height: height, fps: fps, bitrate: bitrate)
      return nil
    case "frame":
      guard let data = call.arguments as? FlutterStandardTypedData else {
        throw Failure(description: "quadro inválido")
      }
      try frame(data.data)
      return nil
    case "finish":
      return try finish()
    case "cancel":
      cancel()
      return nil
    default:
      return FlutterMethodNotImplemented
    }
  }

  private func start(path: String, width: Int, height: Int, fps: Int, bitrate: Int) throws {
    cancel()
    self.path = path
    self.width = width
    self.height = height
    self.fps = Int32(fps)
    index = 0
    let url = URL(fileURLWithPath: path)
    try? FileManager.default.removeItem(at: url)
    let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
    let input = AVAssetWriterInput(
      mediaType: .video,
      outputSettings: [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: width,
        AVVideoHeightKey: height,
        AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: bitrate],
      ])
    input.expectsMediaDataInRealTime = false
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(
      assetWriterInput: input,
      sourcePixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        kCVPixelBufferWidthKey as String: width,
        kCVPixelBufferHeightKey as String: height,
      ])
    writer.add(input)
    guard writer.startWriting() else {
      throw Failure(description: writer.error?.localizedDescription ?? "startWriting")
    }
    writer.startSession(atSourceTime: .zero)
    self.writer = writer
    self.input = input
    self.adaptor = adaptor
  }

  private func frame(_ rgba: Data) throws {
    guard let input = input, let adaptor = adaptor, let pool = adaptor.pixelBufferPool else {
      throw Failure(description: "encoder não iniciado")
    }
    var buffer: CVPixelBuffer?
    CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer)
    guard let pixels = buffer else { throw Failure(description: "sem pixel buffer") }
    CVPixelBufferLockBaseAddress(pixels, [])
    let base = CVPixelBufferGetBaseAddress(pixels)!.assumingMemoryBound(to: UInt8.self)
    let stride = CVPixelBufferGetBytesPerRow(pixels)
    rgba.withUnsafeBytes { (src: UnsafeRawBufferPointer) in
      let s = src.bindMemory(to: UInt8.self)
      for row in 0..<height {
        let from = row * width * 4
        let to = row * stride
        for col in 0..<width {
          let i = from + col * 4
          let o = to + col * 4
          // RGBA → BGRA
          base[o] = s[i + 2]
          base[o + 1] = s[i + 1]
          base[o + 2] = s[i]
          base[o + 3] = s[i + 3]
        }
      }
    }
    CVPixelBufferUnlockBaseAddress(pixels, [])
    while !input.isReadyForMoreMediaData { usleep(2000) }
    guard adaptor.append(pixels, withPresentationTime: CMTime(value: index, timescale: fps)) else {
      throw Failure(description: writer?.error?.localizedDescription ?? "append")
    }
    index += 1
  }

  private func finish() throws -> String {
    guard let writer = writer, let input = input else {
      throw Failure(description: "encoder não iniciado")
    }
    input.markAsFinished()
    let done = DispatchSemaphore(value: 0)
    writer.finishWriting { done.signal() }
    done.wait()
    defer {
      self.writer = nil
      self.input = nil
      self.adaptor = nil
    }
    guard writer.status == .completed else {
      throw Failure(description: writer.error?.localizedDescription ?? "finishWriting")
    }
    return path
  }

  private func cancel() {
    writer?.cancelWriting()
    writer = nil
    input = nil
    adaptor = nil
  }
}
