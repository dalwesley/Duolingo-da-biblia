/// Monta o que o aluno vê: sentido neste versículo, não o primeiro homônimo.
library;

import 'answer_phrase.dart';
import 'lexicon_pt_overrides.dart';
import 'morphology.dart';
import 'strong_id.dart';
import 'strong_text.dart';

class TokenStudyView {
  final String gloss;
  final List<String> otherSenses;
  final List<String> needles;
  final StrongKind kind;
  final String kindLabel;
  final String? grammarNote;
  final bool extended;
  final bool inVerse;

  const TokenStudyView({
    required this.gloss,
    required this.otherSenses,
    required this.needles,
    required this.kind,
    required this.kindLabel,
    required this.grammarNote,
    required this.extended,
    required this.inVerse,
  });

  bool get isAffix => kind != StrongKind.word;
}

TokenStudyView buildTokenStudyView({
  required String strong,
  required String morph,
  required String tokenGloss,
  String entryGloss = '',
  String definition = '',
  required String verseText,
  required bool hebrew,
}) {
  // Token = sentido neste versículo (TAHOT). Léxico só entra se o token vier vazio.
  final raw = tokenGloss.trim().isNotEmpty ? tokenGloss : entryGloss;
  final base = overlayLexiconGloss(strong, raw);
  final withSuffix = attachSuffixGloss(base, morph);
  final entryAligned = entryGloss.trim().isEmpty
      ? ''
      : overlayLexiconGloss(strong, entryGloss);
  final forAlign =
      entryAligned.isNotEmpty && foldKey(entryAligned) != foldKey(base)
      ? '$withSuffix, $entryAligned'
      : withSuffix;
  final gloss = alignGlossToVerse(
    verseText,
    forAlign,
    definition: overlayLexiconDefinition(strong, definition),
  );
  final needles = studyNeedles(withSuffix, morph, verseGloss: gloss);
  final others = <String>[];
  for (final b in glossNeedles(withSuffix)) {
    if (foldKey(b) == foldKey(gloss)) continue;
    others.add(b);
  }
  final kind = strongKind(strong);
  return TokenStudyView(
    gloss: gloss,
    otherSenses: others.take(6).toList(),
    needles: needles,
    kind: kind,
    kindLabel: strongKindLabel(kind, hebrew: hebrew),
    grammarNote: kind == StrongKind.word ? null : strongKindNote(kind),
    extended: isExtendedStrong(strong),
    inVerse: highlightRanges(verseText, needles).isNotEmpty,
  );
}
