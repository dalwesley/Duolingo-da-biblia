import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/backend_service.dart';
import '../services/progress_service.dart';
import 'crossing_burst.dart';

/// Animação da travessia com o meu retrato e o da outra pessoa.
Future<void> showCornerBurst(
  BuildContext context, {
  required String peerName,
  String? peerPhoto,
  String? caption,
  String? kicker,
  CrossingMode mode = CrossingMode.start,
}) {
  final backend = context.read<BackendService>();
  final progress = context.read<ProgressService>();
  return showCrossingBurst(
    context,
    me: CrossingPerson(
      name: progress.userName,
      photoUrl: backend.userPhotoUrl,
      seed: backend.uid,
    ),
    them: CrossingPerson(name: peerName, photoUrl: peerPhoto, seed: peerName),
    portrait: progress.settings.portraitStyle,
    caption: caption,
    kicker: kicker,
    mode: mode,
  );
}
