import 'dart:math';
import '../l10n/l10n_global.dart';
import '../l10n/question_overlay.dart';
import '../models/trail.dart';

enum TrailDifficulty {
  semente,
  caminhada,
  profundezas;

  String get id => name;

  /// Próximo modo (Observação → Compreensão → Interpretação).
  TrailDifficulty? get next {
    return switch (this) {
      TrailDifficulty.semente => TrailDifficulty.caminhada,
      TrailDifficulty.caminhada => TrailDifficulty.profundezas,
      TrailDifficulty.profundezas => null,
    };
  }

  /// Modo anterior — o que precisa estar concluído para liberar este.
  TrailDifficulty? get previous {
    return switch (this) {
      TrailDifficulty.semente => null,
      TrailDifficulty.caminhada => TrailDifficulty.semente,
      TrailDifficulty.profundezas => TrailDifficulty.caminhada,
    };
  }

  String get labelPt {
    return switch (this) {
      TrailDifficulty.semente => L10n.current.modeSementeLabel,
      TrailDifficulty.caminhada => L10n.current.modeCaminhadaLabel,
      TrailDifficulty.profundezas => L10n.current.modeProfundezasLabel,
    };
  }

  /// Pergunta que o modo faz ao texto — mesma frase em todo o app.
  String get taglinePt {
    return switch (this) {
      TrailDifficulty.semente => L10n.current.modeSementeTagline,
      TrailDifficulty.caminhada => L10n.current.modeCaminhadaTagline,
      TrailDifficulty.profundezas => L10n.current.modeProfundezasTagline,
    };
  }

  /// Número do modo na escada (I, II, III).
  String get ordinalPt {
    return switch (this) {
      TrailDifficulty.semente => 'I',
      TrailDifficulty.caminhada => 'II',
      TrailDifficulty.profundezas => 'III',
    };
  }

  /// O que você exercita neste modo — três verbos.
  List<String> get skillsPt {
    final l = L10n.current;
    return switch (this) {
      TrailDifficulty.semente => [
        l.modeSementeSkill1,
        l.modeSementeSkill2,
        l.modeSementeSkill3,
      ],
      TrailDifficulty.caminhada => [
        l.modeCaminhadaSkill1,
        l.modeCaminhadaSkill2,
        l.modeCaminhadaSkill3,
      ],
      TrailDifficulty.profundezas => [
        l.modeProfundezasSkill1,
        l.modeProfundezasSkill2,
        l.modeProfundezasSkill3,
      ],
    };
  }

  /// Descrição breve do modo (1 linha, ~60 chars).
  String get blurbPt {
    return switch (this) {
      TrailDifficulty.semente => L10n.current.modeSementeBlurb,
      TrailDifficulty.caminhada => L10n.current.modeCaminhadaBlurb,
      TrailDifficulty.profundezas => L10n.current.modeProfundezasBlurb,
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

  /// Rótulo vindo do catálogo; `null` (ou legado) usa o nome do modo no
  /// idioma atual.
  final String? customLabel;
  String get label => customLabel ?? difficulty.labelPt;
  final String subtitle;
  final String description;
  final double stepsMultiplier;
  final String accent;
  final String icon;

  const DifficultyMeta({
    required this.difficulty,
    this.customLabel,
    required this.subtitle,
    required this.description,
    required this.stepsMultiplier,
    required this.accent,
    required this.icon,
  });

  factory DifficultyMeta.fromJson(Map<String, dynamic> json) {
    final difficulty =
        TrailDifficulty.fromId(json['id'] as String) ?? TrailDifficulty.semente;
    final rawLabel = (json['label'] as String?)?.trim();
    const legacy = {'Semente', 'Rota', 'Caminhada', 'Profundezas'};
    final label =
        rawLabel == null || rawLabel.isEmpty || legacy.contains(rawLabel)
        ? null
        : rawLabel;
    return DifficultyMeta(
      difficulty: difficulty,
      customLabel: label,
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      stepsMultiplier:
          ((json['stepsMultiplier'] ?? json['xpMultiplier']) as num).toDouble(),
      accent: json['accent'] as String? ?? '#D4A84B',
      icon: json['icon'] as String? ?? 'seed',
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
  final String? learningObjective;
  final List<String> evidence;

  /// Trecho literal do palco que prova a resposta (banco V3).
  final String? evidenceSpan;

  /// Aplica overlay EN/ES (enunciado, feedback, opções interpretativas).
  /// `passageText` / refs / tokens do versículo permanecem no PT base.
  BankQuestion withOverlay() {
    final ov = QuestionOverlay.instance;
    if (ov.entryFor(id) == null) return this;
    final stem = ov.promptFor(id);
    final cueOv = ov.cueFor(id);
    final lo = ov.field(id, 'learningObjective');
    final fc = ov.field(id, 'feedbackCorrect');
    final fwOv = ov.feedbackWrongFor(id);
    final mappedOpts = [
      for (final o in options)
        QuestionOption(id: o.id, text: ov.optionText(id, o.id) ?? o.text),
    ];
    final fw = fwOv == null
        ? feedbackWrong
        : {
            for (final e in feedbackWrong.entries)
              e.key: fwOv[e.key] ?? e.value,
          };
    return BankQuestion(
      id: id,
      trailSlug: trailSlug,
      difficulty: difficulty,
      section: section,
      question: stem ?? question,
      options: mappedOpts,
      correctOptionId: correctOptionId,
      feedbackCorrect: fc ?? feedbackCorrect,
      feedbackWrong: fw,
      verseRef: verseRef,
      reveal: reveal,
      type: type,
      prompt: stem ?? prompt,
      cue: cueOv ?? cue,
      correctAnswer: correctAnswer,
      passageText: passageText,
      template: template,
      passageA: passageA,
      passageB: passageB,
      correctOrder: correctOrder,
      note: note,
      noteLabel: noteLabel,
      beat: beat,
      skill: skill,
      learningObjective: lo ?? learningObjective,
      evidence: evidence,
      evidenceSpan: evidenceSpan,
    );
  }

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
    this.learningObjective,
    this.evidence = const [],
    this.evidenceSpan,
  });

  factory BankQuestion.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final inferredTrail = () {
      if (id.startsWith('e-') || id.startsWith('exodo-')) return 'exodo';
      if (id.startsWith('g-') ||
          id.startsWith('genesis--') ||
          id.startsWith('genesis-1-11-')) {
        return 'genesis-1-11';
      }
      if (id.startsWith('genesis-12') || id.startsWith('g1250-')) {
        return 'genesis-12-50';
      }
      if (id.startsWith('sm-') || id.startsWith('sermao-')) {
        return 'sermao-do-monte';
      }
      return 'genesis-1-11';
    }();
    final options = (json['options'] as List? ?? [])
        .whereType<Map>()
        .map((e) => QuestionOption.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final wrongRaw = json['feedbackWrong'];
    ExercisePassage? parsePassage(dynamic raw) {
      if (raw is! Map) return null;
      final text = (raw['text'] ?? '').toString();
      if (text.trim().isEmpty) return null;
      return ExercisePassage(ref: (raw['ref'] ?? '').toString(), text: text);
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
      trailSlug:
          json['trail'] as String? ??
          json['trailSlug'] as String? ??
          inferredTrail,
      difficulty:
          TrailDifficulty.fromId(json['difficulty'] as String) ??
          TrailDifficulty.semente,
      section: json['section'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: options,
      correctOptionId: json['correctOptionId'] as String? ?? 'a',
      feedbackCorrect: json['feedbackCorrect'] as String? ?? 'Correto.',
      feedbackWrong: wrongRaw is Map
          ? wrongRaw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))
          : const {},
      verseRef: json['verseRef'] as String?,
      reveal: json['reveal'] == null || json['reveal'] == 'null'
          ? null
          : json['reveal'] as String?,
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
      learningObjective: json['learningObjective'] as String?,
      evidence:
          (json['evidence'] as List?)
              ?.map((e) => e.toString())
              .where((s) => s.trim().isNotEmpty)
              .toList() ??
          const [],
      evidenceSpan: json['evidenceSpan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trail': trailSlug,
      'difficulty': difficulty.id,
      'section': section,
      'question': question,
      'options': options.map((o) => {'id': o.id, 'text': o.text}).toList(),
      'correctOptionId': correctOptionId,
      'feedbackCorrect': feedbackCorrect,
      'feedbackWrong': feedbackWrong,
      if (verseRef != null) 'verseRef': verseRef,
      if (reveal != null) 'reveal': reveal,
      'type': type.wireId,
      if (prompt != null) 'prompt': prompt,
      if (cue != null) 'cue': cue,
      if (correctAnswer != null) 'correctAnswer': correctAnswer,
      if (passageText != null) 'passageText': passageText,
      if (template != null) 'template': template,
      if (passageA != null) 'passageA': passageA!.toJson(),
      if (passageB != null) 'passageB': passageB!.toJson(),
      if (correctOrder.isNotEmpty) 'correctOrder': correctOrder,
      if (note != null) 'note': note,
      if (noteLabel != null) 'noteLabel': noteLabel,
      if (beat != null) 'beat': beat,
      if (skill != null) 'skill': skill,
      if (learningObjective != null && learningObjective!.isNotEmpty)
        'learningObjective': learningObjective,
      if (evidence.isNotEmpty) 'evidence': evidence,
      if (evidenceSpan != null) 'evidenceSpan': evidenceSpan,
    };
  }

  Question toQuestion({bool shuffleOptions = false, Random? rng}) {
    final bq = withOverlay();
    var opts = List<QuestionOption>.from(bq.options);
    if (shuffleOptions) {
      opts = [...opts]..shuffle(rng ?? Random());
    }
    return Question(
      question: bq.question,
      options: opts,
      correctOptionId: bq.correctOptionId,
      feedbackCorrect: bq.feedbackCorrect,
      feedbackWrong: bq.feedbackWrong,
      verseRef: bq.verseRef,
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
