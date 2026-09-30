import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pilgrim_medals.dart';
import '../models/recognition.dart';
import '../l10n/app_language.dart';
import '../services/backend_service.dart';
import '../services/progress_service.dart';
import '../services/recognition_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
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
    ActHaptics.light();
    final status = await service.give(
      toUid: uid,
      fromName: name,
      kind: kind,
      subjectKey: subjectKey,
    );
    if (!context.mounted) return;
    final l10n = context.l10n;
    final title = switch (status) {
      RecognitionGiveStatus.given =>
        kind == RecognitionKind.medal
            ? l10n.recognitionMedalDone
            : l10n.recognitionSceneDone,
      RecognitionGiveStatus.removed => l10n.recognitionRemoved,
      RecognitionGiveStatus.already =>
        kind == RecognitionKind.medal
            ? l10n.recognitionMedalDone
            : l10n.recognitionSceneDone,
      RecognitionGiveStatus.failed =>
        wasGiven
            ? l10n.recognitionFailedWithdraw
            : l10n.recognitionFailedGive,
    };
    await showAppDialog<void>(
      context,
      builder: (ctx) => AppDialog(
        title: title,
        content: Center(
          child: CinematicIcon(
            glyph: CinematicGlyph.heart,
            size: 36,
            framed: false,
            accent: status == RecognitionGiveStatus.failed
                ? Appearance.of(context).textFaint
                : AppColors.clay,
          ),
        ),
        actions: [
          CopperCta(
            label: ctx.l10n.commonGotIt,
            dense: true,
            trailing: null,
            showGlow: false,
            onTap: () => Navigator.pop(ctx),
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
            child: Center(
              child: CinematicIcon(
                glyph: CinematicGlyph.heart,
                size: 22,
                framed: false,
                accent: given
                    ? AppColors.clay
                    : Appearance.of(context).textFaint,
              ),
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
            context.l10n.recognitionRecognizeScene,
            style: AppTypography.body(
              size: 13,
              color: Appearance.of(context).textFaint,
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
                ? context.l10n.recognitionFailedWithdraw
                : context.l10n.recognitionFailedGive)
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
            context.l10n.recognitionTapToWithdraw,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 12,
              color: Appearance.of(context).textFaint,
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
  ActHaptics.tap();
  return showAppSheet<void>(
    context,
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
                ? context.l10n.recognitionFailedWithdraw
                : context.l10n.recognitionFailedGive)
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;
    final who = recognitionFromName(widget.name);

    return AppSheetPanel(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(
              title: who,
              subtitle: context.l10n.recognitionWhichMedal,
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
                      onTap: _busyId != null ? null : () => _recognize(medal),
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
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: onTap,
          child: InsetPanel(
            borderColor: accent.withValues(alpha: given ? 0.7 : 0.45),
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
                        SectionLabel(
                          family,
                          size: 10,
                          color: accent.withValues(alpha: 0.85),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        medal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title(
                          size: 16,
                          color: given
                              ? Appearance.of(context).textSecondary
                              : Appearance.of(context).text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        given
                            ? context.l10n.recognitionGivenTapWithdraw
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
                if (busy) const AppSpinner(inline: true),
              ],
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
  ActHaptics.light();
  final status = await service.give(
    toUid: toUid,
    fromName: name,
    kind: kind,
    subjectKey: subjectKey,
  );
  if (!context.mounted) return status;
  final l10n = context.l10n;
  final message = switch (status) {
    RecognitionGiveStatus.given =>
      kind == RecognitionKind.medal
          ? l10n.recognitionMedalDone
          : l10n.recognitionSceneDone,
    RecognitionGiveStatus.removed => l10n.recognitionRemoved,
    RecognitionGiveStatus.already => l10n.recognitionAlready,
    RecognitionGiveStatus.failed => l10n.recognitionFailedGive,
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
