import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../data/entry_trails.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';
import 'stway_brand.dart';

/// Carta do encontro — verso no centro, marca pequena. Não é um ícone gigante.
class ShareSealCard extends StatelessWidget {
  final CharacterSeal seal;

  const ShareSealCard({super.key, required this.seal});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 280, minWidth: 280),
        child: Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(color: AppColors.primaryDark),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.32,
                child: Image.asset(
                  'assets/icon/splash_bg.png',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.12),
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: AppColors.primaryDark),
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
                      Colors.black.withValues(alpha: 0.4),
                    ],
                    stops: const [0, 0.45, 1],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const StwayLogo(size: 26),
                      const SizedBox(width: 10),
                      StwayWordmark(
                        fontSize: 14,
                        letterSpacing: 2.2,
                        letterColor: Colors.white.withValues(alpha: 0.95),
                        aColor: AppColors.accent,
                      ),
                      const Spacer(),
                      CinematicIcon(
                        glyph: seal.glyph,
                        size: 18,
                        accent: AppColors.accent,
                        framed: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    seal.name.toUpperCase(),
                    style: AppTypography.label(
                      size: 11,
                      letterSpacing: 2.2,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    seal.verseText,
                    style: AppTypography.verse(
                      size: 20,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.96),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    seal.verseRef,
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
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

Future<void> shareSealImage({
  required GlobalKey boundaryKey,
  required CharacterSeal seal,
}) async {
  HapticFeedback.lightImpact();
  await Future<void>.delayed(const Duration(milliseconds: 50));
  await WidgetsBinding.instance.endOfFrame;
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    await SharePlus.instance.share(
      ShareParams(
        text: _sealShareText(seal),
        subject: '${seal.name} — Stway',
      ),
    );
    return;
  }
  final image = await boundary.toImage(pixelRatio: 3);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) return;
  final safe = seal.id.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  final file = File('${Directory.systemTemp.path}/stway_$safe.png');
  await file.writeAsBytes(bytes.buffer.asUint8List());
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'image/png')],
      text: _sealShareText(seal),
      subject: '${seal.name} — Stway',
    ),
  );
}

String _sealShareText(CharacterSeal seal) {
  return '''
“${seal.verseText}”

— ${seal.verseRef}
Encontrei ${seal.name} no Stway.
'''
      .trim();
}
