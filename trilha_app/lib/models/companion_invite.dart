/// Convite direto para a companhia: quem tem o convite aberto chama alguém
/// da Caravana pelo nome, sem passar código.
///
/// Um doc por código (`companionInvites/{code}`): a companhia tem uma vaga
/// só, então chamar outra pessoa troca o destinatário do mesmo convite.
enum CompanionInviteStatus {
  pending,
  accepted,
  declined,
  cancelled;

  static CompanionInviteStatus? fromKey(String? key) {
    for (final s in values) {
      if (s.name == key) return s;
    }
    return null;
  }
}

class CompanionInvite {
  final String code;
  final String fromUid;
  final String fromName;
  final String? fromPhotoUrl;
  final String toUid;
  final String toName;
  final CompanionInviteStatus status;

  const CompanionInvite({
    required this.code,
    required this.fromUid,
    required this.fromName,
    required this.toUid,
    required this.toName,
    required this.status,
    this.fromPhotoUrl,
  });

  bool get isPending => status == CompanionInviteStatus.pending;

  static CompanionInvite? fromDoc(String id, Map<String, dynamic> data) {
    final status = CompanionInviteStatus.fromKey(data['status'] as String?);
    final code = (data['code'] as String?)?.trim().toUpperCase() ?? '';
    final fromUid = (data['fromUid'] as String?)?.trim() ?? '';
    final toUid = (data['toUid'] as String?)?.trim() ?? '';
    final fromName = (data['fromName'] as String?)?.trim() ?? '';
    final toName = (data['toName'] as String?)?.trim() ?? '';
    if (status == null ||
        code.isEmpty ||
        code != id ||
        fromUid.isEmpty ||
        toUid.isEmpty ||
        fromName.isEmpty) {
      return null;
    }
    final photo = (data['fromPhotoUrl'] as String?)?.trim();
    return CompanionInvite(
      code: code,
      fromUid: fromUid,
      fromName: fromName,
      fromPhotoUrl: photo == null || photo.isEmpty ? null : photo,
      toUid: toUid,
      toName: toName,
      status: status,
    );
  }
}
