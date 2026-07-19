import { COL, listCollection, removeDoc, saveDoc } from './db.js';
import { confirmAction, escapeHtml, setLoading, showToast } from './ui.js';

const DIFFS = ['semente', 'caminhada', 'profundezas'];
const SECTIONS = [
  'criacao',
  'jardim',
  'depois',
  'opressao',
  'libertacao',
  'deserto',
];

export async function renderBankPage(root) {
  root.innerHTML = `<div class="page-header"><h1>Banco de perguntas</h1></div><div class="card"><p>Carregando…</p></div>`;
  let items = await listCollection(COL.bank);
  let filterDiff = '';
  let filterSection = '';
  let search = '';

  function filtered() {
    return items.filter((q) => {
      if (filterDiff && q.difficulty !== filterDiff) return false;
      if (filterSection && q.section !== filterSection) return false;
      if (search) {
        const hay = `${q.id} ${q.question}`.toLowerCase();
        if (!hay.includes(search.toLowerCase())) return false;
      }
      return true;
    });
  }

  function render() {
    const list = filtered();
    root.innerHTML = `
      <div class="page-header row-between">
        <div>
          <h1>Banco de perguntas</h1>
          <p class="page-sub">Banco por trilha e nível (Gênesis, Êxodo…) — ${items.length} no total</p>
        </div>
        <button type="button" class="btn btn-primary" id="btn-new-q">+ Pergunta</button>
      </div>
      <div class="card filters-bar">
        <input id="f-search" placeholder="Buscar…" value="${escapeHtml(search)}" />
        <select id="f-diff">
          <option value="">Todas dificuldades</option>
          ${DIFFS.map((d) => `<option value="${d}" ${filterDiff === d ? 'selected' : ''}>${d}</option>`).join('')}
        </select>
        <select id="f-sec">
          <option value="">Todas seções</option>
          ${SECTIONS.map((s) => `<option value="${s}" ${filterSection === s ? 'selected' : ''}>${s}</option>`).join('')}
        </select>
      </div>
      <div class="card">
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr><th>ID</th><th>Dificuldade</th><th>Seção</th><th>Pergunta</th><th></th></tr></thead>
            <tbody>
              ${list.slice(0, 200).map((q) => `
                <tr>
                  <td><code>${escapeHtml(q.id)}</code></td>
                  <td>${escapeHtml(q.difficulty || '')}</td>
                  <td>${escapeHtml(q.section || '')}</td>
                  <td>${escapeHtml((q.question || '').slice(0, 80))}</td>
                  <td class="td-actions">
                    <button type="button" class="btn btn-sm btn-secondary" data-edit="${escapeHtml(q.id)}">Editar</button>
                    <button type="button" class="btn btn-sm btn-danger" data-del="${escapeHtml(q.id)}">Excluir</button>
                  </td>
                </tr>`).join('') || '<tr><td colspan="5">Nenhuma pergunta.</td></tr>'}
            </tbody>
          </table>
        </div>
        ${list.length > 200 ? `<p class="muted">Mostrando 200 de ${list.length}. Refine a busca.</p>` : ''}
      </div>`;

    root.querySelector('#f-search')?.addEventListener('input', (e) => {
      search = e.target.value;
      render();
      root.querySelector('#f-search')?.focus();
    });
    root.querySelector('#f-diff')?.addEventListener('change', (e) => {
      filterDiff = e.target.value;
      render();
    });
    root.querySelector('#f-sec')?.addEventListener('change', (e) => {
      filterSection = e.target.value;
      render();
    });

    root.querySelector('#btn-new-q')?.addEventListener('click', () => openEditor(null));
    root.querySelectorAll('[data-edit]').forEach((btn) => {
      btn.addEventListener('click', () => {
        const q = items.find((x) => x.id === btn.dataset.edit);
        openEditor(q);
      });
    });
    root.querySelectorAll('[data-del]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        if (!(await confirmAction(`Excluir ${btn.dataset.del}?`))) return;
        await removeDoc(COL.bank, btn.dataset.del);
        items = items.filter((x) => x.id !== btn.dataset.del);
        showToast('Removida');
        render();
      });
    });
  }

  function openEditor(existing) {
    const modal = document.getElementById('modal');
    const isNew = !existing;
    const q = existing || {
      id: '',
      difficulty: 'semente',
      section: 'criacao',
      question: '',
      options: [
        { id: 'a', text: '' },
        { id: 'b', text: '' },
        { id: 'c', text: '' },
        { id: 'd', text: '' },
      ],
      correctOptionId: 'a',
      feedbackCorrect: '',
      feedbackWrong: { b: '', c: '', d: '' },
      verseRef: '',
      reveal: '',
    };

    modal.innerHTML = `
      <div class="modal-backdrop">
        <div class="modal-panel modal-lg">
          <button type="button" class="modal-close" aria-label="Fechar">×</button>
          <h2>${isNew ? 'Nova pergunta' : 'Editar pergunta'}</h2>
          <div class="form-grid">
            <label>ID<input id="bq-id" value="${escapeHtml(q.id)}" ${isNew ? '' : 'disabled'} /></label>
            <label>Trilha<select id="bq-trail">
              ${['genesis-1-11', 'exodo'].map((t) => `<option value="${t}" ${(q.trail || q.trailSlug || 'genesis-1-11') === t ? 'selected' : ''}>${t}</option>`).join('')}
            </select></label>
            <label>Dificuldade<select id="bq-diff">${DIFFS.map((d) => `<option ${q.difficulty === d ? 'selected' : ''}>${d}</option>`).join('')}</select></label>
            <label>Seção<select id="bq-sec">${SECTIONS.map((s) => `<option ${q.section === s ? 'selected' : ''}>${s}</option>`).join('')}</select></label>
            <label>Versículo<input id="bq-verse" value="${escapeHtml(q.verseRef || '')}" /></label>
          </div>
          <label>Pergunta<textarea id="bq-q" rows="3">${escapeHtml(q.question || '')}</textarea></label>
          <div class="form-grid">
            ${['a', 'b', 'c', 'd'].map((id) => {
              const opt = (q.options || []).find((o) => o.id === id) || { text: '' };
              return `<label>Opção ${id}<input id="bq-opt-${id}" value="${escapeHtml(opt.text || '')}" /></label>`;
            }).join('')}
            <label>Correta<select id="bq-correct">${['a','b','c','d'].map((id) => `<option ${q.correctOptionId === id ? 'selected' : ''}>${id}</option>`).join('')}</select></label>
          </div>
          <label>Feedback correto<textarea id="bq-ok" rows="2">${escapeHtml(q.feedbackCorrect || '')}</textarea></label>
          <label>Reveal<input id="bq-reveal" value="${escapeHtml(q.reveal || '')}" /></label>
          <div class="modal-actions">
            <button type="button" class="btn btn-secondary" id="cancel">Cancelar</button>
            <button type="button" class="btn btn-primary" id="bq-save">Salvar</button>
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
    modal.querySelector('#bq-save').onclick = async () => {
      const id = (document.getElementById('bq-id').value || '').trim();
      if (!id) {
        showToast('ID obrigatório', 'error');
        return;
      }
      const correct = document.getElementById('bq-correct').value;
      const options = ['a', 'b', 'c', 'd'].map((oid) => ({
        id: oid,
        text: document.getElementById(`bq-opt-${oid}`).value,
      }));
      const feedbackWrong = {};
      for (const oid of ['a', 'b', 'c', 'd']) {
        if (oid !== correct) feedbackWrong[oid] = 'Resposta incorreta. Revise o texto.';
      }
      const payload = {
        id,
        trail: document.getElementById('bq-trail').value,
        difficulty: document.getElementById('bq-diff').value,
        section: document.getElementById('bq-sec').value,
        question: document.getElementById('bq-q').value,
        options,
        correctOptionId: correct,
        feedbackCorrect: document.getElementById('bq-ok').value,
        feedbackWrong,
        verseRef: document.getElementById('bq-verse').value,
        reveal: document.getElementById('bq-reveal').value || null,
        order: existing?.order ?? items.length + 1,
      };
      setLoading(true);
      try {
        await saveDoc(COL.bank, id, payload);
        const idx = items.findIndex((x) => x.id === id);
        if (idx >= 0) items[idx] = { ...items[idx], ...payload };
        else items.push(payload);
        showToast('Salva');
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
