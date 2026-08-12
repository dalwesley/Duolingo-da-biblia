import 'trail.dart';

/// Tipos / gestos do contrato de sessão ([docs/SESSAO_TREINO.md]).
enum ExerciseType {
  choice,
  trueFalse,
  findInText,
  tap,
  connect,
  textSupported,
  order,
  match,
  complete,
  insight,
  explain,
  classify,
  review,
  bestInterpretation;

  static ExerciseType fromId(String? raw) {
    switch ((raw ?? 'choice').trim().toLowerCase()) {
      case 'true_false':
      case 'truefalse':
      case 'tf':
        return ExerciseType.trueFalse;
      case 'find_in_text':
      case 'findintext':
        return ExerciseType.findInText;
      case 'tap':
      case 'touch':
        return ExerciseType.tap;
      case 'connect':
        return ExerciseType.connect;
      case 'text_supported':
      case 'textsupported':
        return ExerciseType.textSupported;
      case 'order':
        return ExerciseType.order;
      case 'match':
      case 'pair':
        return ExerciseType.match;
      case 'complete':
      case 'fill':
        return ExerciseType.complete;
      case 'insight':
        return ExerciseType.insight;
      case 'explain':
        return ExerciseType.explain;
      case 'classify':
        return ExerciseType.classify;
      case 'review':
        return ExerciseType.review;
      case 'best_interpretation':
      case 'bestinterpretation':
        return ExerciseType.bestInterpretation;
      case 'choice':
      default:
        return ExerciseType.choice;
    }
  }

  String get wireId => switch (this) {
        ExerciseType.trueFalse => 'true_false',
        ExerciseType.findInText => 'find_in_text',
        ExerciseType.textSupported => 'text_supported',
        ExerciseType.bestInterpretation => 'best_interpretation',
        _ => name,
      };

  String get labelPt => switch (this) {
        ExerciseType.trueFalse => 'Verdadeiro / Falso',
        ExerciseType.findInText => 'No texto',
        ExerciseType.tap => 'Toque',
        ExerciseType.connect => 'Conecte',
        ExerciseType.textSupported => 'O texto diz',
        ExerciseType.choice => 'Escolha',
        ExerciseType.order => 'Ordene',
        ExerciseType.match => 'Emparelhe',
        ExerciseType.complete => 'Complete',
        ExerciseType.insight => 'Insight',
        ExerciseType.explain => 'Explique',
        ExerciseType.classify => 'Classifique',
        ExerciseType.review => 'Revisão',
        ExerciseType.bestInterpretation => 'Interpretação',
      };

  bool get isPlayable => switch (this) {
        ExerciseType.choice ||
        ExerciseType.trueFalse ||
        ExerciseType.findInText ||
        ExerciseType.tap ||
        ExerciseType.connect ||
        ExerciseType.textSupported ||
        ExerciseType.order ||
        ExerciseType.match ||
        ExerciseType.complete ||
        ExerciseType.insight =>
          true,
        _ => false,
      };

  /// Não consome lâmpada / não conta como quiz.
  bool get isRevealOnly => this == ExerciseType.insight;
}

class ExercisePassage {
  final String ref;
  final String text;

  const ExercisePassage({required this.ref, required this.text});

  factory ExercisePassage.fromJson(Map<String, dynamic> json) {
    return ExercisePassage(
      ref: (json['ref'] as String?) ?? (json['reference'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
    );
  }
}

/// Exercício tipado — um micro-ato da sessão.
class Exercise {
  final String id;
  final ExerciseType type;
  final String skill;
  final String prompt;
  /// Instrução curta de tarefa (secundária). Se vazia, UI deriva do prompt.
  final String? cue;
  final String? reference;
  final String? passageText;
  final List<QuestionOption> options;
  final String correctAnswer;
  final String feedbackCorrect;
  final Map<String, String> feedbackWrong;
  final String? retryHint;
  final List<String> targets;
  final ExercisePassage? passageA;
  final ExercisePassage? passageB;
  final String? beat;
  /// Nota bíblica (contexto / curiosidade) — aparece no ato, sem spoiler.
  final String? note;
  final String? noteLabel;
  /// Instrução explícita do que fazer (acima do contexto/texto).
  final String? instruction;
  /// Ordem correta dos ids (gesto order).
  final List<String> correctOrder;
  /// Template com `___` (gesto complete).
  final String? template;
  /// Pares corretos leftId→rightId (gesto match), serializado "a:x,b:y".
  final Map<String, String> correctPairs;
  final List<QuestionOption> matchLeft;
  final List<QuestionOption> matchRight;

  const Exercise({
    required this.id,
    required this.type,
    required this.prompt,
    required this.correctAnswer,
    this.skill = 'observe',
    this.cue,
    this.reference,
    this.passageText,
    this.options = const [],
    this.feedbackCorrect = '',
    this.feedbackWrong = const {},
    this.retryHint,
    this.targets = const [],
    this.passageA,
    this.passageB,
    this.beat,
    this.note,
    this.noteLabel,
    this.instruction,
    this.correctOrder = const [],
    this.template,
    this.correctPairs = const {},
    this.matchLeft = const [],
    this.matchRight = const [],
  });

  /// Há campo textual/herói além da pergunta (texto-tarefa).
  bool get hasFieldHero {
    switch (type) {
      case ExerciseType.trueFalse:
        return prompt.trim().isNotEmpty;
      case ExerciseType.complete:
        return (template ?? '').trim().isNotEmpty;
      case ExerciseType.tap:
      case ExerciseType.findInText:
        return (passageText ?? '').trim().isNotEmpty ||
            passageA != null ||
            passageB != null;
      case ExerciseType.connect:
        return passageA != null || passageB != null;
      case ExerciseType.choice:
      case ExerciseType.textSupported:
      case ExerciseType.bestInterpretation:
        return (passageText ?? '').trim().isNotEmpty;
      case ExerciseType.order:
      case ExerciseType.match:
        return false;
      case ExerciseType.insight:
      case ExerciseType.explain:
      case ExerciseType.classify:
      case ExerciseType.review:
        return false;
    }
  }

  /// Cue exibido (nunca o beat pedagógico).
  String get displayCue {
    final c = (cue ?? '').trim();
    if (c.isNotEmpty) return c;
    if (type == ExerciseType.trueFalse) return '';
    if (type == ExerciseType.complete && (template ?? '').trim().isNotEmpty) {
      return '';
    }
    if (hasFieldHero) return prompt.trim();
    return '';
  }

  /// O que o usuário deve fazer neste ato.
  String get displayInstruction {
    final i = (instruction ?? '').trim();
    if (i.isNotEmpty) return i;
    return switch (type) {
      ExerciseType.trueFalse =>
        'Leia a afirmação e diga se é verdadeira ou falsa.',
      ExerciseType.tap || ExerciseType.findInText =>
        'Leia o trecho e toque a resposta certa no texto.',
      ExerciseType.choice ||
      ExerciseType.textSupported ||
      ExerciseType.bestInterpretation =>
        'Leia com atenção e escolha a melhor opção.',
      ExerciseType.order => 'Arraste as peças na ordem certa.',
      ExerciseType.match => 'Ligue cada item ao seu par.',
      ExerciseType.complete => 'Complete a lacuna com a opção certa.',
      ExerciseType.connect =>
        'Compare os textos e toque a palavra que os une.',
      _ => 'Responda com base no que o texto diz.',
    };
  }

  String get instructionVerb => switch (type) {
        ExerciseType.trueFalse => 'Decida',
        ExerciseType.tap || ExerciseType.findInText =>
          (passageA != null && passageB != null) ? 'Conecte' : 'Observe',
        ExerciseType.order => 'Ordene',
        ExerciseType.complete => 'Complete',
        ExerciseType.connect || ExerciseType.match => 'Conecte',
        ExerciseType.choice ||
        ExerciseType.textSupported ||
        ExerciseType.bestInterpretation =>
          'Escolha',
        _ => 'Responda',
      };

  /// Opções cujo texto aparece no trecho (toque no versículo).
  List<QuestionOption> optionsEmbeddedIn(String passage) {
    final lower = passage.toLowerCase();
    return effectiveOptions
        .where((o) => o.text.trim().isNotEmpty && lower.contains(o.text.toLowerCase()))
        .toList()
      ..sort((a, b) => b.text.length.compareTo(a.text.length));
  }

  List<QuestionOption> optionsNotEmbeddedIn(String passage) {
    final embedded = optionsEmbeddedIn(passage).map((o) => o.id).toSet();
    return effectiveOptions.where((o) => !embedded.contains(o.id)).toList();
  }

  bool get supportsHint =>
      !type.isRevealOnly &&
      (type == ExerciseType.choice ||
          type == ExerciseType.textSupported ||
          type == ExerciseType.connect ||
          type == ExerciseType.tap ||
          type == ExerciseType.complete);

  /// Conteúdo suficiente para entrar no player (prompt vazio ok se há campo).
  bool get hasPlayableContent {
    if (!type.isPlayable) return false;
    if (type == ExerciseType.insight) return true;
    if (type == ExerciseType.complete) {
      return (template ?? '').trim().isNotEmpty || prompt.trim().isNotEmpty;
    }
    if (type == ExerciseType.trueFalse) return prompt.trim().isNotEmpty;
    if (type == ExerciseType.order || type == ExerciseType.match) {
      return effectiveOptions.isNotEmpty;
    }
    return prompt.trim().isNotEmpty ||
        (cue ?? '').trim().isNotEmpty ||
        (passageText ?? '').trim().isNotEmpty ||
        passageA != null ||
        passageB != null;
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final type = ExerciseType.fromId(json['type'] as String?);
    final feedback = json['feedback'];
    String feedbackCorrect = (json['feedbackCorrect'] as String?) ?? '';
    Map<String, String> feedbackWrong = {};
    String? retryHint = json['retryHint'] as String?;

    if (feedback is Map) {
      feedbackCorrect =
          (feedback['correct'] as String?) ?? feedbackCorrect;
      final wrong = feedback['wrong'];
      if (wrong is Map) {
        feedbackWrong = wrong.map(
          (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
        );
      } else if (wrong is String) {
        feedbackWrong = {'default': wrong};
      }
      retryHint ??= feedback['retryHint'] as String?;
    } else if (json['feedbackWrong'] is Map) {
      feedbackWrong = (json['feedbackWrong'] as Map).map(
        (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
      );
    }

    List<QuestionOption> parseOptions(dynamic raw) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map(
            (e) => QuestionOption(
              id: (e['id'] ?? '').toString(),
              text: (e['text'] ?? '').toString(),
            ),
          )
          .where((o) => o.id.isNotEmpty)
          .toList();
    }

    var options = parseOptions(json['options'] ?? json['items']);
    if (type == ExerciseType.trueFalse && options.isEmpty) {
      options = const [
        QuestionOption(id: 'true', text: 'Verdadeiro'),
        QuestionOption(id: 'false', text: 'Falso'),
      ];
    }

    final correctRaw = json['correctAnswer'] ?? json['correctOptionId'];
    var correctAnswer = correctRaw?.toString() ?? '';
    if (type == ExerciseType.trueFalse) {
      final lower = correctAnswer.toLowerCase();
      if (lower == 'true' || lower == 'verdadeiro' || lower == 'v') {
        correctAnswer = 'true';
      } else if (lower == 'false' || lower == 'falso' || lower == 'f') {
        correctAnswer = 'false';
      }
    }

    final targets = <String>[];
    final rawTargets = json['targets'];
    if (rawTargets is List) {
      for (final t in rawTargets) {
        if (t != null && t.toString().trim().isNotEmpty) {
          targets.add(t.toString().trim());
        }
      }
    }

    final correctOrder = <String>[];
    final rawOrder = json['correctOrder'];
    if (rawOrder is List) {
      for (final o in rawOrder) {
        if (o != null) correctOrder.add(o.toString());
      }
    } else if (correctAnswer.contains(',') && type == ExerciseType.order) {
      correctOrder.addAll(
        correctAnswer.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty),
      );
    }

    final correctPairs = <String, String>{};
    final rawPairs = json['correctPairs'];
    if (rawPairs is Map) {
      rawPairs.forEach((k, v) {
        if (v != null) correctPairs[k.toString()] = v.toString();
      });
    }

    Map<String, dynamic>? asMap(dynamic v) =>
        v is Map ? Map<String, dynamic>.from(v) : null;

    return Exercise(
      id: (json['id'] as String?) ?? '',
      type: type,
      skill: (json['skill'] as String?) ?? 'observe',
      prompt: (json['prompt'] as String?) ??
          (json['question'] as String?) ??
          '',
      cue: json['cue'] as String?,
      reference: json['reference'] as String? ?? json['verseRef'] as String?,
      passageText: json['passageText'] as String?,
      options: options,
      correctAnswer: correctAnswer,
      feedbackCorrect: feedbackCorrect,
      feedbackWrong: feedbackWrong,
      retryHint: retryHint,
      targets: targets,
      passageA: asMap(json['passageA']) != null
          ? ExercisePassage.fromJson(asMap(json['passageA'])!)
          : null,
      passageB: asMap(json['passageB']) != null
          ? ExercisePassage.fromJson(asMap(json['passageB'])!)
          : null,
      beat: json['beat'] as String? ?? json['function'] as String?,
      note: json['note'] as String? ?? json['contextNote'] as String?,
      noteLabel: json['noteLabel'] as String?,
      instruction: json['instruction'] as String? ?? json['howTo'] as String?,
      correctOrder: correctOrder,
      template: json['template'] as String?,
      correctPairs: correctPairs,
      matchLeft: parseOptions(json['matchLeft'] ?? json['left']),
      matchRight: parseOptions(json['matchRight'] ?? json['right']),
    );
  }

  List<QuestionOption> get effectiveOptions {
    if (options.isNotEmpty) return options;
    if ((type == ExerciseType.findInText || type == ExerciseType.tap) &&
        targets.isNotEmpty) {
      final distractors = _clauseCandidates(passageText ?? '')
          .where((c) => !targets.any((t) => _norm(t) == _norm(c)))
          .take(2)
          .toList();
      final all = <String>[targets.first, ...distractors];
      return [
        for (var i = 0; i < all.length; i++)
          QuestionOption(id: 't$i', text: all[i]),
      ];
    }
    return options;
  }

  String get resolvedCorrectAnswer {
    if ((type == ExerciseType.findInText || type == ExerciseType.tap) &&
        options.isEmpty &&
        targets.isNotEmpty) {
      return 't0';
    }
    if (type == ExerciseType.order && correctOrder.isNotEmpty) {
      return correctOrder.join(',');
    }
    return correctAnswer;
  }

  bool checkAnswer(String answer) {
    if (type.isRevealOnly) return true;
    if (type == ExerciseType.order) {
      final got = answer.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
      final want = correctOrder.isNotEmpty
          ? correctOrder
          : correctAnswer.split(',').map((s) => s.trim()).toList();
      if (got.length != want.length) return false;
      final g = got.toList();
      for (var i = 0; i < want.length; i++) {
        if (g[i] != want[i]) return false;
      }
      return true;
    }
    if (type == ExerciseType.match && correctPairs.isNotEmpty) {
      // answer "a:x,b:y"
      final parts = answer.split(',');
      final got = <String, String>{};
      for (final p in parts) {
        final kv = p.split(':');
        if (kv.length == 2) got[kv[0].trim()] = kv[1].trim();
      }
      if (got.length != correctPairs.length) return false;
      for (final e in correctPairs.entries) {
        if (got[e.key] != e.value) return false;
      }
      return true;
    }
    return answer == resolvedCorrectAnswer;
  }

  String feedbackFor(String selectedId, {required bool correct}) {
    if (type.isRevealOnly) {
      return prompt.trim().isEmpty ? 'Seguir.' : '';
    }
    if (correct) {
      return feedbackCorrect.trim().isEmpty
          ? 'Isso.'
          : feedbackCorrect.trim();
    }
    final specific = feedbackWrong[selectedId] ?? feedbackWrong['default'];
    if (specific != null && specific.trim().isNotEmpty) {
      return specific.trim();
    }
    if (retryHint != null && retryHint!.trim().isNotEmpty) {
      return retryHint!.trim();
    }
    return 'Tente de novo.';
  }

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  static List<String> _clauseCandidates(String passage) {
    if (passage.trim().isEmpty) return const [];
    return passage
        .split(RegExp(r'[;.…]+'))
        .map((s) => s.trim())
        .where((s) => s.length >= 12)
        .toList();
  }
}
