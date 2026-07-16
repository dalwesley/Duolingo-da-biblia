import 'dart:math';

/// Falas do companheiro de caminhada por contexto.
class MascotMessages {
  static final _random = Random();

  static String homeGreeting(String name) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia, $name. Continue sua caminhada.';
    if (hour < 18) return 'Olá, $name. A Palavra ilumina o próximo passo.';
    return 'Boa noite, $name. Ainda há tempo para um passo hoje.';
  }

  static String homeTip() {
    const tips = [
      'Cada passo mais perto de Cristo.',
      'A Palavra já iluminou seu caminho hoje?',
      'Não corra — caminhe. Um passo de cada vez.',
      'A Palavra ilumina o próximo passo.',
    ];
    return tips[_random.nextInt(tips.length)];
  }

  static String lessonEncouragement({required bool isBoss, required int questionIndex, required int total}) {
    if (isBoss) return 'Desafio especial. Leia com atenção e caminhe firme.';
    if (questionIndex == 0) return 'Vamos. A Palavra ilumina este passo.';
    if (questionIndex == total - 1) return 'Último trecho deste passo. Continue.';
    return 'Continue caminhando — cada resposta aproxima você de Cristo.';
  }

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
