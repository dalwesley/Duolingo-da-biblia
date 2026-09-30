import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../services/app_update_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Mostra sheet de update. Retorna `true` se o usuário foi à loja.
Future<bool> showAppUpdateSheet(
  BuildContext context,
  AppUpdateStatus status,
) async {
  if (!status.updateAvailable) return false;
  final result = await showAppSheet<bool>(
    context,
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
    final accent = _force ? AppColors.ember : AppColors.accent;

    return PopScope(
      canPop: !_force,
      child: AppSheetPanel(
        tint: _force ? accent : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSheetHeader(
              center: true,
              leading: CinematicIcon(
                glyph: _force ? CinematicGlyph.shield : CinematicGlyph.spark,
                size: 56,
                accent: accent,
                glowing: false,
              ),
              eyebrow: context.l10n.updateEyebrow,
              eyebrowColor: accent.withValues(alpha: 0.85),
              title: _force
                  ? context.l10n.updateForceTitle
                  : context.l10n.updateSoftTitle,
              subtitle: status.message,
            ),
            const SizedBox(height: 16),
            _VersionLane(
              local: status.localLabel,
              latest: status.latestLabel,
              accent: accent,
            ),
            const SizedBox(height: 20),
            CopperCta(
              label: context.l10n.updateNow,
              onTap: () async {
                final ok = await AppUpdateService.openStore(status.storeUrl);
                if (!context.mounted) return;
                if (!ok) {
                  showAppToastFor(
                    context,
                    message: context.l10n.updateStoreOpenFailed,
                    glyph: CinematicGlyph.wrong,
                    tone: AppToastTone.warn,
                  );
                  return;
                }
                if (!_force) Navigator.of(context).pop(true);
              },
            ),
            if (!_force) ...[
              const SizedBox(height: 8),
              TextCta(
                label: context.l10n.commonNotNow,
                color: a.textFaint,
                onTap: () async {
                  await AppUpdateService.snoozeSoftPrompt();
                  if (context.mounted) Navigator.of(context).pop(false);
                },
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

    return SizedBox(
      width: double.infinity,
      child: InsetPanel(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: _VersionMark(
                kicker: context.l10n.commonYou,
                value: local,
                valueColor: a.textSecondary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CinematicIcon(
                glyph: CinematicGlyph.forward,
                size: 16,
                accent: a.textFaint,
                framed: false,
              ),
            ),
            Expanded(
              child: _VersionMark(
                kicker: context.l10n.updateInStore,
                value: latest,
                valueColor: accent,
                alignEnd: true,
              ),
            ),
          ],
        ),
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
        SectionLabel(kicker, size: 10, color: a.textFaint),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.title(size: 14, color: valueColor)),
      ],
    );
  }
}
