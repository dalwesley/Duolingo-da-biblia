import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/question_bank.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../l10n/app_language.dart';
import '../services/analytics_service.dart';
import '../services/content_catalog_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/explained_errors.dart';
import '../utils/layout_utils.dart';
import '../utils/trail_visuals.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/immersive_background.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import 'paywall_screen.dart';

/// "Seus erros explicados" (Peregrino+): página do perfil com os erros
/// guardados — a pergunta, a resposta certa e o porquê de cada uma.
/// A fila de erros em si (praticar de novo) continua grátis em Prática;
/// aqui é a leitura calma, sem pressa e sem lâmpada.
class ExplainedErrorsScreen extends StatefulWidget {
  const ExplainedErrorsScreen({super.key});

  @override
  State<ExplainedErrorsScreen> createState() => _ExplainedErrorsScreenState();
}

class _ExplainedErrorsScreenState extends State<ExplainedErrorsScreen> {
  bool _loading = true;
  List<ExplainedMistake> _items = const [];
  List<Trail> _trails = const [];

  @override
  void initState() {
    super.initState();
    // Gate na tela, não só no cartão que a abre.
    if (!context.read<SubscriptionService>().plusFeaturesOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const PaywallScreen(source: 'explained_errors'),
          ),
        );
      });
      return;
    }
    AnalyticsService.instance.logPlusFeatureOpen(
      feature: 'explained_errors',
      hasPlus: context.read<SubscriptionService>().hasPlus,
    );
    _load();
  }

  Future<void> _load() async {
    final progress = context.read<ProgressService>();
    final ids = progress.mistakeQuestionIds;
    // Carrega só os bancos das trilhas dos erros guardados (teto: 6).
    final trails = await TrailRepository().getTrails();
    final bankSlugs = <String>{};
    for (final id in ids.reversed) {
      if (bankSlugs.length >= 6) break;
      for (final t in trails) {
        if (id.startsWith('${t.slug}-')) {
          bankSlugs.add(t.slug);
          break;
        }
      }
    }
    for (final slug in bankSlugs) {
      await ContentCatalogService.instance.ensureTrailBank(slug);
    }
    var items = explainMistakes(
      mistakeIds: ids,
      byId: QuestionBank.instance.byId,
      answers: progress.mistakeAnswers,
    );
    // Ids antigos podem não começar pelo slug da trilha: se nada
    // resolveu, carrega o banco inteiro uma vez antes de desistir.
    if (items.isEmpty && ids.isNotEmpty) {
      await ContentCatalogService.instance.getBankQuestions();
      items = explainMistakes(
        mistakeIds: ids,
        byId: QuestionBank.instance.byId,
        answers: progress.mistakeAnswers,
      );
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
      _trails = trails;
      _items = items;
    });
  }

  Trail? _trail(String slug) {
    for (final trail in _trails) {
      if (trail.slug == slug) return trail;
    }
    return null;
  }

  String? _trailTitle(String slug) {
    final title = _trail(slug)?.localizedTitle.trim() ?? '';
    return title.isEmpty ? null : title;
  }

  TrailVisuals _visuals(String slug) {
    final trail = _trail(slug);
    if (trail != null) return TrailVisuals.forTrail(trail);
    return TrailVisuals.forSlug(slug);
  }

  /// Nome da cena quando todos os erros do trecho são dela.
  String? _sceneTitle(ExplainedPassageGroup passage) {
    final sections = passage.items.map((item) => item.section).toSet();
    if (sections.length != 1) return null;
    final section = sections.single.trim();
    if (section.isEmpty) return null;
    final slug = passage.items.first.trailSlug;
    for (final trail in _trails) {
      if (trail.slug != slug) continue;
      for (final module in trail.modules) {
        for (final mission in module.missions) {
          if (mission.slug != section &&
              mission.resolvedBankSection != section) {
            continue;
          }
          final title = mission.localizedTitle.trim();
          if (title.isNotEmpty) return title;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final groups = _items.isEmpty
        ? const <ExplainedTrailGroup>[]
        : groupExplainedMistakes(_items);
    final subtitle = groups.length > 1
        ? l10n.explainErrorsEntry(_items.length)
        : null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ImmersiveBackground(
        frameChild: false,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screen,
                ),
                child: TopBar(
                  title: l10n.explainErrorsTitle,
                  subtitle: subtitle,
                  onBack: () => Navigator.pop(context),
                  leadingGlyph: CinematicGlyph.lamp,
                ),
              ),
              Expanded(
                child: ContentFrame(
                  child: _loading
                      ? const Center(child: AppSpinner())
                      : _items.isEmpty
                      ? Center(
                          child: EmptyState(
                            face: CloudFace.feliz,
                            title: l10n.explainErrorsEmptyTitle,
                            body: l10n.explainErrorsEmptyBody,
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpace.screen,
                            AppSpace.afterTopBar,
                            AppSpace.screen,
                            AppSpace.xxxl,
                          ),
                          children: [
                            for (final group in groups) ...[
                              _TrailSheet(
                                title: _trailTitle(group.trailSlug),
                                visuals: _visuals(group.trailSlug),
                                passages: group.passages,
                                sceneOf: _sceneTitle,
                              ),
                              const SizedBox(height: AppSpace.xxl),
                            ],
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Uma trilha, um cartão: o nome e as cenas dentro.
class _TrailSheet extends StatelessWidget {
  final String? title;
  final TrailVisuals visuals;
  final List<ExplainedPassageGroup> passages;
  final String? Function(ExplainedPassageGroup passage) sceneOf;

  const _TrailSheet({
    required this.title,
    required this.visuals,
    required this.passages,
    required this.sceneOf,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final body = <Widget>[];
    final name = title?.trim() ?? '';
    if (name.isNotEmpty) {
      body.add(
        Row(
          children: [
            CinematicIcon(
              glyph: visuals.glyph,
              size: AppMetrics.leadingIcon,
              accent: visuals.accent,
              framed: true,
              glowing: false,
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Text(
                name,
                style: AppTypography.title(size: 20, color: a.text),
              ),
            ),
          ],
        ),
      );
    }
    for (final passage in passages) {
      if (body.isNotEmpty) {
        body.add(const SizedBox(height: AppSpace.lg));
        body.add(const ListDivider());
        body.add(const SizedBox(height: AppSpace.lg));
      }
      body.addAll(_passage(context, passage));
    }
    return GlassCard(
      tint: visuals.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: body,
      ),
    );
  }

  List<Widget> _passage(BuildContext context, ExplainedPassageGroup passage) {
    final a = Appearance.of(context);
    final scene = sceneOf(passage)?.trim() ?? '';
    final ref = (passage.items.first.verseRef ?? '').trim();
    final title = scene.isNotEmpty && scene != ref ? scene : '';
    final body = <Widget>[];
    if (title.isNotEmpty) {
      body.add(
        Text(
          title,
          style: AppTypography.body(
            size: 15,
            weight: FontWeight.w700,
            color: a.textSecondary,
          ),
        ),
      );
      body.add(const SizedBox(height: AppSpace.md));
    }
    for (var i = 0; i < passage.items.length; i++) {
      if (i > 0) {
        body.add(const SizedBox(height: AppSpace.lg));
        body.add(const ListDivider());
        body.add(const SizedBox(height: AppSpace.lg));
      }
      body.add(_MistakeRow(mistake: passage.items[i]));
    }
    return body;
  }
}

class _MistakeRow extends StatelessWidget {
  final ExplainedMistake mistake;

  const _MistakeRow({required this.mistake});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final mode = DifficultyVisuals.accentFor(mistake.difficulty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpace.lg,
          runSpacing: AppSpace.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _chip(
              DifficultyVisuals.glyphFor(mistake.difficulty),
              mode,
              mistake.difficulty.labelPt,
            ),
            _chip(
              _gestureGlyph(mistake.gesture),
              a.sectionLabel,
              mistake.gesture.labelPt,
            ),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          mistake.prompt,
          style: AppTypography.body(
            size: 16,
            weight: FontWeight.w500,
            color: a.text,
          ),
        ),
        const SizedBox(height: AppSpace.md),
        if ((mistake.yours ?? '').isNotEmpty) ...[
          Text(
            context.l10n.explainYourAnswer(mistake.yours!),
            style: AppTypography.body(size: 13, color: a.textSecondary),
          ),
          if ((mistake.whyYours ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpace.xs),
            Text(
              mistake.whyYours!,
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w500,
                color: a.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpace.sm),
        ],
        Text.rich(
          TextSpan(
            style: AppTypography.body(
              size: 14,
              weight: FontWeight.w500,
              color: a.textSecondary,
            ),
            children: [
              TextSpan(text: context.l10n.explainAnswerLabel),
              const TextSpan(text: ': '),
              TextSpan(
                text: mistake.correct,
                style: AppTypography.body(
                  size: 15,
                  weight: FontWeight.w700,
                  color: a.text,
                ),
              ),
            ],
          ),
        ),
        if (mistake.why.isNotEmpty) ...[
          const SizedBox(height: AppSpace.sm),
          Text(
            mistake.why,
            style: AppTypography.title(size: 16, height: 1.35, color: a.text),
          ),
        ],
      ],
    );
  }

  Widget _chip(CinematicGlyph glyph, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CinematicIcon(
          glyph: glyph,
          size: AppMetrics.iconSm,
          accent: color,
          framed: false,
          glowing: false,
        ),
        const SizedBox(width: AppSpace.xs),
        Text(label, style: AppTypography.body(size: 13, color: color)),
      ],
    );
  }
}

CinematicGlyph _gestureGlyph(ExerciseType type) => switch (type) {
  ExerciseType.trueFalse => CinematicGlyph.scales,
  ExerciseType.tap || ExerciseType.findInText => CinematicGlyph.tap,
  ExerciseType.order => CinematicGlyph.stack,
  ExerciseType.complete => CinematicGlyph.gap,
  ExerciseType.connect || ExerciseType.match => CinematicGlyph.link,
  ExerciseType.choice ||
  ExerciseType.textSupported ||
  ExerciseType.bestInterpretation => CinematicGlyph.target,
  _ => CinematicGlyph.book,
};
