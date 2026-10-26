import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'icon_well.dart';
import 'lantern_glyph.dart';

/// Símbolos da marca — silhuetas sólidas, sem emoji.
///
/// Um glifo, um significado. Não reutilizar o mesmo desenho em
/// contextos diferentes (ex.: `chain` é opressão, `link` é o gesto Conecte).
enum CinematicGlyph {
  cosmos,
  sun,
  humanity,
  dove,
  tree,
  fall,
  tears,
  scales,
  flood,
  tower,
  star,
  crown,
  chain,
  sea,
  flame,
  scroll,
  seed,
  path,
  depths,
  spark,
  heart,
  mountain,
  book,
  calendar,
  gem,
  lamp,
  check,
  echo,
  target,
  tune,
  pencil,
  lock,
  search,
  shield,
  mail,
  frost,
  share,
  qr,
  copy,
  podium,
  rise,
  demote,
  people,
  home,
  back,
  // Gestos da missão — um por tipo, sem colidir com narrativa
  tap,
  stack,
  gap,
  link,
  // Chrome
  forward,
  chevron,
  close,
  bookmark,
  gift,
  bell,
  wrong,
  flag,
  refresh,
  stop,
  sprout,
  hourglass,
  // Marca do Peregrino+: o Anan com um +. Só para o Plus (selo, cartões,
  // paywall); a coroa fica com Travessia, perfeição e liderança.
  plus,
  // Medalhas — cada medalha tem o seu; não reaproveitar fora do cofre.
  bookmarked,
  glasses,
  library,
  mortarboard,
  eye,
  seal,
  sneaker,
  bolt,
  trophy,
  plane,
  megaphone,
  quote,
  mind,
  door,
  night,
  cactus,
  walker,
  calendarCheck,
  tent,
  cross,
  compass,
  returning,
  dawn,
  notebook,
  trailMap,
}

class CinematicGlyphResolver {
  static CinematicGlyph forMission(String title, {bool isBoss = false}) {
    if (isBoss) return CinematicGlyph.crown;
    final t = title.toLowerCase();
    if (t.contains('criou') ||
        t.contains('mundo') ||
        t.contains('princípio') ||
        t.contains('principio')) {
      return CinematicGlyph.cosmos;
    }
    if (t.contains('dias') ||
        t.contains('criação') ||
        t.contains('criacao') ||
        t.contains('luz')) {
      return CinematicGlyph.sun;
    }
    if (t.contains('imagem') || t.contains('homem') || t.contains('humano'))
      return CinematicGlyph.humanity;
    if (t.contains('descanso') || t.contains('sábado') || t.contains('sabado'))
      return CinematicGlyph.dove;
    if (t.contains('éden') || t.contains('eden') || t.contains('jardim'))
      return CinematicGlyph.tree;
    if (t.contains('desobediência') ||
        t.contains('desobediencia') ||
        t.contains('queda') ||
        t.contains('tentação') ||
        t.contains('tentacao')) {
      return CinematicGlyph.fall;
    }
    if (t.contains('consequência') || t.contains('consequencia'))
      return CinematicGlyph.tears;
    if (t.contains('caim') || t.contains('abel')) return CinematicGlyph.scales;
    if (t.contains('dilúvio') ||
        t.contains('diluvio') ||
        t.contains('noé') ||
        t.contains('noe') ||
        t.contains('arca')) {
      return CinematicGlyph.flood;
    }
    if (t.contains('babel')) return CinematicGlyph.tower;
    if (t.contains('abraão') || t.contains('abraao') || t.contains('promessa'))
      return CinematicGlyph.star;
    if (t.contains('páscoa') || t.contains('pascoa') || t.contains('cordeiro'))
      return CinematicGlyph.dove;
    if (t.contains('pragas')) return CinematicGlyph.flame;
    if (t.contains('mar vermelho') || t.contains('mar '))
      return CinematicGlyph.sea;
    if (t.contains('moisés') ||
        t.contains('moises') ||
        t.contains('sarça') ||
        t.contains('sarca')) {
      return CinematicGlyph.flame;
    }
    if (t.contains('opressão') ||
        t.contains('opressao') ||
        t.contains('egito') ||
        t.contains('escrav')) {
      return CinematicGlyph.chain;
    }
    return CinematicGlyph.scroll;
  }

  static CinematicGlyph forModule(String title) {
    return switch (title) {
      'A Criação' => CinematicGlyph.sun,
      'O Jardim' => CinematicGlyph.tree,
      'Depois do Éden' => CinematicGlyph.mountain,
      'Opressão no Egito' => CinematicGlyph.chain,
      'A Libertação' => CinematicGlyph.sea,
      'O Início' => CinematicGlyph.dove,
      'Ensino e Sinais' => CinematicGlyph.scroll,
      'Cruz e Ressurreição' => CinematicGlyph.heart,
      'A Igreja nasce' => CinematicGlyph.flame,
      'Esperança final' => CinematicGlyph.crown,
      _ => CinematicGlyph.scroll,
    };
  }

  static CinematicGlyph forTrail(String slug) {
    return switch (slug) {
      'genesis-1-11' || 'genesis-12-50' => CinematicGlyph.book,
      'exodo' => CinematicGlyph.mountain,
      'evangelhos' => CinematicGlyph.heart,
      'atos' => CinematicGlyph.flame,
      'apocalipse' => CinematicGlyph.crown,
      'salmos' || 'oracao' => CinematicGlyph.dove,
      'proverbios' => CinematicGlyph.gem,
      'profetas' => CinematicGlyph.spark,
      'cartas-paulo' => CinematicGlyph.scroll,
      'vida-crista' => CinematicGlyph.seed,
      'historia-igreja' => CinematicGlyph.tower,
      _ => CinematicGlyph.scroll,
    };
  }

  static CinematicGlyph forQuest(String id) {
    return switch (id) {
      'mission' => CinematicGlyph.path,
      'accuracy' => CinematicGlyph.target,
      'perfect' => CinematicGlyph.crown,
      'read' => CinematicGlyph.scroll,
      'bookmark' => CinematicGlyph.bookmark,
      'seasonal' => CinematicGlyph.calendar,
      'memory' => CinematicGlyph.heart,
      'w_missions' => CinematicGlyph.calendar,
      'w_days' => CinematicGlyph.flame,
      'w_perfect' => CinematicGlyph.gem,
      _ => CinematicGlyph.spark,
    };
  }

  /// Cor por quest — identidade própria, alinhada à família da seção.
  static Color accentForQuest(String id) {
    return switch (id) {
      'mission' => AppColors.accent,
      'accuracy' => AppColors.coral,
      'perfect' => AppColors.sand,
      'read' => AppColors.sand,
      'bookmark' => AppColors.clay,
      'seasonal' => AppColors.sand,
      'memory' => AppColors.clay,
      'w_missions' => AppColors.accent,
      'w_days' => AppColors.ember,
      'w_perfect' => AppColors.medalGold,
      _ => AppColors.accent,
    };
  }

  static Color paletteFor(CinematicGlyph glyph, {Color? accent}) {
    return switch (glyph) {
      CinematicGlyph.sun || CinematicGlyph.spark => AppColors.accent,
      CinematicGlyph.star => AppColors.sand,
      CinematicGlyph.bookmark => AppColors.clay,
      CinematicGlyph.cosmos => AppColors.sand,
      CinematicGlyph.depths => AppColors.orchid,
      CinematicGlyph.tree || CinematicGlyph.sprout => AppColors.sand,
      CinematicGlyph.seed => AppColors.accent,
      CinematicGlyph.flood ||
      CinematicGlyph.sea ||
      CinematicGlyph.tears ||
      CinematicGlyph.frost => AppColors.iceSoft,
      CinematicGlyph.flame => AppColors.ember,
      CinematicGlyph.fall || CinematicGlyph.flag => AppColors.ember,
      CinematicGlyph.heart || CinematicGlyph.dove => AppColors.clay,
      CinematicGlyph.crown || CinematicGlyph.lamp => AppColors.sand,
      CinematicGlyph.gem || CinematicGlyph.gift => AppColors.medalGold,
      CinematicGlyph.chain ||
      CinematicGlyph.mountain ||
      CinematicGlyph.tower => AppColors.sand,
      CinematicGlyph.scales ||
      CinematicGlyph.path ||
      CinematicGlyph.tap ||
      CinematicGlyph.stack ||
      CinematicGlyph.forward => AppColors.accent,
      CinematicGlyph.target || CinematicGlyph.link => AppColors.coral,
      CinematicGlyph.humanity => AppColors.clay,
      CinematicGlyph.echo => AppColors.clay,
      CinematicGlyph.book => accent ?? AppColors.accent,
      CinematicGlyph.scroll || CinematicGlyph.gap => accent ?? AppColors.sand,
      CinematicGlyph.calendar ||
      CinematicGlyph.hourglass => accent ?? AppColors.sand,
      CinematicGlyph.plus => AppColors.medalGold,
      CinematicGlyph.check => accent ?? AppColors.accent,
      CinematicGlyph.tune ||
      CinematicGlyph.pencil ||
      CinematicGlyph.share ||
      CinematicGlyph.refresh => accent ?? AppColors.accent,
      CinematicGlyph.lock => AppColors.sand,
      CinematicGlyph.search => AppColors.sand,
      CinematicGlyph.shield => AppColors.sand,
      CinematicGlyph.mail || CinematicGlyph.bell => AppColors.clay,
      CinematicGlyph.qr || CinematicGlyph.copy => accent ?? AppColors.accent,
      CinematicGlyph.podium || CinematicGlyph.rise => AppColors.accent,
      CinematicGlyph.demote ||
      CinematicGlyph.wrong ||
      CinematicGlyph.close => AppColors.error,
      CinematicGlyph.people => AppColors.clay,
      CinematicGlyph.home => AppColors.accent,
      CinematicGlyph.back ||
      CinematicGlyph.chevron => accent ?? AppColors.accent,
      CinematicGlyph.stop => AppColors.ember,
      CinematicGlyph.bookmarked => AppColors.accent,
      CinematicGlyph.glasses => AppColors.accent,
      CinematicGlyph.library => AppColors.accent,
      CinematicGlyph.mortarboard => AppColors.coral,
      CinematicGlyph.eye => AppColors.coral,
      CinematicGlyph.seal => AppColors.medalGold,
      CinematicGlyph.sneaker => AppColors.ember,
      CinematicGlyph.bolt => AppColors.ember,
      CinematicGlyph.trophy => AppColors.medalGold,
      CinematicGlyph.plane => AppColors.accent,
      CinematicGlyph.megaphone => AppColors.accent,
      CinematicGlyph.quote => AppColors.clay,
      CinematicGlyph.mind => AppColors.clay,
      CinematicGlyph.door => AppColors.sand,
      CinematicGlyph.night => AppColors.iceSoft,
      CinematicGlyph.cactus => AppColors.sand,
      CinematicGlyph.walker => AppColors.sand,
      CinematicGlyph.calendarCheck => AppColors.sand,
      CinematicGlyph.tent => AppColors.sand,
      CinematicGlyph.cross => AppColors.clay,
      CinematicGlyph.compass => AppColors.medalGold,
      CinematicGlyph.returning => AppColors.accent,
      CinematicGlyph.dawn => AppColors.accent,
      CinematicGlyph.notebook => AppColors.clay,
      CinematicGlyph.trailMap => AppColors.accent,
    };
  }
}

/// Ícone da marca — Phosphor duotone (MIT), num poço circular suave.
///
/// O enum segue sendo a fonte de significado; aqui só se troca o desenho.
/// Lanterna (vidas) e a marca do Plus (Anan com +) seguem desenhadas à mão.
class CinematicIcon extends StatelessWidget {
  final CinematicGlyph glyph;
  final double size;
  final Color? accent;
  final bool framed;
  final bool glowing;
  final bool animate;

  /// Traço único (sem a camada de fundo do duotone). Para glifos gravados ou
  /// sobrepostos, onde duas camadas embaralham o desenho.
  final bool line;

  const CinematicIcon({
    super.key,
    required this.glyph,
    this.size = 48,
    this.accent,
    this.framed = true,
    this.glowing = false,
    this.animate = false,
    this.line = false,
  });

  factory CinematicIcon.mission(
    String title, {
    Key? key,
    bool isBoss = false,
    double size = 48,
    Color? accent,
    bool framed = true,
    bool glowing = false,
    bool animate = false,
  }) {
    return CinematicIcon(
      key: key,
      glyph: CinematicGlyphResolver.forMission(title, isBoss: isBoss),
      size: size,
      accent: accent,
      framed: framed,
      glowing: glowing,
      animate: animate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = accent ?? CinematicGlyphResolver.paletteFor(glyph);
    final onDark = Appearance.of(context).onDark;
    final ink = onDark
        ? AppColors.glyphInk(color)
        : AppColors.glyphInkOnLight(color);
    final child = _glyph(ink);

    if (!framed) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      );
    }

    return IconWell(
      size: size,
      accent: color,
      glowing: glowing,
      onDark: onDark,
      child: child,
    );
  }

  Widget _glyph(Color ink) {
    final codes = _phosphor(glyph);
    if (codes == null) {
      final glyphSize = framed ? size * 0.72 : size;
      return CustomPaint(
        size: Size.square(glyphSize),
        painter: _GlyphPainter(glyph: glyph, ink: ink),
      );
    }
    final (bold, base, top) = codes;
    final glyphSize = framed ? size * 0.58 : size * 0.9;
    // Chrome e tamanhos pequenos: traço bold, que segura melhor que o duotone.
    if (line || glyphSize < 20 || _chrome.contains(glyph)) {
      return Icon(bold, size: glyphSize, color: ink);
    }
    return SizedBox.square(
      dimension: glyphSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(base, size: glyphSize, color: ink.withValues(alpha: 0.3)),
          Icon(top, size: glyphSize, color: ink),
        ],
      ),
    );
  }

  static const _chrome = {
    CinematicGlyph.back,
    CinematicGlyph.forward,
    CinematicGlyph.chevron,
    CinematicGlyph.close,
  };

  static const _bold = 'PhosphorBold';
  static const _duo = 'PhosphorDuotone';

  /// (bold, fundo do duotone, frente do duotone). Nulo = desenho próprio.
  /// Tudo const: o build release só embute os glifos usados.
  static (IconData, IconData, IconData)? _phosphor(CinematicGlyph g) =>
      switch (g) {
        CinematicGlyph.cosmos => const (
          // planet
          IconData(0xe652, fontFamily: _bold),
          IconData(0xe652, fontFamily: _duo),
          IconData(0xe653, fontFamily: _duo),
        ),
        CinematicGlyph.sun => const (
          // sun
          IconData(0xe472, fontFamily: _bold),
          IconData(0xe472, fontFamily: _duo),
          IconData(0xe473, fontFamily: _duo),
        ),
        CinematicGlyph.humanity => const (
          // personArmsSpread
          IconData(0xecfe, fontFamily: _bold),
          IconData(0xecfe, fontFamily: _duo),
          IconData(0xecff, fontFamily: _duo),
        ),
        CinematicGlyph.dove => const (
          // bird
          IconData(0xe72c, fontFamily: _bold),
          IconData(0xe72c, fontFamily: _duo),
          IconData(0xe72d, fontFamily: _duo),
        ),
        CinematicGlyph.tree => const (
          // tree
          IconData(0xe6da, fontFamily: _bold),
          IconData(0xe6da, fontFamily: _duo),
          IconData(0xe6db, fontFamily: _duo),
        ),
        CinematicGlyph.fall => const (
          // orange
          IconData(0xee40, fontFamily: _bold),
          IconData(0xee40, fontFamily: _duo),
          IconData(0xee41, fontFamily: _duo),
        ),
        CinematicGlyph.tears => const (
          // drop
          IconData(0xe210, fontFamily: _bold),
          IconData(0xe210, fontFamily: _duo),
          IconData(0xe211, fontFamily: _duo),
        ),
        CinematicGlyph.scales => const (
          // scales
          IconData(0xe750, fontFamily: _bold),
          IconData(0xe750, fontFamily: _duo),
          IconData(0xe751, fontFamily: _duo),
        ),
        CinematicGlyph.flood => const (
          // boat
          IconData(0xe786, fontFamily: _bold),
          IconData(0xe786, fontFamily: _duo),
          IconData(0xe787, fontFamily: _duo),
        ),
        CinematicGlyph.tower => const (
          // castleTurret
          IconData(0xe9d0, fontFamily: _bold),
          IconData(0xe9d0, fontFamily: _duo),
          IconData(0xe9d1, fontFamily: _duo),
        ),
        CinematicGlyph.star => const (
          // star
          IconData(0xe46a, fontFamily: _bold),
          IconData(0xe46a, fontFamily: _duo),
          IconData(0xe46b, fontFamily: _duo),
        ),
        CinematicGlyph.crown => const (
          // crown
          IconData(0xe614, fontFamily: _bold),
          IconData(0xe614, fontFamily: _duo),
          IconData(0xe615, fontFamily: _duo),
        ),
        CinematicGlyph.chain => const (
          // linkBreak
          IconData(0xe2e4, fontFamily: _bold),
          IconData(0xe2e4, fontFamily: _duo),
          IconData(0xe2e5, fontFamily: _duo),
        ),
        CinematicGlyph.sea => const (
          // waves
          IconData(0xe6de, fontFamily: _bold),
          IconData(0xe6de, fontFamily: _duo),
          IconData(0xe6df, fontFamily: _duo),
        ),
        CinematicGlyph.flame => const (
          // flame
          IconData(0xe624, fontFamily: _bold),
          IconData(0xe624, fontFamily: _duo),
          IconData(0xe625, fontFamily: _duo),
        ),
        CinematicGlyph.scroll => const (
          // scroll
          IconData(0xeb7a, fontFamily: _bold),
          IconData(0xeb7a, fontFamily: _duo),
          IconData(0xeb7b, fontFamily: _duo),
        ),
        CinematicGlyph.seed => const (
          // grains
          IconData(0xec68, fontFamily: _bold),
          IconData(0xec68, fontFamily: _duo),
          IconData(0xec69, fontFamily: _duo),
        ),
        CinematicGlyph.path => const (
          // footprints
          IconData(0xea88, fontFamily: _bold),
          IconData(0xea88, fontFamily: _duo),
          IconData(0xea89, fontFamily: _duo),
        ),
        CinematicGlyph.depths => const (
          // anchor
          IconData(0xe514, fontFamily: _bold),
          IconData(0xe514, fontFamily: _duo),
          IconData(0xe515, fontFamily: _duo),
        ),
        CinematicGlyph.spark => const (
          // sparkle
          IconData(0xe6a2, fontFamily: _bold),
          IconData(0xe6a2, fontFamily: _duo),
          IconData(0xe6a3, fontFamily: _duo),
        ),
        CinematicGlyph.heart => const (
          // heart
          IconData(0xe2a8, fontFamily: _bold),
          IconData(0xe2a8, fontFamily: _duo),
          IconData(0xe2a9, fontFamily: _duo),
        ),
        CinematicGlyph.mountain => const (
          // mountains
          IconData(0xe7ae, fontFamily: _bold),
          IconData(0xe7ae, fontFamily: _duo),
          IconData(0xe7af, fontFamily: _duo),
        ),
        CinematicGlyph.book => const (
          // bookOpenText
          IconData(0xe8f2, fontFamily: _bold),
          IconData(0xe8f2, fontFamily: _duo),
          IconData(0xe8f3, fontFamily: _duo),
        ),
        CinematicGlyph.calendar => const (
          // calendarDots
          IconData(0xe7b4, fontFamily: _bold),
          IconData(0xe7b4, fontFamily: _duo),
          IconData(0xe7b5, fontFamily: _duo),
        ),
        CinematicGlyph.gem => const (
          // diamond
          IconData(0xe1ec, fontFamily: _bold),
          IconData(0xe1ec, fontFamily: _duo),
          IconData(0xe1ed, fontFamily: _duo),
        ),
        CinematicGlyph.check => const (
          // checkCircle
          IconData(0xe184, fontFamily: _bold),
          IconData(0xe184, fontFamily: _duo),
          IconData(0xe185, fontFamily: _duo),
        ),
        CinematicGlyph.echo => const (
          // speakerHigh
          IconData(0xe44a, fontFamily: _bold),
          IconData(0xe44a, fontFamily: _duo),
          IconData(0xe44b, fontFamily: _duo),
        ),
        CinematicGlyph.target => const (
          // target
          IconData(0xe47c, fontFamily: _bold),
          IconData(0xe47c, fontFamily: _duo),
          IconData(0xe47d, fontFamily: _duo),
        ),
        CinematicGlyph.tune => const (
          // slidersHorizontal
          IconData(0xe434, fontFamily: _bold),
          IconData(0xe434, fontFamily: _duo),
          IconData(0xe435, fontFamily: _duo),
        ),
        CinematicGlyph.pencil => const (
          // pencilSimple
          IconData(0xe3b4, fontFamily: _bold),
          IconData(0xe3b4, fontFamily: _duo),
          IconData(0xe3b5, fontFamily: _duo),
        ),
        CinematicGlyph.lock => const (
          // lock
          IconData(0xe2fa, fontFamily: _bold),
          IconData(0xe2fa, fontFamily: _duo),
          IconData(0xe2fb, fontFamily: _duo),
        ),
        CinematicGlyph.search => const (
          // magnifyingGlass
          IconData(0xe30c, fontFamily: _bold),
          IconData(0xe30c, fontFamily: _duo),
          IconData(0xe30d, fontFamily: _duo),
        ),
        CinematicGlyph.shield => const (
          // shieldCheck
          IconData(0xe40c, fontFamily: _bold),
          IconData(0xe40c, fontFamily: _duo),
          IconData(0xe40f, fontFamily: _duo),
        ),
        CinematicGlyph.mail => const (
          // envelopeSimple
          IconData(0xe218, fontFamily: _bold),
          IconData(0xe218, fontFamily: _duo),
          IconData(0xe219, fontFamily: _duo),
        ),
        CinematicGlyph.frost => const (
          // snowflake
          IconData(0xe5aa, fontFamily: _bold),
          IconData(0xe5aa, fontFamily: _duo),
          IconData(0xe5ab, fontFamily: _duo),
        ),
        CinematicGlyph.share => const (
          // shareNetwork
          IconData(0xe408, fontFamily: _bold),
          IconData(0xe408, fontFamily: _duo),
          IconData(0xe40b, fontFamily: _duo),
        ),
        CinematicGlyph.qr => const (
          // qrCode
          IconData(0xe3e6, fontFamily: _bold),
          IconData(0xe3e6, fontFamily: _duo),
          IconData(0xe3e7, fontFamily: _duo),
        ),
        CinematicGlyph.copy => const (
          // copy
          IconData(0xe1ca, fontFamily: _bold),
          IconData(0xe1ca, fontFamily: _duo),
          IconData(0xe1cb, fontFamily: _duo),
        ),
        CinematicGlyph.podium => const (
          // ranking
          IconData(0xed62, fontFamily: _bold),
          IconData(0xed62, fontFamily: _duo),
          IconData(0xed63, fontFamily: _duo),
        ),
        CinematicGlyph.rise => const (
          // arrowFatUp
          IconData(0xe52e, fontFamily: _bold),
          IconData(0xe52e, fontFamily: _duo),
          IconData(0xe52f, fontFamily: _duo),
        ),
        CinematicGlyph.demote => const (
          // arrowFatDown
          IconData(0xe518, fontFamily: _bold),
          IconData(0xe518, fontFamily: _duo),
          IconData(0xe519, fontFamily: _duo),
        ),
        CinematicGlyph.people => const (
          // usersThree
          IconData(0xe68e, fontFamily: _bold),
          IconData(0xe68e, fontFamily: _duo),
          IconData(0xe68f, fontFamily: _duo),
        ),
        CinematicGlyph.home => const (
          // house
          IconData(0xe2c2, fontFamily: _bold),
          IconData(0xe2c2, fontFamily: _duo),
          IconData(0xe2c3, fontFamily: _duo),
        ),
        CinematicGlyph.back => const (
          // caretLeft
          IconData(0xe138, fontFamily: _bold),
          IconData(0xe138, fontFamily: _duo),
          IconData(0xe139, fontFamily: _duo),
        ),
        CinematicGlyph.tap => const (
          // handTap
          IconData(0xec90, fontFamily: _bold),
          IconData(0xec90, fontFamily: _duo),
          IconData(0xec91, fontFamily: _duo),
        ),
        CinematicGlyph.stack => const (
          // listNumbers
          IconData(0xe2f6, fontFamily: _bold),
          IconData(0xe2f6, fontFamily: _duo),
          IconData(0xe2f7, fontFamily: _duo),
        ),
        CinematicGlyph.gap => const (
          // textbox
          IconData(0xeb0a, fontFamily: _bold),
          IconData(0xeb0a, fontFamily: _duo),
          IconData(0xeb0b, fontFamily: _duo),
        ),
        CinematicGlyph.link => const (
          // link
          IconData(0xe2e2, fontFamily: _bold),
          IconData(0xe2e2, fontFamily: _duo),
          IconData(0xe2e3, fontFamily: _duo),
        ),
        CinematicGlyph.forward => const (
          // arrowRight
          IconData(0xe06c, fontFamily: _bold),
          IconData(0xe06c, fontFamily: _duo),
          IconData(0xe06d, fontFamily: _duo),
        ),
        CinematicGlyph.chevron => const (
          // caretRight
          IconData(0xe13a, fontFamily: _bold),
          IconData(0xe13a, fontFamily: _duo),
          IconData(0xe13b, fontFamily: _duo),
        ),
        CinematicGlyph.close => const (
          // x
          IconData(0xe4f6, fontFamily: _bold),
          IconData(0xe4f6, fontFamily: _duo),
          IconData(0xe4f7, fontFamily: _duo),
        ),
        CinematicGlyph.bookmark => const (
          // bookmarkSimple
          IconData(0xe0ea, fontFamily: _bold),
          IconData(0xe0ea, fontFamily: _duo),
          IconData(0xe0eb, fontFamily: _duo),
        ),
        CinematicGlyph.gift => const (
          // gift
          IconData(0xe276, fontFamily: _bold),
          IconData(0xe276, fontFamily: _duo),
          IconData(0xe277, fontFamily: _duo),
        ),
        CinematicGlyph.bell => const (
          // bell
          IconData(0xe0ce, fontFamily: _bold),
          IconData(0xe0ce, fontFamily: _duo),
          IconData(0xe0cf, fontFamily: _duo),
        ),
        CinematicGlyph.wrong => const (
          // xCircle
          IconData(0xe4f8, fontFamily: _bold),
          IconData(0xe4f8, fontFamily: _duo),
          IconData(0xe4f9, fontFamily: _duo),
        ),
        CinematicGlyph.flag => const (
          // flag
          IconData(0xe244, fontFamily: _bold),
          IconData(0xe244, fontFamily: _duo),
          IconData(0xe245, fontFamily: _duo),
        ),
        CinematicGlyph.refresh => const (
          // arrowClockwise
          IconData(0xe036, fontFamily: _bold),
          IconData(0xe036, fontFamily: _duo),
          IconData(0xe037, fontFamily: _duo),
        ),
        CinematicGlyph.stop => const (
          // stop
          IconData(0xe46c, fontFamily: _bold),
          IconData(0xe46c, fontFamily: _duo),
          IconData(0xe46d, fontFamily: _duo),
        ),
        CinematicGlyph.sprout => const (
          // plant
          IconData(0xebae, fontFamily: _bold),
          IconData(0xebae, fontFamily: _duo),
          IconData(0xebaf, fontFamily: _duo),
        ),
        CinematicGlyph.hourglass => const (
          // hourglassHigh
          IconData(0xe2b4, fontFamily: _bold),
          IconData(0xe2b4, fontFamily: _duo),
          IconData(0xe2b5, fontFamily: _duo),
        ),
        CinematicGlyph.bookmarked => const (
          // bookBookmark
          IconData(0xe0e4, fontFamily: _bold),
          IconData(0xe0e4, fontFamily: _duo),
          IconData(0xe0e5, fontFamily: _duo),
        ),
        CinematicGlyph.glasses => const (
          // eyeglasses
          IconData(0xe7ba, fontFamily: _bold),
          IconData(0xe7ba, fontFamily: _duo),
          IconData(0xe7bb, fontFamily: _duo),
        ),
        CinematicGlyph.library => const (
          // books
          IconData(0xe758, fontFamily: _bold),
          IconData(0xe758, fontFamily: _duo),
          IconData(0xe759, fontFamily: _duo),
        ),
        CinematicGlyph.mortarboard => const (
          // graduationCap
          IconData(0xe62c, fontFamily: _bold),
          IconData(0xe62c, fontFamily: _duo),
          IconData(0xe62d, fontFamily: _duo),
        ),
        CinematicGlyph.eye => const (
          // eye
          IconData(0xe220, fontFamily: _bold),
          IconData(0xe220, fontFamily: _duo),
          IconData(0xe221, fontFamily: _duo),
        ),
        CinematicGlyph.seal => const (
          // sealCheck
          IconData(0xe606, fontFamily: _bold),
          IconData(0xe606, fontFamily: _duo),
          IconData(0xe607, fontFamily: _duo),
        ),
        CinematicGlyph.sneaker => const (
          // sneakerMove
          IconData(0xed60, fontFamily: _bold),
          IconData(0xed60, fontFamily: _duo),
          IconData(0xed61, fontFamily: _duo),
        ),
        CinematicGlyph.bolt => const (
          // lightning
          IconData(0xe2de, fontFamily: _bold),
          IconData(0xe2de, fontFamily: _duo),
          IconData(0xe2df, fontFamily: _duo),
        ),
        CinematicGlyph.trophy => const (
          // trophy
          IconData(0xe67e, fontFamily: _bold),
          IconData(0xe67e, fontFamily: _duo),
          IconData(0xe67f, fontFamily: _duo),
        ),
        CinematicGlyph.plane => const (
          // paperPlaneTilt
          IconData(0xe398, fontFamily: _bold),
          IconData(0xe398, fontFamily: _duo),
          IconData(0xe399, fontFamily: _duo),
        ),
        CinematicGlyph.megaphone => const (
          // megaphone
          IconData(0xe324, fontFamily: _bold),
          IconData(0xe324, fontFamily: _duo),
          IconData(0xe325, fontFamily: _duo),
        ),
        CinematicGlyph.quote => const (
          // quotes
          IconData(0xe660, fontFamily: _bold),
          IconData(0xe660, fontFamily: _duo),
          IconData(0xe661, fontFamily: _duo),
        ),
        CinematicGlyph.mind => const (
          // brain
          IconData(0xe74e, fontFamily: _bold),
          IconData(0xe74e, fontFamily: _duo),
          IconData(0xe74f, fontFamily: _duo),
        ),
        CinematicGlyph.door => const (
          // doorOpen
          IconData(0xe7e6, fontFamily: _bold),
          IconData(0xe7e6, fontFamily: _duo),
          IconData(0xe7e7, fontFamily: _duo),
        ),
        CinematicGlyph.night => const (
          // moonStars
          IconData(0xe58e, fontFamily: _bold),
          IconData(0xe58e, fontFamily: _duo),
          IconData(0xe58f, fontFamily: _duo),
        ),
        CinematicGlyph.cactus => const (
          // cactus
          IconData(0xe918, fontFamily: _bold),
          IconData(0xe918, fontFamily: _duo),
          IconData(0xe919, fontFamily: _duo),
        ),
        CinematicGlyph.walker => const (
          // personSimpleWalk
          IconData(0xe73a, fontFamily: _bold),
          IconData(0xe73a, fontFamily: _duo),
          IconData(0xe73b, fontFamily: _duo),
        ),
        CinematicGlyph.calendarCheck => const (
          // calendarCheck
          IconData(0xe712, fontFamily: _bold),
          IconData(0xe712, fontFamily: _duo),
          IconData(0xe713, fontFamily: _duo),
        ),
        CinematicGlyph.tent => const (
          // tent
          IconData(0xe8ba, fontFamily: _bold),
          IconData(0xe8ba, fontFamily: _duo),
          IconData(0xe8bb, fontFamily: _duo),
        ),
        CinematicGlyph.cross => const (
          // cross
          IconData(0xe8a0, fontFamily: _bold),
          IconData(0xe8a0, fontFamily: _duo),
          IconData(0xe8a1, fontFamily: _duo),
        ),
        CinematicGlyph.compass => const (
          // compass
          IconData(0xe1c8, fontFamily: _bold),
          IconData(0xe1c8, fontFamily: _duo),
          IconData(0xe1c9, fontFamily: _duo),
        ),
        CinematicGlyph.returning => const (
          // arrowUUpLeft
          IconData(0xe08a, fontFamily: _bold),
          IconData(0xe08a, fontFamily: _duo),
          IconData(0xe08b, fontFamily: _duo),
        ),
        CinematicGlyph.dawn => const (
          // sunHorizon
          IconData(0xe5b6, fontFamily: _bold),
          IconData(0xe5b6, fontFamily: _duo),
          IconData(0xe5b7, fontFamily: _duo),
        ),
        CinematicGlyph.notebook => const (
          // notebook
          IconData(0xe34e, fontFamily: _bold),
          IconData(0xe34e, fontFamily: _duo),
          IconData(0xe34f, fontFamily: _duo),
        ),
        CinematicGlyph.trailMap => const (
          // mapTrifold
          IconData(0xe31a, fontFamily: _bold),
          IconData(0xe31a, fontFamily: _duo),
          IconData(0xe31b, fontFamily: _duo),
        ),
        CinematicGlyph.lamp || CinematicGlyph.plus => null,
      };
}

/// Os dois glifos que não vêm do Phosphor: lanterna e marca do Plus.
class _GlyphPainter extends CustomPainter {
  final CinematicGlyph glyph;
  final Color ink;

  _GlyphPainter({required this.glyph, required this.ink});

  late Paint _solid;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = size.shortestSide;
    _solid = Paint()..color = ink;

    switch (glyph) {
      case CinematicGlyph.lamp:
        canvas.save();
        canvas.translate(c.dx - s * 0.5, c.dy - s * 0.5);
        LanternGlyph.paintSolid(canvas, Size(s, s), ink);
        canvas.restore();
      case CinematicGlyph.plus:
        _plusMark(canvas, c, s);
      default:
        break;
    }
  }

  void _plusMark(Canvas canvas, Offset c, double s) {
    final o = c + Offset(-s * 0.05, s * 0.08);
    Path circle(double dx, double dy, double r) => Path()
      ..addOval(
        Rect.fromCircle(center: o + Offset(dx * s, dy * s), radius: r * s),
      );
    var cloud = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            o.dx - s * 0.36,
            o.dy - s * 0.02,
            o.dx + s * 0.36,
            o.dy + s * 0.22,
          ),
          Radius.circular(s * 0.12),
        ),
      );
    for (final puff in [
      circle(-0.17, 0.02, 0.15),
      circle(0.02, -0.08, 0.21),
      circle(0.21, 0.05, 0.14),
    ]) {
      cloud = Path.combine(PathOperation.union, cloud, puff);
    }
    Path cross(Offset at, double arm, double bar) => Path.combine(
      PathOperation.union,
      Path()..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: at, width: arm, height: bar),
          Radius.circular(bar / 2),
        ),
      ),
      Path()..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: at, width: bar, height: arm),
          Radius.circular(bar / 2),
        ),
      ),
    );
    final at = c + Offset(s * 0.29, -s * 0.27);
    final plus = cross(at, s * 0.28, s * 0.1);
    final gap = cross(at, s * 0.42, s * 0.24);
    canvas.drawPath(Path.combine(PathOperation.difference, cloud, gap), _solid);
    canvas.drawPath(plus, _solid);
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter old) =>
      old.glyph != glyph || old.ink != ink;
}
