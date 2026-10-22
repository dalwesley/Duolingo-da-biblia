/**
 * Monta missão + 18 perguntas a partir de um roteiro editorial.
 * Observação / Compreensão / Interpretação × 6 gestos.
 */
import { foldKey } from './_answer_phrase.mjs';

const MODES = ['semente', 'caminhada', 'profundezas'];
const SHORT = { semente: 'sem', caminhada: 'cam', profundezas: 'pro' };
const SKILL = {
  semente: 'observe',
  caminhada: 'understand',
  profundezas: 'interpret',
};

function clean(s) {
  return String(s || '').replace(/\s+/g, ' ').trim();
}

function limit(text, max, label) {
  const t = clean(text);
  if (!t) throw new Error(`${label}: vazio`);
  if (t.length > max) {
    throw new Error(`${label} tem ${t.length} (máx ${max}): ${t.slice(0, 80)}`);
  }
  return t;
}

function whole(text, label) {
  const t = clean(text);
  if (/…$|\.\.\.$/.test(t)) throw new Error(`${label}: reticências (${t})`);
  const words = t.split(/\s+/);
  if (
    words.length >= 4 &&
    /\s+(e|mas|ou|nem|de|do|da|dos|das|que|para|por|com|os|as|o|a|ao|à)\.?$/i.test(
      t,
    )
  ) {
    throw new Error(`${label}: frase cortada (${t})`);
  }
  if (/,\s*(os|as|o|a|e)?$/i.test(t)) {
    throw new Error(`${label}: vírgula no fim (${t})`);
  }
  return t;
}

function noSubset(texts, label) {
  const folded = texts.map((t) => foldKey(t));
  for (let i = 0; i < folded.length; i++) {
    for (let j = 0; j < folded.length; j++) {
      if (i === j) continue;
      const a = folded[i];
      const b = folded[j];
      if (
        a.length >= 5 &&
        b.includes(a) &&
        a !== b &&
        a.length <= b.length * 0.85
      ) {
        throw new Error(
          `${label}: "${texts[i]}" é pedaço de "${texts[j]}"`,
        );
      }
    }
  }
}

function inPassage(passage, word, label) {
  if (!foldKey(passage).includes(foldKey(word))) {
    throw new Error(`${label}: "${word}" não está no versículo`);
  }
}

function wordsOf(text) {
  return clean(text).split(/\s+/).filter(Boolean);
}

function baseQuestion(scene, diff, n, type, fields) {
  const nn = String(n).padStart(2, '0');
  const id = `${scene.trail}-${SHORT[diff]}-${scene.slug}-${nn}`;
  const stem = limit(fields.question, 220, `${id} enunciado`);
  if (/^(o que|qual|quem|como|onde|quando|por que)\b/i.test(stem) && type === 'true_false') {
    throw new Error(`${id}: V/F não pode ser pergunta`);
  }
  return {
    id,
    trail: scene.trail,
    section: scene.slug,
    difficulty: diff,
    type,
    skill: SKILL[diff],
    question: stem,
    prompt: stem,
    cue: stem,
    verseRef: scene.hookRef,
    learningObjective: scene.objective,
    evidence: [scene.hookRef],
    feedbackCorrect: limit(fields.feedbackCorrect, 100, `${id} feedback`),
    feedbackWrong: fields.feedbackWrong,
    passageText: scene.verse,
    ...fields.extra,
  };
}

function buildTf(scene, diff, src) {
  const claim = whole(src.claim, `${scene.slug} ${diff} vf`);
  const answer = src.answer === false || src.answer === 'false' ? 'false' : 'true';
  const wrongId = answer === 'true' ? 'false' : 'true';
  return baseQuestion(scene, diff, 1, 'true_false', {
    question: claim,
    feedbackCorrect: src.ok,
    feedbackWrong: { [wrongId]: limit(src.why, 140, 'vf why') },
    extra: {
      options: [
        { id: 'true', text: 'Verdadeiro' },
        { id: 'false', text: 'Falso' },
      ],
      correctOptionId: answer,
      correctAnswer: answer,
      passageText: scene.verse,
    },
  });
}

function buildTap(scene, diff, src) {
  const word = clean(src.word);
  const wrongs = src.wrong.map(clean);
  if (wrongs.length !== 2) throw new Error(`${scene.slug} tap: 2 distratores`);
  if (wordsOf(word).length > 3) throw new Error(`${scene.slug} tap longo: ${word}`);
  for (const w of [word, ...wrongs]) {
    if (wordsOf(w).length > 3) throw new Error(`${scene.slug} tap longo: ${w}`);
    inPassage(scene.verse, w, `${scene.slug} ${diff} tap`);
  }
  noSubset([word, ...wrongs], `${scene.slug} ${diff} tap`);
  const quote = clean(src.quote);
  if (!quote.includes('___')) throw new Error(`${scene.slug} tap sem ___`);
  if (foldKey(quote).includes(foldKey(word))) {
    throw new Error(`${scene.slug} tap: a lacuna ainda contém "${word}"`);
  }
  const question = `Em ${scene.hookRef}, toque a palavra que falta em "${quote}"?`;
  return baseQuestion(scene, diff, 2, 'tap', {
    question,
    feedbackCorrect: src.ok,
    feedbackWrong: {
      a: limit(src.why[0], 140, 'tap why'),
      c: limit(src.why[1], 140, 'tap why'),
    },
    extra: {
      template: quote,
      passageText: scene.verse,
      options: [
        { id: 'a', text: wrongs[0] },
        { id: 'b', text: word },
        { id: 'c', text: wrongs[1] },
      ],
      correctOptionId: 'b',
      correctAnswer: 'b',
    },
  });
}

function buildChoice(scene, diff, src) {
  const options = src.options.map((text) => whole(text, `${scene.slug} choice`));
  if (options.length !== 4) throw new Error(`${scene.slug} choice: 4 opções`);
  for (const text of options) limit(text, 80, `${scene.slug} ${diff} choice`);
  noSubset(options, `${scene.slug} ${diff} choice`);
  if (src.why.length !== 3) throw new Error(`${scene.slug} choice why`);
  return baseQuestion(scene, diff, 3, 'choice', {
    question: whole(src.q, `${scene.slug} choice q`),
    feedbackCorrect: src.ok,
    feedbackWrong: {
      b: limit(src.why[0], 140, 'choice why'),
      c: limit(src.why[1], 140, 'choice why'),
      d: limit(src.why[2], 140, 'choice why'),
    },
    extra: {
      passageText: scene.verse,
      options: options.map((text, i) => ({ id: 'abcd'[i], text })),
      correctOptionId: 'a',
      correctAnswer: 'a',
    },
  });
}

function buildOrder(scene, diff, pieces, meta) {
  if (pieces.length !== 3) throw new Error(`${scene.slug} order: 3 peças`);
  const texts = pieces.map((p) => whole(p, `${scene.slug} order`));
  for (const text of texts) limit(text, 150, `${scene.slug} order`);
  noSubset(texts, `${scene.slug} ${diff} order`);
  const stems = {
    semente: `Qual é a ordem dos fatos em ${scene.hookRef}?`,
    caminhada: `Como se encadeiam os eventos de ${scene.hookRef}?`,
    profundezas: `Qual sequência revela o sentido de ${scene.hookRef}?`,
  };
  return baseQuestion(scene, diff, 4, 'order', {
    question: stems[diff],
    feedbackCorrect: meta.ok,
    feedbackWrong: {
      b: limit(meta.why[0], 140, 'order why'),
      c: limit(meta.why[1], 140, 'order why'),
    },
    extra: {
      passageText: scene.verse,
      options: texts.map((text, i) => ({ id: 'abc'[i], text })),
      correctOrder: ['a', 'b', 'c'],
      correctOptionId: 'a',
      correctAnswer: 'a',
    },
  });
}

function buildComplete(scene, diff, src) {
  const word = clean(src.word);
  const wrongs = src.wrong.map(clean);
  const template = clean(src.template);
  if (!template.includes('___')) throw new Error(`${scene.slug} complete sem ___`);
  if (foldKey(template).includes(foldKey(word))) {
    throw new Error(`${scene.slug} complete: lacuna ainda tem "${word}"`);
  }
  for (const w of [word, ...wrongs]) {
    if (wordsOf(w).length > 3) throw new Error(`${scene.slug} complete longo: ${w}`);
    inPassage(scene.verse, w, `${scene.slug} ${diff} complete`);
  }
  noSubset([word, ...wrongs], `${scene.slug} ${diff} complete`);
  const question = `Complete a frase: "${template}"`;
  return baseQuestion(scene, diff, 5, 'complete', {
    question,
    feedbackCorrect: src.ok,
    feedbackWrong: {
      b: limit(src.why[0], 140, 'complete why'),
      c: limit(src.why[1], 140, 'complete why'),
    },
    extra: {
      template,
      passageText: scene.verse,
      options: [
        { id: 'a', text: word },
        { id: 'b', text: wrongs[0] },
        { id: 'c', text: wrongs[1] },
      ],
      correctOptionId: 'a',
      correctAnswer: 'a',
    },
  });
}

function buildConnect(scene, diff, src) {
  const texts = src.options.map(clean);
  if (texts.length !== 3) throw new Error(`${scene.slug} connect: 3 opções`);
  for (const text of texts) {
    const n = wordsOf(text).length;
    if (n < 1 || n > 6) {
      throw new Error(`${scene.slug} connect (${n} palavras): ${text}`);
    }
    limit(text, 80, `${scene.slug} connect`);
  }
  noSubset(texts, `${scene.slug} ${diff} connect`);
  const stems = {
    semente: `O que ${scene.hookRef} comunica que se liga a este contexto?`,
    caminhada: `Que relação ${scene.hookRef} estabelece com este contexto?`,
    profundezas: `Que sentido de ${scene.hookRef} se liga a este contexto?`,
  };
  const ids = ['a', 'b', 'c'];
  const correctAt = src.correct ?? 0;
  const correctId = ids[correctAt];
  if (src.why.length !== 2) throw new Error(`${scene.slug} connect why`);
  const wrongWhys = [...src.why];
  const fw = {};
  for (let i = 0; i < 3; i++) {
    if (i === correctAt) continue;
    fw[ids[i]] = limit(wrongWhys.shift(), 140, 'connect why');
  }
  return baseQuestion(scene, diff, 6, 'connect', {
    question: stems[diff],
    feedbackCorrect: src.ok,
    feedbackWrong: fw,
    extra: {
      passageText: scene.verse,
      passageA: { ref: scene.hookRef, text: scene.verse },
      passageB: { ref: 'Contexto', text: src.context || scene.insight },
      options: texts.map((text, i) => ({ id: ids[i], text })),
      correctOptionId: correctId,
      correctAnswer: correctId,
    },
  });
}

function gabarito(q) {
  if (q.type === 'true_false' || q.type === 'order') return '';
  const id = q.correctOptionId;
  return foldKey((q.options || []).find((o) => o.id === id)?.text || '');
}

export function buildScene(scene) {
  const required = [
    'trail',
    'slug',
    'title',
    'intro',
    'hookRef',
    'verse',
    'note',
    'insight',
    'objective',
    'echo',
    'keyword',
    'gloss',
    'context',
    'tf',
    'tap',
    'choice',
    'order',
    'complete',
    'connect',
  ];
  for (const key of required) {
    if (scene[key] == null) throw new Error(`${scene.slug || '?'} falta ${key}`);
  }
  limit(scene.insight, 140, `${scene.slug} insight`);
  limit(scene.objective, 180, `${scene.slug} objective`);
  if (scene.tf.length !== 3 || scene.tap.length !== 3 || scene.choice.length !== 3) {
    throw new Error(`${scene.slug}: tf/tap/choice precisam de 3 modos`);
  }
  if (scene.complete.length !== 3 || scene.connect.length !== 3) {
    throw new Error(`${scene.slug}: complete/connect precisam de 3 modos`);
  }

  const questions = [];
  for (const diff of MODES) {
    const i = MODES.indexOf(diff);
    questions.push(buildTf(scene, diff, scene.tf[i]));
    questions.push(buildTap(scene, diff, scene.tap[i]));
    questions.push(buildChoice(scene, diff, scene.choice[i]));
    questions.push(buildOrder(scene, diff, scene.order.pieces, scene.order));
    questions.push(buildComplete(scene, diff, scene.complete[i]));
    questions.push(buildConnect(scene, diff, scene.connect[i]));
  }

  for (let i = 0; i < 3; i++) {
    if (foldKey(scene.tap[i].word) === foldKey(scene.complete[i].word)) {
      throw new Error(`${scene.slug}: tap e complete iguais no modo ${i}`);
    }
  }

  for (const type of ['tap', 'complete', 'connect']) {
    const sem = questions.find((q) => q.difficulty === 'semente' && q.type === type);
    const cam = questions.find((q) => q.difficulty === 'caminhada' && q.type === type);
    if (gabarito(sem) && gabarito(sem) === gabarito(cam)) {
      throw new Error(`${scene.slug}: mesmo gabarito de ${type} em sem e cam`);
    }
  }

  const mission = {
    slug: scene.slug,
    title: scene.title,
    intro: scene.intro,
    type: 'lesson',
    xpReward: 50,
    questions: [],
    hookRef: scene.hookRef,
    hookVerse: scene.verse,
    hookNote: scene.note,
    centralInsight: scene.insight,
    objective: scene.objective,
    echoQuestion: scene.echo,
  };

  const study = {
    slug: scene.slug,
    passageRef: scene.hookRef,
    passageText: scene.verse,
    context: scene.context,
    keyword: scene.keyword,
    keywordGloss: scene.gloss,
    focusQuestion: scene.objective,
    reflectionPrompts: [scene.insight, scene.echo, scene.context].slice(0, 3),
    relatedVerses: [],
  };

  return { mission, study, questions };
}
