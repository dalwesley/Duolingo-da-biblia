import '../data/entry_trails.dart';
import '../models/trail.dart';

/// Regras puras do Peregrino+: quando o recurso fica aberto.
class PlusAccess {
  PlusAccess._();

  /// Dias de graça após a data de fim gravada: cobre falha de rede/loja
  /// e problema de cobrança sem liberar para sempre.
  static const graceDays = 7;

  /// Anual de lançamento (Pioneiro). No Android a loja pode devolver o id
  /// com o plano base (`plus_founder_annual:annual`).
  static const pioneerProductId = 'plus_founder_annual';

  /// O card da Bíblia (Antigo e Novo Testamento, todos os livros) é grátis.
  /// Os temas, Vida Cristã e Teologia são Peregrino+. As cenas do
  /// Sermão continuam grátis pela trilha de Mateus. As trilhas de entrada
  /// (motivo do onboarding e dores) são a porta do app: grátis inteiras.
  static bool trailIsPlus(Trail trail) =>
      trail.journey.requiresPlus && !EntryTrails.slugs.contains(trail.slug);

  /// A cena pede Plus? Numa trilha Plus, a 1ª cena é amostra grátis.
  static bool missionNeedsPlus(Trail trail, String missionSlug) {
    if (!trailIsPlus(trail)) return false;
    final slugs = trail.missionSlugs;
    return slugs.isNotEmpty && slugs.first != missionSlug;
  }

  /// Peregrino+ de outra pessoa pelo doc público `users/{uid}`
  /// (`plusActive` e `plusExpiresAt`, gravados só pelo webhook). Data de
  /// fim vencida além da graça não conta, mesmo com `plusActive` atrasado.
  static bool profileHasPlus(
    Map<String, dynamic>? data, {
    required DateTime now,
  }) {
    if (data == null || data['plusActive'] != true) return false;
    final raw = data['plusExpiresAt'];
    final expires = raw is String ? DateTime.tryParse(raw) : null;
    if (expires == null) return true;
    return now.isBefore(expires.add(const Duration(days: graceDays)));
  }

  static bool isPioneerProduct(String? id) =>
      id != null &&
      (id == pioneerProductId || id.startsWith('$pioneerProductId:'));

  /// Id do produto sem o plano base do Android (`plus_annual:annual` →
  /// `plus_annual`). Comparar ids de loja sempre por aqui: o pacote da
  /// oferta traz o plano base e o entitlement às vezes não.
  static String baseProductId(String id) => id.split(':').first;

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
