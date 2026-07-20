import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';

/// Compartilhar dias caminhando — encorajamento, não ostentação.
class ShareStreakButton extends StatelessWidget {
  final int streak;
  final String userName;
  final int steps;
  final bool compact;

  const ShareStreakButton({
    super.key,
    required this.streak,
    required this.userName,
    required this.steps,
    this.compact = false,
  });

  Future<void> _share() async {
    HapticFeedback.lightImpact();
    final days = streak == 1 ? '1 dia' : '$streak dias';
    final name = userName.trim().isEmpty ? '' : '\n— $userName';
    final text = '''
👣 Minha caminhada no Trilha: $days!

Estou caminhando na Palavra — $steps passos até agora.$name

Baixe o Trilha e caminhe comigo. 📖✨
'''
        .trim();
    await SharePlus.instance.share(
      ShareParams(text: text, subject: 'Minha caminhada no Trilha'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return SizedBox(
        width: 34,
        height: 34,
        child: IconButton(
          onPressed: streak > 0 ? _share : null,
          tooltip: 'Compartilhar caminhada',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 34, height: 34),
          visualDensity: VisualDensity.compact,
          icon: CinematicIcon(
            glyph: CinematicGlyph.share,
            size: 20,
            accent: streak > 0 ? AppColors.accent : Colors.white38,
            framed: false,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: streak > 0 ? _share : null,
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
            CinematicIcon(
              glyph: CinematicGlyph.share,
              size: 16,
              accent: AppColors.streak.withValues(alpha: streak > 0 ? 1 : 0.4),
              framed: false,
            ),
            const SizedBox(width: AppSpace.sm),
            Text(
              'Compartilhar',
              style: AppTypography.title(
                size: 12,
                weight: FontWeight.w800,
                color: Colors.white.withValues(alpha: streak > 0 ? 0.9 : 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
