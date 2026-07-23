import { COL, batchSet, bumpCatalogVersion } from './db.js';
import { setLoading, showToast } from './ui.js';

async function readJsonFile(file) {
  const text = await file.text();
  return JSON.parse(text);
}

function asQuestionList(data) {
  if (Array.isArray(data)) return data;
  if (data && Array.isArray(data.questions)) return data.questions;
  return [];
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
        <li><code>genesis_questions.json</code> — dificuldades + banco Gênesis</li>
        <li><code>exodo_questions.json</code> — banco Êxodo</li>
        <li><code>ot_questions.json</code> — banco restante do AT</li>
        <li><code>nt_questions.json</code> — banco NT (Evangelhos / Atos / Apocalipse)</li>
        <li><code>mission_studies.json</code> — preparo (estudo) por passo</li>
      </ul>
      <p class="page-sub" style="margin-top:var(--space-3)">Dica: rode <code>npm run prepare:content</code> antes para normalizar banks e gerar preparos.</p>
      <div class="form-grid" style="margin-top:var(--space-5)">
        <label>trails.json<input type="file" id="file-trails" accept="application/json,.json" /></label>
        <label>genesis_questions.json<input type="file" id="file-genesis" accept="application/json,.json" /></label>
        <label>exodo_questions.json<input type="file" id="file-exodo" accept="application/json,.json" /></label>
        <label>ot_questions.json<input type="file" id="file-ot" accept="application/json,.json" /></label>
        <label>nt_questions.json<input type="file" id="file-nt" accept="application/json,.json" /></label>
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

  async function importBankQuestions(file, label, { writeDifficulties = false } = {}) {
    const data = await readJsonFile(file);
    if (writeDifficulties) {
      const diffs = data.difficulties || [];
      if (diffs.length) {
        await batchSet(
          COL.difficulties,
          diffs.map((d, i) => ({ ...d, id: d.id, order: i + 1 })),
          'id',
        );
        log(`✓ ${diffs.length} dificuldades (${label})`);
      }
    }
    const questions = asQuestionList(data);
    if (!questions.length) {
      log(`• ${label}: nenhuma pergunta`);
      return 0;
    }
    await batchSet(
      COL.bank,
      questions.map((q, i) => ({ ...q, id: q.id, order: i + 1 })),
      'id',
    );
    log(`✓ ${questions.length} perguntas (${label})`);
    return questions.length;
  }

  root.querySelector('#btn-import')?.addEventListener('click', async () => {
    const trailsFile = root.querySelector('#file-trails').files?.[0];
    const genesisFile = root.querySelector('#file-genesis').files?.[0];
    const exodoFile = root.querySelector('#file-exodo').files?.[0];
    const otFile = root.querySelector('#file-ot').files?.[0];
    const ntFile = root.querySelector('#file-nt').files?.[0];
    const studiesFile = root.querySelector('#file-studies').files?.[0];
    if (!trailsFile && !genesisFile && !exodoFile && !otFile && !ntFile && !studiesFile) {
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

      if (genesisFile) {
        await importBankQuestions(genesisFile, 'Gênesis', { writeDifficulties: true });
      }
      if (exodoFile) await importBankQuestions(exodoFile, 'Êxodo');
      if (otFile) await importBankQuestions(otFile, 'AT');
      if (ntFile) await importBankQuestions(ntFile, 'NT');

      if (studiesFile) {
        const data = await readJsonFile(studiesFile);
        const studiesMap = data.studies || data;
        const docs = Object.entries(studiesMap)
          .filter(([, s]) => s && typeof s === 'object' && !Array.isArray(s))
          .map(([slug, s]) => ({
            ...s,
            id: slug,
            slug,
          }));
        // evita gravar a chave "verses" como estudo se o arquivo veio achatado
        const clean = docs.filter((d) => d.slug !== 'verses' && d.passageRef != null);
        await batchSet(COL.studies, clean.length ? clean : docs, 'slug');
        log(`✓ ${(clean.length ? clean : docs).length} estudos`);
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
