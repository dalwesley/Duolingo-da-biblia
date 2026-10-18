/// Regras puras do Peregrino+: quando o recurso fica aberto.
class PlusAccess {
  PlusAccess._();

  /// Trava só quando dá para comprar. Sem plano na tela, nada fecha.
  static bool featuresOpen({
    required bool hasPlus,
    required bool canPurchase,
  }) => hasPlus || !canPurchase;
}
