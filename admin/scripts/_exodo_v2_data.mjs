import { readFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

export function exodoV2Packs() {
  return JSON.parse(readFileSync(join(__dirname, '_exodo_v2_data.json'), 'utf8'));
}
