import 'package:shared_preferences/shared_preferences.dart';

/// Qual convite a folha da aba Juntos oferece.
enum JuntosInviteKind {
  /// Formar dupla ou grupo antes da foto do 1º dia do Advento.
  advent,

  /// Convite que vira 1 mês de Plus quando a pessoa assina.
  referral,
}

/// Ritmo da folha de convite na aba Juntos: até [perWeek] vezes por semana
/// civil (segunda), com [minGapDays] dias entre uma e outra. Cada folha
/// para de vez quando a pessoa compartilha o convite dela (o Advento também
/// quando a dupla/grupo já está formado) ou depois de [maxDeclines]
/// "Agora não".
class JuntosInvitePace {
  JuntosInvitePace._();

  static const perWeek = 2;
  static const minGapDays = 2;
  static const maxDeclines = 3;

  /// O convite do Advento começa a aparecer tantos dias antes da foto.
  static const adventLeadDays = 21;

  static const shownKey = 'juntos_invite_shown';
  static String actedKey(JuntosInviteKind k) => 'juntos_invite_acted_${k.name}';
  static String declinesKey(JuntosInviteKind k) =>
      'juntos_invite_declines_${k.name}';

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime _monday(DateTime d) =>
      _day(d).subtract(Duration(days: d.weekday - DateTime.monday));

  /// Qual folha mostrar agora, ou null.
  ///
  /// [rosterAt] é a foto do 1º dia do Advento (null fora de campanha com
  /// prêmio). [shownMs] são os instantes em que a folha já abriu.
  static JuntosInviteKind? pick({
    required DateTime now,
    required DateTime? rosterAt,
    required bool adventDone,
    required bool referralDone,
    required int adventDeclines,
    required int referralDeclines,
    required List<int> shownMs,
  }) {
    final today = _day(now);
    final week = _monday(now);
    var thisWeek = 0;
    DateTime? last;
    for (final ms in shownMs) {
      final at = DateTime.fromMillisecondsSinceEpoch(ms);
      if (!_day(at).isBefore(week)) thisWeek++;
      if (last == null || at.isAfter(last)) last = at;
    }
    if (thisWeek >= perWeek) return null;
    if (last != null && today.difference(_day(last)).inDays < minGapDays) {
      return null;
    }

    final adventOpen =
        rosterAt != null &&
        !now.isAfter(rosterAt) &&
        !now.isBefore(rosterAt.subtract(const Duration(days: adventLeadDays)));
    if (adventOpen && !adventDone && adventDeclines < maxDeclines) {
      return JuntosInviteKind.advent;
    }
    if (!referralDone && referralDeclines < maxDeclines) {
      return JuntosInviteKind.referral;
    }
    return null;
  }

  static Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  static List<int> _shown(SharedPreferences p) => [
    for (final s in p.getStringList(shownKey) ?? const <String>[])
      ?int.tryParse(s),
  ];

  /// Lê o estado guardado e decide.
  static Future<JuntosInviteKind?> load({
    required DateTime now,
    required DateTime? rosterAt,
    required bool adventDone,

    /// Há um convite que conta para a indicação (Companhia com vaga ou
    /// grupo). Sem ele, a folha da indicação não aparece.
    bool canRefer = true,
  }) async {
    final p = await _prefs();
    if (p == null) return null;
    return pick(
      now: now,
      rosterAt: rosterAt,
      adventDone:
          adventDone || (p.getBool(actedKey(JuntosInviteKind.advent)) ?? false),
      referralDone:
          !canRefer ||
          (p.getBool(actedKey(JuntosInviteKind.referral)) ?? false),
      adventDeclines: p.getInt(declinesKey(JuntosInviteKind.advent)) ?? 0,
      referralDeclines: p.getInt(declinesKey(JuntosInviteKind.referral)) ?? 0,
      shownMs: _shown(p),
    );
  }

  static Future<void> markShown(DateTime at) async {
    final p = await _prefs();
    if (p == null) return;
    final list = [..._shown(p), at.millisecondsSinceEpoch];
    // Basta a última semana e pouco para o ritmo.
    final keep = list.length > 4 ? list.sublist(list.length - 4) : list;
    await p.setStringList(shownKey, [for (final ms in keep) '$ms']);
  }

  static Future<void> markDeclined(JuntosInviteKind kind) async {
    final p = await _prefs();
    if (p == null) return;
    final k = declinesKey(kind);
    await p.setInt(k, (p.getInt(k) ?? 0) + 1);
  }

  /// A pessoa compartilhou o convite desta folha: ela não volta.
  static Future<void> markActed(JuntosInviteKind kind) async {
    final p = await _prefs();
    if (p == null) return;
    await p.setBool(actedKey(kind), true);
  }

  /// Um convite de Companhia ou grupo saiu (QR, compartilhar, copiar):
  /// também conta como convidar alguém.
  static Future<void> markShared() => markActed(JuntosInviteKind.referral);

  /// Laboratório: volta tudo ao começo.
  static Future<void> reset() async {
    final p = await _prefs();
    if (p == null) return;
    await p.remove(shownKey);
    for (final k in JuntosInviteKind.values) {
      await p.remove(declinesKey(k));
      await p.remove(actedKey(k));
    }
  }
}
