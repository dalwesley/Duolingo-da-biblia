import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../l10n/app_language.dart';
import '../l10n/gen/app_localizations.dart';
import '../services/plus_log.dart';
import '../services/analytics_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/act_feel.dart';
import '../widgets/app_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/anan_speech.dart';
import '../widgets/coming_soon_trails_card.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/home_brand_backdrop.dart';
import '../widgets/immersive_background.dart';
import '../widgets/plus_perks.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';

/// Paywall do Peregrino+. Abre por Ajustes, pelos recursos bloqueados e
/// pelas ofertas (no máx. 1 por semana, fora da cena) — nunca no meio de uma
/// cena, no onboarding ou no login.
///
/// Ordem: por que apoiar → o que vem → o que segue grátis → planos, cada
/// um com a explicação colada nele → assinar (ao fim da lista).
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

/// Pioneiro primeiro (é a oferta de lançamento), depois o anual herói,
/// o mensal âncora e o restante. Os dois anuais têm o mesmo tipo —
/// desempata o produto.
int _rank(Package p) => SubscriptionService.isFounderPackage(p)
    ? 0
    : switch (SubscriptionService.planType(p)) {
        PackageType.annual => 1,
        PackageType.monthly => 2,
        PackageType.lifetime => 3,
        _ => 4,
      };

class _PaywallScreenState extends State<PaywallScreen> {
  String? _selectedId;
  String _viewState = 'offer';

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
    final mode = context.watch<ProgressService>().settings.appearanceMode;
    final a = AppearanceStyle.resolve(mode);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    final packages = [...sub.packagesForSale]
      ..sort((x, y) => _rank(x).compareTo(_rank(y)));
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

    return ImmersiveScaffold(
      mode: mode,
      style: a,
      frameBody: false,
      // A trilha STWAY do tema escolhido, como no fundo das abas.
      background: Stack(
        fit: StackFit.expand,
        children: [
          AmbientAtmosphere(phase: a.phase),
          HomeBrandBackdrop(style: a),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpace.screen,
              MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
              AppSpace.screen,
              0,
            ),
            child: TopBar(
              inline: true,
              immersive: true,
              dark: true,
              title: l10n.paywallTitle,
              onBack: () => Navigator.pop(context),
              leadingGlyph: CinematicGlyph.plus,
            ),
          ),
          Expanded(
            child: ContentFrame(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpace.screen,
                  AppSpace.lg,
                  AppSpace.screen,
                  AppSpace.xl + bottom,
                ),
                children: [
                  // O recado de abertura é a fala do Anan.
                  AnanSpeech(
                    face: paid ? CloudFace.sucesso : CloudFace.feliz,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          paid
                              ? l10n.paywallAlreadyPlus
                              : promoDate != null
                              ? l10n.paywallLaunchFreeTitle
                              : l10n.paywallHeadline,
                          textAlign: TextAlign.center,
                          style: AppTypography.display(
                            size: 28,
                            color: AnanSpeechBubble.ink,
                          ),
                        ),
                        const SizedBox(height: AppSpace.sm),
                        Text(
                          paid
                              ? l10n.paywallThanks
                              : promoDate != null
                              ? l10n.paywallLaunchFreeBody(promoDate)
                              : l10n.paywallPitch,
                          textAlign: TextAlign.center,
                          style: AppTypography.body(
                            size: 14,
                            color: AnanSpeechBubble.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  if (paid) ...[
                    _YourPlan(sub: sub),
                    const SizedBox(height: AppSpace.lg),
                    // Assinante também acha Restaurar/Termos/Privacidade.
                    _LegalLinks(sub: sub),
                    const SizedBox(height: AppSpace.lg),
                  ],
                  PlusPerkCard(detailed: true, footer: const _FreeForever()),
                  if (offer) ...[
                    const SizedBox(height: AppSpace.xl),
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
                    for (final p in packages) ...[
                      _PlanTile(
                        package: p,
                        monthly: packages
                            .where(
                              (x) =>
                                  SubscriptionService.planType(x) ==
                                  PackageType.monthly,
                            )
                            .firstOrNull,
                        selected: p.identifier == selected!.identifier,
                        trialDays: sub.trialDaysFor(p),
                        onTap: () {
                          AnalyticsService.instance.logPaywallPlanSelect(
                            source: widget.source,
                            productId: p.storeProduct.identifier,
                          );
                          setState(() => _selectedId = p.identifier);
                        },
                      ),
                      if (p.identifier == selected.identifier) ...[
                        const SizedBox(height: 10),
                        _PlanExplain(
                          package: p,
                          trialDays: sub.trialDaysFor(p),
                          pioneerTaken: sub.pioneerTaken,
                          pioneerCap: sub.pioneerCap,
                        ),
                      ],
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: AppSpace.lg),
                    _LegalLinks(sub: sub),
                    const SizedBox(height: AppSpace.xl),
                    if (sub.lastError != null) ...[
                      Text(
                        sub.lastError!,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          size: 12,
                          color: a.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpace.sm),
                    ],
                    CopperCta(
                      label: trial != null
                          ? l10n.paywallStartTrial(trial)
                          : renews
                          ? l10n.paywallSubscribe
                          : l10n.paywallBuyOnce,
                      expanded: true,
                      onTap: sub.loading ? null : () => _subscribe(selected!),
                    ),
                    if (renews) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.paywallCancelAnytime,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(size: 12, color: a.textFaint),
                      ),
                    ],
                  ] else if (!paid) ...[
                    // Sem oferta na tela (falha da loja), Restaurar continua:
                    // é exatamente quem trocou de aparelho que precisa dele.
                    const SizedBox(height: AppSpace.xl),
                    if (promoDate == null)
                      Text(
                        // Loja ligada sem oferta é falha de conexão, não
                        // "versão sem assinatura".
                        sub.isConfigured
                            ? l10n.paywallOffersFailed
                            : l10n.paywallUnavailable,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(size: 12, color: a.textFaint),
                      ),
                    if (sub.isConfigured) ...[
                      const SizedBox(height: AppSpace.md),
                      CopperCta(
                        label: l10n.commonTryAgain,
                        expanded: true,
                        onTap: sub.loading
                            ? null
                            : () => unawaited(sub.retryOfferings()),
                      ),
                    ],
                    if (sub.isConfigured) ...[
                      const SizedBox(height: AppSpace.lg),
                      _LegalLinks(sub: sub),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lembra o que não é vendido — as linhas que o Stway não cruza.
class _FreeForever extends StatelessWidget {
  const _FreeForever();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CinematicIcon(
          glyph: CinematicGlyph.book,
          size: AppMetrics.iconMd,
          accent: a.textSecondary,
          framed: false,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            context.l10n.paywallFreeForever,
            style: AppTypography.body(size: 13, color: a.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  final Package package;

  /// Plano mensal, para calcular quanto o anual economiza.
  final Package? monthly;
  final bool selected;
  final int? trialDays;
  final VoidCallback onTap;

  const _PlanTile({
    required this.package,
    required this.monthly,
    required this.selected,
    required this.trialDays,
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
    final title = founder
        ? l10n.paywallPlanFounder
        : switch (type) {
            PackageType.annual => l10n.paywallPlanAnnual,
            PackageType.monthly => l10n.paywallPlanMonthly,
            PackageType.lifetime => l10n.paywallPlanLifetime,
            _ => product.title,
          };
    final savings = _savings();
    final perMonth = type == PackageType.annual
        ? product.pricePerMonthString
        : null;
    // Preço grande à direita é o valor cobrado (Apple 3.1.2): o anual
    // mostra o ano em destaque e o "por mês" só como comparação.
    final (bigPrice, smallPrice) = switch (type) {
      PackageType.annual when perMonth != null => (
        l10n.paywallPricePerYearShort(product.priceString),
        l10n.paywallPricePerMonthShort(perMonth),
      ),
      PackageType.monthly => (
        l10n.paywallPricePerMonthShort(product.priceString),
        null,
      ),
      _ => (product.priceString, SubscriptionService.packageLabel(package)),
    };
    final tone = selected ? AppRoles.reward : a.textFaint;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              color: selected
                  ? Color.lerp(a.cardFill, AppRoles.reward, 0.14)
                  : a.cardFill,
              border: Border.all(
                width: selected ? 2 : 1,
                color: selected
                    ? AppMetrics.accentBorder(alpha: 0.8)
                    : a.insetBorder,
              ),
            ),
            child: Row(
              children: [
                // Rádio: escolher, não navegar.
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: tone, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: selected
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tone,
                          ),
                        )
                      : null,
                ),
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
                            style: AppTypography.title(size: 16, color: a.text),
                          ),
                          if (founder)
                            SoftBadge(
                              text: l10n.paywallFounderBadge,
                              accent: AppRoles.reward,
                            )
                          else if (type == PackageType.annual)
                            SoftBadge(
                              text: savings != null
                                  ? l10n.paywallSave(savings)
                                  : l10n.paywallBestValue,
                              accent: AppRoles.reward,
                            ),
                        ],
                      ),
                      if (founder) ...[
                        const SizedBox(height: 2),
                        Text(
                          l10n.paywallFounderNote,
                          style: AppTypography.body(
                            size: 12,
                            weight: FontWeight.w700,
                            color: a.textSecondary,
                          ),
                        ),
                      ],
                      if (trialDays != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          l10n.paywallTrialDays(trialDays!),
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
                      style: AppTypography.title(size: 17, color: a.text),
                    ),
                    if (smallPrice != null)
                      Text(
                        smallPrice,
                        style: AppTypography.body(size: 11, color: a.textFaint),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Explicação do plano escolhido, colada nele. O teste conta os dias.
/// O Pioneiro diz o preço travado (e, com teste, os dias vêm abaixo).
/// O mensal só guarda a renovação, para o aviso não ficar solto na tela.
class _PlanExplain extends StatelessWidget {
  final Package package;
  final int? trialDays;
  final int pioneerTaken;
  final int pioneerCap;

  const _PlanExplain({
    required this.package,
    required this.trialDays,
    required this.pioneerTaken,
    required this.pioneerCap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final price = SubscriptionService.packageLabel(package);
    final renews =
        SubscriptionService.planType(package) != PackageType.lifetime;
    final days = trialDays;
    final founder = SubscriptionService.isFounderPackage(package);
    // Data real de cada marco: "Dia 14" é hoje + 14, quando o teste acaba
    // e a loja cobra.
    final now = DateTime.now();
    String trialDate(int day) => DateFormat(
      'd MMM',
      l10n.localeName,
    ).format(DateTime(now.year, now.month, now.day + day)).replaceAll('.', '');
    if (days != null) {
      final steps = _PlanSteps(
        title: l10n.paywallTimelineTitle(days),
        steps: [
          (l10n.paywallTimelineToday, l10n.paywallTimelineTodayBody),
          (
            l10n.paywallTimelineDay(days - 1, trialDate(days - 1)),
            l10n.paywallTimelineReminderBody,
          ),
          (
            l10n.paywallTimelineDay(days, trialDate(days)),
            l10n.paywallTimelineChargeBody(price),
          ),
        ],
        footnote: renews ? l10n.paywallAutoRenew : '',
      );
      if (!founder) return steps;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PioneerNote(
            price: package.storeProduct.priceString,
            taken: pioneerTaken,
            cap: pioneerCap,
            footnote: '',
          ),
          const SizedBox(height: AppSpace.md),
          steps,
        ],
      );
    }
    if (founder) {
      return _PioneerNote(
        price: package.storeProduct.priceString,
        taken: pioneerTaken,
        cap: pioneerCap,
        footnote: renews ? l10n.paywallAutoRenew : '',
      );
    }
    if (!renews) return const SizedBox.shrink();
    return _PlanSteps(
      title: '',
      steps: const [],
      footnote: l10n.paywallAutoRenew,
    );
  }
}

/// O preço do Pioneiro, o contador das vagas e a nota legal no mesmo card.
class _PioneerNote extends StatelessWidget {
  final String price;
  final int taken;
  final int cap;
  final String footnote;

  const _PioneerNote({
    required this.price,
    required this.taken,
    required this.cap,
    required this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.paywallFounderTitle,
            style: AppTypography.title(size: 16, color: a.text),
          ),
          const SizedBox(height: AppSpace.md),
          // "0 de 200" no primeiro dia parece app vazio: o contador só
          // aparece quando já há gente suficiente para animar.
          if (taken >= _PioneerCounter.showFrom) ...[
            _PioneerCounter(taken: taken, cap: cap),
            const SizedBox(height: AppSpace.md),
          ],
          Text(
            l10n.paywallFounderBody(price),
            style: AppTypography.body(size: 14, color: a.text),
          ),
          if (footnote.isNotEmpty) ...[
            const SizedBox(height: AppSpace.lg),
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

/// Quantas vagas do Pioneiro já foram ocupadas, de um teto fixo.
class _PioneerCounter extends StatelessWidget {
  final int taken;
  final int cap;

  const _PioneerCounter({required this.taken, required this.cap});

  /// Vagas ocupadas a partir das quais o contador aparece.
  static const showFrom = 20;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final total = cap <= 0 ? 1 : cap;
    final fill = (taken / total).clamp(0.0, 1.0);
    final label =
        '${taken.clamp(0, total)} ${l10n.paywallFounderCounter(total)}';
    return Semantics(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${taken.clamp(0, total)}',
                style: AppTypography.display(size: 24, color: a.text),
              ),
              const SizedBox(width: AppSpace.sm),
              Text(
                l10n.paywallFounderCounter(total),
                style: AppTypography.body(size: 13, color: a.textSecondary),
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
String plusPlanLabel(AppLocalizations l10n, SubscriptionService sub) =>
    sub.plusIsFounder
    ? l10n.paywallPlanFounder
    : switch (sub.plusPackageType) {
        PackageType.annual => l10n.paywallPlanAnnual,
        PackageType.monthly => l10n.paywallPlanMonthly,
        PackageType.lifetime => l10n.paywallPlanLifetime,
        _ => sub.plusLifetime ? l10n.paywallPlanLifetime : l10n.paywallTitle,
      };

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
    final plan = plusPlanLabel(l10n, sub);
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
          if (!sub.plusLifetime) ...[
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
