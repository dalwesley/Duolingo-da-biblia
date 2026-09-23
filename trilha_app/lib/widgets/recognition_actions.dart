import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/pilgrim_medals.dart';
import '../models/recognition.dart';
import '../services/backend_service.dart';
import '../services/progress_service.dart';
import '../services/recognition_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'medal_cinematic_widgets.dart';
import 'ui_primitives.dart';

/// Coração — mesmo gesto na caminhada e na medalha.
class RecognizeHeartButton extends StatelessWidget {
  final String? toUid;
  final RecognitionKind kind;
  final String subjectKey;
  final EdgeInsetsGeometry padding;

  const RecognizeHeartButton({
    super.key,
    required this.toUid,
    required this.kind,
    required this.subjectKey,
    this.padding = const EdgeInsets.only(left: 8),
  });

  Future<void> _toggle(BuildContext context) async {
    final uid = toUid;
    if (uid == null || uid.isEmpty) return;
    final service = context.read<RecognitionService>();
    final name = context.read<ProgressService>().userName;
    final wasGiven = service.alreadyGiven(
      toUid: uid,
      kind: kind,
      subjectKey: subjectKey,
    );
    HapticFeedback.lightImpact();
    final status = await service.give(
      toUid: uid,
      fromName: name,
      kind: kind,
      subjectKey: subjectKey,
    );
    if (!context.mounted) return;
    final title = switch (status) {
      RecognitionGiveStatus.given => kind == RecognitionKind.medal
          ? 'Medalha reconhecida'
          : 'Caminhada reconhecida',
      RecognitionGiveStatus.removed => 'Reconhecimento retirado',
      RecognitionGiveStatus.already => kind == RecognitionKind.medal
          ? 'Medalha reconhecida'
          : 'Caminhada reconhecida',
      RecognitionGiveStatus.failed => wasGiven
          ? 'Não foi possível retirar'
          : 'Não foi possível reconhecer',
    };
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.nightElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: AppColors.clay.withValues(alpha: 0.45)),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.title(size: 18, color: Colors.white),
        ),
        content: Icon(
          status == RecognitionGiveStatus.failed
              ? Icons.favorite_border_rounded
              : Icons.favorite_rounded,
          size: 36,
          color: status == RecognitionGiveStatus.failed
              ? Colors.white.withValues(alpha: 0.35)
              : AppColors.clay,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Ok',
              style: AppTypography.body(
                weight: FontWeight.w800,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = toUid;
    final backend = context.watch<BackendService>();
    if (uid == null ||
        uid.isEmpty ||
        !backend.isActive ||
        backend.uid == null ||
        backend.uid == uid) {
      return const SizedBox.shrink();
    }
    if (!Recognition.validSubject(kind, subjectKey)) {
      return const SizedBox.shrink();
    }
    final given = context.watch<RecognitionService>().alreadyGiven(
      toUid: uid,
      kind: kind,
      subjectKey: subjectKey,
    );

    return Padding(
      padding: padding,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggle(context),
          customBorder: const CircleBorder(),
          child: Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: given
                  ? AppColors.clay.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.06),
              border: Border.all(
                color: given
                    ? AppColors.clay.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              given ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 22,
              color: given
                  ? AppColors.clay
                  : Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }
}

/// Um toque na caminhada do companheiro.
class RecognizeCompanionWalk extends StatelessWidget {
  final String? partnerUid;
  final String? walkDate;

  const RecognizeCompanionWalk({
    super.key,
    required this.partnerUid,
    required this.walkDate,
  });

  @override
  Widget build(BuildContext context) {
    final uid = partnerUid;
    final date = walkDate;
    if (uid == null ||
        uid.isEmpty ||
        date == null ||
        !Recognition.validSubject(RecognitionKind.walk, date)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Text(
            'Reconhecer a caminhada',
            style: AppTypography.body(
              size: 13,
              color: Appearance.of(context).textMuted(0.55),
            ),
          ),
          const Spacer(),
          RecognizeHeartButton(
            toUid: uid,
            kind: RecognitionKind.walk,
            subjectKey: date,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class RecognizeTargetButton extends StatefulWidget {
  final String toUid;
  final RecognitionKind kind;
  final String subjectKey;
  final String label;
  final String doneLabel;

  const RecognizeTargetButton({
    super.key,
    required this.toUid,
    required this.kind,
    required this.subjectKey,
    required this.label,
    required this.doneLabel,
  });

  @override
  State<RecognizeTargetButton> createState() => _RecognizeTargetButtonState();
}

class _RecognizeTargetButtonState extends State<RecognizeTargetButton> {
  bool _busy = false;
  String? _error;

  Future<void> _tap() async {
    final wasGiven = context.read<RecognitionService>().alreadyGiven(
      toUid: widget.toUid,
      kind: widget.kind,
      subjectKey: widget.subjectKey,
    );
    setState(() {
      _busy = true;
      _error = null;
    });
    final status = await giveRecognition(
      context,
      toUid: widget.toUid,
      kind: widget.kind,
      subjectKey: widget.subjectKey,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = status == RecognitionGiveStatus.failed
          ? (wasGiven
              ? 'Não foi possível retirar'
              : 'Não foi possível reconhecer')
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final given = context.watch<RecognitionService>().alreadyGiven(
      toUid: widget.toUid,
      kind: widget.kind,
      subjectKey: widget.subjectKey,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CopperCta(
          label: given ? widget.doneLabel : widget.label,
          leading: given ? CinematicGlyph.check : CinematicGlyph.heart,
          trailing: null,
          dense: true,
          busy: _busy,
          onTap: _busy ? null : _tap,
        ),
        if (given && !_busy) ...[
          const SizedBox(height: 6),
          Text(
            'Toque de novo para retirar',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 12,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              weight: FontWeight.w700,
              color: AppColors.clay,
            ),
          ),
        ],
      ],
    );
  }
}

Future<void> showRecognizeMedalSheet(
  BuildContext context, {
  required String toUid,
  required String name,
  required List<RecognizableMedal> medals,
}) {
  HapticFeedback.selectionClick();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    isScrollControlled: true,
    builder: (ctx) =>
        _MedalRecognizeSheet(toUid: toUid, name: name, medals: medals),
  );
}

class _MedalRecognizeSheet extends StatefulWidget {
  final String toUid;
  final String name;
  final List<RecognizableMedal> medals;

  const _MedalRecognizeSheet({
    required this.toUid,
    required this.name,
    required this.medals,
  });

  @override
  State<_MedalRecognizeSheet> createState() => _MedalRecognizeSheetState();
}

class _MedalRecognizeSheetState extends State<_MedalRecognizeSheet> {
  String? _error;
  String? _busyId;

  Future<void> _recognize(RecognizableMedal medal) async {
    final wasGiven = context.read<RecognitionService>().alreadyGiven(
      toUid: widget.toUid,
      kind: RecognitionKind.medal,
      subjectKey: medal.id,
    );
    setState(() {
      _busyId = medal.id;
      _error = null;
    });
    final status = await giveRecognition(
      context,
      toUid: widget.toUid,
      kind: RecognitionKind.medal,
      subjectKey: medal.id,
    );
    if (!mounted) return;
    setState(() {
      _busyId = null;
      _error = status == RecognitionGiveStatus.failed
          ? (wasGiven
              ? 'Não foi possível retirar'
              : 'Não foi possível reconhecer')
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;
    final who = recognitionFromName(widget.name);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.nightElevated,
              AppColors.night,
              AppColors.nightMid,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                who,
                style: AppTypography.title(size: 20, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                'Qual medalha você viu?',
                style: AppTypography.body(
                  size: 13,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: AppTypography.body(
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.clay,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final medal in widget.medals)
                      _MedalRecognizeRow(
                        medal: medal,
                        given: context.watch<RecognitionService>().alreadyGiven(
                          toUid: widget.toUid,
                          kind: RecognitionKind.medal,
                          subjectKey: medal.id,
                        ),
                        busy: _busyId == medal.id,
                        onTap: _busyId != null
                            ? null
                            : () => _recognize(medal),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedalRecognizeRow extends StatelessWidget {
  final RecognizableMedal medal;
  final bool given;
  final bool busy;
  final VoidCallback? onTap;

  const _MedalRecognizeRow({
    required this.medal,
    required this.given,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = given ? AppColors.accent : tierColor(medal.tier);
    final family = medal.group?.trim() ?? '';
    final tile = PilgrimMedalTile(
      id: medal.id,
      title: medal.title,
      hint: '',
      glyph: given ? CinematicGlyph.check : medal.glyph,
      tier: medal.tier,
      unlocked: true,
      groupLabel: medal.group,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: AppColors.nightElevated,
              border: Border.all(
                color: accent.withValues(alpha: given ? 0.7 : 0.45),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
              child: Row(
                children: [
                  MedalVaultMedallion(tile: tile, size: 64),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (family.isNotEmpty && family != medal.title) ...[
                          Text(
                            family.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label(
                              size: 10,
                              letterSpacing: 1.1,
                              color: accent.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          medal.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.title(
                            size: 17,
                            color: Colors.white.withValues(
                              alpha: given ? 0.75 : 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          given
                              ? 'Reconhecida · toque para retirar'
                              : tierLabel(medal.tier),
                          style: AppTypography.body(
                            size: 13,
                            weight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (busy)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<RecognitionGiveStatus> giveRecognition(
  BuildContext context, {
  required String toUid,
  required RecognitionKind kind,
  required String subjectKey,
}) async {
  final service = context.read<RecognitionService>();
  final name = context.read<ProgressService>().userName;
  HapticFeedback.lightImpact();
  final status = await service.give(
    toUid: toUid,
    fromName: name,
    kind: kind,
    subjectKey: subjectKey,
  );
  if (!context.mounted) return status;
  final message = switch (status) {
    RecognitionGiveStatus.given =>
      kind == RecognitionKind.medal
          ? 'Medalha reconhecida'
          : 'Caminhada reconhecida',
    RecognitionGiveStatus.removed =>
      kind == RecognitionKind.medal
          ? 'Reconhecimento retirado'
          : 'Caminhada retirada',
    RecognitionGiveStatus.already => 'Você já reconheceu',
    RecognitionGiveStatus.failed => 'Não foi possível reconhecer',
  };
  showAppToastFor(
    context,
    message: message,
    glyph: status == RecognitionGiveStatus.failed
        ? CinematicGlyph.spark
        : CinematicGlyph.check,
    tone: status == RecognitionGiveStatus.failed
        ? AppToastTone.warn
        : AppToastTone.accent,
  );
  return status;
}
