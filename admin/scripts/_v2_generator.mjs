/**
 * Gerador V2 — perguntas a partir de missão + estudo (+ legado opcional).
 */
import {
  clipPhrase,
  findTapTarget,
  foldKey,
  growInPassage,
  isIncompletePhrase,
  isVerseSnippet,
  passagePhrases,
} from './_answer_phrase.mjs';
import { bestPassageText, lookupPassage } from './_bible_lookup.mjs';

export const SHORT = { semente: 'sem', caminhada: 'cam', profundezas: 'pro' };

/** Atos por sessão (alinhado a ProgressService: 6 normal / 8 boss). */
export const ACTS_PER_MISSION = {
  lesson: { semente: 6, caminhada: 6, profundezas: 6 },
  boss: { semente: 8, caminhada: 8, profundezas: 8 },
};

/** Skill canônica por modo (Observação / Compreensão / Interpretação). */
export const PRIMARY_SKILL = {
  semente: 'observe',
  caminhada: 'understand',
  profundezas: 'interpret',
};

const SKILL_ROTATION = {
  semente: ['observe', 'observe', 'observe', 'observe', 'observe', 'observe', 'observe', 'observe'],
  caminhada: [
    'understand',
    'understand',
    'understand',
    'understand',
    'understand',
    'understand',
    'understand',
    'understand',
  ],
  profundezas: [
    'interpret',
    'interpret',
    'interpret',
    'interpret',
    'interpret',
    'interpret',
    'interpret',
    'interpret',
  ],
};

/** Metadados de dificuldade — IDs estáveis; rótulos = verbos cognitivos. */
export const DIFFICULTY_META = [
  {
    id: 'semente',
    label: 'Observação',
    subtitle: 'Observar o que o texto diz',
    description: 'Fatos explícitos — reconhecer e identificar no trecho.',
    xpMultiplier: 1,
    accent: '#F7BB01',
    icon: 'seed',
  },
  {
    id: 'caminhada',
    label: 'Compreensão',
    subtitle: 'Compreender o que o texto comunica',
    description: 'Relações e contexto — relacionar e comparar.',
    xpMultiplier: 1.5,
    accent: '#2EE6C5',
    icon: 'path',
  },
  {
    id: 'profundezas',
    label: 'Interpretação',
    subtitle: 'Interpretar o que o texto significa',
    description: 'Significado e implicação — sustentar com evidência.',
    xpMultiplier: 2,
    accent: '#4A9EFF',
    icon: 'book',
  },
];

function skillFor(diff) {
  return PRIMARY_SKILL[diff] || 'observe';
}

/** Frases banidas — nunca reintroduzir (validador também bloqueia). */
export const BANNED_DISTRACTOR_RE =
  /curiosidade hist[oó]rica|geneal[oó]gic[oa].*sem mensagem|cancela promessas|sem rela[cç][aã]o entre si|autonomia (humana )?plena|apenas memoriza[cç][aã]o de nomes|Revise o texto e o contexto da miss[aã]o/i;

/**
 * Brief da missão — base para gabarito e distratores contextualizados.
 * Sem topic/insight, o gerador não inventa opção genérica de poço.
 */
function missionBrief(mission = {}, study = {}) {
  const passage = passageBody(study, mission);
  let topicRaw =
    cleanKeyword(study.keyword) ||
    cleanKeyword(mission.title) ||
    cleanKeyword(mission.centralInsight) ||
    '';
  // Keyword não pode ser pergunta/frase longa (vira opção sem sentido)
  if (topicRaw.includes('?') || topicRaw.split(/\s+/).length > 4) {
    topicRaw =
      cleanKeyword(mission.title) ||
      topicRaw.split(/\s+/).slice(0, 2).join(' ') ||
      '';
  }
  // Só usa o tema se ecoar no verso — senão puxa substantivos do próprio palco.
  if (!topicRaw || (passage && !themeEchoesPassage(topicRaw, passage))) {
    const fromVerse = contentWords(passage)
      .filter((w) => w.length >= 4)
      .slice(0, 2)
      .join(' ');
    topicRaw = fromVerse || cleanKeyword(mission.title) || 'esta passagem';
  }
  const topic = topicRaw.length <= 3 ? topicRaw : topicRaw.replace(/^./, (c) => c.toLowerCase());
  const insight = declarativeClause(
    mission.centralInsight,
    study.keywordGloss,
    mission.hookNote,
    study.context,
  );
  const fact = declarativeClause(passage, study.passageText, mission.hookVerse, study.context);
  const ref = study.passageRef || mission.hookRef || 'o trecho';
  return { topic, insight, fact, ref, passage };
}

/**
 * Distratores amarrados ao tema da missão (erro plausível neste trecho).
 * Nunca reutiliza o poço genérico antigo.
 */
function contextualWrongTemplates(brief, diff) {
  const t = brief.topic || 'o tema';
  const ref = brief.ref || 'o trecho';
  if (diff === 'semente') {
    return [
      {
        text: `${ref} omite qualquer menção a ${t}`,
        fb: `Releia ${ref}: ${t} está no próprio relato.`,
      },
      {
        text: `O relato troca ${t} por um detalhe de outro capítulo`,
        fb: `Fique neste trecho: o fato explícito é sobre ${t}.`,
      },
      {
        text: `${t} só entraria depois deste versículo`,
        fb: `Neste trecho ${t} já aparece com clareza.`,
      },
      {
        text: `O texto descreve o contrário do que diz sobre ${t}`,
        fb: `Observe o que ${ref} afirma, sem inverter o sentido.`,
      },
      {
        text: `${t} aparece apenas como nota de rodapé sem peso`,
        fb: `${ref} dá peso a ${t}; não é detalhe descartável.`,
      },
      {
        text: `Nada em ${ref} toca o assunto de ${t}`,
        fb: `Volte ao versículo: ${t} está no centro do trecho.`,
      },
    ];
  }
  if (diff === 'profundezas') {
    return [
      {
        text: `${t} aqui ensina viver sem depender de Deus`,
        fb: `${t} no texto aponta dependência de Deus, não autonomia.`,
      },
      {
        text: `${t} fica isolado, sem eco no restante das Escrituras`,
        fb: `${t} se lê no fio maior da Bíblia; o trecho não é ilha.`,
      },
      {
        text: `A implicação correta de ${t} ignora o que ${ref} diz`,
        fb: `Interprete ${t} com a evidência de ${ref}.`,
      },
      {
        text: `Aplicar ${t} autoriza desobedecer ao que o versículo afirma`,
        fb: `A implicação deve seguir o que ${ref} diz sobre ${t}.`,
      },
      {
        text: `${t} se reduz a curiosidade sem chamado prático`,
        fb: `${t} carrega sentido e chamado neste relato.`,
      },
      {
        text: `${t} isenta o leitor de qualquer resposta diante de Deus`,
        fb: `${t} implica responsabilidade, não licença.`,
      },
    ];
  }
  return [
    {
      text: `${t} neste trecho é só aparência, sem vocação`,
      fb: `No trecho, ${t} não é só aparência — há sentido e chamado.`,
    },
    {
      text: `Sobre ${t}, o relato anula a palavra ou ação de Deus`,
      fb: `${ref} não anula a ação de Deus em ${t}.`,
    },
    {
      text: `${t} fica restrito a poucos, sem alcance no povo`,
      fb: `Leia com cuidado: ${t} não fica restrito a uma elite.`,
    },
    {
      text: `${t} surge por acaso, sem propósito no relato`,
      fb: `${t} no relato tem propósito, não é acidente.`,
    },
    {
      text: `O contexto de ${t} isenta qualquer resposta humana`,
      fb: `${t} implica responsabilidade, não isenção.`,
    },
    {
      text: `${t} neste trecho não se liga ao que Deus faz`,
      fb: `${t} está ligado à ação de Deus em ${ref}.`,
    },
  ];
}

function clip(text, max = 110) {
  let t = stripQuotes(String(text || '').replace(/\s+/g, ' ').trim());
  if (!t) return '';
  if (t.length <= max) return t;
  const budget = max - 1;
  let cut = t.slice(0, budget);
  const sp = cut.lastIndexOf(' ');
  if (sp > Math.min(24, Math.floor(budget * 0.45))) cut = cut.slice(0, sp);
  cut = cut.replace(/[,;:…\-–—]+$/g, '').trim();
  // Nunca cortar no meio da palavra.
  if (/[\p{L}]$/u.test(cut) && /[\p{L}]/u.test(t[cut.length] || '')) {
    const sp2 = cut.lastIndexOf(' ');
    if (sp2 > 16) cut = cut.slice(0, sp2).replace(/[,;:]+$/g, '').trim();
  }
  return cut ? `${cut}…` : t.slice(0, Math.min(40, max));
}

/** Remove aspas tipográficas / residuais. */
function stripQuotes(s) {
  return String(s || '')
    .replace(/[“”"«»]/g, '')
    .replace(/^['\s]+|['\s]+$/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

/** Cláusula afirmativa — rejeita perguntas e objetivos meta. */
function declarativeClause(...candidates) {
  const badLead = /^(o que|por que|como|qual|quem|onde|quando|onde você)\b/i;
  for (const raw of candidates) {
    const t = stripQuotes(firstClause(raw));
    if (!t || t.length < 8) continue;
    if (t.includes('?')) continue;
    if (badLead.test(t)) continue;
    return t;
  }
  return '';
}

/** Afirmação V/F: corta e sempre fecha com pontuação. */
function clipStatement(text, max = 140) {
  let t = clip(text, max);
  if (!t) return t;
  if (/[.!?…]$/.test(t)) return t;
  return `${t}.`;
}

/** Remove glossário hebraico/grego e barras: "Criar (bara)" → "criação". */
function cleanKeyword(raw) {
  let t = stripQuotes(
    String(raw || '')
      .replace(/\([^)]*\)/g, ' ')
      .replace(/\/[^/]+/g, ' ')
      .replace(/\s+/g, ' ')
      .trim(),
  );
  if (!t) return '';
  if (/^criar$/i.test(t)) return 'criação';
  if (/^falar$/i.test(t)) return 'palavra de Deus';
  return clip(t, 40);
}

/** Objetivo pedagógico — nunca pergunta de estudo (focusQuestion). */
function learningGoal(mission, study, fallback) {
  const t = declarativeClause(
    mission?.objective,
    study?.context,
    mission?.centralInsight,
    study?.keywordGloss,
    fallback,
  );
  return clip(t || fallback || 'Ler a passagem com fidelidade.', 90);
}

/**
 * Tema curto para Toque — só substantivo/ideia achável no texto.
 * Nunca focusQuestion, nunca frase interrogativa, nunca glossário longo.
 */
function tapFocusLabel(study, mission, passage = '') {
  const badLead = /^(o que|por que|como|qual|quem|onde|quando)\b/i;
  const cleaned = cleanKeyword(study?.keyword);
  const candidates = [
    cleaned,
    cleanKeyword(mission?.title),
    contentWords(study?.context || '')[0],
    contentWords(mission?.centralInsight || '')[0],
  ];

  for (const raw of candidates) {
    const t = String(raw || '').trim();
    if (!t || t.length > 40) continue;
    if (badLead.test(t)) continue;
    if (t.includes('?')) continue;
    if (passage && !themeEchoesPassage(t, passage)) continue;
    return clip(t.toLowerCase(), 36);
  }
  const fromPassage =
    contentWords(passage).find((w) =>
      /\b(criou|disse|fez|chamou|espirito|principio|terra|aguas|luz)\b/i.test(w),
    ) || contentWords(passage)[0];
  return (fromPassage || 'o texto').toLowerCase();
}

function lowerFirst(s) {
  const t = String(s || '').trim();
  if (!t) return t;
  // Mantém nomes próprios / teônimos no início da cláusula.
  if (
    /^(Deus|Senhor|Jesus|Cristo|Esp[ií]rito|Yahweh|Ad[aã]o|Eva|Mois[eé]s|Abra[aã]o|Sara|Isaque|Jac[oó]|Israel|Jos[eé]|Davi|Salom[aã]o|Isa[ií]as|Jeremias|Ezequiel|Daniel|Pedro|Paulo|Jo[aã]o|Maria|No[eé]|Caim|Abel)\b/u.test(
      t,
    )
  ) {
    return t;
  }
  return t.charAt(0).toLowerCase() + t.slice(1);
}

/** Corta template preservando a lacuna `___`. */
function clipKeepingBlank(template, max = 200) {
  const t = String(template || '').replace(/\s+/g, ' ').trim();
  if (t.length <= max) return t;
  const blank = t.indexOf('___');
  if (blank < 0) return clip(t, max);
  const pad = Math.max(40, Math.floor((max - 3) / 2));
  const start = Math.max(0, blank - pad);
  const end = Math.min(t.length, start + max);
  let out = t.slice(start, end).trim();
  if (start > 0) out = `…${out}`;
  if (end < t.length) out = `${out}…`;
  if (!out.includes('___')) out = `${clip(t, max - 4)} ___`;
  return out;
}

function firstClause(text) {
  const t = String(text || '').replace(/\s+/g, ' ').trim();
  const m = t.match(/^[^.!?]+[.!?]?/);
  return (m ? m[0] : t).replace(/[.!?]+$/, '').trim();
}

function ensureQuestion(text) {
  const t = String(text || '').replace(/\s+/g, ' ').trim();
  if (!t) return 'O que o texto comunica nesta passagem?';
  if (t.endsWith('?')) return t;
  if (/^(o que|por que|como|qual|quem|onde|quando)/i.test(t)) return `${t}?`;
  return `${t}?`;
}

function pickDistractors(correct, diff, n = 3, seed = 0, brief = {}) {
  const key = foldKey(correct);
  const templates = contextualWrongTemplates(brief, diff);
  const out = [];
  for (let i = 0; i < templates.length && out.length < n; i++) {
    const item = templates[(i + seed) % templates.length];
    const text = clipOption(item.text, 95);
    if (!text || foldKey(text) === key) continue;
    if (BANNED_DISTRACTOR_RE.test(text)) continue;
    if (out.some((o) => foldKey(o.text) === foldKey(text))) continue;
    out.push({ text, fb: clip(item.fb, 100) });
  }
  // Fallback contextual (nunca poço genérico antigo)
  let guard = 0;
  while (out.length < n && guard < 6) {
    const t = brief.topic || 'o tema';
    const text = clipOption(`${t}: leitura que ${brief.ref || 'o trecho'} não sustenta (${out.length + 1})`, 95);
    if (text && !out.some((o) => foldKey(o.text) === foldKey(text))) {
      out.push({
        text,
        fb: clip(`Essa opção não se sustenta no que o texto diz sobre ${t}.`, 100),
      });
    }
    guard += 1;
  }
  return out.slice(0, n);
}

/** Opção fechada: nunca devolve frase truncada / pendurada / com reticências. */
function clipOption(text, max = 95) {
  let t = stripQuotes(String(text || '').replace(/\s+/g, ' ').trim());
  if (!t) return '';
  t = t.replace(/[…]+/g, ' ').replace(/\s+/g, ' ').trim();
  if (t.length <= max && !isBrokenOption(t)) return t;
  const clause = declarativeClause(t) || firstClause(t);
  if (clause && clause.length <= max && clause.length >= 8 && !isBrokenOption(clause)) {
    return clause;
  }
  let cut = t.slice(0, max);
  const sp = cut.lastIndexOf(' ');
  if (sp > Math.min(20, Math.floor(max * 0.4))) cut = cut.slice(0, sp);
  cut = cut.replace(/[,;:…\-–—]+$/g, '').trim();
  cut = cut.replace(/\s+(e|mas|ou|nem|de|do|da|dos|das|que|para|por|com|os|as|o|a|ao|à)$/i, '').trim();
  if (isBrokenOption(cut)) {
    const words = cut.split(/\s+/).filter(Boolean);
    while (words.length > 3 && isBrokenOption(words.join(' '))) words.pop();
    cut = words.join(' ');
  }
  if (isBrokenOption(cut)) {
    const safe = declarativeClause(briefSafeFallback(t)) || firstClause(t);
    if (safe && !isBrokenOption(safe) && safe.length <= max) return safe;
    return '';
  }
  return cut;
}

function briefSafeFallback(t) {
  const words = String(t || '')
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 10);
  return words.join(' ');
}

/** Frase de opção quebrada (corta no meio / artigo pendurado). */
export function isBrokenOption(text) {
  const t = String(text || '').replace(/\s+/g, ' ').trim();
  if (!t) return true;
  if (/…$|\.\.\.$/.test(t)) return true;
  const words = t.split(/\s+/);
  // "… os céus e a" / "… depois os"
  if (words.length >= 4 && /\s+(e|mas|ou|nem|de|do|da|dos|das|que|para|por|com|os|as|o|a|ao|à)$/i.test(t)) {
    return true;
  }
  if (/,\s*(os|as|o|a|e)?$/i.test(t)) return true;
  return false;
}

function isSubsetOption(a, b) {
  const fa = foldKey(a);
  const fb = foldKey(b);
  if (!fa || !fb || fa === fb) return false;
  if (fa.length < 4) return false;
  return fb.includes(fa) && fa.length <= fb.length * 0.92;
}

/** Escolhe N opções distintas, sem truncar e sem uma ser pedaço da outra. */
function pickDistinctOptions(prefer, candidates, n = 3) {
  const out = [];
  const push = (raw) => {
    const t = stripQuotes(String(raw || '').replace(/\s+/g, ' ').trim());
    if (!t || isBrokenOption(t)) return false;
    if (out.some((o) => foldKey(o) === foldKey(t) || isSubsetOption(t, o) || isSubsetOption(o, t))) {
      return false;
    }
    out.push(t);
    return true;
  };
  if (prefer) push(prefer);
  for (const c of candidates) {
    if (out.length >= n) break;
    push(c);
  }
  return out;
}

/**
 * @param {string} correctText
 * @param {string} diff
 * @param {number} seed
 * @param {{ topic?: string, insight?: string, fact?: string, ref?: string }} brief
 */
function makeOptions(correctText, diff, seed = 0, brief = {}) {
  let correct = clipOption(stripQuotes(correctText), 95);
  if (isBrokenOption(correct)) {
    correct = clipOption(brief.insight || brief.fact || `O texto afirma algo sobre ${brief.topic || 'o tema'}`, 95);
  }
  const wrongs = pickDistractors(correct, diff, 3, seed, brief);
  // Equilíbrio de comprimento: certa não pode ser 2×+ maior que as erradas
  const wrongLens = wrongs.map((w) => w.text.length);
  const avgWrong = wrongLens.reduce((a, b) => a + b, 0) / Math.max(1, wrongLens.length);
  if (correct.length > 70 && avgWrong > 0 && correct.length / avgWrong >= 2) {
    correct = clipOption(firstClause(correct) || correct, Math.max(48, Math.round(avgWrong * 1.3)));
  }
  const slot = seed % 4;
  const texts = wrongs.map((w) => w.text);
  texts.splice(slot, 0, correct);
  const ids = ['a', 'b', 'c', 'd'];
  const wrongFb = {};
  let wi = 0;
  for (let i = 0; i < ids.length; i++) {
    if (i === slot) continue;
    const w = wrongs[wi++];
    wrongFb[ids[i]] =
      w?.fb ||
      clip(`Essa leitura não se sustenta neste trecho sobre ${brief.topic || 'o tema'}.`, 100);
  }
  return {
    options: texts.map((text, i) => ({ id: ids[i], text })),
    correct: ids[slot],
    wrongFb,
  };
}

function makeTrueFalse(statement, correctTrue, ok, wrongMsg) {
  return {
    type: 'true_false',
    question: clip(statement, 140),
    options: [
      { id: 'true', text: 'Verdadeiro' },
      { id: 'false', text: 'Falso' },
    ],
    correct: correctTrue ? 'true' : 'false',
    ok,
    wrong: { [correctTrue ? 'false' : 'true']: wrongMsg },
  };
}

function normalizeOptions(raw, diff, seed, correctText, brief = {}) {
  if (!raw || !raw.length) {
    return makeOptions(correctText || 'Resposta alinhada ao texto.', diff, seed, brief);
  }
  if (raw[0]?.id && raw[0]?.text) {
    const correct = raw.find((o) => o.id)?.id || 'a';
    const topic = brief.topic || 'o tema';
    return {
      options: raw,
      correct,
      wrongFb: Object.fromEntries(
        raw
          .filter((o) => o.id !== correct)
          .map((o) => [o.id, clip(`Essa opção não se sustenta no trecho sobre ${topic}.`, 100)]),
      ),
    };
  }
  if (Array.isArray(raw[0])) {
    const options = raw.map(([id, text]) => ({ id, text }));
    const correct = options[0]?.id || 'a';
    const topic = brief.topic || 'o tema';
    return {
      options,
      correct,
      wrongFb: Object.fromEntries(
        options
          .filter((o) => o.id !== correct)
          .map((o) => [o.id, clip(`Essa opção não se sustenta no trecho sobre ${topic}.`, 100)]),
      ),
    };
  }
  return makeOptions(correctText || 'Resposta alinhada ao texto.', diff, seed, brief);
}

function sanitizeOptionList(raw, correctId) {
  const FALLBACKS = [
    'uma leitura que o trecho não sustenta',
    'um detalhe de outro capítulo',
    'o contrário do que o versículo diz',
  ];
  const opts = (raw || []).map((o) =>
    Array.isArray(o) ? { id: o[0], text: String(o[1] || '').trim() } : { id: o.id, text: String(o.text || '').trim() },
  );
  const cid = String(correctId || opts[0]?.id || 'a');
  for (let i = 0; i < opts.length; i++) {
    for (let j = 0; j < opts.length; j++) {
      if (i === j) continue;
      if (!isSubsetOption(opts[i].text, opts[j].text) && !isSubsetOption(opts[j].text, opts[i].text)) continue;
      const drop = String(opts[i].id) === cid ? j : i;
      if (String(opts[drop].id) === cid) continue;
      const replacement = FALLBACKS.find(
        (f) =>
          !opts.some(
            (o) =>
              foldKey(o.text) === foldKey(f) ||
              isSubsetOption(f, o.text) ||
              isSubsetOption(o.text, f),
          ),
      );
      if (replacement) opts[drop] = { ...opts[drop], text: replacement };
    }
  }
  return opts;
}

/** Ordem canônica dos gestos (1 ato de cada no treino normal). */
export const GESTURE_LESSON = [
  'true_false',
  'tap',
  'choice',
  'order',
  'complete',
  'connect',
];
export const GESTURE_BOSS = [...GESTURE_LESSON, 'tap', 'order'];

export function gestureForAct(n, { boss = false } = {}) {
  const rot = boss ? GESTURE_BOSS : GESTURE_LESSON;
  return rot[(Math.max(1, n) - 1) % rot.length];
}

export function makeV2Question({
  trail,
  section,
  diff,
  n,
  fields,
}) {
  const type = fields.type || 'choice';
  const skill = fields.skill || SKILL_ROTATION[diff][(n - 1) % SKILL_ROTATION[diff].length];
  const question = fields.question;
  const verseRef = fields.verseRef || '';
  const base = {
    id: `${trail}-${SHORT[diff]}-${section}-${String(n).padStart(2, '0')}`,
    trail,
    difficulty: diff,
    section,
    type,
    skill,
    question,
    prompt: fields.prompt || question,
    cue: fields.cue || fields.prompt || question,
    verseRef,
    learningObjective: fields.learningObjective || clip(question, 80),
    evidence: fields.evidence || (verseRef ? [verseRef] : []),
    feedbackCorrect: fields.ok || 'Correto.',
    feedbackWrong: fields.wrong || {},
    ...(fields.passageText ? { passageText: fields.passageText } : {}),
    ...(fields.template ? { template: fields.template } : {}),
    ...(fields.correctOrder ? { correctOrder: fields.correctOrder } : {}),
    ...(fields.passageA ? { passageA: fields.passageA } : {}),
    ...(fields.passageB ? { passageB: fields.passageB } : {}),
  };

  if (type === 'true_false') {
    return {
      ...base,
      options: fields.options || [
        { id: 'true', text: 'Verdadeiro' },
        { id: 'false', text: 'Falso' },
      ],
      correctOptionId: fields.correct,
      correctAnswer: fields.correct,
    };
  }

  if (type === 'order') {
    const options = (fields.options || []).map((o) =>
      Array.isArray(o) ? { id: o[0], text: o[1] } : o,
    );
    const order = fields.correctOrder || options.map((o) => o.id);
    return {
      ...base,
      options,
      correctOrder: order,
      correctOptionId: order[0] || 'a',
      correctAnswer: order.join(','),
    };
  }

  if (type === 'complete') {
    const opts = normalizeOptions(
      fields.options,
      diff,
      n + section.length,
      fields.correctText,
    );
    const correctId = fields.correct || opts.correct;
    return {
      ...base,
      template: fields.template,
      options: sanitizeOptionList(opts.options, correctId),
      correctOptionId: correctId,
      correctAnswer: correctId,
      feedbackWrong: fields.wrong && Object.keys(fields.wrong).length ? fields.wrong : opts.wrongFb,
    };
  }

  if (type === 'tap' || type === 'connect') {
    const opts = normalizeOptions(
      fields.options,
      diff,
      n + section.length,
      fields.correctText,
    );
    const correctId = fields.correct || opts.correct;
    return {
      ...base,
      options: sanitizeOptionList(opts.options, correctId),
      correctOptionId: correctId,
      correctAnswer: correctId,
      feedbackWrong: fields.wrong && Object.keys(fields.wrong).length ? fields.wrong : opts.wrongFb,
    };
  }

  const opts = normalizeOptions(
    fields.options,
    diff,
    n + section.length,
    fields.correctText,
  );
  const correctId = fields.correct || opts.correct;
  return {
    ...base,
    options: sanitizeOptionList(opts.options, correctId),
    correctOptionId: correctId,
    correctAnswer: correctId,
    feedbackWrong: fields.wrong && Object.keys(fields.wrong).length ? fields.wrong : opts.wrongFb,
  };
}

function scoreLegacy(q, diff) {
  let s = 0;
  if (/-x(ch|fill|tru)/i.test(q.id || '')) return -99;
  if (q.difficulty !== diff) return -99;
  const stem = (q.prompt || q.question || '').trim();
  if (stem.length < 12) return -10;
  if (/^(complete|monte)/i.test(stem)) return -5;
  if (q.type === 'order' || q.type === 'connect') return -3;
  s += Math.min(stem.length / 20, 4);
  if ((q.options || []).filter((o) => o.text?.trim()).length >= 3) s += 2;
  if (q.feedbackCorrect && q.feedbackCorrect.length > 10) s += 2;
  if (q.type === 'choice') s += 2;
  const passage = q.passageText || '';
  if (['caminhada', 'profundezas'].includes(diff) && passage) {
    const frags = (q.options || []).filter((o) =>
      isVerseSnippet(o.text || '', passage),
    ).length;
    if (frags >= 2) s -= 4;
  }
  return s;
}

function upgradeLegacy(q, mission, study, trail, diff, n) {
  const ref = study?.passageRef || mission.hookRef || '';
  const stem = clip((q.prompt || q.question || '').trim(), 140);
  let type = q.type === 'true_false' ? 'true_false' : 'choice';
  if (type !== 'true_false' && (q.type === 'order' || q.type === 'tap')) type = 'choice';

  let question = stem;
  if (type === 'true_false') {
    if (stem.includes('?') || /^(o que|qual|quem)/i.test(stem)) {
      question = clip(`O trecho afirma: ${firstClause(study?.passageText || mission.hookNote || stem)}.`, 140);
    }
  }

  const correctOpt = (q.options || []).find(
    (o) => String(o.id) === String(q.correctOptionId || q.correctAnswer),
  );
  const correctText = correctOpt?.text || study?.keywordGloss || study?.keyword || 'Sim';

  let fields;
  if (type === 'true_false') {
    const ans = String(q.correctAnswer || q.correctOptionId || 'true').toLowerCase();
    const isTrue = ans === 'true' || ans === 'verdadeiro';
    fields = makeTrueFalse(
      question,
      isTrue,
      q.feedbackCorrect || 'Correto.',
      Object.values(q.feedbackWrong || {})[0] || 'Revise o texto.',
    );
  } else {
    const opts = (q.options || []).filter((o) => (o.text || '').trim());
    let options;
    let correct = q.correctOptionId || 'a';
    if (opts.length >= 3 && opts.every((o) => !isVerseSnippet(o.text, q.passageText || ''))) {
      options = opts.slice(0, 4).map((o) => [o.id, clip(o.text, 95)]);
      correct = q.correctOptionId || opts[0].id;
    } else {
      const built = makeOptions(correctText, diff, n, missionBrief(mission, study));
      options = built.options.map((o) => [o.id, o.text]);
      correct = built.correct;
    }
    fields = {
      type: 'choice',
      question,
      options,
      correct,
      ok: q.feedbackCorrect || 'Correto.',
      wrong: q.feedbackWrong || {},
      passageText: q.passageText || study?.passageText,
    };
  }

  return makeV2Question({
    trail,
    section: mission.slug,
    diff,
    n,
    fields: {
      ...fields,
      skill: SKILL_ROTATION[diff][(n - 1) % SKILL_ROTATION[diff].length],
      verseRef: q.verseRef || ref,
      learningObjective: learningGoal(mission, study, clip(question, 80)),
      evidence: [q.verseRef || ref].filter(Boolean),
    },
  });
}
function wordCount(text) {
  return String(text || '')
    .trim()
    .split(/\s+/)
    .filter(Boolean).length;
}

/** Opção de tap/order: substring literal do texto, sem reticências. */
function verbatimSnippet(passage, needle, max = 64) {
  const p = String(passage || '');
  let n = String(needle || '')
    .replace(/\s+/g, ' ')
    .replace(/[…]+/g, ' ')
    .trim();
  if (!n) return '';

  const tryExact = (raw) => {
    const t = String(raw || '').replace(/\s+/g, ' ').trim();
    if (!t || t.includes('…')) return '';
    const idx = p.toLowerCase().indexOf(t.toLowerCase());
    if (idx < 0) return '';
    let snippet = p.slice(idx, idx + t.length).replace(/\s+/g, ' ').trim();
    if (snippet.includes('…')) return '';
    if (snippet.length <= max) return snippet;
    const words = snippet.split(/\s+/);
    for (let len = Math.min(words.length, 8); len >= 3; len--) {
      const cut = words.slice(0, len).join(' ');
      if (p.toLowerCase().includes(cut.toLowerCase()) && !cut.includes('…')) return cut;
    }
    return '';
  };

  const direct = tryExact(n);
  if (direct) return direct;

  // Aceita variação de pontuação: "Ora o Senhor" → "Ora, o Senhor"
  const words = n
    .split(/\s+/)
    .map((w) => w.replace(/[^\p{L}]/gu, ''))
    .filter((w) => w.length >= 2);
  if (words.length >= 2) {
    const re = new RegExp(
      words.map((w) => w.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('[\\s,.!?;:…—–\'\"-]*'),
      'i',
    );
    const m = p.match(re);
    if (m && m[0] && !m[0].includes('…') && m[0].length <= max + 12) {
      const hit = tryExact(m[0]) || m[0].replace(/\s+/g, ' ').trim();
      if (hit && !hit.includes('…') && hit.length <= max) return hit;
      if (hit && hit.length > max) {
        const ws = hit.split(/\s+/);
        for (let len = Math.min(ws.length, 8); len >= 3; len--) {
          const cut = ws.slice(0, len).join(' ');
          const ok = tryExact(cut);
          if (ok) return ok;
        }
      }
    }
  }

  const grown = growInPassage(p, n);
  if (grown && !grown.includes('…')) return tryExact(grown);
  return '';
}

function tapCandidates(passage, prefer) {
  const p = String(passage || '').replace(/\s+/g, ' ').trim();
  const out = [];
  const push = (raw) => {
    const v = verbatimSnippet(p, raw, 64);
    if (!v || wordCount(v) < 2) return;
    if (v.includes('…')) return;
    if (isIncompletePhrase(v) && wordCount(v) < 4) return;
    if (out.some((x) => foldKey(x) === foldKey(v))) return;
    out.push(v);
  };

  // Trechos já cortados com … no estudo → cada fatia é candidata.
  for (const chunk of p.split(/…+/)) {
    const c = chunk.replace(/^[,;:\s]+|[,;:\s]+$/g, '').trim();
    if (wordCount(c) >= 3 && c.length <= 90) push(c);
  }

  const hint = String(prefer || '').trim();
  if (hint) {
    push(findTapTarget(hint, p) || growInPassage(p, hint) || hint);
  }
  for (const phrase of passagePhrases(p, hint)) push(phrase);

  const clauses = p
    .split(/[;.!?]+/)
    .map((s) => s.trim())
    .filter((s) => wordCount(s) >= 3 && wordCount(s) <= 14 && !s.includes('…'));
  for (const c of clauses) push(c);

  return out;
}

function contentWords(passage) {
  return String(passage || '')
    .replace(/[^\p{L}\s]/gu, ' ')
    .split(/\s+/)
    .map((w) => w.trim())
    .filter((w) => w.length >= 4)
    .filter(
      (w) =>
        !/^(deus|senhor|porque|quando|onde|como|para|pelo|pela|pela|uma|uns|este|esta|esse|essa|aquele|aquela|disse|havia|porém|sobre|entre|depois|antes|também|toda|todo|face)$/i.test(
          w,
        ),
    );
}

function significantTokens(text) {
  return contentWords(text);
}

function passageBody(study, mission) {
  return bestPassageText({
    passageRef: study?.passageRef || mission?.hookRef,
    passageText: study?.passageText,
    hookRef: mission?.hookRef,
    hookVerse: mission?.hookVerse,
  });
}

/** Variantes ortográficas simples para eco no texto (criação↔criou). */
function themeVariants(theme) {
  const base = foldKey(theme);
  const out = new Set([base]);
  for (const w of base.split(/\s+/).filter((x) => x.length >= 4)) {
    out.add(w);
    out.add(w.replace(/acao$/, 'ou')); // criação → criou
    out.add(w.replace(/acao$/, 'ar')); // criação → criar
    out.add(w.replace(/cao$/, 'cou')); // (fallback curto)
    out.add(w.replace(/ar$/, 'ou')); // criar → criou
    out.add(w.replace(/ar$/, 'ado')); // formar → formado
    out.add(w.replace(/dade$/, '')); // bondade → bond
  }
  return [...out].filter(Boolean);
}

function themeEchoesPassage(theme, passage) {
  if (!passage) return true;
  const pFold = foldKey(passage);
  const words = contentWords(theme).filter((w) => w.length >= 4);
  if (words.length >= 2) {
    const hits = words.filter((w) =>
      themeVariants(w).some((v) => v.length >= 3 && pFold.includes(v)),
    );
    return hits.length >= Math.ceil(words.length * 0.6);
  }
  return themeVariants(theme).some((v) => v.length >= 3 && pFold.includes(v));
}

/** Pontua cláusula pelo eco do tema (criar↔criou, etc.). */
function scoreClauseForTheme(clause, theme) {
  const c = foldKey(clause);
  const variants = themeVariants(theme);
  if (!variants.length) return 0;
  let score = 0;
  for (const w of variants) {
    if (w.length >= 3 && c.includes(w)) score += 3;
  }
  if (/\b(criou|disse|fez|chamou|viu|formou|abençoou|pairava)\b/i.test(clause)) score += 1;
  return score;
}

function pickTapTarget(passage, study) {
  const theme = cleanKeyword(study?.keyword) || firstClause(study?.context || '');
  const candidates = tapCandidates(passage, theme);
  if (!candidates.length) {
    return firstClause(passage) || cleanKeyword(study?.keyword) || 'Deus';
  }
  let best = candidates[0];
  let bestScore = -1;
  for (const c of candidates) {
    const s = scoreClauseForTheme(c, theme);
    if (s > bestScore) {
      bestScore = s;
      best = c;
    }
  }
  // Se tema não ecoa em nada, usa a cláusula mais substantiva (não a 1ª curta).
  if (bestScore <= 0) {
    const byLen = [...candidates].sort((a, b) => wordCount(b) - wordCount(a));
    best = byLen.find((c) => wordCount(c) >= 4) || best;
  }
  return best;
}

function finalizeSnippet(passage, raw, max = 72) {
  let s = verbatimSnippet(passage, raw, max) || clipPhrase(String(raw || ''), max);
  s = stripQuotes(String(s || '').replace(/\s+/g, ' ').trim());
  if (!s) return '';
  if (!isBrokenOption(s)) return s;
  const grown = growInPassage(passage, s);
  if (grown) {
    const g = clipPhrase(grown, max);
    if (g && !isBrokenOption(g)) return g;
  }
  const words = s.split(/\s+/).filter(Boolean);
  while (words.length > 3 && isBrokenOption(words.join(' '))) words.pop();
  s = words
    .join(' ')
    .replace(/\s+(e|mas|ou|nem|de|do|da|dos|das|que|para|por|com|os|as|o|a|ao|à)$/i, '')
    .trim();
  return isBrokenOption(s) ? '' : s;
}

function orderPieces(passage, study, mission) {
  const p = String(passage || '').replace(/\s+/g, ' ').trim();
  const tidy = (raw) => finalizeSnippet(p, raw, 72) || stripQuotes(String(raw || '').replace(/\s+/g, ' ').trim());
  const clauses = p
    .split(/[;.!?]+/)
    .map((s) => s.trim())
    .filter((s) => wordCount(s) >= 3 && s.length <= 100)
    .map((s) => tidy(s))
    .filter((s) => s && !isBrokenOption(s));
  if (clauses.length >= 3) return clauses.slice(0, 3);
  const byComma = p
    .split(/,(?=\s+[A-ZÁÉÍÓÚÀÃÕÂÊÔ])/u)
    .map((s) => tidy(s))
    .filter((s) => s && wordCount(s) >= 3 && !isBrokenOption(s));
  if (byComma.length >= 3) return byComma.slice(0, 3);
  const words = p.split(/\s+/).filter(Boolean);
  if (words.length >= 12) {
    const third = Math.max(3, Math.floor(words.length / 3));
    return [0, 1, 2]
      .map((i) => {
        const slice = words.slice(i * third, i === 2 ? words.length : (i + 1) * third).join(' ');
        return tidy(slice);
      })
      .filter(Boolean);
  }
  const fallback = tapCandidates(p, study?.keyword)
    .map((x) => tidy(x))
    .filter((x) => x && !isBrokenOption(x));
  while (fallback.length < 3) {
    fallback.push(
      clipPhrase(
        firstClause(study?.context || mission?.centralInsight || p) || `Trecho ${fallback.length + 1}`,
        56,
      ),
    );
  }
  return fallback.slice(0, 3);
}

function verseClauses(passage) {
  return String(passage || '')
    .replace(/…+/g, '. ')
    .split(/[;.!?]+/)
    .map((s) => s.replace(/\s+/g, ' ').trim())
    .filter((s) => wordCount(s) >= 4 && s.length <= 110 && !isBrokenOption(s));
}

function inPassage(opt, passage) {
  if (!opt || !passage) return false;
  return foldKey(passage).includes(foldKey(opt));
}

function uniqueNonSubset(prefer, candidates, n, passage) {
  const out = [];
  const push = (raw) => {
    let t = finalizeSnippet(passage, raw, 72) || stripQuotes(String(raw || '').replace(/\s+/g, ' ').trim());
    t = t.replace(/[…]+/g, ' ').replace(/\s+/g, ' ').trim();
    if (!t || isBrokenOption(t) || wordCount(t) < 2) return false;
    if (passage && !inPassage(t, passage) && wordCount(t) >= 3) return false;
    if (out.some((o) => foldKey(o) === foldKey(t) || isSubsetOption(t, o) || isSubsetOption(o, t))) {
      return false;
    }
    out.push(t);
    return true;
  };
  if (prefer) push(prefer);
  for (const c of candidates) {
    if (out.length >= n) break;
    push(c);
  }
  return out;
}

function buildTrueFalseFields(mission, study, diff, n, used = new Set()) {
  const ref = study.passageRef || mission.hookRef || 'esta passagem';
  const passage = passageBody(study, mission);
  const verseFact =
    firstClause(passage) ||
    declarativeClause(passage, study.passageText, mission.hookVerse) ||
    'O texto apresenta a ação de Deus';
  const relation =
    declarativeClause(study.context, mission.hookNote, study.keywordGloss) || verseFact;
  const implication =
    declarativeClause(mission.centralInsight, study.keywordGloss, study.context) || relation;
  const asTrue = n % 2 === 1;
  const review = n > 6;

  let statement;
  if (asTrue) {
    if (diff === 'caminhada') {
      statement = review
        ? `Revisão: em ${ref}, ${lowerFirst(relation)}.`
        : `Em ${ref}, o relato comunica que ${lowerFirst(relation)}.`;
    } else if (diff === 'profundezas') {
      statement = review
        ? `Revisão: ${ref} implica que ${lowerFirst(implication)}.`
        : `${ref} sustenta que ${lowerFirst(implication)}.`;
    } else {
      const fact = lowerFirst(verseFact).replace(/^(entretanto|então|ora|porém),?\s+/i, '');
      statement = review
        ? `Revisão: segundo ${ref}, ${fact}.`
        : `Segundo ${ref}, ${fact}.`;
    }
  } else if (diff === 'caminhada') {
    statement = `Em ${ref}, os fatos do relato não se relacionam entre si.`;
  } else if (diff === 'profundezas') {
    statement = `${ref} ensina que o ser humano age sozinho, sem Deus.`;
  } else {
    statement = `Em ${ref}, o texto nega qualquer ação de Deus.`;
  }

  used.add(`tf:${diff}:${foldKey(statement)}`);
  return {
    type: 'true_false',
    ...makeTrueFalse(
      clipStatement(statement, 140),
      asTrue,
      asTrue ? 'Correto. A afirmação condiz com o texto.' : 'Exato — essa negação não está no texto.',
      asTrue
        ? 'Releia o versículo: a afirmação distorce o que está escrito.'
        : 'O texto não sustenta essa negação. Releia o trecho.',
    ),
    learningObjective: learningGoal(mission, study, `Verificar leitura de ${ref}.`),
    passageText: passage,
    skill: skillFor(diff),
  };
}

function buildChoiceFields(mission, study, diff, n, used = new Set()) {
  const brief = missionBrief(mission, study);
  const ref = brief.ref;
  const topic = brief.topic;
  const passage = passageBody(study, mission);
  const verseFact = firstClause(passage) || brief.fact;

  let correctRaw;
  if (diff === 'semente') {
    correctRaw = verseFact || `O texto registra ${topic} neste trecho`;
  } else if (diff === 'profundezas') {
    correctRaw =
      brief.insight ||
      declarativeClause(mission.centralInsight, study.keywordGloss, mission.hookNote) ||
      verseFact;
  } else {
    correctRaw =
      declarativeClause(study.context, mission.hookNote, study.keywordGloss) ||
      brief.insight ||
      verseFact;
  }
  let correct = clipOption(correctRaw || `O texto afirma algo essencial sobre ${topic}`, 90);
  if (!correct || isBrokenOption(correct) || used.has(`ch:${foldKey(correct)}`)) {
    correct = clipOption(verseFact || `O relato de ${ref} trata de ${topic}`, 90);
  }
  used.add(`ch:${foldKey(correct)}`);
  const { options, correct: cid, wrongFb } = makeOptions(correct, diff, n + diff.length, brief);
  const stems = {
    semente: [
      ensureQuestion(`Segundo ${ref}, o que o texto afirma sobre ${topic}`),
      ensureQuestion(`Qual fato ${ref} registra com clareza`),
      ensureQuestion(`O que ${ref} diz de forma explícita`),
    ],
    caminhada: [
      ensureQuestion(`O que ${ref} comunica sobre ${topic}`),
      ensureQuestion(`Qual leitura o contexto de ${ref} favorece`),
      ensureQuestion(`Como ${ref} relaciona ${topic} com a ação de Deus`),
    ],
    profundezas: [
      ensureQuestion(`Que implicação ${ref} sustenta`),
      ensureQuestion(`Qual interpretação ${ref} permite com evidência`),
      ensureQuestion(`Como ${ref} liga ${topic} ao propósito de Deus`),
    ],
  };
  const stemList = stems[diff] || stems.semente;
  return {
    type: 'choice',
    question: stemList[(n - 1) % stemList.length],
    options: options.map((o) => [o.id, o.text]),
    correct: cid,
    ok: clip(`Correto: ${correct}`, 110),
    wrong: wrongFb,
    learningObjective: learningGoal(mission, study, `Ler ${ref} com fidelidade.`),
    passageText: passage,
    skill: skillFor(diff),
  };
}

function escapeRe(s) {
  return String(s || '').replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function lexemeInPassage(passage, word) {
  const cleaned = String(word || '')
    .replace(/[^\p{L}\s]/gu, ' ')
    .replace(/\s+/g, ' ')
    .trim();
  const token =
    cleaned.split(/\s+/).find((w) => w.length >= 4) || cleaned.split(/\s+/)[0] || '';
  if (!token) return '';
  const m = String(passage || '').match(new RegExp(`\\b${escapeRe(token)}\\b`, 'i'));
  return m ? m[0] : token;
}

function uniqueLexemes(passage) {
  const out = [];
  for (const raw of contentWords(passage).filter((w) => w.length >= 4)) {
    const w = lexemeInPassage(passage, raw);
    if (!w || out.some((u) => foldKey(u) === foldKey(w))) continue;
    out.push(w);
  }
  return out;
}

function themeLexeme(passage, study, words) {
  const preferKw = cleanKeyword(study?.keyword);
  if (!preferKw) return '';
  const tryHit = (token) => {
    const v = foldKey(token);
    if (!v || v.includes(' ') || v.length < 4) return '';
    return (
      words.find((w) => foldKey(w) === v) ||
      words.find((w) => foldKey(w).startsWith(v.slice(0, 4))) ||
      ''
    );
  };
  for (const v of themeVariants(preferKw)) {
    const hit = tryHit(v);
    if (hit) return hit;
  }
  for (const tok of preferKw.split(/\s+/)) {
    const hit = tryHit(tok.replace(/[^\p{L}]/gu, ''));
    if (hit) return hit;
  }
  return '';
}

function clozeAround(passage, blank, radius = 5) {
  const re = new RegExp(`\\b${escapeRe(blank)}\\b`, 'i');
  const m = String(passage || '').match(re);
  if (!m) return '';
  const dang = /^(e|de|do|da|dos|das|o|a|os|as|um|uma|ao|à|que|por|com)$/i;
  const leftWords = passage
    .slice(0, m.index)
    .replace(/[,;:]+$/g, '')
    .trim()
    .split(/\s+/)
    .filter(Boolean)
    .slice(-radius);
  const afterRaw = passage.slice(m.index + m[0].length);
  const comma = /^\s*,/.test(afterRaw) ? ',' : '';
  const rightWords = afterRaw
    .replace(/^[,;:]+/g, '')
    .trim()
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, radius);
  while (rightWords.length && dang.test(rightWords[rightWords.length - 1].replace(/[^\p{L}]/gu, ''))) {
    rightWords.pop();
  }
  const left = leftWords.join(' ').replace(/^[,;:.…]+|[,;:.…]+$/g, '').trim();
  const right = rightWords.join(' ').replace(/^[,;:.…]+|[,;:.…]+$/g, '').trim();
  return `${left} ___${comma} ${right}`.replace(/\s+/g, ' ').trim();
}

function lexemeEchoesTheme(theme, word) {
  if (!theme || !word) return false;
  const wf = foldKey(word);
  return themeVariants(theme).some((v) => v.length >= 4 && (wf.includes(v) || v.includes(wf)));
}

/** Palavras do verso — mesmo padrão do gesto Complete (1 lexema, no texto). */
function pickPassageLexemes(passage, study, diff, used, prefix, { rotateBlank = true, mustBeUnused = false } = {}) {
  const words = uniqueLexemes(passage);
  if (words.length < 3) return null;
  const theme = themeLexeme(passage, study, words);
  const modeIndex = diff === 'semente' ? 0 : diff === 'caminhada' ? 1 : 2;
  const ranked = theme ? [theme, ...words.filter((w) => foldKey(w) !== foldKey(theme))] : words;

  let blank;
  if (!rotateBlank && theme && !used.has(`${prefix}:${foldKey(theme)}`)) {
    blank = theme;
  } else {
    blank =
      ranked.find((w, i) => i % 3 === modeIndex && !used.has(`${prefix}:${foldKey(w)}`)) ||
      ranked.find((w) => !used.has(`${prefix}:${foldKey(w)}`));
    if (!blank && !mustBeUnused) {
      blank = ranked[modeIndex] || ranked[0];
    }
  }
  blank = lexemeInPassage(passage, blank);
  if (!blank) return null;
  used.add(`${prefix}:${foldKey(blank)}`);

  const rest = words.filter(
    (w) => foldKey(w) !== foldKey(blank) && !isSubsetOption(w, blank) && !isSubsetOption(blank, w),
  );
  const topic = cleanKeyword(study?.keyword) || theme || '';
  const rankedRest = [
    ...rest.filter((w) => !lexemeEchoesTheme(topic || blank, w)),
    ...rest,
  ];
  const rotated = [...rankedRest.slice(modeIndex), ...rankedRest.slice(0, modeIndex)];
  const distractors = [];
  for (const w of rotated) {
    const lex = lexemeInPassage(passage, w);
    if (!lex) continue;
    if (distractors.some((d) => foldKey(d) === foldKey(lex) || isSubsetOption(d, lex) || isSubsetOption(lex, d))) {
      continue;
    }
    distractors.push(lex);
    if (distractors.length >= 2) break;
  }
  if (distractors.length < 2) return null;
  return { blank, distractors, topic };
}

function buildTapFields(mission, study, diff, n, used = new Set()) {
  const ref = study.passageRef || mission.hookRef || 'esta passagem';
  let passage = passageBody(study, mission);
  if (passage.length < 20) {
    passage = lookupPassage(ref) || firstClause(study.context || mission.centralInsight) || passage;
  }
  const picked = pickPassageLexemes(passage, study, diff, used, 'tap', {
    rotateBlank: true,
    mustBeUnused: true,
  });
  if (!picked) return buildChoiceFields(mission, study, diff, n, used);

  const cloze = clipKeepingBlank(clozeAround(passage, picked.blank) || '___', 92);
  const blankRe = new RegExp(`\\b${escapeRe(picked.blank)}\\b`, 'i');
  const template = blankRe.test(passage)
    ? clipKeepingBlank(passage.replace(blankRe, '___'), 200)
    : cloze;
  const ask = ensureQuestion(
    `${n > 6 ? 'Revisão: em' : 'Em'} ${ref}, toque a palavra que falta`,
  );

  return {
    type: 'tap',
    question: ask,
    prompt: ask,
    cue: ask,
    passageText: passage,
    template,
    options: [
      ['a', picked.blank],
      ['b', picked.distractors[0]],
      ['c', picked.distractors[1]],
    ],
    correct: 'a',
    ok: 'Boa. Essa palavra responde ao que foi pedido.',
    wrong: {
      b: 'Essa palavra não é a que o pedido pede. Toque a certa no texto.',
      c: 'Releia o pedido e toque a palavra no versículo.',
    },
    learningObjective: learningGoal(mission, study, `Localizar evidência em ${ref}.`),
    skill: skillFor(diff),
  };
}

function buildOrderFields(mission, study, diff, n, used = new Set()) {
  const ref = study.passageRef || mission.hookRef || 'esta passagem';
  const passage = passageBody(study, mission);
  let pieces = orderPieces(passage, study, mission)
    .map((p) => finalizeSnippet(passage, p, 72) || clipPhrase(p, 72))
    .map((p) => String(p || '').replace(/[…]+/g, ' ').replace(/\s+/g, ' ').trim())
    .filter((p) => p && !isBrokenOption(p) && !/Parte \d+/.test(p));
  const clauses = verseClauses(passage);
  if (pieces.length < 3 && clauses.length >= 3) pieces = clauses.slice(0, 3);
  const ids = ['a', 'b', 'c'];
  if (pieces.length < 3) {
    const words = passage.split(/\s+/).filter(Boolean);
    if (words.length >= 15) {
      const third = Math.floor(words.length / 3);
      pieces = [0, 1, 2].map((i) => {
        const slice = words.slice(i * third, i === 2 ? words.length : (i + 1) * third).join(' ');
        return clipPhrase(slice, 72);
      }).filter((p) => p && !isBrokenOption(p));
    }
  }
  if (pieces.length < 3) return buildChoiceFields(mission, study, diff, n, used);

  // Distinguir modos: semente = ordem literal; caminhada/pro = mesma ordem, stem de sentido
  used.add(`ord:${diff}:${pieces.map((p) => foldKey(p)).join('|')}`);
  const ask = ensureQuestion(
    n > 6
      ? diff === 'caminhada'
        ? `Revisão: como se encadeiam os eventos de ${ref}`
        : diff === 'profundezas'
          ? `Revisão: qual sequência revela o sentido de ${ref}`
          : `Revisão: qual a ordem dos fatos em ${ref}`
      : diff === 'caminhada'
        ? `Como se encadeiam os eventos de ${ref}`
        : diff === 'profundezas'
          ? `Qual sequência revela o sentido de ${ref}`
          : `Qual a ordem dos fatos em ${ref}`,
  );
  return {
    type: 'order',
    question: ask,
    prompt: ask,
    cue: ask,
    options: pieces.slice(0, 3).map((text, i) => ({ id: ids[i], text })),
    correctOrder: ids.slice(0, 3),
    ok: 'Sequência correta.',
    wrong: { default: 'Reordene as peças conforme o texto.' },
    learningObjective: `Ordenar o fluxo de ${ref}.`,
    passageText: passage || undefined,
    skill: skillFor(diff),
  };
}

function buildCompleteFields(mission, study, diff, n, used = new Set()) {
  const ref = study.passageRef || mission.hookRef || 'esta passagem';
  let passage = passageBody(study, mission);
  if (passage.length < 16) passage = lookupPassage(ref) || passage;

  const picked = pickPassageLexemes(passage, study, diff, used, 'fill', { rotateBlank: true });
  let blank = picked?.blank || 'Deus';
  const distractors = picked ? [...picked.distractors] : [];
  while (distractors.length < 2) {
    const extra = ['aliança', 'promessa', 'povo', 'terra'][distractors.length];
    if (extra && !distractors.some((d) => foldKey(d) === foldKey(extra)) && foldKey(extra) !== foldKey(blank)) {
      distractors.push(extra);
    } else break;
  }

  const re = new RegExp(`\\b${escapeRe(blank)}\\b`, 'i');
  let template = re.test(passage) ? passage.replace(re, '___') : null;
  if (!template || !template.includes('___')) {
    template = `${firstClause(passage) || `Em ${ref}, o texto destaca`} ___`;
  }
  return finishComplete(mission, study, diff, n, ref, passage, template, blank, distractors);
}

function finishComplete(mission, study, diff, n, ref, passage, template, blank, distractors = []) {
  while (distractors.length < 2) {
    distractors.push(contentWords(passage)[distractors.length] || `opção${distractors.length + 1}`);
  }
  const topic = cleanKeyword(study.keyword) || '';
  const ask = ensureQuestion(
    diff === 'caminhada'
      ? `Qual palavra completa o sentido do trecho de ${ref}${topic ? ` sobre ${topic}` : ''}`
      : diff === 'profundezas'
        ? `Qual palavra de ${ref} sustenta o tema${topic ? ` de ${topic}` : ''}`
        : `Qual palavra o texto usa em ${ref}${topic ? ` ao falar de ${topic}` : ''}`,
  );
  const clipped = clipKeepingBlank(template, 200);
  return {
    type: 'complete',
    question: ask,
    prompt: ask,
    cue: ask,
    template: clipped.includes('___') ? clipped : `${clip(passage, 120).replace(/…$/,'')} ___`,
    passageText: passage,
    options: [
      ['a', String(blank).slice(0, 40)],
      ['b', String(distractors[0]).slice(0, 40)],
      ['c', String(distractors[1]).slice(0, 40)],
    ],
    correct: 'a',
    ok: 'Lacuna preenchida com fidelidade ao texto.',
    wrong: {
      b: 'Essa palavra não completa o trecho.',
      c: 'Releia a passagem e complete a lacuna.',
    },
    learningObjective: `Completar com precisão o texto de ${ref}.`,
    skill: skillFor(diff),
  };
}

function buildConnectFields(mission, study, diff, n, used = new Set()) {
  const brief = missionBrief(mission, study);
  const ref = brief.ref;
  const passage = passageBody(study, mission);
  const clauses = verseClauses(passage);
  const aText =
    verbatimSnippet(passage, clauses[0] || firstClause(passage), 140) ||
    clipOption(firstClause(passage), 140);
  const rv = study.relatedVerses?.[0];

  if (diff === 'semente') {
    const bText =
      verbatimSnippet(passage, clauses[1] || clauses[0] || passage, 140) ||
      clipOption(clauses[1] || aText, 140);
    const phrases = passagePhrases(passage, '').filter((p) => wordCount(p) >= 2 && wordCount(p) <= 5);
    let link =
      phrases.find((p) => inPassage(p, aText) || inPassage(p, bText)) ||
      phrases[0] ||
      contentWords(passage).slice(0, 2).join(' ') ||
      brief.topic;
    if (wordCount(link) < 2) {
      link = `${link} de ${brief.topic}`.trim();
    }
    if (used.has(`con:${foldKey(link)}`)) {
      link = phrases.find((p) => !used.has(`con:${foldKey(p)}`)) || link;
    }
    used.add(`con:${foldKey(link)}`);
    const distractors = uniqueNonSubset(
      null,
      phrases.filter((p) => foldKey(p) !== foldKey(link)).concat(
        contentWords(passage).filter((w) => wordCount(w) >= 2),
      ),
      2,
      passage,
    );
    while (distractors.length < 2) {
      const extra = ['a terra prometida', 'o povo reunido', 'a palavra humana'][distractors.length];
      if (
        extra &&
        foldKey(extra) !== foldKey(link) &&
        !isSubsetOption(extra, link) &&
        !isSubsetOption(link, extra) &&
        !distractors.some((d) => foldKey(d) === foldKey(extra) || isSubsetOption(d, extra) || isSubsetOption(extra, d))
      ) {
        distractors.push(extra);
      } else break;
    }
    const ask = ensureQuestion(
      n > 6
        ? `Revisão: o que une estas partes de ${ref}`
        : `O que une estas partes de ${ref}`,
    );
    return {
      type: 'connect',
      question: ask,
      prompt: ask,
      cue: ask,
      passageA: { ref, text: aText || 'O texto apresenta a ação de Deus.' },
      passageB: { ref: `${ref} (continuação)`, text: bText || aText },
      options: [
        ['a', stripQuotes(link)],
        ['b', stripQuotes(distractors[0])],
        ['c', stripQuotes(distractors[1])],
      ],
      correct: 'a',
      ok: clip(`Sim — isso amarra o que o trecho afirma.`, 100),
      wrong: {
        b: 'Esse trecho não é o elo principal aqui.',
        c: 'Toque o que o texto realmente destaca entre as duas partes.',
      },
      learningObjective: learningGoal(mission, study, `Observar o elo em ${ref}.`),
      skill: skillFor(diff),
      passageText: passage || undefined,
    };
  }

  if (diff === 'caminhada') {
    const bText = clipOption(
      declarativeClause(mission.hookNote, study.context, mission.centralInsight) ||
        `Deus age com propósito em ${brief.topic}.`,
      140,
    );
    let correct = clipOption(
      declarativeClause(mission.hookNote, study.context, mission.centralInsight) ||
        `O texto apresenta ${brief.topic} como ação de Deus`,
      70,
    );
    if (used.has(`con:${foldKey(correct)}`)) {
      correct = clipOption(`Em ${ref}, ${brief.topic} se liga ao que Deus faz`, 70);
    }
    used.add(`con:${foldKey(correct)}`);
    const wrongs = [
      clipOption(`${brief.topic} aqui é só detalhe sem relação com o contexto`, 70),
      clipOption(`O trecho nega qualquer ação de Deus sobre ${brief.topic}`, 70),
    ];
    const ask = ensureQuestion(
      n > 6
        ? `Revisão: o que ${ref} comunica que se liga a este contexto`
        : `O que ${ref} comunica que se liga a este contexto`,
    );
    return {
      type: 'connect',
      question: ask,
      prompt: ask,
      cue: ask,
      passageA: { ref, text: aText || 'O texto apresenta a ação de Deus.' },
      passageB: { ref: 'Contexto', text: bText },
      options: [
        ['a', stripQuotes(correct)],
        ['b', stripQuotes(wrongs[0])],
        ['c', stripQuotes(wrongs[1])],
      ],
      correct: 'a',
      ok: clip(`Correto: o trecho e o contexto se encontram em ${brief.topic}.`, 100),
      wrong: {
        b: `O contexto de ${ref} não trata ${brief.topic} como detalhe vazio.`,
        c: `${ref} afirma a ação de Deus; não a nega.`,
      },
      learningObjective: learningGoal(mission, study, `Compreender ${ref} no contexto.`),
      skill: skillFor(diff),
      passageText: passage || undefined,
    };
  }

  const bText = clipOption(
    declarativeClause(
      rv?.reason,
      mission.centralInsight,
      study.keywordGloss,
      study.context,
      mission.hookNote,
    ) || 'Deus permanece fiel à sua palavra.',
    140,
  );
  let correct = clipOption(
    brief.insight ||
      declarativeClause(mission.centralInsight, study.keywordGloss) ||
      `O sentido de ${brief.topic} aponta para o propósito de Deus`,
    70,
  );
  if (used.has(`con:${foldKey(correct)}`)) {
    correct = clipOption(`${brief.topic} neste texto chama a responder a Deus`, 70);
  }
  used.add(`con:${foldKey(correct)}`);
  const wrongs = [
    clipOption(`${brief.topic} autoriza viver sem Deus`, 70),
    clipOption(`${brief.topic} neste texto não pede nenhuma resposta`, 70),
  ];
  const ask = ensureQuestion(
    rv
      ? n > 6
        ? `Revisão: qual elo de sentido une ${ref} a ${rv.reference}`
        : `Qual elo de sentido une ${ref} a ${rv.reference}`
      : n > 6
        ? `Revisão: o que une ${ref} ao chamado desta missão`
        : `O que une ${ref} ao chamado desta missão`,
  );
  return {
    type: 'connect',
    question: ask,
    prompt: ask,
    cue: ask,
    passageA: { ref, text: aText || 'O texto apresenta a ação de Deus.' },
    passageB: { ref: rv?.reference || 'Chamado', text: bText },
    options: [
      ['a', stripQuotes(correct)],
      ['b', stripQuotes(wrongs[0])],
      ['c', stripQuotes(wrongs[1])],
    ],
    correct: 'a',
    ok: clip(`Correto: o elo é o sentido de ${brief.topic} no fio da missão.`, 100),
    wrong: {
      b: `${brief.topic} no texto não ensina viver sem Deus.`,
      c: `Há implicação clara sobre ${brief.topic}.`,
    },
    learningObjective: learningGoal(mission, study, `Interpretar ${ref} no chamado da missão.`),
    skill: skillFor(diff),
    passageText: passage || undefined,
  };
}

function buildGestureFields(gesture, mission, study, diff, n, used = new Set()) {
  switch (gesture) {
    case 'true_false':
      return buildTrueFalseFields(mission, study, diff, n, used);
    case 'tap':
      return buildTapFields(mission, study, diff, n, used);
    case 'order':
      return buildOrderFields(mission, study, diff, n, used);
    case 'complete':
      return buildCompleteFields(mission, study, diff, n, used);
    case 'connect':
      return buildConnectFields(mission, study, diff, n, used);
    case 'choice':
    default:
      return buildChoiceFields(mission, study, diff, n, used);
  }
}

function slotTypeOf(q) {
  const t = String(q?.type || 'choice').toLowerCase();
  if (['true_false', 'truefalse', 'tf'].includes(t)) return 'true_false';
  if (['complete', 'fill'].includes(t)) return 'complete';
  if (t === 'order') return 'order';
  if (['tap', 'find_in_text'].includes(t)) return 'tap';
  if (['connect', 'match'].includes(t)) return 'connect';
  return 'choice';
}

/**
 * Gera banco V2 para uma missão — 1 gesto de cada no treino (6) / +2 no boss (8).
 */
export function generateMissionV2({ trail, mission, study, legacy = [] }) {
  void legacy;
  const isBoss = mission.type === 'boss';
  const counts = isBoss ? ACTS_PER_MISSION.boss : ACTS_PER_MISSION.lesson;
  const used = new Set();
  const verse = passageBody(study || {}, mission);

  const out = [];
  for (const [diff, count] of Object.entries(counts)) {
    let n = 1;
    while (n <= count) {
      const gesture = gestureForAct(n, { boss: isBoss });
      const tpl = buildGestureFields(gesture, mission, study || {}, diff, n, used);
      const q = makeV2Question({
        trail,
        section: mission.slug,
        diff,
        n,
        fields: {
          ...tpl,
          verseRef: study?.passageRef || mission.hookRef || '',
          evidence: [study?.passageRef || mission.hookRef].filter(Boolean),
          passageText: tpl.passageText || verse || study?.passageText || mission.hookVerse,
        },
      });
      out.push(q);
      n += 1;
    }
  }
  return dedupeCrossModeGestures(out);
}

/** Observação e Compreensão não podem ter o mesmo gabarito em complete/connect.
 *  Toque fica de fora: a palavra-tema precisa permanecer o gabarito do enunciado. */
export function dedupeCrossModeGestures(questions) {
  const kinds = new Set(['complete', 'connect']);
  const groups = new Map();
  for (const q of questions) {
    const t = String(q.type || '').toLowerCase();
    if (!kinds.has(t)) continue;
    const key = `${q.trail || ''}|${q.section}|${t}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(q);
  }
  for (const qs of groups.values()) {
    const sementeTexts = new Set();
    for (const q of qs.filter((x) => x.difficulty === 'semente')) {
      const opts = q.options || [];
      const cid = String(q.correctOptionId || q.correctAnswer || opts[0]?.id || '');
      const text = foldKey((opts.find((o) => String(o.id) === cid) || opts[0])?.text || '');
      if (text.length >= 4) sementeTexts.add(text);
    }
    for (const q of qs.filter((x) => x.difficulty === 'caminhada')) {
      const opts = q.options || [];
      const cid = String(q.correctOptionId || q.correctAnswer || opts[0]?.id || '');
      const textOf = (id) =>
        foldKey((opts.find((o) => String(o.id) === String(id)) || {})?.text || '');
      if (!sementeTexts.has(textOf(cid))) continue;
      const alt = opts.find((o) => {
        const t = textOf(o.id);
        return String(o.id) !== cid && t.length >= 4 && !sementeTexts.has(t);
      });
      if (alt) {
        q.correctOptionId = alt.id;
        if (q.correctAnswer && !String(q.correctAnswer).includes(',')) {
          q.correctAnswer = alt.id;
        }
      }
    }
  }
  return questions;
}

/**
 * Preserva handcraft por TIPO de gesto (não por índice).
 * Assim choice editorial entra no slot choice, mesmo se o gerador
 * colocou choice em n=3 e o handcraft estava em n=1.
 */
export function mergeMissionQuestions(handcrafted, generated) {
  const pools = new Map();
  for (const q of handcrafted) {
    const key = `${q.section}|${q.difficulty}|${slotTypeOf(q)}`;
    if (!pools.has(key)) pools.set(key, []);
    pools.get(key).push(q);
  }
  return generated.map((q) => {
    const key = `${q.section}|${q.difficulty}|${slotTypeOf(q)}`;
    const queue = pools.get(key);
    const hc = queue?.length ? queue.shift() : null;
    if (!hc) return q;
    // V/F editorial fraco (interrogativo) → mantém o gerado.
    if (slotTypeOf(q) === 'true_false') {
      const stem = (hc.prompt || hc.question || hc.cue || '').trim();
      if (
        !stem ||
        /^(o que|qual|quem|como|onde|quando|por que)\b/i.test(stem) ||
        stem.includes('?')
      ) {
        return q;
      }
    }
    return {
      ...hc,
      id: q.id,
      trail: q.trail,
      section: q.section,
      difficulty: q.difficulty,
      type: q.type,
      skill: skillFor(q.difficulty),
    };
  });
}
