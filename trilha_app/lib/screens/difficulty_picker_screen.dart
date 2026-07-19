import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/question_bank.dart';
import '../models/difficulty.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/difficulty_visuals.dart';
import '../widgets/cinematic_icon.dart';

/// Escolha cinematográfica de dificuldade ao iniciar a trilha de Gênesis.
class DifficultyPickerScreen extends StatefulWidget {
  final String trailSlug;
  final VoidCallback onSelected;

  const DifficultyPickerScreen({
    super.key,
    required this.trailSlug,
    required this.onSelected,
  });

  @override
  State<DifficultyPickerScreen> createState() => _DifficultyPickerScreenState();
}

class _DifficultyPickerScreenState extends State<DifficultyPickerScreen> with SingleTickerProviderStateMixin {
  List<DifficultyMeta>? _items;
  TrailDifficulty? _hover;
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _load();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final items = await QuestionBank.instance.getDifficulties();
    if (mounted) setState(() => _items = items);
  }

  Future<void> _choose(DifficultyMeta meta) async {
    HapticFeedback.mediumImpact();
    await context.read<ProgressService>().setTrailDifficulty(widget.trailSlug, meta.difficulty.id);
    if (!mounted) return;
    widget.onSelected();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E0C),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E3D32), Color(0xFF152820), Color(0xFF0A0E0C)],
                ),
              ),
            ),
            Positioned(
              top: -80,
              right: -40,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.accent.withValues(alpha: 0.2), Colors.transparent],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                child: items == null
                    ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.close_rounded, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FadeTransition(
                            opacity: CurvedAnimation(parent: _enter, curve: const Interval(0, 0.4, curve: Curves.easeOut)),
                            child: const Column(
                              children: [
                                Text(
                                  'Antes de partir',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accent,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Escolha o modo\nda sua jornada',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.15,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Semente, Caminhada ou Profundezas —\nas perguntas mudam com o modo.\nVocê pode subir de nível depois.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, height: 1.4, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          Expanded(
                            child: ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 14),
                              itemBuilder: (context, i) {
                                final meta = items[i];
                                final start = 0.15 + i * 0.12;
                                final curve = CurvedAnimation(
                                  parent: _enter,
                                  curve: Interval(start, (start + 0.45).clamp(0, 1), curve: Curves.easeOutCubic),
                                );
                                return FadeTransition(
                                  opacity: curve,
                                  child: SlideTransition(
                                    position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(curve),
                                    child: _DifficultyCard(
                                      meta: meta,
                                      selected: _hover == meta.difficulty,
                                      onTap: () => _choose(meta),
                                      onHighlight: () => setState(() => _hover = meta.difficulty),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final DifficultyMeta meta;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onHighlight;

  const _DifficultyCard({
    required this.meta,
    required this.selected,
    required this.onTap,
    required this.onHighlight,
  });

  @override
  Widget build(BuildContext context) {
    final color = DifficultyVisuals.accentFor(meta.difficulty);
    final xpLabel = meta.stepsMultiplier == 1
        ? 'Passos padrão'
        : '+${((meta.stepsMultiplier - 1) * 100).round()}% passos';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onHighlightChanged: (v) {
          if (v) onHighlight();
        },
        borderRadius: BorderRadius.circular(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: selected ? 0.28 : 0.16),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(color: color.withValues(alpha: selected ? 0.7 : 0.35), width: selected ? 2 : 1.2),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.22), blurRadius: selected ? 24 : 14, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.18),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: CinematicIcon(
                  glyph: DifficultyVisuals.glyphFor(meta.difficulty),
                  size: 30,
                  accent: color,
                  framed: false,
                  glowing: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          meta.label,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            xpLabel,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta.subtitle,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color.withValues(alpha: 0.95)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      meta.description,
                      style: TextStyle(fontSize: 13, height: 1.35, color: Colors.white.withValues(alpha: 0.72)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
