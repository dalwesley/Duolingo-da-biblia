import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sons e feedback tátil nas lições.
class SoundService {
  static final SoundService instance = SoundService._();
  SoundService._();

  AudioPlayer? _player;
  bool _enabled = true;
  bool _available = true;

  bool get enabled => _enabled;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('sound') ?? true;
    try {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      _player = player;
    } on MissingPluginException {
      _available = false;
    } catch (_) {
      _available = false;
    }
  }

  void setEnabled(bool value) => _enabled = value;

  Future<void> playCorrect() async {
    HapticFeedback.lightImpact();
    if (!_enabled) return;
    await _playAsset('sounds/correct.mp3', fallback: SystemSoundType.click);
  }

  Future<void> playWrong() async {
    HapticFeedback.mediumImpact();
    if (!_enabled) return;
    await _playAsset('sounds/wrong.mp3', fallback: SystemSoundType.alert);
  }

  Future<void> playComplete({bool boss = false}) async {
    HapticFeedback.heavyImpact();
    if (!_enabled) return;
    await _playAsset(boss ? 'sounds/boss_complete.mp3' : 'sounds/complete.mp3', fallback: SystemSoundType.click);
  }

  Future<void> playStreak() async {
    HapticFeedback.selectionClick();
    if (!_enabled) return;
    await _playAsset('sounds/streak.mp3', fallback: SystemSoundType.click);
  }

  Future<void> _playAsset(String asset, {required SystemSoundType fallback}) async {
    final player = _player;
    if (!_available || player == null) {
      await SystemSound.play(fallback);
      return;
    }
    try {
      await player.play(AssetSource(asset));
    } catch (_) {
      await SystemSound.play(fallback);
    }
  }
}
