import { COL, batchSet, bumpCatalogVersion, listCollection } from './db.js';
import { escapeHtml, setLoading, showToast } from './ui.js';

const ACCEPT = '.pdf,.docx,.doc,.txt,.md,.json,.zip';

// --- Leitura de arquivos ---

async function readJsonFile(file) {
  const text = await file.text();
  return JSON.parse(text);
}

async function readFileContent(file) {
  const ext = file.name.split('.').pop().toLowerCase();

  if (ext === 'json') {
    return { kind: 'structured', data: await readJsonFile(file) };
  }

  if (ext === 'txt' || ext === 'md') {
    return { kind: 'text', text: await file.text() };
  }

  if (ext === 'pdf') {
    const pdfjsLib = await loadPdfJs();
    const arrayBuf = await file.arrayBuffer();
    const pdf = await pdfjsLib.getDocument({ data: arrayBuf }).promise;
    let fullText = '';
    for (let i = 1; i <= pdf.numPages; i++) {
      const page = await pdf.getPage(i);
      const content = await page.getTextContent();
      fullText += content.items.map((it) => it.str).join(' ') + '\n';
    }
    return { kind: 'text', text: fullText.trim() };
  }

  if (ext === 'docx' || ext === 'doc') {
    const mammoth = await loadMammoth();
    const arrayBuf = await file.arrayBuffer();
    const result = await mammoth.extractRawText({ arrayBuffer: arrayBuf });
    return { kind: 'text', text: result.value.trim() };
  }

  if (ext === 'zip') {
    const JSZip = await loadJsZip();
    const zip = await JSZip.loadAsync(await file.arrayBuffer());
    const entries = [];
    for (const [path, entry] of Object.entries(zip.files)) {
      if (entry.dir) continue;
      const lower = path.toLowerCase();
      if (lower.endsWith('.json')) {
        const data = JSON.parse(await entry.async('string'));
        entries.push({ name: path.split('/').pop(), kind: 'structured', data });
      } else if (/\.(txt|md)$/.test(lower)) {
        entries.push({ name: path.split('/').pop(), kind: 'text', text: await entry.async('string') });
      }
    }
    return { kind: 'zip', entries };
  }

  throw new Error(`Formato não suportado: .${ext}`);
}

let _pdfjs = null;
async function loadPdfJs() {
  if (_pdfjs) return _pdfjs;
  _pdfjs = await import('https://cdn.jsdelivr.net/npm/pdfjs-dist@4.4.168/+esm');
  _pdfjs.GlobalWorkerOptions.workerSrc =
    'https://cdn.jsdelivr.net/npm/pdfjs-dist@4.4.168/build/pdf.worker.min.mjs';
  return _pdfjs;
}

let _mammoth = null;
async function loadMammoth() {
  if (_mammoth) return _mammoth;
  _mammoth = await import('https://cdn.jsdelivr.net/npm/mammoth@1.8.0/+esm');
  return _mammoth;
}

let _jszip = null;
async function loadJsZip() {
  if (_jszip) return _jszip;
  _jszip = (await import('https://cdn.jsdelivr.net/npm/jszip@3.10.1/+esm')).default;
  return _jszip;
}

let _jspdf = null;
async function loadJsPdf() {
  if (_jspdf) return _jspdf;
  const mod = await import('https://cdn.jsdelivr.net/npm/jspdf@2.5.2/+esm');
  _jspdf = mod.jsPDF || mod.default;
  return _jspdf;
}

// --- Detecção e importação ---

function asQuestionList(data) {
  if (Array.isArray(data)) return data;
  if (data && Array.isArray(data.questions)) return data.questions;
  return [];
}

function detectKind(data, filename, forced) {
  if (forced && forced !== 'auto') return forced;

  const lower = filename.toLowerCase();
  if (lower.includes('trail') || lower.includes('trilha')) return 'trails';
  if (lower.includes('question') || lower.includes('pergunta') || lower.includes('bank') || lower.includes('banco'))
    return 'bank';
  if (lower.includes('stud') || lower.includes('estudo') || lower.includes('mission') || lower.includes('preparo'))
    return 'studies';

  if (data?.trails || (data?.bank && data?.studies)) return 'backup';
  if (Array.isArray(data) && data[0]?.modules) return 'trails';
  if (Array.isArray(data) && (data[0]?.enunciado || data[0]?.type || data[0]?.prompt)) return 'bank';
  if (data?.studies && typeof data.studies === 'object') return 'studies';
  if (data?.passageRef != null && !Array.isArray(data)) return 'studies';

  return 'text';
}

function slugFromFilename(name) {
  return name
    .replace(/\.[^.]+$/, '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 60);
}

async function importTrails(data, log) {
  const trails = Array.isArray(data) ? data : data.trails;
  if (!Array.isArray(trails)) throw new Error('Arquivo de trilhas inválido');
  const docs = trails.map((t, i) => ({
    ...t,
    id: t.slug,
    slug: t.slug,
    order: t.order ?? i + 1,
    isActive: true,
  }));
  await batchSet(COL.trails, docs, 'slug');
  log(`✓ ${docs.length} trilhas publicadas`);
}

async function importBank(data, filename, log) {
  const diffs = data.difficulties || [];
  if (diffs.length) {
    await batchSet(
      COL.difficulties,
      diffs.map((d, i) => ({ ...d, id: d.id, order: i + 1 })),
      'id',
    );
    log(`✓ ${diffs.length} níveis de dificuldade`);
  }
  const questions = asQuestionList(data);
  if (!questions.length) {
    log(`• ${filename}: nenhuma pergunta encontrada`);
    return;
  }
  await batchSet(
    COL.bank,
    questions.map((q, i) => ({ ...q, id: q.id, order: i + 1 })),
    'id',
  );
  log(`✓ ${questions.length} perguntas publicadas (${filename})`);
}

async function importStudies(data, log) {
  const studiesMap = data.studies || data;
  const docs = Object.entries(studiesMap)
    .filter(([, s]) => s && typeof s === 'object' && !Array.isArray(s))
    .map(([slug, s]) => ({ ...s, id: slug, slug }));
  const clean = docs.filter((d) => d.slug !== 'verses' && d.passageRef != null);
  const final = clean.length ? clean : docs;
  await batchSet(COL.studies, final, 'slug');
  log(`✓ ${final.length} estudos publicados`);
  if (data.verses) {
    await batchSet(COL.meta, [{ id: 'verses', verses: data.verses }], 'id');
    log('✓ referências bíblicas atualizadas');
  }
}

async function importTextAsStudy(text, filename, log) {
  if (!text.trim()) throw new Error('Arquivo vazio');
  const slug = slugFromFilename(filename);
  const doc = {
    id: slug,
    slug,
    passageRef: '',
    passageText: '',
    context: text.slice(0, 16000),
    keyword: '',
    keywordGloss: '',
    focusQuestion: '',
    reflectionPrompts: [],
    relatedVerses: [],
  };
  await batchSet(COL.studies, [doc], 'slug');
  log(`✓ Estudo "${slug}" criado a partir de ${filename}`);
}

async function importBackup(data, log) {
  if (data.trails) await importTrails(data.trails, log);
  if (data.difficulties?.length) {
    await batchSet(
      COL.difficulties,
      data.difficulties.map((d, i) => ({ ...d, id: d.id, order: i + 1 })),
      'id',
    );
    log(`✓ ${data.difficulties.length} níveis de dificuldade`);
  }
  if (data.bank) await importBank({ questions: data.bank }, 'backup', log);
  if (data.studies) await importStudies({ studies: Object.fromEntries(data.studies.map((s) => [s.slug || s.id, s])) }, log);
}

async function processStructured(data, filename, forced, log) {
  const kind = detectKind(data, filename, forced);
  switch (kind) {
    case 'trails':
      await importTrails(data, log);
      break;
    case 'bank':
      await importBank(data, filename, log);
      break;
    case 'studies':
      await importStudies(data, log);
      break;
    case 'backup':
      await importBackup(data, log);
      break;
    default:
      throw new Error(`Não reconheci o conteúdo de "${filename}". Escolha o tipo manualmente.`);
  }
}

// --- Exportação ---

function downloadBlob(blob, filename) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

function downloadWord(title, bodyHtml, filename) {
  const html = `<!DOCTYPE html><html><head><meta charset="utf-8"><title>${escapeHtml(title)}</title></head><body>${bodyHtml}</body></html>`;
  downloadBlob(new Blob(['\ufeff', html], { type: 'application/msword' }), filename);
}

async function downloadPdf(title, lines, filename) {
  const jsPDF = await loadJsPdf();
  const doc = new jsPDF({ unit: 'mm', format: 'a4' });
  const margin = 14;
  const pageW = doc.internal.pageSize.getWidth() - margin * 2;
  let y = margin;
  doc.setFontSize(14);
  doc.text(title, margin, y);
  y += 10;
  doc.setFontSize(10);
  for (const line of lines) {
    const wrapped = doc.splitTextToSize(line, pageW);
    for (const w of wrapped) {
      if (y > doc.internal.pageSize.getHeight() - margin) {
        doc.addPage();
        y = margin;
      }
      doc.text(w, margin, y);
      y += 5;
    }
    y += 2;
  }
  doc.save(filename);
}

function trailsToText(trails) {
  const lines = [];
  for (const t of trails) {
    lines.push(`TRILHA: ${t.title || t.slug}`);
    if (t.description) lines.push(t.description);
    for (const mod of t.modules || []) {
      lines.push(`  Módulo: ${mod.title || ''}`);
      for (const m of mod.missions || []) {
        lines.push(`    • ${m.title || m.slug}`);
        if (m.intro) lines.push(`      ${m.intro}`);
      }
    }
    lines.push('');
  }
  return lines;
}

function trailsToHtml(trails) {
  return trails
    .map(
      (t) => `
    <h2>${escapeHtml(t.title || t.slug)}</h2>
    <p>${escapeHtml(t.description || '')}</p>
    ${(t.modules || [])
      .map(
        (mod) => `
      <h3>${escapeHtml(mod.title || '')}</h3>
      <ul>${(mod.missions || [])
        .map((m) => `<li><strong>${escapeHtml(m.title || m.slug)}</strong><br>${escapeHtml(m.intro || '')}</li>`)
        .join('')}</ul>`,
      )
      .join('')}`,
    )
    .join('<hr>');
}

function bankToText(questions) {
  return questions.map((q, i) => {
    const opts = (q.options || []).map((o, j) => `    ${String.fromCharCode(65 + j)}. ${o}`).join('\n');
    return [`${i + 1}. [${q.type || 'quiz'}] ${q.enunciado || q.prompt || ''}`, opts, ''].join('\n');
  });
}

function bankToHtml(questions) {
  return questions
    .map(
      (q, i) => `
    <p><strong>${i + 1}. [${escapeHtml(q.type || 'quiz')}]</strong> ${escapeHtml(q.enunciado || q.prompt || '')}</p>
    <ul>${(q.options || []).map((o) => `<li>${escapeHtml(o)}</li>`).join('')}</ul>`,
    )
    .join('');
}

function studiesToText(studies) {
  return studies.flatMap((s) => [
    `ESTUDO: ${s.slug || s.id}`,
    s.passageRef ? `Passagem: ${s.passageRef}` : '',
    s.passageText || '',
    s.context || '',
    s.focusQuestion ? `Pergunta: ${s.focusQuestion}` : '',
    '',
  ]);
}

function studiesToHtml(studies) {
  return studies
    .map(
      (s) => `
    <h2>${escapeHtml(s.slug || s.id)}</h2>
    ${s.passageRef ? `<p><em>${escapeHtml(s.passageRef)}</em></p>` : ''}
    ${s.passageText ? `<blockquote>${escapeHtml(s.passageText)}</blockquote>` : ''}
    <p>${escapeHtml(s.context || '')}</p>
    ${s.focusQuestion ? `<p><strong>${escapeHtml(s.focusQuestion)}</strong></p>` : ''}`,
    )
    .join('<hr>');
}

async function exportCollection(key, format) {
  const labels = { trails: 'Trilhas', bank: 'Perguntas', studies: 'Estudos' };
  const filenames = { trails: 'trilhas', bank: 'perguntas', studies: 'estudos' };
  const docs = await listCollection(COL[key]);
  const label = labels[key];
  const base = filenames[key];

  if (format === 'word') {
    const html =
      key === 'trails' ? trailsToHtml(docs) : key === 'bank' ? bankToHtml(docs) : studiesToHtml(docs);
    downloadWord(label, html, `${base}.doc`);
    return docs.length;
  }

  const lines =
    key === 'trails' ? trailsToText(docs) : key === 'bank' ? bankToText(docs) : studiesToText(docs);
  await downloadPdf(label, lines, `${base}.pdf`);
  return docs.length;
}

async function exportAll(format) {
  const [trails, bank, studies] = await Promise.all([
    listCollection(COL.trails),
    listCollection(COL.bank),
    listCollection(COL.studies),
  ]);

  if (format === 'word') {
    const JSZip = await loadJsZip();
    const zip = new JSZip();
    zip.file('trilhas.doc', `\ufeff${trailsToHtml(trails)}`, { binary: false });
    zip.file('perguntas.doc', `\ufeff${bankToHtml(bank)}`, { binary: false });
    zip.file('estudos.doc', `\ufeff${studiesToHtml(studies)}`, { binary: false });
    const blob = await zip.generateAsync({ type: 'blob' });
    downloadBlob(blob, `stway-conteudo-${dateStamp()}.zip`);
    return trails.length + bank.length + studies.length;
  }

  await downloadPdf(
    'STWAY — Conteúdo completo',
    [...trailsToText(trails), '---', ...bankToText(bank), '---', ...studiesToText(studies)],
    `stway-conteudo-${dateStamp()}.pdf`,
  );
  return trails.length + bank.length + studies.length;
}

function dateStamp() {
  return new Date().toISOString().slice(0, 10);
}

// --- UI ---

export async function renderImportPage(root) {
  root.innerHTML = `
    <div class="page-header">
      <h1>Importar / Exportar</h1>
      <p class="page-sub">Envie PDF, Word ou texto — ou baixe uma cópia do conteúdo publicado.</p>
    </div>

    <div class="card">
      <h2>📥 Importar</h2>
      <p class="page-sub">Arraste arquivos ou escolha do computador. PDF e Word viram estudo; backups do STWAY são reconhecidos automaticamente.</p>

      <div class="ie-dropzone" id="dropzone" tabindex="0">
        <input type="file" id="file-input" accept="${ACCEPT}" multiple hidden />
        <div class="ie-dropzone-inner">
          <span class="ie-dropzone-icon">📄</span>
          <strong>Arraste arquivos aqui</strong>
          <span>PDF · Word · Texto · Backup STWAY</span>
          <button type="button" class="btn btn-secondary btn-sm" id="btn-pick">Escolher arquivos</button>
        </div>
      </div>

      <ul class="ie-file-list" id="file-list" hidden></ul>

      <div class="ie-options">
        <label>
          Tipo de conteúdo
          <select id="import-kind">
            <option value="auto">Detectar automaticamente</option>
            <option value="trails">Trilhas</option>
            <option value="bank">Perguntas</option>
            <option value="studies">Estudos / preparo</option>
            <option value="text">Material de texto (PDF, Word, TXT)</option>
          </select>
        </label>
      </div>

      <div class="btn-row" style="margin-top:var(--space-4)">
        <button type="button" class="btn btn-primary" id="btn-import" disabled>Importar</button>
        <button type="button" class="btn btn-ghost" id="btn-clear" hidden>Limpar</button>
      </div>
      <pre id="import-log" class="import-log" hidden></pre>
    </div>

    <div class="card" style="margin-top:var(--space-5)">
      <h2>📤 Exportar</h2>
      <p class="page-sub">Baixe o conteúdo publicado em Word ou PDF.</p>

      <div class="ie-export-grid">
        ${exportCard('trails', 'Trilhas', 'Mapas e passos do app')}
        ${exportCard('bank', 'Perguntas', 'Banco de ações do treino')}
        ${exportCard('studies', 'Estudos', 'Textos de preparo')}
        ${exportCard('all', 'Tudo', 'Pacote completo')}
      </div>
    </div>`;

  const dropzone = root.querySelector('#dropzone');
  const fileInput = root.querySelector('#file-input');
  const fileListEl = root.querySelector('#file-list');
  const btnImport = root.querySelector('#btn-import');
  const btnClear = root.querySelector('#btn-clear');
  const logEl = root.querySelector('#import-log');
  let pendingFiles = [];

  const log = (msg) => {
    logEl.hidden = false;
    logEl.textContent += `${msg}\n`;
  };

  function renderFileList() {
    if (!pendingFiles.length) {
      fileListEl.hidden = true;
      btnImport.disabled = true;
      btnClear.hidden = true;
      return;
    }
    fileListEl.hidden = false;
    btnImport.disabled = false;
    btnClear.hidden = false;
    fileListEl.innerHTML = pendingFiles
      .map(
        (f, i) => `
      <li>
        <span>${escapeHtml(f.name)}</span>
        <button type="button" class="btn btn-ghost btn-sm" data-rm="${i}" aria-label="Remover">✕</button>
      </li>`,
      )
      .join('');
    fileListEl.querySelectorAll('[data-rm]').forEach((btn) => {
      btn.addEventListener('click', () => {
        pendingFiles.splice(Number(btn.dataset.rm), 1);
        renderFileList();
      });
    });
  }

  function addFiles(fileList) {
    for (const f of fileList) pendingFiles.push(f);
    renderFileList();
  }

  root.querySelector('#btn-pick')?.addEventListener('click', () => fileInput.click());
  fileInput?.addEventListener('change', () => {
    addFiles(fileInput.files);
    fileInput.value = '';
  });
  btnClear?.addEventListener('click', () => {
    pendingFiles = [];
    renderFileList();
  });

  dropzone?.addEventListener('click', (e) => {
    if (e.target.closest('button')) return;
    fileInput.click();
  });
  dropzone?.addEventListener('dragover', (e) => {
    e.preventDefault();
    dropzone.classList.add('ie-dropzone-over');
  });
  dropzone?.addEventListener('dragleave', () => dropzone.classList.remove('ie-dropzone-over'));
  dropzone?.addEventListener('drop', (e) => {
    e.preventDefault();
    dropzone.classList.remove('ie-dropzone-over');
    addFiles(e.dataTransfer.files);
  });

  btnImport?.addEventListener('click', async () => {
    if (!pendingFiles.length) {
      showToast('Escolha ao menos um arquivo', 'error');
      return;
    }

    const forced = root.querySelector('#import-kind')?.value || 'auto';
    setLoading(true);
    logEl.hidden = false;
    logEl.textContent = '';

    try {
      for (const file of pendingFiles) {
        log(`→ ${file.name}`);
        const content = await readFileContent(file);

        if (content.kind === 'zip') {
          for (const entry of content.entries) {
            if (entry.kind === 'structured') {
              await processStructured(entry.data, entry.name, forced, log);
            } else if (entry.kind === 'text') {
              await importTextAsStudy(entry.text, entry.name, log);
            }
          }
          continue;
        }

        if (content.kind === 'text' || forced === 'text') {
          await importTextAsStudy(content.text, file.name, log);
          continue;
        }

        await processStructured(content.data, file.name, forced, log);
      }

      await bumpCatalogVersion();
      showToast('Importação concluída');
      log('Pronto. Conteúdo publicado no app.');
      pendingFiles = [];
      renderFileList();
    } catch (e) {
      console.error(e);
      showToast(e.message || 'Falha na importação', 'error');
      log(`Erro: ${e.message || e}`);
    } finally {
      setLoading(false);
    }
  });

  root.querySelectorAll('[data-export]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const key = btn.dataset.export;
      const format = btn.dataset.format;
      setLoading(true);
      try {
        const count = key === 'all' ? await exportAll(format) : await exportCollection(key, format);
        showToast(`${count} itens exportados`);
      } catch (e) {
        console.error(e);
        showToast(e.message || 'Falha ao exportar', 'error');
      } finally {
        setLoading(false);
      }
    });
  });
}

function exportCard(key, title, desc) {
  return `
    <div class="ie-export-card">
      <strong>${escapeHtml(title)}</strong>
      <span>${escapeHtml(desc)}</span>
      <div class="ie-export-actions">
        <button type="button" class="btn btn-outline btn-sm" data-export="${key}" data-format="word">Word</button>
        <button type="button" class="btn btn-outline btn-sm" data-export="${key}" data-format="pdf">PDF</button>
      </div>
    </div>`;
}
