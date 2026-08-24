import { escapeHtml } from './ui.js';

export const GESTURES = [
  {
    id: 'choice',
    icon: '🔘',
    verb: 'Escolha',
    verbUp: 'ESCOLHA',
    label: 'Quiz',
    blurb: 'Pergunta e alternativas',
    where: 'Opções empilhadas embaixo da pergunta',
  },
  {
    id: 'true_false',
    icon: '✓✗',
    verb: 'Julgue',
    verbUp: 'JULGUE',
    label: 'Verdadeiro / Falso',
    blurb: 'Uma afirmação para julgar',
    where: 'Dois botões — V e F — no rodapé',
  },
  {
    id: 'complete',
    icon: '___',
    verb: 'Complete',
    verbUp: 'COMPLETE',
    label: 'Complete',
    blurb: 'Verso com lacuna',
    where: 'Trecho no centro; chips preenchem o ___',
  },
  {
    id: 'order',
    icon: '↕',
    verb: 'Ordene',
    verbUp: 'ORDENE',
    label: 'Arraste',
    blurb: 'Monte a sequência',
    where: 'Lista no centro, com alça para arrastar',
  },
  {
    id: 'tap',
    icon: '👆',
    verb: 'Toque',
    verbUp: 'TOQUE',
    label: 'Toque',
    blurb: 'Verso em destaque + opções',
    where: 'Manuscrito no centro; opções embaixo',
  },
  {
    id: 'connect',
    icon: '🔗',
    verb: 'Conecte',
    verbUp: 'CONECTE',
    label: 'Conecte',
    blurb: 'Dois trechos',
    where: 'Dois blocos de texto + chips',
  },
];

export const DIFFS = [
  { id: 'semente', label: 'Observação', hint: 'Observar o que o texto diz' },
  { id: 'caminhada', label: 'Compreensão', hint: 'Compreender o que comunica' },
  { id: 'profundezas', label: 'Interpretação', hint: 'Interpretar o que significa' },
];

export function gestureMeta(type) {
  return GESTURES.find((g) => g.id === type) || GESTURES[0];
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

function heroFor(q, focus) {
  const type = q?.type || 'choice';
  if (type === 'complete') {
    return `
      ${region('verseRef', focus, q.verseRef
        ? `<div class="pv-study">ESTUDAR · ${escapeHtml(q.verseRef)}</div>`
        : `<div class="pv-study dim">ESTUDAR · referência</div>`)}
      ${region('template', focus, `<p class="pv-manuscript">${renderBlank(q.template)}</p>`)}`;
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
  const showOpts = type !== 'order';

  const inner = `
    ${topbar(`${index}/${total}`, g.verb)}
    <div class="pv-body">
      ${region('verb', focus, `<div class="pv-verb">${g.verbUp}</div>`)}
      ${region('cue', focus, `<p class="pv-cue">${ph(cue, type === 'true_false' ? 'Afirmação para julgar verdadeira ou falsa.' : 'Pergunta que o aluno lê no topo.')}</p>`)}
      ${hero}
      ${showOpts ? optionTiles(q, focus) : ''}
    </div>
    <div class="pv-foot">
      <span class="pv-lamps">●●●●○</span>
      <span>Dica</span>
      ${type === 'order' ? '<span class="pv-confirm">Confirmar</span>' : ''}
    </div>`;
  return phone(inner, { caption: `Tela da ação · ${g.label}` });
}

/** Overlay depois de responder. */
export function renderFeedbackPreview(q, { focus = '', correct = true } = {}) {
  const ok = (q.feedbackCorrect || '').trim();
  const ref = (q.verseRef || '').trim();
  const passage = (q.passageText || '').trim();
  const inner = `
    ${topbar('1/5', gestureMeta(q?.type).verb)}
    <div class="pv-body dimmed">
      <p class="pv-cue">${ph(cueText(q), 'Pergunta')}</p>
    </div>
    <div class="pv-overlay">
      <strong class="${correct ? 'ok' : 'no'}">${correct ? 'Acertou!' : 'Quase'}</strong>
      ${region('feedbackCorrect', focus, `<p>${ph(ok, 'Frase curta de confirmação.')}</p>`)}
      ${region(
        'verseRef',
        focus,
        `<div class="pv-fb-verse">
          <small>${ph(ref, 'Referência do verso')}</small>
          <p>${ph(passage, 'O trecho aparece aqui depois de responder (quiz e V/F).')}</p>
        </div>`,
      )}
      <div class="pv-cta sm">Continuar</div>
    </div>`;
  return phone(inner, { caption: 'Depois de responder' });
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
