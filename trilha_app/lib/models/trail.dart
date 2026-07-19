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

  const Mission({
    required this.slug,
    required this.title,
    this.subtitle = '',
    required this.intro,
    required this.type,
    required this.stepsReward,
    required this.questions,
  });

  bool get isBoss => type == 'boss';

  factory Mission.fromJson(Map<String, dynamic> json) {
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
      color: json['color'] as String? ?? '#2F5D4A',
      realmId: json['realm'] as String? ?? 'antigo-testamento',
      categoryId: json['category'] as String? ?? 'pentateuco',
      modules: (json['modules'] as List? ?? [])
          .map((e) => TrailModule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
