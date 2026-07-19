import { COL, listCollection, removeDoc, saveDoc } from './db.js';
import { confirmAction, escapeHtml, setLoading, showToast } from './ui.js';

export async function renderStudiesPage(root) {
  root.innerHTML = `<div class="page-header"><h1>Estudos</h1></div><div class="card"><p>Carregando…</p></div>`;
  let items = await listCollection(COL.studies);
  let search = '';

  function filtered() {
    if (!search) return items;
    const q = search.toLowerCase();
    return items.filter((s) => `${s.id} ${s.passageRef} ${s.keyword}`.toLowerCase().includes(q));
  }

  function render() {
    const list = filtered();
    root.innerHTML = `
      <div class="page-header row-between">
        <div>
          <h1>Estudos (preparo)</h1>
          <p class="page-sub">Texto do preparo / reflexão por slug do passo</p>
        </div>
        <button type="button" class="btn btn-primary" id="btn-new">+ Estudo</button>
      </div>
      <div class="card filters-bar">
        <input id="f-search" placeholder="Buscar slug, passagem…" value="${escapeHtml(search)}" />
      </div>
      <div class="card">
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr><th>Slug</th><th>Passagem</th><th>Palavra-chave</th><th></th></tr></thead>
            <tbody>
              ${list.map((s) => `
                <tr>
                  <td><code>${escapeHtml(s.id)}</code></td>
                  <td>${escapeHtml(s.passageRef || '')}</td>
                  <td>${escapeHtml(s.keyword || '')}</td>
                  <td class="td-actions">
                    <button type="button" class="btn btn-sm btn-secondary" data-edit="${escapeHtml(s.id)}">Editar</button>
                    <button type="button" class="btn btn-sm btn-danger" data-del="${escapeHtml(s.id)}">Excluir</button>
                  </td>
                </tr>`).join('') || '<tr><td colspan="4">Nenhum estudo.</td></tr>'}
            </tbody>
          </table>
        </div>
      </div>`;

    root.querySelector('#f-search')?.addEventListener('input', (e) => {
      search = e.target.value;
      render();
      root.querySelector('#f-search')?.focus();
    });
    root.querySelector('#btn-new')?.addEventListener('click', () => openEditor(null));
    root.querySelectorAll('[data-edit]').forEach((btn) => {
      const s = items.find((x) => x.id === btn.dataset.edit);
      btn.addEventListener('click', () => openEditor(s));
    });
    root.querySelectorAll('[data-del]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        if (!(await confirmAction(`Excluir ${btn.dataset.del}?`))) return;
        await removeDoc(COL.studies, btn.dataset.del);
        items = items.filter((x) => x.id !== btn.dataset.del);
        showToast('Removido');
        render();
      });
    });
  }

  function openEditor(existing) {
    const modal = document.getElementById('modal');
    const s = existing || {
      id: '',
      passageRef: '',
      passageText: '',
      context: '',
      keyword: '',
      keywordGloss: '',
      focusQuestion: '',
      reflectionPrompts: ['', '', ''],
    };
    const prompts = (s.reflectionPrompts || []).join('\n');

    modal.innerHTML = `
      <div class="modal-backdrop">
        <div class="modal-panel modal-lg">
          <button type="button" class="modal-close">×</button>
          <h2>${existing ? 'Editar estudo' : 'Novo estudo'}</h2>
          <label>Slug do passo<input id="st-slug" value="${escapeHtml(s.id || s.slug || '')}" ${existing ? 'disabled' : ''} /></label>
          <label>Passagem (ref)<input id="st-ref" value="${escapeHtml(s.passageRef || '')}" /></label>
          <label>Texto da passagem<textarea id="st-text" rows="3">${escapeHtml(s.passageText || '')}</textarea></label>
          <label>Contexto<textarea id="st-ctx" rows="3">${escapeHtml(s.context || '')}</textarea></label>
          <div class="form-grid">
            <label>Palavra-chave<input id="st-kw" value="${escapeHtml(s.keyword || '')}" /></label>
            <label>Glosa<input id="st-gloss" value="${escapeHtml(s.keywordGloss || '')}" /></label>
          </div>
          <label>Pergunta foco<input id="st-focus" value="${escapeHtml(s.focusQuestion || '')}" /></label>
          <label>Prompts de reflexão (um por linha)<textarea id="st-prompts" rows="4">${escapeHtml(prompts)}</textarea></label>
          <div class="modal-actions">
            <button type="button" class="btn btn-secondary" id="cancel">Cancelar</button>
            <button type="button" class="btn btn-primary" id="st-save">Salvar</button>
          </div>
        </div>
      </div>`;
    modal.hidden = false;
    modal.style.display = 'block';

    const close = () => {
      modal.hidden = true;
      modal.style.display = 'none';
      modal.innerHTML = '';
    };
    modal.querySelector('.modal-close').onclick = close;
    modal.querySelector('#cancel').onclick = close;
    modal.querySelector('#st-save').onclick = async () => {
      const id = document.getElementById('st-slug').value.trim();
      if (!id) {
        showToast('Slug obrigatório', 'error');
        return;
      }
      const payload = {
        slug: id,
        passageRef: document.getElementById('st-ref').value,
        passageText: document.getElementById('st-text').value,
        context: document.getElementById('st-ctx').value,
        keyword: document.getElementById('st-kw').value,
        keywordGloss: document.getElementById('st-gloss').value,
        focusQuestion: document.getElementById('st-focus').value,
        reflectionPrompts: document
          .getElementById('st-prompts')
          .value.split('\n')
          .map((l) => l.trim())
          .filter(Boolean),
      };
      setLoading(true);
      try {
        await saveDoc(COL.studies, id, payload);
        const idx = items.findIndex((x) => x.id === id);
        if (idx >= 0) items[idx] = { id, ...payload };
        else items.push({ id, ...payload });
        showToast('Salvo');
        close();
        render();
      } catch (e) {
        showToast(e.message || 'Erro', 'error');
      } finally {
        setLoading(false);
      }
    };
  }

  render();
}
