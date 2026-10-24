import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'anan_speech.dart';
import 'app_sheet.dart';
import 'brand_trail.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'ui_primitives.dart';

/// Carrossel de portais — a mesma forma para motivo, tema e idioma.
///
/// - [showChoiceSheet]: sheet com o Anan ao lado e o carrossel embaixo.
/// - [ChoiceCarousel]: portais deslizáveis + pontos + CTA + nota.
/// - [ChoicePortal]: o que cada portal mostra.

/// Miolo do emblema: tamanho do glifo e tinta legível sobre o céu.
typedef ChoiceEmblem = Widget Function(double size, Color ink);

/// Céu vivo do portal. [t] corre de 0 a 1 em loop (0 parado fora de foco).
typedef ChoiceScene =
    Widget Function(
      BuildContext context,
      double t,
      double focus,
      double parallax,
    );

/// O que um portal mostra.
class ChoicePortal {
  /// Linha pequena no topo (ex.: "Motivo II", "PT").
  final String eyebrow;
  final String title;
  final String tagline;
  final String? blurb;
  final List<String> chips;

  /// Linha no pé (ex.: "Abre: Gênesis 1–11").
  final String? footer;
  final Color accent;
  final ChoiceEmblem emblem;
  final ChoiceScene scene;

  /// Look da arte (céu e trilha STWAY). Nulo = o da página.
  final AppearanceStyle? look;

  /// Arte STWAY no tom do emblema. Falso no tema: a arte mostra o look.
  final bool tintPlate;

  /// Clareia o céu no look (como a arte). Falso quando a cena já é o look.
  final bool liftSky;

  const ChoicePortal({
    required this.eyebrow,
    required this.title,
    required this.tagline,
    this.blurb,
    this.chips = const [],
    this.footer,
    required this.accent,
    required this.emblem,
    required this.scene,
    this.look,
    this.tintPlate = true,
    this.liftSky = true,
  });
}

/// Sheet de escolha — o Anan ao lado pergunta, os portais respondem.
///
/// [eyebrow] e [title] são lidos a cada build: no idioma, a sheet já fala a
/// língua em prévia.
Future<void> showChoiceSheet(
  BuildContext context, {
  required String Function(AppLocalizations l10n) eyebrow,
  required String Function(AppLocalizations l10n) title,
  Color? tint,
  required Widget Function(BuildContext sheetContext) carousel,
}) {
  ActHaptics.tap();
  return showAppSheet<void>(
    context,
    builder: (sheetContext) => AppSheetPanel(
      tint: tint,
      padding: const EdgeInsets.fromLTRB(0, AppSpace.md, 0, AppSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
            // Anan ao lado, balão curto: a regra já vem na nota sob o
            // botão, e o carrossel precisa da altura.
            child: AnanSideSpeech(
              face: CloudFace.feliz,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SectionLabel(
                    eyebrow(sheetContext.l10n),
                    // Tom escurecido: o ouro puro some no papel branco.
                    color: tint == null
                        ? AnanSpeechBubble.mark
                        : Color.lerp(tint, AnanSpeechBubble.ink, 0.3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title(sheetContext.l10n),
                    style: AppTypography.display(
                      size: 22,
                      height: 1.1,
                      color: AnanSpeechBubble.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          carousel(sheetContext),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Carrossel
// ─────────────────────────────────────────────────────────────────────────

/// Portais lado a lado — deslize para conhecer, confirme no botão.
class ChoiceCarousel extends StatefulWidget {
  final List<ChoicePortal> portals;

  /// Escolha atual (selo "Você está aqui"); nulo = nenhuma ainda.
  final int? selected;
  final double height;

  /// Texto do CTA para o portal em foco.
  final String Function(int index, bool current) ctaLabel;

  /// Nota sob o CTA (a regra da escolha).
  final String? footnote;
  final ValueChanged<int>? onCommitted;

  /// Sem rodapé (CTA + nota) — o pai avança no próprio Continuar.
  final bool hideFooter;

  /// Enquanto desliza, avisa a página em foco.
  final ValueChanged<int>? onFocused;

  const ChoiceCarousel({
    super.key,
    required this.portals,
    required this.ctaLabel,
    this.selected,
    this.height = 372,
    this.footnote,
    this.onCommitted,
    this.hideFooter = false,
    this.onFocused,
  });

  @override
  State<ChoiceCarousel> createState() => _ChoiceCarouselState();
}

class _ChoiceCarouselState extends State<ChoiceCarousel>
    with TickerProviderStateMixin {
  late final PageController _pages;
  late final AnimationController _life;
  int _page = 0;
  bool _busy = false;

  int get _count => widget.portals.length;

  @override
  void initState() {
    super.initState();
    final i = widget.selected ?? 0;
    _page = i.clamp(0, _count - 1);
    _pages = PageController(viewportFraction: 0.80, initialPage: _page);
    _life = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    BrandTrail.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    }, onError: (_) {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFocused?.call(_page);
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    _life.dispose();
    super.dispose();
  }

  double get _offset {
    if (!_pages.hasClients || !_pages.position.haveDimensions) {
      return _page.toDouble();
    }
    return _pages.page ?? _page.toDouble();
  }

  void _goTo(int i) {
    _pages.animateToPage(i, duration: AppMotion.slow, curve: AppMotion.enter);
  }

  Future<void> _confirm(int i) async {
    if (_busy) return;
    setState(() => _busy = true);
    ActHaptics.confirm();
    widget.onCommitted?.call(i);
    if (!mounted) return;
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final page = _page.clamp(0, _count - 1);
    final footnote = widget.footnote;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: AnimatedBuilder(
            animation: _pages,
            builder: (context, _) {
              final offset = _offset;
              final focused = offset.round().clamp(0, _count - 1);
              return PageView.builder(
                controller: _pages,
                itemCount: _count,
                clipBehavior: Clip.none,
                onPageChanged: (i) {
                  ActHaptics.tap();
                  setState(() => _page = i);
                  widget.onFocused?.call(i);
                },
                itemBuilder: (context, i) {
                  final delta = (offset - i).clamp(-1.0, 1.0);
                  final scale = 1 - 0.10 * delta.abs();
                  return GestureDetector(
                    // Tocar no card só traz ele para o foco: quem escolhe é
                    // o botão. Sem botão (onboarding), o toque confirma.
                    onTap: () {
                      if (i != focused) {
                        _goTo(i);
                      } else if (widget.hideFooter) {
                        _confirm(i);
                      }
                    },
                    child: Transform(
                      alignment: delta > 0
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateY(delta * 0.32)
                        ..scaleByDouble(scale, scale, 1, 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _PortalCard(
                          portal: widget.portals[i],
                          current: i == widget.selected,
                          focus: 1 - delta.abs(),
                          parallax: delta,
                          life: _life,
                          alive: i == focused,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        AnimatedBuilder(
          animation: _pages,
          builder: (context, _) => _ChoiceDots(
            accents: [for (final p in widget.portals) p.accent],
            offset: _offset,
            onTap: _goTo,
          ),
        ),
        if (!widget.hideFooter) ...[
          const SizedBox(height: AppSpace.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
            child: CopperCta(
              label: widget.ctaLabel(page, page == widget.selected),
              busy: _busy,
              onTap: () => _confirm(page),
            ),
          ),
          if (footnote != null) ...[
            const SizedBox(height: AppSpace.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
              child: Text(
                footnote,
                textAlign: TextAlign.center,
                style: AppTypography.label(
                  size: 11,
                  color: Appearance.of(context).textFaint,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// Um portal: céu vivo · emblema nascendo no horizonte · trilha STWAY na
/// metade de baixo, saindo do emblema.
class _PortalCard extends StatelessWidget {
  final ChoicePortal portal;
  final bool current;
  final double focus;
  final double parallax;
  final Animation<double> life;
  final bool alive;

  static const _haloSize = 144.0;

  /// Altura do horizonte no card (fração).
  static const _horizonAt = 0.42;

  /// Faixa acima do horizonte onde o fundo STWAY se dissolve no céu.
  static const _plateFade = 72.0;

  /// Quanto o centro do emblema fica acima do horizonte — o glifo inteiro
  /// aparece, só a base do aro some atrás dos morros.
  static const _iconRise = 28.0;

  const _PortalCard({
    required this.portal,
    required this.current,
    required this.focus,
    required this.parallax,
    required this.life,
    required this.alive,
  });

  @override
  Widget build(BuildContext context) {
    final a = AppearanceStyle.resolve(AppearanceMode.night);
    final look = portal.look ?? Appearance.of(context);
    final accent = portal.accent;
    final onSky = AppColors.glyphInk(accent);
    final badge = current ? context.l10n.intentBadgeHere : null;
    final blurb = portal.blurb;
    final footer = portal.footer;

    return Appearance(
      style: a,
      mode: AppearanceMode.night,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
          border: Border.all(
            color: onSky.withValues(alpha: 0.25 + 0.55 * focus),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.30 * focus),
              blurRadius: 34,
              spreadRadius: -6,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppMetrics.heroRadius - 1),
          child: LayoutBuilder(
            builder: (context, box) {
              final h = box.maxHeight;
              // Linha do horizonte: onde a trilha da arte termina — e onde
              // o emblema "nasce". Daqui para baixo, o fundo STWAY.
              final horizon = h * _horizonAt;
              final plateTop = horizon - _plateFade;
              final iconCenter = horizon - _iconRise;
              return Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Céu vivo, até um pouco abaixo do horizonte (o fundo
                  // STWAY cobre a emenda).
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: horizon + 12,
                    child: ArtLift(
                      page: portal.liftSky
                          ? look
                          : AppearanceStyle.resolve(AppearanceMode.night),
                      child: ClipRect(
                        child: RepaintBoundary(
                          child: alive
                              ? AnimatedBuilder(
                                  animation: life,
                                  builder: (context, _) => portal.scene(
                                    context,
                                    life.value,
                                    focus,
                                    parallax,
                                  ),
                                )
                              : portal.scene(context, 0, focus, parallax),
                        ),
                      ),
                    ),
                  ),
                  // 2. Fundo STWAY — metade de baixo, com o fim da trilha
                  // centrado sob o emblema; topo some no céu, sem emenda.
                  Positioned(
                    top: plateTop,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _BrandPlate(
                      page: look,
                      horizon: _plateFade,
                      accent: accent,
                      tinted: portal.tintPlate,
                      focus: focus,
                    ),
                  ),
                  // 3. Emblema no horizonte — a base some atrás dos morros,
                  // como sol nascendo: a trilha sai dele.
                  Positioned(
                    top: iconCenter - _haloSize / 2,
                    left: 0,
                    right: 0,
                    height: _haloSize,
                    child: Center(
                      child: _BehindHorizon(
                        cut: _haloSize / 2 + _iconRise,
                        child: ChoiceHalo(
                          emblem: portal.emblem,
                          accent: accent,
                          life: alive ? life : null,
                          size: _haloSize,
                        ),
                      ),
                    ),
                  ),
                  // 4. Véu no pé — texto legível sobre a trilha.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [
                          ((horizon + 24) / h).clamp(0.0, 1.0),
                          ((horizon + 90) / h).clamp(0.0, 1.0),
                          1,
                        ],
                        colors: const [
                          Color(0x00081018),
                          Color(0x8C081018),
                          Color(0xEB081018),
                        ],
                      ),
                    ),
                  ),
                  // 5. Conteúdo.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                portal.eyebrow,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label(
                                  size: 11,
                                  letterSpacing: 2.2,
                                  color: onSky.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (badge != null)
                              ChoicePill(
                                text: badge,
                                accent: accent,
                                solid: true,
                              ),
                          ],
                        ),
                        // Espaço do emblema e do começo da trilha.
                        const Expanded(child: SizedBox.shrink()),
                        Text(
                          portal.title,
                          style: AppTypography.display(
                            size: 26,
                            height: 1.05,
                            color: a.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          portal.tagline,
                          style: AppTypography.body(
                            size: 14,
                            weight: FontWeight.w800,
                            color: onSky,
                          ),
                        ),
                        if (blurb != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            blurb,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body(
                              size: 13,
                              height: 1.35,
                              color: a.textSecondary,
                            ),
                          ),
                        ],
                        if (portal.chips.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final chip in portal.chips)
                                _ChoiceChip(text: chip, accent: accent),
                            ],
                          ),
                        ],
                        if (footer != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            footer,
                            style: AppTypography.label(
                              size: 11,
                              letterSpacing: 0.2,
                              color: a.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Fundo STWAY do portal: a arte enquadrada para o fim da trilha cair
/// em [horizon] (px do topo), no centro do card. Acima disso o fundo se
/// dissolve no céu da cena; no horizonte, uma luz no tom do motivo.
class _BrandPlate extends StatelessWidget {
  final AppearanceStyle page;
  final double horizon;
  final Color accent;
  final bool tinted;
  final double focus;

  const _BrandPlate({
    required this.page,
    required this.horizon,
    required this.accent,
    required this.tinted,
    required this.focus,
  });

  @override
  Widget build(BuildContext context) {
    // Máscara por fora do [ArtLift]: o filtro não acende a borda
    // transparente.
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        // Transparente no alto, inteiro um pouco antes do horizonte (os
        // morros ainda aparecem, sem emenda reta).
        final solid = ((horizon - 10) / bounds.height).clamp(0.0, 1.0);
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0x00000000),
            Color(0x00000000),
            Color(0x66000000),
            Color(0xFF000000),
          ],
          stops: [0, solid * 0.15, solid * 0.6, solid],
        ).createShader(bounds);
      },
      child: ArtLift(
        page: page,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _BrandPainter(
              loaded: BrandTrail.image != null,
              horizon: horizon,
              accent: accent,
              tinted: tinted,
              focus: focus,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _BrandPainter extends CustomPainter {
  final bool loaded;
  final double horizon;
  final Color accent;
  final bool tinted;
  final double focus;

  _BrandPainter({
    required this.loaded,
    required this.horizon,
    required this.accent,
    required this.tinted,
    required this.focus,
  });

  /// Arte mais larga que o card: o horizonte (x 0.62 na arte) vai para o
  /// centro sem abrir vão na direita.
  static const _zoom = 1.4;

  static const _shot = TrailShot(
    exposure: 0.9,
    glow: 0.45,
    lit: 1,
    lamps: 0.4,
    stars: 0,
    zoom: 1,
    focusY: 0,
    drop: 0,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final img = BrandTrail.image;
    final iw = img?.width.toDouble() ?? 455;
    final ih = img?.height.toDouble() ?? 1024;
    final art = Size(size.width * _zoom, size.width * _zoom * ih / iw);
    final sun = Offset(size.width / 2, horizon);

    canvas.save();
    canvas.clipRect(rect);
    canvas.translate(
      sun.dx - BrandTrail.horizon.dx * art.width,
      sun.dy - BrandTrail.horizon.dy * art.height,
    );
    BrandTrail.paint(canvas, art, _shot, loop: 0, calm: true);
    canvas.restore();

    // Arte no tom do emblema, um pouco mais clara: `color` troca o matiz
    // e mantém o relevo; `screen` levanta o fundo.
    if (tinted) {
      final tone = Color.lerp(accent, Colors.white, 0.22)!;
      canvas.drawRect(
        rect,
        Paint()
          ..blendMode = BlendMode.color
          ..color = tone,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..blendMode = BlendMode.screen
          ..color = tone.withValues(alpha: 0.18),
      );
    }

    // Luz do motivo no fim da trilha — a trilha nasce do emblema.
    final r = size.width * 0.42;
    canvas.drawOval(
      Rect.fromCenter(center: sun, width: r * 2, height: r * 1.1),
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: 0.42 * (0.4 + 0.6 * focus)),
            accent.withValues(alpha: 0.12 * (0.4 + 0.6 * focus)),
            accent.withValues(alpha: 0),
          ],
          stops: const [0, 0.4, 1],
        ).createShader(Rect.fromCircle(center: sun, radius: r)),
    );
  }

  @override
  bool shouldRepaint(covariant _BrandPainter old) =>
      old.loaded != loaded ||
      old.horizon != horizon ||
      old.accent != accent ||
      old.tinted != tinted ||
      old.focus != focus;
}

/// Esconde o que passa de [cut] px do topo, com borda macia — o emblema
/// fica "atrás" do horizonte da arte.
class _BehindHorizon extends StatelessWidget {
  final double cut;
  final Widget child;

  const _BehindHorizon({required this.cut, required this.child});

  static const _soft = 6.0;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        final h = bounds.height;
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF000000),
            Color(0xFF000000),
            Color(0x00000000),
          ],
          stops: [
            0,
            ((cut - _soft) / h).clamp(0.0, 1.0),
            ((cut + _soft) / h).clamp(0.0, 1.0),
          ],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

/// Emblema com auréola que respira. [emblem] recebe o tamanho do miolo e
/// a tinta legível sobre o céu.
class ChoiceHalo extends StatelessWidget {
  final ChoiceEmblem emblem;
  final Color accent;
  final Animation<double>? life;
  final double size;

  const ChoiceHalo({
    super.key,
    required this.emblem,
    required this.accent,
    this.life,
    this.size = 112,
  });

  /// Emblema de glifo — o padrão de motivo e tema.
  static ChoiceEmblem glyph(CinematicGlyph glyph) =>
      (size, ink) => CinematicIcon(
        glyph: glyph,
        size: size,
        accent: ink,
        framed: false,
        glowing: false,
      );

  @override
  Widget build(BuildContext context) {
    final onSky = AppColors.glyphInk(accent);
    final core = size * 0.66;
    // Respiro lento e curto — o espetáculo é a cena, não o emblema.
    Widget frame(double breathe) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 1 + 0.035 * breathe,
              child: Container(
                width: size * 0.94,
                height: size * 0.94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.28 + 0.08 * breathe),
                      accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: core,
              height: core,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.night.withValues(alpha: 0.5),
                border: Border.all(
                  color: onSky.withValues(alpha: 0.62 + 0.18 * breathe),
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.18 + 0.12 * breathe),
                    blurRadius: size * 0.18,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: emblem(core * 0.46, onSky),
            ),
          ],
        ),
      );
    }

    final l = life;
    if (l == null) return frame(0);
    return AnimatedBuilder(
      animation: l,
      builder: (context, _) =>
          frame(0.5 + 0.5 * math.sin(l.value * math.pi * 2)),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String text;
  final Color accent;

  const _ChoiceChip({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final onSky = AppColors.glyphInk(accent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: onSky.withValues(alpha: 0.45), width: 1),
      ),
      child: Text(
        text,
        style: AppTypography.label(size: 11, letterSpacing: 0.2, color: a.text),
      ),
    );
  }
}

class ChoicePill extends StatelessWidget {
  final String text;
  final Color accent;
  final bool solid;

  const ChoicePill({
    super.key,
    required this.text,
    required this.accent,
    required this.solid,
  });

  @override
  Widget build(BuildContext context) {
    final ink = solid ? AppColors.night : Appearance.of(context).text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: solid ? accent : AppRoles.chrome.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: solid
            ? null
            : Border.all(color: AppRoles.chrome.withValues(alpha: 0.22)),
      ),
      child: Text(
        text,
        style: AppTypography.label(size: 10, letterSpacing: 0.4, color: ink),
      ),
    );
  }
}

/// Indicador: pílulas que se esticam e tomam a cor do portal em foco.
class _ChoiceDots extends StatelessWidget {
  final List<Color> accents;
  final double offset;
  final ValueChanged<int> onTap;

  const _ChoiceDots({
    required this.accents,
    required this.offset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < accents.length; i++)
          GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Builder(
                builder: (context) {
                  final focus = (1 - (offset - i).abs()).clamp(0.0, 1.0);
                  return Container(
                    width: 8 + 22 * focus,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      color: Color.lerp(
                        Appearance.of(context).textFaint.withValues(alpha: 0.7),
                        accents[i],
                        focus,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// Céu simples de portal: degradê no tom, um brilho no horizonte e
/// partículas que sobem. Para escolhas sem cena própria (tema, idioma).
class GlowScenePainter extends CustomPainter {
  final Color color;
  final double t;
  final double intensity;
  final double parallax;

  /// Pinta o degradê de fundo; falso quando há um céu por baixo.
  final bool sky;

  GlowScenePainter({
    required this.color,
    required this.t,
    this.intensity = 1,
    this.parallax = 0,
    this.sky = true,
  });

  static double _frac(double x) => x - x.floorToDouble();
  static const _tau = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    final k = intensity;
    final lift = Color.lerp(color, Colors.white, 0.2)!;
    if (sky) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(AppColors.night, lift, 0.14)!,
              Color.lerp(AppColors.night, lift, 0.42)!,
            ],
          ).createShader(rect),
      );
    }
    canvas.save();
    canvas.translate(parallax * w * 0.12, 0);
    final c = Offset(w * 0.5, h * 0.9);
    final breathe = 0.5 + 0.5 * math.sin(t * _tau);
    final r = w * (0.5 + 0.04 * breathe);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            lift.withValues(alpha: 0.5 * k),
            lift.withValues(alpha: 0.14 * k),
            lift.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    final mote = Color.lerp(lift, Colors.white, 0.45)!;
    for (var i = 0; i < 22; i++) {
      final x = w * (0.06 + 0.88 * _frac(i * 0.618));
      final p = _frac(t * (0.6 + (i % 3) * 0.2) + _frac(i * 0.293));
      final y = h * (1.02 - p * 1.05);
      final a = math.sin(p * math.pi) * k;
      final dot = 0.9 + 1.6 * _frac(i * 0.731);
      final at = Offset(x + math.sin((p * 2 + i * 0.17) * _tau) * 4, y);
      canvas.drawCircle(
        at,
        dot * 3,
        Paint()..color = lift.withValues(alpha: a * 0.14),
      );
      canvas.drawCircle(
        at,
        dot,
        Paint()..color = mote.withValues(alpha: a * 0.9),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GlowScenePainter old) =>
      old.t != t ||
      old.intensity != intensity ||
      old.parallax != parallax ||
      old.color != color ||
      old.sky != sky;
}
