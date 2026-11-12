/**
 * Editor de pergunta (banco V3).
 *
 * Mostra todos os campos que o app usa — enunciado, palco, opções, feedback
 * por opção errada, dica, trecho da prova (`evidenceSpan`) — e confere a
 * pergunta com as regras de `npm run v3:validate`, contra a JFAAL.
 *
 * Grava com merge: campos que o editor não conhece ficam como estão.
 */
import { COL, getDocById, listCollection, listWhere, saveDoc } from './db.js';
import { validateQuestion } from './bank-validator.js';
import {
  DIFFS,
  GESTURES,
  V3_GESTURES,
  gestureMeta,
  renderActPreview,
  renderFeedbackPreview,
} from './content-preview.js';
import { V3_SHORT, V3_SKILL } from '../scripts/_v3_rules.mjs';
import { checkScene, isV3Question, isV3Scene } from './v3-check.js';
import { jfaal, loadJfaal } from './jfaal-browser.js';
import {
  confirmAction,
  escapeHtml,
  hideModalElement,
  setLoading,
  showModalElement,
  showToast,
} from './ui.js';

export { GESTURES, DIFFS, gestureMeta };

const SKILL_BY_TYPE = {
  choice: 'understand',
  true_false: 'observe',
  complete: 'observe',
  order: 'understand',
  tap: 'observe',
  find_in_text: 'observe',
  connect: 'connect',
};

const VF_OPTIONS = [
  { id: 'true', text: 'Verdadeiro' },
  { id: 'false', text: 'Falso' },
];

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
          title: ms.title || ms.slug || 'Cena',
          label: `${t.title || trail} · ${ms.title || ms.slug || 'Cena'}`,
          hookRef: ms.hookRef || '',
          hookVerse: ms.hookVerse || '',
          boss: ms.type === 'boss',
        });
      }
    }
  }
  return out;
}

export function questionsForPasso(bank, { trail, section }) {
  if (!section) return [];
  return (bank || []).filter((q) => {
    if (q.section !== section) return false;
    if (trail && q.trail && q.trail !== trail && q.trailSlug !== trail) return false;
    return true;
  });
}

/**
 * Próximo id livre. Com trilha e modo, segue o formato V3
 * (`<trilha>-<sem|cam|pro>-<cena>-<nn>`); sem eles, o formato antigo.
 */
export function nextQuestionId(section, type, items, { trail = '', difficulty = '' } = {}) {
  const used = new Set((items || []).map((x) => x.id));
  const short = V3_SHORT[difficulty];
  if (trail && short && section) {
    const prefix = `${trail}-${short}-${section}-`;
    let n = 1;
    while (used.has(`${prefix}${String(n).padStart(2, '0')}`)) n += 1;
    return `${prefix}${String(n).padStart(2, '0')}`;
  }
  const slug = String(section || 'q')
    .replace(/[^a-z0-9-]+/gi, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 40) || 'q';
  const kind = String(type || 'choice').replace(/_/g, '');
  let n = 1;
  let id = `${slug}-${kind}-${String(n).padStart(2, '0')}`;
  while (used.has(id)) {
    n += 1;
    id = `${slug}-${kind}-${String(n).padStart(2, '0')}`;
  }
  return id;
}

function defaultOptions(type) {
  if (type === 'true_false') return VF_OPTIONS.map((o) => ({ ...o }));
  const n = type === 'choice' ? 4 : 3;
  return 'abcd'.slice(0, n).split('').map((id) => ({ id, text: '' }));
}

export function emptyBankQuestion(partial = {}) {
  const type = partial.type || 'choice';
  const diff = partial.difficulty || 'semente';
  const vf = type === 'true_false';
  return {
    id: '',
    trail: '',
    section: '',
    difficulty: diff,
    type,
    skill: V3_SKILL[diff] || SKILL_BY_TYPE[type] || 'observe',
    question: '',
    prompt: '',
    cue: '',
    verseRef: '',
    passageText: '',
    options: defaultOptions(type),
    correctOptionId: vf ? 'true' : 'a',
    correctAnswer: vf ? 'true' : 'a',
    feedbackCorrect: '',
    feedbackWrong: {},
    hint: '',
    evidenceSpan: '',
    evidence: [],
    learningObjective: '',
    ...(type === 'complete' ? { template: '' } : {}),
    ...(type === 'connect' ? { passageA: { ref: '', text: '' }, passageB: { ref: '', text: '' } } : {}),
    ...(type === 'order' ? { correctOrder: ['a', 'b', 'c'] } : {}),
    ...partial,
  };
}

/* ─── Campos ─────────────────────────────────────────────── */

function field(label, control, { hint, count } = {}) {
  const counter = count ? `<span class="qe-count" data-count-for="${count.f}">${count.len}/${count.max}</span>` : '';
  return `<label class="ez-field">
    <span class="ez-label">${label}${counter}</span>
    ${control}
    ${hint ? `<span class="ez-hint">${hint}</span>` : ''}
  </label>`;
}

/** Campo com botão ao lado do controle; a dica fica embaixo da linha inteira. */
function fieldAction(label, control, action, { hint, count } = {}) {
  const counter = count ? `<span class="qe-count" data-count-for="${count.f}">${count.len}/${count.max}</span>` : '';
  return `<div class="ez-field">
    <span class="ez-label">${label}${counter}</span>
    <div class="qe-input-row">${control}${action}</div>
    ${hint ? `<span class="ez-hint">${hint}</span>` : ''}
  </div>`;
}

function block(title, inner, extra = '') {
  return `<section class="qs-block ${extra}">
    ${title ? `<p class="qs-block-title">${title}</p>` : ''}
    ${inner}
  </section>`;
}

const PV_TABS = [['act', 'Na hora'], ['ok', 'Acerto'], ['wrong', 'Erro']];

const LIMITS = { hint: 90, feedbackCorrect: 110, feedbackWrong: 120, question: 140 };

function counted(f, value, max) {
  return { f, len: String(value || '').trim().length, max };
}

function stemOf(q) {
  return String(q.question || q.prompt || q.cue || '').trim();
}

const OPT_IDS = 'abcdefghij'.split('');
function nextOptId(options) {
  const used = new Set((options || []).map((o) => o.id));
  return OPT_IDS.find((id) => !used.has(id)) || `o${(options || []).length + 1}`;
}

function wrongIdsOf(q) {
  if (q.type === 'order') return [];
  if (q.type === 'true_false') return [q.correctOptionId === 'true' ? 'false' : 'true'];
  return (q.options || []).map((o) => o.id).filter((id) => id !== q.correctOptionId);
}

function optionRows(q) {
  const isOrder = q.type === 'order';
  const opts = q.options || [];
  const rows = opts.map((o, i) => {
    const letter = String.fromCharCode(65 + i);
    const correct = !isOrder && q.correctOptionId === o.id;
    return `
      <div class="qe-opt ${correct ? 'correct' : ''}">
        <div class="qe-opt-main">
          ${isOrder
            ? `<span class="opt-letter">${i + 1}</span>`
            : `<input type="radio" name="qe-correct" value="${escapeHtml(o.id)}" ${correct ? 'checked' : ''} data-f="correct" title="Marcar como certa" />
               <span class="opt-letter">${letter}</span>`}
          <input type="text" data-f="opt-${escapeHtml(o.id)}" value="${escapeHtml(o.text || '')}" placeholder="${isOrder ? `Peça ${i + 1} (na ordem certa)` : `Opção ${letter}`}" />
          ${isOrder && i > 0 ? `<button type="button" class="opt-move" data-move-up="${escapeHtml(o.id)}" aria-label="Subir">↑</button>` : ''}
          ${opts.length > 2 ? `<button type="button" class="opt-remove" data-remove-opt="${escapeHtml(o.id)}" aria-label="Remover ${letter}">×</button>` : ''}
        </div>
      </div>`;
  }).join('');
  const add = opts.length < 6 ? `<button type="button" class="opt-add" data-add-opt>+ Opção</button>` : '';
  return `<div class="qe-opts">${rows}${add}</div>`;
}

/** Feedbacks de erro — vão no bloco Dicas, depois das opções. */
function wrongFeedbackFields(q) {
  const fw = q.feedbackWrong || {};
  if (q.type === 'true_false') {
    const wrong = q.correctOptionId === 'true' ? 'false' : 'true';
    const label = wrong === 'true' ? 'Verdadeiro' : 'Falso';
    return field(
      `Feedback se responder ${label}`,
      `<input data-f="fw-${wrong}" data-pv-wrong="${wrong}" value="${escapeHtml(fw[wrong] || '')}" />`,
      { count: counted(`fw-${wrong}`, fw[wrong], LIMITS.feedbackWrong) },
    );
  }
  if (q.type === 'order') {
    return field(
      'Feedback de erro',
      `<input data-f="fw-default" data-pv-wrong="default" value="${escapeHtml(fw.default || '')}" placeholder="O que olhar para acertar a ordem" />`,
      { count: counted('fw-default', fw.default, LIMITS.feedbackWrong) },
    );
  }
  const wrongs = wrongIdsOf(q);
  if (!wrongs.length) return '';
  const opts = q.options || [];
  return wrongs.map((id) => {
    const i = opts.findIndex((o) => o.id === id);
    const letter = i >= 0 ? String.fromCharCode(65 + i) : id;
    return field(
      `Feedback se escolher ${letter}`,
      `<input class="qe-wrong" data-f="fw-${escapeHtml(id)}" data-pv-wrong="${escapeHtml(id)}" value="${escapeHtml(fw[id] || '')}" placeholder="Por que ${letter} está errada" />`,
      { count: counted(`fw-${id}`, fw[id], LIMITS.feedbackWrong) },
    );
  }).join('');
}

function stageFields(q) {
  return `
    ${fieldAction(
      'Referência do palco',
      `<input data-f="verseRef" value="${escapeHtml(q.verseRef || '')}" placeholder="Gênesis 1:1–2" />`,
      `<button type="button" class="btn btn-secondary btn-sm" data-jfaal="stage">Puxar da JFAAL</button>`,
      { hint: 'Um capítulo, faixa contínua, até 2 versos.' },
    )}
    ${field('Texto do palco (JFAAL)', `<textarea data-f="passageText" rows="3" placeholder="Texto exato da JFAAL">${escapeHtml(q.passageText || '')}</textarea>`)}
    ${fieldAction(
      'Trecho da prova (evidenceSpan)',
      `<input data-f="evidenceSpan" value="${escapeHtml(q.evidenceSpan || '')}" placeholder="Trecho exato do palco que prova a resposta" />`,
      `<button type="button" class="btn btn-ghost btn-sm" data-use-selection>Usar seleção</button>`,
      { hint: 'O app acende este trecho depois da resposta. Selecione no texto acima e toque em “Usar seleção”.' },
    )}`;
}

function stemFieldFor(q) {
  const stem = stemOf(q);
  const byType = {
    true_false: ['Afirmação', 'Afirmação completa, sem “?” e sem dois-pontos.'],
    order: ['Instrução', 'Monte Gênesis 1:2 na ordem do texto.'],
    find_in_text: ['Pergunta', 'Em Gênesis 1:1, toque quem criou os céus e a terra.'],
    complete: ['Pergunta', 'Em Gênesis 1:2, o que havia sobre a face do abismo?'],
    connect: ['Pergunta', 'O que liga Gênesis 1:1 a Hebreus 11:3?'],
  };
  const [label, ph] = byType[q.type] || ['Pergunta', 'Pergunta que o aluno lê no topo'];
  return field(
    label,
    `<textarea data-f="stem" rows="2" placeholder="${escapeHtml(ph)}">${escapeHtml(stem)}</textarea>`,
    { count: counted('stem', stem, LIMITS.question) },
  );
}

/** Extras de palco por gesto (depois do palco padrão). */
function typeStageExtras(q) {
  if (q.type === 'complete') {
    return fieldAction(
      'Palco com lacuna (template)',
      `<textarea data-f="template" rows="3" placeholder="O palco com uma palavra trocada por ___">${escapeHtml(q.template || '')}</textarea>`,
      `<button type="button" class="btn btn-ghost btn-sm" data-make-blank>Montar do palco</button>`,
      { hint: 'Exatamente uma lacuna ___. Palco + resposta certa = texto do palco.' },
    );
  }
  if (q.type === 'connect') {
    const a = q.passageA || {};
    const b = q.passageB || {};
    return `<div class="qs-two">
      <div>
        ${fieldAction('Trecho A · ref.', `<input data-f="pa-ref" value="${escapeHtml(a.ref || '')}" />`, `<button type="button" class="btn btn-ghost btn-sm" data-jfaal="pa">JFAAL</button>`)}
        ${field('Trecho A · texto', `<textarea data-f="pa-text" rows="2">${escapeHtml(a.text || '')}</textarea>`)}
      </div>
      <div>
        ${fieldAction('Trecho B · ref.', `<input data-f="pb-ref" value="${escapeHtml(b.ref || '')}" placeholder="Contexto (Observação) ou ref. real" />`, `<button type="button" class="btn btn-ghost btn-sm" data-jfaal="pb">JFAAL</button>`)}
        ${field('Trecho B · texto', `<textarea data-f="pb-text" rows="2">${escapeHtml(b.text || '')}</textarea>`)}
      </div>
    </div>`;
  }
  return '';
}

function optionFields(q) {
  if (q.type === 'true_false') {
    const isTrue = q.correctOptionId === 'true';
    return `
      <p class="ez-label">Resposta certa</p>
      <div class="qs-vf">
        <button type="button" class="qs-vf-btn ${isTrue ? 'on' : ''}" data-vf="true" aria-pressed="${isTrue}"><strong>V</strong> Verdadeiro</button>
        <button type="button" class="qs-vf-btn ${!isTrue ? 'on' : ''}" data-vf="false" aria-pressed="${!isTrue}"><strong>F</strong> Falso</button>
      </div>`;
  }
  if (q.type === 'complete') {
    return `<p class="ez-label">Palavras (a bolinha marca a certa)</p>${optionRows(q)}`;
  }
  if (q.type === 'connect') {
    return `<p class="ez-label">Pontes (1 a 6 palavras; a bolinha marca a certa)</p>${optionRows(q)}`;
  }
  if (q.type === 'order') {
    return `<p class="ez-label">Peças, já na ordem certa — o app embaralha</p>${optionRows(q)}`;
  }
  if (q.type === 'find_in_text') {
    return `<p class="ez-label">Trechos tocáveis (1 a 3 palavras, iguais ao palco)</p>${optionRows(q)}`;
  }
  return `<p class="ez-label">Alternativas (a bolinha marca a certa)</p>${optionRows(q)}`;
}

function tipFields(q) {
  return `
    ${field('Dica (onde olhar, sem dar a resposta)', `<input data-f="hint" value="${escapeHtml(q.hint || '')}" />`, { count: counted('hint', q.hint, LIMITS.hint) })}
    ${field('Feedback de acerto (por quê)', `<input data-f="feedbackCorrect" data-pv-ok value="${escapeHtml(q.feedbackCorrect || '')}" placeholder="Sem “Certo:”/“Correto:”" />`, { count: counted('feedbackCorrect', q.feedbackCorrect, LIMITS.feedbackCorrect) })}
    ${wrongFeedbackFields(q)}
    ${field('Objetivo (1 frase, só no painel)', `<input data-f="learningObjective" value="${escapeHtml(q.learningObjective || '')}" />`)}`;
}

/* ─── Leitura e gravação ─────────────────────────────────── */

function readDraft(root, draft) {
  const el = (name) => root.querySelector(`[data-f="${name}"]`);
  const val = (name, fallback = '') => (el(name) ? el(name).value : fallback);
  const stem = val('stem', stemOf(draft));
  draft.question = stem;
  draft.prompt = stem;
  draft.cue = stem;
  draft.verseRef = val('verseRef', draft.verseRef);
  draft.passageText = val('passageText', draft.passageText);
  draft.evidenceSpan = val('evidenceSpan', draft.evidenceSpan);
  draft.hint = val('hint', draft.hint);
  draft.feedbackCorrect = val('feedbackCorrect', draft.feedbackCorrect);
  draft.learningObjective = val('learningObjective', draft.learningObjective);
  if (el('evidence')) {
    draft.evidence = val('evidence').split(/\n|;/).map((s) => s.trim()).filter(Boolean);
  }
  if (el('note')) draft.note = val('note');
  if (draft.type === 'complete') draft.template = val('template', draft.template);
  if (draft.type === 'connect') {
    draft.passageA = { ...(draft.passageA || {}), ref: val('pa-ref'), text: val('pa-text') };
    draft.passageB = { ...(draft.passageB || {}), ref: val('pb-ref'), text: val('pb-text') };
  }

  const fw = { ...(draft.feedbackWrong || {}) };
  root.querySelectorAll('[data-f^="fw-"]').forEach((input) => {
    fw[input.dataset.f.slice(3)] = input.value;
  });
  draft.feedbackWrong = fw;

  if (draft.type === 'true_false') {
    draft.options = VF_OPTIONS.map((o) => ({ ...o }));
  } else {
    const byId = new Map((draft.options || []).map((o) => [o.id, o]));
    root.querySelectorAll('[data-f^="opt-"]').forEach((input) => {
      const id = input.dataset.f.slice(4);
      const o = byId.get(id);
      if (o) o.text = input.value;
    });
    const checked = root.querySelector('[data-f="correct"]:checked')?.value;
    if (checked) draft.correctOptionId = checked;
  }
  return draft;
}

const META_KEYS = ['id', 'updatedAt', 'panelEditedAt', 'panelEditedBy'];

/** Documento a gravar + campos a apagar (que não valem para o gesto). */
function payloadFrom(draft, { v3, isNew, items }) {
  const type = draft.type;
  const p = { ...draft };
  for (const k of META_KEYS) delete p[k];
  const stem = stemOf(draft);
  p.question = stem;
  p.prompt = stem;
  p.cue = stem;
  if (v3) p.skill = V3_SKILL[p.difficulty] || p.skill;
  else p.skill = p.skill || V3_SKILL[p.difficulty] || SKILL_BY_TYPE[type] || 'observe';

  if (type === 'true_false') {
    p.options = VF_OPTIONS.map((o) => ({ ...o }));
  } else {
    p.options = (draft.options || [])
      .map((o) => ({ ...o, text: String(o.text || '').trim() }))
      .filter((o) => o.text);
  }
  if (type === 'order') {
    p.correctOrder = p.options.map((o) => o.id);
    p.correctAnswer = p.correctOrder.join(',');
    p.correctOptionId = p.correctOrder[0];
  } else {
    p.correctAnswer = p.correctOptionId;
  }

  // Feedback de erro: só as chaves das opções erradas (e `default` no Ordenar).
  const fw = {};
  const keys = type === 'order' ? ['default'] : wrongIdsOf(p);
  for (const k of keys) {
    const t = String(draft.feedbackWrong?.[k] || '').trim();
    if (t) fw[k] = t;
  }
  p.feedbackWrong = fw;

  for (const k of ['hint', 'evidenceSpan', 'learningObjective', 'feedbackCorrect', 'verseRef', 'passageText']) {
    p[k] = String(p[k] || '').trim();
  }
  p.evidence = (p.evidence || []).filter((e) => String(e).trim());

  const remove = [];
  const drop = (k) => {
    delete p[k];
    if (!isNew) remove.push(k);
  };
  if (type !== 'complete') drop('template');
  if (type !== 'connect') {
    drop('passageA');
    drop('passageB');
  }
  if (type !== 'order') drop('correctOrder');
  for (const k of ['hint', 'evidenceSpan', 'learningObjective', 'note']) {
    if (p[k] === '' || p[k] === undefined) drop(k);
  }
  if (!p.evidence.length) drop('evidence');
  if (isNew && !v3) p.order = (items?.length || 0) + 1;
  return { payload: p, remove };
}

function hardErrors(p) {
  if (!p.trail) return 'Escolha a trilha';
  if (!p.section) return 'Escolha a cena';
  if (!stemOf(p)) return p.type === 'true_false' ? 'Escreva a afirmação' : 'Escreva a pergunta';
  if (p.type !== 'true_false') {
    if (p.options.length < 2) return 'Escreva pelo menos duas opções';
    if (p.type !== 'order' && !p.options.some((o) => o.id === p.correctOptionId)) {
      return 'Marque a bolinha da resposta certa';
    }
  }
  if (p.type === 'complete' && !String(p.template || '').includes('___')) return 'O palco precisa de uma lacuna ___';
  if (p.type === 'connect' && !String(p.passageA?.text || '').trim()) return 'Preencha o trecho A';
  return '';
}

/* ─── Modal ──────────────────────────────────────────────── */

/**
 * Abre o editor. `defaults` (pergunta nova): trail, section, type, difficulty,
 * lockPlace. `context` opcional: { sceneQuestions, study, boss } já carregados.
 */
export async function openQuestionStudio({
  existing = null,
  trails = [],
  items = [],
  defaults = {},
  context = null,
  onSaved,
}) {
  const modal = document.getElementById('modal');
  if (!modal) return;
  if (!trails.length) trails = await listCollection(COL.trails);

  const passos = listPassos(trails);
  const isNew = !existing;
  // Timestamps do Firestore ficam fora do rascunho (structuredClone e comparação).
  const { updatedAt: _u, panelEditedAt: _p, ...existingData } = existing || {};
  let draft = structuredClone(
    existing
      ? emptyBankQuestion({ ...existingData })
      : emptyBankQuestion({
          trail: defaults.trail || '',
          section: defaults.section || '',
          type: defaults.type || 'true_false',
          difficulty: defaults.difficulty || 'semente',
        }),
  );
  if (existing && !existing.feedbackWrong) draft.feedbackWrong = {};
  const lockedPlace = Boolean(defaults.lockPlace) || !isNew;

  let scene = context?.sceneQuestions || null;
  let study = context?.study || null;
  let boss = context?.boss ?? passos.find((p) => p.trail === draft.trail && p.section === draft.section)?.boss;
  let v3 = existing ? isV3Question(existing) : false;
  let preview = 'act';
  let wrongId = null;
  let checkState = { status: 'idle', errors: [], warnings: [], scene: [] };
  let checkTimer = null;

  function assignNewId() {
    if (!isNew) return;
    const pool = [...(items || []), ...(scene || [])];
    draft.id = nextQuestionId(draft.section, draft.type, pool, v3 ? { trail: draft.trail, difficulty: draft.difficulty } : {});
  }

  async function loadScene() {
    if (!draft.section) return;
    try {
      if (!scene) {
        const all = await listWhere(COL.bank, 'section', draft.section);
        scene = all.filter((q) => !q.trail || q.trail === draft.trail);
      }
      if (!study) study = await getDocById(COL.studies, draft.section);
      if (isNew) v3 = isV3Scene(scene);
      else v3 = v3 || isV3Scene(scene);
      assignNewId();
    } catch (e) {
      console.warn('cena', e);
    }
  }

  function sceneWithDraft() {
    const { payload } = payloadFrom(readDraft(modal, draft), { v3, isNew, items });
    const me = { ...payload, id: draft.id };
    const list = (scene || []).filter((q) => q.id !== draft.id);
    return [...list, me];
  }

  async function runCheck() {
    if (!v3) {
      const p = payloadFrom(readDraft(modal, draft), { v3, isNew, items }).payload;
      const r = validateQuestion({ ...p, id: draft.id });
      checkState = { status: 'v2', errors: r.errors || [], warnings: r.warnings || [], scene: [] };
      paintCheck();
      return;
    }
    checkState = { ...checkState, status: 'loading' };
    paintCheck();
    try {
      const r = await checkScene({
        trail: draft.trail,
        section: draft.section,
        questions: sceneWithDraft(),
        study,
        boss,
      });
      const mine = r.byQuestion.get(draft.id) || { errors: [], warnings: [] };
      checkState = { status: 'v3', errors: mine.errors, warnings: mine.warnings, scene: r.scene.errors };
    } catch (e) {
      checkState = { status: 'error', errors: [e.message || String(e)], warnings: [], scene: [] };
    }
    paintCheck();
  }

  function scheduleCheck() {
    clearTimeout(checkTimer);
    checkTimer = setTimeout(runCheck, 350);
  }

  function paintCheck() {
    const slot = modal.querySelector('#qe-check');
    if (!slot) return;
    const s = checkState;
    if (s.status === 'loading' || s.status === 'idle') {
      slot.innerHTML = `<p class="qe-check-head">Conferindo… <small>(JFAAL na primeira vez)</small></p>`;
      return;
    }
    const title = s.status === 'v2' ? 'Checagem (banco antigo)' : s.status === 'error' ? 'Checagem indisponível' : 'Checagem V3';
    const ok = !s.errors.length && !s.warnings.length;
    slot.innerHTML = `
      <p class="qe-check-head ${ok ? 'ok' : s.errors.length ? 'bad' : 'warn'}">${escapeHtml(title)} · ${ok ? 'tudo certo' : `${s.errors.length} erro(s), ${s.warnings.length} aviso(s)`}</p>
      <ul class="qe-check-list">
        ${s.errors.map((m) => `<li class="bad">✗ ${escapeHtml(m)}</li>`).join('')}
        ${s.warnings.map((m) => `<li class="warn">! ${escapeHtml(m)}</li>`).join('')}
      </ul>
      ${s.scene?.length ? `<details class="qe-scene-issues"><summary>Cena: ${s.scene.length} problema(s) de conjunto</summary><ul class="qe-check-list">${s.scene.map((m) => `<li class="bad">${escapeHtml(m)}</li>`).join('')}</ul></details>` : ''}`;
  }

  function paintPreview() {
    const slot = modal.querySelector('#qs-preview');
    if (!slot) return;
    readDraft(modal, draft);
    const wrongs = wrongIdsOf(draft);
    if (!wrongId || (!wrongs.includes(wrongId) && wrongId !== 'default')) {
      wrongId = draft.type === 'order' ? 'default' : wrongs[0] || null;
    }
    if (preview === 'act') slot.innerHTML = renderActPreview(draft, {});
    else slot.innerHTML = renderFeedbackPreview(draft, { correct: preview === 'ok', wrongId });
    const chips = modal.querySelector('#qe-wrong-chips');
    if (chips) {
      chips.hidden = preview !== 'wrong' || draft.type === 'order';
      chips.innerHTML = wrongs.map((id) => {
        const label = draft.type === 'true_false' ? (id === 'true' ? 'V' : 'F') : id.toUpperCase();
        return `<button type="button" class="${id === wrongId ? 'on' : ''}" data-wrong-chip="${escapeHtml(id)}">${escapeHtml(label)}</button>`;
      }).join('');
    }
  }

  function paintCounts() {
    modal.querySelectorAll('[data-count-for]').forEach((c) => {
      const input = modal.querySelector(`[data-f="${c.dataset.countFor}"]`);
      const max = Number(c.textContent.split('/')[1]) || 0;
      const len = String(input?.value || '').trim().length;
      c.textContent = `${len}/${max}`;
      c.classList.toggle('over', len > max);
    });
  }

  function sourceFile() {
    const dir = draft.trail === 'genesis-1-11' ? 'admin/pilot/genesis-1-11' : `admin/v3/${draft.trail}`;
    return `${dir}/cenas/${draft.section}.json`;
  }

  /** Linha curta no rodapé: onde a edição vale e de onde a pergunta vem. */
  function footNote() {
    if (!v3) return 'Banco antigo (V2): as regras V3 não valem aqui.';
    if (!draft.section) return 'Grava direto no app.';
    return `Grava direto no app · fonte local <code title="${escapeHtml(sourceFile())}">cenas/${escapeHtml(draft.section)}.json</code> (sincronize em Avançado)`;
  }

  /** Passo a passo da fonte local, dentro de Avançado. */
  function sourceSteps() {
    if (!v3 || !draft.section) return '';
    return `<div class="qe-note v3">
      <strong>Fonte local:</strong> <code>${escapeHtml(sourceFile())}</code>.
      A edição fica marcada; antes do próximo publish rode
      <code>npm run v3:pull -- --trail ${escapeHtml(draft.trail)} --apply</code>.
      EN/ES vêm do app e não mudam: depois rode <code>v3:translate</code>.
    </div>`;
  }

  function modeLabel() {
    return DIFFS.find((d) => d.id === draft.difficulty)?.label || draft.difficulty || '';
  }

  /** Cena, modo e id no cabeçalho (o gesto já é o título). */
  function headMeta() {
    const p = passos.find((x) => x.trail === draft.trail && x.section === draft.section);
    const place = lockedPlace ? `<span class="qe-head-place">📍 ${escapeHtml(p?.label || `${draft.trail} · ${draft.section}`)}</span>` : '';
    const mode = isNew ? '' : `<span class="badge badge-muted">${escapeHtml(modeLabel())}</span>`;
    return `<div class="qe-head-meta">${place}${mode}<code class="qe-head-id">${escapeHtml(draft.id || '—')}</code></div>`;
  }

  /** Cena (só pergunta nova sem lugar travado). */
  function placeHtml() {
    if (!isNew || lockedPlace) return '';
    return block('Cena', field('Cena', `<select data-f="place">
      <option value="">Escolha trilha e cena…</option>
      ${passos.map((p) => {
        const val = `${p.trail}::${p.section}`;
        const sel = draft.trail === p.trail && draft.section === p.section;
        return `<option value="${escapeHtml(val)}" ${sel ? 'selected' : ''}>${escapeHtml(p.label)}</option>`;
      }).join('')}
    </select>`));
  }

  /** Gesto (+ modo na pergunta nova) — mesma ordem do card. */
  function gestureHtml() {
    const list = GESTURES.filter((g) => !g.legacy).sort((a, b) => V3_GESTURES.indexOf(a.id) - V3_GESTURES.indexOf(b.id));
    const mode = isNew ? `
      <p class="ez-label">Modo</p>
      <div class="diff-row compact">
        ${DIFFS.map((d) => `<button type="button" class="diff-chip sm ${draft.difficulty === d.id ? 'on' : ''}" data-diff="${d.id}">${escapeHtml(d.label)}</button>`).join('')}
      </div>` : '';
    return block('Gesto', `
      <div class="gesture-row compact">
        ${list.map((g) => `<button type="button" class="gesture-chip ${draft.type === g.id ? 'on' : ''}" data-type="${g.id}" title="${escapeHtml(g.blurb)}"><span class="gesture-icon">${escapeHtml(g.icon)}</span><strong>${escapeHtml(g.label)}</strong></button>`).join('')}
      </div>
      ${mode}`);
  }

  function paint() {
    const g = gestureMeta(draft.type);
    modal.innerHTML = `
      <div class="modal-backdrop qs-backdrop">
        <div class="modal-card card qs-modal qe-modal" role="dialog" aria-modal="true" aria-labelledby="qe-title">
          <header class="qs-head">
            <div class="qe-head-text">
              <p class="simple-kicker">${isNew ? 'Nova pergunta' : 'Editar pergunta'}</p>
              <h2 id="qe-title">${escapeHtml(g.label)}</h2>
              ${headMeta()}
            </div>
            <button type="button" class="modal-close" aria-label="Fechar">×</button>
          </header>
          <div class="qs-layout">
            <div class="qs-form">
              ${placeHtml()}
              ${gestureHtml()}
              ${block('Pergunta', stemFieldFor(draft))}
              ${block('Palco', `${stageFields(draft)}${typeStageExtras(draft)}`)}
              ${block('Opções', optionFields(draft))}
              ${block('Dicas', tipFields(draft))}
              <details class="qs-advanced">
                <summary>Avançado</summary>
                <div class="qs-advanced-body">
                  ${sourceSteps()}
                  ${field('Evidência (referências, uma por linha)', `<textarea data-f="evidence" rows="2">${escapeHtml((draft.evidence || []).join('\n'))}</textarea>`)}
                  ${draft.note !== undefined && !v3 ? field('Nota de contexto (V2)', `<textarea data-f="note" rows="2">${escapeHtml(draft.note || '')}</textarea>`) : ''}
                  <p class="ez-hint">skill: <code>${escapeHtml(v3 ? V3_SKILL[draft.difficulty] || '' : draft.skill || '')}</code>${draft.panelEditedBy ? ` · última edição no painel: ${escapeHtml(draft.panelEditedBy)}` : ''}</p>
                </div>
              </details>
            </div>
            <aside class="qs-aside">
              <div class="qe-check" id="qe-check" aria-live="polite"></div>
              <div class="pv-tabs" role="tablist">
                ${PV_TABS.map(([id, label]) => `<button type="button" role="tab" class="${preview === id ? 'on' : ''}" aria-selected="${preview === id}" data-pv="${id}">${label}</button>`).join('')}
              </div>
              <div class="qe-wrong-chips" id="qe-wrong-chips" hidden></div>
              <div id="qs-preview"></div>
            </aside>
          </div>
          <footer class="qe-foot">
            <p class="qe-foot-note">${footNote()}</p>
            <div class="btn-row">
              <button type="button" class="btn btn-secondary" id="cancel">Cancelar</button>
              <button type="button" class="btn btn-primary" id="qs-save">Salvar</button>
            </div>
          </footer>
        </div>
      </div>`;
    showModalElement(modal);
    bind();
    paintPreview();
    paintCounts();
    paintCheck();
  }

  function close() {
    clearTimeout(checkTimer);
    hideModalElement(modal);
    if (modal._qsEsc) document.removeEventListener('keydown', modal._qsEsc);
    modal._qsEsc = null;
  }

  async function fillFromJfaal(kind) {
    readDraft(modal, draft);
    try {
      await loadJfaal();
    } catch (e) {
      showToast(e.message || 'JFAAL indisponível', 'error');
      return;
    }
    const ref = kind === 'pa' ? draft.passageA?.ref : kind === 'pb' ? draft.passageB?.ref : draft.verseRef;
    const text = jfaal.passageText(ref);
    if (!text) {
      showToast(`Referência inválida: “${ref || ''}” (um capítulo, faixa contínua)`, 'error');
      return;
    }
    if (kind === 'pa') draft.passageA = { ...draft.passageA, text };
    else if (kind === 'pb') draft.passageB = { ...draft.passageB, text };
    else draft.passageText = text;
    paint();
    scheduleCheck();
  }

  /** Lê o formulário, aplica a mudança, repinta e agenda a checagem. */
  function commit(change) {
    readDraft(modal, draft);
    if (change() === false) return;
    paint();
    scheduleCheck();
  }

  /** Troca a aba do preview sem repintar o formulário. */
  function setPreview(tab) {
    if (preview !== tab) {
      preview = tab;
      modal.querySelectorAll('[data-pv]').forEach((b) => {
        const on = b.dataset.pv === tab;
        b.classList.toggle('on', on);
        b.setAttribute('aria-selected', String(on));
      });
    }
    paintPreview();
  }

  const on = (selector, event, handler) => {
    modal.querySelectorAll(selector).forEach((el) => el.addEventListener(event, (e) => handler(el, e)));
  };

  function bind() {
    if (modal._qsEsc) document.removeEventListener('keydown', modal._qsEsc);
    modal._qsEsc = (e) => {
      if (e.key === 'Escape') close();
    };
    document.addEventListener('keydown', modal._qsEsc);
    on('.modal-close, #cancel', 'click', close);
    on('.modal-backdrop', 'click', (el, e) => {
      if (e.target === el) close();
    });

    on('[data-f="place"]', 'change', async (el) => {
      readDraft(modal, draft);
      const [trail, section] = String(el.value).split('::');
      draft.trail = trail || '';
      draft.section = section || '';
      boss = passos.find((p) => p.trail === draft.trail && p.section === draft.section)?.boss;
      scene = null;
      study = null;
      await loadScene();
      commit(() => assignNewId());
    });

    on('[data-type]', 'click', (btn) => commit(() => {
      if (btn.dataset.type === draft.type) return false;
      const keep = {
        trail: draft.trail,
        section: draft.section,
        difficulty: draft.difficulty,
        verseRef: draft.verseRef,
        passageText: draft.passageText,
        question: draft.question,
        hint: draft.hint,
        learningObjective: draft.learningObjective,
        evidenceSpan: draft.evidenceSpan,
        evidence: draft.evidence,
      };
      draft = emptyBankQuestion({ ...keep, type: btn.dataset.type });
      assignNewId();
    }));

    on('[data-diff]', 'click', (btn) => commit(() => {
      draft.difficulty = btn.dataset.diff;
      draft.skill = V3_SKILL[draft.difficulty] || draft.skill;
      assignNewId();
    }));

    // V/F: o feedback de erro acompanha a troca da resposta certa.
    on('[data-vf]', 'click', (btn) => commit(() => {
      const next = btn.dataset.vf;
      if (next === draft.correctOptionId) return false;
      const fbText = draft.feedbackWrong?.[next];
      draft.correctOptionId = next;
      draft.correctAnswer = next;
      const nextWrong = next === 'true' ? 'false' : 'true';
      if (fbText && !draft.feedbackWrong[nextWrong]) draft.feedbackWrong = { [nextWrong]: fbText };
    }));

    on('[data-f="correct"]', 'change', () => commit(() => {}));

    on('[data-add-opt]', 'click', (btn, e) => {
      e.preventDefault();
      const id = nextOptId(draft.options);
      commit(() => {
        draft.options = [...(draft.options || []), { id, text: '' }];
      });
      modal.querySelector(`[data-f="opt-${id}"]`)?.focus();
    });

    on('[data-remove-opt]', 'click', (btn, e) => {
      e.preventDefault();
      commit(() => {
        const id = btn.dataset.removeOpt;
        draft.options = draft.options.filter((o) => o.id !== id);
        delete draft.feedbackWrong[id];
        if (draft.correctOptionId === id) draft.correctOptionId = draft.options[0]?.id;
      });
    });

    on('[data-move-up]', 'click', (btn, e) => {
      e.preventDefault();
      commit(() => {
        const i = draft.options.findIndex((o) => o.id === btn.dataset.moveUp);
        if (i <= 0) return false;
        const opts = [...draft.options];
        [opts[i - 1], opts[i]] = [opts[i], opts[i - 1]];
        draft.options = opts;
      });
    });

    on('[data-jfaal]', 'click', (btn) => fillFromJfaal(btn.dataset.jfaal));

    on('[data-use-selection]', 'click', () => {
      const ta = modal.querySelector('[data-f="passageText"]');
      const sel = ta ? ta.value.slice(ta.selectionStart, ta.selectionEnd).trim() : '';
      if (!sel) {
        showToast('Selecione o trecho no texto do palco', 'error');
        return;
      }
      commit(() => {
        draft.evidenceSpan = sel;
        preview = 'ok';
      });
    });

    on('[data-make-blank]', 'click', () => {
      readDraft(modal, draft);
      const answer = String(draft.options.find((o) => o.id === draft.correctOptionId)?.text || '').trim();
      const text = String(draft.passageText || '');
      if (!answer || !text) {
        showToast('Preencha o palco e marque a palavra certa', 'error');
        return;
      }
      const re = new RegExp(`(^|[^\\p{L}])${answer.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}(?=$|[^\\p{L}])`, 'u');
      if (!re.test(text)) {
        showToast(`“${answer}” não aparece no palco`, 'error');
        return;
      }
      commit(() => {
        draft.template = text.replace(re, (m, pre) => `${pre}___`);
      });
    });

    on('[data-pv]', 'click', (btn) => setPreview(btn.dataset.pv));

    modal.querySelector('#qe-wrong-chips')?.addEventListener('click', (e) => {
      const chip = e.target.closest('[data-wrong-chip]');
      if (!chip) return;
      wrongId = chip.dataset.wrongChip;
      paintPreview();
    });

    // Digitar num campo de feedback leva o preview para a tela daquele feedback.
    on('[data-f]:not([data-f="place"]):not([data-f="correct"])', 'input', (el) => {
      readDraft(modal, draft);
      if (el.dataset.pvWrong) {
        wrongId = el.dataset.pvWrong;
        setPreview('wrong');
      } else if (el.hasAttribute('data-pv-ok')) {
        setPreview('ok');
      } else {
        paintPreview();
      }
      paintCounts();
      scheduleCheck();
    });

    on('#qs-save', 'click', save);
  }

  async function save() {
    readDraft(modal, draft);
    const { payload, remove } = payloadFrom(draft, { v3, isNew, items });
    const err = hardErrors(payload);
    if (err) {
      showToast(err, 'error');
      return;
    }
    clearTimeout(checkTimer);
    await runCheck();
    if (checkState.errors.length) {
      const ok = await confirmAction(
        `${checkState.errors.length} problema(s) na checagem ${v3 ? 'V3' : ''}. Salvar mesmo assim?`,
        { confirmLabel: 'Salvar assim', danger: false },
      );
      if (!ok) return;
    }
    if (isNew && (items || []).some((x) => x.id === draft.id)) {
      showToast(`Já existe uma pergunta ${draft.id}`, 'error');
      return;
    }
    setLoading(true);
    try {
      await saveDoc(COL.bank, draft.id, payload, { remove });
      showToast(isNew ? 'Pergunta criada — já vale no app' : 'Pergunta salva — já vale no app');
      close();
      onSaved?.({ ...payload, id: draft.id, panelEditedAt: new Date() });
    } catch (e) {
      showToast(e.message || 'Erro', 'error');
    } finally {
      setLoading(false);
    }
  }

  setLoading(true);
  try {
    await loadScene();
    if (isNew) assignNewId();
  } finally {
    setLoading(false);
  }
  paint();
  runCheck();
}

/** Funções puras, expostas para teste. */
export const __test = { payloadFrom, readDraft, hardErrors, wrongIdsOf };
