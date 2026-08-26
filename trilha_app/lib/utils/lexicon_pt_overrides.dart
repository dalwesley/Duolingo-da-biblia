/// Correções pontuais do léxico traduzido por máquina (EN→PT).
///
/// Dois problemas se acumulam no SQLite:
/// 1. Nomes próprios viram substantivo comum (Ham→presunto).
/// 2. O parser do TBESH ficava com o ÚLTIMO homônimo (H2617B vergonha,
///    H0430I Gibeate-elohim, H1697 "Crônicas") em vez do sentido geral.
///
/// Aplicado na leitura para não depender de regenerar o SQLite.
library;

class LexiconPtOverride {
  final String gloss;
  final String? definition;

  const LexiconPtOverride({required this.gloss, this.definition});
}

const lexiconPtOverrides = <String, LexiconPtOverride>{
  'H2526': LexiconPtOverride(
    gloss: 'Cam',
    definition:
        'Cam = "quente"\n'
        'Nome próprio: segundo filho de Noé, pai de Canaã e de povos das terras do sul.\n'
        'Em uso posterior, nome coletivo para os egípcios.\n'
        'Também as terras dos descendentes de Cam.',
  ),
  'H1990': LexiconPtOverride(
    gloss: 'Hã',
    definition:
        'Hã = "quente" ou "queimado de sol"\n'
        'Lugar onde Quedorlaomer e seus aliados derrotaram os zuzins, '
        'provavelmente no território dos amonitas, a leste do Jordão.',
  ),
  'H2540': LexiconPtOverride(
    gloss: 'Hamom',
    definition:
        'Hamom = "fontes quentes"\n'
        'Cidade em Naftali atribuída aos levitas; também chamada Hamate e Hamote-Dor.',
  ),
  'H0347': LexiconPtOverride(gloss: 'Jó'),
  'H3876': LexiconPtOverride(gloss: 'Ló'),
  'G3091': LexiconPtOverride(gloss: 'Ló'),
  'G3138': LexiconPtOverride(gloss: 'Marcos'),

  // Homônimos: o TBESH lista o sentido raro por último e o build antigo ganhava.
  // H1254 não tem entrada G — só A (criar) e B (engordar). O last-wins ficou com B.
  'H1254': LexiconPtOverride(
    gloss: 'criar',
    definition:
        '1. Criar, formar — ato de Deus que faz existir (Gn 1.1).\n'
        '2. Raro: ser gordo; (hifil) engordar (1 Sm 2.29).',
  ),
  'H7225': LexiconPtOverride(
    gloss: 'princípio, começo',
    definition:
        'Começo, primeiro, parte principal. Em Gn 1.1 é o princípio, não "o melhor".',
  ),
  'H4325': LexiconPtOverride(
    gloss: 'água',
    definition: 'Água, águas. Raro como nome de lugar (Porta das Águas).',
  ),
  'H0430': LexiconPtOverride(
    gloss: 'Deus',
    definition:
        '1. Deus — plural de excelência para o Deus de Israel.\n'
        '2. deuses das nações, quando o contexto é pagão.\n'
        '3. Juízes ou poderes, em usos figurados.',
  ),
  'H2617': LexiconPtOverride(
    gloss: 'bondade, misericórdia',
    definition:
        '1. Bondade fiel (ḥesed): misericórdia, lealdade, amor da aliança.\n'
        '2. Raro: vergonha, afronta (como em Lv 20.17).',
  ),
  'H1697': LexiconPtOverride(
    gloss: 'palavra',
    definition:
        '1. Palavra, fala, comando.\n'
        '2. Coisa, assunto, feito.\n'
        '3. Como título, as Crônicas (os "atos" dos reis).',
  ),
  'H4428': LexiconPtOverride(
    gloss: 'rei',
    definition: 'Rei, soberano. Raro como nome de lugar (Vale do Rei).',
  ),
  'H5921': LexiconPtOverride(
    gloss: 'sobre',
    definition: 'Preposição: sobre, em, contra, a respeito de.',
  ),
  'H0410': LexiconPtOverride(
    gloss: 'Deus',
    definition: 'Deus, o Poderoso; às vezes "deus" ou herói poderoso.',
  ),
  'H5971': LexiconPtOverride(
    gloss: 'povo',
    definition: 'Povo, nação, gente — a comunidade, não "criaturas".',
  ),
  'G2424': LexiconPtOverride(
    gloss: 'Jesus',
    definition:
        'Jesus (Iēsous). No NT, o Messias. O mesmo nome grego traduz Josué no AT grego.',
  ),
  'G0846': LexiconPtOverride(
    gloss: 'ele',
    definition: 'Pronome: ele, ela, isso; às vezes enfático (ele mesmo).',
  ),

  // Falsos amigos da tradução automática de partículas STEP.
  'H9001': LexiconPtOverride(
    gloss: 'e',
    definition: 'Vav verbal: liga-se ao verbo (muitas vezes conversivo).',
  ),
  'H9004': LexiconPtOverride(
    gloss: 'como',
    definition: 'Prefixo kaph: como, conforme, segundo.',
  ),
  'H9008': LexiconPtOverride(
    gloss: 'acaso',
    definition: 'Hé interrogativo: marca o início de uma pergunta.',
  ),
  'H0853': LexiconPtOverride(
    gloss: 'objeto',
    definition:
        'Marca de objeto definido (et). Em português costuma não se traduzir.',
  ),
};

String overlayLexiconGloss(String strongId, String gloss) {
  final o = lexiconPtOverrides[strongId];
  if (o != null) return o.gloss;
  return tidyGloss(gloss);
}

String overlayLexiconDefinition(String strongId, String definition) {
  final o = lexiconPtOverrides[strongId];
  if (o != null && o.definition != null && o.definition!.isNotEmpty) {
    return o.definition!;
  }
  var text = tidyDefinition(definition);
  if (o != null) {
    final g = o.gloss;
    text = text
        .replaceAll('Presunto', g)
        .replaceAll('presunto', g)
        .replaceAll('Trabalho', g)
        .replaceAll('Lote', g)
        .replaceAll('Marca', g);
  }
  return text;
}

/// Compacta o gloss STEP: tira subsignificado depois de ":", colchetes e parênteses.
String tidyGloss(String gloss) {
  var s = gloss.trim();
  if (s.isEmpty) return s;

  const special = {
    '&': 'e',
    '[?]': 'acaso',
    '[Obj.]': 'objeto',
    '[obj.]': 'objeto',
    '[o]': 'o',
    '[ ]': '',
    '[-]': '',
    '[.]': '',
    '[¶]': '',
  };
  if (special.containsKey(s)) return special[s]!;

  s = s.replaceAll(RegExp(r'[\[\]]'), '');
  final colon = s.indexOf(':');
  if (colon > 0) {
    final left = s.substring(0, colon).trim();
    if (left.isNotEmpty &&
        left.length <= 28 &&
        !left.contains('(') &&
        !RegExp(r'[:/;0-9]').hasMatch(left)) {
      s = left;
    }
  }
  s = s.replaceAll(RegExp(r'\s*\([^)]*\)'), '');
  return s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Remove a linha de subsignificado STEP que começa com ":".
String tidyDefinition(String definition) {
  var t = definition.trim();
  if (t.isEmpty) return t;
  t = t.replaceFirst(RegExp(r'^:[^\n]*\n+'), '');
  return t.trim();
}
