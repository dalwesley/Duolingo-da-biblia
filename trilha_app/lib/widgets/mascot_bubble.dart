import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'anan_speech.dart';
import 'cloud_mascot.dart';

/// Recado curto do Anan (celebração): o mesmo balão do resto do app
/// ([AnanSpeech]), com a nuvem menor — a cena já tem o palco grande.
class MascotBubble extends StatelessWidget {
  final String message;
  final CloudFace face;

  const MascotBubble({
    super.key,
    required this.message,
    this.face = CloudFace.sucesso,
  });

  @override
  Widget build(BuildContext context) {
    return AnanSpeech(
      face: face,
      ananSize: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.body(
          size: 14,
          weight: FontWeight.w700,
          height: 1.35,
          color: AnanSpeechBubble.ink,
        ),
      ),
    );
  }
}
