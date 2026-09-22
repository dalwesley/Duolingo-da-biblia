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
import '../widgets/app_update_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/hero_card_atmosphere.dart';
import '../widgets/immersive_background.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/user_avatar.dart';
import '../widgets/portrait_face.dart';
import 'login_screen.dart';
import 'paywall_screen.dart';
import 'onboarding_screen.dart';

const _genesisTrailSlug = 'genesis-1-11';

/// Abre ajustes como página empurrada (engrenagem no perfil).
void openSettings(BuildContext context) {
  final progress = context.read<ProgressService>();
  final mode = progress.settings.appearanceMode;
  final appearance = AppearanceStyle.resolve(mode);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) => Appearance(
        mode: mode,
        style: appearance,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ImmersiveBackground(
            appearance: appearance,
            child: SettingsScreen(
              topBar: TopBar(
                inline: true,
                immersive: true,
                dark: appearance.onDark,
                title: 'Ajustes',
                subtitle: 'Conta · Preferências',
                leadingGlyph: CinematicGlyph.tune,
                chromeAccent: AppColors.slate,
                onBack: () => Navigator.pop(ctx),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class SettingsScreen extends StatefulWidget {
  final Widget? topBar;

  const SettingsScreen({super.key, this.topBar});

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
            subtitle: 'Quantas missões por dia cabem no seu dia.',
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
          if (i > 0) const SizedBox(height: 8),
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
    final prev = progress.difficultyForTrail(_genesisTrailSlug);
    progress.setTrailDifficulty(
      _genesisTrailSlug,
      meta.difficulty.id,
      missionSlugs: _genesisMissionSlugs,
      pin: true,
    );
    if (prev != null &&
        prev != meta.difficulty.id &&
        _genesisMissionSlugs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Progresso da trilha reiniciado neste modo.',
            style: AppTypography.body(color: AppColors.textOnDark),
          ),
          backgroundColor: AppColors.nightElevated,
        ),
      );
    }
  }

  Widget _skyPicker(ProgressService progress) {
    final selected = progress.settings.appearanceMode;
    final modes = AppearanceMode.values;
    return Column(
      children: [
        for (var row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var col = 0; col < 2; col++) ...[
                if (col > 0) const SizedBox(width: 8),
                Expanded(
                  child: _SkyStation(
                    mode: modes[row * 2 + col],
                    selected: selected == modes[row * 2 + col],
                    onTap: () {
                      HapticFeedback.selectionClick();
                      progress.updateSettings(
                        progress.settings.copyWith(
                          appearanceMode: modes[row * 2 + col],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _identityCard(ProgressService progress, AppearanceStyle a) {
    final backend = context.watch<BackendService>();
    return GlassCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            label: 'Você',
            glyph: CinematicGlyph.humanity,
            accent: a.sectionLabel,
            trailing: backend.isSignedIn
                ? GestureDetector(
                    onTap: backend.isGoogleBusy
                        ? null
                        : () => _signOutGoogle(backend),
                    child: Text(
                      'Sair',
                      style: AppTypography.body(
                        size: 13,
                        weight: FontWeight.w800,
                        color: a.textMuted(0.72),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          _ProfileHeader(
            a: a,
            nameController: _nameController,
            nameDirty: _nameDirty,
            photoUrl: backend.userPhotoUrl,
            seed: backend.uid,
            portraitStyle: progress.settings.portraitStyle,
            hasPhoto: PortraitFace.isUsablePhotoUrl(backend.userPhotoUrl),
            onPortraitStyle: (style) {
              HapticFeedback.selectionClick();
              progress.updateSettings(
                progress.settings.copyWith(portraitStyle: style),
              );
            },
            onSaveName: () => _saveName(progress),
          ),
          _SettingsDivider(a),
          _sessionBlock(a, backend),
        ],
      ),
    );
  }

  Widget _sessionBlock(AppearanceStyle a, BackendService backend) {
    final signedIn = backend.isSignedIn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          signedIn
              ? (backend.userEmail ??
                    backend.userDisplayName ??
                    'Progresso na nuvem')
              : 'Entre de novo para sincronizar o caminho.',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.body(size: 12, color: a.textMuted(0.68)),
        ),
        if (backend.isActive && backend.lastCloudSaveAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Última sync · ${_shortDate(backend.lastCloudSaveAt!)}',
            style: AppTypography.body(size: 11, color: a.textMuted(0.5)),
          ),
        ],
      ],
    );
  }

  Widget _membershipCard(AppearanceStyle a) {
    final plus = context.watch<SubscriptionService>().isPeregrinoPlus;
    return GlassCard(
      elevated: plus,
      accent: plus,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const PaywallScreen()),
      ),
      child: Stack(
        children: [
          if (plus)
            const Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.22,
                  child: HeroCardAtmosphere(mood: HeroCardMood.alive),
                ),
              ),
            ),
          Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.crown,
                size: 44,
                accent: AppColors.accent,
                glowing: plus,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Peregrino+',
                      style: AppTypography.title(size: 16, color: a.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plus
                          ? 'Assinatura ativa · mais espaço na companhia'
                          : 'Mais espaço para companhia no caminho',
                      style: AppTypography.body(
                        size: 12,
                        height: 1.3,
                        color: a.textMuted(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (plus)
                const SoftBadge(
                  text: 'Ativo',
                  glyph: CinematicGlyph.check,
                  accent: AppColors.accent,
                )
              else
                Text(
                  'Ver',
                  style: AppTypography.body(
                    size: 13,
                    weight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CinematicIcon(
            glyph: glyph,
            size: 40,
            accent: value ? tone : a.textMuted(0.45),
            glowing: false,
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
                  style: AppTypography.body(size: 12, color: a.textMuted(0.62)),
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
    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            label: title,
            glyph: glyph,
            accent: accent ?? a.sectionLabel,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTypography.body(
                size: 13,
                height: 1.35,
                color: a.textMuted(0.62),
              ),
            ),
          ],
          const SizedBox(height: 14),
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
  final bool hasPhoto;
  final ValueChanged<PortraitStyle> onPortraitStyle;
  final VoidCallback onSaveName;

  const _ProfileHeader({
    required this.a,
    required this.nameController,
    required this.nameDirty,
    required this.onSaveName,
    required this.portraitStyle,
    required this.hasPhoto,
    required this.onPortraitStyle,
    this.photoUrl,
    this.seed,
  });

  @override
  Widget build(BuildContext context) {
    final name = nameController.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: UserAvatar(
            name: name,
            photoUrl: photoUrl,
            seed: seed,
            style: portraitStyle,
            radius: 40,
            borderColor: AppColors.accent.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Como te chamamos',
          style: AppTypography.label(
            size: 10,
            letterSpacing: 0.8,
            color: a.textMuted(0.55),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 4, 8, 4),
          decoration: BoxDecoration(
            color: a.cardFillSoft,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: a.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  maxLength: 24,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onSaveName(),
                  cursorColor: AppColors.accent,
                  style: AppTypography.title(size: 18, color: a.text),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Seu nome no caminho',
                    hintStyle: AppTypography.title(
                      size: 18,
                      color: a.textMuted(0.35),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              if (nameDirty)
                GestureDetector(
                  onTap: onSaveName,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Text(
                      'Salvar',
                      style: AppTypography.body(
                        size: 13,
                        weight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Retrato',
          style: AppTypography.label(
            size: 10,
            letterSpacing: 0.8,
            color: a.textMuted(0.55),
          ),
        ),
        const SizedBox(height: 8),
        _SegmentTrack(
          items: [
            for (final style in PortraitStyle.values)
              (
                label: style.label,
                selected: portraitStyle == style,
                onTap: () => onPortraitStyle(style),
              ),
          ],
        ),
        if (portraitStyle == PortraitStyle.photo && !hasPhoto) ...[
          const SizedBox(height: 10),
          Text(
            'Esta conta não tem retrato — o avatar entra no lugar da foto.',
            style: AppTypography.body(size: 12, color: a.textMuted(0.55)),
          ),
        ],
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
    return Column(
      children: [
        for (var i = 0; i < _options.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _RhythmStation(
            steps: _options[i].steps,
            pace: _options[i].pace,
            time: _options[i].time,
            selected: goal == _options[i].steps,
            onTap: () {
              HapticFeedback.selectionClick();
              progress.updateSettings(
                progress.settings.copyWith(dailyGoal: _options[i].steps),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _RhythmStation extends StatelessWidget {
  final int steps;
  final String pace;
  final String time;
  final bool selected;
  final VoidCallback onTap;

  const _RhythmStation({
    required this.steps,
    required this.pace,
    required this.time,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final label = steps == 1 ? '1 passo' : '$steps passos';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: selected ? AppMetrics.accentFill(alpha: 0.22) : a.cardFillSoft,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected
                ? AppMetrics.accentBorder(alpha: 0.85)
                : a.cardBorder,
            width: selected ? 1.75 : 1.25,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.accent : a.cardFill,
                border: Border.all(
                  color: selected ? AppColors.accent : a.cardBorder,
                ),
              ),
              child: Text(
                '$steps',
                style: AppTypography.title(
                  size: 18,
                  weight: FontWeight.w900,
                  color: selected ? AppColors.inkOnAccent : a.text,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title(size: 16, color: a.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$pace · $time',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      size: 12,
                      color: a.textMuted(selected ? 0.78 : 0.58),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const SoftBadge(
                text: 'Atual',
                glyph: CinematicGlyph.check,
                accent: AppColors.accent,
              ),
          ],
        ),
      ),
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
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: locked
              ? a.cardFillSoft.withValues(alpha: 0.45)
              : selected
              ? DifficultyVisuals.chipFill(accent, alpha: 0.28)
              : a.cardFillSoft,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: locked
                ? a.cardBorder.withValues(alpha: 0.35)
                : selected
                ? accent.withValues(alpha: 0.9)
                : a.cardBorder,
            width: selected ? 1.75 : 1.25,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Opacity(
              opacity: locked ? 0.45 : 1,
              child: CinematicIcon(
                glyph: locked
                    ? CinematicGlyph.lock
                    : DifficultyVisuals.glyphFor(meta.difficulty),
                size: 40,
                accent: locked ? a.textMuted(0.5) : accent,
                glowing: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Opacity(
                opacity: locked ? 0.5 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(size: 16, color: a.text),
                    ),
                    if (meta.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        meta.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(
                          size: 12,
                          color: a.textMuted(selected ? 0.78 : 0.58),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (locked)
              Text(
                'Bloqueado',
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 0.4,
                  color: a.textMuted(0.45),
                ),
              )
            else if (selected)
              SoftBadge(
                text: 'Atual',
                glyph: CinematicGlyph.check,
                accent: accent,
              )
            else if (cleared)
              SoftBadge(
                text: 'Concluído',
                glyph: CinematicGlyph.check,
                accent: accent,
              ),
          ],
        ),
      ),
    );
  }
}

class _SkyStation extends StatelessWidget {
  final AppearanceMode mode;
  final bool selected;
  final VoidCallback onTap;

  const _SkyStation({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  String get _caption => switch (mode) {
    AppearanceMode.morning => 'Céu claro',
    AppearanceMode.afternoon => 'Luz baixa',
    AppearanceMode.night => 'Céu escuro',
    AppearanceMode.automatic => 'Segue o horário',
  };

  Color get _accent => switch (mode) {
    AppearanceMode.morning => AppColors.accent,
    AppearanceMode.afternoon => AppColors.ember,
    AppearanceMode.night => AppColors.orchid,
    AppearanceMode.automatic => AppColors.slate,
  };

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final accent = _accent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: selected
              ? AppMetrics.accentFill(color: accent, alpha: 0.22)
              : a.cardFillSoft,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected
                ? AppMetrics.accentBorder(color: accent, alpha: 0.85)
                : a.cardBorder,
            width: selected ? 1.75 : 1.25,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CinematicIcon(
              glyph: mode.glyph,
              size: 32,
              accent: accent,
              glowing: false,
            ),
            const SizedBox(height: 8),
            Text(
              mode.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title(size: 14, color: a.text),
            ),
            const SizedBox(height: 2),
            Text(
              _caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 11,
                color: a.textMuted(selected ? 0.78 : 0.58),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
