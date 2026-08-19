/// Correções pontuais do léxico traduzido por máquina (EN→PT).
///
/// O gloss inglês de nomes próprios vira substantivo comum no Google Translate
/// (Ham→presunto, Job→trabalho, Lot→lote, Mark→marca). Aplicado na leitura
/// para não depender de regenerar o SQLite.
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
};

String overlayLexiconGloss(String strongId, String gloss) {
  return lexiconPtOverrides[strongId]?.gloss ?? gloss;
}

String overlayLexiconDefinition(String strongId, String definition) {
  final o = lexiconPtOverrides[strongId];
  if (o == null) return definition;
  if (o.definition != null && o.definition!.isNotEmpty) return o.definition!;
  final bad = definition;
  final g = o.gloss;
  return bad
      .replaceAll('Presunto', g)
      .replaceAll('presunto', g)
      .replaceAll('Trabalho', g)
      .replaceAll('Lote', g)
      .replaceAll('Marca', g);
}
