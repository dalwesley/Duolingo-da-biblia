import 'package:flutter/material.dart';
import '../data/mission_study.dart';
import '../screens/bible_screen.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';
import 'verse_study_sheet.dart';

/// Preparo curto antes das perguntas — contexto + passagem, sem rito longo.
class StudyPanel extends StatefulWidget {
  final MissionStudy study;
  final Color accent;
  final VoidCallback onContinue;
  final String? priorReflection;
  final String? missionIntro;

  const StudyPanel({
    super.key,
    required this.study,
    required this.accent,
    required this.onContinue,
    this.priorReflection,
    this.missionIntro,
  });

  @override
  State<StudyPanel> createState() => _StudyPanelState();
}

class _StudyPanelState extends State<StudyPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  void _openBible() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BibleReaderScreen(reference: widget.study.passageRef),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final study = widget.study;
    final accent = widget.accent;
    final intro = widget.missionIntro?.trim();

    return FadeTransition(
      opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpace.screen,
          AppSpace.sm,
          AppSpace.screen,
          28,
        ),
        children: [
          Text(
            'ESTUDO',
            textAlign: TextAlign.center,
            style: AppTypography.label(
              size: 11,
              weight: FontWeight.w900,
              letterSpacing: 2,
              color: accent.withValues(alpha: 0.95),
            ),
          ),
          if (intro != null && intro.isNotEmpty) ...[
            const SizedBox(height: AppSpace.sm),
            Text(
              intro,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 14,
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
          ],
          const SizedBox(height: AppSpace.xxl),

          // Passagem
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.screen,
              22,
              AppSpace.screen,
              AppSpace.screen,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Column(
              children: [
                Text(
                  study.passageRef,
                  textAlign: TextAlign.center,
                  style: AppTypography.title(
                    size: 22,
                    weight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                if (study.focusQuestion.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    study.focusQuestion,
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      size: 13,
                      weight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.65),
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpace.section),
                Text(
                  '"${study.passageText}"',
                  textAlign: TextAlign.center,
                  style: AppTypography.verse(
                    size: 18,
                    weight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StudyAction(
                        label: 'Ler na Bíblia',
                        glyph: CinematicGlyph.book,
                        accent: accent,
                        filled: true,
                        onTap: _openBible,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StudyAction(
                        label: 'Estudar',
                        glyph: CinematicGlyph.scroll,
                        accent: accent,
                        filled: false,
                        onTap: () => showVerseStudyFromReference(
                          context,
                          study.passageRef,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (study.context.isNotEmpty) ...[
            const SizedBox(height: AppSpace.section),
            Text(
              study.context,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 14,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],

          if (study.keyword.isNotEmpty) ...[
            const SizedBox(height: AppSpace.section),
            Container(
              padding: const EdgeInsets.all(AppSpace.section),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.22),
                    accent.withValues(alpha: 0.06),
                  ],
                ),
                border: Border.all(color: accent.withValues(alpha: 0.35)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CinematicIcon(
                    glyph: CinematicGlyph.book,
                    size: 28,
                    accent: accent,
                    glowing: false,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DICA DE LEITURA',
                          style: AppTypography.label(
                            size: 10,
                            weight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: AppSpace.xs),
                        Text(
                          study.keyword,
                          style: AppTypography.display(
                            size: 20,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (study.keywordGloss.isNotEmpty) ...[
                          const SizedBox(height: AppSpace.xs),
                          Text(
                            study.keywordGloss,
                            style: AppTypography.body(
                              size: 13,
                              height: 1.35,
                              color: Colors.white.withValues(alpha: 0.78),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (widget.priorReflection != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Text(
                'Sua anotação anterior: “${widget.priorReflection}”',
                style: AppTypography.body(
                  size: 13,
                  color: Colors.white.withValues(alpha: 0.65),
                ).copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],

          const SizedBox(height: 22),
          GestureDetector(
            onTap: widget.onContinue,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                gradient: AppGradients.gold,
                borderRadius: BorderRadius.circular(AppRadii.md),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                'COMEÇAR',
                textAlign: TextAlign.center,
                style: AppTypography.cta().copyWith(letterSpacing: 0.8),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Text(
            'Leia o trecho quando puder — a passagem contextualiza as respostas.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 11,
              height: 1.35,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyAction extends StatelessWidget {
  final String label;
  final CinematicGlyph glyph;
  final Color accent;
  final bool filled;
  final VoidCallback onTap;

  const _StudyAction({
    required this.label,
    required this.glyph,
    required this.accent,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: filled
                ? accent.withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.28),
            width: 1.5,
          ),
          color: filled
              ? accent.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.06),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CinematicIcon(
              glyph: glyph,
              size: 16,
              accent: filled ? accent : Colors.white.withValues(alpha: 0.9),
              framed: false,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(
                  size: 12,
                  weight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: filled ? accent : Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Consolidação pós-missão — opcional, bônus de retenção.
class ReflectionPanel extends StatefulWidget {
  final MissionStudy study;
  final Color accent;
  final int correct;
  final int total;
  final ValueChanged<String> onFinish;
  final VoidCallback onSkip;

  const ReflectionPanel({
    super.key,
    required this.study,
    required this.accent,
    required this.correct,
    required this.total,
    required this.onFinish,
    required this.onSkip,
  });

  @override
  State<ReflectionPanel> createState() => _ReflectionPanelState();
}

class _ReflectionPanelState extends State<ReflectionPanel> {
  String? _selected;
  final _custom = TextEditingController();

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _submit() {
    final text = (_selected ?? _custom.text).trim();
    if (text.isEmpty) return;
    widget.onFinish(text);
  }

  @override
  Widget build(BuildContext context) {
    final study = widget.study;
    final accent = widget.accent;
    final pct = widget.total > 0
        ? ((widget.correct / widget.total) * 100).round()
        : 0;
    final canSubmit =
        (_selected != null && _selected!.isNotEmpty) ||
        _custom.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        AppSpace.sm,
        AppSpace.screen,
        AppSpace.section,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Fixar o que\nvocê aprendeu',
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 28,
              weight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            '$pct% de clareza · opcional · +passos se guardar',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            study.focusQuestion,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...study.reflectionPrompts.map((p) {
                  final selected = _selected == p;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selected = p;
                        _custom.clear();
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? accent.withValues(alpha: 0.22)
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          border: Border.all(
                            color: selected
                                ? accent
                                : Colors.white.withValues(alpha: 0.12),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          p,
                          style: AppTypography.body(
                            size: 14,
                            weight: FontWeight.w700,
                            color: Colors.white.withValues(
                              alpha: selected ? 1 : 0.85,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                TextField(
                  controller: _custom,
                  onChanged: (_) => setState(() => _selected = null),
                  maxLines: 2,
                  style: AppTypography.body(
                    color: Colors.white,
                    weight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ou escreva com suas palavras…',
                    hintStyle: AppTypography.body(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      borderSide: BorderSide(color: accent, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Opacity(
                  opacity: canSubmit ? 1 : 0.45,
                  child: GestureDetector(
                    onTap: canSubmit ? _submit : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppGradients.gold,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        boxShadow: canSubmit
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        'GUARDAR E CONTINUAR',
                        textAlign: TextAlign.center,
                        style: AppTypography.cta().copyWith(letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: widget.onSkip,
                  child: Text(
                    'Pular',
                    style: AppTypography.body(
                      weight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
