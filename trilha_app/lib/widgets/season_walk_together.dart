import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/season_walk_catalog.dart';
import '../l10n/app_language.dart';
import '../models/season_walk.dart';
import '../screens/season_walk_screen.dart';
import '../services/app_update_service.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Caminhada coletiva da temporada (Advento): entrar antes do início, ver
/// quantos estão juntos e quantos caminharam hoje, chamar alguém.
///
/// Aparece [leadDays] dias antes do 1º dia e some quando a temporada acaba.
class SeasonWalkTogetherCard extends StatefulWidget {
  const SeasonWalkTogetherCard({super.key});

  static const leadDays = 21;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Janela do card: [leadDays] antes do início até o último dia.
  static bool visibleOn(SeasonWalkCampaign campaign, DateTime now) {
    final today = _day(now);
    final opens = campaign.start.subtract(const Duration(days: leadDays));
    return !today.isBefore(opens) && !today.isAfter(campaign.end);
  }

  /// Dias até o 1º dia (0 = começa hoje ou já começou).
  static int daysUntilStart(SeasonWalkCampaign campaign, DateTime now) {
    final days = campaign.start.difference(_day(now)).inDays;
    return days < 0 ? 0 : days;
  }

  @override
  State<SeasonWalkTogetherCard> createState() => _SeasonWalkTogetherCardState();
}

class _SeasonWalkTogetherCardState extends State<SeasonWalkTogetherCard> {
  late final SeasonWalkCampaign _campaign = SeasonWalkCatalog.current();
  Future<SeasonWalkPulse?>? _pulse;
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    _pulse = context.read<BackendService>().fetchSeasonWalkPulse(_campaign.id);
  }

  Future<void> _join() async {
    if (_joining) return;
    setState(() => _joining = true);
    ActHaptics.success();
    final progress = context.read<ProgressService>();
    final backend = context.read<BackendService>();
    final league = context.read<LeagueService>();
    await progress.joinWalk(_campaign.id);
    await backend.saveNow(progress, LeagueService.weekKey(), league: league);
    // Avisa no 1º dia, na hora do lembrete.
    await NotificationService.instance.syncFromProgress(progress);
    if (!mounted) return;
    setState(() {
      _joining = false;
      _pulse = backend.fetchSeasonWalkPulse(_campaign.id);
    });
  }

  Future<void> _invite() async {
    final l10n = context.l10n;
    final name = context.read<ProgressService>().userName.trim();
    final start = DateFormat.MMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(_campaign.start);
    await SharePlus.instance.share(
      ShareParams(
        text: l10n.walkTogetherShareText(
          name.isEmpty ? l10n.juntosSomeone : name,
          _campaign.title,
          start,
          AppUpdateService.androidStoreUrl,
        ),
        subject: _campaign.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final now = DateTime.now();
    final joined = context.select(
      (ProgressService p) => p.hasJoinedWalk(_campaign.id),
    );
    final dayIndex = _campaign.dayIndexOn(now);
    final running = dayIndex != null;
    final status = running
        ? l10n.walkTogetherDayOf(dayIndex, _campaign.length)
        : l10n.walkTogetherStartsIn(
            SeasonWalkTogetherCard.daysUntilStart(_campaign, now),
          );

    return GlassCard(
      tint: AppRoles.presence,
      glow: 0.28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CloudMascot(
                face: joined ? CloudFace.sucesso : CloudFace.feliz,
                size: 56,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(
                      l10n.walkTogetherKicker,
                      size: 10,
                      color: AppRoles.presence,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _campaign.title,
                      style: AppTypography.title(size: 16, color: a.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      running
                          ? status
                          : '$status · ${l10n.walkTogetherPitch(_campaign.length)}',
                      style: AppTypography.body(
                        size: 12,
                        height: 1.35,
                        weight: FontWeight.w600,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          FutureBuilder<SeasonWalkPulse?>(
            future: _pulse,
            builder: (context, snap) {
              final pulse = snap.data;
              if (pulse == null) return const SizedBox.shrink();
              final lines = [
                running
                    ? '${l10n.walkTogetherWalkers(pulse.walkers)} · '
                          '${l10n.walkTogetherToday(pulse.walkedToday)}'
                    : l10n.walkTogetherWalkers(pulse.walkers),
                if (running && pulse.daysTogether > 0)
                  l10n.walkTogetherDays(pulse.daysTogether),
              ];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CinematicIcon(
                      glyph: CinematicGlyph.people,
                      size: AppMetrics.iconSm,
                      accent: AppRoles.presence,
                      framed: false,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lines.join('\n'),
                        style: AppTypography.body(
                          size: 12,
                          height: 1.4,
                          weight: FontWeight.w700,
                          color: AppRoles.presence,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (!joined)
            CopperCta(
              label: l10n.walkTogetherJoin,
              leading: CinematicGlyph.path,
              expanded: true,
              onTap: _joining ? null : _join,
            )
          else ...[
            Row(
              children: [
                const CinematicIcon(
                  glyph: CinematicGlyph.check,
                  size: AppMetrics.iconSm,
                  accent: AppRoles.success,
                  framed: false,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.walkTogetherJoined,
                  style: AppTypography.label(
                    size: 12,
                    letterSpacing: 0.2,
                    weight: FontWeight.w800,
                    color: AppRoles.success,
                  ),
                ),
                const Spacer(),
                if (running)
                  TextCta(
                    label: l10n.walkTogetherOpen,
                    onTap: () => openSeasonWalk(context),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            GhostCta(
              label: l10n.walkTogetherInvite,
              leading: CinematicGlyph.share,
              expanded: true,
              onTap: _invite,
            ),
          ],
        ],
      ),
    );
  }
}
