import 'package:flutter/material.dart';
import '../models/trail_catalog.dart';
import '../theme/app_theme.dart';
import '../theme/module_palettes.dart';

/// Tema visual por módulo — nós/caminho/texto (céu vem da Home).
class GenesisModuleTheme {
  final String narrative;
  final String verse;
  final Color pathActive;
  final Color pathInactive;
  final Color nodeCurrentTop;
  final Color nodeCurrentBottom;
  final Color decorColor;

  const GenesisModuleTheme({
    required this.narrative,
    required this.verse,
    required this.pathActive,
    required this.pathInactive,
    required this.nodeCurrentTop,
    required this.nodeCurrentBottom,
    required this.decorColor,
  });

  static const _gold = AppColors.accent;
  static final _pathIdle = Colors.white.withValues(alpha: 0.28);

  static GenesisModuleTheme forModule(
    String title, {
    TrailRealm? realm,
    String? trailSlug,
  }) {
    final resolved = realm ?? realmFor(title: title, trailSlug: trailSlug);
    return switch (title) {
      'A Criação' => _theme(
          narrative: 'Do vazio à luz — os seis dias em que tudo começou.',
          verse: 'Gênesis 1:1–2:3',
          swatch: ModulePalettes.creation,
        ),
      'O Jardim' => _theme(
          narrative: 'O Éden — perfeição, tentação e a queda.',
          verse: 'Gênesis 2:4–3:24',
          swatch: ModulePalettes.garden,
        ),
      'Depois do Éden' => _theme(
          narrative: 'Caim, o dilúvio, Babel — e a promessa de Abraão.',
          verse: 'Gênesis 4–11',
          swatch: ModulePalettes.afterEden,
        ),
      'Abraão' => _theme(
          narrative: 'Do chamado a Moriá — fé, aliança e provisão.',
          verse: 'Gênesis 12–25',
          swatch: ModulePalettes.abraham,
        ),
      'Isaque e Jacó' => _theme(
          narrative: 'A promessa na família — rivalidade, Betel e novo nome.',
          verse: 'Gênesis 24–35',
          swatch: ModulePalettes.isaacJacob,
        ),
      'José' => _theme(
          narrative: 'Da cisterna ao palácio — providência que salva muitos.',
          verse: 'Gênesis 37–50',
          swatch: ModulePalettes.joseph,
        ),
      'Opressão no Egito' => _theme(
          narrative: 'Escravidão, clamor e o Deus que ouve.',
          verse: 'Êxodo 1–2',
          swatch: ModulePalettes.oppression,
        ),
      'A Libertação' => _theme(
          narrative: 'Pragas, Páscoa e o Mar Vermelho — Deus liberta Seu povo.',
          verse: 'Êxodo 7–14',
          swatch: ModulePalettes.liberation,
        ),
      'O Início' => _theme(
          narrative: 'O Verbo se fez carne — batismo e fidelidade no deserto.',
          verse: 'João 1; Mateus 3–4',
          swatch: ModulePalettes.beginning,
        ),
      'Ensino e Sinais' => _theme(
          narrative: 'Bem-aventuranças, parábolas e milagres do Reino.',
          verse: 'Mateus 5–13',
          swatch: ModulePalettes.teaching,
        ),
      'Cruz e Ressurreição' => _theme(
          narrative: 'Ceia, cruz e o túmulo vazio — o centro do evangelho.',
          verse: 'Lucas 22; Mateus 28',
          swatch: ModulePalettes.cross,
        ),
      'A Igreja nasce' => _theme(
          narrative: 'Ascensão, Pentecostes e a comunidade do Espírito.',
          verse: 'Atos 1–2',
          swatch: ModulePalettes.church,
        ),
      'Esperança final' => _theme(
          narrative: 'Cartas, Cordeiro e nova criação — a esperança dos fieis.',
          verse: 'Apocalipse 1–21',
          swatch: ModulePalettes.hope,
        ),
      _ => _theme(
          narrative: 'Sua jornada pela Palavra.',
          verse: resolved == TrailRealm.novoTestamento
              ? 'Novo Testamento'
              : 'Antigo Testamento',
          swatch: resolved == TrailRealm.novoTestamento
              ? ModulePalettes.ntFallback
              : ModulePalettes.atFallback,
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

  static GenesisModuleTheme _theme({
    required String narrative,
    required String verse,
    required ModuleSwatch swatch,
  }) {
    return GenesisModuleTheme(
      narrative: narrative,
      verse: verse,
      pathActive: _gold,
      pathInactive: _pathIdle,
      nodeCurrentTop: swatch.nodeTop,
      nodeCurrentBottom: swatch.nodeBottom,
      decorColor: swatch.decor,
    );
  }
}
