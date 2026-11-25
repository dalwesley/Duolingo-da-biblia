import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../utils/guest_gate.dart';
import '../l10n/app_language.dart';
import '../services/referral_rewards_service.dart';
import '../services/plus_log.dart';
import '../services/analytics_service.dart';
import '../services/family_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/plus_access.dart';
import '../widgets/act_feel.dart';
import '../widgets/app_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/coming_soon_trails_card.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/immersive_background.dart';
import '../widgets/juntos_chrome.dart';
import '../widgets/plus_perks.dart';
import '../widgets/stway_brand.dart';
import '../widgets/tilt_star_sky.dart';
import '../widgets/trail_gift.dart';
import '../widgets/ui_primitives.dart';

/// Paywall do Peregrino+. Abre por Ajustes, pelos recursos bloqueados e
/// pelas ofertas (no máx. 1 por semana, fora da cena) — nunca no meio de uma
/// cena, no onboarding ou no login.
///
/// Uma decisão por tela: o Anan abre com a promessa, três benefícios dizem
/// o que muda, os planos vêm logo abaixo e o botão fica sempre à vista no
/// rodapé, com o preço do plano escolhido colado nele. O resto (teste,
/// renovação, dízimo, links) fica no fim, para quem quer ler.
class PaywallScreen extends StatefulWidget {
  /// De onde o paywall foi aberto (analytics), ex.: `settings`.
  final String source;

  const PaywallScreen({super.key, this.source = 'settings'});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

/// EULA padrão da Apple — exigido junto dos termos em assinatura no iOS.
const _appleEulaUrl =
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

/// Benefícios à vista antes de "ver todos".
const _perksPreview = 5;

/// Espaço que o rodapé fixo ocupa sobre a lista (sem a borda do sistema).
const _footerReserve = 150.0;

/// Anual primeiro (o herói, com o teste grátis), depois o Pioneiro
/// vitalício enquanto houver vaga, o mensal e o restante.
int _rank(Package p) => SubscriptionService.isFounderPackage(p)
    ? 1
    : switch (SubscriptionService.planType(p)) {
        PackageType.annual => 0,
        PackageType.monthly => 2,
        PackageType.lifetime => 3,
        _ => 4,
      };

/// Preço cobrado pelo plano, curto: "R$ 89,99/ano", "R$ 9,99/mês" ou
/// "R$ 149,99 · pagamento único". O mesmo texto no card e sob o botão.
String _chargeLabel(AppLocalizations l10n, Package p) {
  final product = p.storeProduct;
  if (PlusAccess.familySeatsFor(product.identifier) > 0) {
    return l10n.paywallPricePerYearShort(product.priceString);
  }
  return switch (SubscriptionService.planType(p)) {
    PackageType.annual => l10n.paywallPricePerYearShort(product.priceString),
    PackageType.monthly => l10n.paywallPricePerMonthShort(product.priceString),
    PackageType.lifetime => '${product.priceString} · ${l10n.paywallOnceShort}',
    _ => SubscriptionService.packageLabel(p),
  };
}

class _PaywallScreenState extends State<PaywallScreen> {
  String? _selectedId;
  String _viewState = 'offer';

  /// "Família" escolhido no topo dos planos (Casal e Família 3/4).
  bool _family = false;

  /// Lista completa de benefícios aberta.
  bool _allPerks = false;

  @override
  void initState() {
    super.initState();
    final sub = context.read<SubscriptionService>();
    _viewState = sub.isPeregrinoPlus
        ? 'paid'
        : sub.launchPromoActive
        ? 'promo'
        : sub.canPurchase
        ? 'offer'
        : 'unavailable';
    PlusLog.log('paywall', 'aberto por ${widget.source} (estado $_viewState)');
    // A oferta não veio na abertura do app: tenta de novo agora.
    if (_viewState == 'unavailable') unawaited(sub.retryOfferings());
    AnalyticsService.instance.logPaywallView(
      source: widget.source,
      state: _viewState,
    );
  }

  /// Compra nova: o Anan comemora uma vez. Reabrir o paywall já pago,
  /// ou restaurar, só mostra o plano — a festa não se repete.
  Future<void> _subscribe(Package package) async {
    // Assinatura mora na conta (webhook, selo, passe de trilha): visitante
    // salva a caminhada antes de comprar.
    if (!await GuestGate.requireAccount(context, reason: 'paywall')) return;
    if (!mounted) return;
    final ok = await context.read<SubscriptionService>().purchase(package);
    if (!ok || !mounted) return;
    await showPlusWelcomeSheet(context);
  }

  @override
  void dispose() {
    // Fechar sem virar assinante nesta visita fecha o funil.
    if (_viewState != 'paid') {
      AnalyticsService.instance.logPaywallDismiss(
        source: widget.source,
        state: _viewState,
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sub = context.watch<SubscriptionService>();
    final paid = sub.isPeregrinoPlus;
    if (paid) _viewState = 'paid';
    final promoUntil = paid ? null : sub.launchFreeUntil;
    final promoDate = promoUntil == null
        ? null
        : DateFormat(
            'd MMM',
            l10n.localeName,
          ).format(promoUntil).replaceAll('.', '');
    // O paywall é palco: sempre a noite estrelada da marca, em qualquer
    // tema — o dourado do Plus só brilha sobre o escuro.
    const mode = AppearanceMode.night;
    final a = AppearanceStyle.resolve(mode);
    final top = MediaQuery.viewPaddingOf(context).top;
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    final familyOffer = !paid && sub.familyOnSale;
    final showFamily = _family && familyOffer;
    final packages = showFamily
        ? [...sub.familyPackages]
        : ([...sub.packagesForSale]
            ..sort((x, y) => _rank(x).compareTo(_rank(y))));
    // Durante a promoção também dá para assinar: quem quer garantir o
    // plano não espera o fim da gratuidade (a compra começa hoje).
    // Oferta só com plano à venda: o Pioneiro sozinho e fora de venda
    // deixava a lista vazia com o botão na tela (e `selected!` quebrava).
    final offer = !paid && sub.canPurchase && packages.isNotEmpty;
    // A oferta pode chegar depois da abertura (loja lenta): o estado do
    // funil acompanha a tela, não congela no primeiro frame.
    if (offer && _viewState == 'unavailable') _viewState = 'offer';
    final selected = packages.isEmpty
        ? null
        : packages.firstWhere(
            (p) => p.identifier == _selectedId,
            orElse: () => packages.first,
          );
    final trial = selected == null ? null : sub.trialDaysFor(selected);
    final renews =
        selected == null ||
        SubscriptionService.planType(selected) != PackageType.lifetime;
    // Família: o plano com o menor preço por pessoa ganha "Melhor valor".
    double perHead(Package p) =>
        p.storeProduct.price /
        (PlusAccess.familySeatsFor(p.storeProduct.identifier) + 1);
    final bestFamilyId = showFamily && packages.length > 1
        ? packages.reduce((x, y) => perHead(y) < perHead(x) ? y : x).identifier
        : null;
    final monthly = packages
        .where((x) => SubscriptionService.planType(x) == PackageType.monthly)
        .firstOrNull;
    // Sem plano à venda, o rodapé só aparece para tentar de novo.
    final retry = !paid && !offer && sub.isConfigured;
    final footer = offer || retry;

    final perks = PlusPerk.available;
    final foldable = perks.length > _perksPreview;
    final showAll = _allPerks || !foldable;
    var step = 0;
    Widget reveal(Widget child) => _Reveal(index: step++, child: child);

    final list = ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen,
        top + 56,
        AppSpace.screen,
        (footer ? _footerReserve : AppSpace.xl) + bottom,
      ),
      children: [
        reveal(
          _Hero(
            face: paid ? CloudFace.sucesso : CloudFace.feliz,
            title: paid
                ? l10n.paywallAlreadyPlus
                : promoDate != null
                ? l10n.paywallLaunchFreeTitle
                : l10n.paywallHeroTitle,
            body: paid
                ? l10n.paywallThanks
                : promoDate != null
                ? l10n.paywallLaunchFreeBody(promoDate)
                : l10n.paywallHeroBody,
          ),
        ),
        const SizedBox(height: AppSpace.xl),
        if (paid) ...[
          reveal(_YourPlan(sub: sub)),
          const SizedBox(height: AppSpace.xl),
        ],
        reveal(
          _PerkList(
            perks: showAll ? perks : perks.take(_perksPreview).toList(),
            expanded: showAll,
            onToggle: foldable
                ? () {
                    ActHaptics.tap();
                    setState(() => _allPerks = !_allPerks);
                  }
                : null,
          ),
        ),
        const SizedBox(height: AppSpace.xl),
        if (offer)
          reveal(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (promoDate != null) ...[
                  Text(
                    l10n.paywallPromoSubscribeNote(promoDate),
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      size: 12,
                      height: 1.4,
                      color: a.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                ],
                if (familyOffer) ...[
                  AppSegmentedTabs(
                    index: showFamily ? 1 : 0,
                    accent: AppRoles.reward,
                    // Sobre o céu: trilho sólido, o desenho não atravessa.
                    fill: a.cardFill.withValues(alpha: 0.86),
                    onChanged: (i) => setState(() {
                      _family = i == 1;
                      _selectedId = null;
                    }),
                    items: [
                      (
                        label: l10n.paywallForSolo,
                        glyph: CinematicGlyph.walker,
                        mark: null,
                        alert: false,
                      ),
                      (
                        label: l10n.paywallForFamily,
                        glyph: CinematicGlyph.people,
                        mark: null,
                        alert: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.md),
                ],
                for (final p in packages) ...[
                  _PlanTile(
                    package: p,
                    monthly: monthly,
                    selected: p.identifier == selected!.identifier,
                    trialDays: sub.trialDaysFor(p),
                    pioneerTaken: sub.pioneerTaken,
                    pioneerCap: sub.pioneerCap,
                    pioneerUntil: sub.pioneerUntil,
                    bestValue: p.identifier == bestFamilyId,
                    onTap: () {
                      ActHaptics.tap();
                      AnalyticsService.instance.logPaywallPlanSelect(
                        source: widget.source,
                        productId: p.storeProduct.identifier,
                      );
                      setState(() => _selectedId = p.identifier);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                // Como o plano escolhido funciona: o teste em passos, a
                // família pelo link e a renovação em letra miúda.
                const SizedBox(height: AppSpace.sm),
                AnimatedSwitcher(
                  duration: AppMotion.standard,
                  switchInCurve: AppMotion.enter,
                  switchOutCurve: AppMotion.exit,
                  child: KeyedSubtree(
                    key: ValueKey('${selected!.identifier}-$trial'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (trial != null) ...[
                          _TrialSteps(package: selected, days: trial),
                          const SizedBox(height: AppSpace.md),
                        ],
                        if (showFamily) ...[
                          _NoteCard(
                            glyph: CinematicGlyph.people,
                            text: l10n.paywallFamilyHow,
                          ),
                          const SizedBox(height: AppSpace.sm),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (!paid && promoDate == null)
          // Loja ligada sem oferta é falha de conexão, não "versão sem
          // assinatura".
          Text(
            sub.isConfigured
                ? l10n.paywallOffersFailed
                : l10n.paywallUnavailable,
            textAlign: TextAlign.center,
            style: AppTypography.body(size: 13, color: a.textSecondary),
          ),
        const SizedBox(height: AppSpace.xl),
        const _TitheRow(),
        const SizedBox(height: AppSpace.lg),
        _NoteCard(glyph: CinematicGlyph.book, text: l10n.paywallFreeForever),
        // Restaurar fica mesmo sem oferta (falha da loja): é exatamente
        // quem trocou de aparelho que precisa dele. Assinante também acha
        // Restaurar/Termos/Privacidade.
        if (sub.isConfigured || paid) ...[
          const SizedBox(height: AppSpace.lg),
          _LegalLinks(sub: sub),
        ],
      ],
    );

    return ImmersiveScaffold(
      mode: mode,
      style: a,
      frameBody: false,
      background: const _NightStage(),
      body: Stack(
        children: [
          Positioned.fill(child: ContentFrame(child: list)),
          // O conteúdo some sob a barra do sistema ao rolar.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: top + 64,
            child: const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_ink, Color(0x0005101F)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: top + AppSpace.sm,
            left: AppSpace.screen,
            child: const _CloseButton(),
          ),
          if (footer)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _Footer(
                fade: _ink,
                bottomInset: bottom,
                error: offer ? sub.lastError : null,
                cta: offer
                    ? CopperCta(
                        label: trial != null
                            ? l10n.paywallStartTrial(trial)
                            : renews
                            ? l10n.paywallSubscribe
                            : l10n.paywallBuyLifetime,
                        expanded: true,
                        large: true,
                        busy: sub.loading,
                        onTap: sub.loading ? null : () => _subscribe(selected!),
                      )
                    : CopperCta(
                        label: l10n.commonTryAgain,
                        expanded: true,
                        busy: sub.loading,
                        onTap: sub.loading
                            ? null
                            : () => unawaited(sub.retryOfferings()),
                      ),
                // O valor cobrado colado no botão (Apple 3.1.2).
                note: !offer
                    ? null
                    : trial != null
                    ? l10n.paywallCtaNoteTrial(
                        trial,
                        _chargeLabel(l10n, selected!),
                      )
                    : renews
                    ? '${_chargeLabel(l10n, selected!)} · '
                          '${l10n.paywallCancelAnytime}'
                    : l10n.paywallLifetimeNote(
                        selected.storeProduct.priceString,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Entrada em sequência: cada bloco sobe e aparece um pouco depois do
/// anterior. Parado quando o sistema pede menos movimento.
class _Reveal extends StatefulWidget {
  final int index;
  final Widget child;

  const _Reveal({required this.index, required this.child});

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: AppMotion.enter,
  );
  bool _started = false;
  Timer? _delay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
      return;
    }
    _delay = Timer(AppMotion.stagger * (widget.index * 1.5).round(), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _t,
    builder: (context, child) => Opacity(
      opacity: _t.value,
      child: Transform.translate(
        offset: Offset(0, 16 * (1 - _t.value)),
        child: child,
      ),
    ),
    child: widget.child,
  );
}

/// Fechar discreto no canto: a tela é do conteúdo, não da barra.
class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).closeButtonLabel,
      excludeSemantics: true,
      child: Material(
        color: a.cardFill.withValues(alpha: 0.55),
        shape: CircleBorder(side: BorderSide(color: a.insetBorder)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.maybePop(context),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: CinematicIcon(
                glyph: CinematicGlyph.close,
                size: 16,
                accent: a.textSecondary,
                framed: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tinta da noite do palco (fundo do rodapé e do véu do topo).
const _ink = Color(0xF205101F);

/// Fundo do paywall: a trilha STWAY na noite, o céu estrelado que segue a
/// inclinação do celular (o mesmo da splash e do login) e o chão escurecido
/// para os planos lerem bem.
class _NightStage extends StatelessWidget {
  const _NightStage();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColors.primaryDark,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: AssetImage(StwayPathBackdrop.asset),
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          filterQuality: FilterQuality.high,
        ),
        TiltStarSky(alpha: 0.9),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 0.38, 0.62, 1],
              colors: [
                Color(0x00000000),
                Color(0x2205101F),
                Color(0xA605101F),
                Color(0xEE05101F),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/// O Anan num feixe de luz dourada: raios girando devagar, um núcleo que
/// respira e poeira de ouro subindo. A marca brilha num reflexo que passa.
///
/// Um relógio só (24 s) pinta tudo via repaint — sem rebuild por quadro.
/// Parado quando o sistema pede menos movimento.
class _Hero extends StatefulWidget {
  final CloudFace face;
  final String title;
  final String body;

  const _Hero({required this.face, required this.title, required this.body});

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _clock
        ..stop()
        ..value = 0.1;
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                left: -AppSpace.screen,
                right: -AppSpace.screen,
                top: -140,
                bottom: -60,
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _HeroLightPainter(_clock)),
                  ),
                ),
              ),
              CloudMascot(face: widget.face, size: 150),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        // A promessa num card: sobre os raios e as estrelas o texto
        // solto não lia bem.
        _GoldSurface(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.lg,
            AppSpace.lg,
            AppSpace.lg,
            AppSpace.xl,
          ),
          child: Column(
            children: [
              // A marca com um reflexo de ouro que passa a cada poucos segundos.
              AnimatedBuilder(
                animation: _clock,
                builder: (context, child) {
                  // 6 passagens por volta do relógio; cada uma ocupa 40% do ciclo.
                  final f = (_clock.value * 6) % 1;
                  final x = -1.6 + (f / 0.4).clamp(0.0, 1.0) * 3.2;
                  return ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (r) => LinearGradient(
                      begin: Alignment(x - 0.6, 0),
                      end: Alignment(x + 0.6, 0),
                      colors: const [
                        AppRoles.reward,
                        Color(0xFFFFF4D6),
                        AppRoles.reward,
                      ],
                    ).createShader(r),
                    child: child,
                  );
                },
                child: Text(
                  context.l10n.paywallTitle.toUpperCase(),
                  style: AppTypography.label(
                    color: AppRoles.reward,
                    size: 13,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AppTypography.display(size: 34, color: a.text).copyWith(
                  shadows: [
                    Shadow(
                      color: AppRoles.reward.withValues(alpha: 0.35),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
                child: Text(
                  widget.body,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    size: 15,
                    height: 1.45,
                    color: a.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroLightPainter extends CustomPainter {
  final Animation<double> t;

  _HeroLightPainter(this.t) : super(repaint: t);

  static const _rays = 16;
  static const _motes = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final v = t.value;
    // O Anan fica no centro da faixa de 190 px, que começa 140 px abaixo.
    final c = Offset(size.width / 2, 140 + 95);
    final reach = size.longestSide * 0.75;
    final breath = (math.sin(v * math.pi * 2 * 4) + 1) / 2;

    // Raios: leque girando uma volta a cada 24 s.
    final rays = Paint()
      ..shader = RadialGradient(
        colors: [
          AppRoles.reward.withValues(alpha: 0.20 + breath * 0.06),
          AppRoles.reward.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: reach));
    final base = v * math.pi * 2;
    const half = math.pi / _rays / 2.2;
    for (var i = 0; i < _rays; i++) {
      final ang = base + i * math.pi * 2 / _rays;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(
          c.dx + math.cos(ang - half) * reach,
          c.dy + math.sin(ang - half) * reach,
        )
        ..lineTo(
          c.dx + math.cos(ang + half) * reach,
          c.dy + math.sin(ang + half) * reach,
        )
        ..close();
      canvas.drawPath(path, rays);
    }

    // Núcleo que respira atrás do Anan.
    final coreR = 120 + breath * 16;
    canvas.drawCircle(
      c,
      coreR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppRoles.reward.withValues(alpha: 0.42),
            AppRoles.reward.withValues(alpha: 0.10),
            AppRoles.reward.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: c, radius: coreR)),
    );

    // Poeira de ouro subindo, cada grão no seu ritmo.
    final glow = Paint();
    final dot = Paint();
    for (var i = 0; i < _motes; i++) {
      final seed = (i * 7919) % 1000 / 1000;
      final speed = 2 + (i % 4);
      final p = (v * speed + seed) % 1;
      final x =
          c.dx +
          (seed - 0.5) * size.width * 0.9 +
          math.sin((p + seed) * math.pi * 2) * 10;
      final y = c.dy + 110 - p * 300;
      final fade = math.sin(p * math.pi);
      final r = 1.2 + (i % 3) * 0.7;
      glow.color = AppRoles.reward.withValues(alpha: 0.18 * fade);
      dot.color = const Color(0xFFFFF1C9).withValues(alpha: 0.85 * fade);
      canvas.drawCircle(Offset(x, y), r * 3.2, glow);
      canvas.drawCircle(Offset(x, y), r, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroLightPainter old) => old.t != t;
}

/// Superfície dourada do Plus: ouro no canto da luz, borda dourada fina e
/// o véu de luz por cima.
class _GoldSurface extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _GoldSurface({required this.padding, required this.child});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final radius = BorderRadius.circular(AppRadii.lg);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              AppRoles.reward.withValues(alpha: 0.20),
              a.cardFill,
            ),
            a.cardFill.withValues(alpha: 0.86),
          ],
          stops: const [0, 0.65],
        ),
        border: Border.all(color: AppRoles.reward.withValues(alpha: 0.38)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: AppLight.sheen(strength: 1.4),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Reflexo metálico que atravessa o filho de tempos em tempos (folha de
/// ouro). Desligado ([on] falso) ou com menos movimento, não pinta nada.
class _Sheen extends StatefulWidget {
  final double radius;
  final bool on;
  final Widget child;

  const _Sheen({required this.radius, required this.child, this.on = true});

  @override
  State<_Sheen> createState() => _SheenState();
}

class _SheenState extends State<_Sheen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );

  void _sync() {
    final run = widget.on && !MediaQuery.disableAnimationsOf(context);
    if (run && !_c.isAnimating) {
      _c.repeat();
    } else if (!run && _c.isAnimating) {
      _c
        ..stop()
        ..value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _Sheen old) {
    super.didUpdateWidget(old);
    if (old.on != widget.on) {
      // Recém-escolhido: o reflexo passa já, não no próximo ciclo.
      if (widget.on) _c.value = 0;
      _sync();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      if (widget.on)
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius),
              child: RepaintBoundary(
                child: CustomPaint(painter: _SheenPainter(_c)),
              ),
            ),
          ),
        ),
    ],
  );
}

class _SheenPainter extends CustomPainter {
  final Animation<double> t;

  _SheenPainter(this.t) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    // A faixa cruza nos primeiros 35% do ciclo; o resto é pausa.
    final f = t.value / 0.35;
    if (f <= 0 || f >= 1) return;
    final band = size.height * 1.2;
    final x = -band + f * (size.width + band * 2);
    canvas.save();
    canvas.translate(x, 0);
    canvas.skew(-0.5, 0);
    final rect = Rect.fromLTWH(0, 0, band, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.26),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SheenPainter old) => old.t != t;
}

/// Benefícios em uma linha cada. Fechado mostra os 5 principais; "ver
/// todos" abre o card no lugar e "ver menos" fecha de novo.
class _PerkList extends StatelessWidget {
  final List<PlusPerk> perks;
  final bool expanded;

  /// Null = lista curta, sem abrir/fechar.
  final VoidCallback? onToggle;

  const _PerkList({
    required this.perks,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return _GoldSurface(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.lg,
        AppSpace.lg,
        AppSpace.lg,
        AppSpace.sm,
      ),
      child: AnimatedSize(
        duration: AppMotion.gentle,
        curve: AppMotion.enter,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.paywallPerksHeader.toUpperCase(),
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w800,
                color: AppRoles.reward,
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            for (var i = 0; i < perks.length; i++) ...[
              if (i > 0) Divider(height: 1, thickness: 1, color: a.divider),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    CinematicIcon(
                      glyph: perks[i].glyph,
                      size: AppMetrics.iconLg,
                      accent: AppRoles.reward,
                    ),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Text(
                        perks[i].title(l10n),
                        style: AppTypography.title(size: 15, color: a.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (onToggle != null) ...[
              Divider(height: 1, thickness: 1, color: a.divider),
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        expanded
                            ? l10n.paywallSeeFewerPerks
                            : l10n.paywallSeeAllPerks,
                        style: AppTypography.body(
                          size: 14,
                          weight: FontWeight.w800,
                          color: AppRoles.reward,
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: expanded ? -0.25 : 0.25,
                        duration: AppMotion.standard,
                        curve: AppMotion.enter,
                        child: const CinematicIcon(
                          glyph: CinematicGlyph.chevron,
                          size: 14,
                          accent: AppRoles.reward,
                          framed: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else
              const SizedBox(height: AppSpace.sm),
          ],
        ),
      ),
    );
  }
}

/// Nota num card escuro: renovação, família, o que segue grátis. Texto
/// solto sobre o céu não lia bem.
class _NoteCard extends StatelessWidget {
  final CinematicGlyph glyph;
  final String text;

  const _NoteCard({required this.glyph, required this.text});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: a.cardFill.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: a.insetBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: CinematicIcon(
                glyph: glyph,
                size: AppMetrics.iconMd,
                accent: a.textSecondary,
                framed: false,
              ),
            ),
            const SizedBox(width: AppSpace.sm + 2),
            Expanded(
              child: Text(
                text,
                style: AppTypography.body(
                  size: 12,
                  height: 1.45,
                  color: a.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rodapé fixo: some no fundo por cima da lista, o botão e, abaixo dele,
/// o valor do plano escolhido.
class _Footer extends StatelessWidget {
  final Color fade;
  final double bottomInset;
  final String? error;
  final Widget cta;
  final String? note;

  const _Footer({
    required this.fade,
    required this.bottomInset,
    required this.error,
    required this.cta,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            fade.withValues(alpha: 0),
            fade.withValues(alpha: 0.92),
            fade,
          ],
          stops: const [0, 0.32, 1],
        ),
      ),
      child: ContentFrame(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpace.screen,
            AppSpace.xxl,
            AppSpace.screen,
            AppSpace.md + bottomInset,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (error != null) ...[
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(size: 12, color: a.textSecondary),
                ),
                const SizedBox(height: AppSpace.sm),
              ],
              _Sheen(radius: AppRadii.md, child: cta),
              if (note != null) ...[
                const SizedBox(height: AppSpace.sm),
                AnimatedSwitcher(
                  duration: AppMotion.quick,
                  child: Text(
                    note!,
                    key: ValueKey(note),
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: a.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// O dízimo do Stway numa linha: 10% da receita líquida do Peregrino+
/// para missões e tradução da Bíblia. O detalhe fica no manifesto (site).
class _TitheRow extends StatelessWidget {
  const _TitheRow();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final radius = BorderRadius.circular(AppRadii.lg);
    return Semantics(
      button: true,
      label:
          '${l10n.paywallTitheTitle}. 10% ${l10n.paywallTitheBody} '
          '${l10n.paywallTitheLink}',
      excludeSemantics: true,
      child: Material(
        color: AppRoles.reward.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: AppRoles.reward.withValues(alpha: 0.28)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            ActHaptics.tap();
            openSitePage(manifestoPageUrl);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.lg,
              AppSpace.md,
              AppSpace.md,
              AppSpace.md,
            ),
            child: Row(
              children: [
                Text(
                  '10%',
                  style: AppTypography.display(
                    size: 28,
                    weight: FontWeight.w600,
                    color: AppRoles.reward,
                    height: 1,
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(
                    l10n.paywallTitheBody,
                    style: AppTypography.body(
                      size: 13,
                      height: 1.35,
                      color: a.text,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                const CinematicIcon(
                  glyph: CinematicGlyph.chevron,
                  size: 14,
                  accent: AppRoles.reward,
                  framed: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final Package package;

  /// Plano mensal, para calcular quanto o anual economiza.
  final Package? monthly;
  final bool selected;
  final int? trialDays;
  final int pioneerTaken;
  final int pioneerCap;
  final DateTime? pioneerUntil;

  /// Família com o menor preço por pessoa.
  final bool bestValue;
  final VoidCallback onTap;

  const _PlanTile({
    required this.package,
    required this.monthly,
    required this.selected,
    required this.trialDays,
    required this.pioneerTaken,
    required this.pioneerCap,
    required this.pioneerUntil,
    this.bestValue = false,
    required this.onTap,
  });

  /// Economia do anual sobre 12 mensais, em %. Null se < 10%.
  int? _savings() {
    final m = monthly?.storeProduct.price;
    if (SubscriptionService.planType(package) != PackageType.annual ||
        m == null ||
        m <= 0) {
      return null;
    }
    final pct = ((1 - package.storeProduct.price / (m * 12)) * 100).round();
    return pct >= 10 ? pct : null;
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final product = package.storeProduct;
    final type = SubscriptionService.planType(package);
    final founder = SubscriptionService.isFounderPackage(package);
    final renews = !founder && type != PackageType.lifetime;
    final familySeats = PlusAccess.familySeatsFor(product.identifier);
    final family = familySeats > 0;
    final title = family
        ? (familySeats == 1
              ? l10n.paywallPlanCouple
              : l10n.paywallPlanFamilyOf(familySeats + 1))
        : founder
        ? l10n.paywallPlanFounder
        : switch (type) {
            PackageType.annual => l10n.paywallPlanAnnual,
            PackageType.monthly => l10n.paywallPlanMonthly,
            PackageType.lifetime => l10n.paywallPlanLifetime,
            _ => product.title,
          };
    final savings = family ? null : _savings();
    final perMonth = type == PackageType.annual && !family
        ? product.pricePerMonthString
        : null;
    // Por pessoa no ano: o preço dividido por quem usa (titular + vagas).
    final perPerson = family
        ? NumberFormat.simpleCurrency(
            locale: l10n.localeName,
            name: product.currencyCode,
          ).format(product.price / (familySeats + 1))
        : null;
    // Preço grande à direita é o valor cobrado (Apple 3.1.2): o anual
    // mostra o ano em destaque e o "por mês" só como comparação.
    // Família: o preço por pessoa fica logo abaixo do total, na mesma
    // coluna — a conta se lê de cima para baixo, sem selo no título.
    final (bigPrice, smallPrice) = family
        ? (
            l10n.paywallPricePerYearShort(product.priceString),
            l10n.paywallPerPersonShort(perPerson!),
          )
        : switch (type) {
            PackageType.annual when perMonth != null => (
              l10n.paywallPricePerYearShort(product.priceString),
              l10n.paywallPricePerMonthShort(perMonth),
            ),
            PackageType.monthly => (
              l10n.paywallPricePerMonthShort(product.priceString),
              null,
            ),
            PackageType.lifetime => (
              product.priceString,
              l10n.paywallOnceShort,
            ),
            _ => (
              product.priceString,
              SubscriptionService.packageLabel(package),
            ),
          };
    // Pioneiro: o selo diz o que importa — é vitalício. O "lançamento"
    // fica no prazo e nas vagas, que abrem no card.
    // Família: sem selo no título. O "Melhor valor" fica sobre a borda
    // do card, com o Anan, para não brigar com o nome nem com o preço.
    final badge = founder
        ? l10n.paywallPlanLifetime
        : family
        ? null
        : type == PackageType.annual
        ? (savings != null ? l10n.paywallSave(savings) : l10n.paywallBestValue)
        : null;
    // Família: quem entra e como, numa linha (cada um com a sua conta).
    final subtitle = founder
        ? l10n.paywallFounderNote
        : family
        ? l10n.paywallFamilySeatsLine(familySeats)
        : trialDays != null
        ? l10n.paywallTrialDays(trialDays!)
        : null;
    final radius = BorderRadius.circular(AppRadii.lg);

    final card = Semantics(
      button: true,
      selected: selected,
      child: _Sheen(
        radius: AppRadii.lg,
        on: selected,
        child: AnimatedContainer(
          duration: AppMotion.standard,
          curve: AppMotion.enter,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: selected
                ? Color.lerp(a.cardFill, AppRoles.reward, 0.16)
                : a.cardFill.withValues(alpha: 0.72),
            border: Border.all(
              width: 2,
              color: selected
                  ? AppRoles.reward
                  : a.insetBorder.withValues(alpha: 0.6),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppRoles.reward.withValues(alpha: 0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _Radio(on: selected),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    style: AppTypography.title(
                                      size: 17,
                                      color: a.text,
                                    ),
                                  ),
                                  if (badge != null)
                                    SoftBadge(
                                      text: founder
                                          ? badge.toUpperCase()
                                          : badge,
                                      glyph: founder
                                          ? CinematicGlyph.crown
                                          : null,
                                      accent: AppRoles.reward,
                                      solid: selected || founder,
                                    ),
                                ],
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: AppTypography.body(
                                    size: 12,
                                    weight: FontWeight.w700,
                                    color: a.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpace.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              bigPrice,
                              style: AppTypography.title(
                                size: 17,
                                color: a.text,
                              ),
                            ),
                            if (smallPrice != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                smallPrice,
                                style: family
                                    ? AppTypography.body(
                                        size: 12,
                                        weight: FontWeight.w800,
                                        color: AppRoles.reward,
                                      )
                                    : AppTypography.body(
                                        size: 11,
                                        color: a.textFaint,
                                      ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    // Plano escolhido abre os detalhes no próprio card: o
                    // Pioneiro mostra vagas e prazo; quem renova mostra a
                    // renovação automática (Apple 3.1.2), sem bloco solto.
                    if (founder || renews)
                      AnimatedSize(
                        duration: AppMotion.gentle,
                        curve: AppMotion.enter,
                        alignment: Alignment.topCenter,
                        child: !selected
                            ? const SizedBox(width: double.infinity)
                            : founder
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpace.md,
                                  left: 22 + AppSpace.md,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _PioneerCounter(
                                      taken: pioneerTaken,
                                      cap: pioneerCap,
                                      until: pioneerUntil,
                                    ),
                                    const SizedBox(height: AppSpace.sm),
                                    Text(
                                      pioneerUntil == null
                                          ? l10n.paywallFounderLimitCap(
                                              pioneerCap,
                                            )
                                          : l10n.paywallFounderLimitUntil(
                                              DateFormat.MMMMd(
                                                l10n.localeName,
                                              ).format(pioneerUntil!),
                                              pioneerCap,
                                            ),
                                      style: AppTypography.body(
                                        size: 12,
                                        weight: FontWeight.w700,
                                        color: AppRoles.reward,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpace.md,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: a.divider,
                                    ),
                                    const SizedBox(height: AppSpace.md),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 22,
                                          child: CinematicIcon(
                                            glyph: CinematicGlyph.refresh,
                                            size: AppMetrics.iconSm,
                                            accent: a.textSecondary,
                                            framed: false,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpace.md),
                                        Expanded(
                                          child: Text(
                                            l10n.paywallAutoRenew,
                                            style: AppTypography.body(
                                              size: 12,
                                              height: 1.45,
                                              color: a.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (!(family && bestValue)) return card;
    // Anan sentado na borda de cima, com a etiqueta ao lado. O espaço a
    // mais em cima é o que a etiqueta ocupa fora do card.
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          Positioned(
            top: -24,
            left: 8,
            child: IgnorePointer(
              child: _BestValueTag(label: l10n.paywallBestValue),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Melhor valor" sobre a borda do card: o Anan feliz e uma etiqueta
/// pequena, contornada, no tom do card — chama menos que o preço.
class _BestValueTag extends StatelessWidget {
  final String label;

  const _BestValueTag({required this.label});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CloudMascot(face: CloudFace.feliz, size: 36, react: false),
        Transform.translate(
          offset: const Offset(-4, 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: a.cardFill,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: AppRoles.reward.withValues(alpha: 0.7)),
            ),
            child: Text(
              label,
              style: AppTypography.body(
                size: 11,
                weight: FontWeight.w800,
                color: AppRoles.reward,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Rádio: escolher, não navegar. O miolo cresce ao marcar.
class _Radio extends StatelessWidget {
  final bool on;

  const _Radio({required this.on});

  @override
  Widget build(BuildContext context) {
    final tone = on ? AppRoles.reward : Appearance.of(context).textFaint;
    return AnimatedContainer(
      duration: AppMotion.quick,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: tone, width: 2),
      ),
      alignment: Alignment.center,
      child: AnimatedScale(
        scale: on ? 1 : 0,
        duration: AppMotion.standard,
        curve: AppMotion.enter,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppRoles.reward,
          ),
        ),
      ),
    );
  }
}

/// Como o teste funciona, em três marcos com a data real de cada um:
/// "Dia 14" é hoje + 14, quando o teste acaba e a loja cobra.
class _TrialSteps extends StatelessWidget {
  final Package package;
  final int days;

  const _TrialSteps({required this.package, required this.days});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    String date(int day) => DateFormat(
      'd MMM',
      l10n.localeName,
    ).format(DateTime(now.year, now.month, now.day + day)).replaceAll('.', '');
    return _PlanSteps(
      title: l10n.paywallTimelineTitle(days),
      steps: [
        (l10n.paywallTimelineToday, l10n.paywallTimelineTodayBody),
        (
          l10n.paywallTimelineDay(days - 1, date(days - 1)),
          l10n.paywallTimelineReminderBody,
        ),
        (
          l10n.paywallTimelineDay(days, date(days)),
          l10n.paywallTimelineChargeBody(
            SubscriptionService.packageLabel(package),
          ),
        ),
      ],
      footnote: '',
    );
  }
}

/// Vagas do Pioneiro que restam (de um teto fixo) e dias até o prazo.
/// A barra esvazia conforme as vagas acabam.
class _PioneerCounter extends StatelessWidget {
  final int taken;
  final int cap;
  final DateTime? until;

  const _PioneerCounter({required this.taken, required this.cap, this.until});

  /// Dias até o último dia de venda (0 = hoje é o último). Null sem prazo.
  int? _daysLeft() {
    final end = until;
    if (end == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(end.year, end.month, end.day);
    final days = (last.difference(today).inHours + 12) ~/ 24;
    return days < 0 ? null : days;
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final total = cap <= 0 ? 1 : cap;
    final left = (total - taken).clamp(0, total);
    final fill = (left / total).clamp(0.0, 1.0);
    final days = _daysLeft();
    final caption = [
      l10n.paywallFounderRemaining(total),
      if (days != null) l10n.paywallFounderDaysLeft(days),
    ].join(' · ');
    return Semantics(
      label: '$left $caption',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$left',
                style: AppTypography.display(size: 24, color: a.text),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Text(
                  caption,
                  style: AppTypography.body(size: 13, color: a.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.hair),
            child: SizedBox(
              height: AppSpace.xs,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: a.insetFill),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fill,
                    child: const ColoredBox(color: AppRoles.reward),
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

/// Passos do teste e a nota legal no mesmo card. A nota fica apagada
/// para não repetir o que os passos já disseram.
class _PlanSteps extends StatelessWidget {
  final String title;
  final List<(String, String)> steps;
  final String footnote;

  const _PlanSteps({
    required this.title,
    required this.steps,
    required this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title.isNotEmpty)
            Text(title, style: AppTypography.title(size: 16, color: a.text)),
          if (steps.isNotEmpty) ...[
            const SizedBox(height: AppSpace.md),
            for (var i = 0; i < steps.length; i++)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 22,
                      child: Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == 0 ? AppRoles.reward : a.insetFill,
                              border: Border.all(
                                color: i == 0 ? AppRoles.reward : a.textFaint,
                                width: 2,
                              ),
                            ),
                          ),
                          if (i < steps.length - 1)
                            Expanded(
                              child: Container(width: 2, color: a.insetBorder),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: i < steps.length - 1 ? AppSpace.md : 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              steps[i].$1,
                              style: AppTypography.body(
                                size: 13,
                                weight: FontWeight.w700,
                                color: a.text,
                              ),
                            ),
                            Text(
                              steps[i].$2,
                              style: AppTypography.body(
                                size: 12,
                                color: a.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (footnote.isNotEmpty) ...[
            SizedBox(height: steps.isEmpty ? 0 : AppSpace.lg),
            Text(
              footnote,
              style: AppTypography.body(size: 11, color: a.textFaint),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegalLinks extends StatelessWidget {
  final SubscriptionService sub;

  const _LegalLinks({required this.sub});

  /// Restaurar sempre responde: achou, não achou ou falhou. Calado, a
  /// pessoa não sabe se o toque funcionou (e a Apple testa este botão).
  Future<void> _restore(BuildContext context) async {
    // Restaurar no ID anônimo pode tirar o Plus de uma conta de verdade:
    // visitante entra antes (o login já traz o Plus da conta).
    if (!await GuestGate.requireAccount(context, reason: 'restore')) return;
    if (!context.mounted) return;
    final l10n = context.l10n;
    final found = await sub.restore();
    if (!context.mounted) return;
    final failed = found == null && sub.lastError != null;
    if (found == null && !failed) return;
    await showAppToastFor(
      context,
      message: failed
          ? sub.lastError!
          : found!
          ? l10n.paywallRestoreDone
          : l10n.paywallRestoreNone,
      glyph: found == true ? CinematicGlyph.check : CinematicGlyph.wrong,
      tone: found == true ? AppToastTone.accent : AppToastTone.warn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextCta(
          label: l10n.paywallRestore,
          onTap: sub.loading ? null : () => _restore(context),
          color: a.text,
        ),
        // Passe de trilha recebido antes de instalar o app.
        TextCta(
          label: l10n.inviteHaveCodeTitle,
          onTap: () => enterTrailGiftCode(context),
          color: a.text,
        ),
        TextCta(
          label: l10n.legalTerms,
          onTap: () => openSitePage(termsPageUrl),
          color: a.text,
        ),
        TextCta(
          label: l10n.legalPrivacy,
          onTap: () => openSitePage(privacyPageUrl),
          color: a.text,
        ),
        if (defaultTargetPlatform == TargetPlatform.iOS)
          TextCta(
            label: l10n.paywallAppleEula,
            onTap: () => openSitePage(_appleEulaUrl),
            color: a.text,
          ),
      ],
    );
  }
}

/// Nome do plano ativo (Pioneiro, Anual, Mensal, Vitalício). Pioneiro
/// vem antes do tipo: o produto é anual, no preço do lançamento.
///
/// Casal e Família: o titular vê o tamanho do plano; o membro (Plus
/// promocional vindo de [joined]) vê de quem é a família.
String plusPlanLabel(
  AppLocalizations l10n,
  SubscriptionService sub, {
  FamilyPlan? joined,
}) => sub.plusIsFamily
    ? (sub.familySeats == 1
          ? l10n.paywallPlanCouple
          : l10n.paywallPlanFamilyOf(sub.familySeats + 1))
    : joined != null && plusFromFamily(sub, joined)
    ? l10n.familyPlanOf(
        joined.ownerName.isEmpty ? l10n.familySomeone : joined.ownerName,
      )
    : sub.plusIsFounder
    ? l10n.paywallPlanFounder
    : switch (sub.plusPackageType) {
        PackageType.annual => l10n.paywallPlanAnnual,
        PackageType.monthly => l10n.paywallPlanMonthly,
        PackageType.lifetime => l10n.paywallPlanLifetime,
        _ => sub.plusLifetime ? l10n.paywallPlanLifetime : l10n.paywallTitle,
      };

/// O Plus desta conta vem da família de outra pessoa (promocional do
/// RevenueCat), não de uma compra própria na loja.
bool plusFromFamily(SubscriptionService sub, FamilyPlan? joined) =>
    joined != null &&
    sub.isPeregrinoPlus &&
    (sub.plusProductId ?? '').startsWith('rc_promo');

/// Estado do plano: renova em, teste até, cancelada, problema de pagamento.
String plusStatusLabel(AppLocalizations l10n, SubscriptionService sub) {
  final until = sub.plusExpiresAt;
  final date = until == null
      ? ''
      : DateFormat.yMMMd(l10n.localeName).format(until.toLocal());
  return sub.plusBillingIssue
      ? l10n.paywallBillingIssue
      : sub.plusLifetime
      ? l10n.paywallLifetimeActive
      : sub.plusInTrial
      ? l10n.paywallTrialUntil(date)
      : sub.plusWillRenew
      ? l10n.paywallRenewsOn(date)
      : l10n.paywallEndsOn(date);
}

/// Assinante: qual plano, até quando, e o caminho para mudar ou cancelar.
class _YourPlan extends StatelessWidget {
  final SubscriptionService sub;

  const _YourPlan({required this.sub});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final joined = context.watch<FamilyService?>()?.joined;
    final fromFamily = plusFromFamily(sub, joined);
    final plan = plusPlanLabel(l10n, sub, joined: joined);
    final status = plusStatusLabel(l10n, sub);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.paywallYourPlan.toUpperCase(),
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w800,
              color: AppRoles.reward,
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(plan, style: AppTypography.title(size: 18, color: a.text)),
          const SizedBox(height: 2),
          Text(
            status,
            style: AppTypography.body(
              size: 13,
              color: sub.plusBillingIssue ? AppRoles.risk : a.textSecondary,
            ),
          ),
          // Plus da família de outra pessoa: não há assinatura para gerenciar.
          if (!sub.plusLifetime && !fromFamily) ...[
            const SizedBox(height: AppSpace.md),
            GhostCta(
              label: l10n.paywallManage,
              expanded: true,
              onTap: sub.openManagement,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.paywallManageHint,
              textAlign: TextAlign.center,
              style: AppTypography.body(size: 11, color: a.textFaint),
            ),
          ],
          // Convite que vira assinatura: 1 mês (guardado, para quem assina).
          const SizedBox(height: AppSpace.md),
          Text(
            l10n.referralInviteLine,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w700,
              color: AppRoles.reward,
            ),
          ),
          if (ReferralRewardsService.instance.banked > 0) ...[
            const SizedBox(height: 4),
            Text(
              l10n.referralBankedLine(ReferralRewardsService.instance.banked),
              textAlign: TextAlign.center,
              style: AppTypography.body(size: 11, color: a.textFaint),
            ),
          ],
        ],
      ),
    );
  }
}

/// Festa do Anan no instante em que a assinatura confirma.
Future<void> showPlusWelcomeSheet(BuildContext context) {
  ActHaptics.confirm();
  return showAppSheet<void>(context, builder: (_) => const _PlusWelcomeSheet());
}

class _PlusWelcomeSheet extends StatelessWidget {
  const _PlusWelcomeSheet();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;

    return AppSheetPanel(
      tint: AppRoles.reward,
      background: const ConfettiOverlay(active: true, cinematic: true),
      padding: const EdgeInsets.fromLTRB(
        AppSpace.xxl,
        AppSpace.screen + 8,
        AppSpace.xxl,
        AppSpace.screen,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          AppSheetHeader(
            leading: const CloudMascot(face: CloudFace.sucesso, size: 120),
            title: l10n.paywallWelcomeTitle,
            center: true,
            celebration: true,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.paywallWelcomeBody,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              height: 1.45,
              color: a.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          CopperCta(
            label: l10n.commonGotIt,
            onTap: () => Navigator.pop(context),
            trailing: null,
            dense: true,
          ),
        ],
      ),
    );
  }
}
