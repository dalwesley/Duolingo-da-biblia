import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pilgrim_chest.dart';
import '../models/pilgrim_medal_models.dart' show tierLabel, PilgrimMedalTier;
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'confetti_overlay.dart';
import 'immersive_background.dart';
import 'medal_cinematic_widgets.dart';
import 'ui_primitives.dart';
import '../l10n/app_language.dart';

/// Baú do dia — recompensa cosmética variável, 1x/dia, ao completar a
/// cena de hoje. Nunca dá passos/XP: não compete com o Cofre de medalhas
/// (que fica intocado como conquista de longo prazo). A incerteza é só de
/// apresentação — a recompensa em si sempre vem (piso garantido por pity
/// em [PilgrimChestRoll]).
class DailyChestCard extends StatelessWidget {
  const DailyChestCard({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);
    final available = progress.dailyChestAvailable;
    final openedToday = progress.dailyChestOpenedToday;
    final lastReward = progress.lastDailyChestReward;
    final showsTodayReward = openedToday && lastReward != null;

    final accent = showsTodayReward
        ? tierColor(lastReward.tier)
        : AppColors.medalGold;

    final row = Row(
      children: [
        _ChestGlyph(accent: accent, glowing: available),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.chestDailyTitle,
                style: AppTypography.title(size: 14, color: a.text),
              ),
              const SizedBox(height: 2),
              Text(
                showsTodayReward
                    ? lastReward.title
                    : (available
                          ? context.l10n.chestReady
                          : context.l10n.chestLocked),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: accent.withValues(
                    alpha: showsTodayReward || available ? 0.95 : 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpace.md),
        if (showsTodayReward)
          const CinematicIcon(
            glyph: CinematicGlyph.check,
            size: AppMetrics.iconLg,
            accent: AppRoles.success,
            framed: false,
          )
        else if (!available)
          CinematicIcon(
            glyph: CinematicGlyph.lock,
            size: AppMetrics.iconMd,
            accent: accent.withValues(alpha: 0.85),
            framed: false,
          ),
      ],
    );

    // Card com fundo próprio (também vive numa folha transparente).
    // Uma ação só: "Abrir o baú" quando disponível.
    return Semantics(
      container: true,
      child: GlassCard(
        padding: AppMetrics.cardPadding,
        tint: accent,
        elevated: true,
        onTap: available ? () => _open(context) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            row,
            if (available) ...[
              const SizedBox(height: AppSpace.md),
              CopperCta(
                label: context.l10n.chestOpen,
                trailing: CinematicGlyph.gift,
                dense: true,
                onTap: () => _open(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    ActHaptics.tap();
    showAppSheet<void>(
      context,
      enableDrag: false,
      isDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => const _DailyChestSheet(),
    );
  }
}

class _ChestGlyph extends StatelessWidget {
  final Color accent;
  final bool glowing;

  const _ChestGlyph({required this.accent, required this.glowing});

  @override
  Widget build(BuildContext context) {
    return CinematicIcon(
      glyph: CinematicGlyph.gift,
      size: AppMetrics.leadingIcon,
      accent: accent,
      glowing: glowing,
    );
  }
}

class _DailyChestSheet extends StatefulWidget {
  const _DailyChestSheet();

  @override
  State<_DailyChestSheet> createState() => _DailyChestSheetState();
}

class _DailyChestSheetState extends State<_DailyChestSheet>
    with TickerProviderStateMixin {
  late final AnimationController _anticipation;
  late final AnimationController _reveal;
  late final AnimationController _pulse;
  bool _opening = false;
  PilgrimChestReward? _reward;

  @override
  void initState() {
    super.initState();
    _anticipation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_open());
    });
  }

  @override
  void dispose() {
    _anticipation.dispose();
    _reveal.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (_opening || _reward != null) return;
    setState(() => _opening = true);
    ActHaptics.confirm();
    unawaited(SoundService.instance.playStreak());
    await _anticipation.forward();
    if (!mounted) return;
    final progress = context.read<ProgressService>();
    final reward = await progress.openDailyChest();
    if (!mounted) return;
    final isTopTier =
        reward.tier == PilgrimMedalTier.gold ||
        reward.tier == PilgrimMedalTier.mirra;
    ActHaptics.success();
    if (isTopTier) unawaited(SoundService.instance.playComplete());
    setState(() {
      _reward = reward;
      _opening = false;
    });
    _reveal.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final media = MediaQuery.of(context);
    final minHeight = media.size.height * 0.56;
    final reward = _reward;
    final accent = reward != null
        ? tierColor(reward.tier)
        : AppColors.medalGold;
    final glyph = reward?.glyph ?? CinematicGlyph.gem;

    return AppSheetPanel(
      tint: accent,
      padding: const EdgeInsets.fromLTRB(24, AppSpace.md, 24, 28),
      background: Stack(
        children: [
          if (reward != null)
            const Positioned.fill(
              child: ConfettiOverlay(active: true, cinematic: true),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: Listenable.merge([_pulse, _reveal, _anticipation]),
                builder: (context, _) {
                  final breath = (math.sin(_pulse.value * math.pi * 2) + 1) / 2;
                  final intensity = reward != null
                      ? Curves.easeOut.transform(_reveal.value)
                      : 0.45 + _anticipation.value * 0.35;
                  return CustomPaint(
                    painter: MedalSpotlightPainter(
                      accent: accent,
                      breath: breath,
                      intensity: intensity,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      child: SizedBox(
        height: minHeight,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  SectionLabel(
                    reward == null
                        ? context.l10n.chestDailyTitle
                        : _headline(reward.tier),
                    color: accent,
                  ),
                  const SizedBox(height: 28),
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _anticipation,
                      _reveal,
                      _pulse,
                    ]),
                    builder: (context, _) {
                      final wobble = _opening
                          ? math.sin(_anticipation.value * math.pi * 7) *
                                (1 - _anticipation.value) *
                                0.16
                          : 0.0;
                      final breath =
                          (math.sin(_pulse.value * math.pi * 2) + 1) / 2;
                      final revealScale = reward != null
                          ? Curves.elasticOut.transform(_reveal.value)
                          : 1.0;
                      return Transform.rotate(
                        angle: wobble,
                        child: Transform.scale(
                          scale: 0.86 + 0.14 * revealScale,
                          child: MedalHeroEmblem(
                            accent: accent,
                            glyph: glyph,
                            size: 72,
                            breath: breath,
                            glowing: true,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  if (reward == null) ...[
                    Text(
                      context.l10n.chestSheetTitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.title(size: 20, color: a.text),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _opening
                          ? context.l10n.chestOpening
                          : context.l10n.chestRevealStarts,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        size: 14,
                        height: 1.45,
                        color: a.textSecondary,
                      ),
                    ),
                    const Spacer(),
                  ] else ...[
                    FadeTransition(
                      opacity: _reveal,
                      child: Column(
                        children: [
                          SoftBadge(
                            text: tierLabel(reward.tier),
                            accent: accent,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            reward.title,
                            textAlign: TextAlign.center,
                            style: AppTypography.display(
                              size: 24,
                              weight: FontWeight.w900,
                              color: a.text,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            reward.message,
                            textAlign: TextAlign.center,
                            style: AppTypography.body(
                              size: 14,
                              height: 1.5,
                              color: a.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    FadeTransition(
                      opacity: _reveal,
                      child: CopperCta(
                        label: context.l10n.commonContinue,
                        onTap: () => Navigator.pop(context),
                        trailing: CinematicGlyph.forward,
                        dense: true,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _headline(PilgrimMedalTier tier) => tier == PilgrimMedalTier.mirra
      ? context.l10n.chestVeryRare
      : context.l10n.chestTierToday(tierLabel(tier));
}
