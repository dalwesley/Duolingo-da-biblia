import 'package:flutter/material.dart';

import '../data/mission_study.dart';
import '../l10n/app_language.dart';
import '../services/session_composer.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/palco_verse.dart';
import 'act_feel.dart';
import 'evidence_verse.dart';
import 'ui_primitives.dart';

/// Os fatos da placa Hoje. Tocar um fato acende no versículo o trecho que o
/// prova. Usado no fim da cena e ao reabrir o "Hoje:" na revisão da semana.
class TodayFacts extends StatefulWidget {
  final List<StudyFact> facts;
  final String passageRef;
  final String passageText;
  final Color accent;

  const TodayFacts({
    super.key,
    required this.facts,
    required this.accent,
    this.passageRef = '',
    this.passageText = '',
  });

  @override
  State<TodayFacts> createState() => _TodayFactsState();
}

class _TodayFactsState extends State<TodayFacts> {
  int? _active;

  @override
  Widget build(BuildContext context) {
    final facts = widget.facts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(context.l10n.lessonFactsLabel, size: 12),
        const SizedBox(height: AppSpace.sm),
        for (var i = 0; i < facts.length; i++)
          _FactRow(
            text: facts[i].text,
            accent: widget.accent,
            active: _active == i,
            onTap:
                facts[i].evidenceSpan.trim().isEmpty ||
                    widget.passageText.trim().isEmpty
                ? null
                : () {
                    ActHaptics.tap();
                    setState(() => _active = _active == i ? null : i);
                  },
          ),
        AnimatedSize(
          duration: AppMotion.standard,
          curve: AppMotion.enter,
          alignment: Alignment.topCenter,
          child: _evidence(),
        ),
      ],
    );
  }

  Widget _evidence() {
    final i = _active;
    if (i == null || i >= widget.facts.length) return const SizedBox.shrink();
    final span = PalcoVerse.swapDivineName(widget.facts[i].evidenceSpan.trim());
    final verse = SessionComposer.clipFeedbackPassage(
      PalcoVerse.swapDivineName(widget.passageText.trim()),
      hint: span,
      maxWords: 32,
    );
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.sm),
      child: EvidenceVerse(
        key: ValueKey('fact-$i'),
        reference: widget.passageRef.trim(),
        verse: verse,
        accent: AppRoles.presence,
        highlight: span,
        highlightColor: AppRoles.presence,
      ),
    );
  }
}

/// Um fato da placa Hoje. Aceso quando o seu trecho está no versículo.
class _FactRow extends StatelessWidget {
  final String text;
  final Color accent;
  final bool active;
  final VoidCallback? onTap;

  const _FactRow({
    required this.text,
    required this.accent,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 7, right: 10),
              child: AnimatedContainer(
                duration: AppMotion.standard,
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppRoles.presence : accent,
                ),
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: AppTypography.body(
                  size: 15,
                  height: 1.35,
                  weight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? a.text : a.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
