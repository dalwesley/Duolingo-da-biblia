import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/question_bank.dart';
import '../data/trail_repository.dart';
import '../models/caravan_profile_prefs.dart';
import '../models/difficulty.dart';
import '../services/app_update_service.dart';
import '../services/backend_service.dart';
import '../services/bible_service.dart';
import '../services/bible_study_service.dart';
import '../services/companion_service.dart';
import '../services/corner_service.dart';
import '../services/league_service.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/layout_utils.dart';
import '../utils/trail_progress.dart';
import '../widgets/app_update_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/hero_card_atmosphere.dart';
import '../widgets/immersive_background.dart';
import '../widgets/mode_emblem.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/user_avatar.dart';
import 'login_screen.dart';
import 'paywall_screen.dart';
import 'onboarding_screen.dart';

const _genesisTrailSlug = 'genesis-1-11';

/// Abre ajustes como página empurrada (engrenagem no perfil).
void openSettings(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) {
        final progress = ctx.watch<ProgressService>();
        final mode = progress.settings.appearanceMode;
        final appearance = AppearanceStyle.resolve(mode);
        return Appearance(
          mode: mode,
          style: appearance,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: ImmersiveBackground(
              appearance: appearance,
              child: SettingsScreen(
                onOpenProfile: () => Navigator.pop(ctx),
                topBar: TopBar(
                  inline: true,
                  immersive: true,
                  dark: appearance.onDark,
                  title: 'Ajustes',
                  subtitle: 'Como você caminha',
                  leadingGlyph: CinematicGlyph.tune,
                  chromeAccent: AppColors.slate,
                  onBack: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class SettingsScreen extends StatefulWidget {
  final Widget? topBar;
  final VoidCallback? onOpenProfile;

  const SettingsScreen({super.key, this.topBar, this.onOpenProfile});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  bool _confirmReset = false;
  bool _nameDirty = false;
  List<DifficultyMeta>? _difficulties;
  List<String> _genesisMissionSlugs = const [];
  late final AnimationController _entrance;
  String? _versionLabel;
  bool _checkingUpdate = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    _loadDifficulties();
    _loadVersionLabel();
    _nameController.addListener(_onNameChanged);
  }

  Future<void> _loadVersionLabel() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _versionLabel = '${info.version} (${info.buildNumber})');
  }

  Future<void> _checkForUpdates() async {
    if (_checkingUpdate) return;
    setState(() => _checkingUpdate = true);
    try {
      final status = await AppUpdateService.check(ignoreSnooze: true);
      if (!mounted) return;
      setState(() => _versionLabel = status.localLabel);

      if (status.updateAvailable) {
        await showAppUpdateSheet(context, status);
        return;
      }

      if (!mounted) return;
      final msg = !status.remoteReachable
          ? status.message
          : 'Você está na versão mais recente · ${status.localLabel}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: AppTypography.body(size: 13, color: Colors.white),
          ),
          backgroundColor: AppColors.nightElevated,
        ),
      );
    } finally {
      if (mounted) setState(() => _checkingUpdate = false);
    }
  }

  void _onNameChanged() {
    if (!mounted) return;
    final current = context.read<ProgressService>().userName;
    final dirty = _nameController.text.trim() != current;
    if (dirty != _nameDirty) setState(() => _nameDirty = dirty);
  }

  Future<void> _loadDifficulties() async {
    final items = await QuestionBank.instance.getDifficulties();
    final trail = await TrailRepository().getTrailBySlug(_genesisTrailSlug);
    if (mounted) {
      setState(() {
        _difficulties = items;
        _genesisMissionSlugs = trail?.missionSlugs ?? const [];
      });
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  Widget _reveal(int index, Widget child) {
    if (_entrance.isCompleted) return child;
    final start = (0.08 * index).clamp(0.0, 0.6);
    final end = (start + 0.36).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _entrance,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final sync = context.watch<SyncService>();
    final a = Appearance.of(context);

    // Mantém o campo alinhado ao progresso (ex.: nome restaurado do Google),
    // sem sobrescrever enquanto o usuário edita.
    if (!_nameDirty && _nameController.text != progress.userName) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _nameDirty) return;
        if (_nameController.text == progress.userName) return;
        _nameController.text = progress.userName;
        setState(() => _nameDirty = false);
      });
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen,
        widget.topBar == null
            ? AppSpace.sm
            : MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
        AppSpace.screen,
        scrollPaddingBelowNav(context),
      ),
      physics: const ClampingScrollPhysics(),
      children: [
        if (widget.topBar != null) ...[
          widget.topBar!,
          const SizedBox(height: AppSpace.afterTopBar),
        ],

        _reveal(0, _identityCard(progress, a)),
        const SizedBox(height: AppSpace.section),
        _reveal(1, _membershipCard(a)),
        const SizedBox(height: AppSpace.section),
        _reveal(
          3,
          _groupedCard(
            a,
            title: 'O ritmo',
            glyph: CinematicGlyph.target,
            subtitle: 'Quantas missões cabem no seu dia.',
            children: [_RhythmPath(progress: progress)],
          ),
        ),
        const SizedBox(height: AppSpace.section),
        _reveal(
          4,
          _groupedCard(
            a,
            title: 'O olhar',
            glyph: CinematicGlyph.book,
            subtitle: 'Gênesis 1–11 · o primeiro caminho',
            children: [_difficultyPicker(progress)],
          ),
        ),
        const SizedBox(height: AppSpace.section),
        _reveal(
          5,
          _groupedCard(
            a,
            title: 'O céu',
            glyph: CinematicGlyph.sun,
            subtitle: 'Luz da tela e tamanho da letra.',
            children: [
              _skyPicker(progress),
              const SizedBox(height: 16),
              _fieldLabel(a, 'Tamanho do texto'),
              const SizedBox(height: 10),
              _fontScalePicker(progress),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.section),
        _reveal(
          6,
          _groupedCard(
            a,
            title: 'Lembretes',
            glyph: CinematicGlyph.bell,
            children: [
              _toggle(
                a,
                'Sons',
                'Efeitos nas lições',
                progress.settings.sound,
                (v) {
                  progress.updateSettings(progress.settings.copyWith(sound: v));
                  SoundService.instance.setEnabled(v);
                },
                glyph: CinematicGlyph.echo,
              ),
              _SettingsDivider(a, compact: true),
              _toggle(
                a,
                'Notificações',
                'Meta, missões e prática',
                progress.settings.notifications,
                (v) async {
                  await progress.markNotificationsPrompted(enabled: v);
                  if (v) {
                    await NotificationService.instance.requestOsPermission();
                  }
                  await NotificationService.instance.syncFromProgress(progress);
                },
                glyph: CinematicGlyph.bell,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.section),
        _reveal(
          7,
          _groupedCard(
            a,
            title: 'Privacidade',
            glyph: CinematicGlyph.shield,
            subtitle: 'O que outros veem no seu card da caravana.',
            children: [
              for (var i = 0; i < CaravanProfileSection.values.length; i++) ...[
                if (i > 0) _SettingsDivider(a, compact: true),
                _caravanProfileToggle(
                  progress,
                  a,
                  CaravanProfileSection.values[i],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpace.section),
        _reveal(8, _backupBlock(a, sync, progress)),
        const SizedBox(height: AppSpace.section),
        _reveal(9, _aboutBlock(a)),
        const SizedBox(height: AppSpace.section),
        _reveal(10, _dangerBlock(a, progress)),
        const SizedBox(height: 8),
      ],
    );
  }

  String _shortDate(DateTime dt) {
    final local = dt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$d/$m/${local.year} · $h:$min';
  }

  Widget _fieldLabel(AppearanceStyle a, String title) {
    return Text(
      title,
      style: AppTypography.body(
        size: 13,
        weight: FontWeight.w700,
        color: a.textMuted(0.72),
      ),
    );
  }

  void _saveName(ProgressService progress) {
    FocusScope.of(context).unfocus();
    progress.setUserName(_nameController.text);
    setState(() => _nameDirty = false);
    HapticFeedback.lightImpact();
  }

  Widget _fontScalePicker(ProgressService progress) {
    const steps = <(double, String)>[
      (0.9, 'Peq.'),
      (1.0, 'Médio'),
      (1.15, 'Grande'),
      (1.3, 'Extra'),
    ];
    final current = progress.settings.fontScale;

    return _SegmentTrack(
      items: [
        for (final step in steps)
          (
            label: step.$2,
            selected: (current - step.$1).abs() < 0.01,
            onTap: () {
              HapticFeedback.selectionClick();
              progress.updateSettings(
                progress.settings.copyWith(fontScale: step.$1),
              );
            },
          ),
      ],
    );
  }

  Widget _difficultyPicker(ProgressService progress) {
    final items = _difficulties;
    final selectedId = progress.difficultyForTrail(_genesisTrailSlug);

    if (items == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Builder(
            builder: (context) {
              final meta = items[i];
              final locked = !progress.isDifficultyUnlocked(
                _genesisTrailSlug,
                meta.difficulty,
              );
              final selected = selectedId == meta.difficulty.id && !locked;
              final cleared = progress.hasClearedMode(
                _genesisTrailSlug,
                meta.difficulty.id,
              );
              return _ModeStation(
                meta: meta,
                locked: locked,
                selected: selected,
                cleared: cleared,
                onTap: () => _onDifficultyTap(context, progress, meta, locked),
              );
            },
          ),
        ],
      ],
    );
  }

  void _onDifficultyTap(
    BuildContext context,
    ProgressService progress,
    DifficultyMeta meta,
    bool locked,
  ) {
    if (locked) {
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Conclua o modo anterior para liberar ${meta.label}.',
            style: AppTypography.body(color: AppColors.textOnDark),
          ),
          backgroundColor: AppColors.nightElevated,
        ),
      );
      return;
    }
    HapticFeedback.selectionClick();
    progress.setSessionTrailDifficulty(
      _genesisTrailSlug,
      meta.difficulty.id,
      missionSlugs: _genesisMissionSlugs,
    );
    final canonical = progress.canonicalDifficultyId(_genesisTrailSlug);
    if (meta.difficulty.id != canonical) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Modo ${meta.label} só nesta sessão. Ao fechar o app volta para ${TrailProgress.modeLabel(canonical)}.',
            style: AppTypography.body(color: AppColors.textOnDark),
          ),
          backgroundColor: AppColors.nightElevated,
        ),
      );
    }
  }

  Widget _skyPicker(ProgressService progress) {
    final selected = progress.settings.appearanceMode;
    return _SkySwitch(
      selected: selected,
      onChanged: (mode) {
        if (mode == selected) return;
        progress.updateSettings(
          progress.settings.copyWith(appearanceMode: mode),
        );
      },
    );
  }

  Widget _identityCard(ProgressService progress, AppearanceStyle a) {
    final backend = context.watch<BackendService>();
    return GlassCard(
      elevated: true,
      padding: const EdgeInsets.fromLTRB(
        AppSpace.lg,
        AppSpace.lg,
        AppSpace.lg,
        AppSpace.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHeader(
            a: a,
            nameController: _nameController,
            nameDirty: _nameDirty,
            photoUrl: backend.userPhotoUrl,
            seed: backend.uid,
            portraitStyle: progress.settings.portraitStyle,
            signedIn: backend.isSignedIn,
            email: backend.isSignedIn
                ? (backend.userEmail ?? backend.userDisplayName)
                : null,
            lastSync: backend.isActive ? backend.lastCloudSaveAt : null,
            onSignOut: backend.isSignedIn && !backend.isGoogleBusy
                ? () => _signOutGoogle(backend)
                : null,
            onOpenProfile: widget.onOpenProfile,
            onSaveName: () => _saveName(progress),
          ),
        ],
      ),
    );
  }

  Widget _membershipCard(AppearanceStyle a) {
    final plus = context.watch<SubscriptionService>().isPeregrinoPlus;
    return GlassCard(
      elevated: true,
      accent: true,
      padding: EdgeInsets.zero,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const PaywallScreen()),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppMetrics.cardRadius - 1.5),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.16,
                  child: HeroCardAtmosphere(mood: HeroCardMood.alive),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.accent.withValues(alpha: plus ? 0.18 : 0.10),
                      AppColors.accent.withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.42, 1],
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 5,
              child: ColoredBox(color: AppColors.accent),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 16, 20),
              child: Row(
                children: [
                  CinematicIcon(
                    glyph: CinematicGlyph.crown,
                    size: 52,
                    accent: AppColors.accent,
                    glowing: plus,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'PEREGRINO+',
                          style: AppTypography.label(
                            size: 11,
                            letterSpacing: 1.8,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plus
                              ? 'Assinatura ativa no caminho'
                              : 'Mais espaço para a companhia',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.title(
                            size: 16,
                            height: 1.15,
                            color: a.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (plus)
                    Text(
                      'ATIVO',
                      style: AppTypography.label(
                        size: 10,
                        letterSpacing: 1.2,
                        color: AppColors.accent,
                      ),
                    )
                  else
                    ListChevron(
                      color: AppColors.accent.withValues(alpha: 0.9),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOutGoogle(BackendService backend) async {
    final progress = context.read<ProgressService>();
    final ok = await backend.signOutGoogle();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(backend.lastError ?? 'Não foi possível sair')),
      );
      return;
    }
    await progress.resetMemoryToDefaults();
    if (!mounted) return;
    await context.read<LeagueService>().resetForLogout();
    // Limpa códigos locais de companhia/sala (evita herdar na próxima conta).
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('companionCodes');
    await prefs.remove('activeRoomCode');
    if (!mounted) return;
    context.read<CompanionService>().markCloudUnsynced();
    if (!mounted) return;
    context.read<CornerService>().markCloudUnsynced();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  Future<void> _exportProgress(
    ProgressService progress,
    SyncService sync,
  ) async {
    final league = context.read<LeagueService>();
    final json = sync.exportJson(progress, league: league);
    await SharePlus.instance.share(
      ShareParams(text: json, subject: 'Backup Stway'),
    );
    await sync.markSynced();
  }

  Future<void> _importProgress(
    ProgressService progress,
    SyncService sync,
  ) async {
    final backend = context.read<BackendService>();
    final league = context.read<LeagueService>();
    final data = await Clipboard.getData('text/plain');
    final text = data?.text;
    if (text == null || text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cole o backup na área de transferência primeiro'),
          ),
        );
      }
      return;
    }
    final parsed = sync.parseImport(text);
    if (parsed == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Backup inválido')));
      }
      return;
    }
    await progress.applyFromCloud(parsed);
    await league.applyFromCloud(parsed);
    progress.bindCacheUid(backend.uid);
    progress.markCloudHydrated();
    await backend.saveNow(progress, LeagueService.weekKey(), league: league);
    await sync.markSynced();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Progresso restaurado!')));
    }
  }

  Widget _toggle(
    AppearanceStyle a,
    String label,
    String desc,
    bool value,
    ValueChanged<bool> onChanged, {
    CinematicGlyph glyph = CinematicGlyph.spark,
    Color? accent,
  }) {
    final tone = accent ?? AppColors.accent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CinematicIcon(
            glyph: glyph,
            size: 32,
            accent: value ? tone : a.textMuted(0.42),
            glowing: false,
            framed: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.title(size: 15, color: a.text),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTypography.body(size: 12, color: a.textMuted(0.58)),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }

  Widget _caravanProfileToggle(
    ProgressService progress,
    AppearanceStyle a,
    CaravanProfileSection section,
  ) {
    final prefs = progress.caravanProfilePrefs;
    final visible = prefs.isVisible(section);
    final glyph = switch (section) {
      CaravanProfileSection.presence => CinematicGlyph.people,
      CaravanProfileSection.ranking => CinematicGlyph.podium,
      CaravanProfileSection.daysAsLeader => CinematicGlyph.crown,
      CaravanProfileSection.lastMission => CinematicGlyph.path,
      CaravanProfileSection.accuracy => CinematicGlyph.target,
      CaravanProfileSection.bible => CinematicGlyph.book,
      CaravanProfileSection.trails => CinematicGlyph.mountain,
      CaravanProfileSection.medals => CinematicGlyph.gem,
    };
    return _toggle(a, section.label, section.subtitle, visible, (v) {
      HapticFeedback.selectionClick();
      progress.updateCaravanProfilePrefs(prefs.copyWithSection(section, v));
    }, glyph: glyph);
  }

  Widget _groupedCard(
    AppearanceStyle a, {
    required String title,
    required CinematicGlyph glyph,
    required List<Widget> children,
    String? subtitle,
    Color? accent,
  }) {
    final mark = accent ?? a.sectionLabel;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.lg,
        AppSpace.lg,
        AppSpace.lg,
        AppSpace.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(label: title, glyph: glyph, accent: mark),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.body(
                size: 13,
                height: 1.4,
                color: a.textMuted(0.62),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Divider(
            height: 1,
            thickness: 1,
            color: a.cardBorder.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _dangerBlock(AppearanceStyle a, ProgressService progress) {
    return GlassCard(
      tint: AppColors.error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeader(
            label: 'Zona de perigo',
            glyph: CinematicGlyph.fall,
            accent: AppColors.error,
          ),
          const SizedBox(height: 6),
          Text(
            'Ações que não dá para desfazer.',
            style: AppTypography.body(
              size: 13,
              height: 1.35,
              color: a.textMuted(0.62),
            ),
          ),
          const SizedBox(height: 14),
          if (!_confirmReset) ...[
            GhostCta(
              label: 'Rever introdução',
              leading: CinematicGlyph.scroll,
              expanded: true,
              onTap: () async {
                if (!mounted) return;
                await Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const OnboardingScreen(),
                  ),
                  (_) => false,
                );
              },
            ),
            const SizedBox(height: AppSpace.sm),
            GhostCta(
              label: 'Resetar progresso',
              leading: CinematicGlyph.fall,
              danger: true,
              expanded: true,
              onTap: () => setState(() => _confirmReset = true),
            ),
          ] else ...[
            Text(
              'Tem certeza? Todos os passos, dias caminhando e progresso serão apagados. A introdução volta a aparecer.',
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w700,
                color: AppColors.error,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpace.md),
            Row(
              children: [
                Expanded(
                  child: GhostCta(
                    label: 'Cancelar',
                    onTap: () => setState(() => _confirmReset = false),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      final backend = context.read<BackendService>();
                      final league = context.read<LeagueService>();
                      await progress.resetProgress();
                      await backend.saveNow(
                        progress,
                        LeagueService.weekKey(),
                        league: league,
                      );
                      if (!mounted) return;
                      setState(() => _confirmReset = false);
                      await Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => const OnboardingScreen(),
                        ),
                        (_) => false,
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                    ),
                    child: Text(
                      'Confirmar',
                      style: AppTypography.cta(size: 13, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _backupBlock(
    AppearanceStyle a,
    SyncService sync,
    ProgressService progress,
  ) {
    return _groupedCard(
      a,
      title: 'Dados',
      glyph: CinematicGlyph.copy,
      subtitle: 'Exporte um backup ou cole um da área de transferência.',
      children: [
        if (sync.deviceId != null || sync.lastSyncAt != null) ...[
          if (sync.deviceId != null)
            Text(
              'Dispositivo · ${sync.deviceId}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 11,
                weight: FontWeight.w600,
                color: a.textMuted(0.5),
              ),
            ),
          if (sync.lastSyncAt != null) ...[
            if (sync.deviceId != null) const SizedBox(height: 2),
            Text(
              'Último backup · ${_shortDate(sync.lastSyncAt!)}',
              style: AppTypography.body(
                size: 11,
                weight: FontWeight.w600,
                color: a.textMuted(0.5),
              ),
            ),
          ],
          const SizedBox(height: AppSpace.md),
        ],
        Row(
          children: [
            Expanded(
              child: GhostCta(
                label: 'Exportar',
                leading: CinematicGlyph.share,
                onTap: () => _exportProgress(progress, sync),
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: GhostCta(
                label: 'Importar',
                leading: CinematicGlyph.copy,
                onTap: () => _importProgress(progress, sync),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _aboutBlock(AppearanceStyle a) {
    return _groupedCard(
      a,
      title: 'Sobre',
      glyph: CinematicGlyph.spark,
      subtitle: 'Aprenda a Bíblia em missões curtas, no seu ritmo.',
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _versionLabel == null ? 'Versão…' : 'Versão $_versionLabel',
                style: AppTypography.body(
                  size: 13,
                  weight: FontWeight.w700,
                  color: a.text.withValues(alpha: 0.9),
                ),
              ),
            ),
            GestureDetector(
              onTap: _checkingUpdate ? null : _checkForUpdates,
              child: Text(
                _checkingUpdate ? 'Verificando…' : 'Atualizar',
                style: AppTypography.body(
                  size: 13,
                  weight: FontWeight.w800,
                  color: _checkingUpdate ? a.textMuted(0.45) : AppColors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        Text(
          'Traduções bíblicas',
          style: AppTypography.label(
            size: 10,
            color: a.textMuted(0.55),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        for (final t in BibleService.catalog.where((t) => t.available))
          if (t.attribution != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.xs),
              child: Text(
                '${t.shortName} — ${t.attribution}',
                style: AppTypography.body(
                  size: 11,
                  height: 1.35,
                  color: a.textMuted(0.5),
                ),
              ),
            ),
          ],
        const SizedBox(height: AppSpace.sm),
        Text(
          'Estudo (Strong)',
          style: AppTypography.label(
            size: 10,
            color: a.textMuted(0.55),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          BibleStudyService.attribution,
          style: AppTypography.body(
            size: 11,
            height: 1.35,
            color: a.textMuted(0.5),
          ),
        ),
      ],
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  final AppearanceStyle a;
  final bool compact;

  const _SettingsDivider(this.a, {this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 6 : 14),
      child: Divider(
        height: 1,
        thickness: 1,
        color: a.cardBorder.withValues(alpha: 0.55),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AppearanceStyle a;
  final TextEditingController nameController;
  final bool nameDirty;
  final String? photoUrl;
  final String? seed;
  final PortraitStyle portraitStyle;
  final bool signedIn;
  final String? email;
  final DateTime? lastSync;
  final VoidCallback? onSignOut;
  final VoidCallback? onOpenProfile;
  final VoidCallback onSaveName;

  const _ProfileHeader({
    required this.a,
    required this.nameController,
    required this.nameDirty,
    required this.onSaveName,
    required this.portraitStyle,
    required this.signedIn,
    this.email,
    this.lastSync,
    this.onSignOut,
    this.onOpenProfile,
    this.photoUrl,
    this.seed,
  });

  String _whisperDate(DateTime dt) {
    final local = dt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$d/$m · $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final name = nameController.text;
    final caption = signedIn
        ? (email?.trim().isNotEmpty == true
              ? email!
              : 'Progresso na nuvem')
        : 'Entre de novo para sincronizar o caminho.';
    final syncLine = lastSync == null
        ? null
        : 'Nuvem · ${_whisperDate(lastSync!)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              name: name,
              photoUrl: photoUrl,
              seed: seed,
              style: portraitStyle,
              radius: 34,
              borderColor: AppColors.accent.withValues(alpha: 0.82),
              onTap: onOpenProfile,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'VOCÊ',
                          style: AppTypography.label(
                            size: 10,
                            letterSpacing: 1.4,
                            color: a.sectionLabel,
                          ),
                        ),
                      ),
                      if (onSignOut != null)
                        GestureDetector(
                          onTap: onSignOut,
                          child: Text(
                            'Sair',
                            style: AppTypography.body(
                              size: 13,
                              weight: FontWeight.w800,
                              color: a.textMuted(0.62),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    maxLength: 24,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => onSaveName(),
                    cursorColor: AppColors.accent,
                    style: AppTypography.display(
                      size: 22,
                      weight: FontWeight.w800,
                      color: a.text,
                      height: 1.1,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Seu nome no caminho',
                      hintStyle: AppTypography.display(
                        size: 22,
                        weight: FontWeight.w800,
                        color: a.textMuted(0.32),
                        height: 1.1,
                      ),
                      isDense: true,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                  if (nameDirty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: onSaveName,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 2),
                          child: Text(
                            'Salvar nome',
                            style: AppTypography.body(
                              size: 13,
                              weight: FontWeight.w800,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      size: 12,
                      color: a.textMuted(0.58),
                    ),
                  ),
                  if (syncLine != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      syncLine,
                      style: AppTypography.body(
                        size: 11,
                        color: a.textMuted(0.42),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onOpenProfile,
                    child: Text(
                      onOpenProfile == null
                          ? 'Retrato · ${portraitStyle.label}'
                          : 'Retrato · ${portraitStyle.label} · no perfil',
                      style: AppTypography.body(
                        size: 12,
                        weight: FontWeight.w700,
                        color: onOpenProfile == null
                            ? a.textMuted(0.5)
                            : AppColors.accent.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SegmentTrack extends StatelessWidget {
  final List<({String label, bool selected, VoidCallback onTap})> items;

  const _SegmentTrack({required this.items});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: a.cardFillSoft,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: a.cardBorder.withValues(alpha: 0.75)),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: GestureDetector(
                onTap: item.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: item.selected
                        ? AppColors.accent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(
                      size: 11,
                      letterSpacing: 0.4,
                      color: item.selected
                          ? AppColors.inkOnAccent
                          : a.textMuted(0.68),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RhythmPath extends StatelessWidget {
  final ProgressService progress;

  const _RhythmPath({required this.progress});

  static const _options = <({int steps, String pace, String time})>[
    (steps: 1, pace: 'Leve', time: '~3 min'),
    (steps: 2, pace: 'Firme', time: '~6 min'),
    (steps: 3, pace: 'Intenso', time: '~9 min'),
  ];

  @override
  Widget build(BuildContext context) {
    final goal = progress.settings.dailyGoal;
    final selectedIndex = _options.indexWhere((o) => o.steps == goal);

    final litIndex = selectedIndex < 0 ? 0 : selectedIndex;

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final start = w / 6;
              final span = w * 2 / 3;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: start,
                    width: span,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        color: AppColors.accent.withValues(alpha: 0.22),
                      ),
                    ),
                  ),
                  Positioned(
                    left: start,
                    width: span * (litIndex / (_options.length - 1)),
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        color: AppColors.accent.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (final option in _options)
                        Expanded(
                          child: Center(
                            child: _RhythmNode(
                              steps: option.steps,
                              selected: goal == option.steps,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                progress.updateSettings(
                                  progress.settings.copyWith(
                                    dailyGoal: option.steps,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final option in _options)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    progress.updateSettings(
                      progress.settings.copyWith(dailyGoal: option.steps),
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: _RhythmCaption(
                    steps: option.steps,
                    pace: option.pace,
                    time: option.time,
                    selected: goal == option.steps,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _RhythmNode extends StatelessWidget {
  final int steps;
  final bool selected;
  final VoidCallback onTap;

  const _RhythmNode({
    required this.steps,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: selected ? 40 : 32,
        height: selected ? 40 : 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.accent : a.cardFill,
          border: Border.all(
            color: selected
                ? AppColors.accent
                : AppColors.accent.withValues(alpha: 0.45),
            width: selected ? 2 : 1.4,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          '$steps',
          style: AppTypography.title(
            size: selected ? 18 : 15,
            weight: FontWeight.w900,
            color: selected ? AppColors.inkOnAccent : a.text,
          ),
        ),
      ),
    );
  }
}

class _RhythmCaption extends StatelessWidget {
  final int steps;
  final String pace;
  final String time;
  final bool selected;

  const _RhythmCaption({
    required this.steps,
    required this.pace,
    required this.time,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final label = steps == 1 ? '1 passo' : '$steps passos';
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.title(
            size: 13,
            color: selected ? AppColors.accent : a.text,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$pace · $time',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.body(
            size: 11,
            color: a.textMuted(selected ? 0.72 : 0.5),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 2,
          width: selected ? 28 : 0,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ],
    );
  }
}

class _ModeStation extends StatelessWidget {
  final DifficultyMeta meta;
  final bool locked;
  final bool selected;
  final bool cleared;
  final VoidCallback onTap;

  const _ModeStation({
    required this.meta,
    required this.locked,
    required this.selected,
    required this.cleared,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final accent = DifficultyVisuals.accentFor(meta.difficulty);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        clipBehavior: Clip.antiAlias,
        decoration: DifficultyVisuals.stationCard(
          accent: accent,
          baseFill: a.cardFillSoft,
          lit: selected && !locked,
          sealed: cleared,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                width: 5,
                color: locked
                    ? accent.withValues(alpha: 0.22)
                    : selected
                    ? accent
                    : accent.withValues(alpha: 0.4),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Row(
                    children: [
                      Opacity(
                        opacity: locked ? 0.46 : 1,
                        child: ModeEmblem(
                          difficulty: meta.difficulty,
                          size: 40,
                          locked: locked,
                          cleared: cleared,
                          active: selected && !locked,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Opacity(
                          opacity: locked ? 0.55 : 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meta.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.title(
                                  size: 16,
                                  color: selected && !locked
                                      ? DifficultyVisuals.onSky(accent)
                                      : a.text,
                                ),
                              ),
                              if (meta.subtitle.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  locked
                                      ? 'Conclua o modo anterior'
                                      : meta.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.body(
                                    size: 12,
                                    color: a.textMuted(selected ? 0.72 : 0.55),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (locked)
                        CinematicIcon(
                          glyph: CinematicGlyph.lock,
                          size: 16,
                          accent: a.textMuted(0.42),
                          framed: false,
                        )
                      else if (selected)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent,
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.45),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        )
                      else if (cleared)
                        CinematicIcon(
                          glyph: CinematicGlyph.check,
                          size: 16,
                          accent: accent,
                          framed: false,
                        ),
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

/// Switch do céu — quatro estágios, de ponta a ponta do card.
class _SkySwitch extends StatefulWidget {
  final AppearanceMode selected;
  final ValueChanged<AppearanceMode> onChanged;

  const _SkySwitch({required this.selected, required this.onChanged});

  static const modes = AppearanceMode.values;
  static const trackHeight = 100.0;

  @override
  State<_SkySwitch> createState() => _SkySwitchState();
}

class _SkySwitchState extends State<_SkySwitch>
    with TickerProviderStateMixin {
  static const _modes = _SkySwitch.modes;
  static const _slideDuration = Duration(milliseconds: 520);
  static const _slideCurve = Curves.easeOutCubic;

  late final AnimationController _slide;
  late final AnimationController _life;
  double _downX = 0;
  int _lastSlot = -1;

  int get _index {
    final i = _modes.indexOf(widget.selected);
    return i < 0 ? 0 : i;
  }

  double get _visual => _slide.value;

  AppearanceMode get _visualMode {
    final i = _visual.round().clamp(0, _modes.length - 1);
    return _modes[i];
  }

  String get _caption => switch (_visualMode) {
    AppearanceMode.morning => 'Céu claro',
    AppearanceMode.afternoon => 'Luz baixa',
    AppearanceMode.night => 'Céu escuro',
    AppearanceMode.automatic => 'Segue o horário',
  };

  Color _accentFor(AppearanceMode mode) => switch (mode) {
    AppearanceMode.morning => AppColors.accent,
    AppearanceMode.afternoon => AppColors.ember,
    AppearanceMode.night => AppColors.orchid,
    AppearanceMode.automatic => AppColors.slate,
  };

  Color get _accentNow {
    final x = _visual.clamp(0.0, 3.0);
    final i = x.floor().clamp(0, 2);
    final t = Curves.easeInOut.transform(x - i);
    return Color.lerp(
      _accentFor(_modes[i]),
      _accentFor(_modes[i + 1]),
      t,
    )!;
  }

  String _shortLabel(AppearanceMode mode) => switch (mode) {
    AppearanceMode.automatic => 'Auto',
    _ => mode.label,
  };

  double _focus(int i) {
    final d = (_visual - i).abs();
    return (1.0 - d).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _slide = AnimationController(
      vsync: this,
      duration: _slideDuration,
      lowerBound: 0,
      upperBound: (_modes.length - 1).toDouble(),
      value: _index.toDouble(),
    );
    _life = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _lastSlot = _index;
  }

  @override
  void didUpdateWidget(covariant _SkySwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected == widget.selected) return;
    _lastSlot = _index;
    if (!_slide.isAnimating) {
      _slide.animateTo(
        _index.toDouble(),
        duration: _slideDuration,
        curve: _slideCurve,
      );
    }
  }

  @override
  void dispose() {
    _slide.dispose();
    _life.dispose();
    super.dispose();
  }

  void _commit(int index) {
    final next = _modes[index.clamp(0, _modes.length - 1)];
    if (next != widget.selected) {
      if (_lastSlot != index) HapticFeedback.selectionClick();
      widget.onChanged(next);
    }
    _lastSlot = index;
  }

  void _goTo(int index) {
    _slide.animateTo(
      index.toDouble(),
      duration: _slideDuration,
      curve: _slideCurve,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _commit(index);
    });
  }

  void _pickSnap(double localX, double width) {
    if (width <= 0) return;
    final i = (localX / width * _modes.length)
        .floor()
        .clamp(0, _modes.length - 1);
    _goTo(i);
  }

  void _follow(double localX, double width) {
    if (width <= 0) return;
    final v = ((localX / width) * _modes.length - 0.5)
        .clamp(0.0, (_modes.length - 1).toDouble());
    final slot = v.round();
    if (slot != _lastSlot) {
      _lastSlot = slot;
      HapticFeedback.selectionClick();
    }
    _slide.stop();
    _slide.value = v;
  }

  void _endDrag() {
    final snap = _visual.round().clamp(0, _modes.length - 1);
    _goTo(snap);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);

    return Column(
      children: [
        MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.05,
          child: SizedBox(
            height: _SkySwitch.trackHeight,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) => _downX = d.localPosition.dx,
                  onTap: () => _pickSnap(_downX, w),
                  onHorizontalDragStart: (d) =>
                      _follow(d.localPosition.dx, w),
                  onHorizontalDragUpdate: (d) =>
                      _follow(d.localPosition.dx, w),
                  onHorizontalDragEnd: (_) => _endDrag(),
                  onHorizontalDragCancel: _endDrag,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(color: a.cardBorder, width: 1.2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.md - 0.6),
                      child: AnimatedBuilder(
                        animation: _slide,
                        builder: (context, _) {
                          return Stack(
                            children: [
                              Row(
                                children: [
                                  for (var i = 0; i < _modes.length; i++)
                                    Expanded(
                                      child: _SkyStageSky(
                                        mode: _modes[i],
                                        focus: _focus(i),
                                      ),
                                    ),
                                ],
                              ),
                              Row(
                                children: [
                                  for (var i = 0; i < _modes.length; i++)
                                    Expanded(
                                      child: _SkyStageFace(
                                        mode: _modes[i],
                                        label: _shortLabel(_modes[i]),
                                        accent: _accentFor(_modes[i]),
                                        focus: _focus(i),
                                        selected: i == _visual.round(),
                                        life: _life,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _slide,
          builder: (context, _) {
            return Column(
              children: [
                Text(
                  _visualMode.label,
                  style: AppTypography.title(size: 15, color: _accentNow),
                ),
                const SizedBox(height: 2),
                Text(
                  _caption,
                  style: AppTypography.body(
                    size: 12,
                    color: a.textMuted(0.68),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SkyStageSky extends StatelessWidget {
  final AppearanceMode mode;
  final double focus;

  const _SkyStageSky({required this.mode, required this.focus});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AmbientAtmosphere(phase: AppearanceStyle.resolve(mode).phase),
        IgnorePointer(
          child: ColoredBox(
            color: Color.fromRGBO(0, 0, 0, 0.46 * (1 - focus)),
          ),
        ),
      ],
    );
  }
}

class _SkyStageFace extends StatelessWidget {
  final AppearanceMode mode;
  final String label;
  final Color accent;
  final double focus;
  final bool selected;
  final Animation<double> life;

  const _SkyStageFace({
    required this.mode,
    required this.label,
    required this.accent,
    required this.focus,
    required this.selected,
    required this.life,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(
      Colors.white.withValues(alpha: 0.7),
      accent,
      Curves.easeOut.transform(focus),
    )!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Transform.scale(
                scale: 0.86 + 0.22 * focus,
                child: selected
                    ? AnimatedBuilder(
                        animation: life,
                        builder: (context, _) {
                          return CustomPaint(
                            size: const Size(38, 38),
                            painter: _SkyMarkPainter(
                              mode: mode,
                              color: color,
                              t: life.value,
                              alive: true,
                              amp: 1,
                            ),
                          );
                        },
                      )
                    : CustomPaint(
                        size: const Size(38, 38),
                        painter: _SkyMarkPainter(
                          mode: mode,
                          color: color,
                          t: 0,
                          alive: false,
                          amp: 0,
                        ),
                      ),
              ),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0.2,
              color: color,
              weight: focus > 0.55 ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Marcas do switch: sol entre nuvens, sol, lua entre nuvens, ciclo.
class _SkyMarkPainter extends CustomPainter {
  final AppearanceMode mode;
  final Color color;
  final double t;
  final bool alive;
  final double amp;

  _SkyMarkPainter({
    required this.mode,
    required this.color,
    required this.t,
    required this.alive,
    this.amp = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = size.shortestSide;
    final wave = t * math.pi * 2;
    final breathe = 0.5 + 0.5 * math.sin(wave);
    final drift = math.sin(wave) * amp;
    final drift2 = math.cos(wave) * amp;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final soft = Paint()
      ..color = color.withValues(alpha: 0.86)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    if (alive) {
      canvas.drawCircle(
        c,
        s * (0.46 + breathe * 0.05 * amp),
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: (0.16 + breathe * 0.12) * amp),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: s * 0.52)),
      );
    }

    switch (mode) {
      case AppearanceMode.morning:
        _sun(
          canvas,
          c + Offset(0, -s * 0.08),
          s * (0.9 + breathe * 0.04 * amp),
          fill,
          spin: wave,
        );
        _cloud(
          canvas,
          c + Offset(-s * 0.08 + drift * s * 0.05, s * 0.18),
          s * 0.72,
          fill,
        );
        _cloud(
          canvas,
          c + Offset(s * 0.18 + drift2 * s * 0.04, s * 0.22),
          s * 0.5,
          soft,
        );
      case AppearanceMode.afternoon:
        _sun(
          canvas,
          c + Offset(0, -s * 0.06),
          s * (0.94 + breathe * 0.05 * amp),
          fill,
          spin: wave * 0.7,
        );
        _cloud(
          canvas,
          c + Offset(s * 0.02 + drift * s * 0.04, s * 0.28),
          s * 0.55,
          soft,
        );
      case AppearanceMode.night:
        _star(
          canvas,
          c + Offset(s * 0.28, -s * 0.28),
          s * (0.08 + breathe * 0.025 * amp),
          Paint()
            ..color = color.withValues(alpha: 0.4 + breathe * 0.6 * amp)
            ..isAntiAlias = true,
        );
        _moon(
          canvas,
          c + Offset(-s * 0.04, -s * 0.08 + drift * s * 0.025),
          s * 0.88,
          fill,
        );
        _cloud(
          canvas,
          c + Offset(-s * 0.06 + drift * s * 0.04, s * 0.2),
          s * 0.7,
          fill,
        );
        _cloud(
          canvas,
          c + Offset(s * 0.2 + drift2 * s * 0.03, s * 0.24),
          s * 0.48,
          soft,
        );
      case AppearanceMode.automatic:
        _clock(canvas, c, s, fill, alive: alive);
    }
  }

  void _sun(
    Canvas canvas,
    Offset c,
    double s,
    Paint paint, {
    double spin = 0,
  }) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(spin);
    canvas.drawCircle(Offset.zero, s * 0.16, paint);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 2;
      final len = s * (i.isEven ? 0.13 : 0.09);
      final inner = s * 0.22;
      final p1 = Offset(math.cos(a) * inner, math.sin(a) * inner);
      final p2 = Offset(
        math.cos(a) * (inner + len),
        math.sin(a) * (inner + len),
      );
      final perp = Offset(-math.sin(a), math.cos(a)) * s * 0.04;
      canvas.drawPath(
        Path()
          ..moveTo(p1.dx + perp.dx, p1.dy + perp.dy)
          ..lineTo(p2.dx + perp.dx, p2.dy + perp.dy)
          ..lineTo(p2.dx - perp.dx, p2.dy - perp.dy)
          ..lineTo(p1.dx - perp.dx, p1.dy - perp.dy)
          ..close(),
        paint,
      );
    }
    canvas.restore();
  }

  void _cloud(Canvas canvas, Offset c, double s, Paint paint) {
    canvas.drawCircle(c + Offset(-s * 0.18, 0), s * 0.16, paint);
    canvas.drawCircle(c + Offset(s * 0.02, -s * 0.08), s * 0.2, paint);
    canvas.drawCircle(c + Offset(s * 0.2, 0), s * 0.14, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c + Offset(0, s * 0.06),
          width: s * 0.62,
          height: s * 0.2,
        ),
        Radius.circular(s * 0.1),
      ),
      paint,
    );
  }

  void _moon(Canvas canvas, Offset c, double s, Paint paint) {
    final moon = Path()..addOval(Rect.fromCircle(center: c, radius: s * 0.2));
    final cut = Path()
      ..addOval(
        Rect.fromCircle(
          center: c + Offset(s * 0.1, -s * 0.05),
          radius: s * 0.17,
        ),
      );
    canvas.drawPath(Path.combine(PathOperation.difference, moon, cut), paint);
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2 - math.pi / 2;
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
      final b = a + math.pi / 4;
      final q = c + Offset(math.cos(b) * r * 0.35, math.sin(b) * r * 0.35);
      path.lineTo(q.dx, q.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _clock(
    Canvas canvas,
    Offset c,
    double s,
    Paint paint, {
    required bool alive,
  }) {
    final ring = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.07
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawCircle(c, s * 0.32, ring);

    final tick = Paint()
      ..color = paint.color
      ..strokeWidth = s * 0.045
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2 - math.pi / 2;
      final inner = s * 0.24;
      final outer = s * 0.32;
      canvas.drawLine(
        c + Offset(math.cos(a) * inner, math.sin(a) * inner),
        c + Offset(math.cos(a) * outer, math.sin(a) * outer),
        tick,
      );
    }

    final now = DateTime.now();
    final hour = ((now.hour % 12) + now.minute / 60) / 12 * math.pi * 2 -
        math.pi / 2;
    final minute = (now.minute + now.second / 60) / 60 * math.pi * 2 -
        math.pi / 2;
    final second = alive
        ? (now.second + now.millisecond / 1000) / 60 * math.pi * 2 - math.pi / 2
        : minute;

    void hand(double angle, double len, double weight) {
      canvas.drawLine(
        c,
        c + Offset(math.cos(angle) * s * len, math.sin(angle) * s * len),
        Paint()
          ..color = paint.color
          ..strokeWidth = s * weight
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true,
      );
    }

    hand(hour, 0.16, 0.07);
    hand(minute, 0.24, 0.05);
    if (alive) {
      hand(second, 0.26, 0.03);
    }
    canvas.drawCircle(c, s * 0.035, paint);
  }

  @override
  bool shouldRepaint(covariant _SkyMarkPainter old) =>
      old.mode != mode ||
      old.color != color ||
      old.t != t ||
      old.alive != alive ||
      old.amp != amp;
}

