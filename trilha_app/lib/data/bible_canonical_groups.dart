/// Divisões canônicas (ordem protestante) — Pentateuco, Históricos, etc.
library;

import 'package:flutter/painting.dart';

import '../l10n/l10n_global.dart';
import '../theme/app_colors.dart';

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

  /// Cor do gênero — AT em tons quentes (terra, fogo), NT em tons frios
  /// (água, céu). Vizinhos nunca repetem a mesma família.
  Color get tone => switch (id) {
    'pentateuco' => AppColors.sand,
    'historicos' => AppColors.ember,
    'poeticos' => const Color(0xFFFF8FB1),
    'profetas-maiores' => AppColors.coral,
    'profetas-menores' => AppColors.clay,
    'evangelhos' => AppColors.cedar,
    'historia-nt' => AppColors.sprout,
    'paulinas' => AppColors.sky,
    'gerais' => AppColors.orchid,
    'profecia' => const Color(0xFFB592FF),
    _ => AppColors.slate,
  };

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
    BibleCanonGroup(id: 'pentateuco', startIndex: 0, endIndex: 4),
    BibleCanonGroup(id: 'historicos', startIndex: 5, endIndex: 16),
    BibleCanonGroup(id: 'poeticos', startIndex: 17, endIndex: 21),
    BibleCanonGroup(id: 'profetas-maiores', startIndex: 22, endIndex: 26),
    BibleCanonGroup(id: 'profetas-menores', startIndex: 27, endIndex: 38),
    // Novo Testamento (39–65)
    BibleCanonGroup(id: 'evangelhos', startIndex: 39, endIndex: 42),
    BibleCanonGroup(id: 'historia-nt', startIndex: 43, endIndex: 43),
    BibleCanonGroup(id: 'paulinas', startIndex: 44, endIndex: 56),
    BibleCanonGroup(id: 'gerais', startIndex: 57, endIndex: 64),
    BibleCanonGroup(id: 'profecia', startIndex: 65, endIndex: 65),
  ];

  /// Cor do gênero do livro [bookIndex]; null fora do cânon.
  static Color? toneOf(int bookIndex) => ofBook(bookIndex)?.tone;

  /// Grupo do livro [bookIndex] (0–65), ou null fora do cânon.
  static BibleCanonGroup? ofBook(int bookIndex) {
    for (final g in groups) {
      if (bookIndex >= g.startIndex && bookIndex <= g.endIndex) return g;
    }
    return null;
  }
}
