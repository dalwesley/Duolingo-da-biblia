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
import '../widgets/home_brand_backdrop.dart';
import '../widgets/immersive_background.dart';
import '../widgets/ui_primitives.dart';

/// O que ainda não abriu e espera liberação por Remote Config.
enum ComingSoonFeature {
  groups('groups'),
  companion('companion'),
  challenge('challenge');

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
    await context.read<BackendService>().joinWaitlist(widget.feature.key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
    AnalyticsService.instance.logEvent('${widget.feature.key}_waitlist_join');
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
                  Center(
                    child: CloudMascot(
                      face: _joined ? CloudFace.sucesso : CloudFace.carregando,
                      size: 120,
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                  GlassCard(
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
                            color: AppRoles.reward,
                          ),
                        ),
                        const SizedBox(height: AppSpace.sm),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppTypography.display(size: 30, color: a.text),
                        ),
                        const SizedBox(height: AppSpace.sm),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: AppTypography.body(
                            size: 14,
                            height: 1.45,
                            color: a.textSecondary,
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
                          l10n.comingSoonComingHeader.toUpperCase(),
                          style: AppTypography.body(
                            size: 12,
                            weight: FontWeight.w800,
                            color: AppRoles.reward,
                          ),
                        ),
                        const SizedBox(height: AppSpace.md),
                        for (var i = 0; i < coming.length; i++) ...[
                          if (i > 0) const SizedBox(height: 10),
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
                      onTap: _busy ? null : _join,
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
