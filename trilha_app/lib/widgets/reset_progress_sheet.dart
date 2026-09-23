import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Confirmação irreversível. O botão só habilita depois de [waitSeconds]
/// e com o aviso de perda de progresso marcado.
Future<bool> showResetProgressSheet(BuildContext context) {
  HapticFeedback.mediumImpact();
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
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
    final a = Appearance.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    const accent = AppColors.error;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: CinematicIcon(
              glyph: CinematicGlyph.fall,
              size: 52,
              accent: accent,
              glowing: false,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Resetar progresso',
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 20, color: a.text),
          ),
          const SizedBox(height: 8),
          Text(
            'Todos os passos, dias caminhando e progresso serão apagados. A introdução volta a aparecer. Não dá para desfazer.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              height: 1.4,
              weight: FontWeight.w600,
              color: a.textMuted(0.78),
            ),
          ),
          const SizedBox(height: 16),
          _AwarenessCheck(
            checked: _aware,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() => _aware = value);
            },
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _ready
                ? () {
                    HapticFeedback.heavyImpact();
                    Navigator.pop(context, true);
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              disabledBackgroundColor: accent.withValues(alpha: 0.28),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            child: Text(
              _remaining > 0 ? 'Confirmar · ${_remaining}s' : 'Confirmar',
              style: AppTypography.cta(size: 14, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: AppTypography.title(
                size: 13,
                weight: FontWeight.w700,
                color: a.textMuted(0.7),
              ),
            ),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!checked),
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            color: accent.withValues(alpha: checked ? 0.14 : 0.06),
            border: Border.all(
              color: accent.withValues(alpha: checked ? 0.55 : 0.28),
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: checked ? accent : Colors.transparent,
                  border: Border.all(
                    color: checked ? accent : a.textMuted(0.45),
                    width: 1.6,
                  ),
                ),
                child: checked
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Estou ciente de que vou perder o progresso',
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
    );
  }
}
