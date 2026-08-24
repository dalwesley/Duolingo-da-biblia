import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/network_reachability.dart';
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
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.72),
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

class _OfflineCurriculumDialogState extends State<_OfflineCurriculumDialog>
    with SingleTickerProviderStateMixin {
  bool _busy = false;
  String? _hint;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

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
          ? 'Ainda não deu para baixar as missões. Toque de novo em instantes.'
          : 'Sem internet no momento. Ligue o Wi‑Fi ou os dados e tente de novo.';
    });
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final accent = AppColors.ember;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: PopScope(
        canPop: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
          decoration: BoxDecoration(
            color: Color.lerp(a.cardFill, accent, 0.06),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
            boxShadow: AppTheme.cardShadow(elevated: true),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) {
                  final t = _pulse.value;
                  return Transform.scale(
                    scale: 0.96 + 0.04 * t,
                    child: Opacity(
                      opacity: 0.82 + 0.18 * t,
                      child: child,
                    ),
                  );
                },
                child: const _DisconnectedTrailIcon(size: 88),
              ),
              const SizedBox(height: 18),
              Text(
                'Missões ainda não chegaram',
                textAlign: TextAlign.center,
                style: AppTypography.title(size: 20, color: a.text),
              ),
              const SizedBox(height: 10),
              Text(
                'Na primeira abertura o STWAY baixa o currículo da nuvem. Precisa de internet uma vez — depois fica no aparelho.',
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  size: 14,
                  height: 1.4,
                  weight: FontWeight.w600,
                  color: a.textMuted(0.72),
                ),
              ),
              if (_hint != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: accent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _hint!,
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.errorSoft,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              CopperCta(
                label: _busy ? 'Baixando…' : 'Tentar de novo',
                onTap: _busy ? null : _retry,
                showArrow: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ícone: trilha que se parte no meio + sinal cortado (desconectado).
class _DisconnectedTrailIcon extends StatelessWidget {
  final double size;

  const _DisconnectedTrailIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DisconnectedTrailPainter()),
    );
  }
}

class _DisconnectedTrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(size.width / 2, size.height / 2);
    final ink = AppColors.ember;
    final soft = ink.withValues(alpha: 0.35);
    final mute = Colors.white.withValues(alpha: 0.22);

    canvas.drawCircle(
      c,
      s * 0.46,
      Paint()
        ..color = ink.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      c,
      s * 0.46,
      Paint()
        ..color = ink.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.018,
    );

    final arcPaint = Paint()
      ..color = soft
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.04
      ..strokeCap = StrokeCap.round;

    for (final r in [0.18, 0.28, 0.38]) {
      canvas.drawArc(
        Rect.fromCircle(center: c.translate(0, s * 0.06), radius: s * r),
        -2.35,
        1.55,
        false,
        arcPaint,
      );
    }

    final pathPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final left = Path()
      ..moveTo(c.dx - s * 0.32, c.dy + s * 0.22)
      ..quadraticBezierTo(
        c.dx - s * 0.18,
        c.dy + s * 0.02,
        c.dx - s * 0.08,
        c.dy + s * 0.08,
      );
    final right = Path()
      ..moveTo(c.dx + s * 0.08, c.dy + s * 0.08)
      ..quadraticBezierTo(
        c.dx + s * 0.18,
        c.dy + s * 0.14,
        c.dx + s * 0.32,
        c.dy - s * 0.02,
      );
    canvas.drawPath(left, pathPaint);
    canvas.drawPath(right, pathPaint);

    final node = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(Offset(c.dx - s * 0.32, c.dy + s * 0.22), s * 0.045, node);
    canvas.drawCircle(Offset(c.dx + s * 0.32, c.dy - s * 0.02), s * 0.045, node);

    final gapCenter = Offset(c.dx, c.dy + s * 0.06);
    canvas.drawCircle(
      gapCenter,
      s * 0.09,
      Paint()..color = AppColors.nightElevated,
    );
    canvas.drawCircle(
      gapCenter,
      s * 0.09,
      Paint()
        ..color = ink.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.02,
    );

    final slash = Paint()
      ..color = ink
      ..strokeWidth = s * 0.045
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      gapCenter + Offset(-s * 0.045, -s * 0.045),
      gapCenter + Offset(s * 0.045, s * 0.045),
      slash,
    );
    canvas.drawLine(
      gapCenter + Offset(s * 0.045, -s * 0.045),
      gapCenter + Offset(-s * 0.045, s * 0.045),
      slash,
    );

    canvas.drawCircle(
      gapCenter + Offset(-s * 0.14, -s * 0.1),
      s * 0.018,
      Paint()..color = mute,
    );
    canvas.drawCircle(
      gapCenter + Offset(s * 0.15, s * 0.12),
      s * 0.015,
      Paint()..color = mute,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
