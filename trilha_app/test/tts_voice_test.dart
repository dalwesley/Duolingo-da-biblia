import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/services/tts_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          call,
        ) async {
          switch (call.method) {
            case 'getVoices':
              return [
                {'name': 'pt-br-x-abc-local', 'locale': 'pt-BR'},
                {'name': 'en-gb-x-gba-local', 'locale': 'en-GB'},
                {'name': 'en-us-x-iob-local', 'locale': 'en-US'},
                {
                  'name': 'en-us-x-iob-network',
                  'locale': 'en-US',
                  'network_required': '1',
                },
                {
                  'name': 'en-us-x-zzz-local',
                  'locale': 'en-US',
                  'features': 'notInstalled',
                },
                {'name': 'Samantha', 'locale': 'en_US', 'gender': 'female'},
              ];
            default:
              return 1;
          }
        });
  });

  test('voicesFor keeps installed local voices of the language', () async {
    final voices = await TtsService.instance.voicesFor('en');
    expect(voices.map((v) => v.name), [
      'Samantha',
      'en-us-x-iob-local',
      'en-gb-x-gba-local',
    ]);
    expect(voices.first.gender, 'female');
    expect(voices.first.locale, 'en-US');
  });

  test('speed and voice choice are saved on the device', () async {
    final tts = TtsService.instance;
    await tts.setSpeed(TtsSpeed.fast);
    expect(tts.speed, TtsSpeed.fast);
    const voice = TtsVoice(name: 'en-gb-x-gba-local', locale: 'en-GB');
    await tts.setVoice('en', voice);
    expect(tts.chosenVoice('en'), voice);
    expect(tts.chosenVoice('es'), isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('tts.speed'), 'fast');
    expect(prefs.getString('tts.voice.en'), contains('en-gb-x-gba-local'));

    await tts.setVoice('en', null);
    expect(tts.chosenVoice('en'), isNull);
    expect(prefs.getString('tts.voice.en'), isNull);
    await tts.setSpeed(TtsSpeed.normal);
  });
}
