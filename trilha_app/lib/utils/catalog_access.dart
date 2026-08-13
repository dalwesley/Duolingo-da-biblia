/// Acesso ao catálogo de trilhas/passos/modos.
///
/// Default da loja: catálogo **fechado** (unlock narrativo vale).
/// Em teste com usuários reais, liberar tudo com:
/// `flutter run --dart-define=OPEN_ALL_TRAILS=true`
class CatalogAccess {
  CatalogAccess._();

  /// Default `false` (loja). Testers: `--dart-define=OPEN_ALL_TRAILS=true`.
  static const bool openAllForTesting = bool.fromEnvironment(
    'OPEN_ALL_TRAILS',
    defaultValue: false,
  );
}
