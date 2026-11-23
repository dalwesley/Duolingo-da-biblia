/**
 * Banco V3 feito à mão no ChatGPT (sem API). O script prepara o que colar e
 * confere o que voltou; o ChatGPT só escreve.
 *
 *   node admin/scripts/v3_manual.mjs kit
 *       → admin/v3/_chatgpt/: instruções e arquivos para um Projeto do ChatGPT (uma vez)
 *   node admin/scripts/v3_manual.mjs pedidos --trail rute
 *       → v3/rute/manual/pedidos/<nn>-<cena>.txt: o pedido de cada cena, curto
 *   node admin/scripts/v3_manual.mjs pedidos --trail rute --completo
 *       → o mesmo, mas cada pedido já leva instruções, especificação e exemplo:
 *         cola numa conversa comum, sem Projeto nem arquivos no ChatGPT
 *   node admin/scripts/v3_manual.mjs conferir --trail rute
 *       → lê v3/rute/manual/respostas/<cena>.json, completa, valida;
 *         válidas vão para cenas/, as outras ganham manual/correcoes/<cena>.txt
 *   node admin/scripts/v3_manual.mjs traducao --trail rute [--completo]
 *       → v3/rute/manual/traducao/<nn>-<lote>.txt: EN+ES de uma vez, só o que falta
 *         (com --completo cada pedido já leva as regras; sem, use o Projeto de
 *         tradução com v3/_chatgpt/traducao_instrucoes.txt)
 *   node admin/scripts/v3_manual.mjs conferir-traducao --trail rute
 *       → lê manual/traducao-respostas/<nn>-<lote>.json e grava l10n/ (aplique com
 *         v3_translate.mjs --apply)
 */
import { createHash } from 'crypto';
import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'fs';
import { join } from 'path';
import { parseJsonReply } from './_llm.mjs';
import { hydrateCena, scopeErrors } from './_v3_hydrate.mjs';
import { FORMAT_RULES, ROLE, exampleJson, fixPromptInChat, specText, userPrompt } from './_v3_prompts.mjs';
import { ADMIN_DIR, argValue, readJson, trailDir } from './_v3_paths.mjs';
import { batchesOf, buildRequest, checkReply, pendingItems, saveTrail, storeTranslation, systemBoth } from './v3_translate.mjs';
import { buildInputs } from './v3_inputs.mjs';
import { validateCenaData } from './validate_pilot_v3.mjs';
import { verseCount } from './_jfaal_core.mjs';

const KIT_DIR = join(ADMIN_DIR, 'v3', '_chatgpt');
// Limite do campo de instruções de um Projeto / GPT personalizado do ChatGPT.
const INSTRUCTIONS_MAX = 8000;

const nn = (i) => String(i + 1).padStart(2, '0');
/** "03-rute-04-asas.json" → "rute-04-asas". */
const slugOf = (file) => file.replace(/\.(json|txt)$/, '').replace(/^\d{2}-/, '');

function kit() {
  mkdirSync(KIT_DIR, { recursive: true });
  const instructions = `${ROLE}

Siga à risca o arquivo especificacao.md deste projeto: ele é a regra. A trilha de exemplo é Gênesis 1–11; para outra trilha, troque o prefixo dos ids e as referências, e mantenha tudo o mais. exemplo_licao.json e exemplo_desafio.json mostram o formato e o nível esperados.

Cada pedido traz uma cena em <cena>. Quando eu mandar erros da validação, corrija todos e devolva a cena inteira.

${FORMAT_RULES}`;
  if (instructions.length > INSTRUCTIONS_MAX) {
    throw new Error(`Instruções com ${instructions.length} caracteres (máximo ${INSTRUCTIONS_MAX}).`);
  }
  writeFileSync(join(KIT_DIR, 'instrucoes.txt'), `${instructions}\n`);
  writeFileSync(join(KIT_DIR, 'especificacao.md'), specText());
  writeFileSync(join(KIT_DIR, 'exemplo_licao.json'), `${exampleJson('lesson')}\n`);
  writeFileSync(join(KIT_DIR, 'exemplo_desafio.json'), `${exampleJson('boss')}\n`);
  writeFileSync(
    join(KIT_DIR, 'LEIA-ME.txt'),
    `Configurar o ChatGPT (uma vez)

1. No ChatGPT, crie um Projeto chamado "STWAY V3" (ou um GPT personalizado).
2. Em Instruções, cole todo o conteúdo de instrucoes.txt (${instructions.length} caracteres).
3. Em Arquivos, envie especificacao.md, exemplo_licao.json e exemplo_desafio.json.
4. Use o modelo mais forte disponível no seu plano.

Depois, para cada cena: uma conversa nova dentro do projeto, cole o pedido
(v3/<trilha>/manual/pedidos/<nn>-<cena>.txt) e salve a resposta inteira em
v3/<trilha>/manual/respostas/<cena>.json.
`,
  );
  console.log(`✓ Kit em ${KIT_DIR} (instruções: ${instructions.length}/${INSTRUCTIONS_MAX} caracteres). Veja LEIA-ME.txt.`);
}

/** Pacotes na ordem da trilha (a numeração dos pedidos segue o mapa). */
function packetsFor(trail, dir) {
  const inputs = join(dir, 'inputs');
  const fresh = buildInputs(trail);
  if (!existsSync(inputs)) {
    mkdirSync(inputs, { recursive: true });
    for (const p of fresh) writeFileSync(join(inputs, `${p.mission.slug}.json`), `${JSON.stringify(p, null, 2)}\n`);
  }
  return fresh.map((p) => readJson(join(inputs, `${p.mission.slug}.json`), p));
}

/**
 * Cabeçalho do pedido completo: o que o Projeto do ChatGPT guardaria
 * (instruções, especificação e o exemplo do tipo da cena), para colar numa
 * conversa comum. O exemplo vai compacto (sem espaços) para pesar menos.
 */
function standaloneHeader(type) {
  const boss = type === 'boss';
  const example = JSON.stringify(JSON.parse(exampleJson(boss ? 'boss' : 'lesson')));
  return `${ROLE}

Siga à risca a ESPECIFICAÇÃO abaixo: ela é a regra. O EXEMPLO mostra o formato e o nível esperados. Ele é da trilha Gênesis 1–11; para outra trilha, troque o prefixo dos ids e as referências, e mantenha tudo o mais.

O PEDIDO, no fim, traz a cena em <cena>. Quando eu mandar erros da validação, corrija todos e devolva a cena inteira.

${FORMAT_RULES}

LIMITES QUE O VALIDADOR COBRA (os erros mais comuns; confira antes de responder):
- Conectar: as 3 opções com no máximo 6 palavras cada (nomeie a ponte, não explique).
- Toque: cada opção com 1 a 3 palavras, copiada do versículo do palco.
- Escolha: cada opção com até 85 caracteres.
- Ordenar: cada peça com até 72 caracteres; nenhuma peça se repete entre os três modos.
- Ordenar da Observação (semente): as peças são trechos COPIADOS do versículo do palco, na ordem do texto (não resuma).
- Completar: opções com 1 palavra (2 só se for nome composto; nunca 3).
- feedbackCorrect até 110 caracteres; cada feedbackWrong até 120; hint até 90, sem entregar a resposta.
- verseRef de cada pergunta: um capítulo, até 2 versos (ex.: "Marcos 2:10–11"; nunca "Marcos 2:5–12").

===== ESPECIFICAÇÃO =====
${specText().trim()}

===== EXEMPLO (${boss ? 'desafio / Travessia' : 'lição'}) =====
${example}

===== PEDIDO =====
`;
}

function pedidos(trail, { completo = false } = {}) {
  const dir = trailDir(trail);
  const out = join(dir, 'manual', 'pedidos');
  mkdirSync(out, { recursive: true });
  mkdirSync(join(dir, 'manual', 'respostas'), { recursive: true });
  const packets = packetsFor(trail, dir);
  let skipped = 0;
  packets.forEach((p, i) => {
    if (existsSync(join(dir, 'cenas', `${p.mission.slug}.json`))) {
      skipped++;
      return;
    }
    const head = completo ? standaloneHeader(p.mission.type) : '';
    writeFileSync(join(out, `${nn(i)}-${p.mission.slug}.txt`), `${head}${userPrompt(p, i)}\n`);
  });
  console.log(`✓ ${packets.length - skipped} pedido(s) em ${out}${skipped ? ` (${skipped} cena(s) já prontas)` : ''}.`);
  console.log(`  Salve cada resposta em ${join(dir, 'manual', 'respostas')}/<cena>.json`);
}

/**
 * Resposta colada da tela do ChatGPT (não do botão de copiar do bloco de
 * código) vem com `&#x20;` no lugar de espaços e `\` no fim de cada linha.
 * Limpa isso antes de ler o JSON.
 */
function cleanPasted(text) {
  // Só mexe em resposta copiada da tela (tem as marcas dela).
  if (!/&#x20;|\\[ \t]*$/m.test(text)) return text;
  return text
    .replace(/&#x20;/g, ' ')
    .replace(/&nbsp;/g, ' ')
    .replace(/\\[ \t]*$/gm, '')
    // Escape de markdown que a tela põe (\_\_\_, \*): não vale em JSON.
    .replace(/\\([_*#[\]])/g, '$1')
    // Aspas dentro de texto: a tela dobra a barra (\\" vira \").
    .replace(/\\\\"/g, '\\"');
}

const letterRe = /\p{L}/u;
const normText = (t) => String(t || '').normalize('NFC').replace(/\s+/g, ' ').trim();
/** Palavra/expressão inteira dentro do texto (mesma regra do validador). */
function wordIn(haystack, needle) {
  const h = String(haystack || '');
  const n = String(needle || '').trim();
  if (!n) return false;
  for (let from = 0; ; ) {
    const i = h.indexOf(n, from);
    if (i < 0) return false;
    if (!letterRe.test(i > 0 ? h[i - 1] : '') && !letterRe.test(h[i + n.length] || '')) return true;
    from = i + 1;
  }
}

/** Palcos possíveis da cena: cada verso do pacote e cada par de versos seguidos. */
function stageWindows(packet) {
  const vs = (packet.verses || [])
    .map((v) => {
      const m = String(v.ref).match(/^(.*?)\s(\d+):(\d+)$/);
      return m && { ref: v.ref, book: m[1], ch: +m[2], v: +m[3], text: normText(v.text) };
    })
    .filter(Boolean);
  const singles = vs.map((a) => ({ ref: a.ref, text: a.text }));
  const pairs = [];
  vs.forEach((a, i) => {
    const b = vs[i + 1];
    if (b && b.book === a.book && b.ch === a.ch && b.v === a.v + 1) {
      pairs.push({ ref: `${a.book} ${a.ch}:${a.v}–${b.v}`, text: `${a.text} ${b.text}` });
    }
  });
  return [...singles, ...pairs];
}

/**
 * Conserta o palco sozinho quando o erro é só de recorte: verseRef com mais
 * de 2 versos, ou Toque/Completar/Ordenar da Observação com peça que mora no
 * verso vizinho. Escolhe o menor palco da cena (1 verso, depois 2) que
 * contém a evidência e as peças. Devolve quantas perguntas mudaram.
 */
function autoStage(raw, packet) {
  const wins = stageWindows(packet);
  const byRef = new Map(wins.map((w) => [w.ref, w]));
  let fixed = 0;
  for (const q of raw.questions || []) {
    const literal = [];
    if (q.type === 'find_in_text') literal.push(...(q.options || []).map((o) => o.text));
    if (q.type === 'complete') {
      const right = (q.options || []).find((o) => o.id === q.correctOptionId);
      if (right) literal.push(right.text);
    }
    const pieces = q.type === 'order' && q.difficulty === 'semente' ? (q.options || []).map((o) => o.text) : [];
    const span = normText(q.evidenceSpan);
    const fits = (w) =>
      (!span || w.text.includes(span)) &&
      literal.every((t) => wordIn(w.text, normText(t))) &&
      pieces.every((t) => w.text.includes(normText(t)));
    const current = byRef.get(q.verseRef);
    const tooLong = verseCount(q.verseRef) > 2;
    if (!tooLong && (!current || fits(current))) continue;
    const better = wins.find(fits);
    if (better && better.ref !== q.verseRef) {
      q.verseRef = better.ref;
      fixed++;
    }
  }
  return fixed;
}

function conferir(trail) {
  const dir = trailDir(trail);
  const respDir = join(dir, 'manual', 'respostas');
  const fixDir = join(dir, 'manual', 'correcoes');
  mkdirSync(join(dir, 'cenas'), { recursive: true });
  mkdirSync(fixDir, { recursive: true });
  const packets = Object.fromEntries(packetsFor(trail, dir).map((p) => [p.mission.slug, p]));
  const files = existsSync(respDir) ? readdirSync(respDir).filter((f) => /\.(json|txt)$/.test(f)) : [];
  let ok = 0;
  const bad = [];
  for (const f of files) {
    const slug = slugOf(f);
    const packet = packets[slug];
    if (!packet) {
      console.log(`  ? ${f}: não é cena de ${trail}`);
      continue;
    }
    let result;
    let cena;
    let staged = 0;
    try {
      const raw = parseJsonReply(cleanPasted(readFileSync(join(respDir, f), 'utf8')));
      staged = autoStage(raw, packet);
      cena = hydrateCena(raw, packet);
      result = validateCenaData(cena, slug, { trail: packet.trail.slug, boss: packet.mission.type === 'boss' });
      result.errors.push(...scopeErrors(cena, packet));
    } catch (e) {
      result = { errors: [`a resposta não é um JSON completo (${e.message}); peça a cena inteira de novo, só o JSON`], warnings: [] };
    }
    if (!result.errors.length) {
      writeFileSync(join(dir, 'cenas', `${slug}.json`), `${JSON.stringify(cena, null, 2)}\n`);
      rmSync(join(fixDir, `${slug}.txt`), { force: true });
      ok++;
      console.log(`  ✓ ${slug}${staged ? ` (${staged} palco(s) ajustado(s))` : ''}${result.warnings.length ? ` (${result.warnings.length} aviso(s))` : ''}`);
    } else {
      writeFileSync(join(fixDir, `${slug}.txt`), `${fixPromptInChat(result.errors.slice(0, 40))}\n`);
      bad.push(slug);
      console.log(`  ✗ ${slug}: ${result.errors.length} erro(s)${staged ? ` (${staged} palco(s) já ajustados)` : ''} → cole manual/correcoes/${slug}.txt na mesma conversa`);
    }
  }
  const missing = Object.keys(packets).filter((s) => !existsSync(join(dir, 'cenas', `${s}.json`)) && !bad.includes(s));
  console.log(`\n${ok} cena(s) válidas agora · ${bad.length} para corrigir · ${missing.length} sem resposta ainda.`);
  if (!bad.length && !missing.length) {
    console.log(`Trilha completa. Próximo: shuffle_pilot_options.mjs, validate_pilot_v3.mjs --final e merge_pilot_v3.mjs com --trail ${trail}.`);
  }
}

/**
 * Pedidos de tradução no formato compacto: EN e ES de uma vez, só o que
 * falta (ou mudou no português), em lotes numerados. O mapa liga cada número
 * do lote à pergunta ou ao estudo.
 */
function traducao(trail, { completo }) {
  const p = pendingItems(trail);
  const dir = trailDir(trail);
  const out = join(dir, 'manual', 'traducao');
  const respDir = join(dir, 'manual', 'traducao-respostas');
  mkdirSync(out, { recursive: true });
  mkdirSync(respDir, { recursive: true });
  // Pedidos velhos saem (as respostas ficam); o mapa acumula.
  for (const f of readdirSync(out)) if (f.endsWith('.txt')) rmSync(join(out, f));
  const mapPath = join(dir, 'manual', 'traducao-mapa.json');
  const map = readJson(mapPath, {});
  const batches = batchesOf(p);
  batches.forEach((items, i) => {
    const id = createHash('sha1').update(items.map((it) => `${it.key}:${it.hash}`).join('|')).digest('hex').slice(0, 6);
    const name = `${nn(i)}-${id}`;
    map[id] = items.map(({ key, slug, tf, hash, src }) => ({ key, slug, tf, hash, src }));
    const req = buildRequest(items);
    const tail = 'Responda num único JSON: {"en":{"<n>":{...}},"es":{"<n>":{...}}}';
    writeFileSync(join(out, `${name}.txt`), completo ? `${systemBoth()}\n\n${req}\n` : `${req}\n\n${tail}\n`);
  });
  writeFileSync(mapPath, `${JSON.stringify(map)}\n`);
  mkdirSync(KIT_DIR, { recursive: true });
  writeFileSync(join(KIT_DIR, 'traducao_instrucoes.txt'), `${systemBoth()}\n`);
  if (!p.q.length && !p.s.length) saveTrail(p);
  console.log(`${trail}: ${p.q.length}/${p.total} pergunta(s) e ${p.s.length} estudo(s) a traduzir → ${batches.length} pedido(s) em ${out}`);
  if (batches.length) {
    console.log(`Cole cada pedido numa conversa ${completo ? 'nova' : 'do Projeto de tradução (instruções em v3/_chatgpt/traducao_instrucoes.txt)'} e salve a resposta em manual/traducao-respostas/<mesmo nome>.json`);
  }
}

/** Fim do objeto que abre em `start` (respeita strings); -1 se não fecha. */
function objectEnd(t, start) {
  let depth = 0;
  let inStr = false;
  let esc = false;
  for (let i = start; i < t.length; i++) {
    const ch = t[i];
    if (inStr) {
      if (esc) esc = false;
      else if (ch === '\\') esc = true;
      else if (ch === '"') inStr = false;
      continue;
    }
    if (ch === '"') inStr = true;
    else if (ch === '{') depth++;
    else if (ch === '}' && --depth === 0) return i;
  }
  return -1;
}

const ITEM_KEYS = new Set(['q', 'c', 'w', 'h', 'o', 'x', 'f', 'k', 'r', 't']);
const SPANISH = /[¿¡ñ]|\b(el|los|las|del|que|una|por|para)\b/gi;
const ENGLISH = /\b(the|and|of|to|what|which|is|does)\b/gi;
const looksSpanish = (s) => (s.match(SPANISH) || []).length > (s.match(ENGLISH) || []).length;

/**
 * Resposta do lote como {en, es}, lida item a item: aceita {"en","es"}, um
 * bloco por idioma, agrupamentos copiados do pedido e chaves fechadas a mais.
 */
function translationReply(text) {
  const t = String(text || '');
  const esAt = t.search(/"es"\s*:\s*\{/);
  const enAt = t.search(/"en"\s*:\s*\{/);
  const reply = { en: {}, es: {} };
  // Sem "en"/"es": um bloco de primeiro nível por idioma; o idioma é o do bloco inteiro.
  const blocks = [];
  for (let i = 0; i < t.length; i++) {
    if (t[i] !== '{') continue;
    const end = objectEnd(t, i);
    if (end < 0) break;
    blocks.push({ start: i, end, lang: looksSpanish(t.slice(i, end + 1)) ? 'es' : 'en' });
    i = end;
  }
  const blockLang = (pos) => (blocks.find((b) => pos >= b.start && pos <= b.end) || { lang: 'en' }).lang;
  const re = /"(\d+)"\s*:\s*\{/g;
  let m;
  let found = 0;
  while ((m = re.exec(t))) {
    const start = m.index + m[0].length - 1;
    const end = objectEnd(t, start);
    if (end < 0) continue;
    let obj;
    try {
      obj = JSON.parse(t.slice(start, end + 1));
    } catch {
      continue;
    }
    const keys = Object.keys(obj);
    if (!keys.length || !keys.every((k) => ITEM_KEYS.has(k))) continue;
    let lang;
    if (esAt >= 0 && enAt >= 0) lang = (esAt > enAt ? m.index > esAt : m.index < enAt) ? 'es' : 'en';
    else lang = blockLang(m.index);
    reply[lang][m[1]] = obj;
    found++;
    re.lastIndex = end + 1;
  }
  if (!found) throw new Error('Resposta sem itens traduzidos.');
  return reply;
}

function conferirTraducao(trail) {
  const dir = trailDir(trail);
  const respDir = join(dir, 'manual', 'traducao-respostas');
  const map = readJson(join(dir, 'manual', 'traducao-mapa.json'), {});
  const p = pendingItems(trail);
  const pending = new Map([...p.q, ...p.s].map((it) => [it.key, it]));
  const files = existsSync(respDir) ? readdirSync(respDir).filter((f) => /^\d{2}-[0-9a-f]{6}\.(json|txt)$/.test(f)) : [];
  let accepted = 0;
  for (const f of files) {
    let reply;
    try {
      reply = translationReply(readFileSync(join(respDir, f), 'utf8'));
    } catch (e) {
      console.log(`  ✗ ${f}: ${e.message}`);
      continue;
    }
    // O nome diz o lote; se a resposta for de outro lote ainda pendente, vale o que encaixa melhor.
    const score = (its) => checkReply(its, reply).ok.size;
    let id = f.slice(3, 9);
    let best = map[id] ? score(map[id]) : -1;
    for (const [other, its] of Object.entries(map)) {
      if (other === id) continue;
      const sc = score(its);
      if (sc > best) [id, best] = [other, sc];
    }
    const items = map[id];
    // Encaixe fraco = resposta de outra coisa: não aceita nada por coincidência.
    if (!items || best < Math.ceil(items.length * 0.8)) {
      console.log(`  ? ${f}: não bate com nenhum pedido (salvou a resposta certa?)`);
      continue;
    }
    if (id !== f.slice(3, 9)) console.log(`  … ${f} é a resposta do pedido ${id}`);
    const { ok, failed } = checkReply(items, reply);
    let n = 0;
    let stale = 0;
    for (const it of items) {
      const tr = ok.get(it.key);
      const cur = pending.get(it.key);
      if (!tr || !cur) continue;
      // Português mudou depois do pedido: a tradução não vale mais.
      if (cur.hash !== it.hash) {
        stale++;
        continue;
      }
      storeTranslation(p, cur, tr);
      pending.delete(it.key);
      n++;
    }
    accepted += n;
    const notes = [failed.length ? `${failed.length} com problema (${failed[0].errs[0]})` : '', stale ? `${stale} com português mudado` : '']
      .filter(Boolean)
      .join('; ');
    console.log(`  ${failed.length ? '△' : '✓'} ${f}: ${n} aceito(s)${notes ? ` · ${notes}` : ''}`);
  }
  saveTrail(p);
  const left = pending.size;
  console.log(`${trail}: ${accepted} item(ns) aceitos agora · faltam ${left}.`);
  console.log(
    left
      ? `Para o que falta: node admin/scripts/v3_manual.mjs traducao --trail ${trail} (gera só os pendentes)`
      : `Completo. Aplique: node admin/scripts/v3_translate.mjs --trail ${trail} --apply`,
  );
}

const [cmd] = process.argv.slice(2);
const trail = argValue('--trail');
const needTrail = () => {
  if (!trail) throw new Error('Informe --trail <slug>.');
  return trail;
};
try {
  if (cmd === 'kit') kit();
  else if (cmd === 'pedidos') pedidos(needTrail(), { completo: process.argv.includes('--completo') });
  else if (cmd === 'conferir') conferir(needTrail());
  else if (cmd === 'traducao') traducao(needTrail(), { completo: process.argv.includes('--completo') });
  else if (cmd === 'conferir-traducao') conferirTraducao(needTrail());
  else {
    console.log('Uso: node admin/scripts/v3_manual.mjs kit | pedidos | conferir | traducao | conferir-traducao --trail <slug>');
    process.exitCode = 1;
  }
} catch (e) {
  console.error(e.message || e);
  process.exit(1);
}
