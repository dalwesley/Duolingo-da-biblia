import 'exercise.dart';

export 'exercise.dart';

class QuestionOption {
  final String id;
  final String text;

  const QuestionOption({required this.id, required this.text});

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(id: json['id'] as String, text: json['text'] as String);
  }
}

class Question {
  final String question;
  final List<QuestionOption> options;
  final String correctOptionId;
  final String feedbackCorrect;
  final Map<String, String> feedbackWrong;
  final String? verseRef;

  const Question({
    required this.question,
    required this.options,
    required this.correctOptionId,
    required this.feedbackCorrect,
    required this.feedbackWrong,
    this.verseRef,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] as String,
      options: (json['options'] as List)
          .map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctOptionId: json['correctOptionId'] as String,
      feedbackCorrect: json['feedbackCorrect'] as String,
      feedbackWrong: (json['feedbackWrong'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v as String),
      ),
      verseRef: json['verseRef'] as String?,
    );
  }
}

class Mission {
  final String slug;
  final String title;
  final String subtitle;
  final String intro;
  final String type;
  final int stepsReward;
  final List<Question> questions;
  /// Learning Engine v2 — preservado no modelo para admin/legado;
  /// o runtime monta a sessão só pelo banco (`SessionComposer`).
  final List<Exercise> exercises;
  final String? objective;
  final String? centralInsight;
  /// Entrada bíblica (≤ ~5 s): verso + nota de contexto/curiosidade + fio de conexão.
  final String? hookRef;
  final String? hookVerse;
  final String? hookNote;
  final String? hookThread;

  const Mission({
    required this.slug,
    required this.title,
    this.subtitle = '',
    required this.intro,
    required this.type,
    required this.stepsReward,
    required this.questions,
    this.exercises = const [],
    this.objective,
    this.centralInsight,
    this.hookRef,
    this.hookVerse,
    this.hookNote,
    this.hookThread,
  });

  bool get isBoss => type == 'boss';

  bool get hasExercises => exercises.any((e) => e.hasPlayableContent);

  bool get hasBibleHook =>
      (hookVerse ?? '').trim().isNotEmpty || (hookNote ?? '').trim().isNotEmpty;

  factory Mission.fromJson(Map<String, dynamic> json) {
    final entrance = json['entrance'];
    Map<String, dynamic>? entranceMap;
    if (entrance is Map) {
      entranceMap = Map<String, dynamic>.from(entrance);
    }

    return Mission(
      slug: json['slug'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      intro: json['intro'] as String? ?? '',
      type: json['type'] as String? ?? 'lesson',
      stepsReward: (json['stepsReward'] as int?) ?? (json['xpReward'] as int?) ?? 50,
      questions: (json['questions'] as List? ?? [])
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
      exercises: (json['exercises'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Exercise.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      objective: json['objective'] as String?,
      centralInsight: json['centralInsight'] as String?,
      hookRef: json['hookRef'] as String? ?? entranceMap?['ref'] as String?,
      hookVerse: json['hookVerse'] as String? ?? entranceMap?['verse'] as String?,
      hookNote: json['hookNote'] as String? ?? entranceMap?['note'] as String?,
      hookThread:
          json['hookThread'] as String? ?? entranceMap?['thread'] as String?,
    );
  }
}

class TrailModule {
  final String title;
  final String icon;
  /// Chave do banco de perguntas (ex.: `abraao`, `opressao`).
  final String? section;
  final List<Mission> missions;

  const TrailModule({
    required this.title,
    required this.icon,
    this.section,
    required this.missions,
  });

  factory TrailModule.fromJson(Map<String, dynamic> json) {
    return TrailModule(
      title: json['title'] as String,
      icon: json['icon'] as String,
      section: json['section'] as String? ?? json['sectionId'] as String?,
      missions: (json['missions'] as List? ?? [])
          .map((e) => Mission.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Trail {
  final String slug;
  final String title;
  final String description;
  final String icon;
  final int order;
  final String? unlockAfter;
  final bool comingSoon;
  final String color;
  final String realmId;
  final String categoryId;
  final List<TrailModule> modules;

  const Trail({
    required this.slug,
    required this.title,
    required this.description,
    required this.icon,
    required this.order,
    this.unlockAfter,
    required this.comingSoon,
    required this.color,
    this.realmId = 'antigo-testamento',
    this.categoryId = 'pentateuco',
    required this.modules,
  });

  List<String> get missionSlugs =>
      modules.expand((m) => m.missions.map((mission) => mission.slug)).toList();

  factory Trail.fromJson(Map<String, dynamic> json) {
    return Trail(
      slug: json['slug'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      order: json['order'] as int? ?? 0,
      unlockAfter: json['unlockAfter'] as String?,
      comingSoon: json['comingSoon'] as bool? ?? false,
      color: json['color'] as String? ?? '#1B3A5C',
      realmId: json['realm'] as String? ?? 'antigo-testamento',
      categoryId: json['category'] as String? ?? 'pentateuco',
      modules: (json['modules'] as List? ?? [])
          .map((e) => TrailModule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
