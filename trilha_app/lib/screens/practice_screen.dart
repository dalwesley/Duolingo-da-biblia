import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/question_bank.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
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
          intro: 'Volte aos pontos em que você errou. Cada acerto limpa a pergunta da fila.',
          type: 'lesson',
          xpReward: 30,
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
        child: Scaffold(
          backgroundColor: AppColors.night,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            title: const Text('Revisar erros'),
          ),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Nenhum erro guardado ainda.\nContinue as missões — quando errar, volta aqui.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.5),
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
