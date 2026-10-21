import 'package:flutter/foundation.dart';

/// Uma linha do registro do Peregrino+.
class PlusLogEntry {
  final DateTime at;
  final String area;
  final String message;

  const PlusLogEntry(this.at, this.area, this.message);

  String get time =>
      '${at.hour.toString().padLeft(2, '0')}:'
      '${at.minute.toString().padLeft(2, '0')}:'
      '${at.second.toString().padLeft(2, '0')}';

  @override
  String toString() => '$time [$area] $message';
}

/// Registro do Peregrino+: loja, acesso e travas. Cada linha vai para o
/// console com a tag `[Plus:area]` (no Android, `adb logcat | grep Plus`)
/// e as últimas ficam na memória para o Laboratório mostrar.
///
/// Nada de dado pessoal: nem e-mail nem uid inteiro.
class PlusLog extends ChangeNotifier {
  PlusLog._();

  static final instance = PlusLog._();

  static const _max = 300;

  final List<PlusLogEntry> _entries = [];

  /// Mais recentes primeiro.
  List<PlusLogEntry> get entries => _entries.reversed.toList(growable: false);

  static void log(String area, String message) =>
      instance._add(PlusLogEntry(DateTime.now(), area, message));

  void _add(PlusLogEntry entry) {
    debugPrint('[Plus:${entry.area}] ${entry.message}');
    _entries.add(entry);
    if (_entries.length > _max) _entries.removeAt(0);
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }

  /// Texto para copiar e colar (mais antigas primeiro).
  String dump() => _entries.map((e) => e.toString()).join('\n');

  /// Uid encurtado: dá para distinguir contas sem expor o id.
  static String shortUid(String? uid) {
    if (uid == null || uid.isEmpty) return '-';
    return uid.length <= 6 ? uid : '${uid.substring(0, 6)}…';
  }
}
