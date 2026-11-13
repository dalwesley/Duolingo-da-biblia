import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/room_week.dart';
import 'package:trilha_app/models/study_room.dart';

const week = '2026-11-09';
const study = RoomStudy(missionSlug: 'evg-01', title: 'O Verbo', week: week);
const reading = RoomReading(
  bookAbbrev: 'Jo',
  bookName: 'João',
  from: 1,
  to: 3,
  week: week,
);

RoomMember m(
  String uid, {
  bool studied = false,
  int read = 0,
  List<int> days = const [],
  String readWeek = week,
}) => RoomMember(
  uid: uid,
  name: uid.toUpperCase(),
  steps: 0,
  studyDone: studied ? RoomMember.studyDoneKey(study) : null,
  readingDone: read,
  readingWeek: readWeek,
  weekDays: days,
);

void main() {
  test('fiel = fez estudo e leitura; constante = mais dias; % do grupo', () {
    final w = RoomWeek.of(
      members: [
        m('ana', studied: true, read: 3, days: [1, 2, 3, 4]),
        m('bia', studied: true, read: 1, days: [1, 2, 3, 4]),
        m('caio', read: 3, days: [2]),
        m('davi', studied: true, read: 3, days: [5], readWeek: '2026-11-02'),
      ],
      study: study,
      reading: reading,
    );
    expect(w.faithful.map((e) => e.member.uid), ['ana']);
    expect(w.mostConstant.map((e) => e.member.uid).toSet(), {'ana', 'bia'});
    // ana 1 · bia (1+1/3)/2 · caio (0+1)/2 · davi leitura de outra semana (1+0)/2
    expect(w.groupPct, 67);
    expect(w.entries.first.member.uid, 'ana');
    final c = w.close(week: week);
    expect(c.faithful, ['ana']);
    expect(c.readingLabel, 'João 1–3');
    final back = RoomClosing.fromMap(c.toMap())!;
    expect(back.groupPct, 67);
    expect(back.nameOf('bia'), 'BIA');
  });

  test('sem nada marcado, fiel é estudar 3 dias', () {
    final w = RoomWeek.of(
      members: [
        m('ana', days: [1, 2, 3]),
        m('bia', days: [1]),
      ],
    );
    expect(w.faithful.map((e) => e.member.uid), ['ana']);
    expect(w.groupPct, 67);
  });

  test('quem mais cresceu: maior variação da semana, mínimo 5 pontos', () {
    RoomMember g(String uid, int? pts, {String w = week}) => RoomMember(
      uid: uid,
      name: uid,
      steps: 0,
      growthPts: pts,
      growthWeek: w,
    );
    final w = RoomWeek.of(
      members: [
        g('ana', 12),
        g('bia', 12),
        g('caio', 4),
        g('davi', 30, w: '2026-11-02'), // semana passada: não conta
      ],
      week: week,
    );
    expect(w.mostGrown.map((e) => e.member.uid).toSet(), {'ana', 'bia'});
    expect(w.close(week: week).grown.toSet(), {'ana', 'bia'});
    final none = RoomWeek.of(members: [g('caio', 4)], week: week);
    expect(none.mostGrown, isEmpty);
  });

  test('leitura inválida não abre (mais de 10 capítulos)', () {
    expect(
      RoomReading.fromMap({
        'bookAbbrev': 'Sl',
        'bookName': 'Salmos',
        'from': 1,
        'to': 11,
        'week': week,
      }),
      isNull,
    );
  });
}
