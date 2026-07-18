import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mission_study.dart';
import '../screens/bible_screen.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';
import 'verse_study_sheet.dart';

/// Momento de estudo — cena de abertura da Bíblia antes de responder.
class StudyPanel extends StatefulWidget {
  final MissionStudy study;
  final Color accent;
  final VoidCallback onContinue;
  final String? priorReflection;

  const StudyPanel({
    super.key,
    required this.study,
    required this.accent,
    required this.onContinue,
    this.priorReflection,
  });

  @override
  State<StudyPanel> createState() => _StudyPanelState();
}

class _StudyPanelState extends State<StudyPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  bool _acknowledged = false;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final study = widget.study;
    final accent = widget.accent;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'LEIA A PASSAGEM',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: accent.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            study.passageRef,
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            study.focusQuestion,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.68),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Pergaminho / prévia
          Container(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.12),
                  blurRadius: 28,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 1,
                      color: accent.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 10),
                    CinematicIcon(
                      glyph: CinematicGlyph.book,
                      size: 28,
                      accent: accent,
                      glowing: false,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 20,
                      height: 1,
                      color: accent.withValues(alpha: 0.4),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '"${study.passageText}"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Prévia — leia o trecho completo na sua Bíblia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                BibleReaderScreen(reference: study.passageRef),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.65),
                            width: 1.5,
                          ),
                          color: accent.withValues(alpha: 0.1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 17,
                              color: accent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'LER NO APP',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => showVerseStudyFromReference(
                        context,
                        study.passageRef,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28),
                            width: 1.5,
                          ),
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_stories_rounded,
                              size: 17,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ESTUDAR',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            study.context,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 20),

          // Palavra-chave
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.22),
                  accent.withValues(alpha: 0.06),
                ],
              ),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AO LER, PROCURE ISTO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  study.keyword,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  study.keywordGloss,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),

          // Rito de leitura
          const SizedBox(height: 20),
          _RiteStep(n: '01', title: 'Abra', detail: study.passageRef, accent: accent),
          const SizedBox(height: 10),
          _RiteStep(
            n: '02',
            title: 'Leia',
            detail: 'o trecho completo — não só a prévia',
            accent: accent,
          ),
          const SizedBox(height: 10),
          _RiteStep(
            n: '03',
            title: 'Marque',
            detail: 'palavras que tocarem o coração',
            accent: accent,
          ),
          const SizedBox(height: 10),
          _RiteStep(
            n: '04',
            title: 'Pesquise',
            detail: 'com a pergunta-guia em mente',
            accent: accent,
          ),

          if (widget.priorReflection != null) ...[
            const SizedBox(height: 16),
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

          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => setState(() => _acknowledged = !_acknowledged),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(top: 1),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: _acknowledged ? AppGradients.gold : null,
                    color: _acknowledged ? null : Colors.transparent,
                    border: Border.all(
                      color: accent.withValues(alpha: 0.7),
                      width: 2,
                    ),
                  ),
                  child: _acknowledged
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppColors.inkOnAccent,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Li ${study.passageRef} na minha Bíblia',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Opacity(
            opacity: _acknowledged ? 1 : 0.4,
            child: GestureDetector(
              onTap: _acknowledged ? widget.onContinue : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 17),
                decoration: BoxDecoration(
                  gradient: AppGradients.gold,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: _acknowledged
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.45),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: const Text(
                  'ENTRAR NAS PERGUNTAS',
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
          ),
          const SizedBox(height: 10),
          Text(
            'Abra a Bíblia, leia o trecho e só depois responda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiteStep extends StatelessWidget {
  final String n;
  final String title;
  final String detail;
  final Color accent;

  const _RiteStep({
    required this.n,
    required this.title,
    required this.detail,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          n,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: accent.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              children: [
                TextSpan(
                  text: '$title ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                TextSpan(text: detail),
              ],
            ),
          ),
        ),
      ],
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
