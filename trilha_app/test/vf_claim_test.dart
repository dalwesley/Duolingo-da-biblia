import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/exercise.dart';
import 'package:trilha_app/utils/vf_claim.dart';

void main() {
  test('por que + para → afirmação direta', () {
    expect(
      vfClaim('Por que Abrão desce ao Egito: Para guerrear.'),
      'Abrão desce ao Egito para guerrear.',
    );
    expect(
      vfClaimFromParts('Por que Abrão desce ao Egito?', 'Por causa da fome'),
      'Abrão desce ao Egito por causa da fome.',
    );
  });

  test('qual + ser inverte tópico e recorte', () {
    expect(
      vfClaim('Qual foi a primeira ordem criadora registrada: Haja firmamento.'),
      'A primeira ordem criadora registrada foi “Haja firmamento”.',
    );
    expect(
      vfClaim('Quais eram os três filhos de Noé: Caim, Abel e Sete.'),
      'Os três filhos de Noé eram Caim, Abel e Sete.',
    );
  });

  test('quem coloca a resposta como sujeito', () {
    expect(
      vfClaim('Quem deu nome aos animais: O homem.'),
      'O homem deu nome aos animais.',
    );
  });

  test('quem com nome na pergunta coloca o recorte como objeto', () {
    expect(
      vfClaim('Quem Abrão resgata: Sarai.'),
      'Abrão resgata Sarai.',
    );
    expect(
      vfClaimFromParts('Quem Abrão resgata?', 'Ló'),
      'Abrão resgata Ló.',
    );
  });

  test('quem é Nome + descrição mantém o nome como sujeito', () {
    expect(
      vfClaim('Quem é Melquisedeque: Rei de Salém e sacerdote.'),
      'Melquisedeque é rei de Salém e sacerdote.',
    );
  });

  test('o que anexa o recorte ao restante', () {
    expect(
      vfClaim('O que Deus criou no princípio: Os céus e a terra.'),
      'Deus criou no princípio os céus e a terra.',
    );
  });

  test('o que + verbo sem sujeito usa o recorte como sujeito', () {
    expect(
      vfClaim(
        'O que passa entre os pedaços na aliança: Um forno fumegante e uma tocha.',
      ),
      'Um forno fumegante e uma tocha passam entre os pedaços na aliança.',
    );
  });

  test('em qual e como se chama viram afirmação direta', () {
    expect(
      vfClaim('Em qual dia Deus fez o firmamento: No segundo dia.'),
      'Deus fez o firmamento no segundo dia.',
    );
    expect(
      vfClaimFromParts('Como se chama o filho de Agar?', 'Ismael'),
      'O filho de Agar se chama Ismael.',
    );
  });

  test('qual o X vira O X é resposta', () {
    expect(
      vfClaimFromParts('Qual o novo nome de Abrão?', 'Abraão'),
      'O novo nome de Abrão é Abraão.',
    );
  });

  test('o que ocorre logo após mantém a circunstância', () {
    expect(
      vfClaim(
        'O que ocorre logo após a terra seca aparecer: O homem nomeia os animais.',
      ),
      'Logo após a terra seca aparecer, o homem nomeia os animais.',
    );
  });

  test('já-afirmação permanece; aspas internas não separam', () {
    expect(
      vfClaim('Abrão desce ao Egito por causa da fome.'),
      'Abrão desce ao Egito por causa da fome.',
    );
    expect(
      vfClaim('Por que estudar “Desafio: O altar”.'),
      'Por que estudar “Desafio: O altar”.',
    );
  });

  test('V/F mostra Julgue e o enunciado afirmativo', () {
    const ex = Exercise(
      id: 'vf',
      type: ExerciseType.trueFalse,
      prompt: 'Por que Abrão desce ao Egito: Para guerrear.',
      correctAnswer: 'false',
    );
    expect(ex.instructionVerb, 'Julgue');
    expect(ex.displayCue, 'Abrão desce ao Egito para guerrear.');
  });

  test('vfIsAskStem distingue pergunta de afirmação completa', () {
    expect(vfIsAskStem('O que Deus criou no princípio?'), isTrue);
    expect(
      vfIsAskStem('O que Deus criou no princípio: Somente os mares.'),
      isTrue,
    );
    expect(
      vfIsAskStem(
        'Ageu 2:4 registra que Jeová pede esforço ao povo, mas nega qualquer promessa de estar com eles.',
      ),
      isFalse,
    );
    expect(
      vfIsAskStem(
        'Em Gênesis 1:1–2, a terra já aparece ordenada e cheia antes de qualquer ato de Deus.',
      ),
      isFalse,
    );
  });
}
