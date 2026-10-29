import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'postcard.dart';
import 'ui_primitives.dart';

/// Folha grande de prévia — tema, trilha ou estação.
///
/// Imagem no topo, texto no meio, CTA/status no pé.
Future<void> showPathPreviewSheet(
  BuildContext context, {
  required String title,
  required String description,
  String? art,

  /// Pintura de cena cujo postal ainda não foi revelado.
  bool artVeiled = false,
  Color? accent,
  String? eyebrow,
  String? statusLabel,
  CinematicGlyph? glyph,
  Widget? footer,

  /// Chips curtos (ex.: "5 cenas").
  List<String> chips = const [],

  /// Prosa extra (resumo bíblico, blurb da categoria).
  String? detail,

  /// Linhas do roteiro (módulos ou cenas).
  List<String> outline = const [],
}) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => PathPreviewSheet(
      title: title,
      description: description,
      art: art,
      artVeiled: artVeiled,
      accent: accent,
      eyebrow: eyebrow,
      statusLabel: statusLabel,
      glyph: glyph,
      footer: footer,
      chips: chips,
      detail: detail,
      outline: outline,
    ),
  );
}

class PathPreviewSheet extends StatelessWidget {
  final String title;
  final String description;
  final String? art;
  final bool artVeiled;
  final Color? accent;
  final String? eyebrow;
  final String? statusLabel;
  final CinematicGlyph? glyph;
  final Widget? footer;
  final List<String> chips;
  final String? detail;
  final List<String> outline;

  const PathPreviewSheet({
    super.key,
    required this.title,
    required this.description,
    this.art,
    this.artVeiled = false,
    this.accent,
    this.eyebrow,
    this.statusLabel,
    this.glyph,
    this.footer,
    this.chips = const [],
    this.detail,
    this.outline = const [],
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final media = MediaQuery.of(context);
    final safeBottom = media.padding.bottom;
    final keyboard = media.viewInsets.bottom;
    final tone = accent ?? AppRoles.presence;
    final radius = AppRadii.sheet;
    // Hero compacto: a folha encolhe com o texto, não com a tela.
    final heroH = (media.size.height * 0.2).clamp(140.0, 176.0);
    final body = description.trim();
    final extra = detail?.trim() ?? '';
    final maxH = media.size.height * 0.88 - keyboard - 12;
    final chipLabels = chips
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();
    final lines = outline
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final bottom =
        footer ??
        (statusLabel != null && statusLabel!.trim().isNotEmpty
            ? Align(
                alignment: Alignment.centerLeft,
                child: SoftBadge(
                  text: statusLabel!,
                  accent: tone,
                  textColor: tone,
                ),
              )
            : null);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null && eyebrow!.trim().isNotEmpty) ...[
          SectionLabel(eyebrow!, size: 11, color: tone, maxLines: 1),
          const SizedBox(height: AppSpace.sm),
        ],
        Text(
          title,
          style: AppTypography.display(size: 26, height: 1.1, color: a.text),
        ),
        if (chipLabels.isNotEmpty) ...[
          const SizedBox(height: AppSpace.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final chip in chipLabels)
                SoftBadge(text: chip, accent: tone, textColor: tone),
            ],
          ),
        ],
        if (body.isNotEmpty) ...[
          const SizedBox(height: AppSpace.md),
          Text(
            body,
            style: AppTypography.body(
              size: 15,
              height: 1.45,
              color: a.textSecondary,
            ),
          ),
        ],
        if (extra.isNotEmpty) ...[
          const SizedBox(height: AppSpace.md),
          Text(
            extra,
            style: AppTypography.body(
              size: 14,
              height: 1.5,
              color: a.textSecondary,
            ),
          ),
        ],
        if (lines.isNotEmpty) ...[
          const SizedBox(height: AppSpace.lg),
          SectionLabel(
            l10n.comingSoonComingHeader,
            size: 10,
            color: a.textFaint,
            maxLines: 1,
          ),
          const SizedBox(height: AppSpace.sm),
          for (var i = 0; i < lines.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == lines.length - 1 ? 0 : AppSpace.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '·  ',
                    style: AppTypography.body(
                      size: 15,
                      weight: FontWeight.w700,
                      color: tone,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      lines[i],
                      style: AppTypography.body(
                        size: 14,
                        height: 1.35,
                        weight: FontWeight.w600,
                        color: a.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
        if (bottom != null) ...[const SizedBox(height: AppSpace.lg), bottom],
      ],
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + keyboard),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: contentMaxWidth,
            maxHeight: maxH,
          ),
          child: Material(
            color: Colors.transparent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: a.cardFill,
                border: Border.all(
                  color: tone.withValues(alpha: 0.55),
                  width: AppMetrics.cardBorderWidth,
                ),
                boxShadow: AppMetrics.cardShadow(elevated: true),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  (radius - AppMetrics.cardBorderWidth).clamp(0.0, radius),
                ),
                // Scroll só se o conteúdo passar do teto da tela.
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: heroH,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (art != null)
                              SceneArtImage(
                                art!,
                                veiled: artVeiled,
                                alignment: const Alignment(0, -0.15),
                                errorBuilder: (_, _, _) =>
                                    _ArtFallback(accent: tone, glyph: glyph),
                              )
                            else
                              _ArtFallback(accent: tone, glyph: glyph),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x00000000),
                                    Color(0x5906080C),
                                  ],
                                  stops: [0.6, 1.0],
                                ),
                              ),
                            ),
                            const Positioned(
                              top: AppSpace.md,
                              left: 0,
                              right: 0,
                              child: Center(child: SheetGrabber()),
                            ),
                            Positioned(
                              top: AppSpace.sm,
                              right: AppSpace.sm,
                              child: IconButton(
                                tooltip: l10n.commonClose,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black.withValues(
                                    alpha: 0.45,
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(8),
                                  minimumSize: const Size(40, 40),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => Navigator.pop(context),
                                icon: const CinematicIcon(
                                  glyph: CinematicGlyph.close,
                                  size: AppMetrics.iconMd,
                                  accent: Colors.white,
                                  framed: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpace.xl,
                          AppSpace.lg,
                          AppSpace.xl,
                          AppSpace.lg + safeBottom,
                        ),
                        child: content,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArtFallback extends StatelessWidget {
  final Color accent;
  final CinematicGlyph? glyph;

  const _ArtFallback({required this.accent, this.glyph});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(const Color(0xFF0A1018), accent, 0.35)!,
            const Color(0xFF06080C),
          ],
        ),
      ),
      child: Center(
        child: CinematicIcon(
          glyph: glyph ?? CinematicGlyph.path,
          size: 64,
          accent: accent,
          glowing: true,
          framed: false,
        ),
      ),
    );
  }
}
