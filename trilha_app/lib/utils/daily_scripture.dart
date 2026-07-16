import 'liturgical_calendar.dart';

/// Versículo do dia — litúrgico nos tempos fortes; senão, rotaciona no ano.
class DailyScripture {
  static const _verses = [
    ('Lâmpada para os meus pés é a tua palavra.', 'Salmos 119:105'),
    ('Tudo posso naquele que me fortalece.', 'Filipenses 4:13'),
    ('O Senhor é o meu pastor; nada me faltará.', 'Salmos 23:1'),
    ('Buscai primeiro o Reino de Deus.', 'Mateus 6:33'),
    ('No princípio era o Verbo, e o Verbo estava com Deus.', 'João 1:1'),
    ('O temor do Senhor é o princípio da sabedoria.', 'Provérbios 9:10'),
    ('Confia no Senhor de todo o teu coração.', 'Provérbios 3:5'),
    ('Porque Deus amou o mundo de tal maneira que deu o seu Filho.', 'João 3:16'),
    ('Aquietai-vos e sabei que eu sou Deus.', 'Salmos 46:10'),
    ('Lança o teu cuidado sobre o Senhor, e ele te susterá.', 'Salmos 55:22'),
    ('Vinde a mim, todos os que estais cansados.', 'Mateus 11:28'),
    ('O choro pode durar uma noite, mas a alegria vem pela manhã.', 'Salmos 30:5'),
    ('Não temas, porque eu sou contigo.', 'Isaías 41:10'),
    ('A graça do Senhor Jesus seja com o vosso espírito.', 'Filipenses 4:23'),
  ];

  static const _seasonalVerses = {
    LiturgicalSeason.advent: ('Porque um menino nos nasceu, um filho se nos deu.', 'Isaías 9:6'),
    LiturgicalSeason.christmas: ('E o Verbo se fez carne e habitou entre nós.', 'João 1:14'),
    LiturgicalSeason.lent: ('Convertei-vos a mim de todo o vosso coração.', 'Joel 2:12'),
    LiturgicalSeason.holyWeek: ('Mas ele foi traspassado pelas nossas transgressões.', 'Isaías 53:5'),
    LiturgicalSeason.easter: ('Mas, de fato, Cristo ressuscitou dentre os mortos.', '1 Coríntios 15:20'),
    LiturgicalSeason.pentecost: ('Todos ficaram cheios do Espírito Santo.', 'Atos 2:4'),
  };

  static (String text, String ref) today() {
    final moment = LiturgicalCalendar.momentFor();
    final seasonal = _seasonalVerses[moment.season];
    if (seasonal != null) return seasonal;
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return _verses[dayOfYear % _verses.length];
  }
}
