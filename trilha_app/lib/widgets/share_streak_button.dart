import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';
import '../l10n/app_language.dart';

/// Compartilhar a sequência — funciona mesmo com streak 0.
class ShareStreakButton extends StatelessWidget {
  final int streak;
  final String userName;
  final int steps;
  final bool compact;
  final bool asLink;

  const ShareStreakButton({
    super.key,
    required this.streak,
    required this.userName,
    required this.steps,
    this.compact = false,
    this.asLink = false,
  });

  Future<void> _share(AppLocalizations l10n) async {
    final name = userName.trim().isEmpty ? '' : '\n— $userName';
    final String body;
    if (streak > 0) {
      body = l10n.streakShareDays(streak, steps, name);
    } else if (steps > 0) {
      body = l10n.streakShareSteps(steps, name);
    } else {
      body = l10n.streakShareStart(name);
    }
    await SharePlus.instance.share(
      ShareParams(text: body.trim(), subject: l10n.streakShareSubject),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (asLink) {
      final a = Appearance.of(context);
      return TextCta(
        label: context.l10n.commonShare,
        leading: CinematicGlyph.share,
        color: a.textSecondary,
        onTap: () => _share(context.l10n),
      );
    }

    if (compact) {
      final a = Appearance.of(context);
      return Tooltip(
        message: context.l10n.streakShareTooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ActHaptics.light();
              _share(context.l10n);
            },
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: SizedBox(
              width: 36,
              height: 36,
              child: CinematicIcon(
                glyph: CinematicGlyph.share,
                size: AppMetrics.iconMd,
                accent: a.textSecondary,
                framed: false,
              ),
            ),
          ),
        ),
      );
    }

    return GhostCta(
      label: context.l10n.commonShare,
      leading: CinematicGlyph.share,
      onTap: () => _share(context.l10n),
    );
  }
}
