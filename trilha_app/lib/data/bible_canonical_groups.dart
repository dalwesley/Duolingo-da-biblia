/// Divisões canônicas (ordem protestante) — Pentateuco, Históricos, etc.
library;

import '../l10n/l10n_global.dart';

class BibleCanonGroup {
  final String id;

  /// Índices inclusivos no cânon de 66 livros (0-based).
  final int startIndex;
  final int endIndex;

  const BibleCanonGroup({
    required this.id,
    required this.startIndex,
    required this.endIndex,
  });

  int get count => endIndex - startIndex + 1;

  String get title => switch (id) {
    'pentateuco' => L10n.current.canonPentateucoTitle,
    'historicos' => L10n.current.canonHistoricosTitle,
    'poeticos' => L10n.current.canonPoeticosTitle,
    'profetas-maiores' => L10n.current.canonProfetasMaioresTitle,
    'profetas-menores' => L10n.current.canonProfetasMenoresTitle,
    'evangelhos' => L10n.current.canonEvangelhosTitle,
    'historia-nt' => L10n.current.canonHistoriaNtTitle,
    'paulinas' => L10n.current.canonPaulinasTitle,
    'gerais' => L10n.current.canonGeraisTitle,
    'profecia' => L10n.current.canonProfeciaTitle,
    _ => L10n.current.canonPentateucoTitle,
  };

  String get blurb => switch (id) {
    'pentateuco' => L10n.current.canonPentateucoBlurb,
    'historicos' => L10n.current.canonHistoricosBlurb,
    'poeticos' => L10n.current.canonPoeticosBlurb,
    'profetas-maiores' => L10n.current.canonProfetasMaioresBlurb,
    'profetas-menores' => L10n.current.canonProfetasMenoresBlurb,
    'evangelhos' => L10n.current.canonEvangelhosBlurb,
    'historia-nt' => L10n.current.canonHistoriaNtBlurb,
    'paulinas' => L10n.current.canonPaulinasBlurb,
    'gerais' => L10n.current.canonGeraisBlurb,
    'profecia' => L10n.current.canonProfeciaBlurb,
    _ => L10n.current.canonPentateucoBlurb,
  };
}

class BibleCanonicalGroups {
  BibleCanonicalGroups._();

  static const groups = <BibleCanonGroup>[
    // Antigo Testamento (0–38)
    BibleCanonGroup(
      id: 'pentateuco',
      startIndex: 0,
      endIndex: 4,
    ),
    BibleCanonGroup(
      id: 'historicos',
      startIndex: 5,
      endIndex: 16,
    ),
    BibleCanonGroup(
      id: 'poeticos',
      startIndex: 17,
      endIndex: 21,
    ),
    BibleCanonGroup(
      id: 'profetas-maiores',
      startIndex: 22,
      endIndex: 26,
    ),
    BibleCanonGroup(
      id: 'profetas-menores',
      startIndex: 27,
      endIndex: 38,
    ),
    // Novo Testamento (39–65)
    BibleCanonGroup(
      id: 'evangelhos',
      startIndex: 39,
      endIndex: 42,
    ),
    BibleCanonGroup(
      id: 'historia-nt',
      startIndex: 43,
      endIndex: 43,
    ),
    BibleCanonGroup(
      id: 'paulinas',
      startIndex: 44,
      endIndex: 56,
    ),
    BibleCanonGroup(
      id: 'gerais',
      startIndex: 57,
      endIndex: 64,
    ),
    BibleCanonGroup(
      id: 'profecia',
      startIndex: 65,
      endIndex: 65,
    ),
  ];
}
