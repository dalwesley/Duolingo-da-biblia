'use strict';

/**
 * Espelho de trilha_app/lib/utils/content_filter.dart — barra o óbvio em
 * texto que outra pessoa vê (aceno escrito da companhia). Mudou a lista lá,
 * mude aqui.
 */

const WHOLE_WORDS = new Set([
  // pt
  'cu', 'cuzao', 'puta', 'puto', 'putas', 'putos', 'retardado', 'retard',
  'fdp', 'pqp', 'vsf', 'tnc', 'bicha', 'viado', 'corno', 'merda', 'bosta',
  'foder', 'foda', 'fode', 'xota', 'xana', 'cacete', 'porra', 'vadia',
  'piranha', 'otario', 'otaria', 'babaca', 'broxa', 'nazi',
  // en
  'fuck', 'shit', 'dick', 'cock', 'cunt', 'fag', 'slut', 'whore', 'bitch',
  'ass', 'tits', 'porn', 'sex', 'rape', 'nigga',
  // es
  'cono', 'verga', 'polla', 'zorra', 'culo', 'chinga', 'joder',
  // Passar-se pela equipe.
  'admin', 'moderador', 'moderator', 'suporte', 'support', 'stway',
]);

const ANYWHERE = [
  // pt
  'caralho', 'buceta', 'boceta', 'piroca', 'arrombad', 'vagabund',
  'putaria', 'punheta', 'xereca', 'xoxota', 'fodase', 'fodido', 'fudido',
  'desgracad', 'filhodaputa', 'filhadaputa', 'viadinho', 'sapatao',
  'traveco', 'estupr', 'pedofil', 'nazista', 'hitler', 'crioulo',
  // en
  'fucker', 'fucking', 'motherfuck', 'bullshit', 'asshole', 'bastard',
  'nigger', 'faggot', 'pussy', 'penis', 'vagina', 'porno',
  // es
  'mierda', 'cabron', 'pendejo', 'maricon', 'gilipollas', 'hijodeputa',
  'chingar', 'culero', 'follar',
];

const LEET = {
  '0': 'o', '1': 'i', '3': 'e', '4': 'a', '5': 's', '7': 't',
  '@': 'a', '$': 's', '!': 'i',
};

function normalize(text) {
  const plain = text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '');
  let out = '';
  for (const ch of plain) out += LEET[ch] || ch;
  return out;
}

/** "porraaaa" → "porra": letra repetida 3+ vezes vira uma. */
function squeeze(word) {
  return word.replace(/([a-z])\1{2,}/g, '$1');
}

/** Letras soltas em sequência viram uma palavra: "f.d.p" → "fdp". */
function spelledOut(words) {
  const joined = [];
  let run = '';
  for (const word of [...words, '']) {
    if (word.length === 1) {
      run += word;
      continue;
    }
    if (run.length > 1) joined.push(run);
    run = '';
  }
  return joined;
}

/** `true` se o texto pode ser mostrado a outras pessoas. */
function isAllowed(text) {
  const normalized = normalize(String(text || ''));
  if (!normalized.trim()) return true;
  const words = normalized
    .split(/[^a-z]+/)
    .filter(Boolean)
    .map(squeeze);
  for (const word of [...words, ...spelledOut(words)]) {
    if (WHOLE_WORDS.has(word)) return false;
  }
  const compact = squeeze(normalized.replace(/[^a-z]/g, ''));
  return !ANYWHERE.some((bad) => compact.includes(bad));
}

module.exports = { isAllowed };
