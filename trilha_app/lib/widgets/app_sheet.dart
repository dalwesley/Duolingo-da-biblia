import 'dart:async';

import 'package:flutter/material.dart';
import '../l10n/app_language.dart';

import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import 'cloud_mascot.dart';
import 'ui_primitives.dart';

/// Sheets e diálogos do app — uma casca só.
///
/// Toda sheet abre com [showAppSheet] e desenha o conteúdo dentro de
/// [AppSheetPanel]: painel flutuante (12 de margem), raio [AppRadii.sheet],
/// alça no topo e véu [AppColors.scrim]. Diálogos usam [AppDialog] ou
/// [showAppConfirm].

Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = false,

  /// Véu sobre a tela. O padrão escurece; passe transparente quando a
  /// página de baixo precisa continuar legível (prévia de papel).
  Color? barrierColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: barrierColor ?? AppColors.scrim,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    constraints: const BoxConstraints(maxWidth: contentMaxWidth),
    builder: builder,
  );
}

/// Painel padrão de sheet.
///
/// [tint] tinge borda e brilho do topo (sheets de celebração, companhia);
/// sem ele, o painel é o card neutro da aparência atual.
class AppSheetPanel extends StatelessWidget {
  final Widget child;
  final Color? tint;
  final EdgeInsetsGeometry padding;
  final bool showGrabber;

  /// Camada atrás do conteúdo (confete, atmosfera), recortada no raio.
  final Widget? background;

  const AppSheetPanel({
    super.key,
    required this.child,
    this.tint,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpace.xl,
      AppSpace.md,
      AppSpace.xl,
      AppSpace.lg,
    ),
    this.showGrabber = true,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final tone = tint;
    final resolved = padding.resolve(Directionality.of(context));

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + keyboard),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.sheet),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              tone == null ? a.cardFill : Color.lerp(a.cardFill, tone, 0.14)!,
              a.cardFill,
            ],
            stops: const [0.0, 0.45],
          ),
          border: Border.all(
            color: tone?.withValues(alpha: 0.55) ?? a.cardBorder,
            width: AppMetrics.cardBorderWidth,
          ),
          boxShadow: AppMetrics.cardShadow(elevated: true),
        ),
        child: Stack(
          children: [
            if (background != null) Positioned.fill(child: background!),
            if (tone != null)
              Positioned(
                left: 32,
                right: 32,
                top: 0,
                child: _Filament(color: tone),
              ),
            Padding(
              padding: resolved.copyWith(bottom: resolved.bottom + bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showGrabber) ...[
                    const Center(child: SheetGrabber()),
                    const SizedBox(height: AppSpace.lg),
                  ],
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alça de arrastar no topo das sheets.
class SheetGrabber extends StatelessWidget {
  const SheetGrabber({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Appearance.of(context).progressTrack,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
    );
  }
}

class _Filament extends StatelessWidget {
  final Color color;

  const _Filament({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            color.withValues(alpha: 0.15),
            color,
            color.withValues(alpha: 0.15),
            Colors.transparent,
          ],
          stops: const [0, 0.18, 0.5, 0.82, 1],
        ),
      ),
    );
  }
}

/// Diálogo padrão — mesmo painel das sheets, centralizado.
///
/// Todo diálogo tem o Anan no topo: [face] escolhe a cara (feliz por
/// padrão; triste nas saídas de risco; erro quando algo falhou). [leading]
/// troca a nuvem por outra marca só quando a própria nuvem já está ali.
class AppDialog extends StatelessWidget {
  final String? title;
  final Widget? leading;
  final CloudFace face;
  final Widget? content;
  final List<Widget> actions;

  const AppDialog({
    super.key,
    this.title,
    this.leading,
    this.face = CloudFace.feliz,
    this.content,
    this.actions = const [],
  }) : assert(title != null || content != null);

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Dialog(
      backgroundColor: a.cardFill,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpace.xxl,
        vertical: AppSpace.xxl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sheet),
        side: BorderSide(
          color: a.cardBorder,
          width: AppMetrics.cardBorderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.xxl,
          AppSpace.xxl,
          AppSpace.xxl,
          AppSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: leading ?? CloudMascot(face: face, size: 96)),
            const SizedBox(height: AppSpace.lg),
            if (title != null)
              Text(
                title!,
                textAlign: TextAlign.center,
                style: AppTypography.title(size: 20, color: a.text),
              ),
            if (content != null) ...[
              if (title != null) const SizedBox(height: AppSpace.sm),
              DefaultTextStyle.merge(
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  height: 1.45,
                  color: a.textMuted(0.8),
                ),
                child: content!,
              ),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSpace.xl),
              Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpace.sm),
                    Expanded(child: actions[i]),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<T?> showAppDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: AppColors.scrim,
    barrierDismissible: barrierDismissible,
    builder: builder,
  );
}

/// Confirmação de duas saídas. [danger] pinta a confirmação de erro e deixa
/// o Anan triste (sair, encerrar, desistir).
/// [confirmDelay]: o botão de confirmar só libera depois desse tempo, com a
/// contagem no rótulo — para ações sérias, contra o toque no impulso.
Future<bool> showAppConfirm(
  BuildContext context, {
  required String title,
  required String body,
  String? cancelLabel,
  required String confirmLabel,
  bool danger = false,
  CloudFace? face,
  Duration confirmDelay = Duration.zero,
}) async {
  final ok = await showAppDialog<bool>(
    context,
    builder: (ctx) => AppDialog(
      face: face ?? (danger ? CloudFace.triste : CloudFace.feliz),
      title: title,
      content: Text(body),
      actions: [
        GhostCta(
          label: cancelLabel ?? ctx.l10n.commonCancel,
          onTap: () => Navigator.pop(ctx, false),
        ),
        _DelayedConfirm(
          delay: confirmDelay,
          builder: (left) {
            final label = left > 0 ? '$confirmLabel ($left)' : confirmLabel;
            final onTap = left > 0 ? null : () => Navigator.pop(ctx, true);
            return danger
                ? GhostCta(label: label, danger: true, onTap: onTap)
                : CopperCta(
                    label: label,
                    dense: true,
                    trailing: null,
                    onTap: onTap,
                  );
          },
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Conta os segundos até liberar o botão de confirmar.
class _DelayedConfirm extends StatefulWidget {
  final Duration delay;
  final Widget Function(int secondsLeft) builder;

  const _DelayedConfirm({required this.delay, required this.builder});

  @override
  State<_DelayedConfirm> createState() => _DelayedConfirmState();
}

class _DelayedConfirmState extends State<_DelayedConfirm> {
  late int _left = widget.delay.inSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (_left <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _left--);
      if (_left <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_left);
}
