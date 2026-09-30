import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/corner_challenge.dart';
import '../services/corner_service.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'corner_burst.dart';
import 'crossing_burst.dart';
import 'ui_primitives.dart';

/// Confirma a saída da travessia e apaga a minha luz.
Future<void> confirmCornerWithdraw(
  BuildContext context, {
  required CornerChallenge challenge,
  required String myUid,
}) async {
  final ok = await showAppConfirm(
    context,
    title: CornerCopy.withdrawTitle,
    body: CornerCopy.withdrawBody(
      challenge.peerName(myUid),
      pending: challenge.status == CornerStatus.pending,
    ),
    cancelLabel: CornerCopy.withdrawKeep,
    confirmLabel: CornerCopy.withdrawConfirm,
    danger: true,
  );
  if (!ok || !context.mounted) return;
  final corners = context.read<CornerService>();
  final messenger = ScaffoldMessenger.maybeOf(context);
  // Deixa o diálogo terminar de fechar antes da animação entrar.
  await Future<void>.delayed(const Duration(milliseconds: 220));
  if (!context.mounted) return;
  // Convite ainda não aceito: só some, sem a cena da luz apagando.
  if (challenge.status == CornerStatus.active) {
    await showCornerBurst(
      context,
      peerName: challenge.peerName(myUid),
      peerPhoto: challenge.peerPhoto(myUid),
      caption: CornerCopy.burstLeft,
      kicker: challenge.missionTitle,
      mode: CrossingMode.leave,
    );
  }
  final done = await corners.withdraw(challenge.id);
  if (!done) {
    if (messenger != null) {
      showAppToast(
        messenger,
        message: corners.lastError ?? CornerCopy.actionFailed,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
    }
  }
}
