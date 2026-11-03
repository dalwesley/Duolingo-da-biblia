import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../screens/support_screen.dart';
import '../services/analytics_service.dart';
import '../services/league_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/home_support.dart';
import 'coming_soon_trails_card.dart';

/// Rodapé da Home: faixa de apoio (1×/semana; cooldown pós-apoiador).
class HomeSupportBanner extends StatefulWidget {
  const HomeSupportBanner({super.key});

  @override
  State<HomeSupportBanner> createState() => _HomeSupportBannerState();
}

class _HomeSupportBannerState extends State<HomeSupportBanner> {
  HomeSupportKind? _kind;
  bool _ready = false;
  bool _marked = false;
  String? _shownWeek;
  bool _resolving = false;
  bool _dirty = false;
  SubscriptionService? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _sub = context.read<SubscriptionService>()..addListener(_onSub);
      _resolve();
    });
  }

  @override
  void dispose() {
    _sub?.removeListener(_onSub);
    super.dispose();
  }

  /// Loja ficou pronta ou apoio mudou (compra / restore): recalcula a faixa.
  void _onSub() {
    if (!mounted) return;
    if (_resolving) {
      _dirty = true;
      return;
    }
    _resolve();
  }

  Future<void> _resolve() async {
    if (_resolving) {
      _dirty = true;
      return;
    }
    _resolving = true;
    try {
      do {
        _dirty = false;
        final sub = _sub ?? context.read<SubscriptionService>();
        var lastSupported = await HomeSupport.loadLastSupportedAt();
        // Apoiador sem data local (compra antiga / outro aparelho): começa o
        // cooldown agora, sem empurrar o convite de retorno na mesma semana.
        if (sub.isSupporter && lastSupported == null) {
          await HomeSupport.markSupported();
          lastSupported = DateTime.now();
        }
        final week = LeagueService.weekKey();
        final lastShownWeek = await HomeSupport.loadLastShownWeek();
        final kind = HomeSupport.pick(
          storeReady: sub.supportConfigured,
          isSupporter: sub.isSupporter,
          thisWeek: week,
          // A semana gravada por esta própria faixa não a esconde: senão o
          // próximo notify da loja (ou voltar do apoio sem comprar) a tirava.
          lastShownWeek: _shownWeek == week ? null : lastShownWeek,
          today: DateTime.now(),
          lastSupportedAt: lastSupported,
        );
        if (!mounted) return;
        if (kind != null && lastShownWeek != week) {
          await HomeSupport.markShown(week);
          _shownWeek = week;
          if (!_marked) {
            _marked = true;
            AnalyticsService.instance.logEvent('home_support_view', {
              'kind': kind.name,
            });
          }
        }
        if (!mounted) return;
        setState(() {
          _kind = kind;
          _ready = true;
        });
      } while (_dirty && mounted);
    } finally {
      _resolving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionService>();
    if (!_ready || _kind == null || !sub.supportConfigured) {
      return const SizedBox.shrink();
    }
    // Compra nesta sessão a partir do pedido inicial: some na hora. O
    // "again" some no re-_resolve após markSupported + notify.
    if (sub.isSupporter && _kind == HomeSupportKind.ask) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final again = _kind == HomeSupportKind.again;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.section),
      child: DonateCard(
        title: again ? l10n.homeSupportAgainTitle : l10n.homeSupportTitle,
        body: again ? l10n.homeSupportAgainBody : l10n.homeSupportBody,
        cta: again ? l10n.homeSupportAgainCta : l10n.homeSupportCta,
        onDonate: () async {
          await openSupport(context);
          if (mounted) _resolve();
        },
      ),
    );
  }
}
