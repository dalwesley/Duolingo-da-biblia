import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Inclinação do celular para o parallax do céu (splash e onboarding).
///
/// [value] vai de -1 a 1 em cada eixo, relativo a como a pessoa segurava
/// o aparelho quando o leitor ligou. Suavizado para não tremer.
/// Sem sensor (emulador, erro), fica em zero.
class TiltParallax extends ValueNotifier<Offset> {
  TiltParallax() : super(Offset.zero);

  /// Inclinação (em g) que leva o céu ao deslocamento máximo.
  static const _range = 0.22;
  static const _smooth = 0.2;

  StreamSubscription<AccelerometerEvent>? _sub;
  Offset? _rest;
  Offset _raw = Offset.zero;

  void start() {
    if (_sub != null || kIsWeb) return;
    // O plugin configura o sensor com uma chamada assíncrona que ninguém
    // aguarda; sem implementação nativa ela vira erro solto. A zona segura.
    runZonedGuarded(() {
      _sub = accelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(_onEvent, onError: (_) => stop(), cancelOnError: true);
    }, (_, _) => stop());
  }

  void _onEvent(AccelerometerEvent e) {
    final g = Offset(e.x / 9.81, e.y / 9.81);
    final rest = _rest ??= g;
    // Repouso segue a pessoa bem devagar (deitou, mudou a pegada).
    _rest = Offset.lerp(rest, g, 0.004);
    final d = g - rest;
    final target = Offset(
      (d.dx / _range).clamp(-1.0, 1.0),
      (d.dy / _range).clamp(-1.0, 1.0),
    );
    _raw = Offset.lerp(_raw, target, _smooth)!;
    value = _raw;
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
