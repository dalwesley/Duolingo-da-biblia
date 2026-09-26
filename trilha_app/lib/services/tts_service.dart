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
        if (_inSequence) return;
        _speaking = false;
        notifyListeners();
      });
      _tts.setCancelHandler(() {
        _speaking = false;
        notifyListeners();
      });
      _tts.setErrorHandler((_) {
        _speaking = false;
        notifyListeners();
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
    try {
      await _tts.stop();
      _speaking = true;
      notifyListeners();
      await _tts.speak(text);
    } catch (e) {
      _speaking = false;
      notifyListeners();
      debugPrint('TtsService.speak falhou: $e');
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
    try {
      await _tts.stop();
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
    try {
      await _tts.stop();
    } catch (_) {}
    if (_speaking || wasSequence) {
      _speaking = false;
      notifyListeners();
    }
  }
}
