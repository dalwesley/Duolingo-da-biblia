/// Falas do companheiro — jogo + aprendizado, sem tom de retiro.
class MascotMessages {
  static String celebration({required bool isBoss, required int pct}) {
    if (isBoss) {
      return pct >= 80
          ? 'Desafio concluído. Você avançou de verdade.'
          : 'Desafio feito. Revise e siga para a próxima.';
    }
    if (pct == 100) return 'Lição perfeita. Essa passagem ficou na memória.';
    if (pct >= 70) return 'Boa clareza. Você está aprendendo de verdade.';
    return 'Missão feita. Volte e reforçe o que faltou.';
  }
}
