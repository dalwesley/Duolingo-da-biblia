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
    );
    // Ids antigos podem não começar pelo slug da trilha: se nada
    // resolveu, carrega o banco inteiro uma vez antes de desistir.
    if (items.isEmpty && ids.isNotEmpty) {
      await ContentCatalogService.instance.getBankQuestions();
      items = explainMistakes(
        mistakeIds: ids,
        byId: QuestionBank.instance.byId,
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

/// Uma trilha, um cartão. Os trechos são seções dentro dele.
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
    final children = <Widget>[];
    final name = title?.trim() ?? '';
    if (name.isNotEmpty) {
      children.add(_masthead(context, name));
      children.add(const SizedBox(height: AppSpace.md));
      children.add(const ListDivider());
      children.add(const SizedBox(height: AppSpace.lg));
    }
    for (var p = 0; p < passages.length; p++) {
      final passage = passages[p];
      if (p > 0) children.add(const SizedBox(height: AppSpace.xl));
      final head = _head(context, passage);
      if (head != null) {
        children.add(head);
        children.add(const SizedBox(height: AppSpace.md));
      }
      for (var i = 0; i < passage.items.length; i++) {
        if (i > 0) {
          children.add(const SizedBox(height: AppSpace.md));
          children.add(const ListDivider());
          children.add(const SizedBox(height: AppSpace.md));
        }
        children.add(
          _MistakeRow(mistake: passage.items[i], accent: visuals.accent),
        );
      }
    }
    return GlassCard(
      padding: AppMetrics.cardPadding,
      tint: visuals.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _masthead(BuildContext context, String name) {
    final a = Appearance.of(context);
    return Row(
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
            style: AppTypography.title(size: 16, color: a.text),
          ),
        ),
      ],
    );
  }

  Widget? _head(BuildContext context, ExplainedPassageGroup passage) {
    final a = Appearance.of(context);
    final ref = (passage.items.first.verseRef ?? '').trim();
    final scene = sceneOf(passage);
    final label = ref.isNotEmpty ? ref : scene;
    if (label == null || label.isEmpty) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label, color: visuals.accent),
        if (scene != null && ref.isNotEmpty && scene != ref) ...[
          const SizedBox(height: 4),
          Text(
            scene,
            style: AppTypography.body(size: 12, color: a.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _MistakeRow extends StatelessWidget {
  final ExplainedMistake mistake;
  final Color accent;

  const _MistakeRow({required this.mistake, required this.accent});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final mode = DifficultyVisuals.accentFor(mistake.difficulty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _line(
          glyph: DifficultyVisuals.glyphFor(mistake.difficulty),
          color: mode,
          child: Text(
            mistake.difficulty.labelPt,
            style: AppTypography.body(size: 13, color: mode),
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        _line(
          glyph: _gestureGlyph(mistake.gesture),
          color: a.sectionLabel,
          child: Text(
            mistake.gesture.labelPt,
            style: AppTypography.body(size: 13, color: a.sectionLabel),
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        _line(
          glyph: CinematicGlyph.pencil,
          color: a.textSecondary,
          align: CrossAxisAlignment.start,
          child: Text(
            mistake.prompt,
            style: AppTypography.body(size: 14, color: a.text),
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        _line(
          glyph: CinematicGlyph.check,
          color: accent,
          align: CrossAxisAlignment.start,
          child: _answer(),
        ),
        if (mistake.why.isNotEmpty) ...[
          const SizedBox(height: AppSpace.sm),
          _line(
            glyph: CinematicGlyph.scroll,
            color: a.textSecondary,
            align: CrossAxisAlignment.start,
            child: Text(
              mistake.why,
              style: AppTypography.body(size: 14, color: a.textSecondary),
            ),
          ),
        ],
      ],
    );
  }

  Widget _answer() {
    final style = AppTypography.title(size: 16, color: accent);
    if (mistake.gesture != ExerciseType.order) {
      return Text(mistake.correct, style: style);
    }
    final parts = [
      for (final part in mistake.correct.split(' → '))
        if (part.trim().isNotEmpty) part.trim(),
    ];
    if (parts.length < 2) return Text(mistake.correct, style: style);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          Text(parts[i], style: style),
        ],
      ],
    );
  }
}

Widget _line({
  required CinematicGlyph glyph,
  required Color color,
  required Widget child,
  CrossAxisAlignment align = CrossAxisAlignment.center,
}) {
  return Row(
    crossAxisAlignment: align,
    children: [
      CinematicIcon(
        glyph: glyph,
        size: 22,
        accent: color,
        framed: false,
        glowing: false,
      ),
      const SizedBox(width: AppSpace.sm),
      Expanded(child: child),
    ],
  );
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
