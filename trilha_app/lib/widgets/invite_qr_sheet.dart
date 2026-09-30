import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_language.dart';
import '../services/app_update_service.dart';
import '../services/invite_deep_link_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';
import 'stway_brand.dart';

/// Código de convite — um tratamento só (sheet, preview, imagem): display
/// espaçado em [AppearanceStyle.text]. Amarelo fica para o CTA.
TextStyle inviteCodeStyle(AppearanceStyle a, {double size = 24}) =>
    AppTypography.display(
      size: size,
      weight: FontWeight.w900,
      color: a.text,
    ).copyWith(letterSpacing: 4);

/// Bottom sheet de convite: QR presencial, card visual + código à distância.
Future<void> showInviteQrSheet(
  BuildContext context, {
  required String code,
  String? title,
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
  final String? title;
  final String? subtitle;
  final String? shareMessage;
  final String? inviterName;
  final bool companionMode;

  const _InviteQrSheet({
    required this.code,
    this.title,
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
    return n.isEmpty ? context.l10n.inviteSomeone : n;
  }

  String get _installUrl => AppUpdateService.androidStoreUrl;

  String get _inviteLink => widget.companionMode
      ? InviteDeepLinkService.companionUri(widget.code)
      : InviteDeepLinkService.roomHttpsUrl(widget.code);

  String get _defaultShareText {
    if (!widget.companionMode) {
      return widget.shareMessage ??
          context.l10n.inviteRoomShareText(widget.code, _installUrl);
    }
    return context.l10n
        .inviteCompanionShareText(_name, _inviteLink, _installUrl)
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
      message: context.l10n.inviteCodeCopied,
      glyph: CinematicGlyph.copy,
    );
  }

  Future<void> _shareInvite() async {
    if (_busy) return;
    setState(() => _busy = true);
    final text = widget.shareMessage ?? _defaultShareText;
    final subject = context.l10n.inviteShareSubject;
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
      await SharePlus.instance.share(
        ShareParams(
          files: imageFile == null ? null : [imageFile],
          text: text,
          subject: subject,
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
                title: widget.title ?? context.l10n.inviteReadyTitle,
                subtitle:
                    widget.subtitle ??
                    (widget.companionMode
                        ? context.l10n.inviteSheetSubtitleCompanion
                        : context.l10n.inviteSheetSubtitleRoom),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.code, style: inviteCodeStyle(a)),
                      const SizedBox(width: 8),
                      CinematicIcon(
                        glyph: CinematicGlyph.copy,
                        size: AppMetrics.iconSm,
                        accent: a.textFaint,
                        framed: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CopperCta(
                label: _busy
                    ? context.l10n.invitePreparing
                    : context.l10n.inviteShareCta,
                onTap: _busy ? null : _shareInvite,
                leading: CinematicGlyph.share,
                trailing: null,
                dense: true,
                busy: _busy,
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.inviteLinkHint,
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
                border: Border.all(color: a.cardBorder),
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
                        letterColor: a.text,
                        aColor: AppColors.accent,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    context.l10n.inviteCardHeadline,
                    style: AppTypography.display(size: 18, color: a.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.inviteCalledYou(inviterName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(size: 11, color: a.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(code, style: inviteCodeStyle(a, size: 18)),
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
    final a = Appearance.of(context);
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
                  border: Border.all(color: a.cardBorder),
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
                        letterColor: a.text,
                        aColor: AppColors.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    headline ?? context.l10n.inviteCardHeadline,
                    style: AppTypography.display(size: 28, color: a.text)
                        .copyWith(
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
                    context.l10n.inviteCardBody(inviterName),
                    style: AppTypography.body(
                      size: 14,
                      height: 1.4,
                      color: a.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: InsetPanel(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          SectionLabel(context.l10n.inviteCodeHint),
                          const SizedBox(height: 6),
                          Text(code, style: inviteCodeStyle(a)),
                        ],
                      ),
                    ),
                  ),
                  if (installHint) ...[
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.inviteCardInstallHint,
                      style: AppTypography.body(
                        size: 11,
                        height: 1.4,
                        color: a.textFaint,
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
