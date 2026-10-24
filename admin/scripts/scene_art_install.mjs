/**
 * Põe a arte das cenas no app: copia cada scene_*.jpg do manifest, reduzida,
 * para trilha_app/assets/art e regenera a lista de cenas pintadas.
 *
 *   node admin/scripts/scene_art_install.mjs [--from admin/arte/cenas/provisorio]
 *       → trilha_app/assets/art/scene_<slug>.jpg (até 640px de largura)
 *       → trilha_app/lib/data/scene_art.dart: slugs com pintura
 *
 * Usa o `sips` do macOS para reduzir. Cena sem arquivo fica com a pintura da trilha.
 */
import { execFileSync } from 'child_process';
import { existsSync, readdirSync, writeFileSync } from 'fs';
import { isAbsolute, join } from 'path';
import { ADMIN_DIR, REPO_DIR, argValue, readJson } from './_v3_paths.mjs';

const MAX_WIDTH = 640;
const QUALITY = 78;
const APP_ART = join(REPO_DIR, 'trilha_app', 'assets', 'art');
const DART_OUT = join(REPO_DIR, 'trilha_app', 'lib', 'data', 'scene_art.dart');

const fromArg = argValue('--from');
const FROM = fromArg
  ? (isAbsolute(fromArg) ? fromArg : join(REPO_DIR, fromArg))
  : join(ADMIN_DIR, 'arte', 'cenas', 'provisorio');

const manifest = readJson(join(ADMIN_DIR, 'arte', 'cenas', 'manifest.json'));
const bySlug = new Map(manifest.map((s) => [s.slug, s]));

let copied = 0;
for (const scene of manifest) {
  const src = join(FROM, scene.file);
  if (!existsSync(src)) continue;
  // Só reduz: painel menor que MAX_WIDTH fica no tamanho que veio.
  const width = Number(/pixelWidth: (\d+)/.exec(
    execFileSync('sips', ['-g', 'pixelWidth', src], { encoding: 'utf8' }),
  )[1]);
  execFileSync('sips', [
    ...(width > MAX_WIDTH ? ['--resampleWidth', String(MAX_WIDTH)] : []),
    '-s', 'format', 'jpeg',
    '-s', 'formatOptions', String(QUALITY),
    src, '--out', join(APP_ART, scene.file),
  ], { stdio: 'ignore' });
  copied += 1;
}

// A lista sai do que está em assets/art, não só do que foi copiado agora.
const painted = readdirSync(APP_ART)
  .filter((f) => f.startsWith('scene_') && f.endsWith('.jpg'))
  .map((f) => f.slice('scene_'.length, -'.jpg'.length))
  .filter((slug) => bySlug.has(slug))
  .sort();

const dart = `// Gerado por admin/scripts/scene_art_install.mjs. Não edite à mão.

/// Cenas com pintura própria em \`assets/art/scene_<slug>.jpg\`.
const scenesWithArt = {
${painted.map((s) => `  '${s}',`).join('\n')}
};
`;
writeFileSync(DART_OUT, dart);

console.log(`${copied} copiada(s) de ${FROM}`);
console.log(`${painted.length} cena(s) com arte em ${DART_OUT}`);
