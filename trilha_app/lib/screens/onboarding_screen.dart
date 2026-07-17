import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/trilha_mascot.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  final _nameController = TextEditingController();
  int _index = 0;
  int _dailyGoal = 1;

  @override
  void dispose() {
    _page.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final progress = context.read<ProgressService>();
    final backend = context.read<BackendService>();
    final name = _nameController.text.trim();
    if (name.isNotEmpty) await progress.setUserName(name);
    await progress.updateSettings(progress.settings.copyWith(dailyGoal: _dailyGoal));
    await progress.setHasSeenOnboarding(true);
    await backend.saveNow(
      progress,
      LeagueService.weekKey(),
      league: context.read<LeagueService>(),
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.night,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.cosmic)),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: Text('Pular', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w700)),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _page,
                    onPageChanged: (i) => setState(() => _index = i),
                    children: [
                      _Page(
                        mascot: true,
                        title: 'Bem-vindo à caminhada',
                        body: 'Conhecer a Bíblia não é o objetivo. O objetivo é conhecer a Cristo — um passo de cada vez.',
                      ),
                      _Page(
                        glyph: CinematicGlyph.path,
                        title: 'Sua caminhada',
                        body: 'Cada lição é um passo. A caravana semanal é um rank de passos — para se animarem, não para medir espiritualidade.',
                        child: Column(
                          children: [
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              decoration: InputDecoration(
                                hintText: 'Como podemos te chamar?',
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.08),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('Passos por dia', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Row(
                              children: [1, 2, 3].map((g) {
                                final sel = _dailyGoal == g;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: g < 3 ? 8 : 0),
                                    child: GestureDetector(
                                      onTap: () => setState(() => _dailyGoal = g),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(
                                          color: sel ? AppColors.accent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.06),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: sel ? AppColors.accent : Colors.white.withValues(alpha: 0.12)),
                                        ),
                                        child: Text('$g passo${g > 1 ? 's' : ''}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, color: sel ? AppColors.accent : Colors.white70)),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      _Page(
                        glyph: CinematicGlyph.book,
                        title: 'Comece por Gênesis',
                        body: 'Sua primeira jornada já está liberada. Da Criação ao chamado de Abraão — caminhe um trecho de cada vez.',
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => Container(
                        width: i == _index ? 20 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: i == _index ? AppColors.accent : Colors.white.withValues(alpha: 0.25),
                        ),
                      )),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: GestureDetector(
                    onTap: () {
                      if (_index < 2) {
                        _page.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
                      } else {
                        _finish();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppGradients.gold,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.accentDark.withValues(alpha: 0.45), offset: const Offset(0, 4))],
                      ),
                      child: Text(
                        _index < 2 ? 'AVANÇAR' : 'COMEÇAR A CAMINHAR',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.inkOnAccent, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Page extends StatelessWidget {
  final bool mascot;
  final CinematicGlyph? glyph;
  final String title;
  final String body;
  final Widget? child;

  const _Page({this.mascot = false, this.glyph, required this.title, required this.body, this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (mascot)
            const TrilhaMascot(size: 100)
          else if (glyph != null)
            CinematicIcon(glyph: glyph!, size: 96, accent: AppColors.accent, animate: true),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 28, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(body, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, height: 1.5, color: Colors.white.withValues(alpha: 0.75))),
          if (child != null) ...[const SizedBox(height: 24), child!],
        ],
      ),
    );
  }
}
