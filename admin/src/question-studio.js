import { COL, listCollection, saveDoc } from './db.js';
import { validateQuestion } from './bank-validator.js';
import { GESTURES, DIFFS, gestureMeta, renderActPreview, renderFeedbackPreview } from './content-preview.js';
import {
  escapeHtml,
  hideModalElement,
  setLoading,
  showModalElement,
  showToast,
} from './ui.js';

export { GESTURES, DIFFS, gestureMeta };

/** Tipos mais usados — aparecem primeiro no cadastro. */
const PRIMARY_GESTURES = ['choice', 'true_false', 'complete'];
const MORE_GESTURES = GESTURES.filter((g) => !PRIMARY_GESTURES.includes(g.id));

const SKILL_BY_TYPE = {
  choice: 'understand',
  true_false: 'observe',
  complete: 'observe',
  order: 'understand',
  tap: 'observe',
  connect: 'connect',
};

export function listPassos(trails) {
  const out = [];
  for (const t of trails || []) {
    const trail = t.slug || t.id;
    for (const mod of t.modules || []) {
      for (const ms of mod.missions || []) {
        out.push({
          trail,
          trailTitle: t.title || trail,
          section: ms.slug || '',
          title: ms.title || ms.slug || 'Passo',
          label: `${t.title || trail} · ${ms.title || ms.slug || 'Passo'}`,
          hookRef: ms.hookRef || '',
          hookVerse: ms.hookVerse || '',
        });
      }
    }
  }
  return out;
}

export function questionsForPasso(bank, { trail, section }) {
  if (!section) return [];
  return (bank || []).filter((q) => {
    if (q.section === section) return true;
    if (trail && (q.trail === trail || q.trailSlug === trail) && q.section === section) {
      return true;
    }
    return false;
  });
}

export function nextQuestionId(section, type, items) {
  const slug = String(section || 'q')
    .replace(/[^a-z0-9-]+/gi, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 40) || 'q';
  const kind = String(type || 'choice').replace(/_/g, '');
  const used = new Set((items || []).map((x) => x.id));
  let n = 1;
  let id = `${slug}-${kind}-${String(n).padStart(2, '0')}`;
  while (used.has(id)) {
    n += 1;
    id = `${slug}-${kind}-${String(n).padStart(2, '0')}`;
  }
  return id;
}

const SKILL_BY_DIFF = {
  semente: 'observe',
  caminhada: 'understand',
  profundezas: 'interpret',
};

export function emptyBankQuestion(partial = {}) {
  const type = partial.type || 'choice';
  const vf = type === 'true_false';
  const diff = partial.difficulty || 'semente';
  return {
    id: partial.id || '',
    trail: partial.trail || '',
    difficulty: diff,
    section: partial.section || '',
    type,
    skill: partial.skill || SKILL_BY_DIFF[diff] || SKILL_BY_TYPE[type] || 'observe',
    question: '',
    prompt: '',
    cue: '',
    passageText: '',
    template: '',
    correctAnswer: vf ? 'false' : 'a',
    options: vf
      ? [
          { id: 'true', text: 'Verdadeiro' },
          { id: 'false', text: 'Falso' },
        ]
      : [
          { id: 'a', text: '' },
          { id: 'b', text: '' },
          { id: 'c', text: '' },
        ],
    correctOptionId: vf ? 'false' : 'a',
    feedbackCorrect: '',
    feedbackWrong: {},
    verseRef: '',
    reveal: '',
    learningObjective: '',
    evidence: [],
    passageA: { ref: '', text: '' },
    passageB: { ref: '', text: '' },
    correctOrder: ['a', 'b', 'c'],
    note: '',
    ...partial,
  };
}

function field(label, control, { hint } = {}) {
  return `<label class="ez-field">
    <span class="ez-label">${label}</span>
    ${control}
    ${hint ? `<span class="ez-hint">${hint}</span>` : ''}
  </label>`;
}

function qsBlock(title, inner, extra = '') {
  return `<section class="qs-block ${extra}">
    <p class="qs-block-title">${title}</p>
    ${inner}
  </section>`;
}

function currentStepOf(trails, trailId, section) {
  for (const trail of trails || []) {
    const trailSlug = trail.slug || trail.id;
    if (trailId && trailSlug !== trailId && trail.id !== trailId) continue;
    for (const mod of trail.modules || []) {
      for (const ms of mod.missions || []) {
        if ((ms.slug || '') === section) return { trail, step: ms };
      }
    }
  }
  return null;
}

function cleanVerseText(text) {
  return String(text || '').replace(/\s+/g, ' ').trim();
}

const COPILOT_INTENTS = [
  { id: 'observacao', label: 'Observação', hint: 'O que o texto diz' },
  { id: 'interpretacao', label: 'Interpretação', hint: 'O que significa' },
  { id: 'aplicacao', label: 'Aplicação', hint: 'O que muda na vida' },
];

function defaultIntentForDifficulty(diff) {
  if (diff === 'profundezas') return 'aplicacao';
  if (diff === 'caminhada') return 'interpretacao';
  return 'observacao';
}

function chooseKeyword(text) {
  const words = cleanVerseText(text)
    .replace(/[.,;:!?()[\]"]/g, '')
    .split(' ')
    .map((w) => w.trim())
    .filter(Boolean);
  const skip = new Set(['de', 'da', 'do', 'das', 'dos', 'e', 'o', 'a', 'os', 'as', 'um', 'uma', 'que', 'em', 'no', 'na', 'nos', 'nas', 'para', 'por', 'com', 'ao', 'aos']);
  return words.find((w) => w.length >= 5 && !skip.has(w.toLowerCase())) || words.find((w) => w.length >= 3) || '';
}

function buildQuestionStem(type, diff, ref, intent = 'observacao') {
  const r = ref || 'o verso';
  const stems = {
    observacao: {
      choice: { semente: `O que ${r} diz?`, caminhada: `Qual detalhe aparece em ${r}?`, profundezas: `Qual palavra ou expressão aparece literalmente em ${r}?` },
      tap: { semente: `Toque na resposta que aparece em ${r}.`, caminhada: `Qual opção aparece em ${r}?`, profundezas: `Qual palavra-chave aparece em ${r}?` },
      complete: { semente: 'Complete a lacuna.', caminhada: `Complete a parte que falta em ${r}.`, profundezas: `Complete a palavra que falta em ${r}.` },
    },
    interpretacao: {
      choice: { semente: `O que ${r} quer dizer?`, caminhada: `Qual ideia central emerge de ${r}?`, profundezas: `Como interpretar corretamente ${r}?` },
      tap: { semente: `Qual leitura resume ${r}?`, caminhada: `Qual ideia central está em ${r}?`, profundezas: `Qual interpretação bate com ${r}?` },
      complete: { semente: 'Complete a ideia central.', caminhada: `Complete o sentido de ${r}.`, profundezas: `Complete a interpretação de ${r}.` },
    },
    aplicacao: {
      choice: { semente: `O que ${r} nos convida a pensar?`, caminhada: `Como ${r} se aplica hoje?`, profundezas: `Qual implicação prática de ${r}?` },
      tap: { semente: `Toque na aplicação que combina com ${r}.`, caminhada: `Qual resposta prática decorre de ${r}?`, profundezas: `Qual consequência prática de ${r}?` },
      complete: { semente: 'Complete a aplicação.', caminhada: `Complete a resposta prática de ${r}.`, profundezas: `Complete a implicação de ${r}.` },
    },
  };

  if (type === 'true_false') {
    const vf = {
      observacao: `Esta afirmação bate com ${r}?`,
      interpretacao: `Segundo ${r}, esta interpretação é correta?`,
      aplicacao: `Esta aplicação de ${r} faz sentido?`,
    };
    return vf[intent] || vf.observacao;
  }

  const group = stems[intent] || stems.observacao;
  const typeStems = group[type] || group.choice;
  return typeStems[diff] || typeStems.semente;
}

function buildChoiceOptions(text, intent = 'observacao') {
  const keyword = chooseKeyword(text);
  const exact = cleanVerseText(text);
  const short = exact.slice(0, 48) + (exact.length > 48 ? '…' : '');

  if (intent === 'interpretacao') {
    return [
      { id: 'a', text: keyword ? `A ideia de "${keyword}" no contexto` : 'Interpretação correta (edite)' },
      { id: 'b', text: keyword ? `Só a palavra "${keyword}", sem contexto` : 'Leitura literal demais' },
      { id: 'c', text: 'Sentido oposto ao texto' },
    ];
  }
  if (intent === 'aplicacao') {
    return [
      { id: 'a', text: keyword ? `Viver o que ${keyword} aponta hoje` : 'Aplicação prática (edite)' },
      { id: 'b', text: 'Apenas memorizar o verso' },
      { id: 'c', text: 'Ignorar o texto no dia a dia' },
    ];
  }
  return [
    { id: 'a', text: keyword || 'Resposta literal (edite)' },
    { id: 'b', text: keyword ? `${keyword} em outro livro` : 'Detalhe fora do texto' },
    { id: 'c', text: short ? 'Algo que o verso não diz' : 'Distrator (edite)' },
  ];
}

function buildCompleteTemplate(text, intent = 'observacao') {
  const keyword = chooseKeyword(text);
  if (!keyword) {
    return { template: '___', options: [{ id: 'a', text: '' }, { id: 'b', text: '' }, { id: 'c', text: '' }], correct: 'a' };
  }
  const template = cleanVerseText(text).replace(keyword, '___');
  if (intent === 'interpretacao') {
    return {
      template,
      options: [
        { id: 'a', text: keyword },
        { id: 'b', text: 'só leitura literal' },
        { id: 'c', text: 'sentido oposto' },
      ],
      correct: 'a',
    };
  }
  if (intent === 'aplicacao') {
    return {
      template: `Por isso, hoje devemos ___. (${cleanVerseText(text).slice(0, 40)}…)` ,
      options: [
        { id: 'a', text: 'obedecer ao texto' },
        { id: 'b', text: 'ignorar o verso' },
        { id: 'c', text: keyword },
      ],
      correct: 'a',
    };
  }
  return {
    template,
    options: [
      { id: 'a', text: keyword },
      { id: 'b', text: `${keyword}s` },
      { id: 'c', text: 'outra palavra' },
    ],
    correct: 'a',
  };
}

function buildTrueFalseStatement(text, ref, intent = 'observacao') {
  const keyword = chooseKeyword(text);
  const r = ref || 'o verso';
  if (!keyword) {
    return intent === 'aplicacao'
      ? `Podemos aplicar ${r} na vida de hoje.`
      : intent === 'interpretacao'
        ? `${r} aponta para uma ideia central clara.`
        : `Segundo ${r}, a afirmação abaixo é correta.`;
  }
  if (intent === 'interpretacao') {
    return `Em ${r}, "${keyword}" aponta para a ideia central do trecho.`;
  }
  if (intent === 'aplicacao') {
    return `${r} nos convida a responder na prática ao que o texto mostra.`;
  }
  return `Em ${r}, a palavra "${keyword}" aparece no texto.`;
}

function applyCopilotDraft(draft, source, intent) {
  const step = source?.step;
  const ref = step?.hookRef || '';
  const text = cleanVerseText(step?.hookVerse || '');
  if (!step || (!ref && !text)) return false;

  if (draft.type === 'true_false') {
    draft.question = buildTrueFalseStatement(text, ref, intent);
    draft.prompt = draft.question;
    draft.cue = draft.question;
  } else {
    const stem = buildQuestionStem(draft.type, draft.difficulty, ref, intent);
    draft.question = stem;
    draft.prompt = stem;
    draft.cue = stem;
  }
  if (!draft.verseRef) draft.verseRef = ref;
  if ((draft.type === 'tap' || draft.type === 'choice') && !draft.passageText) draft.passageText = text;

  if (draft.type === 'complete') {
    const built = buildCompleteTemplate(text, intent);
    draft.template = built.template;
    draft.options = built.options;
    draft.correctOptionId = built.correct;
    draft.correctAnswer = built.correct;
  } else if (draft.type !== 'true_false' && draft.type !== 'order' && draft.type !== 'connect') {
    draft.options = buildChoiceOptions(text, intent);
    draft.correctOptionId = 'a';
    draft.correctAnswer = 'a';
  }
  return true;
}

function verseSourceBlock(source, draft) {
  const ref = (source?.step?.hookRef || draft.verseRef || '').trim();
  const text = cleanVerseText(source?.step?.hookVerse || draft.passageText || '');
  if (!ref && !text) return '';
  return qsBlock(
    'Verso do passo',
    `<div class="qs-verse-source">
      ${ref ? `<p class="qs-verse-ref">${escapeHtml(ref)}</p>` : ''}
      ${text
        ? `<blockquote class="qs-verse-text">${escapeHtml(text)}</blockquote>
           <p class="ez-hint">Selecione trechos para montar a pergunta manualmente abaixo.</p>
           <button type="button" class="btn btn-ghost btn-sm" data-copy-verse>Copiar texto</button>`
        : `<p class="ez-hint">Só a referência — volte ao passo e cole o trecho bíblico.</p>`}
    </div>`,
    'verse-source',
  );
}

function copilotBlock(source, draft, intent) {
  const hasSource = Boolean(source?.step?.hookRef || source?.step?.hookVerse);
  if (!hasSource) {
    return qsBlock(
      'Ajuda rápida',
      `<p class="qs-copilot-note">Este passo ainda não tem verso. Volte ao passo e preencha a referência — ou escreva a pergunta manualmente abaixo.</p>`,
      'copilot muted',
    );
  }
  return qsBlock(
    'Gerar do verso',
    `<div class="qs-copilot">
      <p class="ez-label">Intenção da pergunta</p>
      <div class="qs-intent-row">
        ${COPILOT_INTENTS.map((it) => `
          <button type="button" class="qs-intent-chip ${intent === it.id ? 'on' : ''}" data-intent="${it.id}">
            <strong>${escapeHtml(it.label)}</strong>
            <small>${escapeHtml(it.hint)}</small>
          </button>`).join('')}
      </div>
      <p class="ez-hint">Escolha o foco — depois gere o rascunho com um clique.</p>
      <button type="button" class="btn btn-primary qs-magic-btn" data-copilot="full">
        ✨ Gerar pergunta completa
      </button>
    </div>`,
    'copilot',
  );
}

function wizardStepsHtml(current, { lockedPlace }) {
  const steps = lockedPlace
    ? [{ id: 1, label: 'Tipo' }, { id: 2, label: 'Texto' }]
    : [{ id: 1, label: 'Onde e tipo' }, { id: 2, label: 'Texto' }];
  return `<nav class="qs-wizard" aria-label="Passos do cadastro">
    ${steps.map((s, i) => `
      <span class="qs-wizard-step ${current >= s.id ? 'done' : ''} ${current === s.id ? 'active' : ''}">
        <em>${i + 1}</em> ${escapeHtml(s.label)}
      </span>`).join('<span class="qs-wizard-line"></span>')}
  </nav>`;
}

function gesturePicker(draft, { compact = false } = {}) {
  const chip = (g) => `
    <button type="button" class="gesture-chip ${draft.type === g.id ? 'on' : ''}" data-type="${g.id}" title="${escapeHtml(g.blurb)}">
      <span class="gesture-icon">${escapeHtml(g.icon || '•')}</span>
      <strong>${escapeHtml(g.label)}</strong>
      <small>${escapeHtml(g.verb)}</small>
    </button>`;
  const primary = GESTURES.filter((g) => PRIMARY_GESTURES.includes(g.id));
  if (compact) {
    return `<div class="gesture-row compact">${primary.map(chip).join('')}</div>`;
  }
  return `
    <p class="ez-label">Tipo de pergunta</p>
    <div class="gesture-row">${primary.map(chip).join('')}</div>
    <details class="qs-more-types">
      <summary>Mais tipos (arraste, toque, conecte…)</summary>
      <div class="gesture-row">${MORE_GESTURES.map(chip).join('')}</div>
    </details>`;
}

const OPT_IDS = 'abcdefghijklmnopqrstuvwxyz'.split('');

function nextOptId(options) {
  const used = new Set((options || []).map((o) => o.id));
  return OPT_IDS.find((id) => !used.has(id)) || `o${(options || []).length + 1}`;
}

function ensureMinOptions(q, min = 2) {
  const opts = [...(q.options || [])].filter((o) => o && o.id);
  while (opts.length < min) {
    opts.push({ id: nextOptId(opts), text: '' });
  }
  q.options = opts;
  return opts;
}

function optInputs(q, { placeholder = 'Opção', min = 2, max = 8, addLabel = '+ Alternativa' } = {}) {
  const opts = ensureMinOptions(q, min);
  const canRemove = opts.length > min;
  const rows = opts
    .map((opt, i) => {
      const letter = String.fromCharCode(65 + i);
      const correct = (q.correctOptionId || q.correctAnswer) === opt.id;
      return `
        <label class="simple-opt ${correct ? 'correct' : ''}">
          <input type="radio" name="qs-correct" value="${escapeHtml(opt.id)}" ${correct ? 'checked' : ''} data-f="correct" title="Marcar como certa" />
          <span class="opt-letter">${letter}</span>
          <input type="text" data-f="opt-${escapeHtml(opt.id)}" data-preview="opt-${escapeHtml(opt.id)}" value="${escapeHtml(opt.text || '')}" placeholder="${placeholder} ${letter}" />
          ${correct ? '<em class="opt-certa">Certa</em>' : '<em class="opt-certa off">Certa</em>'}
          ${canRemove ? `<button type="button" class="opt-remove" data-remove-opt="${escapeHtml(opt.id)}" aria-label="Remover ${letter}">×</button>` : ''}
        </label>`;
    })
    .join('');
  const add = opts.length < max
    ? `<button type="button" class="opt-add" data-add-opt>${escapeHtml(addLabel)}</button>`
    : `<p class="ez-hint">Máximo de ${max} opções nesta tela.</p>`;
  return `${rows}${add}`;
}

function afterAnswerFields(q, { verse = false } = {}) {
  const verseHtml = verse
    ? `${field(
        'Referência do verso',
        `<input data-f="verseRef" data-preview="verseRef" data-screen="feedback" value="${escapeHtml(q.verseRef || '')}" placeholder="Mateus 1:1" />`,
        { hint: 'Só no cartão depois da resposta.' },
      )}
      ${field(
        'Trecho',
        `<textarea data-f="passageText" data-preview="verseRef" data-screen="feedback" rows="2" placeholder="Cole o trecho curto…">${escapeHtml(q.passageText || '')}</textarea>`,
      )}`
    : '';
  return `
    <details class="qs-advanced">
      <summary>Depois de responder (opcional)</summary>
      <div class="qs-advanced-body">
        ${verseHtml}
        ${field(
          'Frase de acerto',
          `<input data-f="feedbackCorrect" data-preview="feedbackCorrect" data-screen="feedback" value="${escapeHtml(q.feedbackCorrect || '')}" placeholder="Correto!" />`,
        )}
      </div>
    </details>`;
}

function typeFields(q) {
  const type = q.type || 'choice';
  const stem = (q.cue || q.prompt || q.question || '').trim();

  if (type === 'true_false') {
    const ans = String(q.correctAnswer || q.correctOptionId || 'false');
    const isTrue = ans === 'true' || ans === 'verdadeiro';
    return `
      ${field(
        'Afirmação',
        `<textarea data-f="stem" data-preview="cue" rows="3" placeholder="Mateus descreve Jesus como filho de Davi.">${escapeHtml(stem)}</textarea>`,
      )}
      <p class="ez-label">Resposta certa</p>
      <div class="qs-vf" data-preview="answer">
        <button type="button" class="qs-vf-btn ${isTrue ? 'on' : ''}" data-vf="true">V · Verdadeiro</button>
        <button type="button" class="qs-vf-btn ${!isTrue ? 'on' : ''}" data-vf="false">F · Falso</button>
      </div>`;
  }

  if (type === 'complete') {
    return `
      ${field(
        'Pergunta (opcional)',
        `<input data-f="stem" data-preview="cue" value="${escapeHtml(stem)}" placeholder="Que título mostra que Deus veio habitar?" />`,
      )}
      ${field(
        'Verso com lacuna',
        `<textarea data-f="template" data-preview="template" rows="3" placeholder="…e o chamarão de ___, que quer dizer Deus conosco.">${escapeHtml(q.template || '')}</textarea>`,
        { hint: 'Use ___ no lugar da palavra que falta.' },
      )}
      ${field(
        'Referência',
        `<input data-f="verseRef" data-preview="verseRef" value="${escapeHtml(q.verseRef || '')}" placeholder="Mateus 1:23" />`,
      )}
      <p class="ez-label">Palavras para preencher</p>
      <div class="simple-opts">${optInputs(q, { placeholder: 'Palavra', addLabel: '+ Palavra' })}</div>
      <p class="ez-hint">A bolinha marca a palavra que entra no ___.</p>`;
  }

  if (type === 'order') {
    return `
      ${field(
        'Instrução',
        `<input data-f="stem" data-preview="cue" value="${escapeHtml(stem)}" placeholder="Monte a sequência do trecho." />`,
      )}
      <p class="ez-label">Trechos na ordem certa</p>
      <p class="ez-hint">Escreva já na sequência correta. O app embaralha na hora.</p>
      <div class="simple-opts">${optInputs(q, { placeholder: 'Trecho', addLabel: '+ Trecho', min: 2, max: 8 })}</div>`;
  }

  if (type === 'tap') {
    return `
      ${field(
        'Pergunta',
        `<textarea data-f="stem" data-preview="cue" rows="2" placeholder="Qual era a missão anunciada pelo anjo?">${escapeHtml(stem)}</textarea>`,
      )}
      ${field(
        'Referência',
        `<input data-f="verseRef" data-preview="verseRef" value="${escapeHtml(q.verseRef || '')}" placeholder="Mateus 1:21" />`,
      )}
      ${field(
        'Texto do verso',
        `<textarea data-f="passageText" data-preview="passageText" rows="3" placeholder="Cole o trecho. A resposta certa deve aparecer nele.">${escapeHtml(q.passageText || '')}</textarea>`,
      )}
      <p class="ez-label">Opções</p>
      <div class="simple-opts">${optInputs(q, { placeholder: 'Leitura', addLabel: '+ Opção' })}</div>`;
  }

  if (type === 'connect') {
    const a = q.passageA || {};
    const b = q.passageB || {};
    return `
      ${field(
        'Pergunta',
        `<input data-f="stem" data-preview="cue" value="${escapeHtml(stem)}" placeholder="Qual palavra une os textos?" />`,
      )}
      <div class="qs-two">
        ${field(
          'Trecho A · referência',
          `<input data-f="pa-ref" data-preview="passageA" value="${escapeHtml(a.ref || '')}" placeholder="Lucas 18:1" />`,
        )}
        ${field(
          'Trecho B · referência',
          `<input data-f="pb-ref" data-preview="passageB" value="${escapeHtml(b.ref || '')}" placeholder="Lucas 18:2" />`,
        )}
      </div>
      ${field(
        'Texto A',
        `<textarea data-f="pa-text" data-preview="passageA" rows="2">${escapeHtml(a.text || '')}</textarea>`,
      )}
      ${field(
        'Texto B',
        `<textarea data-f="pb-text" data-preview="passageB" rows="2">${escapeHtml(b.text || '')}</textarea>`,
      )}
      <p class="ez-label">Palavras / opções</p>
      <div class="simple-opts">${optInputs(q, { placeholder: 'Palavra', addLabel: '+ Palavra' })}</div>`;
  }

  // choice
  return `
    ${field(
      'Pergunta',
      `<textarea data-f="stem" data-preview="cue" rows="2" placeholder="De qual rei Jesus é chamado filho?">${escapeHtml(stem)}</textarea>`,
    )}
    <p class="ez-label">Alternativas</p>
    <div class="simple-opts">${optInputs(q, { placeholder: 'Alternativa', addLabel: '+ Alternativa' })}</div>
    <p class="ez-hint">Toque na bolinha da resposta certa. Use + para mais opções.</p>`;
}

function readDraft(root, draft) {
  const val = (name) => root.querySelector(`[data-f="${name}"]`)?.value ?? '';
  const type = draft.type;
  const stem = val('stem');
  draft.question = stem;
  draft.prompt = type === 'complete' && !stem ? 'Complete a lacuna.' : stem;
  draft.cue = stem;
  draft.verseRef = val('verseRef');
  draft.passageText = val('passageText');
  draft.template = val('template');
  draft.feedbackCorrect = val('feedbackCorrect');
  draft.note = val('note');
  draft.difficulty = root.querySelector('[data-diff].on')?.dataset.diff || draft.difficulty;
  draft.trail = val('trail') || draft.trail;
  draft.section = val('section') || draft.section;

  if (type === 'connect') {
    draft.passageA = { ref: val('pa-ref'), text: val('pa-text') };
    draft.passageB = { ref: val('pb-ref'), text: val('pb-text') };
  }

  if (type === 'true_false') {
    const ans = root.querySelector('[data-vf].on')?.dataset.vf || draft.correctAnswer || 'false';
    draft.correctAnswer = ans;
    draft.correctOptionId = ans;
    draft.options = [
      { id: 'true', text: 'Verdadeiro' },
      { id: 'false', text: 'Falso' },
    ];
    return draft;
  }

  const optionEls = [...root.querySelectorAll('[data-f^="opt-"]')];
  const options = optionEls.map((el) => ({
    id: String(el.dataset.f || '').replace(/^opt-/, ''),
    text: el.value,
  })).filter((o) => o.id);
  draft.options = type === 'order'
    ? options.filter((o) => o.text.trim())
    : options;
  const correct = root.querySelector('[data-f="correct"]:checked')?.value
    || draft.correctOptionId
    || options[0]?.id
    || 'a';
  draft.correctOptionId = correct;
  draft.correctAnswer = type === 'order'
    ? draft.options.map((o) => o.id).join(',')
    : correct;
  if (type === 'order') {
    draft.correctOrder = draft.options.map((o) => o.id);
  }
  return draft;
}

function payloadFrom(draft, existing, items) {
  const type = draft.type;
  const feedbackWrong = {};
  if (type !== 'true_false') {
    for (const o of (draft.options || []).filter((x) => String(x.text || '').trim())) {
      if (o.id !== draft.correctOptionId) {
        feedbackWrong[o.id] = 'Resposta incorreta. Revise o texto.';
      }
    }
  } else {
    const other = draft.correctAnswer === 'true' ? 'false' : 'true';
    feedbackWrong[other] = 'Resposta incorreta. Revise o texto.';
  }

  return {
    id: draft.id,
    trail: draft.trail,
    difficulty: draft.difficulty || 'semente',
    section: draft.section,
    type,
    skill: draft.skill || SKILL_BY_DIFF[draft.difficulty] || SKILL_BY_TYPE[type] || existing?.skill || 'observe',
    learningObjective: (draft.learningObjective || '').trim() || undefined,
    evidence: (draft.evidence || []).filter((e) => String(e).trim()),
    question: draft.question,
    prompt: draft.prompt,
    cue: draft.cue,
    options: (draft.options || []).filter((o) => String(o.text || '').trim()),
    correctOptionId: draft.correctOptionId,
    correctAnswer: draft.correctAnswer,
    feedbackCorrect: draft.feedbackCorrect || 'Correto!',
    feedbackWrong,
    verseRef: draft.verseRef || '',
    passageText: draft.passageText || undefined,
    template: type === 'complete' ? draft.template : existing?.template,
    reveal: draft.reveal || existing?.reveal || null,
    order: existing?.order ?? (items?.length || 0) + 1,
    passageA: type === 'connect' ? draft.passageA : existing?.passageA,
    passageB: type === 'connect' ? draft.passageB : existing?.passageB,
    correctOrder: type === 'order' ? draft.correctOrder : existing?.correctOrder,
    note: draft.note || existing?.note,
    beat: existing?.beat,
  };
}

function validate(draft) {
  if (!draft.trail) return 'Escolha a trilha';
  if (!draft.section) return 'Escolha o passo';
  const stem = (draft.cue || draft.prompt || draft.question || '').trim();
  if (draft.type === 'true_false' && !stem) return 'Escreva a afirmação';
  if (draft.type === 'complete' && !(draft.template || '').includes('___')) {
    return 'O verso precisa de uma lacuna ___';
  }
  if (draft.type === 'tap' && !(draft.passageText || '').trim()) return 'Cole o texto do verso';
  if (draft.type === 'connect' && !(draft.passageA?.text || '').trim()) return 'Preencha os dois trechos';
  if (draft.type !== 'true_false') {
    const filled = (draft.options || []).filter((o) => String(o.text || '').trim());
    if (filled.length < 2) return 'Escreva pelo menos duas opções';
    const correct = draft.correctOptionId || draft.correctAnswer;
    if (!filled.some((o) => o.id === correct)) return 'Marque a bolinha da resposta certa';
  }
  if ((draft.type === 'choice' || draft.type === 'tap' || draft.type === 'complete') && !stem && draft.type !== 'complete') {
    return 'Escreva a pergunta';
  }
  const v2 = validateQuestion(draft);
  if (v2.errors.length) return v2.errors[0];
  return '';
}

/**
 * Editor em modal: só os campos daquele gesto + miniatura da tela do app.
 */
export async function openQuestionStudio({
  existing = null,
  trails = [],
  items = [],
  defaults = {},
  onSaved,
}) {
  const modal = document.getElementById('modal');
  if (!modal) return;

  if (!trails.length) {
    trails = await listCollection(COL.trails);
  }

  const passos = listPassos(trails);
  let draft = emptyBankQuestion({
    ...(existing || {}),
    ...(!existing ? defaults : {}),
    type: defaults.type || existing?.type || 'choice',
  });
  if (!draft.id) {
    draft.id = nextQuestionId(draft.section || defaults.section, draft.type, items);
  }
  if (existing?.passageA && typeof existing.passageA === 'object') {
    draft.passageA = { ref: existing.passageA.ref || '', text: existing.passageA.text || '' };
  }
  if (existing?.passageB && typeof existing.passageB === 'object') {
    draft.passageB = { ref: existing.passageB.ref || '', text: existing.passageB.text || '' };
  }

  let previewScreen = 'act';
  let previewFocus = 'cue';
  const isNew = !existing;
  const lockedPlace = Boolean(defaults.lockPlace);
  let wizardStep = lockedPlace || existing ? 2 : 1;
  let source = currentStepOf(trails, draft.trail || defaults.trail, draft.section || defaults.section);
  let copilotIntent = defaultIntentForDifficulty(draft.difficulty || 'semente');

  function paintPreview() {
    const slot = modal.querySelector('#qs-preview');
    if (!slot) return;
    slot.innerHTML = previewScreen === 'feedback'
      ? renderFeedbackPreview(draft, { focus: previewFocus })
      : renderActPreview(draft, { focus: previewFocus });
  }

  function step1Html() {
    const placeField = lockedPlace
      ? `<p class="qs-place-locked">
          <span class="qs-place-badge">📍 ${escapeHtml(
            passos.find((p) => p.trail === draft.trail && p.section === draft.section)?.label
              || `${draft.trail} · ${draft.section}`,
          )}</span>
        </p>`
      : field(
          'Onde entra no app',
          `<select data-f="place">
            <option value="">Escolha trilha e passo…</option>
            ${passos.map((p) => {
              const val = `${p.trail}::${p.section}`;
              const sel = draft.trail === p.trail && draft.section === p.section;
              return `<option value="${escapeHtml(val)}" ${sel ? 'selected' : ''}>${escapeHtml(p.label)}</option>`;
            }).join('')}
          </select>`,
          { hint: 'A pergunta aparece na sessão deste passo.' },
        );

    return `
      ${wizardStepsHtml(1, { lockedPlace })}
      ${placeField}
      ${gesturePicker(draft)}
      <p class="ez-label">Dificuldade</p>
      <div class="diff-row">
        ${DIFFS.map((d) => `
          <button type="button" class="diff-chip ${draft.difficulty === d.id ? 'on' : ''}" data-diff="${d.id}">
            <strong>${escapeHtml(d.label)}</strong>
            <small>${escapeHtml(d.hint)}</small>
          </button>`).join('')}
      </div>`;
  }

  function step2Html() {
    const placeEdit = !lockedPlace
      ? field(
          'Onde entra',
          `<select data-f="place">
            <option value="">Escolha trilha e passo…</option>
            ${passos.map((p) => {
              const val = `${p.trail}::${p.section}`;
              const sel = draft.trail === p.trail && draft.section === p.section;
              return `<option value="${escapeHtml(val)}" ${sel ? 'selected' : ''}>${escapeHtml(p.label)}</option>`;
            }).join('')}
          </select>`,
        )
      : '';
    return `
      ${wizardStepsHtml(2, { lockedPlace })}
      ${!lockedPlace && !existing ? `<button type="button" class="btn btn-ghost btn-sm qs-back-step" data-wiz="1">← Voltar</button>` : ''}
      ${placeEdit}
      ${gesturePicker(draft, { compact: true })}
      <div class="diff-row compact">
        ${DIFFS.map((d) => `
          <button type="button" class="diff-chip sm ${draft.difficulty === d.id ? 'on' : ''}" data-diff="${d.id}">${escapeHtml(d.label)}</button>`).join('')}
      </div>
      ${verseSourceBlock(source, draft)}
      ${copilotBlock(source, draft, copilotIntent)}
      ${qsBlock('Conteúdo', typeFields(draft))}
      ${afterAnswerFields(draft, { verse: draft.type === 'choice' || draft.type === 'true_false' })}`;
  }

  function paint() {
    const g = gestureMeta(draft.type);
    const stepHtml = wizardStep === 1 ? step1Html() : step2Html();
    modal.innerHTML = `
      <div class="modal-backdrop qs-backdrop">
        <div class="modal-card card qs-modal" role="dialog" aria-modal="true">
          <header class="qs-head">
            <div>
              <p class="simple-kicker">${isNew ? 'Nova pergunta' : 'Editar pergunta'}</p>
              <h2>${escapeHtml(g.label)}</h2>
            </div>
            <button type="button" class="modal-close" aria-label="Fechar">×</button>
          </header>
          <div class="qs-layout">
            <div class="qs-form">
              ${stepHtml}
            </div>
            <aside class="qs-aside">
              <div class="pv-tabs">
                <button type="button" class="${previewScreen === 'act' ? 'on' : ''}" data-pv="act">Na hora</button>
                <button type="button" class="${previewScreen === 'feedback' ? 'on' : ''}" data-pv="feedback">Depois</button>
              </div>
              <div id="qs-preview"></div>
            </aside>
          </div>
          <div class="btn-row qs-actions">
            <button type="button" class="btn btn-secondary" id="cancel">Cancelar</button>
            ${wizardStep === 1
              ? `<button type="button" class="btn btn-primary" id="qs-next">Continuar →</button>`
              : `<button type="button" class="btn btn-primary" id="qs-save">Salvar</button>`}
          </div>
        </div>
      </div>`;

    showModalElement(modal);
    paintPreview();
    bind();
  }

  function bind() {
    const close = () => {
      hideModalElement(modal);
      if (modal._qsEsc) document.removeEventListener('keydown', modal._qsEsc);
      modal._qsEsc = null;
    };
    if (modal._qsEsc) document.removeEventListener('keydown', modal._qsEsc);
    modal._qsEsc = (e) => {
      if (e.key === 'Escape') close();
    };
    document.addEventListener('keydown', modal._qsEsc);
    modal.querySelector('.modal-close')?.addEventListener('click', close);
    modal.querySelector('#cancel')?.addEventListener('click', close);
    modal.querySelector('.modal-backdrop')?.addEventListener('click', (e) => {
      if (e.target.classList.contains('modal-backdrop')) close();
    });

    modal.querySelectorAll('[data-type]').forEach((btn) => {
      btn.addEventListener('click', () => {
        readDraft(modal, draft);
        const next = btn.dataset.type;
        if (next === draft.type) return;
        const keep = {
          trail: draft.trail,
          section: draft.section,
          difficulty: draft.difficulty,
          verseRef: draft.verseRef,
          id: isNew ? nextQuestionId(draft.section, next, items) : draft.id,
        };
        const stem = draft.question;
        draft = emptyBankQuestion({ ...keep, type: next, question: stem, prompt: stem, cue: stem });
        previewScreen = 'act';
        previewFocus = 'cue';
        paint();
      });
    });

    modal.querySelector('#qs-next')?.addEventListener('click', () => {
      readDraft(modal, draft);
      if (!draft.trail) {
        showToast('Escolha trilha e passo', 'error');
        return;
      }
      if (!draft.section) {
        showToast('Escolha o passo', 'error');
        return;
      }
      wizardStep = 2;
      source = currentStepOf(trails, draft.trail, draft.section);
      paint();
    });

    modal.querySelector('[data-wiz="1"]')?.addEventListener('click', () => {
      readDraft(modal, draft);
      wizardStep = 1;
      paint();
    });

    modal.querySelectorAll('[data-diff]').forEach((btn) => {
      btn.addEventListener('click', () => {
        draft.difficulty = btn.dataset.diff;
        copilotIntent = defaultIntentForDifficulty(draft.difficulty);
        modal.querySelectorAll('[data-diff]').forEach((b) => b.classList.toggle('on', b.dataset.diff === draft.difficulty));
        modal.querySelectorAll('[data-intent]').forEach((b) => b.classList.toggle('on', b.dataset.intent === copilotIntent));
      });
    });

    modal.querySelectorAll('[data-intent]').forEach((btn) => {
      btn.addEventListener('click', () => {
        copilotIntent = btn.dataset.intent;
        modal.querySelectorAll('[data-intent]').forEach((b) => b.classList.toggle('on', b.dataset.intent === copilotIntent));
      });
    });

    modal.querySelectorAll('[data-vf]').forEach((btn) => {
      btn.addEventListener('click', () => {
        modal.querySelectorAll('[data-vf]').forEach((b) => b.classList.remove('on'));
        btn.classList.add('on');
        readDraft(modal, draft);
        paintPreview();
      });
    });

    modal.querySelectorAll('[data-pv]').forEach((btn) => {
      btn.addEventListener('click', () => {
        previewScreen = btn.dataset.pv;
        paint();
      });
    });

    modal.querySelector('[data-f="place"]')?.addEventListener('change', (e) => {
      const [trail, section] = String(e.target.value).split('::');
      draft.trail = trail || '';
      draft.section = section || '';
      source = currentStepOf(trails, draft.trail, draft.section);
      if (isNew) draft.id = nextQuestionId(draft.section, draft.type, items);
      paint();
    });

    modal.querySelector('[data-copy-verse]')?.addEventListener('click', async () => {
      source = currentStepOf(trails, draft.trail || defaults.trail, draft.section || defaults.section);
      const text = cleanVerseText(source?.step?.hookVerse || draft.passageText || '');
      if (!text) {
        showToast('Nenhum texto para copiar', 'error');
        return;
      }
      try {
        await navigator.clipboard.writeText(text);
        showToast('Texto copiado');
      } catch {
        showToast('Selecione o texto manualmente', 'error');
      }
    });

    modal.querySelectorAll('[data-copilot]').forEach((btn) => {
      btn.addEventListener('click', () => {
        readDraft(modal, draft);
        source = currentStepOf(trails, draft.trail || defaults.trail, draft.section || defaults.section);
        if (btn.dataset.copilot === 'full') {
          if (!applyCopilotDraft(draft, source, copilotIntent)) {
            showToast('Este passo ainda não tem verso para usar', 'error');
            return;
          }
          paint();
          showToast('Pergunta gerada — revise e salve');
        }
      });
    });

    modal.querySelector('[data-add-opt]')?.addEventListener('click', (e) => {
      e.preventDefault();
      readDraft(modal, draft);
      const id = nextOptId(draft.options || []);
      draft.options = [...(draft.options || []), { id, text: '' }];
      paint();
      modal.querySelector(`[data-f="opt-${id}"]`)?.focus();
    });
    modal.querySelectorAll('[data-remove-opt]').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        readDraft(modal, draft);
        const id = btn.dataset.removeOpt;
        const next = (draft.options || []).filter((o) => o.id !== id);
        if (next.length < 2) return;
        draft.options = next;
        if (draft.correctOptionId === id || draft.correctAnswer === id) {
          draft.correctOptionId = next[0].id;
          draft.correctAnswer = next[0].id;
        }
        paint();
      });
    });

    modal.querySelectorAll('[data-f], [data-preview]').forEach((el) => {
      const bump = () => {
        readDraft(modal, draft);
        if (el.dataset.preview) previewFocus = el.dataset.preview;
        if (el.dataset.screen) previewScreen = el.dataset.screen;
        const tabs = modal.querySelectorAll('[data-pv]');
        if (el.dataset.screen && tabs.length) {
          tabs.forEach((t) => t.classList.toggle('on', t.dataset.pv === previewScreen));
        }
        const marked = modal.querySelector('[data-f="correct"]:checked')?.value;
        modal.querySelectorAll('.simple-opt').forEach((row) => {
          const radio = row.querySelector('[data-f="correct"]');
          const on = Boolean(marked && radio?.value === marked);
          row.classList.toggle('correct', on);
          row.querySelector('.opt-certa')?.classList.toggle('off', !on);
        });
        paintPreview();
      };
      el.addEventListener('input', bump);
      el.addEventListener('change', bump);
      el.addEventListener('focus', bump);
    });

    modal.querySelector('#qs-save')?.addEventListener('click', async () => {
      readDraft(modal, draft);
      const err = validate(draft);
      if (err) {
        showToast(err, 'error');
        return;
      }
      const payload = payloadFrom(draft, existing, items);
      setLoading(true);
      try {
        await saveDoc(COL.bank, payload.id, payload);
        showToast('Pergunta salva — já vale no app');
        close();
        onSaved?.(payload);
      } catch (e) {
        showToast(e.message || 'Erro', 'error');
      } finally {
        setLoading(false);
      }
    });
  }

  paint();
}
