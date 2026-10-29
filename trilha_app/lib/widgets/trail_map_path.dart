import 'package:flutter/material.dart';
import '../data/trail_art.dart';
import '../l10n/app_language.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/genesis_theme.dart';
import '../utils/trail_progress.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'journey_station_card.dart';
import 'winding_trail.dart';

/// Cenas de uma etapa como cards numa curva — mesmo padrão do mapa do reino.
class TrailMapPath extends StatelessWidget {
  final List<Mission> missions;
  final int startGlobalIndex;
  final List<String> allSlugs;
  final List<String> completedMissions;
  final GenesisModuleTheme? theme;
  final Color? modeAccent;
  final void Function(String slug)? onMissionTap;

  /// Presa na cena [currentSlug] — o mapa rola até ela ao abrir.
  final GlobalKey? currentKey;
  final String? currentSlug;

  /// Cenas que pedem o Peregrino+ (trilha temática, da 2ª em diante, sem
  /// Plus). Continuam tocáveis: o toque leva ao paywall.
  final bool Function(String slug)? plusLocked;

  /// Toque numa cena que pede o Plus: abre a compra, não a cena.
  final void Function(String slug)? onPlusTap;

  /// Toque numa cena ainda fechada pela ordem: explica o que falta.
  final void Function(String slug)? onLockedTap;

  /// Trilha dona destas cenas — a pintura do card.
  final String trailSlug;

  /// Nome do modo ativo ("Observação"), sob o título de cada cena.
  final String? modeLabel;

  /// Postal da cena já revelado; sem ele, a pintura aparece velada.
  /// `null` = nenhuma pintura velada.
  final bool Function(String slug)? revealed;

  const TrailMapPath({
    super.key,
    required this.missions,
    required this.startGlobalIndex,
    required this.allSlugs,
    required this.completedMissions,
    required this.trailSlug,
    this.theme,
    this.modeAccent,
    this.modeLabel,
    this.onMissionTap,
    this.currentKey,
    this.currentSlug,
    this.plusLocked,
    this.onPlusTap,
    this.onLockedTap,
    this.revealed,
  });

  bool _completed(String slug) => completedMissions.contains(slug);

  bool _unlocked(String slug) =>
      TrailProgress.isMissionUnlocked(slug, allSlugs, completedMissions);

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) return const SizedBox.shrink();

    final a = Appearance.of(context);
    final accent = modeAccent ?? theme?.pathActive ?? a.chrome;
    final glow = Color.lerp(accent, Colors.white, 0.22)!;
    final track = Color.lerp(
      // Claro: trilho em tinta (sem puxar para o branco, some no céu).
      a.onDark
          ? Color.lerp(a.progressTrack, AppColors.textOnDark, 0.42)!
          : a.text.withValues(alpha: 0.22),
      accent,
      0.32,
    )!;

    return FlowingWindingTrail(
      walked: accent,
      track: track,
      waveOffset: startGlobalIndex,
      edgeInset: 2,
      // Pegadas só no trecho concluído. À frente, tracejado fino.
      showAhead: false,
      walker: const WindingWalker(
        child: CloudMascot(face: CloudFace.feliz, size: 56, react: false),
      ),
      stops: [
        for (var i = 0; i < missions.length; i++)
          _stop(context, i, accent, glow),
      ],
    );
  }

  WindingStop _stop(BuildContext context, int i, Color accent, Color glow) {
    final mission = missions[i];
    final completed = _completed(mission.slug);
    final unlocked = _unlocked(mission.slug);
    final current = unlocked && !completed;
    final needsPlus = !completed && (plusLocked?.call(mission.slug) ?? false);
    final state = completed
        ? JourneyNodeState.completed
        : (current ? JourneyNodeState.current : JourneyNodeState.locked);
    final index = startGlobalIndex + i + 1;
    final roman = journeyRomanNumeral(index);
    final chrome = (current || completed)
        ? (mission.isBoss ? AppRoles.reward : accent)
        : null;
    final eyebrow = mission.isBoss
        ? context.l10n.trailMapCrossing
        : '${context.l10n.commonScene} $roman';
    final glyph = CinematicGlyphResolver.forMission(
      mission.localizedTitle,
      isBoss: mission.isBoss,
    );

    return WindingStop(
      key: mission.slug == currentSlug ? currentKey : null,
      nodeSize: 72,
      passed: completed,
      centerAnchor: true,
      beacon: current,
      child: JourneyStationCard(
        title: mission.localizedTitle,
        eyebrow: eyebrow,
        watermark: roman,
        glyph: glyph,
        art: TrailArt.ofScene(trailSlug, mission.slug),
        artVeiled: !(revealed?.call(mission.slug) ?? true),
        state: state,
        accent: accent,
        glow: glow,
        chrome: chrome,
        // Fechada pela ordem e também paga: o toque é a compra, como o
        // status ("Só no Peregrino+") já diz.
        onTap: !unlocked && !(needsPlus && onPlusTap != null)
            ? (onLockedTap == null ? null : () => onLockedTap!(mission.slug))
            : needsPlus && onPlusTap != null
            ? () => onPlusTap!(mission.slug)
            : () => onMissionTap?.call(mission.slug),
        plusLocked: needsPlus,
        showMeter: true,
        currentSubtitle: modeLabel == null
            ? null
            : context.l10n.modeNamed(modeLabel!),
        done: completed ? 1 : 0,
        total: 1,
        statusLine: completed
            ? context.l10n.trailsCleared
            : needsPlus
            ? context.l10n.plusNoticeLockedHeader
            : (unlocked
                  ? null
                  : (mission.subtitle.trim().isEmpty
                        ? context.l10n.journeyBeyondHorizon
                        : mission.subtitle)),
        semanticsLabel: mission.localizedTitle,
      ),
    );
  }
}
