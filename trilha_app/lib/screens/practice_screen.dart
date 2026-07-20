import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/question_bank.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/top_bar.dart';
import 'lesson_screen.dart';

/// Prática de erros — revisão das perguntas erradas (estilo Practice do Duolingo).
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  bool _loading = true;
  Mission? _mission;
  List<String> _ids = [];

  @override
  void initState() {
    super.initState();
    _build();
  }

  Future<void> _build() async {
    final progress = context.read<ProgressService>();
    await QuestionBank.instance.ensureLoaded();
    final ids = progress.mistakeQuestionIds.reversed.take(6).toList();
    final questions = <Question>[];
    for (final id in ids) {
      final bq = QuestionBank.instance.byId(id);
      if (bq != null) questions.add(bq.toQuestion(shuffleOptions: true));
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
      _ids = ids;
      if (questions.isNotEmpty) {
        _mission = Mission(
          slug: 'practice-mistakes',
          title: 'Revisar erros',
          intro:
              'Volte aos pontos em que você errou. Cada acerto limpa a pergunta da fila.',
          type: 'lesson',
          stepsReward: 30,
          questions: questions,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.night,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    if (_mission == null) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Appearance(
          mode: context.read<ProgressService>().settings.appearanceMode,
          style: AppearanceStyle.resolve(
            context.read<ProgressService>().settings.appearanceMode,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: ImmersiveBackground(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpace.screen,
                      MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
                      AppSpace.screen,
                      0,
                    ),
                    child: TopBar(
                      inline: true,
                      immersive: true,
                      dark: true,
                      title: 'Revisitar',
                      subtitle: 'Reforce as passagens',
                      onBack: () => Navigator.pop(context),
                      leadingGlyph: CinematicGlyph.echo,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpace.xxxl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CinematicIcon(
                              glyph: CinematicGlyph.echo,
                              size: 56,
                              accent: AppColors.accent,
                              glowing: true,
                            ),
                            const SizedBox(height: AppSpace.section),
                            Text(
                              'Nenhum erro guardado ainda.\nContinue as missões — quando errar, volta aqui.',
                              textAlign: TextAlign.center,
                              style: AppTypography.body(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return LessonScreen(
      missionSlug: 'practice-mistakes',
      practiceMode: true,
      missionOverride: _mission,
      questionIdsOverride: _ids,
    );
  }
}
