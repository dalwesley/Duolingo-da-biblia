import '../models/trail.dart';
import '../models/trail_catalog.dart';

/// Regras puras do Peregrino+: quando o recurso fica aberto.
class PlusAccess {
  PlusAccess._();

  /// Dias de graça após a data de fim gravada: cobre falha de rede/loja
  /// e problema de cobrança sem liberar para sempre.
  static const graceDays = 7;

  /// Anual de lançamento (Pioneiro). No Android a loja pode devolver o id
  /// com o plano base (`plus_founder_annual:annual`).
  static const pioneerProductId = 'plus_founder_annual';

  /// Livro é grátis: Antigo e Novo Testamento. O resto (Vida Cristã,
  /// Teologia, trilhas por dor, Sermão do Monte incluso) é tema, e tema é
  /// Peregrino+. As cenas do Sermão continuam grátis pela trilha de Mateus.
  static bool realmIsPlus(TrailRealm realm) =>
      realm != TrailRealm.antigoTestamento &&
      realm != TrailRealm.novoTestamento;

  static bool trailIsPlus(Trail trail) =>
      realmIsPlus(TrailRealm.fromId(trail.realmId));

  /// A cena pede Plus? Numa trilha Plus, a 1ª cena é amostra grátis.
  static bool missionNeedsPlus(Trail trail, String missionSlug) {
    if (!trailIsPlus(trail)) return false;
    final slugs = trail.missionSlugs;
    return slugs.isNotEmpty && slugs.first != missionSlug;
  }

  static bool isPioneerProduct(String? id) =>
      id != null &&
      (id == pioneerProductId || id.startsWith('$pioneerProductId:'));

  /// Aberto para quem tem Plus (assinatura, promoção ou graça do cache).
  ///
  /// Sem loja **configurada** (build sem chaves, de propósito) nada fecha:
  /// não há o que comprar. Loja configurada com oferta vazia/falha de rede
  /// NÃO abre — era o vazamento fail-open: bastava a oferta não carregar
  /// para todo o Plus ficar grátis e sem nenhuma oferta na tela.
  static bool featuresOpen({
    required bool hasPlus,
    required bool storeConfigured,
  }) => hasPlus || !storeConfigured;

  /// O cache do último entitlement conhecido ainda vale?
  ///
  /// Vale até a data de fim; vitalício não vence. Depois do fim, só a
  /// janela de [graceDays] — tempo de a loja responder ou o pagamento
  /// se recuperar. Sem data gravada, não há graça.
  static bool cachedPlusActive({
    required bool cachedPlus,
    required DateTime? expiresAt,
    required DateTime now,
  }) {
    if (!cachedPlus) return false;
    if (expiresAt == null) return true;
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(expiresAt.year, expiresAt.month, expiresAt.day);
    return !today.isAfter(end.add(const Duration(days: graceDays)));
  }
}
