import 'dart:math';

/// Falas do mascote por contexto.
class MascotMessages {
  static final _random = Random();

  static String homeGreeting(String name) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia, $name! Pronto para aprender?';
    if (hour < 18) return 'Olá, $name! Sua trilha te espera.';
    return 'Boa noite, $name! Que tal uma missão antes de dormir?';
  }

  static String homeTip() {
    const tips = [
      'Uma missão por dia mantém sua sequência viva.',
      'Leia o versículo de referência após cada pergunta.',
      'Desafios especiais dão mais XP — prepare-se!',
      'A Palavra ilumina cada passo da sua jornada.',
    ];
    return tips[_random.nextInt(tips.length)];
  }

  static String lessonEncouragement({required bool isBoss, required int questionIndex, required int total}) {
    if (isBoss) return 'Desafio especial! Concentre-se nas Escrituras.';
    if (questionIndex == 0) return 'Vamos lá! Leia com atenção e confie no que aprendeu.';
    if (questionIndex == total - 1) return 'Última pergunta! Você está quase lá.';
    return 'Continue firme — cada resposta aproxima você da meta.';
  }

  static String celebration({required bool isBoss, required int pct}) {
    if (isBoss) return pct >= 80 ? 'Desafio dominado! Você é incrível.' : 'Desafio concluído! Revise e volte mais forte.';
    if (pct == 100) return 'Perfeito! Você memorizou essa passagem.';
    if (pct >= 70) return 'Ótimo trabalho! A Palavra está ficando em você.';
    return 'Missão completa! Revise os versículos e siga em frente.';
  }
}
