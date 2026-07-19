import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/question_bank.dart';
import '../models/difficulty.dart';
import '../services/backend_service.dart';
import '../services/bible_service.dart';
import '../services/bible_study_service.dart';
import '../services/league_service.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/layout_utils.dart';
import '../utils/spiritual_growth.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/user_avatar.dart';
import 'login_screen.dart';

const _genesisTrailSlug = 'genesis-1-11';

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
  bool _nameInitialized = false;
  bool _nameDirty = false;
  List<DifficultyMeta>? _difficulties;
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    _loadDifficulties();
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    if (!mounted) return;
    final current = context.read<ProgressService>().userName;
    final dirty = _nameController.text.trim() != current;
    if (dirty != _nameDirty) setState(() => _nameDirty = dirty);
  }

  Future<void> _loadDifficulties() async {
    final items = await QuestionBank.instance.getDifficulties();
    if (mounted) setState(() => _difficulties = items);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  Widget _reveal(int index, Widget child) {
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
    final backend = context.watch<BackendService>();
    final a = Appearance.of(context);
    final growth = SpiritualGrowth.fromStreak(progress.streak);

    if (!_nameInitialized) {
      _nameInitialized = true;
      // Evita notificar o listener no meio do build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
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
      children: [
        if (widget.topBar != null) ...[
          widget.topBar!,
          const SizedBox(height: 16),
        ],

        _reveal(
          0,
          _ProfileHero(
            progress: progress,
            backend: backend,
            growth: growth,
            a: a,
            nameController: _nameController,
            nameDirty: _nameDirty,
            onSaveName: () => _saveName(progress),
          ),
        ),

        const SizedBox(height: 24),
        _reveal(
          1,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeading(a, 'Seu caminho', 'Ritmo e profundidade do estudo'),
              GlassCard(
                padding: AppMetrics.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inlineLabel(a, 'Ritmo diário', 'Missões por dia'),
                    const SizedBox(height: 12),
                    _dailyGoalPicker(progress, a),
                    _SettingsDivider(a),
                    _inlineLabel(a, 'Dificuldade', 'Gênesis 1–11'),
                    const SizedBox(height: 10),
                    _difficultyPicker(progress, a),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _reveal(
          2,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeading(a, 'Experiência', 'Visual, som e lembretes'),
              GlassCard(
                padding: AppMetrics.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inlineLabel(a, 'Aparência', 'Luz do app'),
                    const SizedBox(height: 12),
                    _themeGrid(progress, a),
                    _SettingsDivider(a),
                    _toggle(
                      a,
                      'Sons',
                      'Efeitos nas lições',
                      progress.settings.sound,
                      (v) {
                        progress.updateSettings(
                          progress.settings.copyWith(sound: v),
                        );
                        SoundService.instance.setEnabled(v);
                      },
                    ),
                    _SettingsDivider(a),
                    _toggle(
                      a,
                      'Notificações',
                      'Lembretes de meta, missões, prática e mais',
                      progress.settings.notifications,
                      (v) async {
                        await progress.updateSettings(
                          progress.settings.copyWith(notifications: v),
                        );
                        await NotificationService.instance.syncFromProgress(
                          progress,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _reveal(
          3,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeading(a, 'Conta', 'Google e nuvem'),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: _cloudCard(a),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),
        _reveal(
          4,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeading(a, 'Backup de emergência', 'Exporta o mesmo mapa do Firestore (v2)'),
              const SizedBox(height: 2),
              GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exporte um backup ou importe da área de transferência.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: a.textMuted(0.78),
                ),
              ),
              if (sync.deviceId != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Dispositivo · ${sync.deviceId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: a.textMuted(0.55),
                  ),
                ),
              ],
              if (sync.lastSyncAt != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Último backup · ${_shortDate(sync.lastSyncAt!)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: a.textMuted(0.55),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _exportProgress(progress, sync),
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: const Text('Exportar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: a.text,
                        side: BorderSide(color: a.cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _importProgress(progress, sync),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Importar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: a.text,
                        side: BorderSide(color: a.cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),
        _reveal(
          5,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeading(a, 'Sobre', 'Trilha · versão 1.0.0'),
              const SizedBox(height: 2),
              GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aprenda a Bíblia em missões curtas, no seu ritmo.',
                style: AppTypography.body(
                  size: 13,
                  height: 1.4,
                  color: a.textMuted(0.78),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Traduções bíblicas',
                style: AppTypography.label(
                  size: 10,
                  color: a.textMuted(0.65),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              for (final t in BibleService.catalog.where((t) => t.available))
                if (t.attribution != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${t.shortName} — ${t.attribution}',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.35,
                        color: a.textMuted(0.55),
                      ),
                    ),
                  ),
                ],
              const SizedBox(height: 12),
              Text(
                'Estudo (Strong)',
                style: AppTypography.label(
                  size: 10,
                  color: a.textMuted(0.65),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                BibleStudyService.attribution,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: a.textMuted(0.55),
                ),
              ),
            ],
          ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),
        _reveal(
          6,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeading(
                a,
                'Zona de perigo',
                'Apaga todo o progresso neste aparelho',
                accent: AppColors.error,
              ),
              const SizedBox(height: 2),
        if (!_confirmReset)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() => _confirmReset = true),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.45),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
              child: const Text(
                'Resetar progresso',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Tem certeza? Todos os passos, dias caminhando e progresso serão apagados.',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _confirmReset = false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text('Confirmar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
            ],
          ),
        ),
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

  Widget _sectionHeading(
    AppearanceStyle a,
    String title,
    String subtitle, {
    Color? accent,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.title(
              size: 17,
              color: accent ?? a.text,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: AppTypography.body(
              size: 12,
              color: a.textMuted(0.62),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inlineLabel(AppearanceStyle a, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.title(size: 14, color: a.text),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTypography.body(size: 11, color: a.textMuted(0.58)),
        ),
      ],
    );
  }

  void _saveName(ProgressService progress) {
    FocusScope.of(context).unfocus();
    progress.setUserName(_nameController.text);
    setState(() => _nameDirty = false);
    HapticFeedback.lightImpact();
  }

  Widget _dailyGoalPicker(ProgressService progress, AppearanceStyle a) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: a.cardFillSoft,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: a.cardBorder.withValues(alpha: 0.65)),
      ),
      child: Row(
        children: [1, 2, 3].map((goal) {
          final selected = progress.settings.dailyGoal == goal;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                progress.updateSettings(
                  progress.settings.copyWith(dailyGoal: goal),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: selected ? AppGradients.gold : null,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.32),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$goal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        color: selected
                            ? AppColors.inkOnAccent
                            : a.textMuted(0.85),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goal == 1 ? 'passo' : 'passos',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: selected
                            ? AppColors.inkOnAccent.withValues(alpha: 0.85)
                            : a.textMuted(0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _difficultyPicker(ProgressService progress, AppearanceStyle a) {
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
      children: items.map((meta) {
        final isSelected = selectedId == meta.difficulty.id;
        final isLast = meta == items.last;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                progress.setTrailDifficulty(
                  _genesisTrailSlug,
                  meta.difficulty.id,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppGradients.gold : null,
                  color: isSelected ? null : a.cardFillSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: 0.45)
                        : a.cardBorder.withValues(alpha: 0.5),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.28),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    CinematicIcon(
                      glyph: DifficultyVisuals.glyphFor(meta.difficulty),
                      size: 26,
                      accent: isSelected
                          ? AppColors.inkOnAccent
                          : a.textMuted(0.75),
                      framed: false,
                      glowing: false,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meta.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? AppColors.inkOnAccent
                                  : a.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meta.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              color: isSelected
                                  ? AppColors.inkOnAccent.withValues(
                                      alpha: 0.75,
                                    )
                                  : a.textMuted(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_rounded,
                        color: AppColors.inkOnAccent,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _themeGrid(ProgressService progress, AppearanceStyle a) {
    final selected = progress.settings.appearanceMode;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final cellW = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: AppearanceMode.values.map((mode) {
            final isSelected = selected == mode;
            return SizedBox(
              width: cellW,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    progress.updateSettings(
                      progress.settings.copyWith(appearanceMode: mode),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppGradients.gold : null,
                      color: isSelected ? null : a.cardFillSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent.withValues(alpha: 0.5)
                            : a.cardBorder.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          mode.icon,
                          size: 18,
                          color: isSelected
                              ? AppColors.inkOnAccent
                              : a.textMuted(0.8),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            mode.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? AppColors.inkOnAccent
                                  : a.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _cloudCard(AppearanceStyle a) {
    final backend = context.watch<BackendService>();
    final google = backend.isGoogleSignedIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: google ? AppColors.teal : a.textMuted(0.4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                google ? 'Conta Google conectada' : 'Conta desconectada',
                style: TextStyle(fontWeight: FontWeight.w800, color: a.text),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          google
              ? (backend.userEmail ??
                    'Progresso sincronizado automaticamente com a nuvem.')
              : 'Faça login novamente para sincronizar a nuvem.',
          style: TextStyle(
            fontSize: 12,
            height: 1.35,
            color: a.textMuted(0.78),
          ),
        ),
        if (google && backend.userDisplayName != null) ...[
          const SizedBox(height: 4),
          Text(
            backend.userDisplayName!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: a.text,
            ),
          ),
        ],
        if (google) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: backend.isGoogleBusy
                  ? null
                  : () => _signOutGoogle(backend),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sair da conta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: a.text,
                side: BorderSide(color: a.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
        if (backend.isActive && backend.lastCloudSaveAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Última sync · ${_shortDate(backend.lastCloudSaveAt!)}',
            style: TextStyle(fontSize: 11, color: a.textMuted(0.55)),
          ),
        ],
      ],
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
    progress.resetMemoryToDefaults();
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
      ShareParams(text: json, subject: 'Backup Trilha'),
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
    await backend.saveNow(
      progress,
      LeagueService.weekKey(),
      league: league,
    );
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
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.title(size: 14, color: a.text),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTypography.body(
                    size: 12,
                    color: a.textMuted(0.62),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  final AppearanceStyle a;

  const _SettingsDivider(this.a);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(
        height: 1,
        thickness: 1,
        color: a.cardBorder.withValues(alpha: 0.55),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final ProgressService progress;
  final BackendService backend;
  final SpiritualGrowth growth;
  final AppearanceStyle a;
  final TextEditingController nameController;
  final bool nameDirty;
  final VoidCallback onSaveName;

  const _ProfileHero({
    required this.progress,
    required this.backend,
    required this.growth,
    required this.a,
    required this.nameController,
    required this.nameDirty,
    required this.onSaveName,
  });

  CinematicGlyph get _growthGlyph => switch (growth.stage) {
        GrowthStage.seed => CinematicGlyph.seed,
        GrowthStage.sprout => CinematicGlyph.tree,
        GrowthStage.sapling => CinematicGlyph.tree,
        GrowthStage.olive => CinematicGlyph.tree,
        GrowthStage.lamp => CinematicGlyph.lamp,
      };

  @override
  Widget build(BuildContext context) {
    final missions = progress.completedMissions.length;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppTheme.cardShadow(elevated: true),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2A4A3C),
                      AppColors.primaryDark,
                      AppColors.nightMid,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.65),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.25),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: UserAvatar(
                          photoUrl: backend.userPhotoUrl,
                          name: progress.userName,
                          radius: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              progress.userName,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textOnDark,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              child: Text(
                                growth.title,
                                style: AppTypography.label(
                                  size: 10,
                                  color: AppColors.accentSoft,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            if (backend.userEmail != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                backend.userEmail!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.body(
                                  size: 11,
                                  color: AppColors.textOnDark.withValues(
                                    alpha: 0.65,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      CinematicIcon(
                        glyph: _growthGlyph,
                        size: 36,
                        accent: growth.stage == GrowthStage.lamp
                            ? AppColors.accent
                            : AppColors.primaryLight,
                        framed: false,
                        glowing: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _HeroStat(
                            glyph: CinematicGlyph.spark,
                            value: '${progress.steps}',
                            label: progress.steps == 1 ? 'passo' : 'passos',
                            accent: AppColors.accent,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        Expanded(
                          child: _HeroStat(
                            glyph: CinematicGlyph.flame,
                            value: '${progress.streak}',
                            label: progress.streak == 1 ? 'dia' : 'dias',
                            accent: AppColors.streak,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        Expanded(
                          child: _HeroStat(
                            glyph: CinematicGlyph.scroll,
                            value: '$missions',
                            label: missions == 1 ? 'missão' : 'missões',
                            accent: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Nome na jornada',
                    style: AppTypography.label(
                      size: 9,
                      color: AppColors.textOnDark.withValues(alpha: 0.55),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    maxLength: 24,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => onSaveName(),
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Como te chamamos?',
                      hintStyle: TextStyle(
                        color: AppColors.textOnDark.withValues(alpha: 0.4),
                      ),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.28),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      suffixIcon: nameDirty
                          ? IconButton(
                              onPressed: onSaveName,
                              icon: const Icon(Icons.check_rounded),
                              color: AppColors.accent,
                              tooltip: 'Salvar',
                            )
                          : null,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.accent.withValues(alpha: 0.7),
                          width: 1.5,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final CinematicGlyph glyph;
  final String value;
  final String label;
  final Color accent;

  const _HeroStat({
    required this.glyph,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CinematicIcon(
          glyph: glyph,
          size: 20,
          accent: accent,
          framed: false,
          glowing: false,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: AppColors.textOnDark,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.35,
            color: AppColors.textOnDark.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
