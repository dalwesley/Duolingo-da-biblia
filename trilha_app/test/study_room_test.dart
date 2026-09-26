import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/study_room.dart';

void main() {
  test('tipo desconhecido ou ausente vira célula', () {
    expect(RoomKind.fromKey(null), RoomKind.celula);
    expect(RoomKind.fromKey('xyz'), RoomKind.celula);
    expect(RoomKind.fromKey('ebd'), RoomKind.ebd);
  });

  test('estudo só vale na semana em que foi marcado', () {
    final room = StudyRoom.fromMap('ABC123', {
      'name': 'Célula Norte',
      'ownerId': 'u1',
      'kind': 'discipulado',
      'study': {
        'missionSlug': 'gen-01-criador',
        'title': 'O Criador',
        'week': '2026-09-21',
        'note': 'Leiam até quarta',
      },
    });
    expect(room.kind, RoomKind.discipulado);
    expect(room.studyFor('2026-09-21')?.missionSlug, 'gen-01-criador');
    expect(room.studyFor('2026-09-28'), isNull);
  });

  test('membro marca o estudo com slug@semana', () {
    const study = RoomStudy(
      missionSlug: 'gen-01-criador',
      title: 'O Criador',
      week: '2026-09-21',
    );
    const done = RoomMember(
      uid: 'u2',
      name: 'Ana',
      steps: 10,
      studyDone: 'gen-01-criador@2026-09-21',
    );
    const lastWeek = RoomMember(
      uid: 'u3',
      name: 'Beto',
      steps: 0,
      studyDone: 'gen-01-criador@2026-09-14',
    );
    expect(done.didStudy(study), isTrue);
    expect(lastWeek.didStudy(study), isFalse);
  });

  test('convite do grupo lê o documento', () {
    final invite = RoomInvite.fromDoc('ABC123_u2', {
      'roomCode': 'abc123',
      'roomName': 'Célula Norte',
      'kind': 'celula',
      'fromUid': 'u1',
      'fromName': 'Dalwesley',
      'toUid': 'u2',
      'toName': 'Ana',
      'status': 'pending',
    });
    expect(invite, isNotNull);
    expect(invite!.isPending, isTrue);
    expect(invite.roomCode, 'ABC123');
    expect(invite.kind, RoomKind.celula);
    expect(RoomInvite.docId('abc123', 'u2'), invite.id);
    expect(RoomInvite.fromDoc('x', {'status': 'nope'}), isNull);
  });

  test('dias sem estudar', () {
    const m = RoomMember(uid: 'u', name: 'A', steps: 0, lastWalk: '2026-09-20');
    expect(m.daysSinceWalk(DateTime(2026, 9, 25, 13)), 5);
    const never = RoomMember(uid: 'u', name: 'A', steps: 0);
    expect(never.daysSinceWalk(), isNull);
  });
}
