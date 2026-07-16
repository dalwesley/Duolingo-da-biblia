import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../services/backend_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/daily_quests_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/milestone_chests.dart';
import '../widgets/reflection_journal_card.dart';
import '../widgets/user_avatar.dart';
import 'memory_screen.dart';
import 'practice_screen.dart';

/// Perfil / jornada — aberto pelo avatar na home.
class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  final _repo = TrailRepository();
  int _trailCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final trails = await _repo.getTrails();
    if (!mounted) return;
    setState(() {
      _trailCount = trails.where((t) => t.missionSlugs.isNotEmpty).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final backend = context.watch<BackendService>();
    final a = Appearance.of(context);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 28 + bottomInset),
      children: [
        Row(
          children: [
            UserAvatar(
              photoUrl: backend.userPhotoUrl,
              name: progress.userName,
              radius: 32,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.userName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: a.text,
                    ),
                  ),
                  if (backend.userEmail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      backend.userEmail!,
                      style: TextStyle(fontSize: 12, color: a.textMuted(0.7)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _JourneySeals(
          steps: progress.steps,
          missions: progress.completedMissions.length,
          trails: _trailCount,
        ),
        const SizedBox(height: 18),
        const DailyQuestsCard(),
        const SizedBox(height: 14),
        const WeeklyQuestsCard(),
        const SizedBox(height: 14),
        GlassCard(
          elevated: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MemoryScreen()),
          ),
          child: Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.scroll,
                size: 44,
                accent: AppColors.accent,
                glowing: true,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Memorizar versículos',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: a.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      progress.memoryMastered.isEmpty
                          ? 'Flashcards com a Palavra'
                          : '${progress.memoryMastered.length} firmes no coração',
                      style: TextStyle(fontSize: 12, color: a.textMuted(0.6)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: a.textMuted(0.5), size: 20),
            ],
          ),
        ),
        if (progress.mistakeQuestionIds.isNotEmpty) ...[
          const SizedBox(height: 14),
          GlassCard(
            elevated: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PracticeScreen()),
            ),
            child: Row(
              children: [
                CinematicIcon(
                  glyph: CinematicGlyph.echo,
                  size: 44,
                  accent: AppColors.error,
                  glowing: true,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reforçar memória',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: a.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${progress.mistakeQuestionIds.length} passagem(ns) para revisitar',
                        style: TextStyle(fontSize: 12, color: a.textMuted(0.6)),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: a.textMuted(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        const ReflectionJournalCard(),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _JourneySeals extends StatelessWidget {
  final int steps;
  final int missions;
  final int trails;

  const _JourneySeals({
    required this.steps,
    required this.missions,
    required this.trails,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Seal(
            glyph: CinematicGlyph.spark,
            value: '$steps',
            label: 'Passos',
            accent: AppColors.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Seal(
            glyph: CinematicGlyph.scroll,
            value: '$missions',
            label: 'Avanços',
            accent: AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Seal(
            glyph: CinematicGlyph.cosmos,
            value: '$trails',
            label: 'Trilhas',
            accent: AppColors.teal,
          ),
        ),
      ],
    );
  }
}

class _Seal extends StatelessWidget {
  final CinematicGlyph glyph;
  final String value;
  final String label;
  final Color accent;

  const _Seal({
    required this.glyph,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          CinematicIcon(glyph: glyph, size: 32, accent: accent, glowing: false),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: a.textMuted(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
