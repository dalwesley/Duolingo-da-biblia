import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';

/// Compartilhar sequência — prova social / investimento (YouVersion + Duolingo).
class ShareStreakButton extends StatelessWidget {
  final int streak;
  final String userName;
  final int xp;
  final bool compact;

  const ShareStreakButton({
    super.key,
    required this.streak,
    required this.userName,
    required this.xp,
    this.compact = false,
  });

  Future<void> _share() async {
    HapticFeedback.lightImpact();
    final days = streak == 1 ? '1 dia' : '$streak dias';
    final name = userName.trim().isEmpty ? '' : '\n— $userName';
    final text = '''
🔥 Minha sequência no Trilha: $days!

Estou na jornada pela Palavra — $xp XP até agora.$name

Baixe o Trilha e caminhe comigo. 📖✨
'''
        .trim();
    await Share.share(text, subject: 'Minha sequência no Trilha');
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        onPressed: streak > 0 ? _share : null,
        tooltip: 'Compartilhar sequência',
        icon: Icon(
          Icons.ios_share_rounded,
          color: streak > 0 ? AppColors.accent : Colors.white38,
        ),
      );
    }

    return GestureDetector(
      onTap: streak > 0 ? _share : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.streak.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.ios_share_rounded, size: 16, color: AppColors.streak.withValues(alpha: streak > 0 ? 1 : 0.4)),
            const SizedBox(width: 8),
            Text(
              'Compartilhar',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white.withValues(alpha: streak > 0 ? 0.9 : 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
