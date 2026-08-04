/**
 * Fecha MissionStudy da abertura do Sermão: sm-01…sm-05
 * (banco de perguntas já existe; bosses ficam sem study — são revisão)
 * Usage: node admin/scripts/build_sermao_cena1_studies.mjs
 */
import { readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const assets = join(__dirname, '../../trilha_app/assets/data');

const studies = {
  'sm-01-rei-no-monte': {
    slug: 'sm-01-rei-no-monte',
    passageRef: 'Mateus 5:1–2',
    passageText:
      'Jesus, vendo a multidão, subiu ao monte, e, como se assentasse, aproximaram-se os seus discípulos; e, abrindo a boca, os ensinava, dizendo:',
    context:
      'Mateus apresenta Jesus como o novo Moisés — mas maior. O Sermão do Monte não é um código civil isolado; é a constituição do Reino anunciado em Mateus 4:17. Subir ao monte e sentar-se é postura de Rabino autoritativo. A multidão ouve; os discípulos se aproximam: o ensino do Reino forma primeiro quem já decidiu seguir. Antes das bem-aventuranças, Mateus destaca disposição: quem sobe, quem se chega, quem escuta.',
    keyword: 'Discipulado',
    keywordGloss:
      'Chegar-se a Jesus para aprender e obedecer — não apenas admirar de longe.',
    focusQuestion:
      'Estou me aproximando de Jesus como discípulo, ou só ouvindo de longe como multidão?',
    reflectionPrompts: [
      'O Reino começa com ouvir',
      'Autoridade de Jesus é maior que Moisés',
      'Discipulado é proximidade + obediência',
    ],
    relatedVerses: [
      {
        reference: 'Mateus 4:17',
        reason: 'O sermão flui do anúncio: “Arrependei-vos, porque é chegado o Reino”.',
      },
      {
        reference: 'Mateus 7:28–29',
        reason: 'A multidão se admira: Ele ensina como quem tem autoridade.',
      },
      {
        reference: 'Êxodo 19:3–6',
        reason: 'Eco de Sinai — agora a lei do Reino sai da boca do Filho.',
      },
      {
        reference: 'João 6:68',
        reason: 'Só Jesus tem palavras de vida eterna; o discípulo permanece junto.',
      },
    ],
  },
  'sm-02-pobres-de-espirito': {
    slug: 'sm-02-pobres-de-espirito',
    passageRef: 'Mateus 5:3',
    passageText:
      'Bem-aventurados os pobres de espírito, porque deles é o Reino dos céus.',
    context:
      '“Pobre de espírito” não é baixa autoestima nem romantizar miséria material. No hebraico bíblico, anawim descreve quem reconhece dependência total de Deus — sem recursos próprios para se justificar. É a porta do Sermão: sem mendigar graça, o resto vira moralismo. A promessa é presente (“deles é”), não só futura: o Reino pertence a quem chega de mãos vazias.',
    keyword: 'Pobreza de espírito',
    keywordGloss:
      'Reconhecer diante de Deus que nada tenho para barganhar — só necessidade de graça.',
    focusQuestion:
      'Em que área da vida ainda confio na minha suficiência em vez de dependência de Deus?',
    reflectionPrompts: [
      'O Reino começa de joelhos',
      'Autossuficiência fecha a porta',
      'Mãos vazias recebem o Reino',
    ],
    relatedVerses: [
      {
        reference: 'Isaías 57:15',
        reason: 'Deus habita com o contrito e abatido de espírito.',
      },
      {
        reference: 'Isaías 66:2',
        reason: 'O Senhor olha para o humilde e que treme diante da Sua palavra.',
      },
      {
        reference: 'Lucas 18:13–14',
        reason: 'O publicano justifica-se: “tem misericórdia de mim, pecador”.',
      },
      {
        reference: 'Apocalipse 3:17–18',
        reason: 'Laodiceia pensava ser rica — Jesus a chama a comprar verdadeiramente.',
      },
    ],
  },
  'sm-03-os-que-choram': {
    slug: 'sm-03-os-que-choram',
    passageRef: 'Mateus 5:4',
    passageText:
      'Bem-aventurados os que choram, porque eles serão consolados.',
    context:
      'O choro aqui não é qualquer tristeza. No fluxo das bem-aventuranças, é lamento pelo pecado próprio e pela quebrantura do mundo — o oposto do coração endurecido. Consolo (parakaleo) aponta para o Espírito Consolador e para a restauração final. Quem foge do lamento santo também foge da cura. Jesus não anula a dor; promete presença e esperança no meio dela.',
    keyword: 'Lamento',
    keywordGloss:
      'Dor consciente diante do pecado e do sofrimento — caminho para o consolo de Deus.',
    focusQuestion:
      'Há algo que Deus quer que eu lamente de verdade, em vez de anestesiar?',
    reflectionPrompts: [
      'Lamento santo abre espaço ao consolo',
      'Dureza de coração não é força',
      'O Consolador encontra quem chora',
    ],
    relatedVerses: [
      {
        reference: 'Salmo 34:18',
        reason: 'Perto está o Senhor dos que têm o coração quebrantado.',
      },
      {
        reference: 'Salmo 51:17',
        reason: 'Sacrifícios a Deus: espírito quebrantado e coração contrito.',
      },
      {
        reference: 'João 16:20–22',
        reason: 'A tristeza dos discípulos se converterá em alegria.',
      },
      {
        reference: 'Apocalipse 21:4',
        reason: 'Deus enxugará toda lágrima — o consolo escatológico.',
      },
    ],
  },
  'sm-04-os-mansos': {
    slug: 'sm-04-os-mansos',
    passageRef: 'Mateus 5:5',
    passageText:
      'Bem-aventurados os mansos, porque eles herdarão a terra.',
    context:
      'Mansidão (praüs) não é passividade covarde. É força sob controle — o oposto da agressão que disputa status. Jesus se descreve como manso e humilde (Mt 11:29). Herdar a terra ecoa o Salmo 37: os mansos não conquistam pelo cotovelo; recebem a herança do Senhor. No Império Romano e em qualquer cultura de poder, isso é subversivo: o Reino recompensa quem não esmaga o outro.',
    keyword: 'Mansidão',
    keywordGloss:
      'Força submetida a Deus — sem violência de ego, sem desistir da verdade.',
    focusQuestion:
      'Onde minha reação costuma ser força bruta de ego em vez de mansidão?',
    reflectionPrompts: [
      'Mansidão é força sob senhorio',
      'A herança não se arrebata',
      'Jesus é o modelo do manso',
    ],
    relatedVerses: [
      {
        reference: 'Salmo 37:11',
        reason: 'Os mansos herdarão a terra e se deleitarão em paz.',
      },
      {
        reference: 'Mateus 11:29',
        reason: 'Jesus: “sou manso e humilde de coração”.',
      },
      {
        reference: 'Números 12:3',
        reason: 'Moisés era mui manso — liderança sem autoexaltação.',
      },
      {
        reference: 'Gálatas 5:22–23',
        reason: 'Mansidão é fruto do Espírito, não técnica de imagem.',
      },
    ],
  },
  'sm-05-fome-e-sede-de-justica': {
    slug: 'sm-05-fome-e-sede-de-justica',
    passageRef: 'Mateus 5:6',
    passageText:
      'Bem-aventurados os que têm fome e sede de justiça, porque eles serão fartos.',
    context:
      'Fome e sede descrevem desejo visceral — não curiosidade casual. “Justiça” (dikaiosynē) em Mateus une retidão diante de Deus e vida alinhada ao Reino (cf. 6:33). Não é só ativismo social nem só status religioso; é anseio de que a vontade de Deus seja feita — em mim e no mundo. A promessa “serão fartos” garante que Deus sacia quem busca de verdade; o formalismo nunca chega.',
    keyword: 'Justiça',
    keywordGloss:
      'Vida reta conforme o caráter e o Reino de Deus — relação com Ele e com o próximo.',
    focusQuestion:
      'O que minha agenda diária revela que eu realmente “tenho fome”?',
    reflectionPrompts: [
      'Desejo revela senhorio',
      'Buscar primeiro o Reino',
      'Deus farta quem tem fome real',
    ],
    relatedVerses: [
      {
        reference: 'Salmo 42:1–2',
        reason: 'A alma com sede de Deus — imagem da fome santa.',
      },
      {
        reference: 'Mateus 6:33',
        reason: 'Buscai primeiro o Reino e a sua justiça.',
      },
      {
        reference: 'Amós 5:24',
        reason: 'Corra o juízo como as águas — justiça que Deus ama.',
      },
      {
        reference: 'João 6:35',
        reason: 'Jesus é o pão: quem vem a Ele não terá fome.',
      },
    ],
  },
};

const verses = {
  'Mateus 5:1–2': studies['sm-01-rei-no-monte'].passageText,
  'Mateus 5:1': 'Jesus, vendo a multidão, subiu ao monte…',
  'Mateus 5:2': 'E, abrindo a boca, os ensinava, dizendo:',
  'Mateus 5:3': studies['sm-02-pobres-de-espirito'].passageText,
  'Mateus 5:4': studies['sm-03-os-que-choram'].passageText,
  'Mateus 5:5': studies['sm-04-os-mansos'].passageText,
  'Mateus 5:6': studies['sm-05-fome-e-sede-de-justica'].passageText,
  'Mateus 4:17': 'Desde então, começou Jesus a pregar e a dizer: Arrependei-vos, porque é chegado o Reino dos céus.',
  'Mateus 7:28–29': 'A multidão se admirou da sua doutrina, porque os ensinava como quem tem autoridade.',
  'Êxodo 19:3–6': 'Moisés subiu a Deus… sereis para mim reino de sacerdotes e nação santa.',
  'João 6:68': 'Simão Pedro respondeu: Senhor, para quem iremos? Tu tens as palavras da vida eterna.',
  'Isaías 57:15': 'Habito com o contrito e abatido de espírito, para vivificar o espírito dos abatidos.',
  'Isaías 66:2': 'Para esse olharei: para o pobre e abatido de espírito e que treme da minha palavra.',
  'Lucas 18:13–14': 'O publicano… dizia: Ó Deus, sê propício a mim, pecador! Este desceu justificado.',
  'Apocalipse 3:17–18': 'Dizes: Rico sou… e não sabes que és… pobre, cego e nu.',
  'Salmo 34:18': 'Perto está o Senhor dos que têm o coração quebrantado.',
  'Salmo 51:17': 'Os sacrifícios de Deus são o espírito quebrantado.',
  'João 16:20–22': 'A vossa tristeza se converterá em alegria.',
  'Apocalipse 21:4': 'Deus limpará de seus olhos toda lágrima.',
  'Salmo 37:11': 'Mas os mansos herdarão a terra e se deleitarão na abundância de paz.',
  'Mateus 11:29': 'Tomai sobre vós o meu jugo… porque sou manso e humilde de coração.',
  'Números 12:3': 'Moisés era mui manso, mais do que todos os homens.',
  'Gálatas 5:22–23': 'O fruto do Espírito é… mansidão, domínio próprio.',
  'Salmo 42:1–2': 'Como o cervo brama… assim a minha alma tem sede de Deus.',
  'Mateus 6:33': 'Buscai primeiro o Reino de Deus, e a sua justiça.',
  'Amós 5:24': 'Corra o juízo como as águas, e a justiça como o ribeiro impetuoso.',
  'João 6:35': 'Eu sou o pão da vida; quem vem a mim não terá fome.',
};

const data = JSON.parse(readFileSync(join(assets, 'mission_studies.json'), 'utf8'));
for (const [slug, study] of Object.entries(studies)) {
  data.studies[slug] = study;
}
Object.assign(data.verses || (data.verses = {}), verses);
writeFileSync(join(assets, 'mission_studies.json'), JSON.stringify(data, null, 2) + '\n');

const missing = ['sm-01', 'sm-02', 'sm-03', 'sm-04', 'sm-05'].filter(
  (p) => !Object.keys(data.studies).some((s) => s.startsWith(p)),
);
console.log('Wrote sm-01…05 studies. Still missing prefixes:', missing.length ? missing : 'none');
console.log(
  'Sermão lesson studies:',
  Object.keys(data.studies).filter((s) => s.startsWith('sm-') && !s.includes('boss')).length,
);
