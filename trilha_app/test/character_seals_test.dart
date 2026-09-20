import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/data/entry_trails.dart';
import 'package:trilha_app/theme/app_theme.dart';
import 'package:trilha_app/widgets/character_seals_strip.dart';

void main() {
  testWidgets('gallery never uses a question mark on locked seals', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: CharacterSealsStrip(completed: []),
          ),
        ),
      ),
    );
    expect(find.text('Selos'), findsOneWidget);
    expect(find.text('?'), findsNothing);
    expect(find.text('Imagem'), findsNothing);
  });

  testWidgets('unlocked seal shows the name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: CharacterSealsStrip(
              completed: ['gen-03-imagem'],
            ),
          ),
        ),
      ),
    );
    expect(find.text('Imagem'), findsOneWidget);
    expect(find.text('Guardar'), findsNothing);
  });

  testWidgets('unlocked seals sit first, even if later in the canon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: CharacterSealsStrip(
              completed: ['gen12-01-chamado'],
            ),
          ),
        ),
      ),
    );
    expect(find.text('Abrão'), findsOneWidget);
    expect(find.text('Imagem'), findsNothing);
    expect(find.textContaining('ainda no texto: Imagem'), findsOneWidget);
  });

  testWidgets('sheet shares the encounter instead of Guardar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () => showCharacterSealSheet(
                  context,
                  CharacterSeals.all.first,
                ),
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('COMPARTILHAR'), findsOneWidget);
    expect(find.text('Guardar'), findsNothing);
    expect(find.textContaining('Criou Deus o homem'), findsWidgets);
  });
}
