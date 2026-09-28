/**
 * Validador do banco V3 (piloto). Confere estudo e perguntas contra a JFAAL
 * e contra a matriz gesto × modo de admin/pilot/genesis-1-11/SPEC_V3.md.
 *
 *   node admin/scripts/validate_pilot_v3.mjs                 # todas as cenas do piloto
 *   node admin/scripts/validate_pilot_v3.mjs cenas/gen-01-criador.json ...
 */
import { existsSync, readdirSync, readFileSync } from 'fs';
import { basename, dirname, join, resolve } from 'path';
import { fileURLToPath } from 'url';
import { parseRef, passageText, verseCount } from './_jfaal.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const pilotDir = join(__dirname, '..', 'pilot', 'genesis-1-11');
const TRAIL = 'genesis-1-11';
// --final: checagens que só valem depois de shuffle_pilot_options.mjs.
const FINAL = process.argv.includes('--final');

const SHORT = { semente: 'sem', caminhada: 'cam', profundezas: 'pro' };
const SKILL = { semente: 'observe', caminhada: 'understand', profundezas: 'interpret' };
const LESSON = ['true_false', 'find_in_text', 'choice', 'order', 'complete', 'connect'];
const BOSS = [...LESSON, 'find_in_text', 'order'];

const BANNED = /curiosidade hist[oó]rica|memoriza[cç][aã]o de nomes|o texto n[aã]o diz nada|^o trecho afirma|^certo[:!.]|^correto[:!.]|imago dei|tipologia|protoevangelho|escatol[oó]gic/i;
const JARGON_UI = /imago dei|tipologia|protoevangelho|escatol[oó]gic|hermen[eê]utic/i;
const TRAILING = /(\s(e|mas|ou|de|do|da|dos|das|que|para|por|com|o|a|os|as)|,|;|…|\.\.\.)$/i;

const letter = /\p{L}/u;
function hasWord(haystack, needle) {
  const h = String(haystack || '');
  const n = String(needle || '').trim();
  if (!n) return false;
  let from = 0;
  while (true) {
    const i = h.indexOf(n, from);
    if (i < 0) return false;
    const before = i > 0 ? h[i - 1] : '';
    const after = h[i + n.length] || '';
    if (!letter.test(before) && !letter.test(after)) return true;
    from = i + 1;
  }
}
const norm = (s) => String(s || '').normalize('NFC').replace(/\s+/g, ' ').trim();
const words = (s) => norm(s).split(' ').filter(Boolean).length;

function isBoss(slug) {
  return slug.includes('boss');
}

function checkStudy(study, slug, err, warn) {
  const s = study || {};
  const where = `${slug} estudo`;
  if (s.slug !== slug) err(`${where}: slug "${s.slug}" ≠ "${slug}"`);
  for (const k of ['passageRef', 'passageText', 'context', 'keyword', 'keywordGloss', 'focusQuestion', 'centralInsight', 'anchorQuestion']) {
    if (!norm(s[k])) err(`${where}: falta ${k}`);
  }
  const main = passageText(s.passageRef);
  if (!main) err(`${where}: passageRef inválida "${s.passageRef}" (um capítulo, faixa contínua)`);
  else if (norm(s.passageText) !== norm(main)) err(`${where}: passageText ≠ JFAAL de ${s.passageRef}`);
  if (verseCount(s.passageRef) > 6) warn(`${where}: passageRef com mais de 6 versos`);
  if (norm(s.context).length > 300) err(`${where}: context > 300 caracteres`);

  const passages = Array.isArray(s.passages) ? s.passages : [];
  if (!passages.length) err(`${where}: falta passages[]`);
  for (const p of passages) {
    const t = passageText(p.ref);
    if (!t) err(`${where}: passages ref inválida "${p.ref}"`);
    else if (norm(p.text) !== norm(t)) err(`${where}: passages "${p.ref}" ≠ JFAAL`);
  }
  const allText = passages.map((p) => p.text).join(' ');

  const range = (arr, min, max, name) => {
    if (!Array.isArray(arr) || arr.length < min || arr.length > max) {
      err(`${where}: ${name} precisa de ${min}–${max} itens (tem ${Array.isArray(arr) ? arr.length : 0})`);
      return [];
    }
    return arr;
  };
  for (const f of range(s.facts, 4, 6, 'facts')) {
    const t = passageText(f.evidenceRef);
    if (!t) err(`${where}: fact com evidenceRef inválida "${f.evidenceRef}"`);
    else if (!norm(t).includes(norm(f.evidenceSpan))) err(`${where}: fact evidenceSpan fora da JFAAL: "${f.evidenceSpan}"`);
    if (!norm(f.text)) err(`${where}: fact sem text`);
  }
  for (const k of range(s.keyTerms, 2, 3, 'keyTerms')) {
    if (!hasWord(allText, k.term)) err(`${where}: keyTerm "${k.term}" não aparece nos trechos da cena`);
    if (!norm(k.gloss)) err(`${where}: keyTerm "${k.term}" sem gloss`);
  }
  for (const st of range(s.structure, 3, 4, 'structure')) {
    if (!norm(st.label)) err(`${where}: structure sem label`);
    if (!parseRef(st.evidenceRef)) err(`${where}: structure evidenceRef inválida "${st.evidenceRef}"`);
  }
  for (const r of range(s.relations, 2, 3, 'relations')) {
    if (!['causa', 'contraste', 'propósito', 'sequência', 'resultado'].includes(r.kind)) err(`${where}: relation kind inválido "${r.kind}"`);
    const t = passageText(r.evidenceRef);
    if (!t) err(`${where}: relation evidenceRef inválida "${r.evidenceRef}"`);
    else if (r.marker && !hasWord(t, r.marker)) err(`${where}: relation marker "${r.marker}" não está em ${r.evidenceRef}`);
  }
  for (const c of range(s.crossRefs, 2, 3, 'crossRefs')) {
    const t = passageText(c.ref);
    if (!t) err(`${where}: crossRef inválida "${c.ref}"`);
    else if (!norm(t).includes(norm(c.text))) err(`${where}: crossRef "${c.ref}" text fora da JFAAL`);
    if (words(c.bridge) > 6) err(`${where}: crossRef bridge > 6 palavras`);
  }
  range(s.misreadings, 3, 3, 'misreadings').forEach((m) => {
    if (!norm(m.text) || !norm(m.why)) err(`${where}: misreading incompleto`);
  });
  if (!Array.isArray(s.relatedVerses) || !s.relatedVerses.length) warn(`${where}: relatedVerses vazio (app atual usa)`);
}

function checkQuestion(q, slug, mode, nn, gesture, err, warn) {
  const id = `${TRAIL}-${SHORT[mode]}-${slug}-${String(nn).padStart(2, '0')}`;
  const where = id;
  if (q.id !== id) err(`${where}: id "${q.id}" esperado "${id}"`);
  if (q.trail !== TRAIL) err(`${where}: trail`);
  if (q.section !== slug) err(`${where}: section`);
  if (q.difficulty !== mode) err(`${where}: difficulty`);
  if (q.type !== gesture) err(`${where}: type "${q.type}" esperado "${gesture}"`);
  if (q.skill !== SKILL[mode]) err(`${where}: skill "${q.skill}" esperado "${SKILL[mode]}"`);
  const stem = norm(q.question);
  if (!stem) err(`${where}: sem question`);
  if (norm(q.prompt) !== stem || norm(q.cue) !== stem) err(`${where}: question/prompt/cue diferentes`);
  if (stem.length > 140) warn(`${where}: enunciado > 140 caracteres`);
  if (BANNED.test(stem)) err(`${where}: enunciado com frase proibida`);

  const vr = q.verseRef;
  const live = passageText(vr);
  if (!live) err(`${where}: verseRef inválida "${vr}" (um capítulo, faixa contínua)`);
  else if (verseCount(vr) > 2) err(`${where}: verseRef com mais de 2 versos`);
  const pt = norm(q.passageText);
  if (live && pt !== norm(live)) err(`${where}: passageText ≠ JFAAL de ${vr}`);
  if (!Array.isArray(q.evidence) || !q.evidence.length) err(`${where}: evidence vazio`);
  for (const e of q.evidence || []) if (!parseRef(e)) err(`${where}: evidence inválida "${e}"`);
  if (!norm(q.evidenceSpan)) err(`${where}: sem evidenceSpan`);
  else if (!pt.includes(norm(q.evidenceSpan))) {
    const inA = q.passageA && norm(q.passageA.text).includes(norm(q.evidenceSpan));
    if (!inA) err(`${where}: evidenceSpan fora do palco`);
  }
  if (!norm(q.learningObjective)) err(`${where}: sem learningObjective`);

  const fc = norm(q.feedbackCorrect);
  if (!fc) err(`${where}: sem feedbackCorrect`);
  if (fc.length > 110) err(`${where}: feedbackCorrect > 110`);
  if (BANNED.test(fc)) err(`${where}: feedbackCorrect com prefixo proibido`);
  const hint = norm(q.hint);
  if (gesture !== 'true_false' && !hint) err(`${where}: sem hint`);
  if (hint.length > 90) err(`${where}: hint > 90`);

  const opts = Array.isArray(q.options) ? q.options : [];
  const ids = opts.map((o) => String(o.id));
  const texts = opts.map((o) => norm(o.text));
  if (new Set(texts.map((t) => t.toLowerCase())).size !== texts.length) err(`${where}: opções repetidas`);
  for (const t of texts) {
    if (!t) err(`${where}: opção vazia`);
    if (BANNED.test(t)) err(`${where}: opção proibida "${t}"`);
  }
  const cid = String(q.correctOptionId ?? '');
  const correctText = norm(opts.find((o) => String(o.id) === cid)?.text);

  const wrongIds = gesture === 'order' ? [] : gesture === 'true_false' ? [cid === 'true' ? 'false' : 'true'] : ids.filter((x) => x !== cid);
  const fw = q.feedbackWrong || {};
  for (const w of wrongIds) {
    if (!norm(fw[w])) err(`${where}: feedbackWrong sem chave "${w}"`);
    else if (norm(fw[w]).length > 120) err(`${where}: feedbackWrong "${w}" > 120`);
  }
  if (gesture === 'order' && !norm(fw.default) && !Object.keys(fw).length) err(`${where}: order sem feedbackWrong`);

  if (hint && correctText && ['find_in_text', 'complete', 'connect'].includes(gesture) && hint.toLowerCase().includes(correctText.toLowerCase())) {
    err(`${where}: hint entrega a resposta`);
  }

  switch (gesture) {
    case 'true_false': {
      if (stem.includes('?')) err(`${where}: V/F com "?"`);
      // `vfClaim` no app parte o enunciado em "pergunta: recorte" — só ": " conta (1:2 não).
      if (/:\s/.test(stem)) err(`${where}: V/F com dois-pontos`);
      if (ids.join(',') !== 'true,false') err(`${where}: V/F options devem ser true,false`);
      if (!['true', 'false'].includes(cid) || q.correctAnswer !== cid) err(`${where}: V/F correctOptionId/correctAnswer`);
      break;
    }
    case 'find_in_text': {
      if (opts.length !== 3) err(`${where}: toque precisa de 3 opções`);
      for (const t of texts) {
        if (words(t) < 1 || words(t) > 3) err(`${where}: opção de toque com ${words(t)} palavras "${t}"`);
        if (!hasWord(pt, t)) err(`${where}: opção de toque não está no palco "${t}"`);
      }
      if (q.template) err(`${where}: toque não usa template (vira lacuna no app)`);
      if (correctText && stem.toLowerCase().includes(correctText.toLowerCase()) && words(correctText) > 1) warn(`${where}: enunciado cita a resposta`);
      break;
    }
    case 'choice': {
      if (opts.length !== 4 || ids.join(',') !== 'a,b,c,d') err(`${where}: escolha precisa de a,b,c,d`);
      for (const t of texts) if (t.length > 85) err(`${where}: opção > 85 caracteres "${t}"`);
      if (mode !== 'semente') {
        for (const t of texts) {
          if (words(t) >= 4 && pt.toLowerCase().includes(t.toLowerCase().replace(/[.]$/, ''))) err(`${where}: opção é cópia do versículo "${t}"`);
        }
      }
      break;
    }
    case 'order': {
      const n = opts.length;
      if (n < 3 || n > 4 || (n === 4 && mode !== 'profundezas')) err(`${where}: ordenar com ${n} peças`);
      const co = Array.isArray(q.correctOrder) ? q.correctOrder.map(String) : [];
      if (co.length !== n || [...co].sort().join() !== [...ids].sort().join()) err(`${where}: correctOrder inválido`);
      if (norm(q.correctAnswer) !== co.join(',')) err(`${where}: correctAnswer ≠ correctOrder`);
      for (const t of texts) {
        if (t.length > 72) err(`${where}: peça > 72 caracteres "${t}"`);
        if (TRAILING.test(t)) err(`${where}: peça termina cortada "${t}"`);
      }
      if (mode === 'semente') {
        let cursor = -1;
        for (const oid of co) {
          const t = norm(opts.find((o) => String(o.id) === oid)?.text).replace(/[.;]$/, '');
          const i = pt.indexOf(t, cursor + 1);
          if (i < 0) err(`${where}: peça da Observação não é trecho literal do palco "${t}"`);
          else if (i <= cursor) err(`${where}: peças fora da ordem do texto`);
          else cursor = i;
        }
      }
      break;
    }
    case 'complete': {
      const tpl = String(q.template || '');
      const blanks = (tpl.match(/_{3,}/g) || []).length;
      if (blanks !== 1) err(`${where}: template precisa de exatamente 1 lacuna`);
      if (opts.length !== 3) err(`${where}: completar precisa de 3 opções`);
      for (const t of texts) if (words(t) > 2) err(`${where}: opção de completar longa "${t}"`);
      if (blanks === 1 && correctText && norm(tpl.replace(/_{3,}/, correctText)) !== pt) {
        err(`${where}: template + resposta ≠ palco`);
      }
      break;
    }
    case 'connect': {
      if (opts.length !== 3) err(`${where}: conectar precisa de 3 opções`);
      for (const t of texts) if (words(t) > 6) err(`${where}: opção de conectar > 6 palavras "${t}"`);
      const a = q.passageA || {};
      const b = q.passageB || {};
      const at = passageText(a.ref);
      if (!at) err(`${where}: passageA ref inválida "${a.ref}"`);
      else if (!norm(at).includes(norm(a.text))) err(`${where}: passageA text fora da JFAAL`);
      if (mode === 'semente') {
        if (b.ref !== 'Contexto') warn(`${where}: Observação deveria usar passageB "Contexto"`);
        if (!norm(b.text)) err(`${where}: passageB sem texto`);
      } else {
        const bt = passageText(b.ref);
        if (!bt) err(`${where}: passageB precisa de referência real (tem "${b.ref}")`);
        else if (!norm(bt).includes(norm(b.text))) err(`${where}: passageB text fora da JFAAL`);
        if (b.ref === a.ref) err(`${where}: passageB igual a passageA`);
      }
      break;
    }
    default:
      break;
  }
  return { correctText, gesture, verseRef: vr, stem, opts: texts, passageB: q.passageB?.ref };
}

function validateCena(path) {
  const errors = [];
  const warnings = [];
  const err = (m) => errors.push(m);
  const warn = (m) => warnings.push(m);
  const slug = basename(path, '.json');
  let data;
  try {
    data = JSON.parse(readFileSync(path, 'utf8'));
  } catch (e) {
    return { slug, errors: [`JSON inválido: ${e.message}`], warnings, trueCount: 0, tfCount: 0 };
  }
  checkStudy(data.study, slug, err, warn);
  const qs = Array.isArray(data.questions) ? data.questions : [];
  const rot = isBoss(slug) ? BOSS : LESSON;
  const answersTapComplete = new Map();
  const orderPieces = new Map();
  const bridgeRefs = [];
  const stems = new Set();
  let trueCount = 0;
  let tfCount = 0;
  // Completar e Conectar aparecem na ordem gravada — certa sempre em "a" é viciada.
  const shown = qs.filter((q) => q.type === 'complete' || q.type === 'connect');
  if (FINAL && shown.length >= 4 && shown.every((q) => q.correctOptionId === 'a')) {
    err(`${slug}: resposta certa sempre em "a" em Completar/Conectar (rode shuffle_pilot_options.mjs)`);
  }
  for (const mode of ['semente', 'caminhada', 'profundezas']) {
    const inMode = qs.filter((q) => q.difficulty === mode).sort((a, b) => String(a.id).localeCompare(String(b.id)));
    if (inMode.length !== rot.length) err(`${slug} ${mode}: ${inMode.length} perguntas, esperado ${rot.length}`);
    const refUse = new Map();
    inMode.forEach((q, i) => {
      const info = checkQuestion(q, slug, mode, i + 1, rot[i], err, warn);
      const key = info.stem.toLowerCase();
      if (stems.has(key)) err(`${q.id}: enunciado repetido na cena`);
      stems.add(key);
      refUse.set(info.verseRef, (refUse.get(info.verseRef) || 0) + 1);
      if (info.gesture === 'find_in_text' || info.gesture === 'complete') {
        const k = info.correctText.toLowerCase();
        if (k && answersTapComplete.has(k)) err(`${q.id}: resposta "${info.correctText}" já usada em ${answersTapComplete.get(k)}`);
        if (k) answersTapComplete.set(k, q.id);
      }
      if (info.gesture === 'order') {
        for (const p of info.opts) {
          const k = p.toLowerCase();
          if (orderPieces.has(k) && orderPieces.get(k) !== mode) err(`${q.id}: peça de ordenar repetida entre modos "${p}"`);
          orderPieces.set(k, mode);
        }
      }
      if (info.gesture === 'connect' && mode !== 'semente') bridgeRefs.push(info.passageB);
      if (info.gesture === 'true_false') {
        tfCount++;
        if (q.correctOptionId === 'true') trueCount++;
      }
    });
    for (const [ref, n] of refUse) if (n > 3 && !isBoss(slug)) warn(`${slug} ${mode}: ${ref} usado em ${n} perguntas`);
  }
  if (bridgeRefs.length === 2 && bridgeRefs[0] === bridgeRefs[1]) err(`${slug}: Conectar repete passageB entre Compreensão e Interpretação`);
  for (const q of qs) {
    const blob = JSON.stringify(q);
    if (JARGON_UI.test(norm(q.question)) || JARGON_UI.test(norm(q.feedbackCorrect))) warn(`${q.id}: jargão na UI`);
    if (/Jeová/.test(blob)) warn(`${q.id}: "Jeová" no texto`);
  }
  return { slug, errors, warnings, trueCount, tfCount };
}

const args = process.argv.slice(2).filter((a) => !a.startsWith('--'));
const cenaDir = join(pilotDir, 'cenas');
const files = args.length
  ? args.map((a) => (existsSync(a) ? resolve(a) : join(pilotDir, a)))
  : existsSync(cenaDir)
    ? readdirSync(cenaDir).filter((f) => f.endsWith('.json')).sort().map((f) => join(cenaDir, f))
    : [];

let failed = false;
let T = 0;
let N = 0;
for (const f of files) {
  const r = validateCena(f);
  T += r.trueCount;
  N += r.tfCount;
  const status = r.errors.length ? 'FALHOU' : 'ok';
  console.log(`\n=== ${r.slug}: ${status} (${r.errors.length} erros, ${r.warnings.length} avisos · V/F verdadeiras ${r.trueCount}/${r.tfCount})`);
  for (const e of r.errors) console.log(`  ✗ ${e}`);
  for (const w of r.warnings) console.log(`  ! ${w}`);
  if (r.errors.length) failed = true;
}
if (files.length > 1 && N) {
  const pct = Math.round((T / N) * 100);
  console.log(`\nV/F verdadeiras na trilha: ${T}/${N} (${pct}%) — alvo 45–55%`);
  if (pct < 45 || pct > 55) console.log('  ! fora do alvo de equilíbrio');
}
console.log(failed ? '\n✗ Validação falhou.' : `\n✓ ${files.length} cena(s) válidas.`);
process.exit(failed ? 1 : 0);
