import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/curated_trails.dart';
import '../data/season_walk_catalog.dart';
import '../data/trail_repository.dart';
import '../services/league_service.dart';
import '../services/plus_log.dart';
import '../services/progress_service.dart';
import '../services/remote_config_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/liturgical_calendar.dart';
import '../utils/plus_offers.dart';
import '../utils/season_walk_debug.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/daily_chest_sheet.dart';
import '../widgets/immersive_background.dart';
import '../widgets/plus_offer_sheet.dart';
import '../widgets/relic_panel.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import 'lesson_screen.dart';
import 'paywall_screen.dart';
import 'support_screen.dart';
import 'weekly_review_screen.dart';
import 'year_review_screen.dart';

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

  /// Qual opção de promoção está valendo agora (para marcar o botão).
  String _promoChoice(SubscriptionService sub) {
    if (!sub.debugPromoOverride) return 'rc';
    final until = sub.launchPromoDate;
    if (until == null) return 'none';
    return switch (until.difference(_inDays(0)).inDays) {
      20 => '20',
      5 => '5',
      -1 => 'ended',
      _ => 'other',
    };
  }

  void _setPromo(
    SubscriptionService sub, {
    bool override = true,
    DateTime? until,
  }) {
    sub.debugSetPromo(override: override, until: until);
    final date = _ymd(sub.launchPromoDate);
    final store = sub.isConfigured;
    _toast(switch ((override, sub.launchPromoActive, until)) {
      (false, _, _) =>
        'Remote Config: ${sub.launchPromoDate == null ? 'sem promoção' : 'até $date'}',
      (_, true, _) => 'Promoção até $date: todos têm o Peregrino+',
      (_, false, _) when !store =>
        'Sem promoção e sem loja: nada trava. Ligue a loja falsa',
      (_, false, null) => 'Sem promoção: sem assinatura, o Plus trava',
      _ => 'Promoção encerrada ($date): sem assinatura, o Plus trava',
    });
  }

  /// Roda a mesma regra da oferta automática da Home e mostra o resultado.
  Future<void> _runRule() async {
    final sub = context.read<SubscriptionService>();
    final progress = context.read<ProgressService>();
    final state = await loadPlusOfferState();
    final week = LeagueService.weekKey();
    final storeReady = sub.isConfigured && sub.availablePackages.isNotEmpty;
    final promo = sub.launchPromoDate;
    final scenes = progress.completedMissions.length;
    final kind = PlusOffers.pick(
      today: DateTime.now(),
      paid: sub.isPeregrinoPlus,
      storeReady: storeReady,
      scenesDone: scenes,
      accountAgeDays: progress.accountAgeDays,
      promoUntil: promo,
      shown: state.shown,
      lastOfferWeek: state.lastWeek,
      thisWeek: week,
    );
    if (!mounted) return;
    if (kind != null) {
      await showPlusOfferSheet(
        context,
        kind: kind,
        week: week,
        promoUntil: promo,
      );
      return;
    }
    final promoActive = promo != null && !_inDays(0).isAfter(promo);
    _toast(
      sub.isPeregrinoPlus
          ? 'Nenhuma: assinante não recebe oferta'
          : !storeReady
          ? 'Nenhuma: sem loja. Ligue a loja falsa'
          : state.lastWeek == week
          ? 'Nenhuma: já houve oferta nesta semana. Zere as ofertas'
          : promoActive
          ? 'Nenhuma: na promoção só avisa nos últimos 7 dias'
          : scenes < PlusOffers.scenesForOffer
          ? 'Nenhuma: só $scenes cenas concluídas (precisa de 7)'
          : progress.accountAgeDays < PlusOffers.minAccountAgeDays
          ? 'Nenhuma: conta nova demais para a oferta das 7 cenas'
          : 'Nenhuma: todas já foram vistas. Zere as ofertas',
    );
  }

  Future<void> _clear() async {
    final progress = context.read<ProgressService>();
    await progress.debugClearLab();
    await progress.debugSetSeasonToday(null);
    _toast('Dados do laboratório limpos');
  }

  Future<void> _setSeasonClock(DateTime? day, String label) async {
    await context.read<ProgressService>().debugSetSeasonToday(day);
    _toast(day == null ? 'Relógio real' : 'Caminhada em $label — volte à Home');
  }

  /// Pré-Advento (card na home), dia 1, meio da campanha, relógio real.
  List<(String id, String label, DateTime? day)> _seasonChoices() {
    final year = DateTime.now().year;
    final start = LiturgicalCalendar.adventStart(year);
    // Se o Advento deste ano já passou, usa o do ano que vem.
    final advent = start.isBefore(DateTime.now())
        ? LiturgicalCalendar.adventStart(year + 1)
        : start;
    return [
      (
        'card',
        'Card na home (7 dias antes)',
        advent.subtract(const Duration(days: 7)),
      ),
      ('day1', 'Dia 1 da caminhada', advent),
      (
        'day10',
        'Dia 10 (calendário aberto)',
        advent.add(const Duration(days: 9)),
      ),
      ('real', 'Relógio real', null),
    ];
  }

  String _seasonChoiceId(ProgressService progress) {
    if (!progress.debugSeasonTodayActive) return 'real';
    final today = progress.seasonToday;
    for (final (id, _, day) in _seasonChoices()) {
      if (day != null &&
          day.year == today.year &&
          day.month == today.month &&
          day.day == today.day) {
        return id;
      }
    }
    return 'other';
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
                          'Caminhada (relógio): ${_ymd(progress.seasonToday)}'
                          '${progress.debugSeasonTodayActive ? ' (simulado)' : ''}',
                        ),
                        line(
                          'Semana da revisão: $week · '
                          'cenas: ${progress.missionsCompletedInWeek(week).length} · '
                          'feita: ${progress.isWeeklyReviewDone(week)}',
                        ),
                      ]),
                      section('Caminhada sazonal', [
                        line(
                          'Simula a data da Caminhada do Advento neste '
                          'aparelho (fica salva). “Card na home” mostra o '
                          'card destaque abaixo da missão. Volte à Home '
                          'depois de escolher.',
                        ),
                        for (final (id, label, day) in _seasonChoices())
                          button(
                            _seasonChoiceId(progress) == id
                                ? '● $label'
                                : label,
                            () => _setSeasonClock(day, _ymd(day)),
                          ),
                        if (SeasonWalkDebug.active)
                          line(
                            'Campanha: ${SeasonWalkCatalog.current(progress.seasonToday).title}',
                          ),
                      ]),
                      section('Registro do Plus', [
                        line(
                          'Loja, ofertas, assinatura, compras, config e '
                          'travas, mais recente no topo. No console: '
                          'adb logcat | grep Plus',
                        ),
                        ListenableBuilder(
                          listenable: PlusLog.instance,
                          builder: (context, _) {
                            final entries = PlusLog.instance.entries;
                            if (entries.isEmpty) return line('(vazio)');
                            return Container(
                              constraints: const BoxConstraints(maxHeight: 320),
                              padding: const EdgeInsets.all(AppSpace.sm),
                              decoration: BoxDecoration(
                                color: a.insetFill,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.sm,
                                ),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: entries.length,
                                itemBuilder: (_, i) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: SelectableText(
                                    entries[i].toString(),
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      height: 1.3,
                                      color: a.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpace.sm),
                        button('Registrar o estado agora', () {
                          PlusLog.log('laboratório', sub.debugSnapshot);
                        }),
                        button('Copiar registro', () async {
                          await Clipboard.setData(
                            ClipboardData(text: PlusLog.instance.dump()),
                          );
                          _toast('Registro copiado');
                        }),
                        button('Limpar registro', PlusLog.instance.clear),
                      ]),
                      section('Assinatura e apoio', [
                        toggle(
                          'Assinante (simulado)',
                          sub.isPeregrinoPlus,
                          sub.debugSetPlus,
                        ),
                        toggle(
                          'Assinante Pioneiro (simulado, selo próprio)',
                          sub.hasPioneerBadge,
                          (v) => sub.debugSetPlus(v, pioneer: true),
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
                        toggle(
                          'Pioneiro esgotado (${sub.pioneerTaken}/${sub.pioneerCap})',
                          sub.pioneerSoldOut,
                          (v) =>
                              sub.debugSetPioneerCount(v ? sub.pioneerCap : 0),
                        ),
                        toggle(
                          'Grupos abertos (simulado)',
                          context.watch<RemoteConfigService>().groupsEnabled,
                          RemoteConfigService.instance.debugSetGroupsEnabled,
                        ),
                        toggle(
                          'Companhia aberta (simulado)',
                          context.watch<RemoteConfigService>().companionEnabled,
                          RemoteConfigService.instance.debugSetCompanionEnabled,
                        ),
                        toggle(
                          'Desafio aberto (simulado)',
                          context.watch<RemoteConfigService>().challengeEnabled,
                          RemoteConfigService.instance.debugSetChallengeEnabled,
                        ),
                      ]),
                      section('Promoção de lançamento', [
                        line(
                          'Muda a data da promoção neste aparelho (fica '
                          'salva ao fechar o app). Veja o efeito no '
                          'Perfil, na revisão da semana, no paywall e em '
                          'Ajustes. Sem loja, nada trava: ligue a loja '
                          'falsa para ver o Plus bloqueado.',
                        ),
                        for (final (id, label, days) in [
                          ('20', 'Termina em 20 dias', 20),
                          ('5', 'Termina em 5 dias', 5),
                          ('ended', 'Acabou ontem', -1),
                        ])
                          button(
                            _promoChoice(sub) == id ? '● $label' : label,
                            () => _setPromo(sub, until: _inDays(days)),
                          ),
                        button(
                          _promoChoice(sub) == 'none'
                              ? '● Sem promoção'
                              : 'Sem promoção',
                          () => _setPromo(sub),
                        ),
                        button(
                          _promoChoice(sub) == 'rc'
                              ? '● Usar o Remote Config'
                              : 'Usar o Remote Config',
                          () => _setPromo(sub, override: false),
                        ),
                      ]),
                      section('Postais', [
                        line(
                          'Abre a retrospectiva do ano corrente agora, '
                          'mesmo antes de year_review_from e com menos '
                          'de 3 postais.',
                        ),
                        button(
                          'Abrir retrospectiva do ano',
                          () => openYearReview(context, force: true),
                        ),
                      ]),
                      section('A Promessa', [
                        line(
                          'Marca as 12 cenas como feitas para abrir a '
                          'Travessia final. Erre de propósito na síntese '
                          'para ver o Mapa da Promessa com revisão. '
                          '"Desfazer" desmarca as 13 cenas.',
                        ),
                        button('Ir para a Travessia', () async {
                          await context.read<ProgressService>().debugMarkScenes(
                            CuratedTrails.origins.keys.toList(),
                          );
                          _toast(
                            '12 cenas feitas: abra Temas › Promessa e cumprimento',
                          );
                        }),
                        button('Desfazer A Promessa', () async {
                          await context
                              .read<ProgressService>()
                              .debugMarkScenes([
                                ...CuratedTrails.origins.keys,
                                CuratedTrails.synthesisSlug,
                              ], undo: true);
                          _toast('A Promessa voltou ao começo');
                        }),
                      ]),
                      section('Para aprofundar', [
                        line(
                          'Abre "O Cordeiro no trono" (Apocalipse) em modo '
                          'prática, sem trava de trilha e sem mexer no '
                          'progresso. Toque no Anan: a folha tem '
                          'palavra-chave, pergunta e ligações.',
                        ),
                        button('Abrir cena com estudo', () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const LessonScreen(
                                missionSlug: 'apo-02-cordeiro',
                                practiceMode: true,
                                skipTrailLock: true,
                              ),
                            ),
                          );
                        }),
                      ]),
                      section('Dados de teste', [
                        line(
                          'Põe 3 cenas na semana da revisão (seg, qua, '
                          'sex) e soma respostas por modo e gesto. Não '
                          'conclui cenas nem dá passos. "Limpar" tira '
                          'todas as cenas da semana da revisão e zera o '
                          'acerto por modo e gesto. Os dois liberam a '
                          'revisão de hoje, se já foi feita.',
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
                        button('Testar a regra agora', _runRule),
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
                      section('Baú do dia', [
                        line(
                          'Rearmar marca a missão de hoje (sem passos), '
                          'esquece a abertura de hoje e deixa a folha '
                          'automática aparecer de novo. Volte para a Hoje '
                          'para vê-la chegar sozinha.',
                        ),
                        button('Rearmar o baú de hoje', () async {
                          await context
                              .read<ProgressService>()
                              .debugRearmDailyChest();
                          await resetDailyChestOffer();
                          _toast('Baú rearmado');
                        }),
                        button(
                          'Mostrar a folha do baú',
                          () => showDailyChestSheet(context),
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
