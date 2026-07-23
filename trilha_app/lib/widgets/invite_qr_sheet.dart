import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';

/// Bottom sheet de convite: QR para o presencial, código para a distância.
Future<void> showInviteQrSheet(
  BuildContext context, {
  required String code,
  String title = 'Convidar amigo',
  String? subtitle,
  String? shareMessage,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _InviteQrSheet(
      code: code,
      title: title,
      subtitle: subtitle,
      shareMessage: shareMessage,
    ),
  );
}

class _InviteQrSheet extends StatelessWidget {
  final String code;
  final String title;
  final String? subtitle;
  final String? shareMessage;

  const _InviteQrSheet({
    required this.code,
    required this.title,
    this.subtitle,
    this.shareMessage,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpace.md, 0, AppSpace.md, AppSpace.md),
      padding: EdgeInsets.fromLTRB(
        AppSpace.xxl,
        AppSpace.screen,
        AppSpace.xxl,
        AppSpace.screen + bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.night,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 24,
              weight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            subtitle ?? 'Mostre o QR ou envie o código pelo WhatsApp',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpace.screen),
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: QrImageView(
                data: code,
                version: QrVersions.auto,
                size: 190,
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
            ),
          ),
          const SizedBox(height: AppSpace.screen),
          GestureDetector(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Código copiado')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    code,
                    style: AppTypography.title(
                      size: 22,
                      weight: FontWeight.w900,
                      color: AppColors.accent,
                    ).copyWith(letterSpacing: 6),
                  ),
                  const SizedBox(width: 10),
                  CinematicIcon(
                    glyph: CinematicGlyph.copy,
                    size: 18,
                    accent: Colors.white.withValues(alpha: 0.55),
                    framed: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          GestureDetector(
            onTap: () {
              SharePlus.instance.share(
                ShareParams(
                  text: shareMessage ??
                      'Caminhe comigo no Steway! Use o código $code para entrar.',
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: AppGradients.gold,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CinematicIcon(
                    glyph: CinematicGlyph.share,
                    size: 18,
                    accent: AppColors.inkOnAccent,
                    framed: false,
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Text(
                    'ENVIAR CÓDIGO',
                    style: AppTypography.cta(size: 13).copyWith(letterSpacing: 0.8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
