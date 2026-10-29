import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/data/mission_study.dart';
import 'package:trilha_app/widgets/scene_study_panel.dart';

MissionStudy _study({
  String gloss = '',
  String question = '',
  List<RelatedVerse> links = const [],
}) => MissionStudy(
  passageRef: 'Gênesis 1:1',
  passageText: '',
  context: '',
  keyword: 'Criador',
  keywordGloss: gloss,
  focusQuestion: question,
  reflectionPrompts: const [],
  relatedVerses: links,
);

void main() {
  test('cena sem palavra-chave, pergunta ou ligação não mostra o bloco', () {
    expect(SceneStudy.hasContent(_study()), isFalse);
  });

  test('pergunta de molde não conta como conteúdo', () {
    expect(
      SceneStudy.hasContent(
        _study(question: 'O que este passo ensina sobre altar?'),
      ),
      isFalse,
    );
    expect(
      SceneStudy.hasContent(
        _study(question: 'Por que o Cordeiro morto é o mais digno?'),
      ),
      isTrue,
    );
  });

  test('palavra-chave ou ligação bastam', () {
    expect(SceneStudy.hasContent(_study(gloss: 'Quem cria')), isTrue);
    expect(
      SceneStudy.hasContent(
        _study(
          links: const [RelatedVerse(reference: 'João 1:3', reason: '')],
        ),
      ),
      isTrue,
    );
  });
}
