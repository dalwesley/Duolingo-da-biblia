import 'package:flutter/material.dart';
import '../data/mission_study.dart';
import '../theme/app_theme.dart';

/// Momento de estudo — abrir a Bíblia e ler o trecho antes de responder.
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
      duration: const Duration(milliseconds: 700),
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'Leia ${study.passageRef}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            study.focusQuestion,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Text(
                  'Faça o seu devocional',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Esse momento aproxima você de Deus e prepara o coração antes de responder.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 12),
                _StudyAction(
                  icon: Icons.menu_book_rounded,
                  accent: accent,
                  title: 'Abra',
                  detail: study.passageRef,
                ),
                const SizedBox(height: 10),
                _StudyAction(
                  icon: Icons.visibility_rounded,
                  accent: accent,
                  title: 'Leia',
                  detail: 'o trecho completo — não só o resumo abaixo',
                ),
                const SizedBox(height: 10),
                _StudyAction(
                  icon: Icons.edit_note_rounded,
                  accent: accent,
                  title: 'Marque',
                  detail: 'palavras e frases que chamarem atenção',
                ),
                const SizedBox(height: 10),
                _StudyAction(
                  icon: Icons.search_rounded,
                  accent: accent,
                  title: 'Pesquise',
                  detail: 'com a pergunta-guia em mente',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.short_text_rounded,
                      color: accent.withValues(alpha: 0.85),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Prévia (não substitui a leitura)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                        color: accent.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '"${study.passageText}"',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            study.context,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.22),
                  accent.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accent.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ao marcar, procure isto',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  study.keyword,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  study.keywordGloss,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (widget.priorReflection != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Sua reflexão anterior: “${widget.priorReflection}”',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => setState(() => _acknowledged = !_acknowledged),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(top: 1),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: _acknowledged ? accent : Colors.transparent,
                    border: Border.all(
                      color: accent.withValues(alpha: 0.7),
                      width: 2,
                    ),
                  ),
                  child: _acknowledged
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Color(0xFF3D2E00),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
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
          const SizedBox(height: 18),
          Opacity(
            opacity: _acknowledged ? 1 : 0.45,
            child: GestureDetector(
              onTap: _acknowledged ? widget.onContinue : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.lerp(accent, Colors.white, 0.25)!, accent],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _acknowledged
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: const Text(
                  'RESPONDER COM O TEXTO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF3D2E00),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Abra a Bíblia, leia o trecho e só depois responda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyAction extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String detail;

  const _StudyAction({
    required this.icon,
    required this.accent,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: Colors.white.withValues(alpha: 0.88),
                ),
                children: [
                  TextSpan(
                    text: '$title ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: detail,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
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
            'REFLEXÃO',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
              color: accent,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'O que esta passagem deposita em você?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$pct% de acertos · agora consolide o aprendizado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            study.focusQuestion,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.75),
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
                              : Colors.white.withValues(alpha: 0.07),
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'GUARDAR E CONCLUIR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3D2E00),
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
