/**
 * Caminhos e leitura comum do pipeline V3 (gerar → validar → embaralhar →
 * juntar → traduzir → publicar).
 *
 * Cada trilha tem uma pasta de trabalho:
 *   admin/pilot/genesis-1-11/   (o piloto, escrito à mão)
 *   admin/v3/<trilha>/          (as demais, geradas por modelo)
 * com cenas/<slug>.json, inputs/<slug>.json, log/ e l10n/.
 */
import { existsSync, readFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const here = dirname(fileURLToPath(import.meta.url));
export const ADMIN_DIR = join(here, '..');
export const REPO_DIR = join(ADMIN_DIR, '..');
export const APP_DATA = join(REPO_DIR, 'trilha_app', 'assets', 'data');
export const APP_L10N = join(REPO_DIR, 'trilha_app', 'assets', 'l10n', 'content');
export const PILOT_DIR = join(ADMIN_DIR, 'pilot', 'genesis-1-11');
export const SPEC_PATH = join(PILOT_DIR, 'SPEC_V3.md');

export function trailDir(trail) {
  return trail === 'genesis-1-11' ? PILOT_DIR : join(ADMIN_DIR, 'v3', trail);
}

/** Valor de uma opção `--nome valor` (ou `--nome=valor`). */
export function argValue(name, argv = process.argv) {
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === name) return argv[i + 1];
    if (argv[i].startsWith(`${name}=`)) return argv[i].slice(name.length + 1);
  }
  return undefined;
}

export function readJson(path, fallback) {
  if (!existsSync(path)) {
    if (fallback !== undefined) return fallback;
    throw new Error(`Arquivo não encontrado: ${path}`);
  }
  return JSON.parse(readFileSync(path, 'utf8'));
}

/** Trilha do catálogo local (trails.json). */
export function loadTrail(slug) {
  const trails = readJson(join(APP_DATA, 'trails.json'));
  const trail = trails.find((t) => t.slug === slug);
  if (!trail) throw new Error(`Trilha "${slug}" não existe em trails.json`);
  return trail;
}

export function listTrailSlugs() {
  return readJson(join(APP_DATA, 'trails.json')).map((t) => t.slug);
}
