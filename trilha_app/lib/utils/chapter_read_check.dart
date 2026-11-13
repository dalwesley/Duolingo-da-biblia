/// Leitura "de verdade" para a leitura da semana do grupo: o capítulo
/// precisa ficar aberto um tempo mínimo (metade de uma leitura a 250
/// palavras por minuto) ou ser ouvido em áudio.
class ChapterReadCheck {
  ChapterReadCheck._();

  static const wordsPerMinute = 250;
  static const share = 0.5;
  static const minSeconds = 20;
  static const maxSeconds = 150;

  /// Segundos mínimos com o capítulo aberto.
  static int secondsFor(List<String> verses) {
    var words = 0;
    for (final v in verses) {
      words += v.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    }
    final secs = (words / wordsPerMinute * 60 * share).round();
    return secs.clamp(minSeconds, maxSeconds);
  }

  static bool attentive({
    required List<String> verses,
    required Duration open,
    bool listened = false,
  }) => listened || open.inSeconds >= secondsFor(verses);
}
