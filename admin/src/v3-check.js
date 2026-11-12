/**
 * Validador V3 no painel — as mesmas regras de `npm run v3:validate`
 * (`scripts/_v3_rules.mjs`), contra a JFAAL do app.
 */
import { createV3Validator, V3_SHORT } from '../scripts/_v3_rules.mjs';
import { jfaal, loadJfaal } from './jfaal-browser.js';

let validator = null;

export async function ensureV3Validator() {
  if (!validator) {
    await loadJfaal();
    validator = createV3Validator(jfaal);
  }
  return validator;
}

/** Pergunta no formato V3: `<trilha>-<sem|cam|pro>-<cena>-<nn>`. */
export function isV3Question(q) {
  if (!q?.id || !q.trail || !q.section) return false;
  const short = V3_SHORT[q.difficulty];
  return Boolean(short) && q.id.startsWith(`${q.trail}-${short}-${q.section}-`);
}

/** Cena V3 se a maioria das perguntas segue o id V3. */
export function isV3Scene(questions) {
  const qs = questions || [];
  if (!qs.length) return false;
  return qs.filter(isV3Question).length >= qs.length / 2;
}

/**
 * Valida uma cena inteira. `boss` vem de `mission.type === 'boss'`.
 * Devolve { errors, warnings, byQuestion: Map<id, {errors, warnings}>, study: {errors, warnings} }.
 */
export async function checkScene({ trail, section, questions, study, boss }) {
  const { validateCenaData } = await ensureV3Validator();
  const clean = (questions || []).map((q) => {
    const { updatedAt, panelEditedAt, panelEditedBy, order, ...rest } = q;
    return rest;
  });
  const r = validateCenaData(
    { study: study ? { ...study, slug: study.slug || section } : { slug: section }, questions: clean },
    section,
    { trail, final: true, boss },
  );
  const byQuestion = new Map();
  for (const q of clean) byQuestion.set(q.id, { errors: [], warnings: [] });
  const studyRes = { errors: [], warnings: [] };
  const scene = { errors: [], warnings: [] };
  const route = (list, kind) => {
    for (const m of list) {
      if (m.startsWith(`${section} estudo`)) {
        studyRes[kind].push(m.replace(`${section} estudo: `, ''));
        continue;
      }
      const owner = clean.find((q) => m.startsWith(`${q.id}:`)) || clean.find((q) => m.includes(q.id));
      if (owner) byQuestion.get(owner.id)[kind].push(m.replace(`${owner.id}: `, ''));
      else scene[kind].push(m.replace(`${section}: `, ''));
    }
  };
  route(r.errors, 'errors');
  route(r.warnings, 'warnings');
  return { errors: r.errors, warnings: r.warnings, byQuestion, study: studyRes, scene };
}
