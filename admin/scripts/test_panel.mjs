/**
 * Teste do editor de perguntas do painel (offline: não lê nem grava o Firestore).
 *
 *   npm run test:panel
 *
 * Abre cada gesto de uma cena do piloto no editor (jsdom + Vite SSR) e confere:
 * checagem V3 limpa, formulário lido sem edição = documento original, nenhum
 * campo existente apagado, feedback de erro e evidenceSpan no preview.
 */
import { readFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { JSDOM } from 'jsdom';
import { createServer } from 'vite';

const ADMIN = join(dirname(fileURLToPath(import.meta.url)), '..');
const BIBLE = join(ADMIN, '..', 'trilha_app', 'assets', 'data', 'bible_jfaal.json');

const dom = new JSDOM(
  '<!doctype html><div id="loading-overlay"></div><div id="toast-container"></div><div id="modal" hidden></div><div id="app"></div>',
  { url: 'http://localhost/' },
);
globalThis.window = dom.window;
globalThis.document = dom.window.document;
globalThis.HTMLElement = dom.window.HTMLElement;
globalThis.requestAnimationFrame = (cb) => setTimeout(cb, 0);
globalThis.fetch = async (url) => {
  if (String(url).includes('bible_jfaal')) return new Response(readFileSync(BIBLE));
  throw new Error(`rede bloqueada no teste: ${url}`);
};

const server = await createServer({
  root: ADMIN,
  configFile: join(ADMIN, 'vite.config.js'),
  server: { middlewareMode: true },
  appType: 'custom',
  logLevel: 'error',
});
const qs = await server.ssrLoadModule('/src/question-studio.js');
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const cena = JSON.parse(readFileSync(join(ADMIN, 'pilot', 'genesis-1-11', 'cenas', 'gen-01-criador.json'), 'utf8'));
const scene = cena.questions;
const trail = { id: 'genesis-1-11', slug: 'genesis-1-11', title: 'Gênesis 1–11', modules: [{ missions: [{ slug: 'gen-01-criador', title: 'Criador' }] }] };
const modal = document.getElementById('modal');
const ctx = { sceneQuestions: scene, study: cena.study, boss: false };
const opts = { v3: true, isNew: false, items: scene };

let fails = 0;
const ok = (cond, msg) => {
  console.log(`${cond ? 'ok  ' : 'FAIL'} ${msg}`);
  if (!cond) fails += 1;
};
const sorted = (o) => JSON.stringify(Object.keys(o).sort().reduce((a, k) => ({ ...a, [k]: o[k] }), {}));

for (const type of ['true_false', 'find_in_text', 'choice', 'order', 'complete', 'connect']) {
  const q = structuredClone(scene.find((x) => x.type === type));
  const { id, ...orig } = q;
  await qs.openQuestionStudio({ existing: q, trails: [trail], items: scene, context: ctx });
  await sleep(1200);
  const check = modal.querySelector('#qe-check')?.textContent.replace(/\s+/g, ' ').trim() || '';
  ok(/tudo certo/.test(check), `${type}: checagem V3 limpa`);
  const viaDom = qs.__test.readDraft(modal, qs.emptyBankQuestion(structuredClone(orig)));
  const { payload, remove } = qs.__test.payloadFrom(viaDom, opts);
  ok(sorted(payload) === sorted(orig), `${type}: formulário sem edição = documento original`);
  ok(!remove.some((k) => k in orig), `${type}: não apaga campo existente`);
}

const tap = structuredClone(scene.find((x) => x.type === 'find_in_text'));
await qs.openQuestionStudio({ existing: tap, trails: [trail], items: scene, context: ctx });
await sleep(800);
const hint = modal.querySelector('[data-f="hint"]');
hint.value = 'x'.repeat(95);
hint.dispatchEvent(new dom.window.Event('input'));
await sleep(900);
ok(/hint > 90/.test(modal.querySelector('#qe-check').textContent), 'hint longo aparece na checagem');
ok(/pv-tap/.test(modal.querySelector('#qs-preview').innerHTML), 'preview do Toque destaca os trechos');
modal.querySelector('[data-pv="wrong"]').dispatchEvent(new dom.window.Event('click'));
await sleep(50);
ok(modal.querySelector('#qs-preview').textContent.includes(tap.feedbackWrong.a), 'aba Erro mostra o feedback da opção');
ok(/pv-span/.test(modal.querySelector('#qs-preview').innerHTML), 'evidenceSpan aceso no feedback');

const moved = structuredClone(tap);
moved.correctOptionId = 'a';
const r1 = qs.__test.payloadFrom(moved, opts);
ok(!('a' in r1.payload.feedbackWrong) && r1.payload.correctAnswer === 'a', 'trocar a certa limpa o feedback dela');

const retyped = structuredClone(scene.find((x) => x.type === 'complete'));
retyped.type = 'choice';
const r2 = qs.__test.payloadFrom(retyped, opts);
ok(r2.remove.includes('template') && !('template' in r2.payload), 'campo de outro gesto é apagado');

ok(
  qs.nextQuestionId('gen-01-criador', 'choice', scene, { trail: 'genesis-1-11', difficulty: 'semente' }) === 'genesis-1-11-sem-gen-01-criador-07',
  'id V3 da próxima pergunta',
);

await server.close();
console.log(fails ? `\n✗ ${fails} falha(s)` : '\n✓ editor ok');
process.exit(fails ? 1 : 0);
