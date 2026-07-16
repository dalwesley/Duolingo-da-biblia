/// Sala privada de caminhada — grupo fechado por código de convite.
class StudyRoom {
  final String code;
  final String name;
  final String ownerId;
  final String ownerName;
  final DateTime? createdAt;

  const StudyRoom({
    required this.code,
    required this.name,
    required this.ownerId,
    required this.ownerName,
    this.createdAt,
  });

  bool isOwner(String? uid) => uid != null && uid == ownerId;

  factory StudyRoom.fromMap(String code, Map<String, dynamic> data) {
    DateTime? createdAt;
    final raw = data['createdAt'];
    if (raw is DateTime) {
      createdAt = raw;
    } else {
      try {
        createdAt = (raw as dynamic)?.toDate() as DateTime?;
      } catch (_) {
        createdAt = null;
      }
    }
    return StudyRoom(
      code: code,
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? data['name'] as String
          : 'Sala',
      ownerId: (data['ownerId'] as String?) ?? '',
      ownerName: (data['ownerName'] as String?)?.trim().isNotEmpty == true
          ? data['ownerName'] as String
          : 'Anfitrião',
      createdAt: createdAt,
    );
  }
}

class RoomMember {
  final String uid;
  final String name;
  final int steps;
  final bool isUser;

  const RoomMember({
    required this.uid,
    required this.name,
    required this.steps,
    this.isUser = false,
  });
}
