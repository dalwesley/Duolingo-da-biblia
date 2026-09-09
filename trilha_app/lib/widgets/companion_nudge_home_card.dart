import 'package:flutter/material.dart';
import '../models/walk_companion.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Card na Home quando alguém te acenou.
class CompanionNudgeHomeCard extends StatelessWidget {
  final WalkCompanion companion;
  final VoidCallback? onWalk;
  final VoidCallback? onOpenCompanhia;

  const CompanionNudgeHomeCard({
    super.key,
    required this.companion,
    this.onWalk,
    this.onOpenCompanhia,
  });

  @override
  Widget build(BuildContext context) {
    final from = companion.incomingNudgeFromName?.trim().isNotEmpty == true
        ? companion.incomingNudgeFromName!.trim().split(' ').first
        : 'Companheiro';
    final message = companion.incomingNudgeMessage?.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.section),
      child: GlassCard(
        elevated: true,
        tint: AppColors.accent,
        padding: AppMetrics.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CinematicIcon(
                  glyph: CinematicGlyph.lamp,
                  size: 40,
                  accent: AppColors.accent,
                  glowing: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$from te animou',
                        style: AppTypography.title(
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Um aceno na trilha. Sua vez de caminhar.',
                        style: AppTypography.body(
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.62),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (message != null && message.isNotEmpty) ...[
              const SizedBox(height: AppSpace.md),
              Text(
                message,
                style: AppTypography.body(
                  size: 15,
                  height: 1.35,
                  weight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ],
            const SizedBox(height: AppSpace.md),
            CopperCta(
              label: 'Dar o passo',
              onTap: onWalk,
              leading: CinematicGlyph.path,
              trailing: null,
              dense: true,
            ),
            if (onOpenCompanhia != null) ...[
              const SizedBox(height: 8),
              GhostCta(
                label: 'Ver companhia',
                leading: CinematicGlyph.people,
                expanded: true,
                onTap: onOpenCompanhia,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
