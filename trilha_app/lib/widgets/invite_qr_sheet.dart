import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../services/app_update_service.dart';
import '../services/invite_deep_link_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';
import 'stway_brand.dart';

/// Bottom sheet de convite: QR presencial, card visual + código à distância.
Future<void> showInviteQrSheet(
  BuildContext context, {
  required String code,
  String title = 'Seu convite está pronto',
  String? subtitle,
  String? shareMessage,
  String? inviterName,
  bool companionMode = true,
}) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => _InviteQrSheet(
      code: code,
      title: title,
      subtitle: subtitle,
      shareMessage: shareMessage,
      inviterName: inviterName,
      companionMode: companionMode,
    ),
  );
}

class _InviteQrSheet extends StatefulWidget {
  final String code;
  final String title;
  final String? subtitle;
  final String? shareMessage;
  final String? inviterName;
  final bool companionMode;

  const _InviteQrSheet({
    required this.code,
    required this.title,
    this.subtitle,
    this.shareMessage,
    this.inviterName,
    required this.companionMode,
  });

  @override
  State<_InviteQrSheet> createState() => _InviteQrSheetState();
}

class _InviteQrSheetState extends State<_InviteQrSheet> {
  final _boundaryKey = GlobalKey();
  bool _busy = false;

  String get _name {
    final n = widget.inviterName?.trim() ?? '';
    return n.isEmpty ? 'Alguém' : n;
  }

  String get _installUrl => AppUpdateService.androidStoreUrl;

  String get _inviteLink => widget.companionMode
      ? InviteDeepLinkService.companionUri(widget.code)
      : InviteDeepLinkService.roomHttpsUrl(widget.code);

  String get _defaultShareText {
    if (!widget.companionMode) {
      return widget.shareMessage ??
          'Entre no Stway com o código ${widget.code}.\n\n'
              'Ainda não tem o app? Baixe: $_installUrl';
    }
    return '''
$_name te convidou a caminhar junto no Stway.
Sem disputa — só presença.

Toque para aceitar (já tem o app):
$_inviteLink

Ainda não tem o Stway? Baixe e toque no link de novo:
$_installUrl
'''
        .trim();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(const AssetImage('assets/icon/splash_bg.png'), context);
      precacheImage(const AssetImage('assets/icon/app_icon.png'), context);
    });
  }

  Future<void> _copyCode() async {
    ActHaptics.tap();
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    showAppToastFor(
      context,
      message: 'Código copiado',
      glyph: CinematicGlyph.copy,
    );
  }

  Future<void> _shareInvite() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      XFile? imageFile;
      if (widget.companionMode) {
        await Future<void>.delayed(const Duration(milliseconds: 40));
        await WidgetsBinding.instance.endOfFrame;
        final boundary =
            _boundaryKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;
        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: 3);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          if (bytes != null) {
            final file = File(
              '${Directory.systemTemp.path}/stway_convite_${widget.code}.png',
            );
            await file.writeAsBytes(bytes.buffer.asUint8List());
            imageFile = XFile(file.path, mimeType: 'image/png');
          }
        }
      }
      final text = widget.shareMessage ?? _defaultShareText;
      await SharePlus.instance.share(
        ShareParams(
          files: imageFile == null ? null : [imageFile],
          text: text,
          subject: 'Convite Stway — caminhem juntos',
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _qr({required double size}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: QrImageView(
        data: _inviteLink,
        version: QrVersions.auto,
        size: size,
        gapless: true,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.circle,
          color: AppColors.nightLight,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.circle,
          color: AppColors.nightLight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Card rico só para o share (Opacity 0 ainda pinta → toImage funciona).
        if (widget.companionMode)
          Positioned(
            left: 0,
            top: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0,
                child: SizedBox(
                  width: 360,
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: InviteShareCard(
                      code: widget.code,
                      inviterName: _name,
                      installHint: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        AppSheetPanel(
          tint: AppColors.accent,
          padding: const EdgeInsets.fromLTRB(
            AppSpace.lg,
            AppSpace.md,
            AppSpace.lg,
            14,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSheetHeader(
                title: widget.title,
                subtitle:
                    widget.subtitle ??
                    (widget.companionMode
                        ? 'Toque no link, mostre o QR ou envie o card'
                        : 'Mostre o QR ou envie o código'),
                center: true,
              ),
              const SizedBox(height: 14),
              if (widget.companionMode)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _InvitePreviewTile(
                        code: widget.code,
                        inviterName: _name,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _qr(size: 108),
                  ],
                )
              else
                Center(child: _qr(size: 168)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _copyCode,
                child: InsetPanel(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  borderColor: AppColors.accent.withValues(alpha: 0.4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.code,
                        style: AppTypography.title(
                          size: 20,
                          weight: FontWeight.w900,
                          color: AppColors.accent,
                        ).copyWith(letterSpacing: 5),
                      ),
                      const SizedBox(width: 8),
                      CinematicIcon(
                        glyph: CinematicGlyph.copy,
                        size: 16,
                        accent: a.textFaint,
                        framed: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CopperCta(
                label: _busy ? 'Preparando…' : 'Enviar convite',
                onTap: _busy ? null : _shareInvite,
                leading: CinematicGlyph.share,
                trailing: null,
                dense: true,
                busy: _busy,
              ),
              const SizedBox(height: 6),
              Text(
                'O link abre o app e aceita sem digitar o código',
                textAlign: TextAlign.center,
                style: AppTypography.body(size: 11, color: a.textFaint),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Preview compacto na sheet (sem scroll).
class _InvitePreviewTile extends StatelessWidget {
  final String code;
  final String inviterName;

  const _InvitePreviewTile({required this.code, required this.inviterName});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: SizedBox(
        height: 124,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.primaryDark),
            Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/icon/splash_bg.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.15),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.55),
                ),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const StwayLogo(size: 20),
                      const SizedBox(width: 6),
                      StwayWordmark(
                        fontSize: 11,
                        letterSpacing: 1.6,
                        letterColor: Colors.white.withValues(alpha: 0.95),
                        aColor: AppColors.accent,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Andem juntos',
                    style: AppTypography.display(
                      size: 16,
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$inviterName te convidou',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(size: 11, color: a.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    code,
                    style: AppTypography.title(
                      size: 16,
                      weight: FontWeight.w900,
                      color: AppColors.accent,
                    ).copyWith(letterSpacing: 3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card visual do convite — vai na imagem compartilhada.
class InviteShareCard extends StatelessWidget {
  final String code;
  final String inviterName;
  final String? headline;
  final bool installHint;

  const InviteShareCard({
    super.key,
    required this.code,
    required this.inviterName,
    this.headline,
    this.installHint = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 280),
        child: Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(color: AppColors.primaryDark),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.42,
                child: Image.asset(
                  'assets/icon/splash_bg.png',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.1),
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.28),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0, 0.4, 1],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const StwayLogo(size: 30),
                      const SizedBox(width: 10),
                      StwayWordmark(
                        fontSize: 15,
                        letterSpacing: 2.4,
                        letterColor: Colors.white.withValues(alpha: 0.95),
                        aColor: AppColors.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    headline ?? 'Andem juntos',
                    style:
                        AppTypography.display(
                          size: 28,
                          weight: FontWeight.w800,
                          color: Colors.white,
                        ).copyWith(
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$inviterName te convidou a caminhar — sem disputa, só presença.',
                    style: AppTypography.body(
                      size: 14,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Column(
                      children: [
                        SectionLabel(
                          'Código',
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          code,
                          style: AppTypography.title(
                            size: 24,
                            weight: FontWeight.w900,
                            color: AppColors.accent,
                          ).copyWith(letterSpacing: 8),
                        ),
                      ],
                    ),
                  ),
                  if (installHint) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Já tem o app? Toque no link do convite.\nAinda não? Baixe o Stway e toque de novo.',
                      style: AppTypography.body(
                        size: 11,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
