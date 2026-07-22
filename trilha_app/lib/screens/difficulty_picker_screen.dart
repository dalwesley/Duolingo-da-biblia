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
                  colors: [Color(0xFF152820), Color(0xFF0E1210), Color(0xFF0A0E0C)],
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
                padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.md, AppSpace.screen, AppSpace.xxl),
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
                                  borderRadius: BorderRadius.circular(AppRadii.sm),
                                ),
                                child: const Icon(Icons.close_rounded, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpace.sm),
                          FadeTransition(
                            opacity: CurvedAnimation(parent: _enter, curve: const Interval(0, 0.4, curve: Curves.easeOut)),
                            child: Column(
                              children: [
                                Text(
                                  'Antes de partir',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.label(
                                    size: 13,
                                    letterSpacing: 1.4,
                                    color: AppColors.accent,
                                  ),
                                ),
                                const SizedBox(height: AppSpace.sm),
                                Text(
                                  'Escolha o modo\nda sua jornada',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.display(size: 28, height: 1.15),
                                ),
                                const SizedBox(height: AppSpace.md),
                                Text(
                                  'Semente, Caminhada ou Profundezas —\nas perguntas mudam com o modo.\nVocê pode subir de nível depois.',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.body(
                                    size: 13,
                                    height: 1.4,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpace.xxl),
                          Expanded(
                            child: ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (_, _) => const SizedBox(height: AppSpace.section),
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
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(AppSpace.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.xl),
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
              CinematicIcon(
                glyph: DifficultyVisuals.glyphFor(meta.difficulty),
                size: 52,
                accent: color,
                glowing: selected,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpace.sm,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          meta.label,
                          style: AppTypography.title(
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpace.sm,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Text(
                            xpLabel,
                            style: AppTypography.label(
                              size: 10,
                              color: color,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      meta.subtitle,
                      style: AppTypography.title(
                        size: 12,
                        color: color.withValues(alpha: 0.95),
                      ),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      meta.description,
                      style: AppTypography.body(
                        size: 13,
                        height: 1.35,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              CinematicIcon(
                glyph: CinematicGlyph.rise,
                size: 20,
                accent: color,
                framed: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
