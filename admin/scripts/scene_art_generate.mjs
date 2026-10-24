/**
 * Gera a arte das cenas que ainda faltam pela API de imagens da OpenAI, uma
 * imagem por cena, com o mesmo estilo e momento de PROMPTS_CENAS.md.
 *
 *   OPENAI_API_KEY=... node admin/scripts/scene_art_generate.mjs --model gpt-image-1 \
 *     [--trail jonas] [--limit 5] [--quality medium] [--dry-run]
 *       → admin/arte/cenas/provisorio/scene_<slug>.jpg
 *
 * Cena que já tem arquivo (em provisorio/ ou no app) é pulada, então dá para
 * parar e retomar. Depois: node admin/scripts/scene_art_install.mjs
 */
import { execFileSync } from 'child_process';
import { mkdirSync, rmSync, writeFileSync } from 'fs';
import { join } from 'path';
import { ADMIN_DIR, argValue } from './_v3_paths.mjs';
import { STYLE, pendingScenes } from './scene_art_prompts.mjs';

const ENDPOINT = process.env.OPENAI_BASE_URL || 'https://api.openai.com/v1';
const OUT_DIR = join(ADMIN_DIR, 'arte', 'cenas', 'provisorio');

const model = argValue('--model');
const trail = argValue('--trail');
const limit = Number(argValue('--limit')) || Infinity;
const quality = argValue('--quality') || 'medium';
const dryRun = process.argv.includes('--dry-run');

const promptFor = (scene) => `${STYLE}

Pinte uma única imagem, de borda a borda, desta cena:

${scene.brief}`;

async function paint(prompt) {
  const key = process.env.OPENAI_API_KEY;
  let lastError;
  for (let attempt = 0; attempt < 4; attempt++) {
    const res = await fetch(`${ENDPOINT}/images/generations`, {
      method: 'POST',
      headers: { 'content-type': 'application/json', authorization: `Bearer ${key}` },
      body: JSON.stringify({ model, prompt, size: '1536x1024', quality, n: 1 }),
    });
    if (res.status === 429 || res.status >= 500) {
      lastError = new Error(`OpenAI ${res.status}: ${await res.text()}`);
      const wait = Number(res.headers.get('retry-after')) || 2 ** attempt * 10;
      await new Promise((r) => setTimeout(r, wait * 1000));
      continue;
    }
    if (!res.ok) throw new Error(`OpenAI ${res.status}: ${await res.text()}`);
    const data = await res.json();
    const b64 = data.data?.[0]?.b64_json;
    if (!b64) throw new Error(`Resposta sem imagem: ${JSON.stringify(data).slice(0, 300)}`);
    return Buffer.from(b64, 'base64');
  }
  throw lastError;
}

async function main() {
  const scenes = pendingScenes(trail ? [trail] : undefined).slice(0, limit);
  if (dryRun) {
    for (const s of scenes) console.log(`${s.file}\n${promptFor(s)}\n`);
    console.log(`${scenes.length} cena(s) a pintar.`);
    return;
  }
  if (!process.env.OPENAI_API_KEY) throw new Error('OPENAI_API_KEY não definida.');
  if (!model) throw new Error('Informe o modelo de imagem com --model (ex.: gpt-image-1).');
  mkdirSync(OUT_DIR, { recursive: true });

  let done = 0;
  for (const scene of scenes) {
    const png = join(OUT_DIR, `${scene.slug}.tmp.png`);
    try {
      writeFileSync(png, await paint(promptFor(scene)));
      execFileSync('sips', ['-s', 'format', 'jpeg', '-s', 'formatOptions', '88', png, '--out', join(OUT_DIR, scene.file)], { stdio: 'ignore' });
      done += 1;
      console.log(`✓ ${done}/${scenes.length} ${scene.file}`);
    } catch (err) {
      console.error(`✗ ${scene.file}: ${err.message}`);
    } finally {
      rmSync(png, { force: true });
    }
  }
  console.log(`${done} de ${scenes.length} pintada(s) em ${OUT_DIR}`);
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
