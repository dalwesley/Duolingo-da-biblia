/**
 * Perguntas: revisor do banco por trilha → cena.
 *
 * Carrega só a trilha escolhida (não o banco inteiro), confere cada cena com
 * as regras do `v3:validate` contra a JFAAL e abre o editor na pergunta.
 */
import { COL, getDocById, listCollection, listWhere, removeDoc, TRASH_DAYS } from './db.js';
import { DIFFS, V3_GESTURES, gestureMeta } from './content-preview.js';
import { openQuestionStudio } from './question-studio.js';
import { checkScene, isV3Scene } from './v3-check.js';
import { confirmAction, escapeHtml, showToast } from './ui.js';

const STORE_KEY = 'stway.admin.bank.trail';
const MODE_ORDER = { semente: 0, caminhada: 1, profundezas: 2 };
const MODE_SHORT = { semente: 'Obs', caminhada: 'Comp', profundezas: 'Interp' };

function readStore() {
  try {
    return localStorage.getItem(STORE_KEY) || '';
  } catch {
    return '';
  }
}

function writeStore(v) {
  try {
    localStorage.setItem(STORE_KEY, v);
  } catch {
    /* sem storage: tudo bem */
  }
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

function scenesOf(trail) {
  const out = [];
  for (const mod of trail?.modules || []) {
    for (const ms of mod.missions || []) {
      if (ms.slug) out.push({ slug: ms.slug, title: ms.title || ms.slug, boss: ms.type === 'boss', module: mod.title || '' });
    }
  }
  return out;
}

function sortQuestions(list) {
  return [...list].sort((a, b) => {
    const m = (MODE_ORDER[a.difficulty] ?? 9) - (MODE_ORDER[b.difficulty] ?? 9);
    return m || String(a.id).localeCompare(String(b.id));
  });
}

export async function renderBankPage(root, navigate) {
  root.innerHTML = `<div class="ez-page"><div class="ez-skeleton">Carregando trilhas…</div></div>`;
  const trails = (await listCollection(COL.trails)).filter((t) => scenesOf(t).length);
  trails.sort((a, b) => String(a.title || a.id).localeCompare(String(b.title || b.id), 'pt-BR'));

  let trailId = readStore();
  if (!trails.some((t) => (t.slug || t.id) === trailId)) trailId = trails[0] ? trails[0].slug || trails[0].id : '';
  let items = [];
  let studies = new Map();
  let results = new Map();
  let checking = false;
  let checkError = '';
  let filterMode = '';
  let filterType = '';
  let onlyIssues = false;
  let onlyEdited = false;
  let search = '';
  let loadToken = 0;

  const trail = () => trails.find((t) => (t.slug || t.id) === trailId);

  async function loadTrail() {
    const token = ++loadToken;
    items = [];
    results = new Map();
    checkError = '';
    paint(true);
    const t = trail();
    if (!t) return;
    const scenes = scenesOf(t);
    const [qs, st] = await Promise.all([
      listWhere(COL.bank, 'trail', trailId),
      Promise.all(scenes.map((s) => getDocById(COL.studies, s.slug).catch(() => null))),
    ]);
    if (token !== loadToken) return;
    items = qs;
    studies = new Map(scenes.map((s, i) => [s.slug, st[i]]));
    paint();
    runChecks(token);
  }

  async function runChecks(token = loadToken) {
    const t = trail();
    if (!t) return;
    checking = true;
    paintSummary();
    try {
      for (const s of scenesOf(t)) {
        const qs = items.filter((q) => q.section === s.slug);
        if (!qs.length || !isV3Scene(qs)) continue;
        const r = await checkScene({ trail: trailId, section: s.slug, questions: qs, study: studies.get(s.slug), boss: s.boss });
        if (token !== loadToken) return;
        results.set(s.slug, r);
      }
    } catch (e) {
      checkError = e.message || String(e);
    }
    checking = false;
    if (token === loadToken) paint();
  }

  function issuesFor(q) {
    return results.get(q.section)?.byQuestion.get(q.id) || null;
  }

  function matches(q) {
    if (filterMode && q.difficulty !== filterMode) return false;
    if (filterType && q.type !== filterType) return false;
    if (onlyEdited && !q.panelEditedAt) return false;
    if (onlyIssues) {
      const i = issuesFor(q);
      if (!i || (!i.errors.length && !i.warnings.length)) return false;
    }
    if (search) {
      const hay = `${q.id} ${promptOf(q)} ${answerOf(q)} ${q.verseRef || ''}`.toLowerCase();
      if (!hay.includes(search.toLowerCase())) return false;
    }
    return true;
  }

  function totals() {
    let errors = 0;
    let warnings = 0;
    for (const r of results.values()) {
      errors += r.errors.length;
      warnings += r.warnings.length;
    }
    const v3Scenes = results.size;
    const edited = items.filter((q) => q.panelEditedAt).length;
    return { errors, warnings, v3Scenes, edited };
  }

  function summaryHtml() {
    if (!items.length) return '';
    const t = totals();
    const pull = t.edited
      ? `<span class="rv-pill warn" title="npm run v3:pull -- --trail ${escapeHtml(trailId)} --apply">${t.edited} editada(s) no painel — falta v3:pull</span>`
      : '';
    const check = checking
      ? '<span class="rv-pill">Conferindo com a JFAAL…</span>'
      : checkError
        ? `<span class="rv-pill bad">Checagem falhou: ${escapeHtml(checkError)}</span>`
        : t.v3Scenes
          ? `<span class="rv-pill ${t.errors ? 'bad' : 'ok'}">${t.errors} erro(s)</span><span class="rv-pill ${t.warnings ? 'warn' : ''}">${t.warnings} aviso(s)</span>`
          : '<span class="rv-pill">Banco antigo (V2): sem checagem V3</span>';
    return `<span class="rv-pill">${items.length} perguntas</span>${check}${pull}`;
  }

  function paintSummary() {
    const slot = root.querySelector('#rv-summary');
    if (slot) slot.innerHTML = summaryHtml();
  }

  function issueList(list, cls) {
    return list.map((m) => `<li class="${cls}">${cls === 'bad' ? '✗' : '!'} ${escapeHtml(m)}</li>`).join('');
  }

  function rowHtml(q) {
    const g = gestureMeta(q.type);
    const iss = issuesFor(q);
    const nErr = iss?.errors.length || 0;
    const nWarn = iss?.warnings.length || 0;
    return `
      <div class="rv-row ${nErr ? 'has-err' : nWarn ? 'has-warn' : ''}">
        <button type="button" class="rv-row-main" data-edit="${escapeHtml(q.id)}" title="${escapeHtml(q.id)}">
          <span class="rv-g" title="${escapeHtml(g.label)}">${escapeHtml(g.icon || '•')}</span>
          <span class="rv-mode m-${escapeHtml(q.difficulty || '')}">${escapeHtml(MODE_SHORT[q.difficulty] || q.difficulty || '—')}</span>
          <span class="rv-text">
            <strong>${escapeHtml(promptOf(q) || q.template || '(sem texto)')}</strong>
            <small>✓ ${escapeHtml(answerOf(q) || '—')}${q.hint ? ` · dica: ${escapeHtml(q.hint)}` : ''}</small>
          </span>
          <span class="rv-badges">
            ${q.panelEditedAt ? '<span class="rv-pill warn sm" title="Editada no painel">editada</span>' : ''}
            ${nErr ? `<span class="rv-pill bad sm">${nErr} ✗</span>` : ''}
            ${nWarn ? `<span class="rv-pill warn sm">${nWarn} !</span>` : ''}
          </span>
        </button>
        <button type="button" class="btn btn-ghost btn-sm" data-del="${escapeHtml(q.id)}" title="Excluir">✕</button>
        ${nErr || nWarn ? `<ul class="rv-issues">${issueList(iss.errors, 'bad')}${issueList(iss.warnings, 'warn')}</ul>` : ''}
      </div>`;
  }

  function sceneHtml(s, i, qs) {
    const r = results.get(s.slug);
    const shown = sortQuestions(qs.filter(matches));
    const sceneIssues = r ? [...r.scene.errors] : [];
    const studyIssues = r ? r.study.errors : [];
    if ((onlyIssues || onlyEdited || filterMode || filterType || search) && !shown.length && !(onlyIssues && (sceneIssues.length || studyIssues.length))) return '';
    const byMode = DIFFS.map((d) => `${MODE_SHORT[d.id]} ${qs.filter((q) => q.difficulty === d.id).length}`).join(' · ');
    return `
      <section class="rv-scene">
        <header class="rv-scene-head">
          <div>
            <p class="rv-scene-kicker">${String(i + 1).padStart(2, '0')}${s.boss ? ' · Travessia' : ''} · <code>${escapeHtml(s.slug)}</code></p>
            <h3>${escapeHtml(s.title)}</h3>
            <p class="rv-scene-meta">${qs.length ? byMode : 'sem perguntas'}${r ? '' : qs.length ? ' · V2' : ''}</p>
          </div>
          <button type="button" class="btn btn-secondary btn-sm" data-new="${escapeHtml(s.slug)}">+ Pergunta</button>
        </header>
        ${sceneIssues.length || studyIssues.length
          ? `<ul class="rv-issues scene">${issueList(sceneIssues, 'bad')}${studyIssues.map((m) => `<li class="bad">✗ estudo: ${escapeHtml(m)}</li>`).join('')}</ul>`
          : ''}
        <div class="rv-rows">${shown.map(rowHtml).join('')}</div>
      </section>`;
  }

  function paint(loading = false) {
    const t = trail();
    const scenes = scenesOf(t);
    const known = new Set(scenes.map((s) => s.slug));
    const orphans = items.filter((q) => !known.has(q.section));
    const types = [...new Set([...V3_GESTURES, ...items.map((q) => q.type)])].filter(Boolean);

    root.innerHTML = `
      <div class="ez-page wide">
        <header class="ez-hero">
          <div>
            <h1>Perguntas</h1>
            <p class="ez-lead">Revise por trilha e cena. A checagem usa as mesmas regras do <code>v3:validate</code>, contra a JFAAL.</p>
          </div>
        </header>

        <div class="ez-toolbar wrap">
          <select id="f-trail" class="ez-select rv-trail-select">
            ${trails.map((x) => {
              const id = x.slug || x.id;
              return `<option value="${escapeHtml(id)}" ${id === trailId ? 'selected' : ''}>${escapeHtml(x.title || id)}${x.comingSoon ? ' (em breve)' : ''}</option>`;
            }).join('')}
          </select>
          <input type="search" id="f-search" class="ez-search" placeholder="Buscar texto, resposta, ref. ou id…" value="${escapeHtml(search)}" />
          <select id="f-mode" class="ez-select">
            <option value="">Todos os modos</option>
            ${DIFFS.map((d) => `<option value="${d.id}" ${filterMode === d.id ? 'selected' : ''}>${escapeHtml(d.label)}</option>`).join('')}
          </select>
          <label class="ez-check"><input type="checkbox" id="f-issues" ${onlyIssues ? 'checked' : ''}/> <span>Só com problema</span></label>
          <label class="ez-check"><input type="checkbox" id="f-edited" ${onlyEdited ? 'checked' : ''}/> <span>Editadas no painel</span></label>
        </div>
        <div class="ez-pills">
          <button type="button" class="ez-pill ${!filterType ? 'active' : ''}" data-type="">Todos os gestos</button>
          ${types.map((id) => `<button type="button" class="ez-pill ${filterType === id ? 'active' : ''}" data-type="${escapeHtml(id)}">${escapeHtml(gestureMeta(id).label)}</button>`).join('')}
        </div>
        <div class="rv-summary" id="rv-summary">${summaryHtml()}</div>

        ${loading
          ? '<div class="ez-skeleton">Carregando perguntas…</div>'
          : !t
            ? '<div class="ez-empty"><h2>Nenhuma trilha com cenas</h2></div>'
            : `${scenes.map((s, i) => sceneHtml(s, i, items.filter((q) => q.section === s.slug))).join('')}
               ${orphans.length
                 ? `<section class="rv-scene"><header class="rv-scene-head"><div><h3>Fora das cenas da trilha</h3><p class="rv-scene-meta">${orphans.length} pergunta(s) com <code>section</code> que não existe na trilha</p></div></header><div class="rv-rows">${sortQuestions(orphans.filter(matches)).map(rowHtml).join('')}</div></section>`
                 : ''}`}
      </div>`;
    bind();
  }

  function openEditor(existing, section) {
    const t = trail();
    const s = scenesOf(t).find((x) => x.slug === (existing?.section || section));
    const sceneQuestions = items.filter((q) => q.section === (existing?.section || section));
    const mode = filterMode || 'semente';
    openQuestionStudio({
      existing,
      trails: t ? [t] : [],
      items,
      defaults: existing ? {} : { trail: trailId, section, lockPlace: true, difficulty: mode, type: 'true_false' },
      context: { sceneQuestions, study: studies.get(s?.slug || section) || null, boss: s?.boss },
      onSaved: async (payload) => {
        const i = items.findIndex((x) => x.id === payload.id);
        // O payload é o documento inteiro: substitui (campos removidos somem).
        if (i >= 0) items[i] = { ...payload };
        else items.push(payload);
        const sec = payload.section;
        const scene = scenesOf(trail()).find((x) => x.slug === sec);
        const qs = items.filter((q) => q.section === sec);
        if (scene && isV3Scene(qs)) {
          try {
            results.set(sec, await checkScene({ trail: trailId, section: sec, questions: qs, study: studies.get(sec), boss: scene.boss }));
          } catch (e) {
            checkError = e.message || String(e);
          }
        }
        paint();
      },
    });
  }

  function bind() {
    root.querySelector('#f-trail')?.addEventListener('change', (e) => {
      trailId = e.target.value;
      writeStore(trailId);
      loadTrail();
    });
    root.querySelector('#f-search')?.addEventListener('input', (e) => {
      search = e.target.value;
      paint();
      const el = root.querySelector('#f-search');
      el?.focus();
      el?.setSelectionRange(el.value.length, el.value.length);
    });
    root.querySelector('#f-mode')?.addEventListener('change', (e) => {
      filterMode = e.target.value;
      paint();
    });
    root.querySelector('#f-issues')?.addEventListener('change', (e) => {
      onlyIssues = e.target.checked;
      paint();
    });
    root.querySelector('#f-edited')?.addEventListener('change', (e) => {
      onlyEdited = e.target.checked;
      paint();
    });
    root.querySelectorAll('[data-type]').forEach((btn) => {
      btn.addEventListener('click', () => {
        filterType = btn.dataset.type;
        paint();
      });
    });
    root.querySelectorAll('[data-edit]').forEach((btn) => {
      btn.addEventListener('click', () => {
        const q = items.find((x) => x.id === btn.dataset.edit);
        if (q) openEditor(q);
      });
    });
    root.querySelectorAll('[data-new]').forEach((btn) => {
      btn.addEventListener('click', () => openEditor(null, btn.dataset.new));
    });
    root.querySelectorAll('[data-del]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const q = items.find((x) => x.id === btn.dataset.del);
        if (!q) return;
        if (!(await confirmAction(`Mover ${q.id} para a lixeira? Sai do app agora e fica ${TRASH_DAYS} dias para restaurar.`, { confirmLabel: 'Mover para a lixeira' }))) return;
        try {
          await removeDoc(COL.bank, q.id, { info: { trail: q.trail || trailId, section: q.section || '' } });
          items = items.filter((x) => x.id !== q.id);
          showToast('Movida para a lixeira');
          paint();
        } catch (e) {
          showToast(e.message || 'Erro', 'error');
        }
      });
    });
    root.querySelectorAll('[data-route]').forEach((a) => {
      a.addEventListener('click', (e) => {
        e.preventDefault();
        navigate?.(a.dataset.route);
      });
    });
  }

  await loadTrail();
}
