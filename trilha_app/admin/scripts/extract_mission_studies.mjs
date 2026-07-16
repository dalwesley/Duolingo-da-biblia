import fs from 'fs';

const dart = fs.readFileSync(
  new URL('../../lib/data/mission_study.dart', import.meta.url),
  'utf8',
);

const mapStart = dart.indexOf('static const _bySlug');
const versesStart = dart.indexOf('static const _verses');
const mapBody = dart.slice(mapStart, versesStart);

const studies = {};
const entryRe = /'([^']+)':\s*MissionStudy\(/g;
const indices = [];
let m;
while ((m = entryRe.exec(mapBody)) !== null) {
  indices.push({ slug: m[1], index: m.index + m[0].length });
}

function extractField(src, key) {
  const re = new RegExp(
    `${key}:\\s*(?:\\n\\s*)?'((?:\\\\'|[^'])*)'`,
  );
  const mm = src.match(re);
  return mm ? mm[1].replace(/\\'/g, "'") : '';
}

function extractList(src, key) {
  const re = new RegExp(`${key}:\\s*\\[([\\s\\S]*?)\\]`);
  const mm = src.match(re);
  if (!mm) return [];
  const items = [];
  const itemRe = /'((?:\\'|[^'])*)'/g;
  let im;
  while ((im = itemRe.exec(mm[1])) !== null) {
    items.push(im[1].replace(/\\'/g, "'"));
  }
  return items;
}

for (let i = 0; i < indices.length; i++) {
  const start = indices[i].index;
  const end = i + 1 < indices.length ? indices[i + 1].index : mapBody.length;
  const chunk = mapBody.slice(start, end);
  studies[indices[i].slug] = {
    slug: indices[i].slug,
    passageRef: extractField(chunk, 'passageRef'),
    passageText: extractField(chunk, 'passageText'),
    context: extractField(chunk, 'context'),
    keyword: extractField(chunk, 'keyword'),
    keywordGloss: extractField(chunk, 'keywordGloss'),
    focusQuestion: extractField(chunk, 'focusQuestion'),
    reflectionPrompts: extractList(chunk, 'reflectionPrompts'),
  };
}

const verses = {};
const versesBody = dart.slice(versesStart);
const vRe = /'([^']+)':\s*'((?:\\'|[^'])*)'/g;
let vm;
while ((vm = vRe.exec(versesBody)) !== null) {
  verses[vm[1]] = vm[2].replace(/\\'/g, "'");
}

const out = new URL('../../assets/data/mission_studies.json', import.meta.url);
fs.writeFileSync(out, JSON.stringify({ studies, verses }, null, 2));
console.log(
  `Wrote ${Object.keys(studies).length} studies, ${Object.keys(verses).length} verses → ${out.pathname}`,
);
console.log('sample keys', Object.keys(studies['gen-01-criador'] || {}));
console.log('passageRef', studies['gen-01-criador']?.passageRef);
