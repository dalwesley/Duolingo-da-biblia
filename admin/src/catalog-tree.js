/**
 * Árvore do catálogo como o app mostra: prateleira → caminho → fase → trilha.
 *
 * Espelho de trilha_app/lib/models/trail_catalog.dart (TrailShelf,
 * TrailJourney, TrailCategory). Categoria nova no app precisa entrar aqui;
 * trilha com categoria desconhecida cai em “Sem caminho”, não some.
 */

export const SHELVES = [
  { id: 'biblia', label: 'Bíblia' },
  { id: 'tematicos', label: 'Temas' },
  { id: 'vidaCrista', label: 'Vida Cristã' },
  { id: 'teologia', label: 'Teologia' },
];

/** id, rótulo, realm e ordem iguais ao enum TrailCategory do app. */
export const CATEGORIES = [
  { id: 'paz-no-dia', label: 'Paz no dia', realm: 'vida-crista', order: 1 },
  { id: 'conhecer-a-deus', label: 'Conhecer a Deus', realm: 'vida-crista', order: 2 },
  { id: 'entender-a-biblia', label: 'Entender a Bíblia', realm: 'vida-crista', order: 3 },
  { id: 'panorama', label: 'Panorama', realm: 'antigo-testamento', order: 4 },
  { id: 'personagens', label: 'Personagens', realm: 'antigo-testamento', order: 5 },
  { id: 'promessa-cumprimento', label: 'Promessa e cumprimento', realm: 'antigo-testamento', order: 6 },
  { id: 'temas-biblicos', label: 'Temas bíblicos', realm: 'antigo-testamento', order: 7 },
  { id: 'parabolas-milagres', label: 'Parábolas e milagres', realm: 'antigo-testamento', order: 8 },
  { id: 'pentateuco', label: 'Pentateuco', realm: 'antigo-testamento', order: 10 },
  { id: 'historicos-at', label: 'Históricos', realm: 'antigo-testamento', order: 20 },
  { id: 'poeticos', label: 'Poéticos', realm: 'antigo-testamento', order: 30 },
  { id: 'profetas-maiores', label: 'Profetas maiores', realm: 'antigo-testamento', order: 40 },
  { id: 'profetas-menores', label: 'Profetas menores', realm: 'antigo-testamento', order: 45 },
  { id: 'intertestamentario', label: 'Intertestamentário', realm: 'antigo-testamento', order: 48 },
  { id: 'evangelhos', label: 'Evangelhos', realm: 'novo-testamento', order: 50 },
  { id: 'historicos-nt', label: 'Históricos', realm: 'novo-testamento', order: 60 },
  { id: 'epistolas', label: 'Epístolas', realm: 'novo-testamento', order: 70 },
  { id: 'apocalipse', label: 'Apocalipse', realm: 'novo-testamento', order: 80 },
  { id: 'discipulado', label: 'Discipulado', realm: 'vida-crista', order: 90 },
  { id: 'oracao', label: 'Oração', realm: 'vida-crista', order: 100 },
  { id: 'historia-igreja', label: 'História da Igreja', realm: 'vida-crista', order: 110 },
  { id: 'hermeneutica', label: 'Hermenêutica', realm: 'teologia', order: 120 },
  { id: 'linguas', label: 'Línguas', realm: 'teologia', order: 130 },
  { id: 'sistematica', label: 'Teologia sistemática', realm: 'teologia', order: 140 },
  { id: 'cristologia', label: 'Cristologia', realm: 'teologia', order: 150 },
];

const CAT = new Map(CATEGORIES.map((c) => [c.id, c]));
const BUILT_IN_COUNT = { categories: CATEGORIES.length, journeys: 0, shelves: SHELVES.length };

/** Cards da aba Trilhas (TrailJourney). AT e NT juntam várias fases. */
export const JOURNEYS = [
  { id: 'antigoTestamento', shelf: 'biblia', label: 'Antigo Testamento', categories: ['pentateuco', 'historicos-at', 'poeticos', 'profetas-maiores', 'profetas-menores', 'intertestamentario'] },
  { id: 'novoTestamento', shelf: 'biblia', label: 'Novo Testamento', categories: ['evangelhos', 'historicos-nt', 'epistolas', 'apocalipse'] },
  ...['paz-no-dia', 'conhecer-a-deus', 'entender-a-biblia', 'panorama', 'personagens', 'promessa-cumprimento', 'temas-biblicos', 'parabolas-milagres']
    .map((c) => ({ id: c, shelf: 'tematicos', label: CAT.get(c).label, categories: [c] })),
  ...['discipulado', 'oracao', 'historia-igreja'].map((c) => ({ id: c, shelf: 'vidaCrista', label: CAT.get(c).label, categories: [c] })),
  ...['hermeneutica', 'linguas', 'sistematica', 'cristologia'].map((c) => ({ id: c, shelf: 'teologia', label: CAT.get(c).label, categories: [c] })),
];

BUILT_IN_COUNT.journeys = JOURNEYS.length;

const FREE_JOURNEYS = new Set(['paz-no-dia', 'conhecer-a-deus', 'entender-a-biblia']);

/** Linhas onde o painel pode criar card (a Bíblia é fixa: AT e NT). Lido na hora: inclui as do painel. */
export function cardShelves() {
  return SHELVES.filter((s) => s.id !== 'biblia');
}

/**
 * Linhas criadas no painel (`content_shelves`): portas novas na aba Explorar,
 * depois das fixas. Chamar antes de setExtraCards (o card aponta para a linha).
 * Mesma regra do app (ExploreShelf.fromJson); inativa entra marcada `hidden`.
 */
export function setExtraShelves(shelves) {
  SHELVES.length = BUILT_IN_COUNT.shelves;
  const valid = (shelves || [])
    .filter((s) => s.id && String(s.title?.pt || '').trim() && !SHELVES.some((x) => x.id === s.id))
    .sort((a, b) => (Number(a.order) || 0) - (Number(b.order) || 0));
  for (const s of valid) SHELVES.push({ id: s.id, label: s.title.pt.trim(), extra: true, hidden: s.active === false, shelf: s });
  return valid;
}

/**
 * Cards criados no painel (`content_cards`): cada um é uma categoria com um
 * card só dela, no fim da prateleira. Entram nas mesmas listas dos fixos —
 * quem importa CATEGORIES/JOURNEYS já vê os extras. Mesma regra do app
 * (ExploreCard.fromJson): sem título, Bíblia ou id fixo não entram. Inativo
 * entra marcado `hidden` (o app não mostra; o painel mostra para reativar).
 */
export function setExtraCards(cards) {
  CATEGORIES.length = BUILT_IN_COUNT.categories;
  JOURNEYS.length = BUILT_IN_COUNT.journeys;
  for (const k of [...CAT.keys()]) if (CAT.get(k).extra) CAT.delete(k);
  const valid = (cards || [])
    .filter((c) => c.id && c.shelf && c.shelf !== 'biblia' && SHELVES.some((s) => s.id === c.shelf) && String(c.title?.pt || '').trim() && !CAT.has(c.id))
    .sort((a, b) => (Number(a.order) || 0) - (Number(b.order) || 0));
  for (const c of valid) {
    const cat = { id: c.id, label: c.title.pt.trim(), realm: c.realm || 'vida-crista', order: 1000 + (Number(c.order) || 0), extra: true, card: c };
    CATEGORIES.push(cat);
    CAT.set(c.id, cat);
    JOURNEYS.push({ id: c.id, shelf: c.shelf, label: cat.label, categories: [c.id], extra: true, hidden: c.active === false, card: c });
  }
  return valid;
}

/** Bíblia (AT/NT) e os motivos do onboarding são grátis; o resto pede Peregrino+. */
export function journeyRequiresPlus(j) {
  if (j.extra) return j.card?.plus !== false;
  if (FREE_JOURNEYS.has(j.id)) return false;
  return j.shelf !== 'biblia';
}

export function categoryLabel(id) {
  return CAT.get(id)?.label || id || 'Sem categoria';
}

export function trailIdOf(t) {
  return t.slug || t.id;
}

/** Cenas na ordem do mapa (módulos → missões). */
export function scenesOf(trail) {
  const out = [];
  for (const mod of trail?.modules || []) {
    for (const ms of mod.missions || []) {
      if (ms.slug) out.push({ ...ms, boss: ms.type === 'boss', module: mod.title || '' });
    }
  }
  return out;
}

/**
 * [{ shelf, journeys: [{ journey, plus, phases: [{ category, label, trails }] }] }]
 * Trilhas na ordem do app: ordem da categoria, depois `order`.
 */
export function buildTree(trails) {
  const byCategory = new Map();
  const orphans = [];
  for (const t of trails || []) {
    if (CAT.has(t.category)) {
      if (!byCategory.has(t.category)) byCategory.set(t.category, []);
      byCategory.get(t.category).push(t);
    } else {
      orphans.push(t);
    }
  }
  for (const list of byCategory.values()) {
    list.sort((a, b) => (Number(a.order) || 0) - (Number(b.order) || 0) || String(a.title).localeCompare(String(b.title), 'pt-BR'));
  }
  const tree = SHELVES.map((shelf) => ({
    shelf,
    journeys: JOURNEYS.filter((j) => j.shelf === shelf.id).map((journey) => ({
      journey,
      plus: journeyRequiresPlus(journey),
      phases: journey.categories.map((c) => ({ category: c, label: categoryLabel(c), trails: byCategory.get(c) || [] })),
    })),
  }));
  if (orphans.length) {
    tree.push({
      shelf: { id: 'orfas', label: 'Sem caminho' },
      journeys: [{ journey: { id: 'orfas', label: 'Categoria desconhecida', categories: [] }, plus: false, phases: [{ category: '', label: 'Fora do catálogo do app', trails: orphans }] }],
    });
  }
  return tree;
}

/** Onde a trilha mora: { shelf, journey, phase }. */
export function locateTrail(tree, trailId) {
  for (const s of tree) {
    for (const j of s.journeys) {
      for (const p of j.phases) {
        if (p.trails.some((t) => trailIdOf(t) === trailId)) return { shelf: s.shelf, journey: j, phase: p };
      }
    }
  }
  return null;
}
