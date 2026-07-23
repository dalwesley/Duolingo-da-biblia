/**
 * Normaliza assets locais antes do seed/import:
 * 1) Wrap exodo/ot banks no formato { questions: [...] }
 * 2) Extrai perguntas embutidas do NT → nt_questions.json (3 dificuldades)
 * 3) Gera preparos faltantes para missões OT (e NT vivo) em mission_studies.json
 *
 * Usage: node scripts/prepare_content.mjs
 */
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const dataRoot = join(__dirname, '..', '..', 'trilha_app', 'assets', 'data');

function readJson(name) {
  return JSON.parse(readFileSync(join(dataRoot, name), 'utf8'));
}

function writeJson(name, data) {
  writeFileSync(join(dataRoot, name), `${JSON.stringify(data, null, 2)}\n`, 'utf8');
}

function normalizeBankFile(name) {
  const path = join(dataRoot, name);
  if (!existsSync(path)) {
    console.log(`skip ${name} (missing)`);
    return 0;
  }
  const raw = JSON.parse(readFileSync(path, 'utf8'));
  if (Array.isArray(raw)) {
    writeJson(name, { questions: raw });
    console.log(`✓ ${name}: array → { questions: ${raw.length} }`);
    return raw.length;
  }
  if (raw && Array.isArray(raw.questions)) {
    console.log(`✓ ${name}: já no formato objeto (${raw.questions.length})`);
    return raw.questions.length;
  }
  throw new Error(`${name}: formato inesperado`);
}

function bankQuestions(name) {
  const raw = readJson(name);
  if (Array.isArray(raw)) return raw;
  return raw.questions || [];
}

const DIFFS = ['semente', 'caminhada', 'profundezas'];
const DIFF_SHORT = { semente: 'sem', caminhada: 'cam', profundezas: 'pro' };

function extractNtBank(trails) {
  const live = new Set(['evangelhos', 'atos', 'apocalipse']);
  const out = [];

  function pushQ({ id, trail, difficulty, section, question, options, correctOptionId, feedbackCorrect, feedbackWrong, verseRef, reveal }) {
    out.push({
      id,
      trail,
      difficulty,
      section,
      question,
      options,
      correctOptionId,
      feedbackCorrect: feedbackCorrect || 'Correto.',
      feedbackWrong: feedbackWrong || {},
      verseRef: verseRef || null,
      reveal: reveal ?? null,
    });
  }

  function optionText(options, id) {
    return (options || []).find((o) => o.id === id)?.text || '';
  }

  function wrongPool(options, correctId) {
    return (options || []).filter((o) => o.id !== correctId).map((o) => o.text);
  }

  for (const trail of trails) {
    if (!live.has(trail.slug)) continue;
    for (const mod of trail.modules || []) {
      const moduleQs = [];
      for (const mission of mod.missions || []) {
        for (const q of mission.questions || []) moduleQs.push({ mission, q });
      }

      for (const mission of mod.missions || []) {
        const base = [...(mission.questions || [])];
        // Amplia o pool da seção com perguntas-irmã do mesmo módulo (sem repetir texto).
        const siblings = moduleQs
          .filter((x) => x.mission.slug !== mission.slug)
          .map((x) => x.q);
        const expanded = [...base];
        for (const sq of siblings) {
          if (expanded.length >= 5) break;
          if (expanded.some((b) => b.question === sq.question)) continue;
          expanded.push(sq);
        }

        // Gera variantes de compreensão a partir das base (caminhada/profundezas).
        const variants = [];
        for (const q of base) {
          const correct = optionText(q.options, q.correctOptionId);
          if (!correct) continue;
          const wrongs = wrongPool(q.options, q.correctOptionId);
          while (wrongs.length < 3) wrongs.push('Nenhuma das anteriores');
          if (q.verseRef) {
            variants.push({
              question: `Segundo ${q.verseRef}, qual afirmação é verdadeira?`,
              options: [
                { id: 'a', text: correct },
                { id: 'b', text: wrongs[0] },
                { id: 'c', text: wrongs[1] },
                { id: 'd', text: wrongs[2] },
              ],
              correctOptionId: 'a',
              feedbackCorrect: q.feedbackCorrect || `Correto. ${q.verseRef}`,
              feedbackWrong: {
                b: `Revise ${q.verseRef}.`,
                c: `Revise ${q.verseRef}.`,
                d: `Revise ${q.verseRef}.`,
              },
              verseRef: q.verseRef,
              reveal: q.reveal ?? null,
            });
          }
          variants.push({
            question: `Qual destas opções resume melhor o ponto central deste passo?`,
            options: [
              { id: 'a', text: correct },
              { id: 'b', text: wrongs[0] },
              { id: 'c', text: wrongs[1] },
              { id: 'd', text: wrongs[2] },
            ],
            correctOptionId: 'a',
            feedbackCorrect: q.feedbackCorrect || 'Correto.',
            feedbackWrong: q.feedbackWrong || {
              b: 'Não é o foco deste passo.',
              c: 'Não é o foco deste passo.',
              d: 'Não é o foco deste passo.',
            },
            verseRef: q.verseRef || null,
            reveal: q.reveal ?? null,
          });
        }

        const byDiff = {
          semente: [...expanded],
          caminhada: [...expanded, ...variants.slice(0, Math.max(0, 5 - expanded.length))],
          profundezas: [
            ...variants,
            ...expanded,
          ],
        };

        for (const diff of DIFFS) {
          const pool = [];
          const seen = new Set();
          for (const q of byDiff[diff]) {
            const key = q.question;
            if (seen.has(key)) continue;
            seen.add(key);
            pool.push(q);
            if (pool.length >= 5) break;
          }
          // Se ainda faltar, reusa base com id distinto (último recurso).
          let pad = 0;
          while (pool.length < 5 && expanded.length > 0) {
            const q = expanded[pad % expanded.length];
            pool.push({
              ...q,
              question: `${q.question}${pad === 0 ? '' : ''}`.trim(),
            });
            pad += 1;
            if (pad > 8) break;
          }

          pool.forEach((q, qi) => {
            pushQ({
              id: `${trail.slug}-${DIFF_SHORT[diff]}-${mission.slug}-${String(qi + 1).padStart(2, '0')}`,
              trail: trail.slug,
              difficulty: diff,
              section: mission.slug,
              question: q.question,
              options: q.options,
              correctOptionId: q.correctOptionId,
              feedbackCorrect: q.feedbackCorrect,
              feedbackWrong: q.feedbackWrong,
              verseRef: q.verseRef,
              reveal: q.reveal,
            });
          });
        }
      }
    }
  }

  writeJson('nt_questions.json', { questions: out });
  console.log(`✓ nt_questions.json: ${out.length} (NT vivo, ≥5/seção/dificuldade quando possível)`);
  return out;
}

function fold(s) {
  return s
    .normalize('NFD')
    .replace(/\p{M}/gu, '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim();
}

function buildBibleIndex() {
  const books = readJson('bible_tb.json');
  const byName = new Map();
  for (const b of books) {
    byName.set(fold(b.name), b);
    byName.set(fold(b.abbrev), b);
  }
  // aliases comuns
  const aliases = {
    genesis: 'gênesis',
    exodo: 'êxodo',
    levitico: 'levítico',
    numeros: 'números',
    deuteronomio: 'deuteronômio',
    josue: 'josué',
    juizes: 'juízes',
    '1 samuel': '1 samuel',
    '2 samuel': '2 samuel',
    '1 reis': '1 reis',
    '2 reis': '2 reis',
    '1 cronicas': '1 crônicas',
    '2 cronicas': '2 crônicas',
    salmos: 'salmos',
    proverbios: 'provérbios',
    eclesiastes: 'eclesiastes',
    cantares: 'cânticos',
    'cantico dos canticos': 'cânticos',
    isaias: 'isaías',
    jeremias: 'jeremias',
    lamentacoes: 'lamentações',
    ezequiel: 'ezequiel',
    oseias: 'oséias',
    miqueias: 'miquéias',
    naum: 'naum',
    habacuque: 'habacuque',
    sofonias: 'sofonias',
    ageu: 'ageu',
    zacarias: 'zacarias',
    malaquias: 'malaquias',
    mateus: 'mateus',
    marcos: 'marcos',
    lucas: 'lucas',
    joao: 'joão',
    atos: 'atos',
    apocalipse: 'apocalipse',
  };
  for (const [alias, target] of Object.entries(aliases)) {
    const book = byName.get(fold(target));
    if (book) byName.set(fold(alias), book);
  }
  return byName;
}

function findBook(byName, bookName) {
  let book = byName.get(bookName);
  if (book) return book;
  for (const [k, b] of byName) {
    if (bookName.includes(k) || k.includes(bookName)) return b;
  }
  return null;
}

function clip(text, max = 280) {
  if (!text) return text;
  if (text.length <= max) return text;
  return `${text.slice(0, max - 1).trim()}…`;
}

function lookupPassage(byName, ref) {
  if (!ref || typeof ref !== 'string') return null;
  const raw = ref.trim();

  // Livro 10:1–2 / Livro 10:1-2 / Livro 10:1
  let m = raw.match(/^(.+?)\s+(\d+)\s*:\s*(\d+)(?:\s*[–\-−]\s*(\d+))?/);
  if (m) {
    const book = findBook(byName, fold(m[1]));
    if (!book) return null;
    const ch = Number(m[2]);
    const v1 = Number(m[3]);
    const v2 = m[4] ? Number(m[4]) : v1;
    const chapter = book.chapters[ch - 1];
    if (!chapter) return null;
    const parts = [];
    for (let i = v1 - 1; i < Math.min(v2, chapter.length); i++) {
      if (chapter[i]) parts.push(chapter[i]);
    }
    return parts.length ? clip(parts.join(' ')) : null;
  }

  // Livro 8–9 (intervalo de capítulos) → primeiro versículo do 1º cap.
  m = raw.match(/^(.+?)\s+(\d+)\s*[–\-−]\s*(\d+)\s*$/);
  if (m) {
    const book = findBook(byName, fold(m[1]));
    if (!book) return null;
    const ch = Number(m[2]);
    const chapter = book.chapters[ch - 1];
    if (!chapter?.length) return null;
    const end = Math.min(3, chapter.length);
    return clip(chapter.slice(0, end).join(' '));
  }

  // Livro 1 (capítulo inteiro) → primeiros versículos
  m = raw.match(/^(.+?)\s+(\d+)\s*$/);
  if (m) {
    const book = findBook(byName, fold(m[1]));
    if (!book) return null;
    const ch = Number(m[2]);
    const chapter = book.chapters[ch - 1];
    if (!chapter?.length) return null;
    const end = Math.min(3, chapter.length);
    return clip(chapter.slice(0, end).join(' '));
  }

  return null;
}

function keywordFromTitle(title) {
  const cleaned = (title || '')
    .replace(/desafio[:\s-]*/i, '')
    .replace(/[—–-].*$/, '')
    .trim();
  const words = cleaned.split(/\s+/).filter(Boolean);
  if (!words.length) return { keyword: 'Palavra', gloss: 'Ouça o texto com atenção.' };
  const stop = new Set(['o', 'a', 'os', 'as', 'de', 'do', 'da', 'dos', 'das', 'e', 'em', 'no', 'na', 'um', 'uma']);
  const pick = words.find((w) => !stop.has(fold(w)) && w.length > 2) || words[0];
  const keyword = pick.replace(/[^A-Za-zÀ-ÿ]/g, '');
  return {
    keyword: keyword ? keyword[0].toUpperCase() + keyword.slice(1) : 'Texto',
    gloss: `Neste passo, preste atenção em “${keyword || 'texto'}” e no que o trecho revela sobre Deus e o povo.`,
  };
}

function verseScore(ref) {
  if (!ref) return -1;
  if (/\d+\s*:\s*\d+/.test(ref)) return 3;
  if (/\d+\s*[–\-−]\s*\d+/.test(ref)) return 2;
  if (/\s\d+\s*$/.test(ref)) return 1;
  return 0;
}

function buildVerseMap(questions) {
  const bySection = new Map();
  for (const q of questions) {
    if (!q.section || !q.verseRef) continue;
    const prev = bySection.get(q.section);
    if (!prev || verseScore(q.verseRef) > verseScore(prev)) {
      bySection.set(q.section, q.verseRef);
    }
  }
  return bySection;
}

const HANDCRAFTED_PREFIXES = ['gen-', 'gen12-', 'exo-', 'evg-', 'ato-', 'apo-'];

function isHandcrafted(slug) {
  return HANDCRAFTED_PREFIXES.some((p) => slug.startsWith(p));
}

function generateMissingStudies(trails, studiesDoc, bankQs) {
  const byName = buildBibleIndex();
  const verseBySection = buildVerseMap(bankQs);
  // Preserva estudos densos manuais; regenera o resto.
  const studies = {};
  for (const [slug, study] of Object.entries(studiesDoc.studies || {})) {
    if (isHandcrafted(slug)) studies[slug] = study;
  }
  const verses = { ...(studiesDoc.verses || {}) };
  let added = 0;

  const targetRealms = new Set(['antigo-testamento', 'novo-testamento']);
  for (const trail of trails) {
    if (!targetRealms.has(trail.realm)) continue;
    if (trail.comingSoon) continue;
    for (const mod of trail.modules || []) {
      for (const mission of mod.missions || []) {
        const slug = mission.slug;
        if (studies[slug]) continue;

        const candidates = [
          verseBySection.get(slug),
          ...(mission.questions || []).map((q) => q.verseRef),
        ].filter(Boolean);
        candidates.sort((a, b) => verseScore(b) - verseScore(a));
        const verseRef = candidates[0] || null;

        let passageText = verseRef ? lookupPassage(byName, verseRef) : null;
        if (!passageText) {
          passageText =
            (mission.intro || '').slice(0, 280) ||
            'Leia o texto com calma antes do desafio.';
        }
        const { keyword, gloss } = keywordFromTitle(mission.title);
        const context =
          (mission.intro || '').trim() ||
          `${mission.title}: prepare o coração antes das perguntas.`;
        const focus =
          mission.subtitle?.trim() ||
          `O que este passo ensina sobre ${keyword.toLowerCase()}?`;

        const realmPrompts = {
          'antigo-testamento': [
            'O que isso revela sobre a aliança de Deus?',
            'Onde você vê fidelidade ou falha humana?',
            'Como este trecho aponta para a história maior?',
          ],
          'novo-testamento': [
            'O que Jesus / a igreja revelam aqui?',
            'Como o Espírito ou o Reino aparecem neste passo?',
            'O que isso muda na sua caminhada hoje?',
          ],
        };

        studies[slug] = {
          slug,
          passageRef: verseRef || mission.title,
          passageText,
          context: clip(context, 320),
          keyword,
          keywordGloss: gloss,
          focusQuestion: focus,
          reflectionPrompts:
            realmPrompts[trail.realm] || [
              'O que o texto revela sobre Deus?',
              'O que isso pede de mim hoje?',
              'Como isso se liga à história maior da Bíblia?',
            ],
        };
        if (verseRef && passageText) {
          verses[verseRef] = passageText;
        }
        added += 1;
      }
    }
  }

  writeJson('mission_studies.json', { studies, verses });
  console.log(
    `✓ mission_studies.json: +${added} preparos (total ${Object.keys(studies).length})`,
  );
  return added;
}

function main() {
  console.log('Preparando conteúdo em', dataRoot);

  normalizeBankFile('exodo_questions.json');
  normalizeBankFile('ot_questions.json');

  const trails = readJson('trails.json');
  extractNtBank(trails);

  const allBank = [
    ...bankQuestions('genesis_questions.json'),
    ...bankQuestions('exodo_questions.json'),
    ...bankQuestions('ot_questions.json'),
    ...bankQuestions('nt_questions.json'),
  ];
  console.log(`Banco unificado (local): ${allBank.length} perguntas`);

  const studiesDoc = readJson('mission_studies.json');
  generateMissingStudies(trails, studiesDoc, allBank);

  console.log('Pronto.');
}

main();
