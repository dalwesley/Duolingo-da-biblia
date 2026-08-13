import { COL, listCollection, removeDoc, saveDoc } from './db.js';
import { confirmAction, escapeHtml, setLoading, showToast } from './ui.js';

const DIFFS = ['semente', 'caminhada', 'profundezas'];
const TRAILS = [
  'genesis-1-11',
  'exodo',
  'evangelhos',
  'atos',
  'apocalipse',
];

/** Seção = slug do passo (ex.: gen-01-criador). Lista dinâmica + exemplos. */
function sectionOptions(items, current) {
  const fromData = [...new Set(items.map((q) => q.section).filter(Boolean))].sort();
  const set = new Set(fromData);
  if (current && !set.has(current)) fromData.unshift(current);
  return fromData;
}

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
    const sections = sectionOptions(items, filterSection);
    const list = filtered();
    root.innerHTML = `
      <div class="page-header row-between">
        <div>
          <h1>Banco de perguntas</h1>
          <p class="page-sub">Seção = slug do passo (ex. gen-01-criador) — ${items.length} no total</p>
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
          ${sections.map((s) => `<option value="${escapeHtml(s)}" ${filterSection === s ? 'selected' : ''}>${escapeHtml(s)}</option>`).join('')}
        </select>
      </div>
      <div class="card">
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr><th>ID</th><th>Gesto</th><th>Dificuldade</th><th>Seção</th><th>Pergunta</th><th></th></tr></thead>
            <tbody>
              ${list.slice(0, 200).map((q) => `
                <tr>
                  <td><code>${escapeHtml(q.id)}</code></td>
                  <td>${escapeHtml(q.type || 'choice')}</td>
                  <td>${escapeHtml(q.difficulty || '')}</td>
                  <td>${escapeHtml(q.section || '')}</td>
                  <td>${escapeHtml((q.prompt || q.question || '').slice(0, 80))}</td>
                  <td class="td-actions">
                    <button type="button" class="btn btn-sm btn-secondary" data-edit="${escapeHtml(q.id)}">Editar</button>
                    <button type="button" class="btn btn-sm btn-danger" data-del="${escapeHtml(q.id)}">Excluir</button>
                  </td>
                </tr>`).join('') || '<tr><td colspan="6">Nenhuma pergunta.</td></tr>'}
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
    const SKILLS = ['observe','understand','contextualize','interpret','connect','synthesize','theologize','apply'];
    const q = existing || {
      id: '',
      difficulty: 'semente',
      section: 'gen-01-criador',
      trail: 'genesis-1-11',
      type: 'choice',
      skill: 'observe',
      question: '',
      prompt: '',
      cue: '',
      passageText: '',
      template: '',
      correctAnswer: '',
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
    const sectionList = sectionOptions(items, q.section);

    modal.innerHTML = `
      <div class="modal-backdrop">
        <div class="modal-panel modal-lg">
          <button type="button" class="modal-close" aria-label="Fechar">×</button>
          <h2>${isNew ? 'Nova pergunta' : 'Editar pergunta'}</h2>
          <div class="form-grid">
            <label>ID<input id="bq-id" value="${escapeHtml(q.id)}" ${isNew ? '' : 'disabled'} /></label>
            <label>Trilha<select id="bq-trail">
              ${TRAILS.map((t) => `<option value="${t}" ${(q.trail || q.trailSlug || 'genesis-1-11') === t ? 'selected' : ''}>${t}</option>`).join('')}
            </select></label>
            <label>Dificuldade<select id="bq-diff">${DIFFS.map((d) => `<option ${q.difficulty === d ? 'selected' : ''}>${d}</option>`).join('')}</select></label>
            <label>Seção (slug do passo)
              <input id="bq-sec" list="bq-sec-list" value="${escapeHtml(q.section || '')}" placeholder="ex.: gen-01-criador" />
              <datalist id="bq-sec-list">${sectionList.map((s) => `<option value="${escapeHtml(s)}"></option>`).join('')}</datalist>
            </label>
            <label>Versículo<input id="bq-verse" value="${escapeHtml(q.verseRef || '')}" /></label>
            <label>Gesto<select id="bq-type">
              ${['choice','true_false','tap','complete','order','connect'].map((t) =>
                `<option value="${t}" ${(q.type || 'choice') === t ? 'selected' : ''}>${t}</option>`
              ).join('')}
            </select></label>
            <label>Competência<select id="bq-skill">
              ${SKILLS.map((s) => `<option value="${s}" ${(q.skill || 'observe') === s ? 'selected' : ''}>${s}</option>`).join('')}
            </select></label>
          </div>
          <p class="muted" style="margin:0 0 var(--space-3)">A seção deve ser o slug do passo na trilha (não use criacao/jardim/depois).</p>
          <label>Pergunta<textarea id="bq-q" rows="3">${escapeHtml(q.question || '')}</textarea></label>
          <label>Prompt / afirmação (V/F e palco)<textarea id="bq-prompt" rows="2">${escapeHtml(q.prompt || '')}</textarea></label>
          <label>Cue (instrução curta)<input id="bq-cue" value="${escapeHtml(q.cue || '')}" /></label>
          <label>Palco — texto do verso (toque / escolha)<textarea id="bq-passage" rows="2">${escapeHtml(q.passageText || '')}</textarea></label>
          <label>Template com ___ (completar)<input id="bq-template" value="${escapeHtml(q.template || '')}" /></label>
          <label>Resposta (V/F: true/false; ou id da opção)<input id="bq-answer" value="${escapeHtml(q.correctAnswer || q.correctOptionId || '')}" /></label>
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
      const section = (document.getElementById('bq-sec').value || '').trim();
      if (!section) {
        showToast('Seção (slug do passo) obrigatória', 'error');
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
        section,
        type: document.getElementById('bq-type')?.value || existing?.type || 'choice',
        skill: document.getElementById('bq-skill')?.value || existing?.skill || 'observe',
        question: document.getElementById('bq-q').value,
        prompt: document.getElementById('bq-prompt')?.value || undefined,
        cue: document.getElementById('bq-cue')?.value || undefined,
        correctAnswer: document.getElementById('bq-answer')?.value || undefined,
        passageText: document.getElementById('bq-passage')?.value || undefined,
        template: document.getElementById('bq-template')?.value || undefined,
        options,
        correctOptionId: correct,
        feedbackCorrect: document.getElementById('bq-ok').value,
        feedbackWrong,
        verseRef: document.getElementById('bq-verse').value,
        reveal: document.getElementById('bq-reveal').value || null,
        order: existing?.order ?? items.length + 1,
        passageA: existing?.passageA,
        passageB: existing?.passageB,
        correctOrder: existing?.correctOrder,
        note: existing?.note,
        beat: existing?.beat,
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
