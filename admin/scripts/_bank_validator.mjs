/**
 * Validador pedagógico do banco STWAY (P0 + qualidade V2).
 * CLI: node admin/scripts/validate_bank.mjs [--strict] [arquivo...]
 */
import { foldKey, isIncompletePhrase, isVerseSnippet } from './_answer_phrase.mjs';

export const CLONE_ID = /-x(ch|fill|tru|com|con|cho|ch2|o)[0-9]*$/i;

export const SKILL_BY_DIFFICULTY = {
  semente: new Set(['observe']),
  caminhada: new Set(['understand']),
  profundezas: new Set(['interpret']),
};

/** Aliases legados aceitos com aviso (não bloqueiam seed). */
export const SKILL_ALIASES = {
  semente: new Set(['recall']),
  caminhada: new Set(['connect']),
  profundezas: new Set(['connect', 'synthesize']),
};

export const VALID_SKILLS = new Set([
  'observe',
  'recall',
  'understand',
  'interpret',
  'connect',
  'synthesize',
]);

export const DIFFICULTY_LABELS = {
  semente: 'Observação',
  caminhada: 'Compreensão',
  profundezas: 'Interpretação',
};

const GENERIC_REFS = /^(gênesis|genesis|êxodo|exodo|mateus|joão|salmos?)\s*1[–-]?\d+/i;

/** Distratores / feedback do poço V1 do gerador — bloquear no seed. */
const BANNED_OPTION_RE =
  /curiosidade hist[oó]rica|geneal[oó]gic[oa].*sem mensagem|A cena cancela promessas anteriores sem motivo|lista fatos sem rela[cç][aã]o|autonomia humana sem depend[eê]ncia|apenas memoriza[cç][aã]o de nomes|O relato trata s[oó] de curiosidade|Um detalhe que o texto n[aã]o afirma neste trecho$|Um personagem ausente nesta passagem$|Um evento de outro livro b[ií]blico$|N[aã]o h[aá] implica[cç][aã]o teol[oó]gica ou pr[aá]tica leg[ií]tima/i;

function isBrokenOptionText(text) {
  const t = String(text || '').replace(/\s+/g, ' ').trim();
  if (!t) return true;
  if (/…$|\.\.\.$/.test(t)) return true;
  const words = t.split(/\s+/);
  if (words.length >= 4 && /\s+(e|mas|ou|nem|de|do|da|dos|das|que|para|por|com|os|as|o|a|ao|à)$/i.test(t)) {
    return true;
  }
  if (/,\s*(os|as|o|a|e)?$/i.test(t)) return true;
  return false;
}

function stemOf(q) {
  return (q.prompt || q.question || q.cue || '').replace(/\s+/g, ' ').trim();
}

function slotType(q) {
  const t = String(q.type || 'choice').toLowerCase();
  if (['true_false', 'truefalse', 'tf'].includes(t)) return 'true_false';
  if (['complete', 'fill'].includes(t)) return 'complete';
  if (['order'].includes(t)) return 'order';
  if (['tap', 'find_in_text'].includes(t)) return 'tap';
  if (['connect', 'match'].includes(t)) return 'connect';
  return t || 'choice';
}

function hasCorrect(q) {
  const t = slotType(q);
  if (t === 'order') return Array.isArray(q.correctOrder) && q.correctOrder.length >= 2;
  if (t === 'complete') return (q.template || '').includes('___') && !!(q.correctAnswer || q.correctOptionId);
  if (t === 'true_false') {
    const a = String(q.correctAnswer || q.correctOptionId || '').toLowerCase();
    return a === 'true' || a === 'false';
  }
  const cid = String(q.correctOptionId || q.correctAnswer || '').trim();
  if (!cid) return false;
  return (q.options || []).some((o) => String(o.id) === cid);
}

function verseSnippetOptions(q) {
  const passage = (q.passageText || q.template || '').trim();
  if (!passage) return 0;
  return (q.options || []).filter((o) => {
    const t = (o.text || '').trim();
    return t.length >= 8 && isVerseSnippet(t, passage);
  }).length;
}

function isWeakTfStem(stem) {
  if (!stem) return true;
  if (/^(verdadeiro|falso)$/i.test(stem)) return true;
  if (isIncompletePhrase(stem)) return true;
  if (/^(o que|qual|quem|como|onde|quando|por que)\b/i.test(stem) && !/^o trecho/i.test(stem)) {
    return true;
  }
  return false;
}

/**
 * @param {object} q
 * @param {{ passage?: string, index?: number }} ctx
 * @returns {{ errors: string[], warnings: string[] }}
 */
export function validateQuestion(q, ctx = {}) {
  const errors = [];
  const warnings = [];
  const id = q.id || `(sem id #${ctx.index ?? '?'})`;
  const stem = stemOf(q);
  const diff = q.difficulty || '';
  const t = slotType(q);

  if (!q.id) errors.push(`${id}: falta id`);
  if (CLONE_ID.test(String(q.id || ''))) errors.push(`${id}: ID de clone (-xch/-xfill) proibido`);
  if (!q.trail && !q.trailSlug) warnings.push(`${id}: falta trail`);
  if (!q.section) errors.push(`${id}: falta section (passo)`);
  if (!['semente', 'caminhada', 'profundezas'].includes(diff)) {
    errors.push(`${id}: difficulty inválida "${diff}"`);
  }
  if (!stem) errors.push(`${id}: enunciado vazio`);

  if (!hasCorrect(q)) errors.push(`${id}: sem gabarito válido`);

  const skill = q.skill || '';
  if (skill && !VALID_SKILLS.has(skill)) warnings.push(`${id}: skill desconhecida "${skill}"`);
  if (diff && skill && SKILL_BY_DIFFICULTY[diff]) {
    if (SKILL_BY_DIFFICULTY[diff].has(skill)) {
      // ok — verbo canônico
    } else if (SKILL_ALIASES[diff]?.has(skill)) {
      warnings.push(
        `${id}: skill "${skill}" é legado; preferir ${[...SKILL_BY_DIFFICULTY[diff]][0]} (${DIFFICULTY_LABELS[diff]})`,
      );
    } else {
      errors.push(
        `${id}: skill "${skill}" incompatível com ${DIFFICULTY_LABELS[diff] || diff}`,
      );
    }
  }
  if (diff === 'profundezas' && skill === 'observe') {
    errors.push(`${id}: Interpretação não pode usar skill observe`);
  }
  if (diff === 'semente' && ['interpret', 'synthesize'].includes(skill)) {
    warnings.push(`${id}: Observação com skill ${skill} — revisar`);
  }

  if (t === 'true_false') {
    if (isWeakTfStem(stem)) errors.push(`${id}: V/F com enunciado incompleto ou interrogativo`);
    if (!(q.options || []).length) {
      // runtime adds V/F options
    }
  }

  if (t === 'complete' && !(q.template || '').includes('___')) {
    errors.push(`${id}: complete sem lacuna (___)`);
  }

  if (t === 'tap' && !(q.passageText || '').trim()) {
    errors.push(`${id}: tap sem passageText`);
  }

  if (t === 'tap') {
    const chopped = stem.match(
      /\b(?:fala de|menciona|ideia de)\s+([^?]+)\??$/i,
    );
    if (chopped) {
      const tokens = chopped[1].trim().split(/\s+/);
      const func = /^(de|da|do|das|dos|o|a|os|as|um|uma|e|que|ao|à)$/i;
      if (
        tokens.length === 2 &&
        tokens.every((w) => w.length >= 4 && !func.test(w))
      ) {
        errors.push(`${id}: enunciado de toque recortado ("${stem.slice(0, 72)}")`);
      }
    }
    for (const ot of (q.options || []).map((o) => (o.text || '').trim()).filter(Boolean)) {
      const n = ot.split(/\s+/).filter(Boolean).length;
      if (n > 3) {
        errors.push(`${id}: opção de toque longa demais ("${ot.slice(0, 48)}") — use palavra, como complete`);
        break;
      }
      const passage = (q.passageText || '').trim();
      if (passage && !foldKey(passage).includes(foldKey(ot))) {
        errors.push(`${id}: opção de toque fora do versículo ("${ot.slice(0, 40)}")`);
        break;
      }
    }
  }

  if (['choice', 'true_false'].includes(t) || !t) {
    const opts = (q.options || []).filter((o) => (o.text || '').trim());
    if (opts.length < 2 && t !== 'true_false') errors.push(`${id}: menos de 2 alternativas`);
    const empty = opts.filter((o) => !o.text?.trim());
    if (empty.length) errors.push(`${id}: alternativa vazia`);
  }

  if (['caminhada', 'profundezas'].includes(diff) && t === 'choice') {
    const passage = (q.passageText || ctx.passage || '').trim();
    const snippetCount = verseSnippetOptions({ ...q, passageText: passage || q.passageText });
    const total = (q.options || []).filter((o) => (o.text || '').trim()).length;
    if (passage && total >= 3 && snippetCount / total > 0.6) {
      errors.push(`${id}: alternativas são mostly fragmentos de versículo (${diff})`);
    }
    if (/^(qual palavra|que palavra|qual frase)/i.test(stem) && snippetCount >= 2) {
      warnings.push(`${id}: pergunta de reconhecimento verbal em ${diff}`);
    }
  }

  // Poço genérico / feedback clone / gabarito truncado
  const optTexts = (q.options || []).map((o) => (o.text || '').trim()).filter(Boolean);
  for (const ot of optTexts) {
    if (BANNED_OPTION_RE.test(ot)) {
      errors.push(`${id}: distrator genérico banido ("${ot.slice(0, 48)}…")`);
      break;
    }
  }
  // Opções quebradas / subset / desequilíbrio
  for (const ot of optTexts) {
    if (isBrokenOptionText(ot)) {
      errors.push(`${id}: alternativa quebrada/truncada ("${ot.slice(0, 48)}")`);
      break;
    }
  }
  for (let i = 0; i < optTexts.length; i++) {
    for (let j = 0; j < optTexts.length; j++) {
      if (i === j) continue;
      const a = foldKey(optTexts[i]);
      const b = foldKey(optTexts[j]);
      if (a.length >= 5 && b.includes(a) && a !== b && a.length <= b.length * 0.85) {
        if (['tap', 'complete', 'connect', 'choice'].includes(t)) {
          errors.push(`${id}: opção é pedaço de outra ("${optTexts[i].slice(0, 40)}")`);
        }
        break;
      }
    }
  }
  if (t === 'choice' && optTexts.length >= 3) {
    const lens = optTexts.map((x) => x.length);
    const max = Math.max(...lens);
    const min = Math.min(...lens);
    if (max >= 70 && min <= 35 && max / min >= 2.5) {
      warnings.push(`${id}: desequilíbrio forte de comprimento nas opções`);
    }
  }
  if (t === 'choice' || t === 'true_false') {
    const wrongs = q.feedbackWrong && typeof q.feedbackWrong === 'object' ? Object.values(q.feedbackWrong) : [];
    const uniq = new Set(wrongs.map((w) => String(w || '').trim()).filter(Boolean));
    if (wrongs.length >= 2 && uniq.size === 1 && /revise o texto e o contexto/i.test([...uniq][0] || '')) {
      errors.push(`${id}: feedbackWrong genérico idêntico em todas as opções`);
    }
  }
  if (/estabelece em torno de/i.test(stem)) {
    errors.push(`${id}: stem fraco "em torno de" (keyword órfã)`);
  }

  if (q.verseRef && GENERIC_REFS.test(q.verseRef) && !q.verseRef.match(/:\d/)) {
    warnings.push(`${id}: referência genérica "${q.verseRef}"`);
  }

  if (q.evidence && !Array.isArray(q.evidence)) {
    errors.push(`${id}: evidence deve ser array`);
  }

  return { errors, warnings };
}

/**
 * @param {object[]} questions
 * @param {{ strict?: boolean }} opts
 */
export function validateBank(questions, opts = {}) {
  const { strict = false } = opts;
  const allErrors = [];
  const allWarnings = [];
  const stemKeys = new Map();

  for (let i = 0; i < questions.length; i++) {
    const q = questions[i];
    const { errors, warnings } = validateQuestion(q, { index: i });
    allErrors.push(...errors);
    allWarnings.push(...warnings);

    const stem = foldKey(stemOf(q));
    if (stem.length >= 8 && q.section && q.difficulty) {
      const key = `${q.trail || q.trailSlug || ''}|${q.section}|${q.difficulty}|${stem}`;
      const prev = stemKeys.get(key);
      if (prev) {
        allErrors.push(`${q.id}: stem duplicado (mesmo passo/nível que ${prev})`);
      } else {
        stemKeys.set(key, q.id);
      }
    }
  }

  const ids = questions.map((q) => q.id).filter(Boolean);
  const dupeIds = ids.filter((id, i) => ids.indexOf(id) !== i);
  for (const id of [...new Set(dupeIds)]) {
    allErrors.push(`ID duplicado: ${id}`);
  }

  // Mesmo gabarito Observação↔Compreensão no mesmo gesto = clone que o usuário percebe
  const correctByGesture = new Map();
  for (const q of questions) {
    if (!['connect', 'tap', 'complete'].includes(slotType(q))) continue;
    if (!['semente', 'caminhada'].includes(q.difficulty)) continue;
    const opts = q.options || [];
    const cid = String(q.correctOptionId || q.correctAnswer || opts[0]?.id || '');
    const correctText = (opts.find((o) => String(o.id) === cid) || opts[0])?.text || '';
    const corr = foldKey(correctText);
    if (corr.length < 4) continue;
    // connect: também o lado B (insight vs texto)
    const bSide = foldKey(q.passageB?.ref || '');
    const key = `${q.trail || q.trailSlug || ''}|${q.section}|${slotType(q)}|${corr}|${bSide}`;
    const prev = correctByGesture.get(key);
    if (prev && prev !== q.difficulty) {
      allErrors.push(
        `${q.id}: mesmo gabarito de ${slotType(q)} em Observação e Compreensão (clone entre modos)`,
      );
    } else if (!prev) {
      correctByGesture.set(key, q.difficulty);
    }
  }

  if (strict) {
    allErrors.push(...allWarnings);
    allWarnings.length = 0;
  }

  return {
    ok: allErrors.length === 0,
    errors: allErrors,
    warnings: allWarnings,
    stats: {
      total: questions.length,
      clones: questions.filter((q) => CLONE_ID.test(String(q.id || ''))).length,
    },
  };
}

export function formatReport(result) {
  const lines = [
    `Total: ${result.stats.total} | Clones: ${result.stats.clones}`,
    result.ok ? '✓ OK' : `✗ ${result.errors.length} erro(s)`,
  ];
  if (result.errors.length) {
    lines.push('', 'Erros:');
    for (const e of result.errors.slice(0, 80)) lines.push(`  • ${e}`);
    if (result.errors.length > 80) lines.push(`  … +${result.errors.length - 80} erros`);
  }
  if (result.warnings.length) {
    lines.push('', 'Avisos:');
    for (const w of result.warnings.slice(0, 40)) lines.push(`  • ${w}`);
    if (result.warnings.length > 40) lines.push(`  … +${result.warnings.length - 40} avisos`);
  }
  return lines.join('\n');
}
