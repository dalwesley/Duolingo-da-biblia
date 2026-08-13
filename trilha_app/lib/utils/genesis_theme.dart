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
      'No deserto' => _theme(
          narrative: 'Maná, Sinai e o tabernáculo — Deus guia no caminho.',
          verse: 'Êxodo 15–40',
          swatch: ModulePalettes.afterEden,
        ),
      'Sacrifícios' => _theme(
          narrative: 'Ofertas e expiação — o altar aponta para a santidade.',
          verse: 'Levítico 1–7',
          swatch: ModulePalettes.oppression,
        ),
      'Sacerdócio' => _theme(
          narrative: 'Arão e os sacerdotes — servir na presença do Senhor.',
          verse: 'Levítico 8–10',
          swatch: ModulePalettes.liberation,
        ),
      'Santidade' => _theme(
          narrative: 'Sede santos — o povo separado para Deus.',
          verse: 'Levítico 11–27',
          swatch: ModulePalettes.abraham,
        ),
      'Partida' => _theme(
          narrative: 'Censo, nuvem e trombetas — Israel deixa o Sinai.',
          verse: 'Números 1–10',
          swatch: ModulePalettes.creation,
        ),
      'Murmurações' => _theme(
          narrative: 'Espias, serpente e quarenta anos — fé posta à prova.',
          verse: 'Números 11–21',
          swatch: ModulePalettes.afterEden,
        ),
      'Às portas' => _theme(
          narrative: 'Balaão e nova geração — às portas da terra.',
          verse: 'Números 22–36',
          swatch: ModulePalettes.garden,
        ),
      'Lembrar' => _theme(
          narrative: 'Moisés relembra a jornada — ouvi, Israel.',
          verse: 'Deuteronômio 1–11',
          swatch: ModulePalettes.abraham,
        ),
      'Aliança' => _theme(
          narrative:
              trailSlug == 'josue'
                  ? 'Reparto e escolha — a quem servireis hoje?'
                  : 'Bênçãos, maldições e a escolha da vida.',
          verse: trailSlug == 'josue' ? 'Josué 13–24' : 'Deuteronômio 12–30',
          swatch: ModulePalettes.isaacJacob,
        ),
      'Despedida' => _theme(
          narrative: 'Josué designado — cântico e bênção de Moisés.',
          verse: 'Deuteronômio 31–34',
          swatch: ModulePalettes.joseph,
        ),
      'Entrada' => _theme(
          narrative: 'Sê forte — Raabe, o Jordão e a terra prometida.',
          verse: 'Josué 1–5',
          swatch: ModulePalettes.liberation,
        ),
      'Conquista' => _theme(
          narrative: 'Jericó, Ai e a conquista — o Senhor pelea por vós.',
          verse: 'Josué 6–12',
          swatch: ModulePalettes.oppression,
        ),
      'O ciclo' => _theme(
          narrative: 'Cada um fazia o que era reto — e Deus levanta juízes.',
          verse: 'Juízes 1–3',
          swatch: ModulePalettes.afterEden,
        ),
      'Juízes' => _theme(
          narrative: 'Débora, Gideão e Sansão — libertadores imperfeitos.',
          verse: 'Juízes 4–16',
          swatch: ModulePalettes.joseph,
        ),
      'Lealdade' => _theme(
          narrative: 'Rute e Noemi — fidelidade no campo de Boaz.',
          verse: 'Rute 1–2',
          swatch: ModulePalettes.garden,
        ),
      'Redenção' => _theme(
          narrative: 'O resgatador — linhagem até Davi.',
          verse: 'Rute 3–4',
          swatch: ModulePalettes.abraham,
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
      'Jerusalém' => _theme(
          narrative: 'Pentecostes e a igreja em Jerusalém — o Espírito age.',
          verse: 'Atos 1–7',
          swatch: ModulePalettes.church,
        ),
      'Até os confins' => _theme(
          narrative: 'Paulo e as missões — o evangelho até os confins.',
          verse: 'Atos 8–28',
          swatch: ModulePalettes.teaching,
        ),
      'Esperança final' => _theme(
          narrative: 'Cartas, Cordeiro e nova criação — a esperança dos fieis.',
          verse: 'Apocalipse 1–21',
          swatch: ModulePalettes.hope,
        ),
      'Cartas e trono' => _theme(
          narrative: 'Cartas às igrejas e o trono no céu.',
          verse: 'Apocalipse 1–5',
          swatch: ModulePalettes.hope,
        ),
      'Juízo e esperança' => _theme(
          narrative: 'Juízo, Cordeiro e nova criação — a esperança final.',
          verse: 'Apocalipse 6–22',
          swatch: ModulePalettes.cross,
        ),
      _ => _theme(
          narrative: title.trim().isEmpty
              ? 'Sua jornada pela Palavra.'
              : '$title — avance nos passos desta cena.',
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
      case 'mateus':
      case 'marcos':
      case 'lucas':
      case 'joao':
      case 'cartas-paulo':
      case 'romanos':
      case 'corintios':
      case 'galatas':
      case 'efesios':
      case 'filipenses':
      case 'colossenses':
      case 'tessalonicenses':
      case 'timoteo':
      case 'tito':
      case 'filemom':
      case 'cartas-gerais':
      case 'hebreus':
      case 'tiago':
      case 'pedro':
      case 'cartas-joao':
      case 'judas':
      case 'sermao-do-monte':
        return TrailRealm.novoTestamento;
      case 'genesis-1-11':
      case 'genesis-12-50':
      case 'exodo':
      case 'levitico':
      case 'numeros':
      case 'deuteronomio':
      case 'josue':
      case 'juizes':
      case 'rute':
        return TrailRealm.antigoTestamento;
    }
    switch (title) {
      case 'O Início':
      case 'Ensino e Sinais':
      case 'Cruz e Ressurreição':
      case 'A Igreja nasce':
      case 'Esperança final':
      case 'Jerusalém':
      case 'Até os confins':
      case 'Cartas e trono':
      case 'Juízo e esperança':
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
