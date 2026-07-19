import { COL, batchSet, bumpCatalogVersion } from './db.js';
import { setLoading, showToast, escapeHtml } from './ui.js';

async function readJsonFile(file) {
  const text = await file.text();
  return JSON.parse(text);
}

export async function renderImportPage(root) {
  root.innerHTML = `
    <div class="page-header">
      <h1>Importar conteúdo</h1>
      <p class="page-sub">Sobe os JSON locais do app para o Firestore (sem precisar republicar o app)</p>
    </div>
    <div class="card">
      <h2>Arquivos esperados</h2>
      <ul class="hint-list">
        <li><code>trails.json</code> — trilhas, cenas, passos e perguntas embutidas</li>
        <li><code>genesis_questions.json</code> — banco de perguntas + dificuldades</li>
        <li><code>mission_studies.json</code> — preparo (estudo) por passo</li>
      </ul>
      <div class="form-grid" style="margin-top:var(--space-5)">
        <label>trails.json<input type="file" id="file-trails" accept="application/json,.json" /></label>
        <label>genesis_questions.json<input type="file" id="file-bank" accept="application/json,.json" /></label>
        <label>mission_studies.json<input type="file" id="file-studies" accept="application/json,.json" /></label>
      </div>
      <div class="btn-row" style="margin-top:var(--space-5)">
        <button type="button" class="btn btn-primary" id="btn-import">Importar selecionados</button>
      </div>
      <pre id="import-log" class="import-log"></pre>
    </div>`;

  const logEl = root.querySelector('#import-log');
  const log = (msg) => {
    logEl.textContent += `${msg}\n`;
  };

  root.querySelector('#btn-import')?.addEventListener('click', async () => {
    const trailsFile = root.querySelector('#file-trails').files?.[0];
    const bankFile = root.querySelector('#file-bank').files?.[0];
    const studiesFile = root.querySelector('#file-studies').files?.[0];
    if (!trailsFile && !bankFile && !studiesFile) {
      showToast('Selecione ao menos um arquivo', 'error');
      return;
    }

    setLoading(true);
    logEl.textContent = '';
    try {
      if (trailsFile) {
        const trails = await readJsonFile(trailsFile);
        if (!Array.isArray(trails)) throw new Error('trails.json deve ser um array');
        const docs = trails.map((t, i) => ({
          ...t,
          id: t.slug,
          slug: t.slug,
          order: t.order ?? i + 1,
          isActive: true,
        }));
        log(`Trilhas: ${docs.length}…`);
        await batchSet(COL.trails, docs, 'slug');
        log(`✓ ${docs.length} trilhas gravadas`);
      }

      if (bankFile) {
        const data = await readJsonFile(bankFile);
        const diffs = data.difficulties || [];
        const questions = data.questions || [];
        if (diffs.length) {
          await batchSet(
            COL.difficulties,
            diffs.map((d, i) => ({ ...d, id: d.id, order: i + 1 })),
            'id',
          );
          log(`✓ ${diffs.length} dificuldades`);
        }
        if (questions.length) {
          await batchSet(
            COL.bank,
            questions.map((q, i) => ({ ...q, id: q.id, order: i + 1 })),
            'id',
          );
          log(`✓ ${questions.length} perguntas do banco`);
        }
      }

      if (studiesFile) {
        const data = await readJsonFile(studiesFile);
        const studiesMap = data.studies || data;
        const docs = Object.entries(studiesMap).map(([slug, s]) => ({
          ...s,
          id: slug,
          slug,
        }));
        await batchSet(COL.studies, docs, 'slug');
        log(`✓ ${docs.length} estudos`);
        if (data.verses) {
          await batchSet(
            COL.meta,
            [{ id: 'verses', verses: data.verses }],
            'id',
          );
          log('✓ mapa de versículos');
        }
      }

      await bumpCatalogVersion();
      showToast('Importação concluída');
      log('Pronto. Versão do catálogo atualizada.');
    } catch (e) {
      console.error(e);
      showToast(e.message || 'Falha na importação', 'error');
      log(`Erro: ${e.message || e}`);
    } finally {
      setLoading(false);
    }
  });
}
