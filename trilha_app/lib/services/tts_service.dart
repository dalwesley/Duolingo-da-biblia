import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uma voz instalada no aparelho.
class TtsVoice {
  final String name;
  final String locale;

  /// iOS informa `male` / `female`; Android não.
  final String? gender;

  const TtsVoice({required this.name, required this.locale, this.gender});

  Map<String, String> toMap() => {'name': name, 'locale': locale};

  @override
  bool operator ==(Object other) =>
      other is TtsVoice && other.name == name && other.locale == locale;

  @override
  int get hashCode => Object.hash(name, locale);
}

/// Velocidade da leitura em voz alta.
enum TtsSpeed {
  slow(0.36),
  normal(0.45),
  fast(0.56);

  final double rate;
  const TtsSpeed(this.rate);
}

/// Narração on-device do texto bíblico (TTS do aparelho) — cobre o momento
/// "sem tela" (trânsito, antes de dormir) sem exigir produção de áudio.
class TtsService extends ChangeNotifier {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _speaking = false;

  /// Texto em pt-BR para ler se a voz original falhar no meio.
  String? _fallbackOnError;

  /// Leitura em sequência (capítulo inteiro, versículo a versículo).
  int _sequenceGen = 0;
  bool _inSequence = false;
  String? _sequenceKey;
  int? _sequenceIndex;

  bool get isSpeaking => _speaking;

  /// Trecho da parte atual sendo falado agora (offsets em `parts[i]`), para
  /// o leitor marcar a palavra. Null quando o motor não informa (Android < 8
  /// ou motor sem suporte) ou entre partes.
  final ValueNotifier<({int start, int end})?> wordRange = ValueNotifier(null);

  static const _keySpeed = 'tts.speed';
  static String _keyVoice(String code) => 'tts.voice.$code';

  TtsSpeed _speed = TtsSpeed.normal;
  final Map<String, TtsVoice> _chosenVoice = {};
  bool _prefsLoaded = false;

  TtsSpeed get speed => _speed;

  /// Voz escolhida para a língua (`pt`, `en`, `es`); null = automática.
  TtsVoice? chosenVoice(String language) =>
      _chosenVoice[_languageCode(language)];

  Future<void> _loadPrefs() async {
    if (_prefsLoaded) return;
    _prefsLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final speed = prefs.getString(_keySpeed);
      _speed = TtsSpeed.values.firstWhere(
        (s) => s.name == speed,
        orElse: () => TtsSpeed.normal,
      );
      for (final code in _voiceCandidates.keys) {
        final raw = prefs.getString(_keyVoice(code));
        if (raw == null) continue;
        final m = jsonDecode(raw) as Map<String, dynamic>;
        _chosenVoice[code] = TtsVoice(
          name: m['name'] as String,
          locale: m['locale'] as String,
          gender: m['gender'] as String?,
        );
      }
    } catch (e) {
      debugPrint('TtsService prefs falharam: $e');
    }
  }

  Future<void> setSpeed(TtsSpeed speed) async {
    await _ensureConfigured();
    _speed = speed;
    notifyListeners();
    try {
      await _tts.setSpeechRate(speed.rate);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySpeed, speed.name);
    } catch (_) {}
  }

  /// Fixa a voz de uma língua; null volta para a automática.
  Future<void> setVoice(String language, TtsVoice? voice) async {
    await _ensureConfigured();
    final code = _languageCode(language);
    if (voice == null) {
      _chosenVoice.remove(code);
    } else {
      _chosenVoice[code] = voice;
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (voice == null) {
        await prefs.remove(_keyVoice(code));
      } else {
        await prefs.setString(
          _keyVoice(code),
          jsonEncode({...voice.toMap(), 'gender': ?voice.gender}),
        );
      }
    } catch (_) {}
  }

  /// Vozes instaladas no aparelho para a língua, sem as que pedem internet.
  Future<List<TtsVoice>> voicesFor(String language) async {
    await _ensureConfigured();
    final code = _languageCode(language);
    final dynamic raw;
    try {
      raw = await _tts.getVoices;
    } catch (_) {
      return const [];
    }
    if (raw is! List) return const [];
    final order = _voiceCandidates[code] ?? const <String>[];
    final out = <TtsVoice>{};
    for (final v in raw) {
      if (v is! Map) continue;
      final name = v['name']?.toString() ?? '';
      final locale = (v['locale']?.toString() ?? '').replaceAll('_', '-');
      if (name.isEmpty || _languageCode(locale) != code) continue;
      if (v['network_required']?.toString() == '1') continue;
      final features = v['features']?.toString() ?? '';
      if (features.contains('notInstalled')) continue;
      out.add(
        TtsVoice(name: name, locale: locale, gender: v['gender']?.toString()),
      );
    }
    int rank(TtsVoice v) {
      final i = order.indexWhere(
        (l) => l.toLowerCase() == v.locale.toLowerCase(),
      );
      return i < 0 ? order.length : i;
    }

    return out.toList()..sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      return r != 0 ? r : a.name.compareTo(b.name);
    });
  }

  /// Aplica a voz escolhida da língua (depois do setLanguage).
  Future<void> _applyVoice(String language) async {
    final v = _chosenVoice[_languageCode(language)];
    if (v == null) return;
    try {
      await _tts.setVoice(v.toMap());
    } catch (e) {
      debugPrint('TtsService: voz ${v.name} falhou: $e');
    }
  }

  /// Vozes por língua do texto, na ordem de preferência. ES: a BES é
  /// latino-americana, então México primeiro.
  static const _voiceCandidates = {
    'pt': ['pt-BR', 'pt-PT'],
    'en': ['en-US', 'en-GB', 'en-AU'],
    'es': ['es-MX', 'es-US', 'es-419', 'es-ES'],
  };

  /// Voz escolhida por língua (null = nenhuma instalada).
  final Map<String, String?> _voiceByLanguage = {};

  static String _languageCode(String language) =>
      language.split(RegExp(r'[_-]')).first.toLowerCase();

  /// Locale da voz instalada para [language] (`pt`, `en`, `es`), ou null.
  /// Android: "disponível" não quer dizer baixada — sem a voz local o motor
  /// lê com a voz padrão (o inglês saía com sotaque português). Exige a voz
  /// instalada.
  Future<String?> _voiceFor(String language) async {
    final code = _languageCode(language);
    if (_voiceByLanguage.containsKey(code)) return _voiceByLanguage[code];
    await _ensureConfigured();
    String? found;
    for (final locale in _voiceCandidates[code] ?? [language]) {
      try {
        final dynamic ok = defaultTargetPlatform == TargetPlatform.android
            ? await _tts.isLanguageInstalled(locale)
            : await _tts.isLanguageAvailable(locale);
        if (ok == true) {
          found = locale;
          break;
        }
      } catch (_) {}
    }
    _voiceByLanguage[code] = found;
    debugPrint('TtsService: voz $code → ${found ?? 'nenhuma'}');
    return found;
  }

  /// O aparelho tem voz para ler texto em [language] (`pt`, `en`, `es`)?
  Future<bool> hasVoice(String language) async =>
      await _voiceFor(language) != null;

  /// Locale para `setLanguage`: a voz instalada; sem ela, o 1º candidato
  /// (português segue lendo como antes mesmo sem a checagem passar).
  Future<String> _localeFor(String language) async {
    final code = _languageCode(language);
    return await _voiceFor(code) ?? (_voiceCandidates[code]?.first ?? 'pt-BR');
  }

  /// Quem pediu a sequência atual (ex.: "gn:1") — o leitor só destaca a sua.
  String? get sequenceKey => _inSequence ? _sequenceKey : null;

  /// Parte que está sendo lida agora na sequência.
  int? get sequenceIndex => _inSequence ? _sequenceIndex : null;

  /// Mesma configuração para chamadas simultâneas: antes, a 2ª seguia sem
  /// esperar prefs/handlers.
  Future<void>? _configuring;

  Future<void> _ensureConfigured() => _configuring ??= _configure();

  Future<void> _configure() async {
    await _loadPrefs();
    try {
      await _tts.setLanguage('pt-BR');
      await _tts.setSpeechRate(_speed.rate);
      _tts.setProgressHandler((text, start, end, word) {
        if (start < 0 || end <= start) return;
        wordRange.value = (start: start, end: end);
      });
      _tts.setCompletionHandler(() {
        wordRange.value = null;
        _fallbackOnError = null;
        if (_inSequence) return;
        _speaking = false;
        notifyListeners();
      });
      _tts.setCancelHandler(() {
        wordRange.value = null;
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

  /// Lê [text] com a voz de [language] (`pt`, `en`, `es`).
  Future<void> speak(String text, {String language = 'pt'}) async {
    if (text.trim().isEmpty) return;
    await _ensureConfigured();
    _endSequence();
    // stop()/outro pedido durante a busca da voz cancela este.
    final gen = _sequenceGen;
    _fallbackOnError = null;
    final locale = await _localeFor(language);
    if (gen != _sequenceGen) return;
    try {
      await _tts.stop();
      await _tts.setLanguage(locale);
      await _applyVoice(language);
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
  ///
  /// [language] é a língua do texto (`pt`, `en`, `es`); [languages], se
  /// vier, dá a língua de cada parte (ex.: versículo PT + insight em EN).
  Future<void> speakSequence(
    List<String> parts, {
    required String key,
    int start = 0,
    String language = 'pt',
    List<String>? languages,
  }) async {
    if (parts.isEmpty) return;
    await _ensureConfigured();
    final gen = ++_sequenceGen;
    _fallbackOnError = null;
    final locales = <String, String>{};
    for (final l in {language, ...?languages}) {
      locales[l] = await _localeFor(l);
    }
    if (gen != _sequenceGen) return;
    String langAt(int i) =>
        languages != null && i < languages.length ? languages[i] : language;
    var current = locales[langAt(start.clamp(0, parts.length - 1))]!;
    try {
      await _tts.stop();
      await _tts.setLanguage(current);
      await _applyVoice(langAt(start.clamp(0, parts.length - 1)));
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
        final locale = locales[langAt(i)]!;
        if (locale != current) {
          current = locale;
          await _tts.setLanguage(locale);
          await _applyVoice(langAt(i));
        }
        wordRange.value = null;
        // Versículo vazio (a BSB omite alguns): speak('') pode não disparar
        // a conclusão e a sequência travava ali.
        if (parts[i].trim().isEmpty) continue;
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
    wordRange.value = null;
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
