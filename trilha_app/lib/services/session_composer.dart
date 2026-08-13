import 'dart:math';

import '../data/question_bank.dart';
import '../models/difficulty.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';

/// Resultado do composer — sempre uma sessão única ([docs/SESSAO_TREINO.md]).
class SessionPlan {
  final List<Exercise> acts;
  final String insight;
  final List<String> bankQuestionIds;
  final List<String?> revealTags;
  final DifficultyMeta? difficultyMeta;
  final bool fromAuthoredExercises;

  const SessionPlan({
    required this.acts,
    required this.insight,
    this.bankQuestionIds = const [],
    this.revealTags = const [],
    this.difficultyMeta,
    this.fromAuthoredExercises = false,
  });

  bool get isEmpty => acts.isEmpty;
}

/// Monta atos **só a partir do banco** (`content_bank_questions`).
/// Sem hardcode local e sem `mission.exercises` embutidos.
class SessionComposer {
  SessionComposer._();

  static Exercise fromBankQuestion(BankQuestion bq, {Random? rng}) {
    final type = bq.type;
    final opts = List<QuestionOption>.from(bq.options);
    if (type == ExerciseType.choice ||
        type == ExerciseType.textSupported ||
        type == ExerciseType.bestInterpretation ||
        type == ExerciseType.order) {
      opts.shuffle(rng);
    }

    final prompt = (bq.prompt ?? '').trim().isNotEmpty
        ? bq.prompt!.trim()
        : bq.question;
    var answer = (bq.correctAnswer ?? '').trim().isNotEmpty
        ? bq.correctAnswer!.trim()
        : bq.correctOptionId;
    if (type == ExerciseType.trueFalse) {
      answer = _normalizeVfAnswer(answer, fallback: bq.correctOptionId);
    }
    final cue = _tapCueWithoutSpoiler(bq, prompt);

    return Exercise(
      id: bq.id,
      type: type,
      skill: _skillFor(bq),
      prompt: type == ExerciseType.tap || type == ExerciseType.findInText
          ? cue
          : prompt,
      cue: cue,
      options: type == ExerciseType.trueFalse
          ? const [
              QuestionOption(id: 'true', text: 'Verdadeiro'),
              QuestionOption(id: 'false', text: 'Falso'),
            ]
          : opts,
      correctAnswer: answer,
      feedbackCorrect: bq.feedbackCorrect,
      feedbackWrong: bq.feedbackWrong,
      reference: bq.verseRef,
      passageText: bq.passageText,
      template: bq.template,
      passageA: bq.passageA,
      passageB: bq.passageB,
      correctOrder: bq.correctOrder,
      note: bq.note,
      noteLabel: bq.noteLabel,
      beat: bq.beat,
    );
  }

  static String _normalizeVfAnswer(String raw, {required String fallback}) {
    final a = raw.trim().toLowerCase();
    if (a == 'true' || a == 'verdadeiro' || a == 'v') return 'true';
    if (a == 'false' || a == 'falso' || a == 'f') return 'false';
    final f = fallback.trim().toLowerCase();
    if (f == 'true' || f == 'verdadeiro' || f == 'v') return 'true';
    if (f == 'false' || f == 'falso' || f == 'f') return 'false';
    return 'false';
  }

  static bool _vfIsTrue(BankQuestion q) {
    final a = _normalizeVfAnswer(
      q.correctAnswer ?? '',
      fallback: q.correctOptionId,
    );
    return a == 'true';
  }

  /// Id base sem sufixo de síntese (`__vftrue`).
  static String _vfBaseId(String id) =>
      id.endsWith('__vftrue') ? id.substring(0, id.length - 8) : id;

  /// Chave de enunciado V/F — evita verdadeiro+falso do mesmo ato na sessão.
  static String _vfStemKey(BankQuestion q) {
    final stem = q.question.trim().toLowerCase();
    if (stem.isNotEmpty) return 'stem:$stem';
    return 'id:${_vfBaseId(q.id)}';
  }

  /// Se o pool só tem V/F falso (Firestore legado), monta um verdadeiro a partir do feedback.
  static BankQuestion _vfAsTrue(BankQuestion q) {
    final m = RegExp(r'[“"]([^”"]+)[”"]').firstMatch(q.feedbackCorrect);
    final quoted = (m?.group(1) ?? '').trim();
    final stem = q.question.replaceAll(RegExp(r'\?\s*$'), '').trim();
    final prompt = quoted.isEmpty
        ? (stem.isNotEmpty ? '$stem.' : (q.prompt ?? q.question))
        : (stem.length > 12 &&
                stem.length < 90 &&
                quoted.length <= 40 &&
                !RegExp(r'[.!?]$').hasMatch(quoted))
            ? '$stem: $quoted.'
            : (RegExp(r'[.!?]$').hasMatch(quoted) ? quoted : '$quoted.');
    return BankQuestion(
      id: '${_vfBaseId(q.id)}__vftrue',
      trailSlug: q.trailSlug,
      difficulty: q.difficulty,
      section: q.section,
      question: q.question,
      options: const [
        QuestionOption(id: 'true', text: 'Verdadeiro'),
        QuestionOption(id: 'false', text: 'Falso'),
      ],
      correctOptionId: 'true',
      feedbackCorrect: q.feedbackCorrect,
      feedbackWrong: q.feedbackWrong,
      verseRef: q.verseRef,
      reveal: q.reveal,
      type: ExerciseType.trueFalse,
      prompt: prompt,
      cue: prompt,
      correctAnswer: 'true',
      passageText: q.passageText,
      template: q.template,
      passageA: q.passageA,
      passageB: q.passageB,
      correctOrder: q.correctOrder,
      note: q.note,
      noteLabel: q.noteLabel,
      beat: q.beat,
      skill: q.skill,
    );
  }

  static String _skillFor(BankQuestion bq) {
    final tagged = (bq.skill ?? '').trim();
    if (tagged.isNotEmpty) return tagged;
    return switch (bq.type) {
      ExerciseType.trueFalse ||
      ExerciseType.tap ||
      ExerciseType.findInText => 'observe',
      ExerciseType.connect || ExerciseType.match => 'connect',
      ExerciseType.order || ExerciseType.complete => 'understand',
      _ => 'understand',
    };
  }

  /// Entrada da sessão: verso curto (≤ ~40 palavras). [docs/SESSAO_TREINO.md] §5.
  static String clipEntranceVerse(String text, {int maxWords = 40}) {
    final t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (t.isEmpty) return t;
    final words = t.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length <= maxWords) return t;
    return '${words.take(maxWords).join(' ')}…';
  }

  /// Tap: enunciado não pode ser o próprio trecho-alvo (`Toque no texto: X`).
  static String _tapCueWithoutSpoiler(BankQuestion bq, String prompt) {
    final rawCue = (bq.cue ?? '').trim().isNotEmpty ? bq.cue!.trim() : prompt;
    if (bq.type != ExerciseType.tap && bq.type != ExerciseType.findInText) {
      return rawCue;
    }
    final optionTexts = {
      for (final o in bq.options) o.text.trim().toLowerCase(),
    };
    bool spoils(String text) {
      final m = RegExp(
        r'^Toque no texto:\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(text.trim());
      if (m == null) return false;
      return optionTexts.contains(m.group(1)!.trim().toLowerCase());
    }

    if (!spoils(rawCue) && !spoils(prompt)) return rawCue;
    final ask = bq.question.trim();
    if (ask.isNotEmpty) return ask;
    return 'Toque o trecho que responde.';
  }

  static Exercise fromQuestion(Question q, {required String id, Random? rng}) {
    final opts = List<QuestionOption>.from(q.options)..shuffle(rng);
    return Exercise(
      id: id,
      type: ExerciseType.choice,
      skill: 'understand',
      prompt: q.question,
      cue: q.question,
      options: opts,
      correctAnswer: q.correctOptionId,
      feedbackCorrect: q.feedbackCorrect,
      feedbackWrong: q.feedbackWrong,
      reference: q.verseRef,
    );
  }

  /// Slot de gesto (aliases não contam como tipos distintos na sessão).
  static ExerciseType gestureSlot(ExerciseType t) => switch (t) {
        ExerciseType.findInText => ExerciseType.tap,
        ExerciseType.match => ExerciseType.connect,
        _ => t,
      };

  /// Teto de Escolher na sessão mista ([docs/SESSAO_TREINO.md] §4).
  static int maxChoiceActs(int sessionMax) =>
      (sessionMax * 0.4).floor().clamp(1, sessionMax);

  /// Ordena atos: V/F → toque → escolha → ordenar → completar → conectar.
  /// Permite 2º Escolher no meio (≤ 40%). V/F no máx. 2. Sem o mesmo gesto 4× seguidas.
  static List<Exercise> arrangeActs(List<Exercise> raw, {int max = 8}) {
    final playable = raw
        .where((e) => e.hasPlayableContent && e.type != ExerciseType.insight)
        .where((e) => (e.beat ?? '').toLowerCase() != 'revisão')
        .where((e) {
          final id = e.id.toLowerCase();
          return !id.contains('-review') && !id.endsWith('-review');
        })
        .toList();

    final bySlot = <ExerciseType, List<Exercise>>{};
    for (final e in playable) {
      bySlot.putIfAbsent(gestureSlot(e.type), () => []).add(e);
    }

    const preferred = <ExerciseType>[
      ExerciseType.trueFalse,
      ExerciseType.tap,
      ExerciseType.choice,
      ExerciseType.order,
      ExerciseType.complete,
      ExerciseType.connect,
    ];

    final ordered = <Exercise>[];

    int countSlot(ExerciseType slot) =>
        ordered.where((e) => gestureSlot(e.type) == slot).length;

    bool canAdd(Exercise e) {
      if (ordered.length >= max) return false;
      final slot = gestureSlot(e.type);
      if (slot == ExerciseType.choice &&
          countSlot(ExerciseType.choice) >= maxChoiceActs(max)) {
        return false;
      }
      if (slot == ExerciseType.trueFalse &&
          countSlot(ExerciseType.trueFalse) >= 2) {
        return false;
      }
      if (ordered.length >= 3) {
        final last3 = ordered.sublist(ordered.length - 3);
        if (last3.every((x) => gestureSlot(x.type) == slot)) return false;
      }
      return true;
    }

    void takeOne(ExerciseType t, {bool insertSecondChoice = false}) {
      final list = bySlot[t];
      if (list == null || list.isEmpty) return;
      final e = list.first;
      if (!canAdd(e)) return;
      list.removeAt(0);
      if (insertSecondChoice &&
          t == ExerciseType.choice &&
          countSlot(ExerciseType.choice) >= 1) {
        final first = ordered.indexWhere(
          (x) => gestureSlot(x.type) == ExerciseType.choice,
        );
        final insertAt = first >= 0
            ? (first + 2).clamp(0, ordered.length)
            : ordered.length;
        ordered.insert(insertAt, e);
      } else {
        ordered.add(e);
      }
    }

    for (final t in preferred) {
      takeOne(t);
    }

    const fillOrder = <ExerciseType>[
      ExerciseType.choice,
      ExerciseType.order,
      ExerciseType.complete,
      ExerciseType.tap,
      ExerciseType.connect,
      ExerciseType.trueFalse,
    ];
    var added = true;
    while (ordered.length < max && added) {
      added = false;
      for (final t in fillOrder) {
        final before = ordered.length;
        takeOne(t, insertSecondChoice: t == ExerciseType.choice);
        if (ordered.length > before) {
          added = true;
          break;
        }
      }
    }
    if (ordered.length > max) return ordered.sublist(0, max);
    return ordered;
  }

  /// Primeiro 1 de cada gesto; depois preenche até [max] (2º Escolher ≤ 40%).
  /// V/F: alterna verdadeiro/falso (evita Firestore legado só-falso).
  /// Nunca repete o mesmo enunciado V/F (verdadeiro + falso do mesmo ato).
  static List<BankQuestion> pickDiverseBankQuestions({
    required List<BankQuestion> pool,
    required Set<String> usedIds,
    required int max,
    String missionSlug = '',
    Random? rng,
  }) {
    const types = <ExerciseType>[
      ExerciseType.trueFalse,
      ExerciseType.tap,
      ExerciseType.choice,
      ExerciseType.order,
      ExerciseType.complete,
      ExerciseType.connect,
    ];
    final random = rng ?? Random(missionSlug.hashCode);
    final picked = <BankQuestion>[];
    final seenIds = <String>{};
    final seenVfStems = <String>{};

    bool vfAvailable(BankQuestion q) {
      if (seenIds.contains(q.id)) return false;
      if (seenIds.contains(_vfBaseId(q.id))) return false;
      if (seenIds.contains('${_vfBaseId(q.id)}__vftrue')) return false;
      if (seenVfStems.contains(_vfStemKey(q))) return false;
      return true;
    }

    void markPicked(BankQuestion q) {
      picked.add(q);
      seenIds.add(q.id);
      if (q.type == ExerciseType.trueFalse) {
        final base = _vfBaseId(q.id);
        seenIds.add(base);
        seenIds.add('${base}__vftrue');
        seenVfStems.add(_vfStemKey(q));
      }
    }

    BankQuestion? bestFor(ExerciseType type) {
      final matches = pool.where((q) {
        if (type == ExerciseType.trueFalse) {
          if (!vfAvailable(q)) return false;
        } else if (seenIds.contains(q.id)) {
          return false;
        }
        if (type == ExerciseType.tap) {
          return q.type == ExerciseType.tap || q.type == ExerciseType.findInText;
        }
        if (type == ExerciseType.connect) {
          return q.type == ExerciseType.connect || q.type == ExerciseType.match;
        }
        return q.type == type;
      }).toList();
      if (matches.isEmpty) return null;

      if (type == ExerciseType.trueFalse) {
        final unused = matches.where((q) => !usedIds.contains(q.id)).toList();
        final candidates = unused.isNotEmpty ? unused : matches;
        final trues = candidates.where(_vfIsTrue).toList();
        final falses = candidates.where((q) => !_vfIsTrue(q)).toList();
        final preferTrue =
            (missionSlug.hashCode ^ usedIds.length ^ picked.length).isEven;
        if (preferTrue) {
          if (trues.isNotEmpty) return trues[random.nextInt(trues.length)];
          if (falses.isNotEmpty &&
              picked.every((q) => q.type != ExerciseType.trueFalse)) {
            final source = falses.first;
            if (!vfAvailable(source)) return null;
            return _vfAsTrue(source);
          }
        } else {
          if (falses.isNotEmpty) return falses[random.nextInt(falses.length)];
          if (trues.isNotEmpty) return trues[random.nextInt(trues.length)];
        }
        return candidates.first;
      }

      final unused = matches.where((q) => !usedIds.contains(q.id)).toList();
      final candidates = unused.isNotEmpty ? unused : matches;
      return candidates[random.nextInt(candidates.length)];
    }

    for (final t in types) {
      if (picked.length >= max) break;
      final q = bestFor(t);
      if (q == null) continue;
      if (q.type == ExerciseType.trueFalse) {
        if (seenVfStems.contains(_vfStemKey(q))) continue;
        if (seenIds.contains(_vfBaseId(q.id))) continue;
      } else if (seenIds.contains(q.id)) {
        continue;
      }
      markPicked(q);
    }

    const fillOrder = <ExerciseType>[
      ExerciseType.choice,
      ExerciseType.order,
      ExerciseType.complete,
      ExerciseType.tap,
      ExerciseType.connect,
      ExerciseType.trueFalse,
    ];
    var added = true;
    while (picked.length < max && added) {
      added = false;
      for (final t in fillOrder) {
        if (picked.length >= max) break;
        if (t == ExerciseType.choice) {
          final n = picked
              .where((q) => gestureSlot(q.type) == ExerciseType.choice)
              .length;
          if (n >= maxChoiceActs(max)) continue;
        }
        if (t == ExerciseType.trueFalse) {
          final n =
              picked.where((q) => q.type == ExerciseType.trueFalse).length;
          if (n >= 2) continue;
        }
        final q = bestFor(t);
        if (q == null) continue;
        if (q.type == ExerciseType.trueFalse) {
          if (seenVfStems.contains(_vfStemKey(q))) continue;
          if (seenIds.contains(_vfBaseId(q.id))) continue;
        } else if (seenIds.contains(q.id)) {
          continue;
        }
        markPicked(q);
        added = true;
        break;
      }
    }
    return picked;
  }

  /// Micro-review do banco — **outro gesto**, nunca repete tipo já usado na sessão.
  static Exercise? reviewFromBank({
    required String missionSlug,
    required TrailDifficulty difficulty,
    required String trailSlug,
    required Set<String> usedInSession,
    Set<ExerciseType> usedTypes = const {},
  }) {
    final blocked = {
      for (final t in usedTypes) gestureSlot(t),
    };
    final all = QuestionBank.instance.bankQuestionsCacheOrEmpty
        .where(
          (q) =>
              q.difficulty == difficulty &&
              q.trailSlug == trailSlug &&
              QuestionBank.matchesMissionSection(q, missionSlug) &&
              !usedInSession.contains(q.id) &&
              !blocked.contains(gestureSlot(q.type)),
        )
        .toList();
    if (all.isEmpty) return null;

    BankQuestion? pick;
    for (final q in all) {
      final id = q.id.toLowerCase();
      if (id.contains('-review') || (q.reveal ?? '') == 'review') {
        pick = q;
        break;
      }
    }
    // Preferir gesto diferente dos básicos já vistos: order/complete/connect/choice/tap/VF.
    pick ??= all
        .where(
          (q) =>
              q.type == ExerciseType.order ||
              q.type == ExerciseType.complete ||
              q.type == ExerciseType.connect ||
              q.type == ExerciseType.tap ||
              q.type == ExerciseType.trueFalse ||
              q.type == ExerciseType.choice,
        )
        .firstOrNull;
    pick ??= all.firstOrNull;
    if (pick == null) return null;
    return fromBankQuestion(pick);
  }

  static Future<SessionPlan> compose({
    required Mission mission,
    required String missionSlug,
    String? trailSlug,
    String? moduleTitle,
    required bool usesBank,
    required ProgressService progress,
    bool practiceMode = false,
    List<String>? questionIdsOverride,
    Random? rng,
  }) async {
    DifficultyMeta? meta;
    TrailDifficulty difficulty = TrailDifficulty.semente;

    if (usesBank && trailSlug != null) {
      final diffId =
          progress.difficultyForTrail(trailSlug) ??
          TrailDifficulty.semente.id;
      difficulty = TrailDifficulty.fromId(diffId) ?? TrailDifficulty.semente;
      meta = await QuestionBank.instance.metaFor(difficulty);
    }

    final insight = (mission.centralInsight ?? '').trim();

    // Prática / override: IDs do banco.
    if (questionIdsOverride != null && questionIdsOverride.isNotEmpty) {
      final acts = <Exercise>[];
      final tags = <String?>[];
      final usedIds = <String>[];
      for (final id in questionIdsOverride) {
        final bq = QuestionBank.instance.byId(id);
        if (bq != null) {
          acts.add(fromBankQuestion(bq, rng: rng));
          tags.add(bq.reveal == 'null' ? null : bq.reveal);
          usedIds.add(id);
        }
      }
      if (acts.isNotEmpty) {
        return SessionPlan(
          acts: arrangeActs(acts),
          insight: insight,
          bankQuestionIds: usedIds,
          revealTags: tags,
          difficultyMeta: meta,
        );
      }
    }

    // Fonte canônica: banco Firestore.
    if (usesBank && trailSlug != null) {
      final pool = await QuestionBank.instance.listForMission(
        difficulty: difficulty,
        moduleTitle: moduleTitle,
        section: mission.slug,
        trailSlug: trailSlug,
      );
      final max = ProgressService.questionCountForMission(isBoss: mission.isBoss)
          .clamp(5, 12);
      final picked = pickDiverseBankQuestions(
        pool: pool,
        usedIds: progress.usedQuestionIds.toSet(),
        max: max,
        missionSlug: missionSlug,
        rng: rng,
      );
      final converted = picked.map((q) => fromBankQuestion(q, rng: rng)).toList();
      final acts = arrangeActs(converted, max: max);
      if (acts.isNotEmpty) {
        return SessionPlan(
          acts: acts,
          insight: insight,
          bankQuestionIds: acts.map((e) => e.id).toList(),
          revealTags: acts.map((e) {
            final bq = QuestionBank.instance.byId(e.id);
            if (bq == null || bq.reveal == 'null') return null;
            return bq.reveal;
          }).toList(),
          difficultyMeta: meta,
        );
      }
    }

    // Fallback raro: questions embutidas na missão (legado) — ainda via adaptador.
    final embedded = <Exercise>[];
    for (var i = 0; i < mission.questions.length; i++) {
      embedded.add(
        fromQuestion(
          mission.questions[i],
          id: '${mission.slug}_q$i',
          rng: rng,
        ),
      );
    }
    return SessionPlan(
      acts: arrangeActs(embedded),
      insight: insight,
      difficultyMeta: meta,
      fromAuthoredExercises: false,
    );
  }
}
