import 'package:flutter/material.dart';
import '../models/trail_catalog.dart';
import '../theme/app_theme.dart';
import '../theme/module_palettes.dart';

/// Atmosfera visual por módulo — variação **dentro** da família do reino.
///
/// Paletas de cena: [ModulePalettes]. Chrome de marca: [AppColors].
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
          swatch: ModulePalettes.creation,
        ),
      'O Jardim' => _at(
          narrative: 'O Éden — perfeição, tentação e a queda.',
          verse: 'Gênesis 2:4–3:24',
          swatch: ModulePalettes.garden,
        ),
      'Depois do Éden' => _at(
          narrative: 'Caim, o dilúvio, Babel — e a promessa de Abraão.',
          verse: 'Gênesis 4–11',
          swatch: ModulePalettes.afterEden,
        ),
      'Abraão' => _at(
          narrative: 'Do chamado a Moriá — fé, aliança e provisão.',
          verse: 'Gênesis 12–25',
          swatch: ModulePalettes.abraham,
        ),
      'Isaque e Jacó' => _at(
          narrative: 'A promessa na família — rivalidade, Betel e novo nome.',
          verse: 'Gênesis 24–35',
          swatch: ModulePalettes.isaacJacob,
        ),
      'José' => _at(
          narrative: 'Da cisterna ao palácio — providência que salva muitos.',
          verse: 'Gênesis 37–50',
          swatch: ModulePalettes.joseph,
        ),
      'Opressão no Egito' => _at(
          narrative: 'Escravidão, clamor e o Deus que ouve.',
          verse: 'Êxodo 1–2',
          swatch: ModulePalettes.oppression,
        ),
      'A Libertação' => _at(
          narrative: 'Pragas, Páscoa e o Mar Vermelho — Deus liberta Seu povo.',
          verse: 'Êxodo 7–14',
          swatch: ModulePalettes.liberation,
        ),
      'O Início' => _nt(
          narrative: 'O Verbo se fez carne — batismo e fidelidade no deserto.',
          verse: 'João 1; Mateus 3–4',
          swatch: ModulePalettes.beginning,
        ),
      'Ensino e Sinais' => _nt(
          narrative: 'Bem-aventuranças, parábolas e milagres do Reino.',
          verse: 'Mateus 5–13',
          swatch: ModulePalettes.teaching,
        ),
      'Cruz e Ressurreição' => _nt(
          narrative: 'Ceia, cruz e o túmulo vazio — o centro do evangelho.',
          verse: 'Lucas 22; Mateus 28',
          swatch: ModulePalettes.cross,
        ),
      'A Igreja nasce' => _nt(
          narrative: 'Ascensão, Pentecostes e a comunidade do Espírito.',
          verse: 'Atos 1–2',
          swatch: ModulePalettes.church,
        ),
      'Esperança final' => _nt(
          narrative: 'Cartas, Cordeiro e nova criação — a esperança dos fieis.',
          verse: 'Apocalipse 1–21',
          swatch: ModulePalettes.hope,
        ),
      _ => resolved == TrailRealm.novoTestamento
          ? _nt(
              narrative: 'Sua jornada pela Palavra.',
              verse: 'Novo Testamento',
              swatch: ModulePalettes.ntFallback,
            )
          : _at(
              narrative: 'Sua jornada pela Palavra.',
              verse: 'Antigo Testamento',
              swatch: ModulePalettes.atFallback,
            ),
    };
  }

  static TrailRealm realmFor({String? title, String? trailSlug}) {
    switch (trailSlug) {
      case 'evangelhos':
      case 'atos':
      case 'apocalipse':
        return TrailRealm.novoTestamento;
      case 'genesis-1-11':
      case 'genesis-12-50':
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
    required ModuleSwatch swatch,
  }) {
    return GenesisModuleTheme(
      narrative: narrative,
      verse: verse,
      sky: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: swatch.sky,
        stops: swatch.stops,
      ),
      pathActive: _gold,
      pathActiveShadow: _goldDeep,
      pathInactive: _pathIdle,
      pathInactiveShadow: _pathIdleShadow,
      nodeCurrentTop: swatch.nodeTop,
      nodeCurrentBottom: swatch.nodeBottom,
      decorColor: swatch.decor,
      realm: TrailRealm.antigoTestamento,
    );
  }

  static GenesisModuleTheme _nt({
    required String narrative,
    required String verse,
    required ModuleSwatch swatch,
  }) {
    return GenesisModuleTheme(
      narrative: narrative,
      verse: verse,
      sky: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: swatch.sky,
        stops: swatch.stops,
      ),
      pathActive: _gold,
      pathActiveShadow: _goldDeep,
      pathInactive: _pathIdle,
      pathInactiveShadow: _pathIdleShadow,
      nodeCurrentTop: swatch.nodeTop,
      nodeCurrentBottom: swatch.nodeBottom,
      decorColor: swatch.decor,
      realm: TrailRealm.novoTestamento,
    );
  }
}

/// Céus padrão alinhados a [RealmVisuals] — fallback sem módulo conhecido.
class RealmVisualsFallback {
  static List<Color> get atSky => ModulePalettes.atFallback.sky;
  static List<Color> get ntSky => ModulePalettes.ntFallback.sky;
}
