import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Narração on-device do texto bíblico (TTS do aparelho) — cobre o momento
/// "sem tela" (trânsito, antes de dormir) sem exigir produção de áudio.
class TtsService extends ChangeNotifier {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _configured = false;
  bool _speaking = false;

  /// Texto em pt-BR para ler se a voz original falhar no meio.
  String? _fallbackOnError;

  /// Leitura em sequência (capítulo inteiro, versículo a versículo).
  int _sequenceGen = 0;
  bool _inSequence = false;
  String? _sequenceKey;
  int? _sequenceIndex;

  bool get isSpeaking => _speaking;

  /// Quem pediu a sequência atual (ex.: "gn:1") — o leitor só destaca a sua.
  String? get sequenceKey => _inSequence ? _sequenceKey : null;

  /// Parte que está sendo lida agora na sequência.
  int? get sequenceIndex => _inSequence ? _sequenceIndex : null;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    _configured = true;
    try {
      await _tts.setLanguage('pt-BR');
      await _tts.setSpeechRate(0.45);
      _tts.setCompletionHandler(() {
        _fallbackOnError = null;
        if (_inSequence) return;
        _speaking = false;
        notifyListeners();
      });
      _tts.setCancelHandler(() {
        _fallbackOnError = null;
        _speaking = false;
        notifyListeners();
      });
      _tts.setErrorHandler((msg) {
        debugPrint('TtsService erro: $msg');
        _speaking = false;
        notifyListeners();
        final fallback = _fallbackOnError;
        _fallbackOnError = null;
        if (fallback != null) speak(fallback);
      });
      try {
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.spokenAudio,
        );
      } catch (_) {}
    } catch (e) {
      debugPrint('TtsService config falhou: $e');
    }
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _ensureConfigured();
    _endSequence();
    _fallbackOnError = null;
    try {
      await _tts.stop();
      await _tts.setLanguage('pt-BR');
      await _tts.awaitSpeakCompletion(false);
      _speaking = true;
      notifyListeners();
      await _tts.speak(text);
    } catch (e) {
      _speaking = false;
      notifyListeners();
      debugPrint('TtsService.speak falhou: $e');
    }
  }

  /// Lê lema hebraico/grego com a voz do aparelho.
  /// Sem voz do idioma instalada (ou se ela falhar), lê [fallback] em pt-BR.
  /// Retorna `false` quando nem chegou a tentar a voz original.
  Future<bool> speakOriginal(
    String text, {
    required bool hebrew,
    String fallback = '',
  }) async {
    if (text.trim().isEmpty) {
      if (fallback.isNotEmpty) await speak(fallback);
      return false;
    }
    await _ensureConfigured();
    _endSequence();
    // Outro speak/stop/toque durante os awaits invalida este pedido.
    final gen = _sequenceGen;
    final lang = hebrew ? 'he-IL' : 'el-GR';
    try {
      await _tts.stop();
      // Android: "disponível" não quer dizer baixada — sem a voz local o
      // motor só dispara onError. Exige a voz instalada.
      final dynamic ok = defaultTargetPlatform == TargetPlatform.android
          ? await _tts.isLanguageInstalled(lang)
          : await _tts.isLanguageAvailable(lang);
      if (gen != _sequenceGen) return false;
      if (ok != true) {
        debugPrint('TtsService: voz $lang indisponível');
        if (fallback.isNotEmpty) await speak(fallback);
        return false;
      }
      await _tts.setLanguage(lang);
      if (gen != _sequenceGen) return false;
      // Sem esperar o fim: no Android um onError deixa o future pendurado.
      await _tts.awaitSpeakCompletion(false);
      _fallbackOnError = fallback.isEmpty ? null : fallback;
      _speaking = true;
      notifyListeners();
      await _tts.speak(text);
      return true;
    } catch (e) {
      _fallbackOnError = null;
      _speaking = false;
      notifyListeners();
      debugPrint('TtsService.speakOriginal falhou: $e');
      if (fallback.isNotEmpty) await speak(fallback);
      return false;
    }
  }

  /// Lê [parts] em ordem a partir de [start], avisando qual parte está no ar.
  /// Qualquer [speak] ou [stop] interrompe a sequência.
  Future<void> speakSequence(
    List<String> parts, {
    required String key,
    int start = 0,
  }) async {
    if (parts.isEmpty) return;
    await _ensureConfigured();
    final gen = ++_sequenceGen;
    _fallbackOnError = null;
    try {
      await _tts.stop();
      await _tts.setLanguage('pt-BR');
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {}
    _inSequence = true;
    _sequenceKey = key;
    _speaking = true;
    for (var i = start.clamp(0, parts.length - 1); i < parts.length; i++) {
      if (gen != _sequenceGen) return;
      _sequenceIndex = i;
      notifyListeners();
      try {
        await _tts.speak(parts[i]);
      } catch (e) {
        debugPrint('TtsService.speakSequence falhou: $e');
        break;
      }
    }
    if (gen != _sequenceGen) return;
    _endSequence();
    _speaking = false;
    notifyListeners();
  }

  void _endSequence() {
    _sequenceGen++;
    _inSequence = false;
    _sequenceKey = null;
    _sequenceIndex = null;
  }

  Future<void> stop() async {
    final wasSequence = _inSequence;
    _endSequence();
    _fallbackOnError = null;
    try {
      await _tts.stop();
    } catch (_) {}
    if (_speaking || wasSequence) {
      _speaking = false;
      notifyListeners();
    }
  }
}
