/**
 * Traduz o banco V3 de uma trilha para inglês e espanhol (overlays do app).
 *
 *   node admin/scripts/v3_translate.mjs --trail mateus --provider anthropic [--langs en,es]
 *   node admin/scripts/v3_translate.mjs --trail mateus --apply
 *
 * Lê questions_v3.json e studies_v3.json (merge_pilot_v3.mjs) e escreve
 * <pasta da trilha>/l10n/{questions,studies}_<lang>.json. Com --apply, troca as
 * entradas da trilha em trilha_app/assets/l10n/content/{questions,studies}_<lang>.json
 * (as entradas antigas com os mesmos ids saem: elas eram da V2).
 *
 * O versículo na tela fica em português, então palavras citadas dele ficam em
 * português entre aspas; opções que são pedaços do versículo não se traduzem.
 */
import { existsSync, mkdirSync, writeFileSync } from 'fs';
import { join } from 'path';
import { complete, parseJsonReply } from './_llm.mjs';
import { APP_L10N, argValue, readJson, trailDir } from './_v3_paths.mjs';

const BATCH = 20;
const LANG = {
  en: { name: 'inglês', bible: 'Genesis, Exodus, John, Psalms, Romans…', tf: { true: 'True', false: 'False' } },
  es: { name: 'espanhol (neutro da América Latina, com "tú")', bible: 'Génesis, Éxodo, Juan, Salmos, Romanos…', tf: { true: 'Verdadero', false: 'Falso' } },
};

/** Opções que são texto da pessoa (não pedaço do versículo) se traduzem. */
function translatableOptions(q) {
  if (q.type === 'choice' || q.type === 'connect') return true;
  return q.type === 'order' && q.difficulty !== 'semente';
}

function questionSource(q) {
  const e = {
    question: q.question,
    learningObjective: q.learningObjective,
    feedbackCorrect: q.feedbackCorrect,
    feedbackWrong: q.feedbackWrong,
    hint: q.hint,
  };
  if (translatableOptions(q)) e.options = Object.fromEntries(q.options.map((o) => [o.id, o.text]));
  return e;
}

function studySource(s) {
  return {
    context: s.context,
    focusQuestion: s.focusQuestion,
    keywordGloss: s.keywordGloss,
    reflectionPrompts: s.reflectionPrompts,
    facts: (s.facts || []).map((f) => f.text),
  };
}

function system(lang) {
  const L = LANG[lang];
  return `Você traduz conteúdo de um app de formação bíblica (STWAY) do português do Brasil para ${L.name}.

Regras:
- O versículo na tela continua em PORTUGUÊS. Quando um texto cita ou aponta palavra ou trecho do versículo da cena (campo "_verso"), mantenha essa citação em português, exatamente como está, entre aspas. Ex.: "\\"Porém\\" vira a página" → em inglês "\\"Porém\\" turns the page".
- Citações de outros livros da Bíblia (que não estão no "_verso") vão traduzidas.
- Referências bíblicas no idioma de destino (${L.bible}). Mantenha o travessão nas faixas (1:1–2).
- Afirmações de verdadeiro ou falso continuam afirmações, nunca perguntas.
- Tamanho parecido com o original: feedbackCorrect até 100 caracteres, hint até 90, opções até 80. Uma linha cada.
- Tom claro e respeitoso, sem arcaísmos. Deus com pronome ele/him/él, como no original.
- Não acrescente nem tire chaves. Não traduza ids nem chaves.

Responda só com um objeto JSON: as mesmas chaves do pedido, cada valor com os campos traduzidos (sem "_verso").`;
}

function checkEntry(src, tr, key) {
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

async function translateBatch(lang, entries, opts) {
  for (let attempt = 0; attempt < 3; attempt++) {
    const reply = await complete({
      provider: opts.provider,
      model: opts.model,
      system: system(lang),
      user: JSON.stringify(entries, null, 1),
      maxTokens: 32000,
      effort: opts.effort,
      tag: `tr-${lang}`,
    });
    opts.totals.input += reply.usage.input;
    opts.totals.output += reply.usage.output;
    try {
      const out = parseJsonReply(reply.text);
      const errs = Object.keys(entries).flatMap((k) => (out[k] ? checkEntry(entries[k], out[k], k) : [`${k}: faltou`]));
      if (!errs.length) return out;
      console.log(`    … ${errs.length} problema(s), refazendo: ${errs.slice(0, 3).join('; ')}`);
    } catch (e) {
      console.log(`    … resposta inválida (${e.message}), refazendo`);
    }
  }
  throw new Error('Tradução do lote falhou 3 vezes.');
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

async function main() {
  const trail = argValue('--trail');
  if (!trail) throw new Error('Informe --trail <slug>.');
  const langs = (argValue('--langs') || 'en,es').split(',').map((s) => s.trim());
  const dir = trailDir(trail);
  mkdirSync(join(dir, 'l10n'), { recursive: true });

  if (process.argv.includes('--apply')) {
    for (const lang of langs) apply(trail, lang, dir);
    return;
  }

  const provider = argValue('--provider') || 'anthropic';
  const opts = {
    provider,
    model: argValue('--model') || (provider === 'anthropic' ? 'claude-opus-5-5' : undefined),
    effort: argValue('--effort') || 'medium',
    totals: { input: 0, output: 0 },
  };
  if (!opts.model && provider === 'openai') throw new Error('Informe --model para o fornecedor openai.');
  const questions = readJson(join(dir, 'questions_v3.json'));
  const { studies } = readJson(join(dir, 'studies_v3.json'));

  for (const lang of langs) {
    const outQ = join(dir, 'l10n', `questions_${lang}.json`);
    const done = existsSync(outQ) ? readJson(outQ) : {};
    const pending = questions.filter((q) => !done[q.id]);
    console.log(`${lang}: ${pending.length} pergunta(s) a traduzir`);
    for (let i = 0; i < pending.length; i += BATCH) {
      const slice = pending.slice(i, i + BATCH);
      const entries = Object.fromEntries(slice.map((q) => [q.id, { ...questionSource(q), _verso: q.passageText }]));
      const out = await translateBatch(lang, entries, opts);
      for (const q of slice) {
        const e = { ...out[q.id] };
        delete e._verso;
        if (q.type === 'true_false') e.options = LANG[lang].tf;
        done[q.id] = e;
      }
      // Grava a cada lote: uma queda não perde o que já foi pago.
      writeFileSync(outQ, `${JSON.stringify(done, null, 1)}\n`);
      console.log(`  ${Object.keys(done).length}/${questions.length}`);
    }
    const sEntries = Object.fromEntries(Object.entries(studies).map(([slug, s]) => [slug, { ...studySource(s), _verso: s.passageText }]));
    const sOut = await translateBatch(lang, sEntries, opts);
    for (const v of Object.values(sOut)) delete v._verso;
    writeFileSync(join(dir, 'l10n', `studies_${lang}.json`), `${JSON.stringify(sOut, null, 1)}\n`);
  }
  const t = opts.totals;
  console.log(`\n✓ Tradução pronta em ${join(dir, 'l10n')}. Tokens: entrada ${t.input} · saída ${t.output}.`);
  console.log(`Revise e rode: node admin/scripts/v3_translate.mjs --trail ${trail} --apply`);
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
