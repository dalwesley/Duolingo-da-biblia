import 'dart:math';
import '../models/trail.dart';

enum TrailDifficulty {
  semente,
  caminhada,
  profundezas;

  String get id => name;

  /// Próximo modo (Semente → Rota → Profundezas).
  TrailDifficulty? get next {
    return switch (this) {
      TrailDifficulty.semente => TrailDifficulty.caminhada,
      TrailDifficulty.caminhada => TrailDifficulty.profundezas,
      TrailDifficulty.profundezas => null,
    };
  }

  String get labelPt {
    return switch (this) {
      TrailDifficulty.semente => 'Semente',
      TrailDifficulty.caminhada => 'Rota',
      TrailDifficulty.profundezas => 'Profundezas',
    };
  }

  static TrailDifficulty? fromId(String? id) {
    if (id == null) return null;
    for (final d in TrailDifficulty.values) {
      if (d.id == id) return d;
    }
    return null;
  }
}

class DifficultyMeta {
  final TrailDifficulty difficulty;
  final String label;
  final String subtitle;
  final String description;
  final double stepsMultiplier;
  final String accent;
  final String icon;

  const DifficultyMeta({
    required this.difficulty,
    required this.label,
    required this.subtitle,
    required this.description,
    required this.stepsMultiplier,
    required this.accent,
    required this.icon,
  });

  factory DifficultyMeta.fromJson(Map<String, dynamic> json) {
    return DifficultyMeta(
      difficulty: TrailDifficulty.fromId(json['id'] as String) ?? TrailDifficulty.semente,
      label: json['label'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      stepsMultiplier: ((json['stepsMultiplier'] ?? json['xpMultiplier']) as num).toDouble(),
      accent: json['accent'] as String,
      icon: json['icon'] as String,
    );
  }
}

class BankQuestion {
  final String id;
  final String trailSlug;
  final TrailDifficulty difficulty;
  final String section;
  final String question;
  final List<QuestionOption> options;
  final String correctOptionId;
  final String feedbackCorrect;
  final Map<String, String> feedbackWrong;
  final String? verseRef;
  final String? reveal;
  final ExerciseType type;
  final String? prompt;
  final String? cue;
  final String? correctAnswer;
  final String? passageText;
  final String? template;
  final ExercisePassage? passageA;
  final ExercisePassage? passageB;
  final List<String> correctOrder;
  final String? note;
  final String? noteLabel;
  final String? beat;
  final String? skill;

  const BankQuestion({
    required this.id,
    this.trailSlug = 'genesis-1-11',
    required this.difficulty,
    required this.section,
    required this.question,
    required this.options,
    required this.correctOptionId,
    required this.feedbackCorrect,
    required this.feedbackWrong,
    this.verseRef,
    this.reveal,
    this.type = ExerciseType.choice,
    this.prompt,
    this.cue,
    this.correctAnswer,
    this.passageText,
    this.template,
    this.passageA,
    this.passageB,
    this.correctOrder = const [],
    this.note,
    this.noteLabel,
    this.beat,
    this.skill,
  });

  factory BankQuestion.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final inferredTrail = id.startsWith('e-')
        ? 'exodo'
        : id.startsWith('g-')
            ? 'genesis-1-11'
            : 'genesis-1-11';
    final options = (json['options'] as List? ?? [])
        .whereType<Map>()
        .map((e) => QuestionOption.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final wrongRaw = json['feedbackWrong'];
    ExercisePassage? parsePassage(dynamic raw) {
      if (raw is! Map) return null;
      final text = (raw['text'] ?? '').toString();
      if (text.trim().isEmpty) return null;
      return ExercisePassage(
        ref: (raw['ref'] ?? '').toString(),
        text: text,
      );
    }

    final order = <String>[];
    final rawOrder = json['correctOrder'];
    if (rawOrder is List) {
      for (final o in rawOrder) {
        if (o != null) order.add(o.toString());
      }
    }

    return BankQuestion(
      id: id,
      trailSlug: json['trail'] as String? ??
          json['trailSlug'] as String? ??
          inferredTrail,
      difficulty: TrailDifficulty.fromId(json['difficulty'] as String) ?? TrailDifficulty.semente,
      section: json['section'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: options,
      correctOptionId: json['correctOptionId'] as String? ?? 'a',
      feedbackCorrect: json['feedbackCorrect'] as String? ?? 'Correto.',
      feedbackWrong: wrongRaw is Map
          ? wrongRaw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))
          : const {},
      verseRef: json['verseRef'] as String?,
      reveal: json['reveal'] == null || json['reveal'] == 'null' ? null : json['reveal'] as String?,
      type: ExerciseType.fromId(json['type'] as String?),
      prompt: json['prompt'] as String?,
      cue: json['cue'] as String?,
      correctAnswer: json['correctAnswer'] as String?,
      passageText: json['passageText'] as String?,
      template: json['template'] as String?,
      passageA: parsePassage(json['passageA']),
      passageB: parsePassage(json['passageB']),
      correctOrder: order,
      note: json['note'] as String?,
      noteLabel: json['noteLabel'] as String?,
      beat: json['beat'] as String?,
      skill: json['skill'] as String?,
    );
  }

  Question toQuestion({bool shuffleOptions = false, Random? rng}) {
    var opts = List<QuestionOption>.from(options);
    if (shuffleOptions) {
      opts = [...opts]..shuffle(rng ?? Random());
    }
    return Question(
      question: question,
      options: opts,
      correctOptionId: correctOptionId,
      feedbackCorrect: feedbackCorrect,
      feedbackWrong: feedbackWrong,
      verseRef: verseRef,
    );
  }
}

/// Mapeia título da cena (módulo) → seção do banco de perguntas.
String moduleTitleToSection(String? moduleTitle, {String? trailSlug}) {
  final title = moduleTitle?.trim() ?? '';
  if (trailSlug == 'exodo') {
    return switch (title) {
      'Opressão no Egito' => 'opressao',
      'A Libertação' => 'libertacao',
      'No deserto' => 'deserto',
      _ => 'opressao',
    };
  }
  return switch (title) {
    'A Criação' => 'criacao',
    'O Jardim' => 'jardim',
    'Depois do Éden' => 'depois',
    _ => 'criacao',
  };
}
