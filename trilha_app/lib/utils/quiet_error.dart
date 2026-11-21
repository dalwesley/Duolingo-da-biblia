import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Erro que não pode travar a tela, mas precisa aparecer: segue em frente
/// e manda ao Crashlytics como não fatal (fora do modo debug). [where] diz
/// de onde veio ("sync:save", "plus:cache"…) para agrupar no painel.
///
/// Para falha esperada (sem rede, preferência local), use [report] false:
/// só o log do debug.
void quietError(
  Object error,
  StackTrace? stack,
  String where, {
  bool report = true,
}) {
  debugPrint('[$where] $error');
  if (!report || kDebugMode) return;
  try {
    if (Firebase.apps.isEmpty) return;
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: where,
      fatal: false,
    );
  } catch (_) {
    // O próprio relato não pode derrubar nada.
  }
}
