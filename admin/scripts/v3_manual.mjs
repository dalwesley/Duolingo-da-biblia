/**
 * Banco V3 feito à mão no ChatGPT (sem API). O script prepara o que colar e
 * confere o que voltou; o ChatGPT só escreve.
 *
 *   node admin/scripts/v3_manual.mjs kit
 *       → admin/v3/_chatgpt/: instruções e arquivos para um Projeto do ChatGPT (uma vez)
 *   node admin/scripts/v3_manual.mjs pedidos --trail rute
 *       → v3/rute/manual/pedidos/<nn>-<cena>.txt: o pedido de cada cena, curto
 *   node admin/scripts/v3_manual.mjs conferir --trail rute
 *       → lê v3/rute/manual/respostas/<cena>.json, completa, valida;
 *         válidas vão para cenas/, as outras ganham manual/correcoes/<cena>.txt
 *   node admin/scripts/v3_manual.mjs traducao --trail rute [--lang en]
 *       → v3/rute/manual/traducao/<lang>/<nn>-<cena>.txt (depois do merge)
 *   node admin/scripts/v3_manual.mjs conferir-traducao --trail rute [--lang en]
 *       → lê manual/traducao-respostas/<lang>/<cena>.json e grava l10n/ (aplique com
 *         v3_translate.mjs --apply)
 */
import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'fs';
import { join } from 'path';
import { parseJsonReply } from './_llm.mjs';
import { hydrateCena, scopeErrors } from './_v3_hydrate.mjs';
import { FORMAT_RULES, ROLE, exampleJson, fixPromptInChat, specText, userPrompt } from './_v3_prompts.mjs';
import { ADMIN_DIR, argValue, readJson, trailDir } from './_v3_paths.mjs';
import { LANG, checkEntry, questionSource, studySource, system as translateRules } from './v3_translate.mjs';
import { buildInputs } from './v3_inputs.mjs';
import { validateCenaData } from './validate_pilot_v3.mjs';

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

function pedidos(trail) {
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
    writeFileSync(join(out, `${nn(i)}-${p.mission.slug}.txt`), `${userPrompt(p, i)}\n`);
  });
  console.log(`✓ ${packets.length - skipped} pedido(s) em ${out}${skipped ? ` (${skipped} cena(s) já prontas)` : ''}.`);
  console.log(`  Salve cada resposta em ${join(dir, 'manual', 'respostas')}/<cena>.json`);
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
    try {
      cena = hydrateCena(parseJsonReply(readFileSync(join(respDir, f), 'utf8')), packet);
      result = validateCenaData(cena, slug, { trail: packet.trail.slug, boss: packet.mission.type === 'boss' });
      result.errors.push(...scopeErrors(cena, packet));
    } catch (e) {
      result = { errors: [`a resposta não é um JSON completo (${e.message}); peça a cena inteira de novo, só o JSON`], warnings: [] };
    }
    if (!result.errors.length) {
      writeFileSync(join(dir, 'cenas', `${slug}.json`), `${JSON.stringify(cena, null, 2)}\n`);
      rmSync(join(fixDir, `${slug}.txt`), { force: true });
      ok++;
      console.log(`  ✓ ${slug}${result.warnings.length ? ` (${result.warnings.length} aviso(s))` : ''}`);
    } else {
      writeFileSync(join(fixDir, `${slug}.txt`), `${fixPromptInChat(result.errors.slice(0, 40))}\n`);
      bad.push(slug);
      console.log(`  ✗ ${slug}: ${result.errors.length} erro(s) → cole manual/correcoes/${slug}.txt na mesma conversa`);
    }
  }
  const missing = Object.keys(packets).filter((s) => !existsSync(join(dir, 'cenas', `${s}.json`)) && !bad.includes(s));
  console.log(`\n${ok} cena(s) válidas agora · ${bad.length} para corrigir · ${missing.length} sem resposta ainda.`);
  if (!bad.length && !missing.length) {
    console.log(`Trilha completa. Próximo: shuffle_pilot_options.mjs, validate_pilot_v3.mjs --final e merge_pilot_v3.mjs com --trail ${trail}.`);
  }
}

function langsArg() {
  return (argValue('--lang') || argValue('--langs') || 'en,es').split(',').map((s) => s.trim());
}

function traducao(trail) {
  const dir = trailDir(trail);
  const questions = readJson(join(dir, 'questions_v3.json'));
  const { studies } = readJson(join(dir, 'studies_v3.json'));
  const slugs = Object.keys(studies);
  for (const lang of langsArg()) {
    if (!LANG[lang]) throw new Error(`Idioma desconhecido: ${lang}`);
    const out = join(dir, 'manual', 'traducao', lang);
    mkdirSync(out, { recursive: true });
    mkdirSync(join(dir, 'manual', 'traducao-respostas', lang), { recursive: true });
    slugs.forEach((slug, i) => {
      const entries = Object.fromEntries(
        questions.filter((q) => q.section === slug).map((q) => [q.id, { ...questionSource(q), _verso: q.passageText }]),
      );
      // O estudo da cena vai junto, sob a chave "estudo:<slug>".
      entries[`estudo:${slug}`] = { ...studySource(studies[slug]), _verso: studies[slug].passageText };
      writeFileSync(join(out, `${nn(i)}-${slug}.txt`), `${translateRules(lang)}\n\n${JSON.stringify(entries, null, 1)}\n`);
    });
    console.log(`✓ ${lang}: ${slugs.length} pedido(s) em ${out}. Respostas em manual/traducao-respostas/${lang}/<cena>.json`);
  }
}

function conferirTraducao(trail) {
  const dir = trailDir(trail);
  const questions = readJson(join(dir, 'questions_v3.json'));
  const { studies } = readJson(join(dir, 'studies_v3.json'));
  mkdirSync(join(dir, 'l10n'), { recursive: true });
  for (const lang of langsArg()) {
    const respDir = join(dir, 'manual', 'traducao-respostas', lang);
    const qPath = join(dir, 'l10n', `questions_${lang}.json`);
    const sPath = join(dir, 'l10n', `studies_${lang}.json`);
    const qOut = readJson(qPath, {});
    const sOut = readJson(sPath, {});
    const files = existsSync(respDir) ? readdirSync(respDir).filter((f) => /\.(json|txt)$/.test(f)) : [];
    for (const f of files) {
      const slug = slugOf(f);
      let reply;
      try {
        reply = parseJsonReply(readFileSync(join(respDir, f), 'utf8'));
      } catch (e) {
        console.log(`  ✗ ${lang} ${slug}: JSON incompleto (${e.message})`);
        continue;
      }
      const errs = [];
      for (const q of questions.filter((x) => x.section === slug)) {
        const tr = reply[q.id];
        if (!tr) {
          errs.push(`${q.id}: faltou`);
          continue;
        }
        errs.push(...checkEntry(questionSource(q), tr, q.id));
      }
      const study = reply[`estudo:${slug}`];
      if (studies[slug]) {
        if (!study) errs.push(`estudo:${slug}: faltou`);
        else errs.push(...checkEntry(studySource(studies[slug]), study, `estudo:${slug}`));
      }
      if (errs.length) {
        console.log(`  ✗ ${lang} ${slug}: ${errs.length} problema(s): ${errs.slice(0, 4).join('; ')}`);
        continue;
      }
      for (const q of questions.filter((x) => x.section === slug)) {
        const e = { ...reply[q.id] };
        delete e._verso;
        if (q.type === 'true_false') e.options = LANG[lang].tf;
        qOut[q.id] = e;
      }
      const s = { ...study };
      delete s._verso;
      sOut[slug] = s;
      console.log(`  ✓ ${lang} ${slug}`);
    }
    writeFileSync(qPath, `${JSON.stringify(qOut, null, 1)}\n`);
    writeFileSync(sPath, `${JSON.stringify(sOut, null, 1)}\n`);
    const done = questions.filter((q) => qOut[q.id]).length;
    console.log(`${lang}: ${done}/${questions.length} pergunta(s) traduzidas.`);
  }
  console.log(`Quando estiver completo: node admin/scripts/v3_translate.mjs --trail ${trail} --apply`);
}

const [cmd] = process.argv.slice(2);
const trail = argValue('--trail');
const needTrail = () => {
  if (!trail) throw new Error('Informe --trail <slug>.');
  return trail;
};
try {
  if (cmd === 'kit') kit();
  else if (cmd === 'pedidos') pedidos(needTrail());
  else if (cmd === 'conferir') conferir(needTrail());
  else if (cmd === 'traducao') traducao(needTrail());
  else if (cmd === 'conferir-traducao') conferirTraducao(needTrail());
  else {
    console.log('Uso: node admin/scripts/v3_manual.mjs kit | pedidos | conferir | traducao | conferir-traducao --trail <slug>');
    process.exitCode = 1;
  }
} catch (e) {
  console.error(e.message || e);
  process.exit(1);
}
