import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/season_walk_catalog.dart';
import '../l10n/app_language.dart';
import '../models/season_walk.dart';
import '../screens/season_walk_screen.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/liturgical_calendar.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'path_preview_sheet.dart';
import 'season_walk_together.dart';
import 'ui_primitives.dart';

/// Card destaque da Caminhada sazonal na Home — fora de "Mais para hoje".
///
/// Mesmo espírito do fluxo de Trilhas: paisagem, título grande, CTA dourado.
/// Aparece na janela de [SeasonWalkTogetherCard.leadDays] até o fim.
class SeasonWalkFeatureCard extends StatefulWidget {
  const SeasonWalkFeatureCard({super.key});

  /// Visível na Home (pré-início ou durante a temporada).
  static bool visible(ProgressService progress) {
    final today = progress.seasonToday;
    final campaign = SeasonWalkCatalog.current(today);
    return SeasonWalkTogetherCard.visibleOn(campaign, today);
  }

  @override
  State<SeasonWalkFeatureCard> createState() => _SeasonWalkFeatureCardState();
}

class _SeasonWalkFeatureCardState extends State<SeasonWalkFeatureCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final Animation<double> _glow = _pulse.drive(
    Tween<double>(begin: 0.4, end: 1).chain(CurveTween(curve: AppMotion.move)),
  );
  bool _pressed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = AppMotion.reduced(context);
    final tickersOn = TickerMode.valuesOf(context).enabled;
    if (reduced || !tickersOn) {
      _pulse.stop();
      _pulse.value = 0.7;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _open(SeasonWalkCampaign campaign, DateTime today) {
    ActHaptics.confirm();
    final running = campaign.dayIndexOn(today) != null;
    if (running) {
      openSeasonWalk(context);
      return;
    }
    final l10n = context.l10n;
    final accent = LiturgicalCalendar.accentOf(
      campaign.kind == SeasonWalkKind.advent
          ? LiturgicalSeason.advent
          : LiturgicalSeason.lent,
    );
    final daysUntil = SeasonWalkTogetherCard.daysUntilStart(campaign, today);
    showPathPreviewSheet(
      context,
      title: campaign.title,
      description:
          '${l10n.walkTogetherStartsIn(daysUntil)}. ${campaign.subtitle}',
      art: SeasonWalkCatalog.artAsset(campaign.kind),
      accent: accent,
      eyebrow: l10n.walkTogetherKicker,
      glyph: CinematicGlyph.calendar,
      footer: const SeasonWalkTogetherCard(bare: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final today = context.select((ProgressService p) => p.seasonToday);
    final campaign = SeasonWalkCatalog.current(today);
    if (!SeasonWalkTogetherCard.visibleOn(campaign, today)) {
      return const SizedBox.shrink();
    }

    final joined = context.select(
      (ProgressService p) => p.hasJoinedWalk(campaign.id),
    );
    final doneDays = context.select(
      (ProgressService p) => p.walkDatesFor(campaign.id).length,
    );
    final dayIndex = campaign.dayIndexOn(today);
    final running = dayIndex != null;
    final daysUntil = SeasonWalkTogetherCard.daysUntilStart(campaign, today);
    final accent = LiturgicalCalendar.accentOf(
      campaign.kind == SeasonWalkKind.advent
          ? LiturgicalSeason.advent
          : LiturgicalSeason.lent,
    );
    final status = running
        ? l10n.walkTogetherDayOf(dayIndex, campaign.length)
        : l10n.walkTogetherStartsIn(daysUntil);
    final pitch = running
        ? campaign.subtitle
        : l10n.walkTogetherPitch(campaign.length);
    final progress = running
        ? (doneDays / campaign.length).clamp(0.0, 1.0)
        : null;
    final morning = a.look == AppearanceLook.morning;
    final ink = morning ? a : AppearanceStyle.resolve(AppearanceMode.night);

    return Semantics(
      button: true,
      label: '${campaign.title}. $status. $pitch',
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () => _open(campaign, today),
        child: AnimatedScale(
          scale: _pressed ? 0.985 : 1,
          duration: AppMotion.quick,
          curve: AppMotion.enter,
          child: GlassCard(
            radius: AppMetrics.heroRadius,
            elevated: true,
            tint: accent,
            glow: 0.72,
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppMetrics.heroRadius - AppMetrics.cardBorderWidth,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      SeasonWalkCatalog.artAsset(campaign.kind),
                      fit: BoxFit.cover,
                      alignment: const Alignment(-0.35, 0),
                      cacheWidth:
                          (MediaQuery.sizeOf(context).width *
                                  MediaQuery.devicePixelRatioOf(context))
                              .round(),
                      cacheHeight:
                          (220 * MediaQuery.devicePixelRatioOf(context)).round(),
                    ),
                  ),
                  // Véu só sob o texto — a pintura abre cedo à direita.
                  // Antes o Claro ia a 0xF5 até a metade e o pé ainda
                  // cobria de branco: a estação sumia.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: morning
                              ? const [
                                  Color(0xE0E7F0F8),
                                  Color(0x99E7F0F8),
                                  Color(0x28E7F0F8),
                                  Color(0x00E7F0F8),
                                ]
                              : const [
                                  Color(0xD906080C),
                                  Color(0x8006080C),
                                  Color(0x2606080C),
                                  Color(0x0006080C),
                                ],
                          stops: const [0.0, 0.32, 0.62, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: morning
                              ? const [
                                  Color(0x00FFFFFF),
                                  Color(0x59FFFFFF),
                                ]
                              : const [
                                  Color(0x0006080C),
                                  Color(0x7306080C),
                                ],
                          stops: const [0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -40,
                    top: -50,
                    child: IgnorePointer(
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              accent.withValues(alpha: 0.22),
                              accent.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: AppMetrics.cardPadding,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SectionLabel(
                                l10n.walkTogetherKicker,
                                size: 10,
                                color: accent,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                campaign.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.display(
                                  size: 22,
                                  color: ink.text,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                status,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.body(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: ink.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pitch,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.body(
                                  size: 12,
                                  height: 1.35,
                                  color: ink.textSecondary,
                                ),
                              ),
                              if (progress != null) ...[
                                const SizedBox(height: 10),
                                AppProgressBar(
                                  value: progress,
                                  height: 6,
                                  color: accent,
                                  trackColor: accent.withValues(alpha: 0.22),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        RepaintBoundary(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                const Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppRoles.action,
                                    ),
                                  ),
                                ),
                                FadeTransition(
                                  opacity: _glow,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppRoles.action.withValues(
                                            alpha: 0.46,
                                          ),
                                          blurRadius: 18,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const SizedBox(
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: CinematicIcon(
                                    glyph: running || joined
                                        ? CinematicGlyph.forward
                                        : CinematicGlyph.path,
                                    size: AppMetrics.iconMd,
                                    accent: AppRoles.onAction,
                                    framed: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
