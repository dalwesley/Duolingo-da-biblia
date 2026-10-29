import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'postcard.dart';
import 'stway_brand.dart';
import 'ui_primitives.dart';

/// Placa Hoje: capa da cena. A pintura grande no alto, de ponta a ponta, se
/// desfaz no escuro, e a frase vem grande embaixo — como um pôster.
///
/// A pintura cobre a área de cima inteira (corta o que sobra nas bordas).
///
/// A pintura aproxima devagar enquanto a frase entra palavra por palavra.
/// Com [veiled] (fim da cena, postal ainda guardado), ela sai do véu junto.
/// [still] desenha tudo pronto e troca o botão pela marca: é o card que se
/// compartilha.
class TodayStage extends StatefulWidget {
  final String insight;
  final String? art;
  final bool veiled;
  final String reference;
  final DateTime on;
  final Color accent;

  /// Altura fixa (dentro de rolagem). Sem ela, a placa fica em 4:5,
  /// centrada no espaço que recebe.
  final double? height;

  /// Mostra "Compartilhar" no rodapé, depois que a frase chega.
  final VoidCallback? onShare;

  /// Sem animação, com a marca no rodapé — imagem para compartilhar.
  final bool still;

  const TodayStage({
    super.key,
    required this.insight,
    required this.on,
    required this.accent,
    this.art,
    this.veiled = false,
    this.reference = '',
    this.height,
    this.onShare,
    this.still = false,
  });

  /// Proporção da placa sem [height]: a mesma do card compartilhado.
  static const aspect = 4 / 5;

  @override
  State<TodayStage> createState() => _TodayStageState();
}

class _TodayStageState extends State<TodayStage>
    with SingleTickerProviderStateMixin {
  late final List<String> _words = widget.insight
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 900 + _words.length * 110),
  );

  @override
  void initState() {
    super.initState();
    if (widget.still) {
      _t.value = 1;
      return;
    }
    _t.addStatusListener((s) {
      if (s == AnimationStatus.completed) ActHaptics.light();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (AppMotion.reduced(context)) {
        _t.value = 1;
      } else {
        Future.delayed(AppMotion.quick, () {
          if (mounted) _t.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  /// Janela da palavra [i]: entram em cascata, sobrepostas.
  double _wordT(int i) {
    final n = _words.length;
    if (n == 0) return 1;
    final step = 0.8 / (n + 2);
    final v = ((_t.value - 0.15 - i * step) / (step * 3)).clamp(0.0, 1.0);
    return AppMotion.enter.transform(v);
  }

  double _after(double start) =>
      ((_t.value - start) / (1 - start)).clamp(0.0, 1.0);

  Widget _image(String art) => Image.asset(
    art,
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
    filterQuality: FilterQuality.high,
    gaplessPlayback: true,
    errorBuilder: (_, _, _) => const SizedBox.shrink(),
  );

  /// A pintura nítida; com véu, a limpa acende por cima junto com a frase.
  Widget _sharp(String art) {
    final clear = _image(art);
    if (!widget.veiled) return clear;
    return Stack(
      fit: StackFit.expand,
      children: [
        clear,
        Positioned.fill(
          child: Opacity(
            opacity: 1 - AppMotion.enter.transform(_t.value),
            child: SceneArtImage(art, veiled: true),
          ),
        ),
      ],
    );
  }

  /// Área de cima: a pintura cobrindo tudo, aproximando devagar (6% a 0).
  Widget _art(String art) {
    final zoom = 1.06 - 0.06 * AppMotion.enter.transform(_t.value);
    return ClipRect(
      child: Transform.scale(scale: zoom, child: _sharp(art)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const ink = AppColors.textOnDark;
    final l10n = context.l10n;
    final date = DateFormat(
      'd MMM',
      l10n.localeName,
    ).format(widget.on).replaceAll('.', '').toUpperCase();
    final art = widget.art;
    final ref = widget.reference.trim();
    final long = widget.insight.length > 60;
    final shadow = [
      Shadow(color: AppColors.night.withValues(alpha: 0.8), blurRadius: 16),
    ];

    final stage = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: LayoutBuilder(
        builder: (context, box) {
          // A pintura fica com ~60% de cima; a frase pousa na emenda.
          final artH = box.maxHeight * 0.6;
          return AnimatedBuilder(
            animation: _t,
            builder: (context, _) => Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: AppColors.night),
                if (art != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: artH,
                    child: _art(art),
                  ),
                // Escurece o alto (o Anan) e funde a pintura no escuro.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.night.withValues(alpha: 0.55),
                          AppColors.night.withValues(alpha: 0),
                          AppColors.night.withValues(alpha: 0),
                          AppColors.night,
                        ],
                        stops: const [0, 0.18, 0.36, 0.62],
                      ),
                    ),
                  ),
                ),
                // Luz do modo por baixo da frase.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, 1.1),
                        radius: 0.9,
                        colors: [
                          widget.accent.withValues(alpha: 0.18),
                          widget.accent.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Alto: o Anan e o dia.
                Positioned(
                  left: 16,
                  top: 14,
                  child: Row(
                    children: [
                      CloudMascot(
                        face: CloudFace.sucesso,
                        size: 38,
                        react: !widget.still,
                      ),
                      const SizedBox(width: 8),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: l10n.commonToday.toUpperCase(),
                              style: const TextStyle(color: AppRoles.reward),
                            ),
                            TextSpan(text: '  ·  $date'),
                          ],
                        ),
                        style: AppTypography.body(
                          size: 12,
                          weight: FontWeight.w800,
                          color: ink.withValues(alpha: 0.85),
                        ).copyWith(letterSpacing: 2, shadows: shadow),
                      ),
                    ],
                  ),
                ),
                // Baixo: a frase, a referência e o compartilhar (ou a marca).
                Positioned(
                  left: 22,
                  right: 22,
                  bottom: 16,
                  top: art == null ? 60 : artH * 0.72,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      width: box.maxWidth - 44,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            runSpacing: 2,
                            children: [
                              for (var i = 0; i < _words.length; i++)
                                Opacity(
                                  opacity: _wordT(i),
                                  child: Transform.translate(
                                    offset: Offset(0, 12 * (1 - _wordT(i))),
                                    child: Text(
                                      i == _words.length - 1
                                          ? _words[i]
                                          : '${_words[i]} ',
                                      style: AppTypography.display(
                                        size: long ? 30 : 38,
                                        height: 1.08,
                                        color: ink,
                                      ).copyWith(shadows: shadow),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (ref.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Opacity(
                              opacity: _after(0.75),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 2,
                                    color: widget.accent,
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      ref,
                                      style: AppTypography.verse(
                                        size: 16,
                                        weight: FontWeight.w600,
                                        color: ink.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          if (widget.still)
                            _brand()
                          else if (widget.onShare != null)
                            Opacity(
                              opacity: _after(0.85),
                              child: IgnorePointer(
                                ignoring: _t.value < 0.85,
                                child: TextCta(
                                  label: l10n.commonShare,
                                  leading: CinematicGlyph.share,
                                  color: ink,
                                  onTap: widget.onShare,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        border: Border.all(color: ink.withValues(alpha: 0.12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return Semantics(
      label: '${l10n.commonToday}: ${widget.insight}',
      excludeSemantics: true,
      child: widget.height == null
          ? Center(
              child: AspectRatio(aspectRatio: TodayStage.aspect, child: stage),
            )
          : SizedBox(height: widget.height, child: stage),
    );
  }

  /// Rodapé do card compartilhado: a marca e onde achar o app.
  Widget _brand() {
    return Row(
      children: [
        const StwayLogo(size: 18),
        const SizedBox(width: 8),
        StwayWordmark(
          fontSize: 12,
          letterSpacing: 2,
          letterColor: AppColors.textOnDark,
          aColor: AppColors.accent,
        ),
        const SizedBox(width: 10),
        Text(
          'stway.com.br',
          style: AppTypography.label(
            size: 10,
            color: AppColors.textOnDark.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
