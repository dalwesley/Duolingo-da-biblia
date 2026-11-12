/**
 * Estudos: a matéria-prima de cada cena (SPEC_V3 §2) — fatos, termos,
 * estrutura, relações, textos cruzados, leituras erradas — além dos campos do
 * preparo que o app mostra. Confere com as regras do `v3:validate`.
 */
import { COL, listCollection, listWhere, removeDoc, saveDoc } from './db.js';
import { checkScene, isV3Scene } from './v3-check.js';
import { jfaal, loadJfaal } from './jfaal-browser.js';
import { confirmAction, escapeHtml, hideModalElement, setLoading, showModalElement, showToast } from './ui.js';

const RELATION_KINDS = ['causa', 'contraste', 'propósito', 'sequência', 'resultado'];

/** Listas de objetos do estudo V3: [campo, rótulo, colunas]. */
const LISTS = [
  ['passages', 'Trechos da cena (o principal primeiro)', [['ref', 'Referência', 'jfaal'], ['text', 'Texto JFAAL', 'area']]],
  ['facts', 'Fatos (4 a 6)', [['text', 'Fato literal'], ['evidenceRef', 'Referência'], ['evidenceSpan', 'Trecho exato que prova']]],
  ['keyTerms', 'Termos-chave (2 a 3)', [['term', 'Termo (aparece no texto)'], ['gloss', 'Explicação']]],
  ['structure', 'Estrutura (3 ou 4 movimentos, em ordem)', [['label', 'Rótulo próprio'], ['evidenceRef', 'Referência']]],
  ['relations', 'Relações (2 ou 3)', [['kind', 'Tipo', 'kind'], ['text', 'Relação'], ['marker', 'Marcador no texto (ou vazio)'], ['evidenceRef', 'Referência']]],
  ['crossRefs', 'Textos cruzados (2 ou 3)', [['ref', 'Referência'], ['text', 'Trecho JFAAL', 'area'], ['bridge', 'Ponte (até 6 palavras)']]],
  ['misreadings', 'Leituras erradas (3)', [['text', 'Leitura errada real'], ['why', 'Por que o texto não sustenta']]],
  ['relatedVerses', 'Conexões no preparo (app atual)', [['reference', 'Referência'], ['reason', 'Motivo']]],
];

const TEXT_FIELDS = [
  ['context', 'Contexto (até 300, sem spoiler)', 'area', 300],
  ['keyword', 'Palavra da cena (até 3 palavras)'],
  ['keywordGloss', 'Explicação da palavra (1 frase)'],
  ['focusQuestion', 'Pergunta de reflexão (tom “você”)'],
  ['centralInsight', 'Frase “Hoje” (igual à da cena)'],
  ['anchorQuestion', 'Pergunta âncora (D+2, sem ver o treino)'],
];

function isV3Study(s) {
  return Array.isArray(s?.facts) && s.facts.length > 0;
}

function cellInput(list, i, [key, label, kind], value) {
  const name = `${list}.${i}.${key}`;
  if (kind === 'area') {
    return `<textarea data-l="${name}" rows="2" placeholder="${escapeHtml(label)}">${escapeHtml(value || '')}</textarea>`;
  }
  if (kind === 'kind') {
    return `<select data-l="${name}">
      <option value="">${escapeHtml(label)}</option>
      ${RELATION_KINDS.map((k) => `<option value="${k}" ${value === k ? 'selected' : ''}>${k}</option>`).join('')}
    </select>`;
  }
  const btn = kind === 'jfaal' ? `<button type="button" class="btn btn-ghost btn-sm" data-jfaal-row="${list}.${i}">JFAAL</button>` : '';
  return `<span class="st-cell-row"><input data-l="${name}" value="${escapeHtml(value ?? '')}" placeholder="${escapeHtml(label)}" />${btn}</span>`;
}

function listEditor([list, title, cols], rows) {
  const items = rows?.length ? rows : [];
  return `
    <section class="qs-block st-list" data-list="${list}">
      <p class="qs-block-title">${escapeHtml(title)} <small>${items.length}</small></p>
      ${items.map((row, i) => `
        <div class="st-row cols-${cols.length}">
          ${cols.map((c) => cellInput(list, i, c, row?.[c[0]])).join('')}
          <button type="button" class="opt-remove" data-del-row="${list}.${i}" aria-label="Remover">×</button>
        </div>`).join('')}
      <button type="button" class="opt-add" data-add-row="${list}">+ Linha</button>
    </section>`;
}

export async function renderStudiesPage(root) {
  root.innerHTML = `<div class="ez-page wide"><div class="ez-skeleton">Carregando…</div></div>`;
  let items = await listCollection(COL.studies, 'slug');
  let search = '';
  let onlyV3 = false;
  let onlyEdited = false;

  function filtered() {
    const q = search.toLowerCase();
    return items.filter((s) => {
      if (onlyV3 && !isV3Study(s)) return false;
      if (onlyEdited && !s.panelEditedAt) return false;
      if (!q) return true;
      return `${s.id} ${s.passageRef || ''} ${s.keyword || ''}`.toLowerCase().includes(q);
    });
  }

  function onSaved(next) {
    const idx = items.findIndex((x) => x.id === next.id);
    if (idx >= 0) items[idx] = { ...items[idx], ...next };
    else items.push(next);
    render();
  }

  function render() {
    const list = filtered();
    root.innerHTML = `
      <div class="ez-page wide">
        <header class="ez-hero">
          <div>
            <h1>Estudos</h1>
            <p class="ez-lead">A matéria-prima de cada cena. As perguntas V3 saem daqui. ${items.length} estudos · ${items.filter(isV3Study).length} V3.</p>
          </div>
          <div class="ez-hero-actions"><button type="button" class="btn btn-secondary" id="btn-new">+ Estudo</button></div>
        </header>
        <div class="ez-toolbar wrap">
          <input id="f-search" class="ez-search" placeholder="Buscar slug, passagem, palavra…" value="${escapeHtml(search)}" />
          <label class="ez-check"><input type="checkbox" id="f-v3" ${onlyV3 ? 'checked' : ''}/> <span>Só V3</span></label>
          <label class="ez-check"><input type="checkbox" id="f-edited" ${onlyEdited ? 'checked' : ''}/> <span>Editados no painel</span></label>
        </div>
        <div class="table-wrap card">
          <table class="data-table">
            <thead><tr><th>Cena</th><th>Passagem</th><th>Palavra</th><th></th><th></th></tr></thead>
            <tbody>
              ${list.slice(0, 300).map((s) => `
                <tr>
                  <td><code>${escapeHtml(s.id)}</code></td>
                  <td>${escapeHtml(s.passageRef || '')}</td>
                  <td>${escapeHtml(s.keyword || '')}</td>
                  <td>${isV3Study(s) ? '<span class="rv-pill ok sm">V3</span>' : '<span class="rv-pill sm">V2</span>'}${s.panelEditedAt ? ' <span class="rv-pill warn sm">editado</span>' : ''}</td>
                  <td class="td-actions">
                    <button type="button" class="btn btn-sm btn-secondary" data-edit="${escapeHtml(s.id)}">Editar</button>
                    <button type="button" class="btn btn-sm btn-ghost" data-del="${escapeHtml(s.id)}">Excluir</button>
                  </td>
                </tr>`).join('') || '<tr><td colspan="5">Nenhum estudo.</td></tr>'}
            </tbody>
          </table>
          ${list.length > 300 ? `<p class="ez-hint">Mostrando 300 de ${list.length}. Refine a busca.</p>` : ''}
        </div>
      </div>`;

    root.querySelector('#f-search')?.addEventListener('input', (e) => {
      search = e.target.value;
      render();
      const el = root.querySelector('#f-search');
      el?.focus();
      el?.setSelectionRange(el.value.length, el.value.length);
    });
    root.querySelector('#f-v3')?.addEventListener('change', (e) => {
      onlyV3 = e.target.checked;
      render();
    });
    root.querySelector('#f-edited')?.addEventListener('change', (e) => {
      onlyEdited = e.target.checked;
      render();
    });
    root.querySelector('#btn-new')?.addEventListener('click', () => openStudyEditor(null, { onSaved }));
    root.querySelectorAll('[data-edit]').forEach((btn) => {
      btn.addEventListener('click', () => openStudyEditor(items.find((x) => x.id === btn.dataset.edit), { onSaved }));
    });
    root.querySelectorAll('[data-del]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        if (!(await confirmAction(`Excluir o estudo ${btn.dataset.del}?`))) return;
        await removeDoc(COL.studies, btn.dataset.del);
        items = items.filter((x) => x.id !== btn.dataset.del);
        showToast('Removido');
        render();
      });
    });
  }

  render();
}

/**
 * Editor do estudo em modal. `slug` pré-preenche um estudo novo; `onSaved`
 * recebe o documento gravado.
 */
export function openStudyEditor(existing, { slug = '', onSaved } = {}) {
  const modal = document.getElementById('modal');
  const { updatedAt: _u, panelEditedAt: _p, ...existingData } = existing || {};
  const draft = structuredClone(existing ? { ...existingData } : { id: slug, reflectionPrompts: [] });
  for (const [k] of LISTS) if (!Array.isArray(draft[k])) draft[k] = [];
  let scene = null;
  let checkTimer = null;

  function readForm() {
    const v = (id) => modal.querySelector(`[data-s="${id}"]`);
    if (v('slug') && !existing) draft.id = v('slug').value.trim();
    for (const k of ['passageRef', 'passageText', ...TEXT_FIELDS.map((f) => f[0])]) {
      if (v(k)) draft[k] = v(k).value;
    }
    if (v('reflectionPrompts')) {
      draft.reflectionPrompts = v('reflectionPrompts').value.split('\n').map((l) => l.trim()).filter(Boolean);
    }
    modal.querySelectorAll('[data-l]').forEach((el) => {
      const [list, i, key] = el.dataset.l.split('.');
      const row = draft[list][Number(i)] || (draft[list][Number(i)] = {});
      row[key] = el.value;
    });
  }

  function cleanLists() {
    const out = {};
    for (const [list, , cols] of LISTS) {
      out[list] = (draft[list] || [])
        .map((row) => {
          const r = { ...row };
          for (const [k] of cols) {
            r[k] = String(r[k] ?? '').trim();
            if (list === 'relations' && k === 'marker' && !r[k]) r[k] = null;
          }
          return r;
        })
        .filter((row) => cols.some(([k]) => row[k]));
    }
    return out;
  }

  function payload() {
    const p = { slug: draft.id };
    for (const k of ['passageRef', 'passageText', ...TEXT_FIELDS.map((f) => f[0])]) {
      const val = String(draft[k] || '').trim();
      // Campo vazio só vai se o estudo já tinha (não cria campo novo vazio).
      if (val || (existing && k in existing)) p[k] = val;
    }
    p.reflectionPrompts = draft.reflectionPrompts || [];
    const lists = cleanLists();
    for (const [list] of LISTS) {
      // Não cria lista vazia em estudo V2 que nunca teve o campo.
      if (lists[list].length || (existing && Array.isArray(existing[list]))) p[list] = lists[list];
    }
    return p;
  }

  async function runCheck() {
    const slot = modal.querySelector('#st-check');
    if (!slot) return;
    if (!draft.id) {
      slot.innerHTML = '';
      return;
    }
    slot.innerHTML = '<p class="qe-check-head">Conferindo…</p>';
    try {
      if (!scene) scene = await listWhere(COL.bank, 'section', draft.id);
      if (!scene.length || !isV3Scene(scene)) {
        slot.innerHTML = '<p class="qe-check-head">Cena sem banco V3: checagem V3 não se aplica.</p>';
        return;
      }
      const r = await checkScene({ trail: scene[0].trail, section: draft.id, questions: scene, study: { ...existing, ...payload() } });
      const { errors, warnings } = r.study;
      slot.innerHTML = `
        <p class="qe-check-head ${errors.length ? 'bad' : warnings.length ? 'warn' : 'ok'}">Checagem V3 do estudo · ${errors.length || warnings.length ? `${errors.length} erro(s), ${warnings.length} aviso(s)` : 'tudo certo'}</p>
        <ul class="qe-check-list">
          ${errors.map((m) => `<li class="bad">✗ ${escapeHtml(m)}</li>`).join('')}
          ${warnings.map((m) => `<li class="warn">! ${escapeHtml(m)}</li>`).join('')}
        </ul>`;
    } catch (e) {
      slot.innerHTML = `<p class="qe-check-head bad">Checagem indisponível: ${escapeHtml(e.message || String(e))}</p>`;
    }
  }

  function scheduleCheck() {
    clearTimeout(checkTimer);
    checkTimer = setTimeout(runCheck, 400);
  }

  function close() {
    clearTimeout(checkTimer);
    hideModalElement(modal);
    document.removeEventListener('keydown', onEsc);
  }
  function onEsc(e) {
    if (e.key === 'Escape') close();
  }

  function textField([k, label, kind, max]) {
    const value = draft[k] || '';
    const control = kind === 'area'
      ? `<textarea data-s="${k}" rows="3">${escapeHtml(value)}</textarea>`
      : `<input data-s="${k}" value="${escapeHtml(value)}" />`;
    return `<label class="ez-field"><span class="ez-label">${escapeHtml(label)}${max ? ` <span class="qe-count">${String(value).length}/${max}</span>` : ''}</span>${control}</label>`;
  }

  function paint() {
    modal.innerHTML = `
      <div class="modal-backdrop qs-backdrop">
        <div class="modal-card card qs-modal st-modal" role="dialog" aria-modal="true">
          <header class="qs-head">
            <div>
              <p class="simple-kicker">${existing ? 'Editar estudo' : 'Novo estudo'}</p>
              <h2>${escapeHtml(draft.id || 'Estudo')}</h2>
            </div>
            <button type="button" class="modal-close" aria-label="Fechar">×</button>
          </header>
          <div class="st-layout">
            <div class="qs-form">
              ${existing ? '' : `<label class="ez-field"><span class="ez-label">Slug da cena</span><input data-s="slug" value="${escapeHtml(draft.id)}" /></label>`}
              <div class="qe-note v3">A fonte é o arquivo local da cena. A edição fica marcada; antes do próximo publish rode <code>npm run v3:pull -- --trail &lt;trilha&gt; --apply</code>.</div>
              <section class="qs-block">
                <p class="qs-block-title">Trecho principal</p>
                <div class="qe-ref-row">
                  <label class="ez-field"><span class="ez-label">Referência (um capítulo, até 6 versos)</span><input data-s="passageRef" value="${escapeHtml(draft.passageRef || '')}" /></label>
                  <button type="button" class="btn btn-secondary btn-sm" data-jfaal-main>Puxar da JFAAL</button>
                </div>
                <label class="ez-field"><span class="ez-label">Texto JFAAL</span><textarea data-s="passageText" rows="3">${escapeHtml(draft.passageText || '')}</textarea></label>
              </section>
              <section class="qs-block">
                <p class="qs-block-title">Preparo</p>
                ${TEXT_FIELDS.map(textField).join('')}
                <label class="ez-field"><span class="ez-label">Rótulos de reflexão (3, um por linha)</span><textarea data-s="reflectionPrompts" rows="3">${escapeHtml((draft.reflectionPrompts || []).join('\n'))}</textarea></label>
              </section>
              ${LISTS.map((l) => listEditor(l, draft[l[0]])).join('')}
            </div>
            <aside class="st-aside"><div class="qe-check" id="st-check"></div></aside>
          </div>
          <div class="btn-row qs-actions">
            <button type="button" class="btn btn-secondary" id="cancel">Cancelar</button>
            <button type="button" class="btn btn-primary" id="st-save">Salvar</button>
          </div>
        </div>
      </div>`;
    showModalElement(modal);
    bind();
    runCheck();
  }

  async function jfaalText(ref) {
    await loadJfaal();
    const t = jfaal.passageText(ref);
    if (!t) throw new Error(`Referência inválida: “${ref || ''}”`);
    return t;
  }

  function bind() {
    document.removeEventListener('keydown', onEsc);
    document.addEventListener('keydown', onEsc);
    modal.querySelector('.modal-close')?.addEventListener('click', close);
    modal.querySelector('#cancel')?.addEventListener('click', close);
    modal.querySelectorAll('[data-s], [data-l]').forEach((el) => {
      el.addEventListener('input', () => {
        readForm();
        scheduleCheck();
      });
    });
    modal.querySelectorAll('[data-add-row]').forEach((btn) => {
      btn.addEventListener('click', () => {
        readForm();
        draft[btn.dataset.addRow].push({});
        paint();
      });
    });
    modal.querySelectorAll('[data-del-row]').forEach((btn) => {
      btn.addEventListener('click', () => {
        readForm();
        const [list, i] = btn.dataset.delRow.split('.');
        draft[list].splice(Number(i), 1);
        paint();
      });
    });
    modal.querySelector('[data-jfaal-main]')?.addEventListener('click', async () => {
      readForm();
      try {
        draft.passageText = await jfaalText(draft.passageRef);
        paint();
      } catch (e) {
        showToast(e.message, 'error');
      }
    });
    modal.querySelectorAll('[data-jfaal-row]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        readForm();
        const [list, i] = btn.dataset.jfaalRow.split('.');
        const row = draft[list][Number(i)];
        try {
          row.text = await jfaalText(row.ref);
          paint();
        } catch (e) {
          showToast(e.message, 'error');
        }
      });
    });
    modal.querySelector('#st-save')?.addEventListener('click', async () => {
      readForm();
      if (!draft.id) {
        showToast('Slug obrigatório', 'error');
        return;
      }
      const p = payload();
      setLoading(true);
      try {
        await saveDoc(COL.studies, draft.id, p);
        showToast('Estudo salvo');
        close();
        onSaved?.({ ...existingData, id: draft.id, ...p, panelEditedAt: new Date() });
      } catch (e) {
        showToast(e.message || 'Erro', 'error');
      } finally {
        setLoading(false);
      }
    });
  }

  paint();
}
