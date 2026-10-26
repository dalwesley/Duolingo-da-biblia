import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Aparelho de teste automático (Firebase Test Lab / pré-lançamento do Play).
///
/// O robô faz login e abre o app todo dia: sem este filtro ele aparece no
/// ranking da Caravana e no "estudando".
class TestDevice {
  static const _channel = MethodChannel('stway/device');
  static Future<bool>? _isTestLab;

  static Future<bool> isTestLab() => _isTestLab ??= _read();

  static Future<bool> _read() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('isTestLab') ?? false;
    } catch (_) {
      return false;
    }
  }
}
