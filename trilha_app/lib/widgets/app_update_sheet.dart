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
          color: Color.lerp(a.cardFill, accent, 0.08),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: accent.withValues(alpha: 0.45)),
          boxShadow: AppMetrics.cardShadow(elevated: true, tint: accent),
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
              _force ? 'Atualização necessária' : 'Nova versão disponível',
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
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: accent.withValues(alpha: 0.28)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Você · ${status.localLabel}',
                      style: AppTypography.body(
                        size: 12,
                        weight: FontWeight.w700,
                        color: a.textMuted(0.7),
                      ),
                    ),
                  ),
                  Text(
                    'Nova · ${status.latestLabel}',
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CopperCta(
              label: 'Atualizar agora',
              trailing: CinematicGlyph.rise,
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
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  await AppUpdateService.snoozeSoftPrompt();
                  if (context.mounted) Navigator.of(context).pop(false);
                },
                child: Text(
                  'Agora não',
                  style: AppTypography.body(
                    size: 14,
                    weight: FontWeight.w700,
                    color: a.textMuted(0.65),
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
