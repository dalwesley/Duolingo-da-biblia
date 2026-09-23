import '../widgets/cinematic_icon.dart';
import 'caravan_pilgrim_profile.dart';
import 'caravan_profile_prefs.dart';
import 'pilgrim_medals.dart';
import 'trail.dart';

enum RecognitionGiveStatus { given, already, removed, failed }

/// O que foi reconhecido: a cena de um dia, ou uma medalha.
enum RecognitionKind {
  walk,
  medal;

  static RecognitionKind? parse(String? raw) => switch (raw) {
    'walk' => RecognitionKind.walk,
    'medal' => RecognitionKind.medal,
    _ => null,
  };
}

/// Um reconhecimento já recebido. O texto vem do catálogo, não de um
/// rótulo livre gravado por quem enviou.
class Recognition {
  final String id;
  final String fromUid;
  final String fromName;
  final String toUid;
  final RecognitionKind kind;
  final String subjectKey;
  final DateTime? createdAt;

  const Recognition({
    required this.id,
    required this.fromUid,
    required this.fromName,
    required this.toUid,
    required this.kind,
    required this.subjectKey,
    this.createdAt,
  });

  String get headline {
    final name = fromName.trim().isEmpty ? 'Alguém' : fromName.trim();
    if (kind == RecognitionKind.medal) {
      final title = medalTitleFor(subjectKey);
      if (title == null) return '$name reconheceu uma medalha sua';
      return '$name reconheceu a medalha $title';
    }
    return '$name reconheceu a sua cena';
  }

  /// O que foi visto, sem repetir quem enviou.
  String get subjectLabel {
    if (kind == RecognitionKind.walk) {
      return walkSubjectLabel(subjectKey);
    }
    return medalTitleFor(subjectKey) ?? 'Uma medalha';
  }

  /// Linha completa para histórico: quem · o quê.
  String get historyLine {
    final name = fromName.trim().isEmpty ? 'Alguém' : fromName.trim();
    return '$name · $subjectLabel';
  }

  /// Id estável: este remetente, esta pessoa, esta cena ou medalha, uma vez.
  static String docId({
    required String fromUid,
    required String toUid,
    required RecognitionKind kind,
    required String subjectKey,
  }) => '${fromUid}_${toUid}_${kind.name}_$subjectKey';

  static final _walkKey = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  static final _medalKey = RegExp(r'^[A-Za-z0-9:_-]{1,80}$');

  static bool validSubject(RecognitionKind kind, String subjectKey) {
    return switch (kind) {
      RecognitionKind.walk => _walkKey.hasMatch(subjectKey),
      RecognitionKind.medal => _medalKey.hasMatch(subjectKey),
    };
  }
}

/// Remetente + lista do que ele reconheceu.
class RecognitionSenderGroup {
  final String name;
  final List<Recognition> items;

  const RecognitionSenderGroup(this.name, this.items);
}

List<RecognitionSenderGroup> groupRecognitionsBySender(List<Recognition> items) {
  final order = <String>[];
  final map = <String, List<Recognition>>{};
  for (final item in items) {
    map
        .putIfAbsent(item.fromUid, () {
          order.add(item.fromUid);
          return [];
        })
        .add(item);
  }
  return [
    for (final uid in order)
      RecognitionSenderGroup(
        recognitionFromName(map[uid]!.first.fromName),
        map[uid]!,
      ),
  ];
}

/// Cena do dia — data curta em PT.
String walkSubjectLabel(String ymd) {
  final parts = ymd.split('-');
  if (parts.length != 3) return 'A sua cena';
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return 'A sua cena';
  const months = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];
  if (m < 1 || m > 12) return 'A sua cena';
  return 'Cena de $d ${months[m - 1]}';
}

/// Primeiro nome, curto, para o card de quem recebe.
String recognitionFromName(String raw) {
  final trimmed = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (trimmed.isEmpty) return 'Alguém';
  final first = trimmed.split(' ').first;
  if (first.length <= 40) return first;
  return first.substring(0, 40);
}

/// Dia da cena que a caravana pode ver. Respeita o que o perfil esconde.
String? recognizableWalkDate(CaravanPilgrimProfile profile) {
  final showMission = profile.prefs.shouldShow(
    CaravanProfileSection.lastMission,
    isOwner: false,
  );
  final showPresence = profile.prefs.shouldShow(
    CaravanProfileSection.presence,
    isOwner: false,
  );
  if (!showMission && !showPresence) return null;
  if (showMission && profile.lastMissionCompletedDate != null) {
    return profile.lastMissionCompletedDate;
  }
  if (showPresence && profile.lastWalkDate != null) {
    return profile.lastWalkDate;
  }
  if (showMission && profile.lastWalkDate != null) {
    return profile.lastWalkDate;
  }
  return null;
}

class RecognizableMedal {
  final String id;
  final String title;
  final String? group;
  final CinematicGlyph glyph;
  final PilgrimMedalTier tier;

  const RecognizableMedal({
    required this.id,
    required this.title,
    this.group,
    this.glyph = CinematicGlyph.gem,
    this.tier = PilgrimMedalTier.bronze,
  });
}

/// Medalhas já conquistadas que o visitante pode reconhecer, uma a uma.
List<RecognizableMedal> recognizableMedals({
  required CaravanPilgrimProfile profile,
  required List<Trail> catalog,
}) {
  if (!profile.prefs.shouldShow(CaravanProfileSection.medals, isOwner: false)) {
    return const [];
  }
  final vaults = PilgrimMedals.evaluateVaults(
    profile: profile,
    catalog: catalog,
  );
  final out = <RecognizableMedal>[];
  final seen = <String>{};
  void add(
    String id,
    String title,
    String? group,
    CinematicGlyph glyph,
    PilgrimMedalTier tier,
  ) {
    if (!Recognition.validSubject(RecognitionKind.medal, id)) return;
    if (!seen.add(id)) return;
    out.add(
      RecognizableMedal(
        id: id,
        title: title,
        group: group,
        glyph: glyph,
        tier: tier,
      ),
    );
  }

  for (final vault in vaults) {
    for (final trackState in vault.tracks) {
      if (!trackState.hasStarted) continue;
      final track = trackState.track;
      final last = trackState.levelIndex;
      for (var i = 0; i <= last && i < track.levels.length; i++) {
        final level = track.levels[i];
        add(level.id, level.title, track.title, track.glyph, level.tier);
      }
    }
    for (final rare in vault.rareMedals) {
      if (!rare.unlocked) continue;
      add(rare.def.id, rare.def.title, null, rare.def.glyph, rare.def.tier);
    }
  }
  return out;
}

/// Título da medalha a partir do id. Trilha usa o degrau, sem o nome do livro.
String? medalTitleFor(String id, {DateTime? now}) {
  for (final track in PilgrimMedalCatalog.journeyTracks) {
    for (final level in track.levels) {
      if (level.id == id) return level.title;
    }
  }
  for (final medal in PilgrimMedalCatalog.rareMedals) {
    if (medal.id == id) return medal.title;
  }
  final year = (now ?? DateTime.now()).year;
  for (final y in [year - 1, year, year + 1]) {
    for (final vault in [
      PilgrimMedalCatalog.adventVault(y),
      PilgrimMedalCatalog.lentVault(y),
    ]) {
      for (final track in vault.tracks) {
        for (final level in track.levels) {
          if (level.id == id) return level.title;
        }
      }
      for (final rare in vault.rareMedals) {
        if (rare.id == id) return rare.title;
      }
    }
  }
  if (id.startsWith('track:trail:')) {
    final index = int.tryParse(id.split(':').last);
    return switch (index) {
      0 => 'Primeiro passo',
      1 => 'Semente',
      2 => 'Caminhada',
      3 => 'Peregrino',
      _ => null,
    };
  }
  return null;
}
