/**
 * Traduz o banco V3 de uma trilha para inglês e espanhol (overlays do app).
 *
 *   node admin/scripts/v3_translate.mjs --trail mateus --dry          # só conta o que falta
 *   node admin/scripts/v3_translate.mjs --trail mateus [--model id] [--effort low] [--max-batches 1]
 *   node admin/scripts/v3_translate.mjs --trail mateus --apply
 *
 * Lê questions_v3.json e studies_v3.json (merge_pilot_v3.mjs) e escreve
 * <pasta da trilha>/l10n/{questions,studies}_<lang>.json. Com --apply, troca as
 * entradas da trilha em trilha_app/assets/l10n/content/{questions,studies}_<lang>.json
 * (as entradas antigas com os mesmos ids saem: elas eram da V2).
 *
 * O versículo na tela fica em português, então palavras citadas dele ficam em
 * português entre aspas; opções que são pedaços do versículo não se traduzem.
 *
 * Economia de tokens:
 * - EN e ES saem do mesmo pedido (o português vai uma vez só).
 * - Chaves curtas e número no lugar do id; JSON sem espaços.
 * - O versículo vai uma vez por grupo de perguntas que o compartilham.
 * - `learningObjective` não se traduz (nenhuma tela mostra).
 * - l10n/_hash.json guarda o carimbo do português de cada item: só o que
 *   mudou (ou falta) volta para a tradução. Lote que falha refaz só os itens
 *   com problema.
 */
import { createHash } from 'crypto';
import { existsSync, mkdirSync, writeFileSync } from 'fs';
import { join } from 'path';
import { pathToFileURL } from 'url';
import { complete, parseJsonReply } from './_llm.mjs';
import { APP_L10N, argValue, readJson, trailDir } from './_v3_paths.mjs';

const BATCH_Q = 40;
const BATCH_S = 12;
export const LANGS = ['en', 'es'];
export const LANG = {
  en: { name: 'inglês', bible: 'Genesis, Exodus, John, Psalms, Romans…', tf: { true: 'True', false: 'False' } },
  es: { name: 'espanhol (neutro da América Latina, com "tú")', bible: 'Génesis, Éxodo, Juan, Salmos, Romanos…', tf: { true: 'Verdadero', false: 'Falso' } },
};

/** Opções que são texto da pessoa (não pedaço do versículo) se traduzem. */
export function translatableOptions(q) {
  if (q.type === 'choice' || q.type === 'connect') return true;
  return q.type === 'order' && q.difficulty !== 'semente';
}

/** Campos que a tela mostra (learningObjective fica de fora: nenhuma tela usa). */
export function questionSource(q) {
  const e = {
    question: q.question,
    feedbackCorrect: q.feedbackCorrect,
    feedbackWrong: q.feedbackWrong,
    hint: q.hint,
  };
  if (translatableOptions(q)) e.options = Object.fromEntries(q.options.map((o) => [o.id, o.text]));
  return e;
}

export function studySource(s) {
  return {
    context: s.context,
    focusQuestion: s.focusQuestion,
    keywordGloss: s.keywordGloss,
    reflectionPrompts: s.reflectionPrompts,
    facts: (s.facts || []).map((f) => f.text),
  };
}

const RULES = (target, bibles) => `- O versículo na tela continua em PORTUGUÊS. Quando um texto cita ou aponta palavra ou trecho do versículo da cena, mantenha essa citação em português, exatamente como está, entre aspas. Ex.: "\\"Porém\\" vira a página" → em inglês "\\"Porém\\" turns the page".
- Citações de outros livros da Bíblia (que não estão no versículo) vão traduzidas.
- Referências bíblicas no idioma de destino (${bibles}). Mantenha o travessão nas faixas (1:1–2).
- Afirmações de verdadeiro ou falso continuam afirmações, nunca perguntas.
- Tamanho parecido com o original: feedback até 100 caracteres, dica até 90, opções até 80. Uma linha cada.
- Tom claro e respeitoso, sem arcaísmos. Deus com pronome ele/him/él, como no original.
- Não acrescente nem tire chaves. Não traduza ids nem chaves.${target}`;

/** Regras para um idioma (rota manual, v3_manual.mjs traducao). */
export function system(lang) {
  const L = LANG[lang];
  return `Você traduz conteúdo de um app de formação bíblica (STWAY) do português do Brasil para ${L.name}.

Regras:
${RULES('', L.bible)}

Responda só com um objeto JSON: as mesmas chaves do pedido, cada valor com os campos traduzidos (sem "_verso").`;
}

/** Regras do pedido compacto: EN e ES de uma vez. */
export function systemBoth() {
  return `Você traduz conteúdo de um app de formação bíblica (STWAY) do português do Brasil para inglês e para espanhol (neutro da América Latina, com "tú").

Entrada: JSON {"g":[{"v":"versículo da cena","i":{"<n>":{...}}}]}. Chaves dos itens: q=enunciado, c=feedback de acerto, w=feedback de erro por opção, h=dica, o=opções, x=contexto, f=pergunta-foco, k=glosa da palavra-chave, r=perguntas de reflexão (lista), t=fatos (lista). "v" é só referência: não traduza nem devolva.

Regras:
${RULES('', 'Genesis, John, Psalms… / Génesis, Juan, Salmos…')}
- Listas com o mesmo tamanho e a mesma ordem.

Responda só com JSON compacto, sem espaços nem explicação: {"en":{"<n>":{...}},"es":{"<n>":{...}}}, com os mesmos números e as mesmas chaves de cada item.`;
}

export function checkEntry(src, tr, key) {
  const errs = [];
  for (const f of Object.keys(src)) {
    if (f.startsWith('_')) continue;
    if (tr[f] === undefined) errs.push(`${key}: falta ${f}`);
  }
  for (const f of ['feedbackWrong', 'options']) {
    if (src[f] && JSON.stringify(Object.keys(src[f]).sort()) !== JSON.stringify(Object.keys(tr[f] || {}).sort())) errs.push(`${key}: chaves de ${f}`);
  }
  for (const f of ['reflectionPrompts', 'facts']) {
    if (Array.isArray(src[f]) && (!Array.isArray(tr[f]) || tr[f].length !== src[f].length)) errs.push(`${key}: ${f} com tamanho diferente`);
  }
  return errs;
}

// ---- chaves curtas ----------------------------------------------------------
const SHORT = {
  question: 'q', feedbackCorrect: 'c', feedbackWrong: 'w', hint: 'h', options: 'o',
  context: 'x', focusQuestion: 'f', keywordGloss: 'k', reflectionPrompts: 'r', facts: 't',
};
const LONG = Object.fromEntries(Object.entries(SHORT).map(([l, s]) => [s, l]));
const isEmpty = (v) => v == null || v === '' || (Array.isArray(v) && !v.length) || (typeof v === 'object' && !Array.isArray(v) && !Object.keys(v).length);

export function toShort(src) {
  const out = {};
  for (const [k, v] of Object.entries(src)) if (!isEmpty(v)) out[SHORT[k] ?? k] = v;
  return out;
}

/** Volta às chaves longas; campo vazio no português volta como estava. */
export function fromShort(tr, src) {
  const out = {};
  for (const [k, v] of Object.entries(src)) out[k] = isEmpty(v) ? v : tr?.[SHORT[k] ?? k];
  for (const k of Object.keys(out)) if (out[k] === undefined) delete out[k];
  return out;
}

export function hashOf(src, verse) {
  return createHash('sha1').update(JSON.stringify([src, verse || ''])).digest('hex').slice(0, 12);
}

/** Lotes compactos: itens agrupados pelo versículo que compartilham. */
export function buildRequest(items) {
  const groups = new Map();
  items.forEach((it, i) => {
    const v = it.verse || '';
    if (!groups.has(v)) groups.set(v, {});
    groups.get(v)[String(i + 1)] = toShort(it.src);
  });
  return JSON.stringify({ g: [...groups].map(([v, i]) => (v ? { v, i } : { i })) });
}

async function translateItems(items, opts) {
  const done = new Map();
  let pending = items;
  for (let attempt = 0; attempt < 3 && pending.length; attempt++) {
    const reply = await complete({
      provider: opts.provider,
      model: opts.model,
      system: systemBoth(),
      user: buildRequest(pending),
      maxTokens: 64000,
      effort: opts.effort,
      tag: `tr-${opts.tag}-${attempt}`,
    });
    opts.totals.input += reply.usage.input + (reply.usage.cached || 0);
    opts.totals.output += reply.usage.output;
    opts.totals.calls++;
    let out;
    try {
      out = parseJsonReply(reply.text);
    } catch (e) {
      console.log(`    … resposta inválida (${e.message}), refazendo`);
      continue;
    }
    const { ok, failed } = checkReply(pending, out);
    for (const [k, v] of ok) done.set(k, v);
    if (failed.length) {
      console.log(`    … ${failed.length} item(ns) com problema, refazendo só eles: ${failed.slice(0, 2).flatMap((f) => f.errs).join('; ')}`);
    }
    pending = failed.map((f) => f.it);
  }
  if (pending.length) console.log(`    ✗ ${pending.length} item(ns) sem tradução válida depois de 3 tentativas (ficam para a próxima rodada)`);
  return done;
}

function apply(trail, lang, dir) {
  const qPath = join(APP_L10N, `questions_${lang}.json`);
  const sPath = join(APP_L10N, `studies_${lang}.json`);
  const qNew = readJson(join(dir, 'l10n', `questions_${lang}.json`));
  const sNew = readJson(join(dir, 'l10n', `studies_${lang}.json`));
  const qAll = readJson(qPath);
  const sAll = readJson(sPath);
  const before = Object.keys(qAll).filter((k) => k.startsWith(`${trail}-`)).length;
  for (const k of Object.keys(qAll)) if (k.startsWith(`${trail}-`)) delete qAll[k];
  Object.assign(qAll, qNew);
  Object.assign(sAll, sNew);
  // questions_*.json é uma linha só; studies_*.json é indentado.
  writeFileSync(qPath, JSON.stringify(qAll));
  writeFileSync(sPath, `${JSON.stringify(sAll, null, 2)}\n`);
  console.log(`  ${lang}: ${before} entrada(s) antigas de ${trail} trocadas por ${Object.keys(qNew).length}; ${Object.keys(sNew).length} estudo(s)`);
}

/** Lotes de perguntas e de estudos (o mesmo corte da API e da rota manual). */
export function batchesOf(p) {
  const out = [];
  for (let i = 0; i < p.q.length; i += BATCH_Q) out.push(p.q.slice(i, i + BATCH_Q));
  for (let i = 0; i < p.s.length; i += BATCH_S) out.push(p.s.slice(i, i + BATCH_S));
  return out;
}

/** Grava uma tradução aceita nos overlays da trilha (em memória, em `p.out`). */
export function storeTranslation(p, it, tr) {
  for (const lang of LANGS) {
    if (it.slug) p.out[`s_${lang}`][it.slug] = tr[lang];
    else p.out[`q_${lang}`][it.key] = it.tf ? { ...tr[lang], options: LANG[lang].tf } : tr[lang];
  }
  p.hashes[it.key] = it.hash;
}

export function saveTrail(p) {
  mkdirSync(p.l10n, { recursive: true });
  for (const lang of LANGS) {
    writeFileSync(join(p.l10n, `questions_${lang}.json`), `${JSON.stringify(p.out[`q_${lang}`], null, 1)}\n`);
    writeFileSync(join(p.l10n, `studies_${lang}.json`), `${JSON.stringify(p.out[`s_${lang}`], null, 1)}\n`);
  }
  writeFileSync(p.hashPath, `${JSON.stringify(p.hashes)}\n`);
}

/** Confere a resposta de um lote: devolve as traduções válidas e os erros. */
export function checkReply(items, out) {
  const ok = new Map();
  const failed = [];
  items.forEach((it, i) => {
    const n = String(i + 1);
    const tr = {};
    const errs = [];
    for (const lang of LANGS) {
      const e = fromShort(out?.[lang]?.[n], it.src);
      errs.push(...(out?.[lang]?.[n] ? checkEntry(it.src, e, `${lang}:${it.key}`) : [`${lang}:${it.key}: faltou`]));
      tr[lang] = e;
    }
    if (errs.length) failed.push({ it, errs });
    else ok.set(it.key, tr);
  });
  return { ok, failed };
}

/** O que falta traduzir: sem tradução nos dois idiomas ou com português mudado. */
export function pendingItems(trail) {
  const dir = trailDir(trail);
  const questions = readJson(join(dir, 'questions_v3.json'));
  const sp = join(dir, 'studies_v3.json');
  const studies = existsSync(sp) ? readJson(sp).studies || {} : {};
  const l10n = join(dir, 'l10n');
  const hashPath = join(l10n, '_hash.json');
  const out = Object.fromEntries(LANGS.flatMap((lang) => [
    [`q_${lang}`, readJson(join(l10n, `questions_${lang}.json`), {})],
    [`s_${lang}`, readJson(join(l10n, `studies_${lang}.json`), {})],
  ]));
  const hadHashes = existsSync(hashPath);
  const hashes = readJson(hashPath, {});
  const q = [];
  const s = [];
  for (const x of questions) {
    const src = questionSource(x);
    const h = hashOf(src, x.passageText);
    const have = LANGS.every((l) => out[`q_${l}`][x.id]);
    // Trilha traduzida antes do carimbo: o que já existe vale como atual.
    if (have && !hadHashes) hashes[x.id] = h;
    if (!have || hashes[x.id] !== h) q.push({ key: x.id, src, verse: x.passageText, hash: h, tf: x.type === 'true_false' });
  }
  for (const [slug, st] of Object.entries(studies)) {
    const src = studySource(st);
    const h = hashOf(src, st.passageText);
    const key = `estudo:${slug}`;
    const have = LANGS.every((l) => out[`s_${l}`][slug]);
    if (have && !hadHashes) hashes[key] = h;
    if (!have || hashes[key] !== h) s.push({ key, slug, src, verse: st.passageText, hash: h });
  }
  return { dir, l10n, hashPath, hashes, out, q, s, total: questions.length };
}

async function main() {
  const trail = argValue('--trail');
  if (!trail) throw new Error('Informe --trail <slug>.');
  const dir = trailDir(trail);
  mkdirSync(join(dir, 'l10n'), { recursive: true });

  if (process.argv.includes('--apply')) {
    for (const lang of (argValue('--langs') || 'en,es').split(',')) apply(trail, lang.trim(), dir);
    return;
  }

  const p = pendingItems(trail);
  const batches = batchesOf(p);
  const chars = batches.reduce((sum, b) => sum + buildRequest(b).length + systemBoth().length, 0);
  console.log(`${trail}: ${p.q.length}/${p.total} pergunta(s) e ${p.s.length} estudo(s) a traduzir (EN+ES) · ~${Math.round(chars / 3.2 / 1000)} mil tokens de entrada`);
  if (process.argv.includes('--dry') || (!p.q.length && !p.s.length)) {
    if (!p.q.length && !p.s.length) saveTrail(p);
    return;
  }

  const provider = argValue('--provider') || 'anthropic';
  const opts = {
    provider,
    model: argValue('--model') || (provider === 'anthropic' ? 'claude-opus-5-5' : undefined),
    effort: argValue('--effort') || 'low',
    totals: { input: 0, output: 0, calls: 0 },
  };
  if (!opts.model && provider === 'openai') throw new Error('Informe --model para o fornecedor openai.');
  const maxBatches = Number(argValue('--max-batches') || Infinity);

  let n = 0;
  for (const batch of batches) {
    if (n++ >= maxBatches) break;
    opts.tag = `${trail}-${n}`;
    const done = await translateItems(batch, opts);
    for (const it of batch) {
      const tr = done.get(it.key);
      if (tr) storeTranslation(p, it, tr);
    }
    // Grava a cada lote: uma queda não perde o que já foi pago.
    saveTrail(p);
    const t = opts.totals;
    console.log(`  lote ${n}/${batches.length} · tokens até aqui: entrada ${t.input} · saída ${t.output}`);
  }
  const t = opts.totals;
  console.log(`\n✓ ${join(dir, 'l10n')} · ${t.calls} chamada(s) · tokens: entrada ${t.input} · saída ${t.output} · total ${t.input + t.output}`);
  console.log(`Revise e rode: node admin/scripts/v3_translate.mjs --trail ${trail} --apply`);
}

if (import.meta.url === pathToFileURL(process.argv[1] || '').href) {
  main().catch((e) => {
    console.error(e.message || e);
    process.exit(1);
  });
}
