import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

class _HourOption {
  final int hour;
  final String label;
  final String echo;

  const _HourOption({
    required this.hour,
    required this.label,
    required this.echo,
  });
}

const _hours = <_HourOption>[
  _HourOption(hour: 7, label: 'Manhã', echo: '7h'),
  _HourOption(hour: 12, label: 'Meio-dia', echo: '12h'),
  _HourOption(hour: 20, label: 'Noite', echo: '20h'),
];

/// Pedido de lembrete — depois da 1ª missão, com horário âncora.
Future<void> showReminderPromptSheet(BuildContext context) async {
  final progress = context.read<ProgressService>();
  final choice = await showModalBottomSheet<(bool enabled, int hour)>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (_) => const _ReminderPromptSheet(),
  );
  if (progress.notificationsPrompted) return;
  final enabled = choice?.$1 == true;
  final hour = choice?.$2 ?? progress.settings.reminderHour;
  if (enabled) {
    await progress.updateSettings(
      progress.settings.copyWith(reminderHour: hour),
    );
  }
  await progress.markNotificationsPrompted(enabled: enabled);
  if (enabled) {
    await NotificationService.instance.requestOsPermission();
  }
  await NotificationService.instance.syncFromProgress(progress);
}

class _ReminderPromptSheet extends StatefulWidget {
  const _ReminderPromptSheet();

  @override
  State<_ReminderPromptSheet> createState() => _ReminderPromptSheetState();
}

class _ReminderPromptSheetState extends State<_ReminderPromptSheet> {
  int _hour = 7;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final selected = _hours.firstWhere(
      (h) => h.hour == _hour,
      orElse: () => _hours.first,
    );

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
            glyph: CinematicGlyph.bell,
            size: 56,
            accent: AppColors.accent,
            glowing: false,
          ),
          const SizedBox(height: 14),
          Text(
            'O PEREGRINO',
            style: AppTypography.label(
              letterSpacing: 1.5,
              color: AppColors.accent.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Em que hora te chamamos?',
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 20, color: a.text),
          ),
          const SizedBox(height: 8),
          Text(
            'Um horário fixo cola o hábito. Amanhã te avisamos da próxima cena.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              height: 1.4,
              weight: FontWeight.w600,
              color: a.textMuted(0.72),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < _hours.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _HourChip(
                    option: _hours[i],
                    selected: _hour == _hours[i].hour,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _hour = _hours[i].hour);
                    },
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          CopperCta(
            label: 'Chamar às ${selected.echo}',
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop((true, _hour));
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop((false, _hour));
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

class _HourChip extends StatelessWidget {
  final _HourOption option;
  final bool selected;
  final VoidCallback onTap;

  const _HourChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : a.cardFill,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : a.cardBorder.withValues(alpha: 0.55),
            ),
          ),
          child: Column(
            children: [
              Text(
                option.label,
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 0.8,
                  color: selected
                      ? AppColors.inkOnAccent
                      : a.textMuted(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                option.echo,
                style: AppTypography.title(
                  size: 16,
                  color: selected ? AppColors.inkOnAccent : a.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
