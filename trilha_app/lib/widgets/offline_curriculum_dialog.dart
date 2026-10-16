import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/network_reachability.dart';
import 'app_sheet.dart';
import 'cloud_mascot.dart';
import 'ui_primitives.dart';

/// Diálogo: currículo ainda não baixou (rede, Firebase ou 1ª abertura).
///
/// [onRetry] deve forçar refresh do catálogo e retornar `true` se carregou.
Future<bool> showOfflineCurriculumDialog(
  BuildContext context, {
  required Future<bool> Function() onRetry,
}) async {
  if (_offlineDialogOpen) return false;
  _offlineDialogOpen = true;
  try {
    final result = await showAppDialog<bool>(
      context,
      barrierDismissible: false,
      builder: (ctx) => _OfflineCurriculumDialog(onRetry: onRetry),
    );
    return result == true;
  } finally {
    _offlineDialogOpen = false;
  }
}

bool _offlineDialogOpen = false;

class _OfflineCurriculumDialog extends StatefulWidget {
  final Future<bool> Function() onRetry;

  const _OfflineCurriculumDialog({required this.onRetry});

  @override
  State<_OfflineCurriculumDialog> createState() =>
      _OfflineCurriculumDialogState();
}

class _OfflineCurriculumDialogState extends State<_OfflineCurriculumDialog> {
  bool _busy = false;
  String? _hint;

  Future<void> _retry() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _hint = null;
    });
    HapticFeedback.lightImpact();

    // Sempre tenta o download — DNS/VPN dão falso negativo com frequência.
    final ok = await widget.onRetry();
    if (!mounted) return;

    if (ok) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(true);
      return;
    }

    final online = await NetworkReachability.hasInternet();
    if (!mounted) return;

    setState(() {
      _busy = false;
      _hint = online
          ? context.l10n.offlineDownloadFailed
          : context.l10n.offlineNoInternet;
    });
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    const accent = AppRoles.risk;

    return PopScope(
      canPop: false,
      child: AppDialog(
        // Sem rede: erro; baixando de novo: espera.
        face: _busy ? CloudFace.carregando : CloudFace.erro,
        title: context.l10n.offlineTitle,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.offlineBody,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 14,
                height: 1.4,
                weight: FontWeight.w600,
                color: a.textSecondary,
              ),
            ),
            if (_hint != null) ...[
              const SizedBox(height: 14),
              InsetPanel(
                borderColor: accent.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    _hint!,
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: a.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          CopperCta(
            label: _busy
                ? context.l10n.offlineDownloading
                : context.l10n.commonTryAgain,
            onTap: _busy ? null : _retry,
            showArrow: false,
          ),
        ],
      ),
    );
  }
}
