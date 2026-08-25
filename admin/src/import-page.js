import { COL, batchSet, bumpCatalogVersion, listCollection } from './db.js';
import { validateBank, formatReport, CLONE_ID } from './bank-validator.js';
import { questionsForPasso } from './question-studio.js';
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

  const clones = questions.filter((q) => CLONE_ID.test(String(q.id || '')));
  if (clones.length) {
    log(`⚠ ${clones.length} clone(s) ignorado(s) (-xch/-xfill)`);
  }
  const clean = questions.filter((q) => !CLONE_ID.test(String(q.id || '')));
  const report = validateBank(clean);
  for (const w of report.warnings.slice(0, 12)) log(`⚠ ${w}`);
  if (report.errors.length) {
    for (const e of report.errors.slice(0, 20)) log(`✗ ${e}`);
    throw new Error(
      `${report.errors.length} erro(s) pedagógico(s). Corrija antes de publicar.\n${formatReport(report)}`,
    );
  }

  await batchSet(
    COL.bank,
    clean.map((q, i) => ({ ...q, id: q.id, order: i + 1 })),
    'id',
  );
  log(`✓ ${clean.length} perguntas publicadas (${filename})`);
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

function downloadJson(data, filename) {
  downloadBlob(
    new Blob([`${JSON.stringify(data, null, 2)}\n`], { type: 'application/json' }),
    filename,
  );
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

const TYPE_LABEL = {
  choice: 'escolher',
  true_false: 'V/F',
  complete: 'completar',
  order: 'ordenar',
  tap: 'toque',
  connect: 'conectar',
};

const DIFF_LABEL = {
  semente: 'Observação',
  caminhada: 'Compreensão',
  profundezas: 'Interpretação',
};

const DIFF_ORDER = [
  { id: 'semente', label: 'Observação' },
  { id: 'caminhada', label: 'Compreensão' },
  { id: 'profundezas', label: 'Interpretação' },
];

function questionStem(q) {
  return (q.cue || q.prompt || q.question || q.enunciado || '').trim();
}

function correctId(q) {
  return String(q.correctOptionId || q.correctAnswer || '');
}

function normalizeOptions(q) {
  const type = q.type || 'choice';
  const correct = correctId(q);

  if (type === 'true_false') {
    return [
      { id: 'true', label: 'a', text: 'Verdadeiro', correct: correct === 'true' },
      { id: 'false', label: 'b', text: 'Falso', correct: correct === 'false' },
    ];
  }

  const opts = q.options || [];
  if (!opts.length) return [];

  return opts.map((o, i) => {
    if (typeof o === 'string') {
      const id = String.fromCharCode(97 + i);
      return { id, label: id, text: o, correct: correct === id };
    }
    if (Array.isArray(o) && o.length >= 2) {
      const id = String(o[0] || String.fromCharCode(97 + i));
      return {
        id,
        label: id,
        text: String(o[1] || '').trim(),
        correct: correct === id,
      };
    }
    const id = o?.id || String.fromCharCode(97 + i);
    return {
      id,
      label: id,
      text: String(o?.text ?? o?.label ?? '').trim(),
      correct: correct === id,
    };
  });
}

function questionTag(q, { showDifficulty = true } = {}) {
  const type = TYPE_LABEL[q.type] || q.type || 'quiz';
  if (!showDifficulty) return `[${type}]`;
  const diff = DIFF_LABEL[q.difficulty] || q.difficulty || '';
  return diff ? `[${type} · ${diff}]` : `[${type}]`;
}

function orderLabels(q) {
  const order = q.correctOrder || q.order || [];
  if (!Array.isArray(order) || !order.length) return '';
  const byId = new Map((q.options || []).map((o) => [String(o.id), o.text || '']));
  return order
    .map((id) => {
      const text = byId.get(String(id));
      return text ? stripExportQuotes(text) : String(id);
    })
    .join(' → ');
}

function stripExportQuotes(s) {
  return String(s || '')
    .replace(/^[“”"«»'\s]+|[“”"«»'\s]+$/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

function extraQuestionLines(q) {
  const type = q.type || 'choice';
  const lines = [];
  if (type === 'complete' && q.template) lines.push(`Lacuna: ${q.template}`);
  if (type === 'tap' && q.passageText) lines.push(`Trecho: ${q.passageText}`);
  if (type === 'order') {
    const labels = orderLabels(q);
    if (labels) lines.push(`Ordem correta: ${labels}`);
  }
  if (type === 'connect') {
    if (q.passageA?.text) {
      lines.push(`Trecho A: ${[q.passageA.ref, q.passageA.text].filter(Boolean).join(' — ')}`);
    }
    if (q.passageB?.text) {
      lines.push(`Trecho B: ${[q.passageB.ref, q.passageB.text].filter(Boolean).join(' — ')}`);
    }
  }
  if (q.verseRef) lines.push(`Ref.: ${q.verseRef}`);
  return lines;
}

function formatQuestionText(q, index, { showDifficulty = true } = {}) {
  const stem = questionStem(q);
  const tag = questionTag(q, { showDifficulty });
  const lines = [`${index}. ${tag} ${stem}`.trim()];
  for (const extra of extraQuestionLines(q)) {
    lines.push(`   ${extra}`);
  }
  for (const opt of normalizeOptions(q)) {
    const letter = String(opt.label || opt.id || '').toUpperCase();
    const mark = opt.correct ? ' ✓' : '';
    lines.push(`   ${letter}. ${stripExportQuotes(opt.text)}${mark}`);
  }
  if (!normalizeOptions(q).length && !extraQuestionLines(q).length && !stem) {
    lines.push('   (sem enunciado)');
  }
  lines.push('');
  return lines;
}

function formatQuestionHtml(q, index, { showDifficulty = true } = {}) {
  const stem = questionStem(q);
  const opts = normalizeOptions(q);
  const extras = extraQuestionLines(q)
    .map((line) => `<p class="ie-q-extra">${escapeHtml(line)}</p>`)
    .join('');
  return `
    <div class="ie-q">
      <p><strong>${index}.</strong> <em>${escapeHtml(questionTag(q, { showDifficulty }))}</em> ${escapeHtml(stem)}</p>
      ${extras}
      ${
        opts.length
          ? `<ul>${opts
              .map(
                (o) =>
                  `<li><strong>${escapeHtml(String(o.label || o.id).toUpperCase())}.</strong> ${escapeHtml(stripExportQuotes(o.text))}${o.correct ? ' ✓' : ''}</li>`,
              )
              .join('')}</ul>`
          : ''
      }
    </div>`;
}

function groupByDifficulty(questions) {
  const buckets = new Map();
  for (const q of questions || []) {
    const id = q.difficulty || 'semente';
    if (!buckets.has(id)) buckets.set(id, []);
    buckets.get(id).push(q);
  }

  const groups = [];
  for (const d of DIFF_ORDER) {
    const items = sortQuestions(buckets.get(d.id) || []);
    if (items.length) groups.push({ id: d.id, label: d.label, questions: items });
    buckets.delete(d.id);
  }
  for (const [id, items] of buckets) {
    const sorted = sortQuestions(items);
    if (sorted.length) {
      groups.push({ id, label: DIFF_LABEL[id] || id, questions: sorted });
    }
  }
  return groups;
}

function formatMissionQuestionsText(questions) {
  const groups = groupByDifficulty(questions);
  if (!groups.length) return ['(sem perguntas no banco)', ''];

  const lines = [];
  for (const group of groups) {
    lines.push(group.label);
    lines.push('');
    group.questions.forEach((q, i) => {
      lines.push(...formatQuestionText(q, i + 1, { showDifficulty: false }));
    });
  }
  return lines;
}

function formatMissionQuestionsHtml(questions) {
  const groups = groupByDifficulty(questions);
  if (!groups.length) return '<p><em>(sem perguntas no banco)</em></p>';

  return groups
    .map(
      (group) => `
        <div class="ie-diff">
          <h5>${escapeHtml(group.label)}</h5>
          ${group.questions.map((q, i) => formatQuestionHtml(q, i + 1, { showDifficulty: false })).join('')}
        </div>`,
    )
    .join('');
}

function mapQuestionForExport(q) {
  return {
    id: q.id,
    type: q.type || 'choice',
    difficulty: q.difficulty || '',
    stem: questionStem(q),
    verseRef: q.verseRef || '',
    options: normalizeOptions(q).map((o) => ({
      id: o.id,
      text: o.text,
      correct: o.correct,
    })),
  };
}

function missionSlugs(trails) {
  const slugs = new Set();
  for (const t of trails || []) {
    for (const mod of t.modules || []) {
      for (const m of mod.missions || []) {
        if (m.slug) slugs.add(m.slug);
      }
    }
  }
  return slugs;
}

function sortQuestions(items) {
  return [...items].sort((a, b) => {
    const ao = a.order ?? Number.MAX_SAFE_INTEGER;
    const bo = b.order ?? Number.MAX_SAFE_INTEGER;
    if (ao !== bo) return ao - bo;
    return String(a.id || '').localeCompare(String(b.id || ''));
  });
}

function curriculumToText(trails, bank) {
  const lines = [];
  const sortedTrails = [...(trails || [])].sort(
    (a, b) => (a.order ?? 999) - (b.order ?? 999) || String(a.title || '').localeCompare(String(b.title || '')),
  );

  for (const t of sortedTrails) {
    const trailSlug = t.slug || t.id;
    lines.push(`TRILHA: ${t.title || trailSlug}`);
    if (t.description) lines.push(t.description);
    lines.push('');

    for (const mod of t.modules || []) {
      lines.push(`Módulo: ${mod.title || 'Sem título'}`);
      for (const m of mod.missions || []) {
        lines.push(`• ${m.title || m.slug}`);
        if (m.intro) lines.push(m.intro);
        lines.push('');

        const questions = questionsForPasso(bank, { trail: trailSlug, section: m.slug });
        lines.push(...formatMissionQuestionsText(questions));
      }
      lines.push('');
    }
    lines.push('');
  }

  const linked = missionSlugs(trails);
  const orphans = sortQuestions(
    (bank || []).filter((q) => !q.section || !linked.has(q.section)),
  );
  if (orphans.length) {
    lines.push('PERGUNTAS SEM PASSO (órfãs)');
    lines.push('');
    for (const group of groupByDifficulty(orphans)) {
      lines.push(group.label);
      lines.push('');
      group.questions.forEach((q, i) => {
        lines.push(...formatQuestionText(q, i + 1, { showDifficulty: false }));
      });
    }
  }

  return lines;
}

function curriculumToHtml(trails, bank) {
  const sortedTrails = [...(trails || [])].sort(
    (a, b) => (a.order ?? 999) - (b.order ?? 999) || String(a.title || '').localeCompare(String(b.title || '')),
  );

  const trailHtml = sortedTrails
    .map((t) => {
      const trailSlug = t.slug || t.id;
      const modulesHtml = (t.modules || [])
        .map(
          (mod) => `
        <h3>Módulo: ${escapeHtml(mod.title || 'Sem título')}</h3>
        ${(mod.missions || [])
          .map((m) => {
            const questions = questionsForPasso(bank, { trail: trailSlug, section: m.slug });
            const qHtml = formatMissionQuestionsHtml(questions);
            return `
          <div class="ie-mission">
            <h4>• ${escapeHtml(m.title || m.slug)}</h4>
            ${m.intro ? `<p>${escapeHtml(m.intro)}</p>` : ''}
            ${qHtml}
          </div>`;
          })
          .join('')}`,
        )
        .join('');

      return `
      <section class="ie-trail">
        <h2>TRILHA: ${escapeHtml(t.title || trailSlug)}</h2>
        ${t.description ? `<p>${escapeHtml(t.description)}</p>` : ''}
        ${modulesHtml}
      </section>`;
    })
    .join('<hr>');

  const linked = missionSlugs(trails);
  const orphans = sortQuestions(
    (bank || []).filter((q) => !q.section || !linked.has(q.section)),
  );
  const orphanHtml = orphans.length
    ? `<hr><h2>Perguntas sem passo (órfãs)</h2>${groupByDifficulty(orphans)
        .map(
          (group) => `
        <div class="ie-diff">
          <h3>${escapeHtml(group.label)}</h3>
          ${group.questions.map((q, i) => formatQuestionHtml(q, i + 1, { showDifficulty: false })).join('')}
        </div>`,
        )
        .join('')}`
    : '';

  return `${trailHtml}${orphanHtml}`;
}

function buildCurriculumTree(trails, bank, difficultyLevels = []) {
  const sortedTrails = [...(trails || [])].sort(
    (a, b) => (a.order ?? 999) - (b.order ?? 999) || String(a.title || '').localeCompare(String(b.title || '')),
  );

  const tree = sortedTrails.map((t) => {
    const trailSlug = t.slug || t.id;
    return {
      slug: trailSlug,
      title: t.title || trailSlug,
      description: t.description || '',
      modules: (t.modules || []).map((mod) => ({
        title: mod.title || '',
        missions: (mod.missions || []).map((m) => ({
          slug: m.slug || '',
          title: m.title || m.slug || '',
          intro: m.intro || '',
          difficulties: groupByDifficulty(
            questionsForPasso(bank, { trail: trailSlug, section: m.slug }),
          ).map((group) => ({
            id: group.id,
            label: group.label,
            questions: group.questions.map(mapQuestionForExport),
          })),
        })),
      })),
    };
  });

  const linked = missionSlugs(trails);
  const orphans = sortQuestions(
    (bank || []).filter((q) => !q.section || !linked.has(q.section)),
  );

  return {
    exportedAt: new Date().toISOString(),
    difficultyLevels: (difficultyLevels.length ? difficultyLevels : DIFF_ORDER.map((d) => ({ id: d.id, label: d.label }))),
    trails: tree,
    orphans: groupByDifficulty(orphans).map((group) => ({
      id: group.id,
      label: group.label,
      questions: group.questions.map((q) => ({
        ...mapQuestionForExport(q),
        section: q.section || '',
        trail: q.trail || q.trailSlug || '',
      })),
    })),
  };
}

async function exportCurriculum(format) {
  const [trails, bank, difficultyLevels] = await Promise.all([
    listCollection(COL.trails),
    listCollection(COL.bank),
    listCollection(COL.difficulties),
  ]);

  const stamp = dateStamp();

  if (format === 'json') {
    const tree = buildCurriculumTree(trails, bank, difficultyLevels);
    downloadJson(tree, `curriculo-${stamp}.json`);
    return bank.length;
  }

  if (format === 'word') {
    downloadWord('Currículo STWAY', curriculumToHtml(trails, bank), `curriculo-${stamp}.doc`);
    return bank.length;
  }

  await downloadPdf('STWAY — Currículo', curriculumToText(trails, bank), `curriculo-${stamp}.pdf`);
  return bank.length;
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
  return questions.flatMap((q, i) => {
    const stem = questionStem(q) || q.enunciado || '';
    const lines = [`${i + 1}. ${questionTag(q)} ${stem}`];
    lines.push(...extraQuestionLines(q).map((line) => line.replace(/^ {6}/, '    ')));
    for (const opt of normalizeOptions(q)) {
      const letter = String(opt.label || opt.id || '').toUpperCase();
      lines.push(`    ${letter}. ${opt.text}${opt.correct ? ' ✓' : ''}`);
    }
    if (!normalizeOptions(q).length && q.type === 'order' && Array.isArray(q.correctOrder)) {
      lines.push(`    Ordem: ${q.correctOrder.join(' → ')}`);
    }
    lines.push('');
    return lines;
  });
}

function bankToHtml(questions) {
  return questions
    .map((q, i) => {
      const stem = questionStem(q) || q.enunciado || '';
      const opts = normalizeOptions(q);
      const extras = extraQuestionLines(q)
        .map((line) => `<p class="ie-q-extra">${escapeHtml(line.trim())}</p>`)
        .join('');
      return `
    <p><strong>${i + 1}. ${escapeHtml(questionTag(q))}</strong> ${escapeHtml(stem)}</p>
    ${extras}
    ${
      opts.length
        ? `<ul>${opts
            .map(
              (o) =>
                `<li><strong>${escapeHtml(String(o.label || o.id).toUpperCase())}.</strong> ${escapeHtml(o.text)}${o.correct ? ' ✓' : ''}</li>`,
            )
            .join('')}</ul>`
        : ''
    }`;
    })
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
  const stamp = dateStamp();

  if (format === 'json') {
    if (key === 'trails') {
      downloadJson(docs, `${base}-${stamp}.json`);
      return docs.length;
    }
    if (key === 'bank') {
      const difficulties = await listCollection(COL.difficulties);
      downloadJson({ difficulties, questions: docs }, `${base}-${stamp}.json`);
      return docs.length;
    }
    const studies = {};
    for (const s of docs) {
      const slug = s.slug || s.id;
      studies[slug] = { ...s, slug };
    }
    downloadJson({ studies }, `${base}-${stamp}.json`);
    return docs.length;
  }

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
  const [trails, bank, studies, difficulties] = await Promise.all([
    listCollection(COL.trails),
    listCollection(COL.bank),
    listCollection(COL.studies, 'slug'),
    listCollection(COL.difficulties),
  ]);
  const stamp = dateStamp();

  if (format === 'json') {
    downloadJson(
      {
        exportedAt: new Date().toISOString(),
        trails,
        difficulties,
        bank,
        studies,
      },
      `stway-conteudo-${stamp}.json`,
    );
    return trails.length + bank.length + studies.length;
  }

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
      <p class="page-sub">Baixe o conteúdo publicado em Word, PDF ou JSON. Use <strong>Currículo</strong> para trilha → passo → pergunta → opções.</p>

      <div class="ie-export-grid">
        ${exportCard('curriculum', 'Currículo', 'Trilhas com perguntas aninhadas')}
        ${exportCard('trails', 'Trilhas', 'Mapas e passos do app')}
        ${exportCard('bank', 'Perguntas', 'Banco de ações do treino')}
        ${exportCard('studies', 'Estudos', 'Textos de preparo')}
        ${exportCard('all', 'Tudo', 'Pacote completo (separado)')}
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
        const count =
          key === 'curriculum'
            ? await exportCurriculum(format)
            : key === 'all'
              ? await exportAll(format)
              : await exportCollection(key, format);
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

function exportCard(key, title, desc, formats = ['word', 'pdf', 'json']) {
  const labels = { word: 'Word', pdf: 'PDF', json: 'JSON' };
  const buttons = formats
    .map(
      (format) =>
        `<button type="button" class="btn btn-outline btn-sm" data-export="${key}" data-format="${format}">${labels[format] || format}</button>`,
    )
    .join('');
  return `
    <div class="ie-export-card">
      <strong>${escapeHtml(title)}</strong>
      <span>${escapeHtml(desc)}</span>
      <div class="ie-export-actions">
        ${buttons}
      </div>
    </div>`;
}
