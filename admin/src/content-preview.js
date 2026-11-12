import { escapeHtml } from './ui.js';

export const GESTURES = [
  {
    id: 'choice',
    icon: '🔘',
    verb: 'Escolha',
    verbUp: 'ESCOLHA',
    label: 'Pergunta',
    blurb: 'Pergunta e alternativas',
    where: 'Opções empilhadas embaixo da pergunta',
  },
  {
    id: 'true_false',
    icon: '✓✗',
    verb: 'Julgue',
    verbUp: 'JULGUE',
    label: 'Afirmação',
    blurb: 'Uma afirmação para julgar',
    where: 'Dois botões — V e F — no rodapé',
  },
  {
    id: 'complete',
    icon: '___',
    verb: 'Complete',
    verbUp: 'COMPLETE',
    label: 'Completar',
    blurb: 'Verso com lacuna',
    where: 'Trecho no centro; chips preenchem o ___',
  },
  {
    id: 'order',
    icon: '↕',
    verb: 'Ordene',
    verbUp: 'ORDENE',
    label: 'Sequência',
    blurb: 'Monte a sequência',
    where: 'Lista no centro, com alça para arrastar',
  },
  {
    id: 'find_in_text',
    icon: '👆',
    verb: 'Toque',
    verbUp: 'TOQUE',
    label: 'Toque',
    blurb: 'Tocar a palavra no versículo',
    where: 'Versículo no centro; o aluno toca o trecho certo',
  },
  {
    id: 'tap',
    icon: '👆',
    verb: 'Toque',
    verbUp: 'TOQUE',
    label: 'Toque (V2)',
    blurb: 'Formato antigo: verso + opções embaixo',
    where: 'Manuscrito no centro; opções embaixo',
    legacy: true,
  },
  {
    id: 'connect',
    icon: '🔗',
    verb: 'Conecte',
    verbUp: 'CONECTE',
    label: 'Ponte',
    blurb: 'Dois trechos',
    where: 'Dois blocos de texto + chips',
  },
];

export const DIFFS = [
  { id: 'semente', label: 'Observação', hint: 'Observar o que o texto diz' },
  { id: 'caminhada', label: 'Compreensão', hint: 'Compreender o que comunica' },
  { id: 'profundezas', label: 'Interpretação', hint: 'Interpretar o que significa' },
];

/** Ordem da matriz V3 (SPEC_V3 §3). */
export const V3_GESTURES = ['true_false', 'find_in_text', 'choice', 'order', 'complete', 'connect'];

export function gestureMeta(type) {
  return GESTURES.find((g) => g.id === type) || { ...GESTURES[0], id: type, label: type || 'Quiz' };
}

export function diffMeta(id) {
  return DIFFS.find((d) => d.id === id) || DIFFS[0];
}

function ph(value, fallback) {
  const t = String(value || '').trim();
  if (t) return escapeHtml(t);
  return `<span class="pv-ph">${escapeHtml(fallback)}</span>`;
}

function region(id, focus, html, extra = '') {
  return `<div class="pv-region ${focus === id ? 'pv-hot' : ''} ${extra}" data-region="${id}">${html}</div>`;
}

function phone(inner, { caption = 'Como aparece no app' } = {}) {
  return `
    <div class="pv-phone-col">
      <p class="pv-caption">${escapeHtml(caption)}</p>
      <div class="pv-phone">
        <div class="pv-notch"></div>
        <div class="pv-screen">${inner}</div>
      </div>
    </div>`;
}

function topbar(title, subtitle) {
  return `
    <div class="pv-topbar">
      <span class="pv-back">‹</span>
      <div>
        <strong>${title}</strong>
        <small>${subtitle}</small>
      </div>
    </div>`;
}

function cta(label) {
  return `<div class="pv-cta">${escapeHtml(label)}</div>`;
}

/** Cartão da trilha — lista / mapa. */
export function renderTrailCardPreview(trail, { focus = '' } = {}) {
  const title = trail?.title || '';
  const desc = trail?.description || '';
  const icon = trail?.icon || '📖';
  const realm = trail?.realmLabel || trail?.realm || 'Reino';
  const inner = `
    <div class="pv-trail-sky">
      ${region('icon', focus, `<span class="pv-trail-icon">${escapeHtml(icon)}</span>`)}
      <span class="pv-chip">${trail?.comingSoon ? 'Em breve' : 'Trilha'}</span>
    </div>
    ${region('title', focus, `<h3 class="pv-trail-title">${ph(title, 'Nome da trilha')}</h3>`)}
    ${region('description', focus, `<p class="pv-trail-desc">${ph(desc, 'Uma linha sobre o caminho…')}</p>`)}
    <p class="pv-trail-meta">${escapeHtml(realm)}</p>`;
  return phone(inner, { caption: 'Cartão da trilha no app' });
}

/**
 * Jornada no app (aba Explorar → card → caminho): card da fase e as estações
 * da trilha. `stations`: [{ roman, title, status, soon, isNew }]; a nova vem em destaque.
 */
export function renderJourneyPreview({ journeyLabel, subtitle, phaseIndex, phaseLabel, stations, before = 0 }) {
  const station = (st) => `
    <div class="pv-station ${st.isNew ? 'is-new' : ''} ${st.soon ? 'is-soon' : ''}">
      <span class="pv-station-node" aria-hidden="true"></span>
      <div class="pv-station-card">
        <span class="pv-station-eyebrow">Trilha ${escapeHtml(st.roman)}${st.isNew ? '<em>nova</em>' : ''}</span>
        <strong class="pv-station-title">${st.isNew ? ph(st.title, 'Nome da trilha') : escapeHtml(st.title)}</strong>
        <span class="pv-station-status">${st.isNew ? ph(st.status, 'Uma linha sobre o caminho…') : escapeHtml(st.status || '')}</span>
        ${st.soon ? '<span class="pv-chip pv-station-chip">Em breve</span>' : ''}
      </div>
    </div>`;
  const inner = `
    ${topbar(escapeHtml(journeyLabel), escapeHtml(subtitle))}
    <div class="pv-journey">
      ${before ? `<p class="pv-journey-more">↑ ${before} trilha${before > 1 ? 's' : ''} antes</p>` : ''}
      <div class="pv-phase">
        <span>Fase ${escapeHtml(String(phaseIndex).padStart(2, '0'))}</span>
        <strong>${escapeHtml(phaseLabel)}</strong>
      </div>
      <div class="pv-path">${stations.map(station).join('')}</div>
    </div>`;
  return phone(inner, { caption: 'Onde aparece no app' });
}

/**
 * Linha da aba Explorar com o card novo no fim. `cards`: [{ title, blurb, plus, isNew, tone }].
 */
export function renderShelfPreview({ shelfLabel, cards }) {
  const card = (c) => `
    <div class="pv-shelf-card tone-${escapeHtml(c.tone || 'vida-crista')} ${c.isNew ? 'is-new' : ''}">
      <span class="pv-shelf-glyph" aria-hidden="true">${escapeHtml(c.icon || '✦')}</span>
      ${c.plus ? '<span class="pv-chip pv-shelf-plus">Plus</span>' : ''}
      <strong>${c.isNew ? ph(c.title, 'Nome do card') : escapeHtml(c.title)}</strong>
      <small>${c.isNew ? ph(c.blurb, 'Frase do card') : escapeHtml(c.blurb || '')}</small>
      ${c.isNew ? '<em class="pv-shelf-new">novo</em>' : ''}
    </div>`;
  const inner = `
    <div class="pv-shelf">
      <p class="pv-shelf-title">${escapeHtml(shelfLabel)}</p>
      <div class="pv-shelf-row">${cards.map(card).join('')}</div>
    </div>`;
  return phone(inner, { caption: 'Onde aparece no app' });
}

/**
 * Aba Explorar: as portas (linhas) em lista, a nova no fim e em destaque.
 * `doors`: [{ title, subtitle, tone, icon, plus, isNew }].
 */
export function renderDoorsPreview({ doors }) {
  const door = (d) => `
    <div class="pv-door tone-${escapeHtml(d.tone || 'vida-crista')} ${d.isNew ? 'is-new' : ''}">
      <span class="pv-shelf-glyph" aria-hidden="true">${escapeHtml(d.icon || '✦')}</span>
      ${d.plus ? '<span class="pv-chip pv-shelf-plus">Plus</span>' : ''}
      <strong>${d.isNew ? ph(d.title, 'Nome da linha') : escapeHtml(d.title)}</strong>
      <small>${d.isNew ? ph(d.subtitle, 'Frase da linha') : escapeHtml(d.subtitle || '')}</small>
      ${d.isNew ? '<em class="pv-shelf-new">nova</em>' : ''}
    </div>`;
  const inner = `
    <div class="pv-shelf">
      <p class="pv-shelf-title">Explorar</p>
      <div class="pv-doors">${doors.map(door).join('')}</div>
    </div>`;
  return phone(inner, { caption: 'Onde aparece no app' });
}

/** Tela de entrada do passo. */
export function renderIntroPreview(step, { focus = '', trailTitle = '' } = {}) {
  const title = step?.title || '';
  const verse = step?.hookVerse || '';
  const ref = step?.hookRef || '';
  const note = step?.hookNote || '';
  const intro = step?.intro || '';
  const hasBible = Boolean(String(verse).trim() || String(note).trim());

  const verseBlock = hasBible
    ? `
      <div class="pv-verse-card">
        ${region('hookRef', focus, `<div class="pv-ref">${ph(ref, 'Gênesis 1:1')}</div>`)}
        ${region('hookVerse', focus, `<p class="pv-verse">${ph(verse, 'O texto do verso aparece aqui.')}</p>`)}
      </div>
      ${region('hookNote', focus, `<p class="pv-note">${ph(note, 'Nota de entrada — uma ou duas linhas.')}</p>`)}`
    : region('intro', focus, `<p class="pv-note">${ph(intro, 'Frase de contexto, se não houver verso.')}</p>`);

  const inner = `
    ${topbar(ph(title, 'Título do passo'), 'Treino')}
    <div class="pv-body">
      <div class="pv-mission-icon">✦</div>
      ${region('title', focus, `<h3 class="pv-h">${ph(title, 'Título do passo')}</h3>`)}
      <p class="pv-meta">~3 min · atos · ${escapeHtml(trailTitle || 'trilha')}</p>
      ${verseBlock}
    </div>
    ${cta('Começar')}`;
  return phone(inner, { caption: 'Tela de entrada — antes das perguntas' });
}

/** Tela “Hoje” / insight. */
export function renderInsightPreview(insight, { focus = '' } = {}) {
  const inner = `
    ${topbar('Hoje', 'O que ficou')}
    <div class="pv-body pv-insight">
      <div class="pv-spark">✧</div>
      <div class="pv-hoje-rule"><span>HOJE</span></div>
      ${region('insight', focus, `<p class="pv-insight-text">${ph(insight, 'A frase que fica — até 140 caracteres.')}</p>`)}
    </div>
    ${cta('Seguir')}`;
  return phone(inner, { caption: 'Tela final — o que ficou' });
}

function cueText(q) {
  const type = q?.type || 'choice';
  const cue = (q.cue || q.prompt || q.question || '').trim();
  if (type === 'complete' && /^complete a lacuna\.?$/i.test(cue)) return '';
  return cue;
}

function optsOf(q) {
  return (q.options || []).filter((o) => String(o.text || '').trim());
}

function renderBlank(template) {
  const raw = String(template || '').trim() || 'Escreva o trecho com ___ no lugar da palavra.';
  return escapeHtml(raw).replaceAll('___', '<span class="pv-blank">　　</span>');
}

function optionTiles(q, focus, { letters = true } = {}) {
  const type = q?.type || 'choice';
  if (type === 'true_false') {
    return region(
      'answer',
      focus,
      `<div class="pv-vf">
        <div class="pv-vf-btn ${q.correctAnswer === 'true' || q.correctOptionId === 'true' ? 'on' : ''}">V<span>Verdadeiro</span></div>
        <div class="pv-vf-btn ${q.correctAnswer === 'false' || q.correctOptionId === 'false' ? 'on' : ''}">F<span>Falso</span></div>
      </div>`,
    );
  }
  const all = (q.options || []).filter((o) => o && o.id);
  const shown = all.length ? all : [
    { id: 'a', text: '' },
    { id: 'b', text: '' },
    { id: 'c', text: '' },
  ];
  const compact = type === 'complete' || type === 'connect';
  return region(
    'options',
    focus,
    `<div class="pv-opts ${compact ? 'chips' : ''}">
      ${shown.map((o, i) => {
        const letter = String.fromCharCode(65 + i);
        const correct = (q.correctOptionId || q.correctAnswer) === o.id;
        return `<div class="pv-opt ${correct ? 'correct' : ''}" data-region="opt-${o.id}">
          ${letters && !compact ? `<span class="pv-badge">${letter}</span>` : ''}
          <span>${ph(o.text, compact ? `Opção ${letter}` : `Alternativa ${letter}`)}</span>
        </div>`;
      }).join('')}
    </div>`,
  );
}

/** Destaca no versículo os trechos tocáveis (opções) — a certa em dourado. */
function markTaps(text, options, correctId) {
  const raw = String(text || '');
  const spans = [];
  for (const o of options || []) {
    const t = String(o.text || '').trim();
    if (!t) continue;
    const i = raw.indexOf(t);
    if (i >= 0) spans.push({ start: i, end: i + t.length, correct: o.id === correctId });
  }
  spans.sort((a, b) => a.start - b.start);
  let out = '';
  let at = 0;
  for (const sp of spans) {
    if (sp.start < at) continue;
    out += escapeHtml(raw.slice(at, sp.start));
    out += `<span class="pv-tap ${sp.correct ? 'correct' : ''}">${escapeHtml(raw.slice(sp.start, sp.end))}</span>`;
    at = sp.end;
  }
  return out + escapeHtml(raw.slice(at));
}

/** Versículo com o `evidenceSpan` aceso, como o app mostra depois da resposta. */
function markSpan(text, span) {
  const raw = String(text || '');
  const s = String(span || '').trim();
  const i = s ? raw.indexOf(s) : -1;
  if (i < 0) return escapeHtml(raw);
  return `${escapeHtml(raw.slice(0, i))}<mark class="pv-span">${escapeHtml(s)}</mark>${escapeHtml(raw.slice(i + s.length))}`;
}

function heroFor(q, focus) {
  const type = q?.type || 'choice';
  if (type === 'complete') {
    return `
      ${region('verseRef', focus, q.verseRef
        ? `<div class="pv-study">ESTUDAR · ${escapeHtml(q.verseRef)}</div>`
        : `<div class="pv-study dim">ESTUDAR · referência</div>`)}
      ${region('template', focus, `<p class="pv-manuscript">${renderBlank(q.template)}</p>`)}`;
  }
  if (type === 'find_in_text') {
    return `
      ${region('verseRef', focus, q.verseRef
        ? `<div class="pv-study">${escapeHtml(q.verseRef)}</div>`
        : `<div class="pv-study dim">referência</div>`)}
      ${region('passageText', focus, `<p class="pv-manuscript">${q.passageText
        ? markTaps(q.passageText, optsOf(q), q.correctOptionId)
        : ph('', 'Cole o versículo. As opções precisam aparecer nele.')}</p>`)}`;
  }
  if (type === 'tap') {
    return `
      ${region('verseRef', focus, q.verseRef
        ? `<div class="pv-study">ESTUDAR · ${escapeHtml(q.verseRef)}</div>`
        : `<div class="pv-study dim">ESTUDAR · referência</div>`)}
      ${region('passageText', focus, `<p class="pv-manuscript">${ph(q.passageText, 'Cole o trecho. Ele fica no centro da tela.')}</p>`)}`;
  }
  if (type === 'connect') {
    const a = q.passageA || {};
    const b = q.passageB || {};
    return `<div class="pv-bridge">
      ${region('passageA', focus, `
        <div class="pv-mini-pass">
          <small>${ph(a.ref, 'Ref. A')}</small>
          <p>${ph(a.text, 'Primeiro trecho.')}</p>
        </div>`)}
      <div class="pv-bridge-line"></div>
      ${region('passageB', focus, `
        <div class="pv-mini-pass">
          <small>${ph(b.ref, 'Ref. B')}</small>
          <p>${ph(b.text, 'Segundo trecho.')}</p>
        </div>`)}
    </div>`;
  }
  if (type === 'order') {
    const items = optsOf(q);
    const shown = items.length ? items : [
      { id: 'a', text: '' },
      { id: 'b', text: '' },
      { id: 'c', text: '' },
    ];
    return region(
      'options',
      focus,
      `<div class="pv-order">
        ${shown.map((o, i) => `
          <div class="pv-order-row ${focus === `opt-${o.id}` ? 'pv-hot' : ''}">
            <span class="pv-handle">⋮⋮</span>
            <span>${ph(o.text, `Trecho ${i + 1} — na ordem certa`)}</span>
          </div>`).join('')}
      </div>`,
    );
  }
  if (q.note) {
    return region('note', focus, `<div class="pv-context"><small>CONTEXTO</small><p>${escapeHtml(q.note)}</p></div>`);
  }
  return '';
}

/** Tela da ação (quiz / V/F / complete / drag / tap / connect). */
export function renderActPreview(q, { focus = '', index = 1, total = 5 } = {}) {
  const g = gestureMeta(q?.type);
  const cue = cueText(q);
  const type = q?.type || 'choice';
  const hero = heroFor(q, focus);
  const showOpts = type !== 'order' && type !== 'find_in_text';
  const hint = String(q?.hint || '').trim();

  const inner = `
    ${topbar(`${index}/${total}`, g.verb)}
    <div class="pv-body">
      ${region('verb', focus, `<div class="pv-verb">${g.verbUp}</div>`)}
      ${region('cue', focus, `<p class="pv-cue">${ph(cue, type === 'true_false' ? 'Afirmação para julgar verdadeira ou falsa.' : 'Pergunta que o aluno lê no topo.')}</p>`)}
      ${hero}
      ${showOpts ? optionTiles(q, focus) : ''}
      ${hint ? region('hint', focus, `<p class="pv-hint-line"><span>Dica</span> ${escapeHtml(hint)}</p>`) : ''}
    </div>
    <div class="pv-foot">
      <span class="pv-lamps">●●●●○</span>
      <span>Dica</span>
      ${type === 'order' ? '<span class="pv-confirm">Confirmar</span>' : ''}
    </div>`;
  return phone(inner, { caption: `Tela da ação · ${g.label}` });
}

/** Overlay depois de responder. `wrongId` mostra o feedback daquela opção errada. */
export function renderFeedbackPreview(q, { focus = '', correct = true, wrongId = null } = {}) {
  const fw = q.feedbackWrong || {};
  const wrongKey = wrongId
    || (q.type === 'true_false'
      ? (q.correctOptionId === 'true' ? 'false' : 'true')
      : Object.keys(fw).find((k) => k !== 'default') || 'default');
  const msg = correct
    ? (q.feedbackCorrect || '').trim()
    : String(fw[wrongKey] || fw.default || '').trim();
  const ref = (q.verseRef || '').trim();
  const passage = (q.passageText || '').trim();
  const wrongOpt = (q.options || []).find((o) => o.id === wrongKey);
  const inner = `
    ${topbar('1/5', gestureMeta(q?.type).verb)}
    <div class="pv-body dimmed">
      <p class="pv-cue">${ph(cueText(q), 'Pergunta')}</p>
    </div>
    <div class="pv-overlay">
      <strong class="${correct ? 'ok' : 'no'}">${correct ? 'Acertou!' : 'Quase'}</strong>
      ${!correct && wrongOpt ? `<p class="pv-wrong-pick">Escolheu: ${escapeHtml(wrongOpt.text || wrongKey)}</p>` : ''}
      ${region(correct ? 'feedbackCorrect' : 'feedbackWrong', focus, `<p>${ph(msg, correct ? 'Por que está certo.' : 'Por que esta opção está errada.')}</p>`)}
      ${region(
        'evidenceSpan',
        focus,
        `<div class="pv-fb-verse">
          <small>${ph(ref, 'Referência do verso')}</small>
          <p>${passage ? markSpan(passage, q.evidenceSpan) : ph('', 'O versículo aparece aqui, com o trecho da prova aceso.')}</p>
        </div>`,
      )}
      <div class="pv-cta sm">Continuar</div>
    </div>`;
  return phone(inner, { caption: correct ? 'Depois de acertar' : 'Depois de errar' });
}

export function renderPreviewByScreen(screen, ctx) {
  if (screen === 'insight') return renderInsightPreview(ctx.insight || ctx.step?.centralInsight, { focus: ctx.focus });
  if (screen === 'feedback') return renderFeedbackPreview(ctx.question || {}, { focus: ctx.focus });
  if (screen === 'act' || screen === 'question') {
    return renderActPreview(ctx.question || {}, { focus: ctx.focus });
  }
  if (screen === 'trail') return renderTrailCardPreview(ctx.trail || {}, { focus: ctx.focus });
  return renderIntroPreview(ctx.step || {}, { focus: ctx.focus, trailTitle: ctx.trailTitle });
}
