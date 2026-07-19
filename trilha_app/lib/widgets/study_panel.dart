import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final String? missionTitle;
  final String? missionIntro;

  const StudyPanel({
    super.key,
    required this.study,
    required this.accent,
    required this.onContinue,
    this.priorReflection,
    this.missionTitle,
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
    final title = widget.missionTitle?.trim();
    final intro = widget.missionIntro?.trim();

    return FadeTransition(
      opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            'PREPARE-SE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: accent.withValues(alpha: 0.95),
            ),
          ),
          if (title != null && title.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.15,
              ),
            ),
          ],
          if (intro != null && intro.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              intro,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
          ],
          const SizedBox(height: 22),

          // Passagem
          Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
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
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                if (study.focusQuestion.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    study.focusQuestion,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withValues(alpha: 0.65),
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  '"${study.passageText}"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
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
                        icon: Icons.menu_book_rounded,
                        accent: accent,
                        filled: true,
                        onTap: _openBible,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StudyAction(
                        label: 'Estudar',
                        icon: Icons.auto_stories_rounded,
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
            const SizedBox(height: 16),
            Text(
              study.context,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],

          if (study.keyword.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
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
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          study.keyword,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (study.keywordGloss.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            study.keywordGloss,
                            style: TextStyle(
                              fontSize: 13,
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
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Text(
                'Sua reflexão anterior: “${widget.priorReflection}”',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
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
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'RESPONDER PERGUNTAS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.inkOnAccent,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Leia o trecho quando puder — a passagem contextualiza as respostas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
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
  final IconData icon;
  final Color accent;
  final bool filled;
  final VoidCallback onTap;

  const _StudyAction({
    required this.label,
    required this.icon,
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
          borderRadius: BorderRadius.circular(14),
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
            Icon(
              icon,
              size: 16,
              color: filled ? accent : Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
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

/// Reflexão pós-missão — consolidar aprendizado.
class ReflectionPanel extends StatefulWidget {
  final MissionStudy study;
  final Color accent;
  final int correct;
  final int total;
  final ValueChanged<String> onFinish;

  const ReflectionPanel({
    super.key,
    required this.study,
    required this.accent,
    required this.correct,
    required this.total,
    required this.onFinish,
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'O que você leva\ndesta passagem?',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$pct% de acertos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            study.focusQuestion,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
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
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? accent
                                : Colors.white.withValues(alpha: 0.12),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          p,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ou escreva com suas palavras…',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
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
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: canSubmit
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.4),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: const Text(
                        'AVANÇAR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.inkOnAccent,
                          letterSpacing: 0.5,
                        ),
                      ),
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
