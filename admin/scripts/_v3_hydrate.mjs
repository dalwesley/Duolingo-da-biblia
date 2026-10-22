/**
 * O modelo escreve só o que exige julgamento. Este módulo preenche o resto a
 * partir da JFAAL e da posição da pergunta: texto bíblico, ids, prompt/cue,
 * opções do V/F, template do Completar, relatedVerses.
 *
 * `compactCena` faz o caminho inverso, para mostrar ao modelo os exemplos de
 * Gênesis no mesmo formato enxuto que ele deve devolver.
 */
import { passageText, verseCount } from './_jfaal.mjs';

export const SHORT = { semente: 'sem', caminhada: 'cam', profundezas: 'pro' };
export const SKILL = { semente: 'observe', caminhada: 'understand', profundezas: 'interpret' };
export const MODES = ['semente', 'caminhada', 'profundezas'];
export const LESSON = ['true_false', 'find_in_text', 'choice', 'order', 'complete', 'connect'];
export const BOSS = [...LESSON, 'find_in_text', 'order'];

const letter = /\p{L}/u;
const norm = (s) => String(s || '').normalize('NFC').replace(/\s+/g, ' ').trim();

/** Texto da JFAAL para um trecho de até [maxVerses] versos, ou null. */
function jfaal(ref, maxVerses = 2) {
  const t = passageText(ref);
  if (!t || verseCount(ref) > maxVerses) return null;
  return t;
}

/** Mantém o recorte do modelo se for trecho exato; senão, o verso inteiro. */
function exactOrWhole(ref, text) {
  const whole = jfaal(ref);
  if (!whole) return text;
  return text && norm(whole).includes(norm(text)) ? text : whole;
}

/** Troca a primeira ocorrência da palavra inteira por ___. */
function blankOut(passage, word) {
  const w = norm(word);
  if (!w) return null;
  let from = 0;
  while (true) {
    const i = passage.indexOf(w, from);
    if (i < 0) return null;
    const before = i > 0 ? passage[i - 1] : '';
    const after = passage[i + w.length] || '';
    if (!letter.test(before) && !letter.test(after)) return `${passage.slice(0, i)}___${passage.slice(i + w.length)}`;
    from = i + 1;
  }
}

export function hydrateCena(data, packet) {
  const { trail, mission } = packet;
  const slug = mission.slug;
  const boss = mission.type === 'boss';
  const study = { ...(data.study || {}) };
  study.slug = slug;
  if (study.passageRef) study.passageText = passageText(study.passageRef) || study.passageText;
  const passages = Array.isArray(study.passages) && study.passages.length ? study.passages : study.passageRef ? [{ ref: study.passageRef }] : [];
  study.passages = passages.map((p) => ({ ref: p.ref, text: passageText(p.ref) || p.text }));
  study.crossRefs = (study.crossRefs || []).map((c) => ({ ...c, text: exactOrWhole(c.ref, c.text) }));
  if (!Array.isArray(study.relatedVerses) || !study.relatedVerses.length) {
    study.relatedVerses = study.crossRefs.map((c) => ({ reference: c.ref, reason: c.bridge }));
  }
  // O insight é da cena (trails.json). Só um insight cortado ou longo cede ao do modelo.
  const insight = norm(mission.centralInsight);
  const weak = !insight || insight.endsWith('…') || insight.length > 140;
  if (!weak || !norm(study.centralInsight)) study.centralInsight = mission.centralInsight;

  const rot = boss ? BOSS : LESSON;
  const questions = [];
  for (const mode of MODES) {
    const inMode = (data.questions || []).filter((q) => q.difficulty === mode);
    inMode.forEach((q0, i) => {
      const q = { ...q0 };
      const nn = String(i + 1).padStart(2, '0');
      q.id = `${trail.slug}-${SHORT[mode]}-${slug}-${nn}`;
      q.trail = trail.slug;
      q.section = slug;
      q.difficulty = mode;
      q.skill = SKILL[mode];
      if (!q.type && rot[i]) q.type = rot[i];
      q.question = norm(q.question);
      q.prompt = q.question;
      q.cue = q.question;
      const live = passageText(q.verseRef);
      if (live) q.passageText = live;
      if (!Array.isArray(q.evidence) || !q.evidence.length) q.evidence = q.verseRef ? [q.verseRef] : [];
      if (q.type === 'true_false') {
        q.options = [
          { id: 'true', text: 'Verdadeiro' },
          { id: 'false', text: 'Falso' },
        ];
        q.correctOptionId = String(q.correctOptionId);
        q.correctAnswer = q.correctOptionId;
      } else if (q.type === 'order') {
        q.correctOrder = Array.isArray(q.correctOrder) && q.correctOrder.length ? q.correctOrder : (q.options || []).map((o) => o.id);
        q.correctOptionId = q.correctOrder[0];
        q.correctAnswer = q.correctOrder.join(',');
      } else {
        q.correctAnswer = q.correctOptionId;
      }
      if (q.type === 'complete' && q.passageText) {
        const word = (q.options || []).find((o) => o.id === q.correctOptionId)?.text;
        q.template = blankOut(q.passageText, word) || q.template;
      }
      if (q.type === 'find_in_text') delete q.template;
      if (q.type === 'connect') {
        if (q.passageA?.ref) q.passageA = { ref: q.passageA.ref, text: exactOrWhole(q.passageA.ref, q.passageA.text) };
        if (q.passageB?.ref && q.passageB.ref !== 'Contexto') {
          q.passageB = { ref: q.passageB.ref, text: exactOrWhole(q.passageB.ref, q.passageB.text) };
        }
      }
      questions.push(order(q));
    });
  }
  return { study: orderStudy(study), questions };
}

const Q_KEYS = [
  'id', 'trail', 'section', 'difficulty', 'type', 'skill', 'question', 'prompt', 'cue', 'verseRef', 'passageText',
  'template', 'passageA', 'passageB', 'options', 'correctOptionId', 'correctOrder', 'correctAnswer', 'evidenceSpan',
  'feedbackCorrect', 'feedbackWrong', 'hint', 'learningObjective', 'evidence',
];
function order(q) {
  const out = {};
  for (const k of Q_KEYS) if (q[k] !== undefined) out[k] = q[k];
  for (const k of Object.keys(q)) if (!(k in out)) out[k] = q[k];
  return out;
}

const S_KEYS = [
  'slug', 'passageRef', 'passageText', 'passages', 'context', 'keyword', 'keywordGloss', 'focusQuestion',
  'reflectionPrompts', 'facts', 'keyTerms', 'structure', 'relations', 'crossRefs', 'misreadings', 'centralInsight',
  'anchorQuestion', 'relatedVerses',
];
function orderStudy(s) {
  const out = {};
  for (const k of S_KEYS) if (s[k] !== undefined) out[k] = s[k];
  for (const k of Object.keys(s)) if (!(k in out)) out[k] = s[k];
  return out;
}

/** Cena completa → formato que o modelo escreve (sem o que o script preenche). */
export function compactCena(cena) {
  const s = { ...cena.study };
  for (const k of ['slug', 'passageText', 'relatedVerses']) delete s[k];
  s.passages = (s.passages || []).map((p) => ({ ref: p.ref }));
  s.crossRefs = (s.crossRefs || []).map((c) => ({ ref: c.ref, bridge: c.bridge }));
  const questions = cena.questions.map((q0) => {
    const q = { ...q0 };
    for (const k of ['id', 'trail', 'section', 'skill', 'prompt', 'cue', 'passageText', 'template', 'correctAnswer']) delete q[k];
    if (q.type === 'true_false') delete q.options;
    if (q.type === 'order') delete q.correctOptionId;
    if (q.passageA) q.passageA = { ref: q.passageA.ref };
    if (q.passageB && q.passageB.ref !== 'Contexto') q.passageB = { ref: q.passageB.ref };
    return q;
  });
  return { study: s, questions };
}
