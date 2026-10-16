import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/trail_repository.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/plus_offers.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/plus_offer_sheet.dart';
import '../widgets/relic_panel.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import 'paywall_screen.dart';
import 'support_screen.dart';
import 'weekly_review_screen.dart';

/// Laboratório do Peregrino+ — só em build de desenvolvimento ([kDebugMode]).
///
/// Simula assinatura, apoio, promoção e loja, e cria dados de teste para a
/// revisão da semana e Minha caminhada. Textos fixos em português de
/// propósito: a tela não vai para a loja.
class PlusLabScreen extends StatefulWidget {
  const PlusLabScreen({super.key});

  @override
  State<PlusLabScreen> createState() => _PlusLabScreenState();
}

class _PlusLabScreenState extends State<PlusLabScreen> {
  bool _busy = false;

  String _ymd(DateTime? d) =>
      d == null ? '—' : d.toIso8601String().substring(0, 10);

  DateTime _inDays(int n) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + n);
  }

  void _toast(String message) {
    if (!mounted) return;
    showAppToastFor(context, message: message);
  }

  Future<void> _seedWeek() async {
    setState(() => _busy = true);
    final progress = context.read<ProgressService>();
    final trails = await TrailRepository().getTrails();
    final slugs = <String>[];
    for (final trail in trails) {
      if (trail.comingSoon) continue;
      for (final mod in trail.modules) {
        for (final m in mod.missions) {
          if (slugs.length < 3) slugs.add(m.slug);
        }
      }
      if (slugs.length >= 3) break;
    }
    await progress.debugSeedReviewWeek(slugs);
    if (!mounted) return;
    setState(() => _busy = false);
    _toast('Semana criada: ${slugs.join(', ')}');
  }

  Future<void> _clear() async {
    await context.read<ProgressService>().debugClearLab();
    _toast('Dados do laboratório limpos');
  }

  Future<void> _offer(PlusOfferKind kind) async {
    final sub = context.read<SubscriptionService>();
    await showPlusOfferSheet(
      context,
      kind: kind,
      week: LeagueService.weekKey(),
      promoUntil: sub.launchPromoDate ?? _inDays(5),
    );
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    final a = Appearance.of(context);
    final sub = context.watch<SubscriptionService>();
    final progress = context.watch<ProgressService>();
    final week = progress.weeklyReviewWeekKey();

    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.lg),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RelicChapter(title: title, divided: false),
            const SizedBox(height: AppSpace.sm),
            ...children,
          ],
        ),
      ),
    );

    Widget line(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppTypography.body(size: 12, color: a.textSecondary),
      ),
    );

    Widget toggle(String label, bool value, ValueChanged<bool> onChanged) =>
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(
            label,
            style: AppTypography.body(size: 14, color: a.text),
          ),
          value: value,
          onChanged: onChanged,
        );

    Widget button(String label, VoidCallback? onTap) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GhostCta(label: label, expanded: true, onTap: onTap),
    );

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
                  title: 'Laboratório Peregrino+',
                  subtitle: 'Só em desenvolvimento',
                  onBack: () => Navigator.pop(context),
                  leadingGlyph: CinematicGlyph.tune,
                ),
              ),
              Expanded(
                child: ContentFrame(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.screen,
                      AppSpace.md,
                      AppSpace.screen,
                      AppSpace.xl,
                    ),
                    children: [
                      section('Estado agora', [
                        line(
                          'Loja configurada: ${sub.isConfigured}'
                          '${sub.debugFakeStore ? ' (falsa)' : ''}',
                        ),
                        line(
                          'Assinante: ${sub.isPeregrinoPlus} · '
                          'Apoiador: ${sub.isSupporter}',
                        ),
                        line(
                          'Acesso Plus (hasPlus): ${sub.hasPlus} · '
                          'Selo: ${sub.hasBadge}',
                        ),
                        line(
                          'Promoção: ${_ymd(sub.launchPromoDate)} · '
                          'ativa: ${sub.launchPromoActive}'
                          '${sub.debugPromoOverride ? ' (simulada)' : ''}',
                        ),
                        line(
                          'Semana da revisão: $week · '
                          'cenas: ${progress.missionsCompletedInWeek(week).length} · '
                          'feita: ${progress.isWeeklyReviewDone(week)}',
                        ),
                      ]),
                      section('Assinatura e apoio', [
                        toggle(
                          'Assinante (simulado)',
                          sub.isPeregrinoPlus,
                          sub.debugSetPlus,
                        ),
                        toggle(
                          'Apoiador (simulado)',
                          sub.isSupporter,
                          sub.debugSetSupporter,
                        ),
                        toggle(
                          'Loja falsa (planos e apoios de mentira)',
                          sub.debugFakeStore,
                          sub.debugSetFakeStore,
                        ),
                      ]),
                      section('Promoção de lançamento', [
                        button(
                          'Termina em 20 dias',
                          () => sub.debugSetPromo(
                            override: true,
                            until: _inDays(20),
                          ),
                        ),
                        button(
                          'Termina em 5 dias',
                          () => sub.debugSetPromo(
                            override: true,
                            until: _inDays(5),
                          ),
                        ),
                        button(
                          'Acabou ontem',
                          () => sub.debugSetPromo(
                            override: true,
                            until: _inDays(-1),
                          ),
                        ),
                        button(
                          'Sem promoção',
                          () => sub.debugSetPromo(override: true),
                        ),
                        button(
                          'Voltar ao Remote Config',
                          () => sub.debugSetPromo(override: false),
                        ),
                      ]),
                      section('Dados de teste', [
                        line(
                          'Põe 3 cenas na semana da revisão (seg, qua, '
                          'sex) e soma respostas por modo e gesto. Não '
                          'conclui cenas nem dá passos. "Limpar" tira '
                          'todas as cenas da semana da revisão e zera o '
                          'acerto por modo e gesto.',
                        ),
                        button(
                          _busy ? 'Criando…' : 'Criar semana de revisão',
                          _busy ? null : _seedWeek,
                        ),
                        button('Limpar dados do laboratório', _clear),
                      ]),
                      section('Ofertas', [
                        line(
                          'A oferta automática da Home roda 1× por '
                          'abertura do app. Zere e reabra o app para '
                          'testar a regra.',
                        ),
                        button('Zerar ofertas vistas', () async {
                          await resetPlusOfferState();
                          _toast('Ofertas zeradas');
                        }),
                        button(
                          'Mostrar: 7 cenas',
                          () => _offer(PlusOfferKind.sevenScenes),
                        ),
                        button(
                          'Mostrar: promoção acabando',
                          () => _offer(PlusOfferKind.promoEndingSoon),
                        ),
                        button(
                          'Mostrar: promoção encerrada',
                          () => _offer(PlusOfferKind.promoEnded),
                        ),
                      ]),
                      section('Abrir telas', [
                        button(
                          'Paywall',
                          () => _open(const PaywallScreen(source: 'lab')),
                        ),
                        button(
                          'Revisão da semana',
                          () => _open(const WeeklyReviewScreen()),
                        ),
                        button('Apoiar o Stway', () => openSupport(context)),
                      ]),
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
