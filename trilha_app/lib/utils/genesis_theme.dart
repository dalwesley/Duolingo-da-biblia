import 'package:flutter/material.dart';

/// Temas visuais por módulo de Gênesis 1–11.
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
  });

  static GenesisModuleTheme forModule(String title) {
    return switch (title) {
      'A Criação' => const GenesisModuleTheme(
          narrative: 'Do vazio à luz — os seis dias em que tudo começou.',
          verse: 'Gênesis 1:1–2:3',
          sky: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050A18), Color(0xFF0B1D3A), Color(0xFF1A3F6E), Color(0xFF3D6A9A), Color(0xFFC9A066)],
            stops: [0.0, 0.22, 0.48, 0.72, 1.0],
          ),
          pathActive: Color(0xFFE8B84B),
          pathActiveShadow: Color(0xFFB8892A),
          pathInactive: Color(0xFFC8D8E8),
          pathInactiveShadow: Color(0xFF9AABB8),
          nodeCurrentTop: Color(0xFF5BA3E8),
          nodeCurrentBottom: Color(0xFF163A6B),
          decorColor: Color(0xFFFFE082),
        ),
      'O Jardim' => const GenesisModuleTheme(
          narrative: 'O Éden — perfeição, tentação e a queda.',
          verse: 'Gênesis 2:4–3:24',
          sky: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1F16), Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C), Color(0xFF95D5B2)],
            stops: [0.0, 0.2, 0.45, 0.72, 1.0],
          ),
          pathActive: Color(0xFFD4A843),
          pathActiveShadow: Color(0xFF9A7B2E),
          pathInactive: Color(0xFFA8C5B0),
          pathInactiveShadow: Color(0xFF7A9A82),
          nodeCurrentTop: Color(0xFF74C69D),
          nodeCurrentBottom: Color(0xFF1B4332),
          decorColor: Color(0xFF95D5B2),
        ),
      'Opressão no Egito' => const GenesisModuleTheme(
          narrative: 'Escravidão, clamor e o Deus que ouve.',
          verse: 'Êxodo 1–2',
          sky: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1035), Color(0xFF3D2B4F), Color(0xFF6B5B7A)],
            stops: [0.0, 0.5, 1.0],
          ),
          pathActive: Color(0xFFE8B84B),
          pathActiveShadow: Color(0xFFB8892A),
          pathInactive: Color(0xFFC8D8E8),
          pathInactiveShadow: Color(0xFF9AABB8),
          nodeCurrentTop: Color(0xFF74B9FF),
          nodeCurrentBottom: Color(0xFF0984E3),
          decorColor: Color(0xFF74B9FF),
        ),
      'A Libertação' => const GenesisModuleTheme(
          narrative: 'Pragas, Páscoa e o Mar Vermelho — Deus liberta Seu povo.',
          verse: 'Êxodo 7–14',
          sky: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1D3A), Color(0xFF1E4A7A), Color(0xFF74B9FF)],
            stops: [0.0, 0.45, 1.0],
          ),
          pathActive: Color(0xFFE8B84B),
          pathActiveShadow: Color(0xFFB8892A),
          pathInactive: Color(0xFFB0C4DE),
          pathInactiveShadow: Color(0xFF7A9AB8),
          nodeCurrentTop: Color(0xFF0984E3),
          nodeCurrentBottom: Color(0xFF0B1D3A),
          decorColor: Color(0xFF74B9FF),
        ),
      'Depois do Éden' => const GenesisModuleTheme(
          narrative: 'Caim, o dilúvio, Babel — e a promessa de Abraão.',
          verse: 'Gênesis 4–11',
          sky: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C1810), Color(0xFF5C4033), Color(0xFF8B7355), Color(0xFFD4C4A8)],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
          pathActive: Color(0xFFE8B84B),
          pathActiveShadow: Color(0xFF8B6914),
          pathInactive: Color(0xFFC4B5A0),
          pathInactiveShadow: Color(0xFF8A7B68),
          nodeCurrentTop: Color(0xFF8B7355),
          nodeCurrentBottom: Color(0xFF3D2B1F),
          decorColor: Color(0xFFD4A574),
        ),
      _ => const GenesisModuleTheme(
          narrative: 'Sua jornada pela Palavra.',
          verse: 'Gênesis',
          sky: LinearGradient(
            colors: [Color(0xFF1A1530), Color(0xFF2A2248)],
          ),
          pathActive: Color(0xFFE8B84B),
          pathActiveShadow: Color(0xFFB8892A),
          pathInactive: Color(0xFFE5E5E5),
          pathInactiveShadow: Color(0xFF9E9E9E),
          nodeCurrentTop: Color(0xFF8B7CF6),
          nodeCurrentBottom: Color(0xFF5B4FCF),
          decorColor: Color(0xFFE8B84B),
        ),
    };
  }
}

class GenesisTrailTheme {
  static const headerVerse = 'No princípio, Deus criou os céus e a terra.';
  static const headerRef = 'Gênesis 1:1';

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1035), Color(0xFF2D1B69), Color(0xFF4A3F8C)],
  );
}
