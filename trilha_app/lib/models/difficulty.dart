import 'dart:math';
import '../models/trail.dart';

enum TrailDifficulty {
  semente,
  caminhada,
  profundezas;

  String get id => name;

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
  final double xpMultiplier;
  final String accent;
  final String icon;

  const DifficultyMeta({
    required this.difficulty,
    required this.label,
    required this.subtitle,
    required this.description,
    required this.xpMultiplier,
    required this.accent,
    required this.icon,
  });

  factory DifficultyMeta.fromJson(Map<String, dynamic> json) {
    return DifficultyMeta(
      difficulty: TrailDifficulty.fromId(json['id'] as String) ?? TrailDifficulty.semente,
      label: json['label'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      xpMultiplier: (json['xpMultiplier'] as num).toDouble(),
      accent: json['accent'] as String,
      icon: json['icon'] as String,
    );
  }
}

class BankQuestion {
  final String id;
  final TrailDifficulty difficulty;
  final String section;
  final String question;
  final List<QuestionOption> options;
  final String correctOptionId;
  final String feedbackCorrect;
  final Map<String, String> feedbackWrong;
  final String? verseRef;
  final String? reveal;

  const BankQuestion({
    required this.id,
    required this.difficulty,
    required this.section,
    required this.question,
    required this.options,
    required this.correctOptionId,
    required this.feedbackCorrect,
    required this.feedbackWrong,
    this.verseRef,
    this.reveal,
  });

  factory BankQuestion.fromJson(Map<String, dynamic> json) {
    return BankQuestion(
      id: json['id'] as String,
      difficulty: TrailDifficulty.fromId(json['difficulty'] as String) ?? TrailDifficulty.semente,
      section: json['section'] as String,
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
      reveal: json['reveal'] == null || json['reveal'] == 'null' ? null : json['reveal'] as String?,
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

String moduleTitleToSection(String? moduleTitle) {
  return switch (moduleTitle) {
    'A Criação' => 'criacao',
    'O Jardim' => 'jardim',
    'Depois do Éden' => 'depois',
    _ => 'criacao',
  };
}
