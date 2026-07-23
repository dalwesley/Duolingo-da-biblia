import 'package:flutter/material.dart';
import '../models/trail_catalog.dart';
import '../theme/app_theme.dart';

/// Atmosfera visual por módulo — variação **dentro** da família do reino.
///
/// Canal dual:
/// - **Âncora (reino):** matiz-base do céu nunca sai da família
///   (AT = oceano/tinta, NT = clay/quente).
/// - **Chrome:** path/progress usam açafrão da marca (estáveis em todo o app).
/// - **Módulo:** só muda temperatura, valor e acento secundário.
class GenesisModuleTheme {
  final String narrative;
  final String verse;
  final LinearGradient sky;
  final Color pathActive;
  final Color pathActiveShadow;
  final Color pathInactive;
  final Color pathInactiveShadow;
  final Color nodeCurrentTop;
  final Color nodeCurrentBottom;
  final Color decorColor;
  final TrailRealm realm;

  const GenesisModuleTheme({
    required this.narrative,
    required this.verse,
    required this.sky,
    required this.pathActive,
    required this.pathActiveShadow,
    required this.pathInactive,
    required this.pathInactiveShadow,
    required this.nodeCurrentTop,
    required this.nodeCurrentBottom,
    required this.decorColor,
    required this.realm,
  });

  /// Chrome de marca — açafrão fixo (não muda com a cena).
  static const _gold = AppColors.accent;
  static const _goldDeep = AppColors.accentDark;
  static final _pathIdle = Colors.white.withValues(alpha: 0.28);
  static final _pathIdleShadow = Colors.white.withValues(alpha: 0.12);

  static GenesisModuleTheme forModule(
    String title, {
    TrailRealm? realm,
    String? trailSlug,
  }) {
    final resolved = realm ?? realmFor(title: title, trailSlug: trailSlug);
    return switch (title) {
      'A Criação' => _at(
          narrative: 'Do vazio à luz — os seis dias em que tudo começou.',
          verse: 'Gênesis 1:1–2:3',
          // Abismo oceânico abrindo para aurora — família AT.
          sky: const [
            Color(0xFF04080E),
            Color(0xFF0A1524),
            Color(0xFF163050),
            Color(0xFF2A5078),
            Color(0xFFE0A84A),
          ],
          stops: const [0.0, 0.22, 0.48, 0.72, 1.0],
          nodeTop: const Color(0xFF5A8AB0),
          nodeBottom: const Color(0xFF0E2438),
          decor: AppColors.accentBright,
        ),
      'O Jardim' => _at(
          narrative: 'O Éden — perfeição, tentação e a queda.',
          verse: 'Gênesis 2:4–3:24',
          sky: const [
            Color(0xFF061418),
            Color(0xFF0E3040),
            Color(0xFF1A5868),
            Color(0xFF2A7888),
            Color(0xFF5AB8A8),
          ],
          stops: const [0.0, 0.2, 0.45, 0.72, 1.0],
          nodeTop: const Color(0xFF4AB8A8),
          nodeBottom: const Color(0xFF0E3840),
          decor: const Color(0xFF7AD0C0),
        ),
      'Depois do Éden' => _at(
          narrative: 'Caim, o dilúvio, Babel — e a promessa de Abraão.',
          verse: 'Gênesis 4–11',
          // Tinta terrosa / pó — NÃO clay do NT.
          sky: const [
            Color(0xFF0E1218),
            Color(0xFF1A2430),
            Color(0xFF3A4558),
            Color(0xFF5A6878),
          ],
          stops: const [0.0, 0.32, 0.68, 1.0],
          nodeTop: const Color(0xFF8A9AB0),
          nodeBottom: const Color(0xFF243040),
          decor: const Color(0xFFC4B07A),
        ),
      'Opressão no Egito' => _at(
          narrative: 'Escravidão, clamor e o Deus que ouve.',
          verse: 'Êxodo 1–2',
          sky: const [
            Color(0xFF0A1018),
            Color(0xFF141C28),
            Color(0xFF243040),
            Color(0xFF3A4858),
          ],
          stops: const [0.0, 0.35, 0.7, 1.0],
          nodeTop: const Color(0xFF6A8098),
          nodeBottom: const Color(0xFF182030),
          decor: const Color(0xFFB8A878),
        ),
      'A Libertação' => _at(
          narrative: 'Pragas, Páscoa e o Mar Vermelho — Deus liberta Seu povo.',
          verse: 'Êxodo 7–14',
          // Águas profundas abrindo — ainda blue-family.
          sky: const [
            Color(0xFF061018),
            Color(0xFF0E3048),
            Color(0xFF1A5878),
            Color(0xFF2A7898),
          ],
          stops: const [0.0, 0.35, 0.7, 1.0],
          nodeTop: const Color(0xFF4A98B8),
          nodeBottom: const Color(0xFF0E3040),
          decor: AppColors.accentBright,
        ),
      'O Início' => _nt(
          narrative: 'O Verbo se fez carne — batismo e fidelidade no deserto.',
          verse: 'João 1; Mateus 3–4',
          sky: const [
            Color(0xFF1A0E10),
            Color(0xFF3A2018),
            Color(0xFF6A3A30),
            Color(0xFFE0A898),
          ],
          stops: const [0.0, 0.35, 0.7, 1.0],
          nodeTop: const Color(0xFFFFAB91),
          nodeBottom: const Color(0xFF8B3A2A),
          decor: const Color(0xFFFFAB91),
        ),
      'Ensino e Sinais' => _nt(
          narrative: 'Bem-aventuranças, parábolas e milagres do Reino.',
          verse: 'Mateus 5–13',
          // Clay luminoso — NÃO oceano do AT.
          sky: const [
            Color(0xFF1A1010),
            Color(0xFF3A281E),
            Color(0xFF6B4A38),
            Color(0xFFD4A890),
          ],
          stops: const [0.0, 0.35, 0.7, 1.0],
          nodeTop: const Color(0xFFE8C4A8),
          nodeBottom: const Color(0xFF5C3A2A),
          decor: AppColors.accentBright,
        ),
      'Cruz e Ressurreição' => _nt(
          narrative: 'Ceia, cruz e o túmulo vazio — o centro do evangelho.',
          verse: 'Lucas 22; Mateus 28',
          sky: const [
            Color(0xFF12080C),
            Color(0xFF3A1520),
            Color(0xFF6A2A30),
            Color(0xFFE0A84A),
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
          nodeTop: AppColors.accentBright,
          nodeBottom: const Color(0xFF5C2A1A),
          decor: const Color(0xFFFFD56A),
        ),
      'A Igreja nasce' => _nt(
          narrative: 'Ascensão, Pentecostes e a comunidade do Espírito.',
          verse: 'Atos 1–2',
          sky: const [
            Color(0xFF1A100E),
            Color(0xFF3D2818),
            Color(0xFF6B4A28),
            AppColors.accentBright,
          ],
          stops: const [0.0, 0.35, 0.7, 1.0],
          nodeTop: const Color(0xFFFFE082),
          nodeBottom: const Color(0xFF8B6914),
          decor: const Color(0xFFFFE082),
        ),
      'Esperança final' => _nt(
          narrative: 'Cartas, Cordeiro e nova criação — a esperança dos fieis.',
          verse: 'Apocalipse 1–21',
          sky: const [
            Color(0xFF140C08),
            Color(0xFF3A2018),
            Color(0xFF6B3A28),
            AppColors.ember,
          ],
          stops: const [0.0, 0.35, 0.7, 1.0],
          nodeTop: AppColors.ember,
          nodeBottom: const Color(0xFF6B2E1A),
          decor: AppColors.accent,
        ),
      _ => resolved == TrailRealm.novoTestamento
          ? _nt(
              narrative: 'Sua jornada pela Palavra.',
              verse: 'Novo Testamento',
              sky: RealmVisualsFallback.ntSky,
              nodeTop: AppColors.clay,
              nodeBottom: AppColors.clayDeep,
              decor: AppColors.accent,
            )
          : _at(
              narrative: 'Sua jornada pela Palavra.',
              verse: 'Antigo Testamento',
              sky: RealmVisualsFallback.atSky,
              nodeTop: AppColors.primaryLight,
              nodeBottom: AppColors.primaryDark,
              decor: AppColors.accent,
            ),
    };
  }

  /// Resolve o reino a partir do slug da trilha ou do título do módulo.
  static TrailRealm realmFor({String? title, String? trailSlug}) {
    switch (trailSlug) {
      case 'evangelhos':
      case 'atos':
      case 'apocalipse':
        return TrailRealm.novoTestamento;
      case 'genesis-1-11':
      case 'exodo':
        return TrailRealm.antigoTestamento;
    }
    switch (title) {
      case 'O Início':
      case 'Ensino e Sinais':
      case 'Cruz e Ressurreição':
      case 'A Igreja nasce':
      case 'Esperança final':
        return TrailRealm.novoTestamento;
      default:
        return TrailRealm.antigoTestamento;
    }
  }

  static GenesisModuleTheme _at({
    required String narrative,
    required String verse,
    required List<Color> sky,
    List<double>? stops,
    required Color nodeTop,
    required Color nodeBottom,
    required Color decor,
  }) {
    return GenesisModuleTheme(
      narrative: narrative,
      verse: verse,
      sky: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: sky,
        stops: stops,
      ),
      pathActive: _gold,
      pathActiveShadow: _goldDeep,
      pathInactive: _pathIdle,
      pathInactiveShadow: _pathIdleShadow,
      nodeCurrentTop: nodeTop,
      nodeCurrentBottom: nodeBottom,
      decorColor: decor,
      realm: TrailRealm.antigoTestamento,
    );
  }

  static GenesisModuleTheme _nt({
    required String narrative,
    required String verse,
    required List<Color> sky,
    List<double>? stops,
    required Color nodeTop,
    required Color nodeBottom,
    required Color decor,
  }) {
    return GenesisModuleTheme(
      narrative: narrative,
      verse: verse,
      sky: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: sky,
        stops: stops,
      ),
      pathActive: _gold,
      pathActiveShadow: _goldDeep,
      pathInactive: _pathIdle,
      pathInactiveShadow: _pathIdleShadow,
      nodeCurrentTop: nodeTop,
      nodeCurrentBottom: nodeBottom,
      decorColor: decor,
      realm: TrailRealm.novoTestamento,
    );
  }
}

/// Céus padrão alinhados a [RealmVisuals] — fallback sem módulo conhecido.
class RealmVisualsFallback {
  static const atSky = [
    AppColors.night,
    AppColors.primaryDark,
    AppColors.primary,
  ];
  static const ntSky = [
    Color(0xFF180E10),
    Color(0xFF3A2018),
    Color(0xFF5C3830),
  ];
}
