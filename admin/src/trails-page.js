import {
  COL,
  batchSet,
  bumpCatalogVersion,
  listCollection,
  realmLabel,
  removeDoc,
  saveDoc,
} from './db.js';
import { confirmAction, escapeHtml, setLoading, showToast } from './ui.js';

const REALMS = [
  { value: 'antigo-testamento', label: 'Antigo Testamento' },
  { value: 'novo-testamento', label: 'Novo Testamento' },
  { value: 'vida-crista', label: 'Vida Cristã' },
  { value: 'teologia', label: 'Teologia' },
];

const CATEGORIES = [
  'pentateuco', 'historicos-at', 'poeticos', 'profetas-maiores', 'profetas-menores',
  'intertestamentario',
  'evangelhos', 'historicos-nt', 'epistolas', 'apocalipse',
  'discipulado', 'oracao', 'historia-igreja',
  'hermeneutica', 'linguas', 'sistematica', 'cristologia',
];

function emptyMission() {
  return {
    slug: '',
    title: '',
    intro: '',
    type: 'lesson',
    xpReward: 50,
    questions: [],
  };
}

function emptyModule() {
  return { title: '', icon: '📘', missions: [] };
}

function emptyQuestion() {
  return {
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
  };
}

export async function renderTrailsList(root, navigate) {
  root.innerHTML = `<div class="page-header"><h1>Trilhas</h1></div><div class="card"><p>Carregando…</p></div>`;
  const trails = await listCollection(COL.trails);

  root.innerHTML = `
    <div class="page-header row-between">
      <div>
        <h1>Trilhas</h1>
        <p class="page-sub">Trilha → subtrilhas (módulos) → missões → perguntas embutidas</p>
      </div>
      <button type="button" class="btn btn-primary" id="btn-new-trail">+ Nova trilha</button>
    </div>
    <div class="card">
      <div class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th>Ordem</th>
              <th>Trilha</th>
              <th>Reino</th>
              <th>Módulos</th>
              <th>Missões</th>
              <th>Status</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            ${trails.length === 0
              ? '<tr><td colspan="7">Nenhuma trilha no Firebase. Use <strong>Importar JSON</strong>.</td></tr>'
              : trails.map((t) => {
                  const mods = t.modules || [];
                  const missions = mods.reduce((n, m) => n + (m.missions?.length || 0), 0);
                  return `<tr>
                    <td>${t.order ?? 0}</td>
                    <td><strong>${escapeHtml(t.icon || '')} ${escapeHtml(t.title || t.id)}</strong><div class="muted">${escapeHtml(t.slug || t.id)}</div></td>
                    <td>${escapeHtml(realmLabel(t.realm))}</td>
                    <td>${mods.length}</td>
                    <td>${missions}</td>
                    <td>${t.comingSoon ? '<span class="badge badge-warn">Em breve</span>' : '<span class="badge badge-success">Ativa</span>'}</td>
                    <td class="td-actions">
                      <button type="button" class="btn btn-sm btn-secondary" data-edit="${escapeHtml(t.id)}">Editar</button>
                      <button type="button" class="btn btn-sm btn-danger" data-del="${escapeHtml(t.id)}">Excluir</button>
                    </td>
                  </tr>`;
                }).join('')}
          </tbody>
        </table>
      </div>
    </div>`;

  root.querySelector('#btn-new-trail')?.addEventListener('click', async () => {
    const slug = prompt('Slug da trilha (ex.: genesis-1-11):');
    if (!slug) return;
    const clean = slug.trim().toLowerCase().replace(/[^a-z0-9-]/g, '-');
    await saveDoc(COL.trails, clean, {
      slug: clean,
      title: 'Nova trilha',
      description: '',
      icon: '📖',
      order: trails.length + 1,
      unlockAfter: null,
      comingSoon: true,
      color: '#2F5D4A',
      realm: 'antigo-testamento',
      category: 'pentateuco',
      modules: [],
      isActive: true,
    });
    showToast('Trilha criada');
    navigate(`trail:${clean}`);
  });

  root.querySelectorAll('[data-edit]').forEach((btn) => {
    btn.addEventListener('click', () => navigate(`trail:${btn.dataset.edit}`));
  });

  root.querySelectorAll('[data-del]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const ok = await confirmAction(`Excluir trilha “${btn.dataset.del}”?`);
      if (!ok) return;
      setLoading(true);
      try {
        await removeDoc(COL.trails, btn.dataset.del);
        showToast('Trilha removida');
        await renderTrailsList(root, navigate);
      } catch (e) {
        showToast(e.message || 'Erro ao excluir', 'error');
      } finally {
        setLoading(false);
      }
    });
  });
}

export async function renderTrailEditor(root, trailId, navigate) {
  root.innerHTML = `<div class="page-header"><h1>Editando…</h1></div><div class="card"><p>Carregando…</p></div>`;
  const trails = await listCollection(COL.trails);
  const trail = trails.find((t) => t.id === trailId);
  if (!trail) {
    root.innerHTML = `<div class="card"><p>Trilha não encontrada.</p><button class="btn" data-route="trails">Voltar</button></div>`;
    return;
  }

  let draft = structuredClone({
    ...trail,
    modules: trail.modules || [],
  });

  function render() {
    root.innerHTML = `
      <div class="page-header row-between">
        <div>
          <nav class="breadcrumb"><a href="#" data-route="trails">Trilhas</a> / <span>${escapeHtml(draft.title)}</span></nav>
          <h1>${escapeHtml(draft.icon || '')} ${escapeHtml(draft.title)}</h1>
          <p class="page-sub">Subtrilhas, missões e perguntas embutidas</p>
        </div>
        <div class="btn-row">
          <button type="button" class="btn btn-secondary" data-route="trails">Voltar</button>
          <button type="button" class="btn btn-primary" id="btn-save-trail">Salvar</button>
        </div>
      </div>

      <div class="card" style="margin-bottom:var(--space-5)">
        <h2>Dados da trilha</h2>
        <div class="form-grid">
          <label>Slug<input id="f-slug" value="${escapeHtml(draft.slug || '')}" disabled /></label>
          <label>Título<input id="f-title" value="${escapeHtml(draft.title || '')}" /></label>
          <label>Ícone<input id="f-icon" value="${escapeHtml(draft.icon || '')}" /></label>
          <label>Ordem<input id="f-order" type="number" value="${draft.order ?? 0}" /></label>
          <label>Cor<input id="f-color" type="color" value="${escapeHtml(draft.color || '#2F5D4A')}" /></label>
          <label>Reino<select id="f-realm">${REALMS.map((r) => `<option value="${r.value}" ${draft.realm === r.value ? 'selected' : ''}>${r.label}</option>`).join('')}</select></label>
          <label>Categoria<select id="f-category">${CATEGORIES.map((c) => `<option value="${c}" ${draft.category === c ? 'selected' : ''}>${c}</option>`).join('')}</select></label>
          <label>Desbloqueia após<input id="f-unlock" value="${escapeHtml(draft.unlockAfter || '')}" placeholder="slug da trilha anterior" /></label>
          <label class="checkbox-label"><input id="f-soon" type="checkbox" ${draft.comingSoon ? 'checked' : ''}/> Em breve</label>
        </div>
        <label style="display:block;margin-top:var(--space-3)">Descrição<textarea id="f-desc" rows="2">${escapeHtml(draft.description || '')}</textarea></label>
      </div>

      <div class="card">
        <div class="row-between" style="margin-bottom:var(--space-4)">
          <h2 style="margin:0">Subtrilhas (módulos)</h2>
          <button type="button" class="btn btn-secondary" id="btn-add-mod">+ Subtrilha</button>
        </div>
        ${(draft.modules || []).map((mod, mi) => renderModule(mod, mi)).join('') || '<p class="muted">Nenhuma subtrilha ainda.</p>'}
      </div>`;

    bindEditor();
  }

  function renderModule(mod, mi) {
    return `
      <div class="nested-block" data-mod="${mi}">
        <div class="row-between">
          <h3>Subtrilha ${mi + 1}</h3>
          <button type="button" class="btn btn-sm btn-danger" data-del-mod="${mi}">Remover</button>
        </div>
        <div class="form-grid">
          <label>Título<input data-mod-title="${mi}" value="${escapeHtml(mod.title || '')}" /></label>
          <label>Ícone<input data-mod-icon="${mi}" value="${escapeHtml(mod.icon || '')}" /></label>
        </div>
        <div class="row-between" style="margin:var(--space-3) 0">
          <strong>Missões</strong>
          <button type="button" class="btn btn-sm btn-secondary" data-add-mission="${mi}">+ Missão</button>
        </div>
        ${(mod.missions || []).map((ms, qi) => renderMission(ms, mi, qi)).join('') || '<p class="muted">Sem missões.</p>'}
      </div>`;
  }

  function renderMission(ms, mi, qi) {
    const qs = ms.questions || [];
    return `
      <div class="nested-block nested-block-inner" data-mission="${mi}-${qi}">
        <div class="row-between">
          <h4>${escapeHtml(ms.title || 'Missão')} <span class="muted">(${escapeHtml(ms.type || 'lesson')})</span></h4>
          <button type="button" class="btn btn-sm btn-danger" data-del-mission="${mi}-${qi}">Remover</button>
        </div>
        <div class="form-grid">
          <label>Slug<input data-ms-slug="${mi}-${qi}" value="${escapeHtml(ms.slug || '')}" /></label>
          <label>Título<input data-ms-title="${mi}-${qi}" value="${escapeHtml(ms.title || '')}" /></label>
          <label>Tipo<select data-ms-type="${mi}-${qi}">
            <option value="lesson" ${ms.type === 'lesson' ? 'selected' : ''}>lesson</option>
            <option value="boss" ${ms.type === 'boss' ? 'selected' : ''}>boss</option>
          </select></label>
          <label>XP / passos<input type="number" data-ms-xp="${mi}-${qi}" value="${ms.xpReward ?? ms.stepsReward ?? 50}" /></label>
        </div>
        <label>Intro<textarea data-ms-intro="${mi}-${qi}" rows="2">${escapeHtml(ms.intro || '')}</textarea></label>
        <div class="row-between" style="margin:var(--space-3) 0">
          <strong>Perguntas embutidas (${qs.length})</strong>
          <button type="button" class="btn btn-sm btn-secondary" data-add-q="${mi}-${qi}">+ Pergunta</button>
        </div>
        ${qs.map((q, qi2) => renderQuestion(q, mi, qi, qi2)).join('')}
      </div>`;
  }

  function renderQuestion(q, mi, qi, qi2) {
    const opts = q.options || [];
    return `
      <details class="q-details" open>
        <summary>Pergunta ${qi2 + 1}: ${escapeHtml((q.question || '').slice(0, 60))}</summary>
        <label>Enunciado<textarea data-q-text="${mi}-${qi}-${qi2}" rows="2">${escapeHtml(q.question || '')}</textarea></label>
        <label>Versículo<input data-q-verse="${mi}-${qi}-${qi2}" value="${escapeHtml(q.verseRef || '')}" /></label>
        <label>Feedback correto<textarea data-q-ok="${mi}-${qi}-${qi2}" rows="2">${escapeHtml(q.feedbackCorrect || '')}</textarea></label>
        <div class="form-grid">
          ${['a', 'b', 'c', 'd'].map((id) => {
            const opt = opts.find((o) => o.id === id) || { id, text: '' };
            return `<label>Opção ${id.toUpperCase()}<input data-q-opt="${mi}-${qi}-${qi2}-${id}" value="${escapeHtml(opt.text || '')}" /></label>`;
          }).join('')}
          <label>Correta<select data-q-correct="${mi}-${qi}-${qi2}">
            ${['a', 'b', 'c', 'd'].map((id) => `<option value="${id}" ${q.correctOptionId === id ? 'selected' : ''}>${id}</option>`).join('')}
          </select></label>
        </div>
        <button type="button" class="btn btn-sm btn-danger" data-del-q="${mi}-${qi}-${qi2}">Remover pergunta</button>
      </details>`;
  }

  function readFormIntoDraft() {
    draft.title = root.querySelector('#f-title')?.value || draft.title;
    draft.icon = root.querySelector('#f-icon')?.value || draft.icon;
    draft.order = Number(root.querySelector('#f-order')?.value || 0);
    draft.color = root.querySelector('#f-color')?.value || draft.color;
    draft.realm = root.querySelector('#f-realm')?.value || draft.realm;
    draft.category = root.querySelector('#f-category')?.value || draft.category;
    draft.unlockAfter = root.querySelector('#f-unlock')?.value || null;
    draft.comingSoon = Boolean(root.querySelector('#f-soon')?.checked);
    draft.description = root.querySelector('#f-desc')?.value || '';

    draft.modules = (draft.modules || []).map((mod, mi) => {
      const title = root.querySelector(`[data-mod-title="${mi}"]`)?.value ?? mod.title;
      const icon = root.querySelector(`[data-mod-icon="${mi}"]`)?.value ?? mod.icon;
      const missions = (mod.missions || []).map((ms, qi) => {
        const key = `${mi}-${qi}`;
        const questions = (ms.questions || []).map((q, qi2) => {
          const qk = `${mi}-${qi}-${qi2}`;
          const options = ['a', 'b', 'c', 'd'].map((id) => ({
            id,
            text: root.querySelector(`[data-q-opt="${qk}-${id}"]`)?.value || '',
          }));
          const correct = root.querySelector(`[data-q-correct="${qk}"]`)?.value || 'a';
          const feedbackWrong = {};
          for (const id of ['a', 'b', 'c', 'd']) {
            if (id !== correct) {
              feedbackWrong[id] = q.feedbackWrong?.[id] || 'Resposta incorreta. Revise o texto.';
            }
          }
          return {
            question: root.querySelector(`[data-q-text="${qk}"]`)?.value || '',
            options,
            correctOptionId: correct,
            feedbackCorrect: root.querySelector(`[data-q-ok="${qk}"]`)?.value || '',
            feedbackWrong,
            verseRef: root.querySelector(`[data-q-verse="${qk}"]`)?.value || '',
          };
        });
        return {
          slug: root.querySelector(`[data-ms-slug="${key}"]`)?.value || '',
          title: root.querySelector(`[data-ms-title="${key}"]`)?.value || '',
          type: root.querySelector(`[data-ms-type="${key}"]`)?.value || 'lesson',
          xpReward: Number(root.querySelector(`[data-ms-xp="${key}"]`)?.value || 50),
          intro: root.querySelector(`[data-ms-intro="${key}"]`)?.value || '',
          questions,
        };
      });
      return { title, icon, missions };
    });
  }

  function bindEditor() {
    root.querySelector('#btn-save-trail')?.addEventListener('click', async () => {
      readFormIntoDraft();
      setLoading(true);
      try {
        const { id, updatedAt, ...payload } = draft;
        await saveDoc(COL.trails, trailId, {
          ...payload,
          slug: trailId,
          isActive: true,
        });
        showToast('Trilha salva — app atualiza no próximo carregamento');
      } catch (e) {
        showToast(e.message || 'Erro ao salvar', 'error');
      } finally {
        setLoading(false);
      }
    });

    root.querySelector('#btn-add-mod')?.addEventListener('click', () => {
      readFormIntoDraft();
      draft.modules.push(emptyModule());
      render();
    });

    root.querySelectorAll('[data-del-mod]').forEach((btn) => {
      btn.addEventListener('click', () => {
        readFormIntoDraft();
        draft.modules.splice(Number(btn.dataset.delMod), 1);
        render();
      });
    });

    root.querySelectorAll('[data-add-mission]').forEach((btn) => {
      btn.addEventListener('click', () => {
        readFormIntoDraft();
        const mi = Number(btn.dataset.addMission);
        draft.modules[mi].missions = draft.modules[mi].missions || [];
        draft.modules[mi].missions.push(emptyMission());
        render();
      });
    });

    root.querySelectorAll('[data-del-mission]').forEach((btn) => {
      btn.addEventListener('click', () => {
        readFormIntoDraft();
        const [mi, qi] = btn.dataset.delMission.split('-').map(Number);
        draft.modules[mi].missions.splice(qi, 1);
        render();
      });
    });

    root.querySelectorAll('[data-add-q]').forEach((btn) => {
      btn.addEventListener('click', () => {
        readFormIntoDraft();
        const [mi, qi] = btn.dataset.addQ.split('-').map(Number);
        draft.modules[mi].missions[qi].questions =
          draft.modules[mi].missions[qi].questions || [];
        draft.modules[mi].missions[qi].questions.push(emptyQuestion());
        render();
      });
    });

    root.querySelectorAll('[data-del-q]').forEach((btn) => {
      btn.addEventListener('click', () => {
        readFormIntoDraft();
        const [mi, qi, qi2] = btn.dataset.delQ.split('-').map(Number);
        draft.modules[mi].missions[qi].questions.splice(qi2, 1);
        render();
      });
    });
  }

  render();
}

export { batchSet, bumpCatalogVersion };
