import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Confirmação irreversível. O botão só habilita depois de [waitSeconds]
/// e com o aviso de perda de progresso marcado.
Future<bool> showResetProgressSheet(BuildContext context) {
  ActHaptics.confirm();
  return showAppSheet<bool>(
    context,
    builder: (_) => const _ResetProgressSheet(),
  ).then((value) => value == true);
}

class _ResetProgressSheet extends StatefulWidget {
  const _ResetProgressSheet();

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
    const accent = AppColors.error;

    return AppSheetPanel(
      tint: accent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(
            center: true,
            leading: const CinematicIcon(
              glyph: CinematicGlyph.fall,
              size: 52,
              accent: accent,
              glowing: false,
            ),
            title: context.l10n.resetTitle,
            subtitle: context.l10n.resetBody,
          ),
          const SizedBox(height: AppSpace.lg),
          _AwarenessCheck(
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
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
              minimumSize: const Size.fromHeight(CopperCta.height),
              padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            child: Text(
              _remaining > 0
                  ? context.l10n.resetConfirmCountdown(_remaining)
                  : context.l10n.resetConfirm,
              style: CopperCta.labelStyle(size: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          GhostCta(
            label: context.l10n.commonCancel,
            expanded: true,
            onTap: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }
}

class _AwarenessCheck extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;

  const _AwarenessCheck({required this.checked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    const accent = AppColors.error;

    return Semantics(
      checked: checked,
      label: context.l10n.resetAwareness,
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
                  duration: const Duration(milliseconds: 160),
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
                          size: 16,
                          accent: Colors.white,
                          framed: false,
                        )
                      : null,
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(
                    context.l10n.resetAwareness,
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
