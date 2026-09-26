import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
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
  final choice = await showAppSheet<(bool enabled, int hour)>(
    context,
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

/// Escolha do horário a partir dos Ajustes (ao ligar o lembrete ou mudar
/// a hora). Devolve a hora escolhida, ou null se a pessoa desistir.
Future<int?> showReminderHourSheet(BuildContext context) async {
  final choice = await showAppSheet<(bool enabled, int hour)>(
    context,
    builder: (_) => const _ReminderPromptSheet(fromSettings: true),
  );
  if (choice == null || !choice.$1) return null;
  return choice.$2;
}

class _ReminderPromptSheet extends StatefulWidget {
  /// Nos Ajustes a pessoa já pediu o lembrete — sem convite, só a hora.
  final bool fromSettings;

  const _ReminderPromptSheet({this.fromSettings = false});

  @override
  State<_ReminderPromptSheet> createState() => _ReminderPromptSheetState();
}

class _ReminderPromptSheetState extends State<_ReminderPromptSheet> {
  int _hour = 7;

  @override
  void initState() {
    super.initState();
    // Já vem com o horário escolhido no onboarding.
    final chosen = context.read<ProgressService>().settings.reminderHour;
    if (_hours.any((h) => h.hour == chosen)) _hour = chosen;
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final selected = _hours.firstWhere(
      (h) => h.hour == _hour,
      orElse: () => _hours.first,
    );

    return AppSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetHeader(
            center: true,
            leading: const CinematicIcon(
              glyph: CinematicGlyph.bell,
              size: 56,
              accent: AppColors.accent,
              glowing: false,
            ),
            eyebrow: widget.fromSettings ? 'Lembrete diário' : 'O peregrino',
            eyebrowColor: AppColors.accent.withValues(alpha: 0.85),
            title: 'Em que hora lembramos você?',
            subtitle: widget.fromSettings
                ? 'Um aviso por dia, no horário que você escolher.'
                : 'Um horário fixo cola o hábito. Amanhã te avisamos da próxima cena.',
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
                      ActHaptics.tap();
                      setState(() => _hour = _hours[i].hour);
                    },
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          CopperCta(
            label: 'Lembrar às ${selected.echo}',
            onTap: () {
              Navigator.of(context).pop((true, _hour));
            },
          ),
          const SizedBox(height: 8),
          TextCta(
            label: widget.fromSettings ? 'Cancelar' : 'Agora não',
            color: a.textFaint,
            onTap: () {
              Navigator.of(context).pop((false, _hour));
            },
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
    return AppChoiceTile(
      selected: selected,
      onTap: onTap,
      child: Column(
        children: [
          Text(
            option.label,
            style: AppTypography.label(
              size: 11,
              letterSpacing: 0.8,
              color: selected ? AppColors.inkOnAccent : a.textSecondary,
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
    );
  }
}
