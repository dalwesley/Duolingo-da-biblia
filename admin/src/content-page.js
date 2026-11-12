/**
 * Explorar: coleção → trilha → cena (vocab do painel).
 *
 * Coleção = Bíblia, Temas, Vida Cristã, Teologia (e portas do painel).
 * À esquerda, cards de coleção; ao clicar, as trilhas abrem ao lado.
 * À direita, a trilha (cenas) ou a cena em Perguntas / Estudo / Entrada.
 *
 * Endereço: #explorar/<trilha>/<cena>/<aba>.
 */
import { COL, getDocById, listCollection, listTrash, listWhere, purgeFromTrash, removeDoc, restoreFromTrash, saveDoc, TRASH_DAYS, formatDate } from './db.js';
import { buildTree, cardShelves, categoryLabel, locateTrail, scenesOf, setExtraCards, setExtraShelves, trailIdOf } from './catalog-tree.js';
import { NEW_DOOR, openCardEditor } from './card-editor.js';
import { openShelfEditor } from './shelf-editor.js';
import { DIFFS, V3_GESTURES, gestureMeta, renderInsightPreview, renderIntroPreview } from './content-preview.js';
import { openQuestionStudio } from './question-studio.js';
import { openStudyEditor } from './studies-page.js';
import { openCreateTrail } from './trails-page.js';
import { checkScene, isV3Scene } from './v3-check.js';
import { jfaal, loadJfaal } from './jfaal-browser.js';
import { confirmAction, escapeHtml, setLoading, showToast } from './ui.js';

const HASH = '#explorar';
const MODE_ORDER = { semente: 0, caminhada: 1, profundezas: 2 };
const TABS = [
  { id: 'perguntas', label: 'Perguntas' },
  { id: 'estudo', label: 'Estudo' },
  { id: 'entrada', label: 'Entrada' },
];

export function contentHash(trail = '', scene = '', tab = '') {
  return [HASH, trail, scene, tab].filter(Boolean).join('/');
}

function readHash() {
  const h = decodeURIComponent(location.hash || '');
  if (!h.startsWith(HASH)) return {};
  const [, trail = '', scene = '', tab = ''] = h.split('/');
  return { trail, scene, tab };
}

function pad(n) {
  return String(n).padStart(2, '0');
}

function promptOf(q) {
  return (q.cue || q.prompt || q.question || '').trim();
}

function answerOf(q) {
  if (q.type === 'true_false') return q.correctOptionId === 'true' ? 'Verdadeiro' : 'Falso';
  if (q.type === 'order') {
    const byId = new Map((q.options || []).map((o) => [o.id, o.text]));
    return (q.correctOrder || []).map((id) => byId.get(id)).filter(Boolean).join(' → ');
  }
  return (q.options || []).find((o) => o.id === q.correctOptionId)?.text || '';
}

function issueCount(r) {
  if (!r) return { e: 0, w: 0 };
  return { e: r.errors.length, w: r.warnings.length };
}

export async function renderContentPage(root, navigate) {
  root.innerHTML = `<div class="ez-skeleton">Carregando catálogo…</div>`;
  const [trails, cards, shelves] = await Promise.all([
    listCollection(COL.trails),
    listCollection(COL.cards).catch(() => []),
    listCollection(COL.shelves).catch(() => []),
  ]);
  // Linhas antes dos cards: o card aponta para a linha.
  setExtraShelves(shelves);
  setExtraCards(cards);
  const tree = buildTree(trails);
  const trailById = new Map(trails.map((t) => [trailIdOf(t), t]));

  const start = readHash();
  const startLoc = trailById.has(start.trail) ? locateTrail(tree, start.trail) : null;
  let sel = {
    shelf: startLoc?.shelf?.id || '',
    trail: trailById.has(start.trail) ? start.trail : '',
    scene: start.scene || '',
    tab: TABS.some((t) => t.id === start.tab) ? start.tab : 'perguntas',
  };
  let search = '';
  let onlyIssues = false;
  const cache = new Map(); // trailId → { items, studies, results, checking, error }
  let trash = [];

  async function refreshTrash() {
    try {
      trash = await listTrash();
    } catch {
      trash = [];
    }
  }

  function writeHash() {
    const h = sel.trail ? contentHash(sel.trail, sel.scene, sel.scene ? sel.tab : '') : HASH;
    if (location.hash !== h) history.replaceState(null, '', h);
  }

  function shelfNode(id) {
    return tree.find((x) => x.shelf.id === id) || null;
  }

  function shelfTrailCount(node) {
    return (node?.journeys || []).reduce((k, j) => k + j.phases.reduce((m, p) => m + p.trails.length, 0), 0);
  }

  function filteredJourneys(node) {
    return (node?.journeys || [])
      .map((j) => {
        const phases = j.phases.map((p) => ({ ...p, trails: p.trails.filter(matches) }));
        const all = phases.flatMap((p) => p.trails);
        return { ...j, phases, total: all.length, soon: all.length > 0 && all.every((t) => t.comingSoon) };
      })
      .filter((j) => j.total || !search);
  }

  /* ─── Dados da trilha ─────────────────────────────────── */

  /** Banco da cena: o dela ou, se emprestada, o da cena de origem. */
  function bankOf(trailId, slug) {
    const ms = missionOf(trailById.get(trailId), slug) || {};
    return { trail: ms.bankTrailSlug || trailId, section: ms.bankSection || slug };
  }
  const inScene = (trailId, slug) => {
    const b = bankOf(trailId, slug);
    return (q) => (q.trail || trailId) === b.trail && q.section === b.section;
  };

  async function loadTrail(trailId) {
    if (cache.has(trailId)) return cache.get(trailId);
    const t = trailById.get(trailId);
    const scenes = scenesOf(t);
    const entry = { items: [], studies: new Map(), results: new Map(), checking: true, error: '' };
    cache.set(trailId, entry);
    // Cena emprestada (A Promessa): perguntas e estudo são os da cena de origem.
    const banks = [...new Set([trailId, ...scenes.map((s) => bankOf(trailId, s.slug).trail)])];
    const [lists, studies] = await Promise.all([
      Promise.all(banks.map((b) => listWhere(COL.bank, 'trail', b))),
      Promise.all(scenes.map((s) => getDocById(COL.studies, bankOf(trailId, s.slug).section).catch(() => null))),
    ]);
    entry.items = lists.flat();
    entry.studies = new Map(scenes.map((s, i) => [s.slug, studies[i]]));
    paintMain();
    runChecks(trailId);
    return entry;
  }

  async function checkOne(trailId, slug) {
    const entry = cache.get(trailId);
    const s = scenesOf(trailById.get(trailId)).find((x) => x.slug === slug);
    const qs = entry.items.filter(inScene(trailId, slug));
    if (!s || !qs.length || !isV3Scene(qs)) {
      entry.results.delete(slug);
      return;
    }
    entry.results.set(slug, await checkScene({ ...bankOf(trailId, slug), questions: qs, study: entry.studies.get(slug), boss: s.boss }));
  }

  async function runChecks(trailId) {
    const entry = cache.get(trailId);
    entry.checking = true;
    try {
      for (const s of scenesOf(trailById.get(trailId))) {
        await checkOne(trailId, s.slug);
        if (sel.trail === trailId) {
          if (!sel.scene || sel.scene === s.slug) paintMain();
        } else if (sel.shelf && !sel.trail) {
          paintMain();
        }
      }
    } catch (e) {
      entry.error = e.message || String(e);
    }
    entry.checking = false;
    if (sel.trail === trailId || (sel.shelf && !sel.trail)) paintMain();
  }

  function trailIssues(trailId) {
    const entry = cache.get(trailId);
    if (!entry) return null;
    let e = 0;
    let w = 0;
    for (const r of entry.results.values()) {
      e += r.errors.length;
      w += r.warnings.length;
    }
    return { e, w, checking: entry.checking };
  }

  /* ─── Coleções (esquerda) + trilhas (ao lado) ─────────── */

  function matches(t) {
    if (!search) return true;
    return `${t.title || ''} ${trailIdOf(t)}`.toLowerCase().includes(search.toLowerCase());
  }

  function collectionCardsHtml() {
    return tree.map((node) => {
      const { shelf } = node;
      const n = shelfTrailCount(node);
      const on = sel.shelf === shelf.id;
      return `
        <button type="button" class="ct-col-card ${on ? 'on' : ''}" data-shelf="${escapeHtml(shelf.id)}">
          <span class="ct-col-card-top">
            <strong>${escapeHtml(shelf.label)}</strong>
            ${shelf.hidden ? '<span class="ct-tag">oculta</span>' : ''}
            ${shelf.extra ? `<span class="ct-edit-shelf" data-edit-shelf="${escapeHtml(shelf.id)}" role="button" tabindex="0" aria-label="Editar coleção ${escapeHtml(shelf.label)}" title="Editar">✎</span>` : ''}
          </span>
          <span class="ct-col-card-meta">${n} trilha${n === 1 ? '' : 's'}</span>
        </button>`;
    }).join('') + `
      <button type="button" class="ct-add-shelf" data-new-shelf>+ Nova coleção</button>`;
  }

  function paintCollections() {
    const slot = root.querySelector('#ct-cols');
    if (!slot) return;
    slot.innerHTML = collectionCardsHtml();
  }

  function trailCard(t, journeySoon = false) {
    const id = trailIdOf(t);
    const scenes = scenesOf(t);
    const iss = trailIssues(id);
    const badge = iss
      ? iss.checking
        ? '<span class="ct-dot wait" title="Conferindo">…</span>'
        : iss.e
          ? `<span class="rv-pill bad sm">${iss.e}</span>`
          : '<span class="ct-dot ok" title="Sem erros">✓</span>'
      : '';
    return `
      <button type="button" class="ct-trail-card" data-trail="${escapeHtml(id)}">
        <span class="ct-trail-card-top">
          <strong>${escapeHtml(t.title || id)}</strong>
          ${t.comingSoon && !journeySoon ? '<span class="ct-tag">em breve</span>' : ''}
          ${badge}
        </span>
        <span class="ct-trail-card-meta">${scenes.length} cena${scenes.length === 1 ? '' : 's'}</span>
      </button>`;
  }

  function addTrailTile(category) {
    if (!category) return '';
    return `<button type="button" class="ct-trail-add" data-new-trail="${escapeHtml(category)}" title="Nasce “em breve” aqui">+ Nova trilha</button>`;
  }

  /** Topo (nome + busca) separado; cada fase/grupo em card próprio. */
  function trailsBrowserHtml() {
    const node = shelfNode(sel.shelf);
    const js = node ? filteredJourneys(node) : [];
    const canAddCard = node && cardShelves().some((s) => s.id === node.shelf.id) && !search;
    const total = js.reduce((n, j) => n + j.total, 0);
    const subtitle = node
      ? escapeHtml(node.shelf.label)
      : 'Escolha uma coleção à esquerda para ver as trilhas.';

    const top = `
      <header class="ct-trails-top">
        <div>
          <h3>Trilhas${node ? ` <small>${total}</small>` : ''}</h3>
          <p class="ct-level ${node ? '' : 'is-hint'}">${subtitle}</p>
        </div>
        ${node ? `<input type="search" id="ct-search" class="ez-search" placeholder="Buscar trilha…" autocomplete="off" value="${escapeHtml(search)}" />` : ''}
      </header>`;

    if (!node) return `<div class="ct-trails-stack">${top}</div>`;

    // Cada fase (Pentateuco…) ou grupo (Paz no dia…) vira um card.
    const withJourneyLabels = js.map((j) => {
      const phases = j.phases.filter((p) => p.trails.length || !search);
      if (!phases.length) return '';
      const multiPhase = phases.length > 1;
      const phaseCards = phases.map((p) => {
        const title = multiPhase ? p.label : j.journey.label;
        const tiles = [
          ...p.trails.map((t) => trailCard(t, j.soon)),
          addTrailTile(p.category),
        ].join('');
        return `
          <section class="ct-phase-card ${j.journey.extra ? 'is-extra' : ''} ${multiPhase ? 'is-phase' : 'is-group'}">
            <header class="ct-phase-card-head">
              <h3>${escapeHtml(title)}</h3>
              ${!multiPhase && j.journey.hidden ? '<span class="ct-tag">oculto</span>' : ''}
              ${!multiPhase && j.plus ? '<span class="ct-tag plus">Plus</span>' : ''}
              ${!multiPhase && j.soon ? '<span class="ct-tag">em breve</span>' : ''}
              ${!multiPhase && j.journey.extra ? `<button type="button" class="ct-edit-card" data-edit-card="${escapeHtml(j.journey.id)}" aria-label="Editar ${escapeHtml(j.journey.label)}" title="Editar">✎</button>` : ''}
              <span class="ct-count">${p.trails.length}</span>
            </header>
            <div class="ct-trail-grid">${tiles}</div>
          </section>`;
      }).join('');
      return multiPhase
        ? `<div class="ct-journey-block">
            <p class="ct-journey-label">${escapeHtml(j.journey.label)} <span class="ct-count">${j.total}</span></p>
            <div class="ct-journey-cards">${phaseCards}</div>
          </div>`
        : phaseCards;
    }).join('');

    return `
      <div class="ct-trails-stack">
        ${top}
        <div class="ct-trails-browser">
          ${withJourneyLabels || `<p class="ct-shelf-note">${search ? 'Nenhuma trilha com esse nome.' : 'Sem trilhas nesta coleção.'}</p>`}
          ${canAddCard ? `<button type="button" class="ct-add-row" data-new-card="${escapeHtml(node.shelf.id)}">+ Grupo em ${escapeHtml(node.shelf.label)}</button>` : ''}
        </div>
      </div>`;
  }

  /* ─── Painel central ──────────────────────────────────── */

  function crumbs() {
    const parts = [];
    const t = trailById.get(sel.trail);
    const loc = t ? locateTrail(tree, sel.trail) : null;
    const shelf = shelfNode(sel.shelf)?.shelf;
    if (shelf) {
      parts.push(`<button type="button" class="ct-crumb" data-shelf-home>${escapeHtml(shelf.label)}</button>`);
    }
    if (loc && t) {
      if (loc.journey.journey.label !== shelf?.label) {
        parts.push(escapeHtml(loc.journey.journey.label));
      }
      parts.push(`<button type="button" class="ct-crumb" data-trail-home>${escapeHtml(t.title || sel.trail)}</button>`);
    }
    if (sel.scene && t) {
      const scenes = scenesOf(t);
      const i = scenes.findIndex((s) => s.slug === sel.scene);
      if (i >= 0) parts.push(`Cena ${i + 1} · ${escapeHtml(scenes[i].title || sel.scene)}`);
    }
    return parts.length ? `<nav class="ct-crumbs">${parts.join('<span>›</span>')}</nav>` : '';
  }

  function trailHtml() {
    const t = trailById.get(sel.trail);
    const entry = cache.get(sel.trail);
    const scenes = scenesOf(t);
    const loc = locateTrail(tree, sel.trail);
    const iss = trailIssues(sel.trail);
    const items = entry?.items || [];
    const status = !entry || entry.checking
      ? '<span class="rv-pill">Conferindo com a JFAAL…</span>'
      : entry.error
        ? `<span class="rv-pill bad">Checagem falhou: ${escapeHtml(entry.error)}</span>`
        : entry.results.size
          ? `<span class="rv-pill ${iss.e ? 'bad' : 'ok'}">${iss.e} erro(s)</span><span class="rv-pill ${iss.w ? 'warn' : ''}">${iss.w} aviso(s)</span>`
          : '<span class="rv-pill">Banco V2: sem checagem V3</span>';
    const edited = items.filter((q) => q.panelEditedAt).length;

    const cards = scenes.map((s, i) => {
      const qs = items.filter(inScene(sel.trail, s.slug));
      const r = entry?.results.get(s.slug);
      const { e, w } = issueCount(r);
      const modes = DIFFS.map((d) => `${d.label} ${qs.filter((q) => q.difficulty === d.id).length}`).join(' · ');
      const list = onlyIssues && r
        ? [...r.scene.errors, ...r.study.errors.map((m) => `estudo: ${m}`), ...[...r.byQuestion].flatMap(([id, x]) => x.errors.map((m) => `${id.split('-').slice(-1)[0]} · ${m}`))]
        : [];
      if (onlyIssues && !e && !w) return '';
      return `
        <button type="button" class="ct-scene-card ${e ? 'has-err' : w ? 'has-warn' : ''}" data-scene="${escapeHtml(s.slug)}">
          <span class="ct-scene-num">Cena ${i + 1}${s.boss ? ' · Travessia' : ''}</span>
          <strong>${escapeHtml(s.title || s.slug)}</strong>
          <small>${qs.length ? modes : 'sem perguntas'}</small>
          <span class="rv-badges">${e ? `<span class="rv-pill bad sm">${e} ✗</span>` : ''}${w ? `<span class="rv-pill warn sm">${w} !</span>` : ''}${entry?.studies.get(s.slug) ? '' : '<span class="rv-pill sm">sem estudo</span>'}</span>
          ${list.length ? `<ul class="rv-issues">${list.slice(0, 6).map((m) => `<li class="bad">✗ ${escapeHtml(m)}</li>`).join('')}${list.length > 6 ? `<li>…e mais ${list.length - 6}</li>` : ''}</ul>` : ''}
        </button>`;
    }).join('');

    return `
      ${crumbs()}
      <header class="ct-head">
        <div>
          <p class="ct-level">Trilha</p>
          <h1>${escapeHtml(t.title || sel.trail)}</h1>
          <p class="ez-lead">${escapeHtml(t.description || '')}</p>
          <p class="ct-meta"><code>${escapeHtml(sel.trail)}</code> · fase ${escapeHtml(loc ? categoryLabel(loc.phase.category) : t.category || '')} · ${scenes.length} cenas · ${items.length} perguntas${t.comingSoon ? ' · <strong>em breve</strong>' : ''}${loc?.journey.plus ? ' · Peregrino+' : ''}</p>
        </div>
        <div class="ez-hero-actions">
          <button type="button" class="btn btn-secondary btn-sm" data-new-scene>+ Nova cena</button>
          <button type="button" class="btn btn-secondary btn-sm" data-edit-trail>Editar trilha</button>
        </div>
      </header>
      <div class="rv-summary">
        ${status}
        ${edited ? `<span class="rv-pill warn" title="npm run v3:pull -- --trail ${escapeHtml(sel.trail)} --apply">${edited} editada(s) no painel — falta v3:pull</span>` : ''}
        <label class="ez-check"><input type="checkbox" id="ct-only-issues" ${onlyIssues ? 'checked' : ''}/> <span>Só cenas com problema</span></label>
      </div>
      <h2 class="ct-section">Cenas <small>${scenes.length}</small></h2>
      <div class="ct-scene-grid">${cards || '<p class="ez-hint">Nenhuma cena com problema.</p>'}</div>`;
  }

  /** Uma célula da matriz: a pergunta inteira, clicável; excluir aparece no hover. */
  function cellHtml(q, r, order = 0) {
    const g = gestureMeta(q.type);
    const iss = r?.byQuestion.get(q.id);
    const e = iss?.errors.length || 0;
    const w = iss?.warnings.length || 0;
    return `
      <div class="ct-cell ${e ? 'has-err' : w ? 'has-warn' : ''}" style="--o:${order}">
        <button type="button" class="ct-cell-main" data-edit-q="${escapeHtml(q.id)}" title="Editar ${escapeHtml(q.id)}">
          <span class="ct-cell-tag">${escapeHtml(g.label)}</span>
          <span class="ct-cell-stem">${escapeHtml(promptOf(q) || q.template || '(sem texto)')}</span>
          <span class="ct-cell-answer">✓ ${escapeHtml(answerOf(q) || '—')}</span>
          ${q.panelEditedAt || e || w ? `<span class="ct-cell-badges">
            ${q.panelEditedAt ? '<span class="rv-pill warn sm">editada</span>' : ''}
            ${e ? `<span class="rv-pill bad sm">${e} erro${e > 1 ? 's' : ''}</span>` : ''}
            ${w ? `<span class="rv-pill warn sm">${w} aviso${w > 1 ? 's' : ''}</span>` : ''}
          </span>` : ''}
        </button>
        <button type="button" class="ct-cell-del" data-del-q="${escapeHtml(q.id)}" title="Excluir ${escapeHtml(q.id)}" aria-label="Excluir pergunta">✕</button>
        ${e || w ? `<ul class="rv-issues">${iss.errors.map((m) => `<li class="bad">✗ ${escapeHtml(m)}</li>`).join('')}${iss.warnings.map((m) => `<li class="warn">! ${escapeHtml(m)}</li>`).join('')}</ul>` : ''}
      </div>`;
  }

  /**
   * Perguntas da cena como a matriz gesto × modo do SPEC V3: uma linha por
   * posição (a ordem do id), uma coluna por modo.
   */
  function questionsTab(scene, entry, r) {
    const qs = (entry?.items || []).filter(inScene(sel.trail, scene.slug));
    const sceneIssues = r ? [...r.scene.errors, ...r.study.errors.map((m) => `estudo: ${m}`)] : [];
    const cols = DIFFS.map((d) => qs.filter((q) => q.difficulty === d.id).sort((a, b) => String(a.id).localeCompare(String(b.id))));
    const rows = Math.max(0, ...cols.map((c) => c.length));
    const loose = qs.filter((q) => !MODE_ORDER.hasOwnProperty(q.difficulty));

    let body = '';
    for (let i = 0; i < rows; i++) {
      const types = [...new Set(cols.map((c) => c[i]?.type).filter(Boolean))];
      const label = types.length === 1 ? gestureMeta(types[0]).label : types.map((t) => gestureMeta(t).label).join(' / ');
      body += `
        <div class="ct-mx-gesture"><span class="ct-mx-n">${pad(i + 1)}</span>${escapeHtml(label)}</div>
        ${cols.map((c, m) => (c[i] ? cellHtml(c[i], r, m * 100 + i + 1) : `<div class="ct-cell empty" style="--o:${m * 100 + i + 1}"><button type="button" class="ct-cell-add" data-new-q="${DIFFS[m].id}">+ ${escapeHtml(DIFFS[m].label)}</button></div>`)).join('')}`;
    }

    return `
      ${sceneIssues.length ? `<ul class="rv-issues scene">${sceneIssues.map((m) => `<li class="bad">✗ ${escapeHtml(m)}</li>`).join('')}</ul>` : ''}
      <div class="ct-matrix">
        <div class="ct-mx-corner">Gesto</div>
        ${DIFFS.map((d, m) => `
          <div class="ct-mx-mode" style="--o:${m * 100}">
            <strong>${escapeHtml(d.label)}</strong>
            <small>${cols[m].length} pergunta${cols[m].length === 1 ? '' : 's'}</small>
            <button type="button" class="btn btn-ghost btn-sm" data-new-q="${d.id}" title="Nova pergunta em ${escapeHtml(d.label)}">+</button>
          </div>`).join('')}
        ${body || '<p class="ez-hint ct-mx-empty">Nenhuma pergunta nesta cena.</p>'}
      </div>
      ${loose.length ? `<h3 class="ct-section">Sem modo <small>${loose.length}</small></h3><div class="ct-loose">${loose.map((q) => cellHtml(q, r)).join('')}</div>` : ''}
      ${trashHtml(trash.filter(inScene(sel.trail, scene.slug)))}`;
  }

  /** Lixeira da cena: perguntas excluídas, restauráveis por TRASH_DAYS dias. */
  function trashHtml(items) {
    if (!items.length) return '';
    return `
      <section class="ct-trash">
        <h3 class="ct-section">Lixeira desta cena <small>${items.length}</small></h3>
        <ul class="ct-trash-list">
          ${items.map((x) => {
            const d = x.data || {};
            const mode = DIFFS.find((m) => m.id === d.difficulty)?.label || d.difficulty || '';
            return `<li>
              <div>
                <strong>${escapeHtml(promptOf(d) || x.id)}</strong>
                <small>${escapeHtml(mode)} · ${escapeHtml(gestureMeta(d.type).label)} · excluída ${escapeHtml(formatDate(x.at))}${x.by ? ` por ${escapeHtml(x.by)}` : ''} · ${x.daysLeft ? `some em ${x.daysLeft} dia${x.daysLeft === 1 ? '' : 's'}` : 'some hoje'}</small>
              </div>
              <button type="button" class="btn btn-secondary btn-sm" data-restore="${escapeHtml(x.id)}">Restaurar</button>
            </li>`;
          }).join('')}
        </ul>
      </section>`;
  }

  function studyTab(scene, entry, r) {
    const s = entry?.studies.get(scene.slug);
    if (!s) {
      return `<div class="db-card"><p class="db-lead">Esta cena ainda não tem estudo.</p><button type="button" class="btn btn-primary" data-edit-study>Criar estudo</button></div>`;
    }
    const issues = r ? [...r.study.errors.map((m) => ['bad', m]), ...r.study.warnings.map((m) => ['warn', m])] : [];
    const field = (label, v) => (v
      ? `<div class="ct-study-field"><p class="ct-study-k">${escapeHtml(label)}</p><p class="ct-study-v">${escapeHtml(v)}</p></div>`
      : '');
    const list = (title, arr, fmt) => (Array.isArray(arr) && arr.length
      ? `<section class="ct-study-sec"><h4>${escapeHtml(title)} <small>${arr.length}</small></h4><ul>${arr.map((x) => `<li>${fmt(x)}</li>`).join('')}</ul></section>`
      : '');
    const status = issues.length
      ? `<ul class="rv-issues scene">${issues.map(([c, m]) => `<li class="${c}">${c === 'bad' ? '✗' : '!'} ${escapeHtml(m)}</li>`).join('')}</ul>`
      : r ? '<p class="qe-check-head ok">Checagem V3 do estudo · tudo certo</p>' : '';
    const palavraLabel = s.keyword ? `Palavra · ${s.keyword}` : 'Palavra';
    const rail = [
      list('Fatos', s.facts, (f) => `${escapeHtml(f.text)} <small>${escapeHtml(f.evidenceRef || '')} · “${escapeHtml(f.evidenceSpan || '')}”</small>`),
      list('Relações', s.relations, (x) => `<em>${escapeHtml(x.kind)}</em> ${escapeHtml(x.text)}${x.marker ? ` <small>“${escapeHtml(x.marker)}”</small>` : ''}`),
      list('Textos cruzados', s.crossRefs, (c) => `<strong>${escapeHtml(c.ref)}</strong> ${escapeHtml(c.bridge || '')} <small>${escapeHtml(c.text || '')}</small>`),
      list('Leituras erradas', s.misreadings, (m) => `${escapeHtml(m.text)} <small>${escapeHtml(m.why || '')}</small>`),
    ].join('');
    return `
      <div class="ct-study">
        <div class="ct-study-toolbar">
          <div class="ct-study-status">
            ${status}
            ${s.panelEditedAt ? '<p class="ez-hint"><span class="rv-pill warn sm">editado no painel</span> falta <code>v3:pull</code></p>' : ''}
          </div>
          <button type="button" class="btn btn-primary" data-edit-study>Editar estudo</button>
        </div>
        <article class="ct-study-verse">
          <p class="ct-study-ref">${escapeHtml(s.passageRef || 'Trecho')}</p>
          <blockquote>${escapeHtml(s.passageText || '')}</blockquote>
        </article>
        <div class="ct-study-layout${rail ? '' : ' solo'}">
          <section class="ct-study-read">
            ${field('Contexto', s.context)}
            ${field(palavraLabel, s.keywordGloss)}
            ${field('Reflexão', s.focusQuestion)}
            ${field('Hoje', s.centralInsight)}
            ${field('Pergunta âncora', s.anchorQuestion)}
            ${list('Termos-chave', s.keyTerms, (k) => `<strong>${escapeHtml(k.term)}</strong> — ${escapeHtml(k.gloss)}`)}
            ${list('Estrutura', s.structure, (x) => `${escapeHtml(x.label)} <small>${escapeHtml(x.evidenceRef || '')}</small>`)}
          </section>
          ${rail ? `<aside class="ct-study-rail">${rail}</aside>` : ''}
        </div>
      </div>`;
  }

  const ENTRY_FIELDS = [
    ['title', 'Título da cena', 'input'],
    ['hookRef', 'Verso âncora · referência', 'input'],
    ['hookVerse', 'Texto do verso', 'area'],
    ['hookNote', 'Nota de entrada', 'area'],
    ['intro', 'Descritivo (se não houver verso)', 'area'],
    ['centralInsight', 'Frase “Hoje” (até 140)', 'input'],
    ['echoQuestion', 'Eco (pergunta aberta)', 'area'],
    ['objective', 'Objetivo (só no painel)', 'input'],
  ];

  function missionOf(trail, slug) {
    for (const mod of trail.modules || []) {
      for (const ms of mod.missions || []) if (ms.slug === slug) return ms;
    }
    return null;
  }

  function entryTab(scene) {
    const ms = missionOf(trailById.get(sel.trail), scene.slug) || {};
    return `
      <div class="ct-entry">
        <form class="ct-entry-form" id="ct-entry-form">
          ${ENTRY_FIELDS.map(([k, label, kind]) => `
            <label class="ez-field"><span class="ez-label">${escapeHtml(label)}</span>
              ${kind === 'area'
                ? `<textarea data-e="${k}" rows="2">${escapeHtml(ms[k] || '')}</textarea>`
                : `<input data-e="${k}" value="${escapeHtml(ms[k] || '')}" ${k === 'centralInsight' ? 'maxlength="140"' : ''} />`}
            </label>
            ${k === 'hookRef' ? '<button type="button" class="btn btn-ghost btn-sm" data-hook-jfaal>Puxar texto da JFAAL</button>' : ''}`).join('')}
          <p class="ez-hint">Grava na trilha (<code>content_trails</code>). Esta parte não passa pelo <code>v3:pull</code>.</p>
          <button type="submit" class="btn btn-primary">Salvar entrada</button>
        </form>
        <aside class="ct-entry-preview" id="ct-entry-preview"></aside>
      </div>`;
  }

  function paintEntryPreview() {
    const slot = root.querySelector('#ct-entry-preview');
    if (!slot) return;
    const draft = {};
    root.querySelectorAll('[data-e]').forEach((el) => {
      draft[el.dataset.e] = el.value;
    });
    slot.innerHTML = `${renderIntroPreview(draft, { trailTitle: trailById.get(sel.trail)?.title || '' })}${renderInsightPreview(draft.centralInsight || '')}`;
  }

  function sceneHtml() {
    const t = trailById.get(sel.trail);
    const scenes = scenesOf(t);
    const i = scenes.findIndex((s) => s.slug === sel.scene);
    const scene = scenes[i];
    if (!scene) return trailHtml();
    const entry = cache.get(sel.trail);
    const r = entry?.results.get(scene.slug);
    const qs = (entry?.items || []).filter(inScene(sel.trail, scene.slug));
    const { e, w } = issueCount(r);
    const prev = scenes[i - 1];
    const next = scenes[i + 1];
    let body = '<div class="ez-skeleton">Carregando cena…</div>';
    if (entry && !(entry.checking && !entry.items.length)) {
      body = sel.tab === 'estudo' ? studyTab(scene, entry, r) : sel.tab === 'entrada' ? entryTab(scene) : questionsTab(scene, entry, r);
    }
    return `
      ${crumbs()}
      <header class="ct-head">
        <div>
          <p class="ct-level">Cena ${i + 1} de ${scenes.length}${scene.boss ? ' · Travessia' : ''}</p>
          <h1>${escapeHtml(scene.title || scene.slug)}</h1>
          <div class="ct-meta-row">
            <code class="ct-slug">${escapeHtml(scene.slug)}</code>
            <span class="ct-chip">${qs.length} pergunta${qs.length === 1 ? '' : 's'}</span>
            ${r
              ? `<span class="ct-chip ${e ? 'bad' : w ? 'warn' : 'ok'}">${e} erro${e === 1 ? '' : 's'} · ${w} aviso${w === 1 ? '' : 's'}</span>`
              : entry?.checking
                ? '<span class="ct-chip">conferindo…</span>'
                : '<span class="ct-chip">sem checagem V3</span>'}
          </div>
        </div>
        <div class="ez-hero-actions">
          <button type="button" class="btn btn-ghost btn-sm" data-scene="${escapeHtml(prev?.slug || '')}" ${prev ? '' : 'disabled'}>← Anterior</button>
          <button type="button" class="btn btn-ghost btn-sm" data-scene="${escapeHtml(next?.slug || '')}" ${next ? '' : 'disabled'}>Próxima →</button>
        </div>
      </header>
      <div class="ct-tabs" role="tablist">
        ${TABS.map((tab) => `<button type="button" role="tab" class="${sel.tab === tab.id ? 'on' : ''}" data-tab="${tab.id}">${escapeHtml(tab.label)}</button>`).join('')}
      </div>
      <div class="ct-tab-body">${body}</div>`;
  }

  function paintMain() {
    const slot = root.querySelector('#ct-main');
    if (!slot) return;
    const page = root.querySelector('.ct-page');
    if (page) page.classList.toggle('is-scene', Boolean(sel.scene));
    const prevSearch = slot.querySelector('#ct-search');
    const keepFocus = document.activeElement === prevSearch;
    const caret = keepFocus ? prevSearch.selectionStart : null;
    const scroll = slot.scrollTop;
    slot.innerHTML = !sel.trail
      ? trailsBrowserHtml()
      : sel.scene
        ? sceneHtml()
        : trailHtml();
    if (!sel.trail) slot.scrollTop = scroll;
    else slot.scrollTop = 0;
    bindMain();
    const searchEl = slot.querySelector('#ct-search');
    if (keepFocus && searchEl) {
      searchEl.focus();
      if (caret != null) searchEl.setSelectionRange(caret, caret);
    }
    if (sel.scene && sel.tab === 'entrada') paintEntryPreview();
  }

  /* ─── Ações ───────────────────────────────────────────── */

  function selectShelf(shelfId) {
    if (!shelfId) return;
    sel = { shelf: shelfId, trail: '', scene: '', tab: sel.tab };
    search = '';
    writeHash();
    paintCollections();
    paintMain();
  }

  async function selectTrail(trailId) {
    const loc = locateTrail(tree, trailId);
    sel = {
      shelf: loc?.shelf?.id || sel.shelf,
      trail: trailId,
      scene: '',
      tab: sel.tab,
    };
    writeHash();
    paintCollections();
    paintMain();
    if (!cache.has(trailId)) await loadTrail(trailId);
  }

  function selectScene(slug) {
    if (!slug) return;
    sel = { ...sel, scene: slug };
    writeHash();
    paintMain();
    root.querySelector('#ct-main')?.scrollTo?.({ top: 0 });
  }

  function sceneContext(slug) {
    const entry = cache.get(sel.trail);
    const s = scenesOf(trailById.get(sel.trail)).find((x) => x.slug === slug);
    return {
      sceneQuestions: entry.items.filter(inScene(sel.trail, slug)),
      study: entry.studies.get(slug) || null,
      boss: s?.boss,
    };
  }

  async function afterQuestionChange(slug) {
    try {
      await checkOne(sel.trail, slug);
    } catch (e) {
      cache.get(sel.trail).error = e.message || String(e);
    }
    paintMain();
  }

  function openQuestion(existing, difficulty) {
    const entry = cache.get(sel.trail);
    const t = trailById.get(sel.trail);
    openQuestionStudio({
      existing,
      trails: [...new Set([t, trailById.get(bankOf(sel.trail, sel.scene).trail)])].filter(Boolean),
      items: entry.items,
      defaults: existing ? {} : { ...bankOf(sel.trail, sel.scene), lockPlace: true, difficulty, type: 'true_false' },
      context: sceneContext(sel.scene),
      onSaved: (payload) => {
        const i = entry.items.findIndex((x) => x.id === payload.id);
        if (i >= 0) entry.items[i] = { ...payload };
        else entry.items.push(payload);
        afterQuestionChange(sel.scene);
      },
    });
  }

  async function saveEntry(form) {
    const t = trailById.get(sel.trail);
    const ms = missionOf(t, sel.scene);
    if (!ms) return;
    const prev = { ...ms };
    form.querySelectorAll('[data-e]').forEach((el) => {
      const v = el.value.trim();
      if (v || ms[el.dataset.e] !== undefined) ms[el.dataset.e] = v;
    });
    setLoading(true);
    try {
      await saveDoc(COL.trails, sel.trail, { modules: t.modules });
      showToast('Entrada salva — já vale no app');
      paintMain();
    } catch (e) {
      Object.assign(ms, prev);
      showToast(e.message || 'Erro', 'error');
    } finally {
      setLoading(false);
    }
  }

  function bindMain() {
    const main = root.querySelector('#ct-main');
    main.querySelector('#ct-search')?.addEventListener('input', (e) => {
      search = e.target.value.trim();
      paintMain();
    });
    main.querySelectorAll('[data-new-trail]').forEach((b) => b.addEventListener('click', (e) => {
      e.stopPropagation();
      openCreateTrail(trails, navigate, { category: b.dataset.newTrail });
    }));
    main.querySelectorAll('[data-trail]').forEach((b) => b.addEventListener('click', () => selectTrail(b.dataset.trail)));
    main.querySelectorAll('[data-scene]').forEach((b) => b.addEventListener('click', () => selectScene(b.dataset.scene)));
    const addCard = main.querySelector('[data-new-card]');
    addCard?.addEventListener('click', () => {
      openCardEditor({ cards, shelves, shelf: addCard.dataset.newCard, onSaved: reload });
    });
    const editCard = main.querySelector('[data-edit-card]');
    editCard?.addEventListener('click', () => {
      openCardEditor({ cards, shelves, existing: cards.find((c) => c.id === editCard.dataset.editCard), onSaved: reload });
    });
    main.querySelector('[data-shelf-home]')?.addEventListener('click', () => {
      sel = { ...sel, trail: '', scene: '' };
      writeHash();
      paintCollections();
      paintMain();
    });
    main.querySelector('[data-trail-home]')?.addEventListener('click', () => selectTrail(sel.trail));
    main.querySelector('[data-edit-trail]')?.addEventListener('click', () => navigate?.(`trail:${sel.trail}`));
    main.querySelector('[data-new-scene]')?.addEventListener('click', () => navigate?.(`trail:${sel.trail}:cena`));
    main.querySelector('#ct-only-issues')?.addEventListener('change', (e) => {
      onlyIssues = e.target.checked;
      paintMain();
    });
    main.querySelectorAll('[data-tab]').forEach((b) => b.addEventListener('click', () => {
      sel = { ...sel, tab: b.dataset.tab };
      writeHash();
      paintMain();
    }));
    main.querySelectorAll('[data-edit-q]').forEach((b) => b.addEventListener('click', () => {
      const q = cache.get(sel.trail)?.items.find((x) => x.id === b.dataset.editQ);
      if (q) openQuestion(q);
    }));
    main.querySelectorAll('[data-new-q]').forEach((b) => b.addEventListener('click', () => openQuestion(null, b.dataset.newQ)));
    main.querySelectorAll('[data-del-q]').forEach((b) => b.addEventListener('click', async () => {
      const entry = cache.get(sel.trail);
      const q = entry?.items.find((x) => x.id === b.dataset.delQ);
      if (!q) return;
      if (!(await confirmAction(`Mover ${q.id} para a lixeira? Sai do app agora e fica ${TRASH_DAYS} dias para restaurar.`, { confirmLabel: 'Mover para a lixeira' }))) return;
      try {
        await removeDoc(COL.bank, q.id, { info: { trail: q.trail || sel.trail, section: q.section || '' } });
        entry.items = entry.items.filter((x) => x.id !== q.id);
        await refreshTrash();
        showToast('Movida para a lixeira');
        afterQuestionChange(q.section);
      } catch (e) {
        showToast(e.message || 'Erro', 'error');
      }
    }));
    main.querySelectorAll('[data-restore]').forEach((b) => b.addEventListener('click', async () => {
      const item = trash.find((x) => x.id === b.dataset.restore);
      if (!item) return;
      setLoading(true);
      try {
        const restored = await restoreFromTrash(item);
        const entry = cache.get(item.trail);
        if (entry) entry.items = [...entry.items.filter((x) => x.id !== restored.id), restored];
        await refreshTrash();
        showToast('Pergunta restaurada — já vale no app');
        afterQuestionChange(item.section);
      } catch (e) {
        showToast(e.message || 'Erro', 'error');
      } finally {
        setLoading(false);
      }
    }));
    main.querySelectorAll('[data-purge]').forEach((b) => b.addEventListener('click', async () => {
      if (!(await confirmAction(`Excluir ${b.dataset.purge} de vez? Não dá para restaurar depois.`))) return;
      await purgeFromTrash(b.dataset.purge);
      await refreshTrash();
      paintMain();
    }));
    main.querySelector('[data-edit-study]')?.addEventListener('click', () => {
      const entry = cache.get(sel.trail);
      const slug = sel.scene;
      openStudyEditor(entry.studies.get(slug) || null, {
        slug: bankOf(sel.trail, slug).section,
        onSaved: (next) => {
          entry.studies.set(slug, next);
          afterQuestionChange(slug);
        },
      });
    });
    const form = main.querySelector('#ct-entry-form');
    if (form) {
      form.addEventListener('submit', (e) => {
        e.preventDefault();
        saveEntry(form);
      });
      form.querySelectorAll('[data-e]').forEach((el) => el.addEventListener('input', paintEntryPreview));
      form.querySelector('[data-hook-jfaal]')?.addEventListener('click', async () => {
        const ref = form.querySelector('[data-e="hookRef"]').value;
        try {
          await loadJfaal();
          const text = jfaal.passageText(ref);
          if (!text) throw new Error(`Referência inválida: “${ref}” (um capítulo, faixa contínua)`);
          form.querySelector('[data-e="hookVerse"]').value = text;
          paintEntryPreview();
        } catch (e) {
          showToast(e.message, 'error');
        }
      });
    }
  }

  const reload = () => renderContentPage(root, navigate);

  root.innerHTML = `
    <div class="ct-page">
      <aside class="ct-cols-pane">
        <header class="ct-tree-head">
          <h2>Coleções</h2>
        </header>
        <div class="ct-cols" id="ct-cols"></div>
      </aside>
      <section class="ct-main" id="ct-main"></section>
    </div>`;

  root.querySelector('#ct-cols').addEventListener('click', (e) => {
    const editShelf = e.target.closest('[data-edit-shelf]');
    if (editShelf) {
      e.preventDefault();
      e.stopPropagation();
      openShelfEditor({ shelves, existing: shelves.find((x) => x.id === editShelf.dataset.editShelf), onSaved: reload });
      return;
    }
    if (e.target.closest('[data-new-shelf]')) {
      openCardEditor({ cards, shelves, shelf: NEW_DOOR, onSaved: reload });
      return;
    }
    const card = e.target.closest('[data-shelf]');
    if (card) selectShelf(card.dataset.shelf);
  });

  await refreshTrash();
  paintCollections();
  paintMain();
  writeHash();
  if (sel.trail) await loadTrail(sel.trail);
}
