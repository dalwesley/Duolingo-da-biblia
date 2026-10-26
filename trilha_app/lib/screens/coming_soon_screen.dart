import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_language.dart';
import '../services/analytics_service.dart';
import '../services/backend_service.dart';
import '../services/progress_service.dart';
import '../services/remote_config_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/act_feel.dart';
import '../widgets/anan_speech.dart';
import '../widgets/home_brand_backdrop.dart';
import '../widgets/immersive_background.dart';
import '../widgets/ui_primitives.dart';

/// O que ainda não abriu e espera liberação por Remote Config.
enum ComingSoonFeature {
  groups('groups'),
  companion('companion'),
  challenge('challenge'),

  /// Linha do tempo, mapas e personagens: ainda não decidido. Mede o
  /// interesse por ferramenta antes de construir.
  explore('explore');

  const ComingSoonFeature(this.key);

  /// Prefixo do evento de analytics e do campo da lista de espera.
  final String key;
}

/// Abre o aviso "em breve" de [feature] em tela inteira.
Future<void> openComingSoon(
  BuildContext context,
  ComingSoonFeature feature, {
  required String source,
}) {
  AnalyticsService.instance.logEvent('${feature.key}_soon_view', {
    'source': source,
  });
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => ComingSoonScreen(feature: feature),
    ),
  );
}

/// Algo ainda não abriu (grupos chegam com os planos Líder e Igreja;
/// companhia e desafio, depois do lançamento): o Anan avisa, conta o que
/// vem e guarda quem quer ser avisado.
class ComingSoonScreen extends StatefulWidget {
  final ComingSoonFeature feature;

  const ComingSoonScreen({super.key, required this.feature});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  String get _prefsKey => '${widget.feature.key}WaitlistJoined';

  bool _joined = false;
  bool _busy = false;

  /// Ferramentas marcadas (só [ComingSoonFeature.explore]).
  final _picks = <String>{};

  bool get _picking => widget.feature == ComingSoonFeature.explore;

  static const _exploreTools = [
    ('timeline', CinematicGlyph.hourglass),
    ('atlas', CinematicGlyph.mountain),
    ('characters', CinematicGlyph.people),
  ];

  String _toolLabel(String id) => switch (id) {
    'timeline' => context.l10n.exploreSoonItemTimeline,
    'atlas' => context.l10n.exploreSoonItemAtlas,
    _ => context.l10n.exploreSoonItemCharacters,
  };

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted && (prefs.getBool(_prefsKey) ?? false)) {
        setState(() => _joined = true);
      }
    });
  }

  Future<void> _join() async {
    setState(() => _busy = true);
    final picks = _exploreTools
        .map((t) => t.$1)
        .where(_picks.contains)
        .toList();
    await context.read<BackendService>().joinWaitlist(
      widget.feature.key,
      picks: picks,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
    AnalyticsService.instance.logEvent('${widget.feature.key}_waitlist_join', {
      for (final t in _exploreTools)
        if (_picking) t.$1: _picks.contains(t.$1) ? 1 : 0,
    });
    if (!mounted) return;
    setState(() {
      _busy = false;
      _joined = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mode = context.watch<ProgressService>().settings.appearanceMode;
    final a = AppearanceStyle.resolve(mode);
    final top = MediaQuery.viewPaddingOf(context).top;
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    final companionOpen = context.watch<RemoteConfigService>().companionEnabled;
    final meanwhile = companionOpen
        ? l10n.comingSoonMeanwhileCompanion
        : l10n.comingSoonMeanwhileCaravan;
    final (
      title,
      body,
      joined,
      meanwhileLine,
      coming,
    ) = switch (widget.feature) {
      ComingSoonFeature.groups => (
        l10n.groupsSoonTitle,
        l10n.groupsSoonBody,
        l10n.groupsSoonJoined,
        meanwhile,
        [
          (CinematicGlyph.home, l10n.groupsSoonItemStudy),
          (CinematicGlyph.people, l10n.groupsSoonItemTogether),
          (CinematicGlyph.target, l10n.groupsSoonItemLeader),
        ],
      ),
      ComingSoonFeature.companion => (
        l10n.companionSoonTitle,
        l10n.companionSoonBody,
        l10n.companionSoonJoined,
        l10n.comingSoonMeanwhileCaravan,
        [
          (CinematicGlyph.link, l10n.companionSoonItemPair),
          (CinematicGlyph.path, l10n.companionSoonItemToday),
          (CinematicGlyph.bell, l10n.companionSoonItemNudge),
        ],
      ),
      ComingSoonFeature.challenge => (
        l10n.challengeSoonTitle,
        l10n.challengeSoonBody,
        l10n.challengeSoonJoined,
        meanwhile,
        [
          (CinematicGlyph.podium, l10n.challengeSoonItemCall),
          (CinematicGlyph.book, l10n.challengeSoonItemScene),
          (CinematicGlyph.crown, l10n.challengeSoonItemWin),
        ],
      ),
      ComingSoonFeature.explore => (
        l10n.exploreSoonTitle,
        l10n.exploreSoonBody,
        l10n.exploreSoonJoined,
        l10n.exploreSoonMeanwhile,
        [for (final t in _exploreTools) (t.$2, _toolLabel(t.$1))],
      ),
    };

    return ImmersiveScaffold(
      mode: mode,
      style: a,
      frameBody: false,
      background: Stack(
        fit: StackFit.expand,
        children: [
          AmbientAtmosphere(phase: a.phase),
          HomeBrandBackdrop(style: a),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ContentFrame(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpace.screen,
                  top + AppSpace.lg,
                  AppSpace.screen,
                  AppSpace.xl,
                ),
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: l10n.commonBack,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: CinematicIcon(
                        glyph: CinematicGlyph.close,
                        size: AppMetrics.iconLg,
                        accent: a.textSecondary,
                        framed: false,
                      ),
                    ),
                  ),
                  // O recado de abertura é a fala do Anan.
                  AnanSpeech(
                    face: _joined ? CloudFace.sucesso : CloudFace.carregando,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.comingSoonEyebrow.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: AppTypography.body(
                            size: 12,
                            weight: FontWeight.w800,
                            color: AnanSpeechBubble.mark,
                          ),
                        ),
                        const SizedBox(height: AppSpace.sm),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppTypography.display(
                            size: 30,
                            color: AnanSpeechBubble.ink,
                          ),
                        ),
                        const SizedBox(height: AppSpace.sm),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: AppTypography.body(
                            size: 14,
                            height: 1.45,
                            color: AnanSpeechBubble.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          (_picking
                                  ? l10n.exploreSoonPickHeader
                                  : l10n.comingSoonComingHeader)
                              .toUpperCase(),
                          style: AppTypography.body(
                            size: 12,
                            weight: FontWeight.w800,
                            color: AppRoles.reward,
                          ),
                        ),
                        const SizedBox(height: AppSpace.md),
                        for (var i = 0; i < coming.length; i++) ...[
                          if (i > 0) const SizedBox(height: 10),
                          if (_picking)
                            _PickRow(
                              glyph: coming[i].$1,
                              label: coming[i].$2,
                              picked: _picks.contains(_exploreTools[i].$1),
                              enabled: !_joined,
                              onTap: () => setState(() {
                                final id = _exploreTools[i].$1;
                                if (!_picks.remove(id)) _picks.add(id);
                              }),
                            )
                          else
                            Row(
                              children: [
                                CinematicIcon(
                                  glyph: coming[i].$1,
                                  size: AppMetrics.iconLg,
                                  accent: AppRoles.reward,
                                ),
                                const SizedBox(width: AppSpace.md),
                                Expanded(
                                  child: Text(
                                    coming[i].$2,
                                    style: AppTypography.title(
                                      size: 15,
                                      color: a.text,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                  GlassCard(
                    child: Row(
                      children: [
                        CinematicIcon(
                          glyph: CinematicGlyph.path,
                          size: AppMetrics.iconLg,
                          accent: a.textSecondary,
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Text(
                            meanwhileLine,
                            style: AppTypography.body(
                              size: 13,
                              color: a.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ContentFrame(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpace.screen,
                AppSpace.sm,
                AppSpace.screen,
                AppSpace.md + bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_joined)
                    Text(
                      joined,
                      textAlign: TextAlign.center,
                      style: AppTypography.title(size: 15, color: a.text),
                    )
                  else
                    CopperCta(
                      label: _busy
                          ? l10n.comingSoonSaving
                          : l10n.comingSoonNotifyMe,
                      leading: CinematicGlyph.bell,
                      expanded: true,
                      onTap: _busy || (_picking && _picks.isEmpty)
                          ? null
                          : _join,
                    ),
                  TextCta(
                    label: l10n.commonBack,
                    color: a.textFaint,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ferramenta marcável: o toque liga e desliga o interesse.
class _PickRow extends StatelessWidget {
  final CinematicGlyph glyph;
  final String label;
  final bool picked;
  final bool enabled;
  final VoidCallback onTap;

  const _PickRow({
    required this.glyph,
    required this.label,
    required this.picked,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final tone = picked ? AppRoles.reward : a.textSecondary;
    return Semantics(
      button: true,
      toggled: picked,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled
              ? () {
                  ActHaptics.tap();
                  onTap();
                }
              : null,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Ink(
            padding: const EdgeInsets.all(AppSpace.sm),
            decoration: BoxDecoration(
              color: picked ? AppRoles.reward.withValues(alpha: 0.12) : null,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: picked ? AppRoles.reward : a.cardBorder,
              ),
            ),
            child: Row(
              children: [
                CinematicIcon(
                  glyph: glyph,
                  size: AppMetrics.iconLg,
                  accent: tone,
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.title(size: 15, color: a.text),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                // O + é marca do Peregrino+: desmarcado fica vazio.
                SizedBox.square(
                  dimension: AppMetrics.iconMd,
                  child: picked
                      ? CinematicIcon(
                          glyph: CinematicGlyph.check,
                          size: AppMetrics.iconMd,
                          accent: tone,
                          framed: false,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
