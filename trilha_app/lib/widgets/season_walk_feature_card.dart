import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/season_walk_catalog.dart';
import '../l10n/app_language.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/pilgrim_medals.dart';
import '../models/season_walk.dart';
import '../models/trail.dart';
import '../screens/season_walk_screen.dart';
import '../services/backend_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/liturgical_calendar.dart';
import '../utils/season_walk_debug.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'season_countdown.dart';
import 'season_walk_sheet.dart';
import 'season_walk_together.dart';
import 'ui_primitives.dart';

/// Card destaque da Caminhada sazonal na Home — fora de "Mais para hoje".
///
/// Mesmo espírito do fluxo de Trilhas: paisagem, título grande. Fica sempre
/// na Home: antes do início, cadeado e contagem regressiva até a abertura;
/// durante a temporada, o dia, o progresso e a próxima medalha da estação
/// (o cofre sazonal mora aqui — sem linha própria em "Mais para hoje").
class SeasonWalkFeatureCard extends StatefulWidget {
  final List<Trail> trails;

  const SeasonWalkFeatureCard({super.key, required this.trails});

  /// Trilho do cofre da estação ativo — null fora da janela.
  static PilgrimTrackState? seasonMedalTrack(
    BuildContext context,
    List<Trail> catalog, {
    required ProgressService progress,
  }) {
    final uid = context.read<BackendService>().uid ?? '';
    final profile = CaravanPilgrimProfile.fromProgress(
      progress: progress,
      uid: uid,
    );
    final vaults = PilgrimMedals.evaluateVaults(
      profile: profile,
      catalog: catalog,
      ctx: PilgrimMedalEvalContext.fromProgress(progress),
    );
    for (final v in vaults) {
      if (v.vault.kind == PilgrimVaultKind.season && v.tracks.isNotEmpty) {
        return v.tracks.first;
      }
    }
    return null;
  }

  @override
  State<SeasonWalkFeatureCard> createState() => _SeasonWalkFeatureCardState();
}

class _SeasonWalkFeatureCardState extends State<SeasonWalkFeatureCard> {
  /// Abaixo disso o número soa vazio; a linha some.
  static const _minPulse = 5;

  bool _pressed = false;
  Future<SeasonWalkPulse?>? _pulse;
  String? _pulseCampaignId;

  /// Busca o pulso uma vez por estação (contagens agregadas, leitura barata).
  Future<SeasonWalkPulse?> _pulseFor(String campaignId) {
    if (_pulseCampaignId != campaignId || _pulse == null) {
      _pulseCampaignId = campaignId;
      final fake = SeasonWalkDebug.crowd;
      _pulse = fake != null
          ? Future.value(
              SeasonWalkPulse(
                walkers: fake,
                walkedToday: fake ~/ 3,
                daysTogether: 0,
              ),
            )
          : context.read<BackendService>().fetchSeasonWalkPulse(campaignId);
    }
    return _pulse!;
  }

  String? _pulseLine(SeasonWalkPulse? pulse, {required bool running}) {
    if (pulse == null || pulse.walkers < _minPulse) return null;
    final l10n = context.l10n;
    if (!running) return l10n.seasonCardJoined(pulse.walkers);
    final walking = l10n.seasonCardWalking(pulse.walkers);
    return pulse.walkedToday > 0
        ? '$walking · ${l10n.seasonCardWalkedToday(pulse.walkedToday)}'
        : walking;
  }

  void _open(SeasonWalkCampaign campaign, DateTime today) {
    ActHaptics.confirm();
    final running = campaign.dayIndexOn(today) != null;
    if (running) {
      openSeasonWalk(context);
      return;
    }
    showSeasonWalkSheet(context, campaign: campaign, seasonToday: today);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    // select só assina o relógio do Laboratório; o dia vem fresco a cada
    // build (o valor guardado ficava velho depois da meia-noite).
    context.select((ProgressService p) => p.seasonToday);
    final today = SeasonWalkDebug.today();
    final campaign = SeasonWalkCatalog.current(today);
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
    // Medalhas da estação só contam com ela aberta.
    final medal = running
        ? SeasonWalkFeatureCard.seasonMedalTrack(
            context,
            widget.trails,
            progress: context.watch<ProgressService>(),
          )
        : null;
    final nextMedal = medal?.nextLevel;
    final medalLine = medal == null
        ? null
        : medal.isComplete
        ? medal.currentLevel?.title
        : nextMedal == null
        ? null
        : l10n.medalVaultNextSemantics(nextMedal.title);
    final morning = a.look == AppearanceLook.morning;
    final ink = morning ? a : AppearanceStyle.resolve(AppearanceMode.night);

    return Semantics(
      button: true,
      label: [campaign.title, status, pitch, ?medalLine].join('. '),
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
                          (220 * MediaQuery.devicePixelRatioOf(context))
                              .round(),
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
                              ? const [Color(0x00FFFFFF), Color(0x59FFFFFF)]
                              : const [Color(0x0006080C), Color(0x7306080C)],
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
                                campaign.isGift
                                    ? '${l10n.walkTogetherKicker} · '
                                          '${l10n.seasonGiftTag}'
                                    : l10n.walkTogetherKicker,
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
                              if (running)
                                Text(
                                  status,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.body(
                                    size: 13,
                                    weight: FontWeight.w700,
                                    color: ink.text,
                                  ),
                                )
                              else
                                SeasonCountdown(
                                  opens: campaign.start,
                                  seasonToday: today,
                                  color: ink.text,
                                  muted: ink.textSecondary,
                                  // Abriu com a Home na tela: vira o dia 1.
                                  onDone: () {
                                    if (mounted) setState(() {});
                                  },
                                ),
                              const SizedBox(height: 4),
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
                              FutureBuilder<SeasonWalkPulse?>(
                                future: _pulseFor(campaign.id),
                                builder: (context, snap) {
                                  final line = _pulseLine(
                                    snap.data,
                                    running: running,
                                  );
                                  if (line == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Row(
                                      children: [
                                        CinematicIcon(
                                          glyph: CinematicGlyph.people,
                                          size: 14,
                                          accent: accent,
                                          framed: false,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            line,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.body(
                                              size: 12,
                                              weight: FontWeight.w700,
                                              color: ink.text,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
                              if (medalLine != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    CinematicIcon(
                                      glyph: medal!.isComplete
                                          ? CinematicGlyph.check
                                          : nextMedal!.glyph,
                                      size: 14,
                                      accent: medal.isComplete
                                          ? AppRoles.success
                                          : accent,
                                      framed: false,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        medalLine,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.body(
                                          size: 12,
                                          weight: FontWeight.w700,
                                          color: ink.text,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Selo translúcido: cadeado até abrir, seta depois.
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ink.text.withValues(alpha: 0.12),
                            border: Border.all(
                              color: ink.text.withValues(alpha: 0.22),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Opacity(
                            opacity: 0.8,
                            child: CinematicIcon(
                              glyph: running
                                  ? CinematicGlyph.forward
                                  : CinematicGlyph.lock,
                              size: AppMetrics.iconMd,
                              accent: ink.text,
                              framed: false,
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
