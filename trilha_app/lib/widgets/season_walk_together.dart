import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Future<SeasonWalkPulse?>? _pulse;
  bool _joining = false;
  String? _pulseCampaignId;

  void _ensurePulse(String campaignId) {
    if (_pulseCampaignId == campaignId && _pulse != null) return;
    _pulseCampaignId = campaignId;
    _pulse = context.read<BackendService>().fetchSeasonWalkPulse(campaignId);
  }

  Future<void> _join(SeasonWalkCampaign campaign) async {
    if (_joining) return;
    setState(() => _joining = true);
    ActHaptics.success();
    final progress = context.read<ProgressService>();
    final backend = context.read<BackendService>();
    final league = context.read<LeagueService>();
    await progress.joinWalk(campaign.id);
    await backend.saveNow(progress, LeagueService.weekKey(), league: league);
    // Avisa no 1º dia, na hora do lembrete.
    await NotificationService.instance.syncFromProgress(progress);
    if (!mounted) return;
    setState(() {
      _joining = false;
      _pulseCampaignId = campaign.id;
      _pulse = backend.fetchSeasonWalkPulse(campaign.id);
    });
  }

  Future<void> _invite(SeasonWalkCampaign campaign) async {
    final l10n = context.l10n;
    final name = context.read<ProgressService>().userName.trim();
    final start = DateFormat.MMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(campaign.start);
    final store = !kIsWeb && Platform.isIOS
        ? AppUpdateService.iosStoreUrl
        : AppUpdateService.androidStoreUrl;
    final text = l10n.walkTogetherShareText(
      name.isEmpty ? l10n.juntosSomeone : name,
      campaign.title,
      l10n.walkTogetherPitch(campaign.length),
      start,
      store,
    );
    final subject = l10n.walkTogetherShareSubject(campaign.title);
    XFile? art;
    try {
      art = await _seasonArtFile(campaign.kind);
    } catch (e, st) {
      debugPrint('season share art: $e\n$st');
    }
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: art == null ? null : [art],
          text: text,
          subject: subject,
        ),
      );
    } catch (e, st) {
      debugPrint('season share: $e\n$st');
      await SharePlus.instance.share(
        ShareParams(text: text, subject: subject),
      );
    }
  }

  /// Copia a arte da estação do bundle para um arquivo temporário compartilhável.
  static Future<XFile> _seasonArtFile(SeasonWalkKind kind) async {
    final asset = SeasonWalkCatalog.artAsset(kind);
    final data = await rootBundle.load(asset);
    final ext = asset.endsWith('.png') ? 'png' : 'jpg';
    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
    final file = File(
      '${Directory.systemTemp.path}/stway_estacao_${kind.name}.$ext',
    );
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return XFile(file.path, mimeType: mime, name: 'stway_${kind.name}.$ext');
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final now = context.select((ProgressService p) => p.seasonToday);
    final campaign = SeasonWalkCatalog.current(now);
    _ensurePulse(campaign.id);
    final joined = context.select(
      (ProgressService p) => p.hasJoinedWalk(campaign.id),
    );
    final dayIndex = campaign.dayIndexOn(now);
    final running = dayIndex != null;
    final status = running
        ? l10n.walkTogetherDayOf(dayIndex, campaign.length)
        : l10n.walkTogetherStartsIn(
            SeasonWalkTogetherCard.daysUntilStart(campaign, now),
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
                      campaign.title,
                      style: AppTypography.title(size: 16, color: a.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      running
                          ? status
                          : '$status · ${l10n.walkTogetherPitch(campaign.length)}',
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
              // Pré-início: só mostra quando já há companhia de verdade.
              if (!running && pulse.walkers < 2) {
                return const SizedBox.shrink();
              }
              final lines = [
                if (running)
                  '${l10n.walkTogetherWalkers(pulse.walkers)} · '
                      '${l10n.walkTogetherToday(pulse.walkedToday)}'
                else
                  l10n.walkTogetherWalkers(pulse.walkers),
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
              onTap: _joining ? null : () => _join(campaign),
            )
          else ...[
            if (running)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.sm),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextCta(
                    label: l10n.walkTogetherOpen,
                    onTap: () => openSeasonWalk(context),
                  ),
                ),
              ),
            GhostCta(
              label: l10n.walkTogetherInvite,
              leading: CinematicGlyph.share,
              expanded: true,
              onTap: () => _invite(campaign),
            ),
          ],
        ],
      ),
    );
  }
}
