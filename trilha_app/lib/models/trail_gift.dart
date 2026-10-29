import 'dart:math';

/// Passe de trilha: quem tem o Peregrino+ libera, uma vez por mês, uma
/// trilha do Plus para outra pessoa. Doc `trailGifts/{code}`; o marco do
/// mês fica em `users/{uid}/giftMonths/{mês}` (ver firestore.rules).
class TrailGift {
  final String code;
  final String trailSlug;
  final String fromUid;
  final String fromName;
  final String? toName;

  const TrailGift({
    required this.code,
    required this.trailSlug,
    required this.fromUid,
    required this.fromName,
    this.toName,
  });

  /// Alguém já recebeu este passe.
  bool get redeemed => toName != null;

  TrailGift withTrail(String slug) => TrailGift(
    code: code,
    trailSlug: slug,
    fromUid: fromUid,
    fromName: fromName,
    toName: toName,
  );

  static TrailGift? fromMap(String code, Map<String, dynamic>? data) {
    if (data == null) return null;
    final slug = data['trailSlug'];
    final from = data['fromUid'];
    if (slug is! String || from is! String) return null;
    final toUid = data['toUid'];
    return TrailGift(
      code: code,
      trailSlug: slug,
      fromUid: from,
      fromName: data['fromName'] as String? ?? '',
      toName: toUid is String ? (data['toName'] as String? ?? '') : null,
    );
  }

  /// Mês do passe em UTC (`2026-10`) — o mesmo que a regra calcula com
  /// `request.time`.
  static String monthKey(DateTime now) {
    final utc = now.toUtc();
    return '${utc.year}-${utc.month.toString().padLeft(2, '0')}';
  }

  /// Sem 0/O e 1/I: o código pode ser lido em voz alta ou digitado.
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String newCode([Random? random]) {
    final r = random ?? Random.secure();
    return List.generate(
      8,
      (_) => _alphabet[r.nextInt(_alphabet.length)],
    ).join();
  }
}

/// Resultado de abrir o link de um passe.
enum TrailGiftRedeem {
  /// Liberada agora (ou já era deste peregrino).
  done,

  /// Sem conta: o passe precisa de um uid para ficar guardado.
  needsAccount,

  /// Código que não existe.
  invalid,

  /// O próprio passe de quem abriu.
  own,

  /// Outra pessoa já recebeu.
  taken,

  /// Quem abriu já tem o Plus ou já tem esta trilha: o passe fica para
  /// outra pessoa.
  notNeeded,

  failed,
}
