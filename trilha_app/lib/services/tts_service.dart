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

  bool get isSpeaking => _speaking;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    _configured = true;
    try {
      await _tts.setLanguage('pt-BR');
      await _tts.setSpeechRate(0.45);
      _tts.setCompletionHandler(() {
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

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    if (_speaking) {
      _speaking = false;
      notifyListeners();
    }
  }
}
