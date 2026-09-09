import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Pedido de lembrete — depois da 1ª missão, com contexto da sequência.
/// Fecha o sheet primeiro; só então grava a escolha (evita pop extra / tela preta).
Future<void> showReminderPromptSheet(BuildContext context) async {
  final progress = context.read<ProgressService>();
  final choice = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (_) => const _ReminderPromptSheet(),
  );
  if (progress.notificationsPrompted) return;
  await progress.markNotificationsPrompted(enabled: choice == true);
  if (choice == true) {
    await NotificationService.instance.requestOsPermission();
  }
  await NotificationService.instance.syncFromProgress(progress);
}

class _ReminderPromptSheet extends StatelessWidget {
  const _ReminderPromptSheet();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(20, 18, 20, 16 + bottom),
      decoration: BoxDecoration(
        color: a.cardFill,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: a.cardBorder),
        boxShadow: AppTheme.cardShadow(elevated: true),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.mail,
            size: 56,
            accent: AppColors.streak,
            glowing: false,
          ),
          const SizedBox(height: 14),
          Text(
            'O PEREGRINO',
            style: AppTypography.label(
              letterSpacing: 1.5,
              color: AppColors.streak.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Quer proteger a sequência?',
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 20, color: a.text),
          ),
          const SizedBox(height: 8),
          Text(
            'Um aviso amanhã, na hora certa — antes da chama se apagar. Você muda isso quando quiser em Ajustes.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              height: 1.4,
              weight: FontWeight.w600,
              color: a.textMuted(0.72),
            ),
          ),
          const SizedBox(height: 20),
          CopperCta(
            label: 'Proteger sequência',
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop(true);
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop(false);
            },
            child: Text(
              'Agora não',
              style: AppTypography.body(
                weight: FontWeight.w700,
                color: a.textMuted(0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
