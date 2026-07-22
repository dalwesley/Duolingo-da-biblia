import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';

/// Compartilhar a caminhada — funciona mesmo com streak 0.
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
    final name = userName.trim().isEmpty ? '' : '\n— $userName';
    final String body;
    if (streak > 0) {
      final days = streak == 1 ? '1 dia' : '$streak dias';
      body = '''
👣 Minha caminhada no Steway: $days!

Estou caminhando na Palavra — $steps passos até agora.$name

Baixe o Steway e caminhe comigo. 📖✨
''';
    } else if (steps > 0) {
      body = '''
👣 Estou caminhando na Palavra no Steway — $steps passos até agora.$name

Baixe o Steway e caminhe comigo. 📖✨
''';
    } else {
      body = '''
👣 Estou começando a caminhar na Palavra com o Steway.$name

Baixe o Steway e caminhe comigo. 📖✨
''';
    }
    await SharePlus.instance.share(
      ShareParams(text: body.trim(), subject: 'Minha caminhada no Steway'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      final a = Appearance.of(context);
      return Tooltip(
        message: 'Compartilhar caminhada',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _share,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(
                Icons.ios_share_rounded,
                size: 18,
                color: a.text.withValues(alpha: 0.72),
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
            const Icon(
              Icons.ios_share_rounded,
              size: 16,
              color: AppColors.streak,
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
