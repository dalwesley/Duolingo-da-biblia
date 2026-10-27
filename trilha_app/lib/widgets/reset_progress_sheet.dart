import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'ui_primitives.dart';

/// Confirmação irreversível. O botão só habilita depois de [waitSeconds]
/// e com o aviso de perda de progresso marcado.
Future<bool> showResetProgressSheet(BuildContext context) {
  return _showDangerSheet(context, _DangerKind.resetProgress);
}

/// Mesma confirmação para excluir a conta (App Store 5.1.1(v)).
/// [subscriptionNote]: avisa que a assinatura não cai junto (só com Peregrino+ ativo).
Future<bool> showDeleteAccountSheet(
  BuildContext context, {
  bool subscriptionNote = false,
}) {
  return _showDangerSheet(
    context,
    _DangerKind.deleteAccount,
    subscriptionNote: subscriptionNote,
  );
}

/// Sai da trilha e zera o progresso dela — mesmo ritual (checkbox + contagem).
Future<bool> showLeaveTrailSheet(BuildContext context) {
  return _showDangerSheet(context, _DangerKind.leaveTrail);
}

enum _DangerKind { resetProgress, deleteAccount, leaveTrail }

Future<bool> _showDangerSheet(
  BuildContext context,
  _DangerKind kind, {
  bool subscriptionNote = false,
}) {
  ActHaptics.confirm();
  return showAppSheet<bool>(
    context,
    builder: (_) =>
        _ResetProgressSheet(kind: kind, subscriptionNote: subscriptionNote),
  ).then((value) => value == true);
}

class _ResetProgressSheet extends StatefulWidget {
  final _DangerKind kind;
  final bool subscriptionNote;

  const _ResetProgressSheet({
    required this.kind,
    this.subscriptionNote = false,
  });

  @override
  State<_ResetProgressSheet> createState() => _ResetProgressSheetState();
}

class _ResetProgressSheetState extends State<_ResetProgressSheet> {
  static const _waitSeconds = 10;

  Timer? _ticker;
  int _remaining = _waitSeconds;
  bool _aware = false;

  bool get _ready => _remaining == 0 && _aware;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining <= 1) {
        timer.cancel();
        setState(() => _remaining = 0);
        return;
      }
      setState(() => _remaining -= 1);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = AppRoles.risk;
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final kind = widget.kind;
    final deletesAccount = kind == _DangerKind.deleteAccount;
    final (title, subtitle, awareness) = switch (kind) {
      _DangerKind.deleteAccount => (
        l10n.deleteAccountTitle,
        l10n.deleteAccountBody,
        l10n.deleteAccountAwareness,
      ),
      _DangerKind.leaveTrail => (
        l10n.trailsLeaveTitle,
        l10n.trailsLeaveBody,
        l10n.trailsLeaveAwareness,
      ),
      _DangerKind.resetProgress => (
        l10n.resetTitle,
        l10n.resetBody,
        l10n.resetAwareness,
      ),
    };

    return AppSheetPanel(
      tint: accent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(
            center: true,
            leading: const CloudMascot(face: CloudFace.triste, size: 112),
            title: title,
            subtitle: subtitle,
          ),
          if (deletesAccount && widget.subscriptionNote) ...[
            const SizedBox(height: AppSpace.md),
            Text(
              l10n.deleteAccountSubscriptionNote,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 12,
                height: 1.35,
                weight: FontWeight.w600,
                color: a.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpace.lg),
          _AwarenessCheck(
            label: awareness,
            checked: _aware,
            onChanged: (value) {
              ActHaptics.tap();
              setState(() => _aware = value);
            },
          ),
          const SizedBox(height: AppSpace.lg),
          // Fica FilledButton: test/reset_progress_sheet_test.dart procura
          // o tipo para checar o bloqueio. Estilo só com tokens.
          FilledButton(
            onPressed: _ready
                ? () {
                    ActHaptics.error();
                    Navigator.pop(context, true);
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              disabledBackgroundColor: accent.withValues(alpha: 0.28),
              foregroundColor: AppColors.textOnDark,
              disabledForegroundColor: a.textSecondary,
              minimumSize: const Size.fromHeight(CopperCta.height),
              padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            child: Text(
              _remaining > 0
                  ? l10n.resetConfirmCountdown(_remaining)
                  : l10n.resetConfirm,
              style: CopperCta.labelStyle(
                size: 16,
                color: AppColors.textOnDark,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          GhostCta(
            label: l10n.commonCancel,
            expanded: true,
            onTap: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }
}

class _AwarenessCheck extends StatelessWidget {
  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  const _AwarenessCheck({
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    const accent = AppRoles.risk;

    return Semantics(
      checked: checked,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!checked),
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: InsetPanel(
            borderColor: accent.withValues(alpha: checked ? 0.55 : 0.28),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: AppMotion.quick,
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.xs),
                    color: checked ? accent : Colors.transparent,
                    border: Border.all(
                      color: checked ? accent : a.textFaint,
                      width: 1.6,
                    ),
                  ),
                  child: checked
                      ? const CinematicIcon(
                          glyph: CinematicGlyph.check,
                          size: AppMetrics.iconSm,
                          accent: AppColors.textOnDark,
                          framed: false,
                        )
                      : null,
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body(
                      size: 13,
                      height: 1.35,
                      weight: FontWeight.w700,
                      color: a.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
