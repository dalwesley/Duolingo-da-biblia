import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_update_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Mostra sheet de update. Retorna `true` se o usuário foi à loja.
Future<bool> showAppUpdateSheet(
  BuildContext context,
  AppUpdateStatus status,
) async {
  if (!status.updateAvailable) return false;
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: status.kind != AppUpdateKind.force,
    enableDrag: status.kind != AppUpdateKind.force,
    builder: (_) => _AppUpdateSheet(status: status),
  );
  return result == true;
}

class _AppUpdateSheet extends StatelessWidget {
  final AppUpdateStatus status;

  const _AppUpdateSheet({required this.status});

  bool get _force => status.kind == AppUpdateKind.force;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final accent = _force ? AppColors.ember : AppColors.accent;

    return PopScope(
      canPop: !_force,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: EdgeInsets.fromLTRB(20, 18, 20, 16 + bottom),
        decoration: BoxDecoration(
          color: _force ? Color.lerp(a.cardFill, accent, 0.08) : a.cardFill,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: _force ? accent.withValues(alpha: 0.45) : a.cardBorder,
          ),
          boxShadow: _force
              ? AppMetrics.cardShadow(elevated: true, tint: accent)
              : AppTheme.cardShadow(elevated: true),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CinematicIcon(
              glyph: _force ? CinematicGlyph.shield : CinematicGlyph.spark,
              size: 56,
              accent: accent,
              glowing: false,
            ),
            const SizedBox(height: 14),
            Text(
              'O PEREGRINO',
              style: AppTypography.label(
                letterSpacing: 1.5,
                color: accent.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _force
                  ? 'Esta versão precisa atualizar'
                  : 'Uma versão nova te espera',
              textAlign: TextAlign.center,
              style: AppTypography.title(size: 20, color: a.text),
            ),
            const SizedBox(height: 8),
            Text(
              status.message,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 14,
                height: 1.4,
                weight: FontWeight.w600,
                color: a.textMuted(0.72),
              ),
            ),
            const SizedBox(height: 16),
            _VersionLane(
              local: status.localLabel,
              latest: status.latestLabel,
              accent: accent,
            ),
            const SizedBox(height: 20),
            CopperCta(
              label: 'Atualizar agora',
              onTap: () async {
                HapticFeedback.mediumImpact();
                final ok = await AppUpdateService.openStore(status.storeUrl);
                if (!context.mounted) return;
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Não deu para abrir a loja. Tente pelo link: ${status.storeUrl}',
                        style: AppTypography.body(
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: AppColors.nightElevated,
                    ),
                  );
                  return;
                }
                if (!_force) Navigator.of(context).pop(true);
              },
            ),
            if (!_force) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  await AppUpdateService.snoozeSoftPrompt();
                  if (context.mounted) Navigator.of(context).pop(false);
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
          ],
        ),
      ),
    );
  }
}

class _VersionLane extends StatelessWidget {
  final String local;
  final String latest;
  final Color accent;

  const _VersionLane({
    required this.local,
    required this.latest,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: a.cardFillSoft,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: a.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _VersionMark(
              kicker: 'Você',
              value: local,
              valueColor: a.textMuted(0.85),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CinematicIcon(
              glyph: CinematicGlyph.forward,
              size: 16,
              accent: a.textMuted(0.45),
              framed: false,
            ),
          ),
          Expanded(
            child: _VersionMark(
              kicker: 'Na loja',
              value: latest,
              valueColor: accent,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionMark extends StatelessWidget {
  final String kicker;
  final String value;
  final Color valueColor;
  final bool alignEnd;

  const _VersionMark({
    required this.kicker,
    required this.value,
    required this.valueColor,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final align = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          kicker.toUpperCase(),
          style: AppTypography.label(
            size: 10,
            letterSpacing: 1.2,
            color: a.textMuted(0.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.title(size: 14, color: valueColor)),
      ],
    );
  }
}
