import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';

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

  Future<void> _share() async {
    HapticFeedback.lightImpact();
    final name = userName.trim().isEmpty ? '' : '\n— $userName';
    final String body;
    if (streak > 0) {
      final days = streak == 1 ? '1 dia' : '$streak dias';
      body = '''
🔥 $days no Stway!

Estou aprendendo a Bíblia em missões curtas — $steps passos até agora.$name

Baixe o Stway e venha junto.
''';
    } else if (steps > 0) {
      body = '''
🔥 Estou aprendendo a Bíblia no Stway — $steps passos até agora.$name

Baixe o Stway e venha junto.
''';
    } else {
      body = '''
🔥 Comecei a aprender a Bíblia com o Stway.$name

Baixe o Stway e venha junto.
''';
    }
    await SharePlus.instance.share(
      ShareParams(text: body.trim(), subject: 'Minha sequência no Stway'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (asLink) {
      final a = Appearance.of(context);
      return TextButton(
        onPressed: _share,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CinematicIcon(
              glyph: CinematicGlyph.share,
              size: 15,
              accent: a.textMuted(0.7),
              framed: false,
            ),
            const SizedBox(width: 6),
            Text(
              'Compartilhar',
              style: AppTypography.body(
                weight: FontWeight.w700,
                color: a.textMuted(0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (compact) {
      final a = Appearance.of(context);
      return Tooltip(
        message: 'Compartilhar sequência',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _share,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: SizedBox(
              width: 36,
              height: 36,
              child: CinematicIcon(
                glyph: CinematicGlyph.share,
                size: 18,
                accent: a.text.withValues(alpha: 0.72),
                framed: false,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _share,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.streak.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CinematicIcon(
              glyph: CinematicGlyph.share,
              size: 16,
              accent: AppColors.streak,
              framed: false,
            ),
            const SizedBox(width: AppSpace.sm),
            Text(
              'Compartilhar',
              style: AppTypography.title(
                size: 12,
                weight: FontWeight.w800,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
