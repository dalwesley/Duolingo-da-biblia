import 'package:flutter/foundation.dart';

import 'network_reachability_stub.dart'
    if (dart.library.io) 'network_reachability_io.dart' as impl;

/// Checagem leve de rede — sem pacote extra.
class NetworkReachability {
  NetworkReachability._();

  /// True se há caminho de rede utilizável (proxy de “tem internet”).
  static Future<bool> hasInternet({
    Duration timeout = const Duration(seconds: 3),
  }) {
    if (kIsWeb) return Future.value(true);
    return impl.hasInternet(timeout: timeout);
  }
}
