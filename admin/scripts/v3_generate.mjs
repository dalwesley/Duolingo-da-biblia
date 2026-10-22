/**
 * Gera as cenas V3 de uma trilha com um modelo de linguagem, valida cada uma
 * contra a JFAAL e a especificação, e devolve os erros ao modelo até passar.
 *
 *   node admin/scripts/v3_generate.mjs --trail mateus --provider openai --model <id>
 *   node admin/scripts/v3_generate.mjs --trail mateus --provider anthropic [--model claude-opus-5-5]
 *
 * Opções:
 *   --only a,b        só estas cenas (slugs)
 *   --limit N         no máximo N cenas nesta rodada
 *   --retries N       correções depois da primeira tentativa (padrão 2)
 *   --concurrency N   cenas em paralelo (padrão 2)
 *   --effort nível    esforço no fornecedor anthropic (padrão high)
 *   --force           refaz cenas que já existem em cenas/
 *   --dry-run         só monta os prompts em log/ e estima o tamanho
 *
 * Antes: node admin/scripts/v3_inputs.mjs --trail <slug>
 * Depois: shuffle_pilot_options.mjs → validate_pilot_v3.mjs --final → merge_pilot_v3.mjs
 *         (todos com --trail <slug>), revisão humana, v3_translate.mjs, publish_pilot_v3.mjs.
 *
 * Saída: cenas/<slug>.json (válidas), falhas/<slug>.json (com os erros), e
 * log/usage.jsonl com os tokens de cada chamada.
 */
import { appendFileSync, existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from 'fs';
import { join } from 'path';
import { complete, parseJsonReply } from './_llm.mjs';
import { compactCena, hydrateCena } from './_v3_hydrate.mjs';
import { PILOT_DIR, SPEC_PATH, argValue, readJson, trailDir } from './_v3_paths.mjs';
import { validateCenaData } from './validate_pilot_v3.mjs';

const EXAMPLES = { lesson: 'gen-01-criador', boss: 'gen-boss-01' };

/** Instruções fixas: iguais em todas as cenas, para o fornecedor guardar em cache. */
function systemPrompt() {
  const spec = readFileSync(SPEC_PATH, 'utf8');
  const example = (slug) => JSON.stringify(compactCena(readJson(join(PILOT_DIR, 'cenas', `${slug}.json`))), null, 1);
  return `Você é editor pedagógico do STWAY, app de formação bíblica em português do Brasil. Você escreve o banco V3 de uma cena: o estudo e as perguntas dos três modos (Observação = semente, Compreensão = caminhada, Interpretação = profundezas).

A especificação abaixo é a regra. A trilha de exemplo é Gênesis 1–11; para outra trilha, troque o prefixo dos ids e as referências, e mantenha tudo o mais.

<especificacao>
${spec}
</especificacao>

<formato_de_saida>
Responda com UM objeto JSON e nada mais: {"study": {...}, "questions": [...]}.

Um script completa a cena depois. NÃO escreva estes campos (ele preenche):
- em cada pergunta: id, trail, section, skill, prompt, cue, passageText, template, correctAnswer; no V/F, options; no Ordenar, correctOptionId;
- no estudo: slug, passageText, relatedVerses; em passages, crossRefs, passageA e passageB com referência bíblica, escreva só "ref" (o texto vem da JFAAL). Exceção: passageA pode trazer "text" quando for um recorte exato de parte do versículo.

Ordem das perguntas: todas as de semente, depois caminhada, depois profundezas; dentro do modo, na ordem dos gestos (lição: 01 V/F, 02 Toque, 03 Escolha, 04 Ordenar, 05 Completar, 06 Conectar; desafio: as mesmas e mais 07 Toque e 08 Ordenar). O número do id é a posição da pergunta no modo.

Texto bíblico: use SÓ os versos que vêm no pedido (campo "verses"), copiados letra por letra. verseRef de cada pergunta: um capítulo, até 2 versos, escolhidos desses versos. evidenceSpan, opções do Toque, peças da Observação no Ordenar, facts[].evidenceSpan, keyTerms[].term e relations[].marker saem literalmente desse texto. Para crossRefs e Conectar (Compreensão e Interpretação), escolha referências reais de 1 ou 2 versos que você conhece bem; o script põe o texto.

Nome de Deus: escreva "Senhor", como a JFAAL. Os dados da V2 às vezes dizem "Jeová" (outra tradução); não copie.

Se o "centralInsight" da cena vier cortado (termina em "…") ou genérico, escreva em study.centralInsight um insight próprio da cena, até 140 caracteres. Senão, copie o da cena.
</formato_de_saida>

<exemplo_licao>
${example(EXAMPLES.lesson)}
</exemplo_licao>

<exemplo_desafio>
${example(EXAMPLES.boss)}
</exemplo_desafio>`;
}

function userPrompt(packet, index) {
  const boss = packet.mission.type === 'boss';
  // V/F equilibrado na trilha: cenas pares com 2 verdadeiras, ímpares com 1.
  const trues = index % 2 === 0 ? 2 : 1;
  return `Escreva a cena "${packet.mission.slug}" da trilha "${packet.trail.slug}" (${packet.trail.title}).
Tipo: ${boss ? 'desafio — 8 perguntas por modo, misturando as cenas anteriores do bloco' : 'lição — 6 perguntas por modo'}.
V/F: ${trues === 1 ? '1 das 3 afirmações (uma por modo) deve ser verdadeira' : '2 das 3 afirmações (uma por modo) devem ser verdadeiras'}.

<cena>
${JSON.stringify(packet, null, 1)}
</cena>`;
}

function fixPrompt(packet, index, previous, errors) {
  return `${userPrompt(packet, index)}

Sua versão anterior falhou na validação. Corrija TODOS os erros abaixo e devolva a cena inteira, no mesmo formato.

<erros>
${errors.map((e) => `- ${e}`).join('\n')}
</erros>

<versao_anterior>
${previous}
</versao_anterior>`;
}

async function runScene({ packet, index, dir, opts, system }) {
  const slug = packet.mission.slug;
  const boss = packet.mission.type === 'boss';
  let user = userPrompt(packet, index);
  let last = { errors: ['sem resposta'], warnings: [] };
  for (let attempt = 0; attempt <= opts.retries; attempt++) {
    const started = Date.now();
    let reply;
    try {
      reply = await complete({ provider: opts.provider, model: opts.model, system, user, maxTokens: opts.maxTokens, effort: opts.effort, tag: slug });
    } catch (e) {
      last = { errors: [`chamada falhou: ${e.message}`], warnings: [] };
      log(dir, { slug, attempt, error: e.message });
      break;
    }
    let cena;
    let raw = reply.text;
    try {
      if (reply.stop === 'refusal') throw new Error('o modelo recusou');
      if (reply.stop === 'max_tokens') throw new Error('resposta cortada no limite de tokens');
      cena = hydrateCena(parseJsonReply(raw), packet);
      last = validateCenaData(cena, slug, { trail: packet.trail.slug, boss });
    } catch (e) {
      last = { errors: [`resposta inválida: ${e.message}`], warnings: [] };
    }
    log(dir, {
      slug,
      attempt,
      provider: opts.provider,
      model: reply.model || opts.model,
      ms: Date.now() - started,
      usage: reply.usage,
      stop: reply.stop,
      errors: last.errors.length,
      warnings: last.warnings?.length ?? 0,
    });
    opts.totals.input += reply.usage.input;
    opts.totals.output += reply.usage.output;
    opts.totals.cached += reply.usage.cached;
    if (cena && !last.errors.length) {
      writeFileSync(join(dir, 'cenas', `${slug}.json`), `${JSON.stringify(cena, null, 2)}\n`);
      console.log(`  ✓ ${slug} (tentativa ${attempt + 1}${last.warnings.length ? `, ${last.warnings.length} avisos` : ''})`);
      return true;
    }
    console.log(`  … ${slug}: ${last.errors.length} erro(s) na tentativa ${attempt + 1}`);
    user = fixPrompt(packet, index, raw.slice(0, 60000), last.errors.slice(0, 40));
  }
  writeFileSync(join(dir, 'falhas', `${slug}.json`), `${JSON.stringify({ errors: last.errors, warnings: last.warnings }, null, 2)}\n`);
  console.log(`  ✗ ${slug}: falhou — veja falhas/${slug}.json`);
  return false;
}

function log(dir, entry) {
  appendFileSync(join(dir, 'log', 'usage.jsonl'), `${JSON.stringify({ at: new Date().toISOString(), ...entry })}\n`);
}

async function pool(items, size, fn) {
  const queue = [...items];
  const workers = Array.from({ length: Math.max(1, size) }, async () => {
    while (queue.length) await fn(queue.shift());
  });
  await Promise.all(workers);
}

async function main() {
  const trail = argValue('--trail');
  if (!trail) throw new Error('Informe --trail <slug>.');
  const provider = argValue('--provider') || 'anthropic';
  const opts = {
    provider,
    model: argValue('--model') || (provider === 'anthropic' ? 'claude-opus-5-5' : undefined),
    effort: argValue('--effort') || 'high',
    retries: Number(argValue('--retries') ?? 2),
    maxTokens: Number(argValue('--max-tokens') ?? 48000),
    totals: { input: 0, output: 0, cached: 0 },
  };
  if (!opts.model && provider === 'openai') throw new Error('Informe --model para o fornecedor openai.');
  const dir = trailDir(trail);
  for (const sub of ['cenas', 'falhas', 'log']) mkdirSync(join(dir, sub), { recursive: true });
  const inputsDir = join(dir, 'inputs');
  if (!existsSync(inputsDir)) throw new Error(`Sem pacotes. Rode antes: node admin/scripts/v3_inputs.mjs --trail ${trail}`);

  const only = (argValue('--only') || '').split(',').map((s) => s.trim()).filter(Boolean);
  const all = readdirSync(inputsDir)
    .filter((f) => f.endsWith('.json'))
    .sort()
    .map((f) => readJson(join(inputsDir, f)));
  let todo = all.map((packet, index) => ({ packet, index })).filter(({ packet }) => !only.length || only.includes(packet.mission.slug));
  if (!process.argv.includes('--force')) {
    todo = todo.filter(({ packet }) => !existsSync(join(dir, 'cenas', `${packet.mission.slug}.json`)));
  }
  const limit = Number(argValue('--limit') || 0);
  if (limit > 0) todo = todo.slice(0, limit);

  const system = systemPrompt();
  if (process.argv.includes('--dry-run')) {
    for (const { packet, index } of todo) {
      writeFileSync(join(dir, 'log', `prompt-${packet.mission.slug}.txt`), `${system}\n\n===== USER =====\n\n${userPrompt(packet, index)}\n`);
    }
    // ~3,5 caracteres por token em português com JSON.
    const est = (s) => Math.round(s.length / 3.5);
    const userAvg = todo.length ? Math.round(todo.reduce((n, t) => n + est(userPrompt(t.packet, t.index)), 0) / todo.length) : 0;
    console.log(`Simulação: ${todo.length} cena(s). Prompts em ${join(dir, 'log')}.`);
    console.log(`  Instruções fixas ≈ ${est(system)} tokens (em cache depois da 1ª chamada) · pedido por cena ≈ ${userAvg} tokens.`);
    return;
  }

  console.log(`Gerando ${todo.length} cena(s) de ${trail} com ${opts.provider}/${opts.model}…`);
  let ok = 0;
  await pool(todo, Number(argValue('--concurrency') || 2), async (item) => {
    if (await runScene({ ...item, dir, opts, system })) ok++;
  });
  const t = opts.totals;
  console.log(`\n${ok}/${todo.length} cena(s) válidas. Tokens: entrada ${t.input} (cache ${t.cached}) · saída ${t.output}.`);
  if (ok < todo.length) process.exitCode = 1;
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
