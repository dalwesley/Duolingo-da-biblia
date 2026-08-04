/// Copy de atraso — poeira na trilha, caravana à frente. Curto, cinematográfico.
class DustCopy {
  DustCopy._();

  static int get _tick =>
      DateTime.now().day * 17 + DateTime.now().hour * 3;

  // ── Notificações: título curto (cabe na bandeja) ─────────────────────────

  static String atRiskTitle({bool lateEvening = false}) {
    if (lateEvening) {
      return _pick(const [
        'Poeira no fim do dia',
        'A caravana some no pó',
        'Quase meia-noite de poeira',
      ]);
    }
    final hour = DateTime.now().hour;
    if (hour < 14) {
      return _pick(const [
        'Comendo poeira',
        'A trilha já empoeira',
        'Um passo atrás',
      ]);
    }
    return _pick(const [
      'Ficando pra trás',
      'Pó na sequência',
      'A caravana te ultrapassa',
    ]);
  }

  static String atRiskBody({
    required String name,
    required String countdown,
    required bool hasFreeze,
    required int streak,
  }) {
    final days = streak == 1 ? '1 dia' : '$streak dias';
    if (hasFreeze) {
      return _pick([
        '$name · $countdown e o pó sobe. Um passo limpa — ou o gelo cobre 1 dia.',
        'Caravana na frente. Você com $days ainda em jogo. Faltam $countdown.',
        'Trilha coberta de pó. $countdown · continue a caminhada (gelo à postos).',
      ]);
    }
    return _pick([
      '$name · sem gelo e comendo poeira. Faltam $countdown. Uma lição e você alcança.',
      '$days em risco sob o pó. Faltam $countdown — caminhe antes que suma.',
      'A poeira engole a sequência. $countdown · uma missão limpa o caminho.',
    ]);
  }

  static String eveningSoftBody({
    required String name,
    required String countdown,
    required bool hasFreeze,
  }) {
    if (hasFreeze) {
      return _pick([
        '$name, o dia vira poeira. Faltam $countdown — caminhe, ou o gelo cobre 1 dia.',
        'Últimas $countdown. Continue a caminhada antes que a caravana some no pó.',
      ]);
    }
    return _pick([
      '$name, faltam $countdown e sem gelo. Uma lição — ou a sequência vira poeira.',
      'Noite fechando. $countdown · continue a caminhada agora.',
    ]);
  }

  static String lostAwayTitle({required int daysAway}) {
    if (daysAway >= 3) {
      return _pick(const [
        'Sumiu na poeira',
        'A trilha te espera',
        'Volta do pó',
      ]);
    }
    if (daysAway >= 2) {
      return _pick(const [
        'Dois dias de poeira',
        'Ainda dá pra alcançar',
        'Poeira acumulada',
      ]);
    }
    return _pick(const [
      'Um dia de poeira',
      'Trilha empoeirada',
      'Ficou pra trás',
    ]);
  }

  static String lostAwayBody({
    required String name,
    required int streak,
    required int daysAway,
    required bool hasFreeze,
  }) {
    final days = streak == 1 ? '1 dia' : '$streak dias';
    if (daysAway >= 3) {
      return hasFreeze
          ? '$name, $daysAway dias no pó. O gelo ainda cobre 1 falta — retome a caminhada.'
          : '$name, $daysAway dias comendo poeira. Uma lição limpa o caminho e recomeça.';
    }
    if (daysAway >= 2) {
      return hasFreeze
          ? '$name, dois dias de poeira. Gelo ainda pode salvar 1 dia — volte hoje.'
          : '$name, dois dias pra trás. Uma missão e a caravana te vê de novo.';
    }
    return streak > 0
        ? '$name, $days cobertos de pó. Uma lição e você deixa a poeira pra trás.'
        : '$name, a trilha empoeirou. Um passo basta pra limpar o caminho.';
  }

  // ── UI in-app (curto, sob o card / marcos) ───────────────────────────────

  static String uiRiskLine({required bool hasFreeze}) {
    if (hasFreeze) {
      return _pick(const [
        'Comendo poeira · gelo ainda cobre 1 dia',
        'Ficando pra trás · gelo à postos',
        'Pó na trilha · gelo cobre 1 falta',
      ]);
    }
    return _pick(const [
      'Comendo poeira · caminhe agora',
      'Ficando pra trás · sem gelo',
      'A caravana some · uma lição alcança',
    ]);
  }

  static String uiRiskDetail() => _pick(const [
        'Ficando pra trás · continue a caminhada',
        'Comendo poeira · um passo limpa o caminho',
        'Pó na sequência · caminhe hoje',
      ]);

  /// Linha do hero card (com countdown).
  static String heroRiskLine({
    required String countdown,
    required bool hasFreeze,
  }) {
    if (hasFreeze) {
      return _pick([
        'Faltam $countdown · um passo alcança — ou o gelo cobre 1 dia',
        'Faltam $countdown · poeira sobe · gelo ainda cobre 1 falta',
        'Faltam $countdown · continue a caminhada (gelo à postos)',
      ]);
    }
    return _pick([
      'Faltam $countdown · sem gelo · a caravana segue sem você',
      'Faltam $countdown · poeira engole a sequência',
      'Faltam $countdown · uma lição limpa o caminho',
    ]);
  }

  static String _pick(List<String> options) {
    if (options.isEmpty) return '';
    return options[_tick.abs() % options.length];
  }
}
