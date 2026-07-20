/// Falas do companheiro de caminhada por contexto.
class MascotMessages {
  static String celebration({required bool isBoss, required int pct}) {
    if (isBoss) {
      return pct >= 80
          ? 'Você avançou no desafio. Continue caminhando.'
          : 'Desafio atravessado. Revise e siga em frente.';
    }
    if (pct == 100) return 'A Palavra iluminou este trecho por completo.';
    if (pct >= 70) return 'Ótimo passo. A Palavra está ficando em você.';
    return 'Você avançou. Continue caminhando.';
  }
}
