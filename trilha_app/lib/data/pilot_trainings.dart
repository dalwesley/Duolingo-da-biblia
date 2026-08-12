import '../models/trail.dart';

/// Piloto Imagem de Deus — apresentação texto-tarefa ([docs/SESSAO_TREINO.md]).
class PilotTrainings {
  PilotTrainings._();

  static const insightText =
      'A dignidade humana não é conquista: é presente — homem e mulher, sob Deus, com responsabilidade.';

  /// Entrada bíblica do piloto (verso + contexto + conexão).
  static const hookRef = 'Gênesis 1:27';
  static const hookVerse =
      'À imagem de Deus o criou; homem e mulher os criou.';
  static const hookNote =
      'No antigo Oriente, “imagem do deus” era título de reis. Gênesis dá isso a homem e mulher — toda a humanidade.';
  static const hookThread =
      'A mesma palavra reaparece no Novo Testamento falando de Cristo.';

  static List<Exercise> forSlug(String slug) {
    switch (slug) {
      case 'gen-03-imagem':
        return List.unmodifiable(_imagemDeDeus);
      default:
        return const [];
    }
  }

  /// Micro-review (outro gesto) se errou algo na sessão.
  static Exercise? reviewForSlug(String slug) {
    switch (slug) {
      case 'gen-03-imagem':
        return _imagemReview;
      default:
        return null;
    }
  }

  static const _passageImagem =
      'Também disse Deus: Façamos o homem à nossa imagem, conforme a nossa semelhança; e domine sobre os peixes do mar, sobre as aves dos céus e sobre todo animal que rasteja sobre a terra. À imagem de Deus o criou; homem e mulher os criou.';

  static const _imagemDeDeus = <Exercise>[
    Exercise(
      id: 'gen-03-imagem-e01',
      type: ExerciseType.trueFalse,
      skill: 'observe',
      beat: 'Hipótese',
      prompt: 'Tudo que tem fôlego foi feito à imagem de Deus.',
      instruction: 'Antes de abrir o versículo: esta frase é verdadeira ou falsa?',
      noteLabel: 'Por quê isso importa',
      note:
          'Muita gente estende “imagem de Deus” a todo ser vivo. Gênesis 1 pode ser mais preciso — teste a afirmação.',
      correctAnswer: 'false',
      feedbackCorrect: 'Certo. O texto é mais preciso — vamos ver o versículo.',
      feedbackWrong: {
        'true': 'Quase. Gênesis 1 é específico. Veja o próximo ato.',
      },
    ),
    Exercise(
      id: 'gen-03-imagem-e02',
      type: ExerciseType.tap,
      skill: 'observe',
      beat: 'Toque',
      reference: 'Gênesis 1:26–27',
      passageText: _passageImagem,
      instruction:
          'Leia o trecho. Depois toque, no próprio texto, quem recebe a imagem de Deus.',
      cue: 'Quem recebe a imagem de Deus?',
      prompt: 'Quem recebe a imagem de Deus?',
      noteLabel: 'Contexto histórico',
      note:
          'No antigo Oriente Próximo, a “imagem” do deus era o rei — o representante divino na terra. Gênesis usa a mesma linguagem, mas aponta para outro sujeito. Procure no versículo quem é.',
      options: [
        QuestionOption(id: 'a', text: 'homem e mulher'),
        QuestionOption(id: 'b', text: 'todo animal'),
        QuestionOption(id: 'c', text: 'peixes do mar'),
        QuestionOption(id: 'd', text: 'aves dos céus'),
      ],
      correctAnswer: 'a',
      feedbackCorrect:
          'Isso — homem e mulher. Animais aparecem no mandato de cuidado, não como portadores da imagem.',
      feedbackWrong: {
        'b': 'O texto fala de animal no mandato — não como imagem.',
        'c': 'Peixes estão sob o domínio; não recebem a imagem.',
        'd': 'Aves estão no mandato; a imagem é outra coisa.',
      },
    ),
    Exercise(
      id: 'gen-03-imagem-e03',
      type: ExerciseType.choice,
      skill: 'observe',
      beat: 'Escolha',
      reference: 'Gênesis 1:26',
      passageText:
          'Façamos o homem à nossa imagem, conforme a nossa semelhança; e domine sobre os peixes do mar, sobre as aves dos céus, sobre os animais domésticos, sobre toda a terra e sobre todo réptil que rasteja sobre a terra.',
      instruction: 'Leia 1:26 e escolha o que vem junto com a imagem.',
      cue: 'Além da imagem, o que o texto liga ao humano?',
      prompt: 'Além da imagem, o que o texto liga ao humano?',
      noteLabel: 'Como ler',
      note:
          'Em 1:26 a imagem não vem sozinha. Há um verbo de responsabilidade logo em seguida — observe o que Deus une à identidade humana.',
      options: [
        QuestionOption(id: 'a', text: 'Cuidar / dominar a criação'),
        QuestionOption(id: 'b', text: 'Construir um templo'),
        QuestionOption(id: 'c', text: 'Dominar outros povos'),
        QuestionOption(id: 'd', text: 'Descansar no 7º dia'),
      ],
      correctAnswer: 'a',
      feedbackCorrect:
          'Imagem e mandato vêm juntos: representar Deus cuidando da criação.',
      feedbackWrong: {
        'b': 'Não está em 1:26.',
        'c': 'O mandato é sobre a criação, não nações.',
        'd': 'Isso é outro trecho (2:1–3).',
      },
    ),
    Exercise(
      id: 'gen-03-imagem-e04',
      type: ExerciseType.order,
      skill: 'understand',
      beat: 'Ordene',
      instruction: 'Arraste as peças na ordem em que Gênesis 1 apresenta o humano.',
      cue: 'Qual a sequência do capítulo?',
      prompt: 'Qual a sequência do capítulo?',
      noteLabel: 'Estrutura',
      note:
          'O capítulo não solta a “imagem” no vazio. Há um movimento: Deus cria, confere identidade e encarrega.',
      options: [
        QuestionOption(id: 'a', text: 'Cria o humano'),
        QuestionOption(id: 'b', text: 'Dá a imagem'),
        QuestionOption(id: 'c', text: 'Chama a cuidar'),
      ],
      correctAnswer: 'a,b,c',
      correctOrder: ['a', 'b', 'c'],
      feedbackCorrect: 'Criado → imagem → cuidado. Identidade e missão andam juntas.',
      feedbackWrong: {
        'default': 'Pense na ordem do capítulo: criar, nomear a imagem, mandar.',
      },
    ),
    Exercise(
      id: 'gen-03-imagem-e05',
      type: ExerciseType.choice,
      skill: 'interpret',
      beat: 'Freio',
      instruction: 'Separe o que Gênesis 1 afirma do que tradições acrescentam.',
      cue: 'O que Gênesis 1 não afirma?',
      prompt: 'O que Gênesis 1 não afirma?',
      noteLabel: 'Atenção',
      note:
          'Tradições cristãs às vezes definem “imagem” como razão, emoção e vontade. Isso pode ser útil depois — mas o texto de Gênesis 1 não lista essas faculdades.',
      options: [
        QuestionOption(id: 'a', text: 'Humanos à imagem de Deus'),
        QuestionOption(id: 'b', text: 'Homem e mulher criados'),
        QuestionOption(id: 'c', text: 'Imagem = razão + emoção + vontade'),
        QuestionOption(id: 'd', text: 'Há chamado ligado à criação'),
      ],
      correctAnswer: 'c',
      feedbackCorrect:
          'Essa tríade não está em Gênesis 1. O texto afirma imagem, homem e mulher, e o mandato.',
      feedbackWrong: {
        'a': 'Isso o texto diz.',
        'b': 'Isso o texto diz.',
        'd': 'O mandato está no texto.',
      },
    ),
    Exercise(
      id: 'gen-03-imagem-e06',
      type: ExerciseType.tap,
      skill: 'connect',
      beat: 'Conecte',
      instruction:
          'Compare os dois textos. Toque a palavra que aparece nos dois e faz a ponte.',
      cue: 'Qual palavra une Gênesis e Colossenses?',
      prompt: 'Qual palavra une Gênesis e Colossenses?',
      noteLabel: 'Conexão bíblica',
      note:
          'Séculos depois, uma carta cristã fala de alguém como “imagem” do Deus invisível. Leia as duas falas lado a lado e ache a ponte.',
      passageA: ExercisePassage(
        ref: 'Gênesis 1:27',
        text: 'À imagem de Deus o criou; homem e mulher os criou.',
      ),
      passageB: ExercisePassage(
        ref: 'Colossenses 1:15',
        text: 'Este é a imagem do Deus invisível, o primogênito de toda a criação.',
      ),
      options: [
        QuestionOption(id: 'a', text: 'criação'),
        QuestionOption(id: 'b', text: 'imagem'),
        QuestionOption(id: 'c', text: 'mulher'),
        QuestionOption(id: 'd', text: 'invisível'),
      ],
      correctAnswer: 'b',
      feedbackCorrect:
          '“Imagem” une Gn e Cl — em Colossenses, a palavra aponta para Cristo.',
      feedbackWrong: {
        'a': 'Aparece em Colossenses, mas não é a ponte principal com Gn 1:27.',
        'c': 'Só em Gênesis.',
        'd': 'Só em Colossenses.',
      },
    ),
    Exercise(
      id: 'gen-03-imagem-e07',
      type: ExerciseType.complete,
      skill: 'observe',
      beat: 'Complete',
      reference: 'Gênesis 1:27',
      template: 'À imagem de Deus o criou; ___ e ___ os criou.',
      prompt: '',
      instruction: 'Complete o versículo com o que Gênesis 1:27 diz.',
      noteLabel: 'Recupere',
      note:
          'Feche o círculo: o texto nomeia explicitamente quem foi criado à imagem.',
      options: [
        QuestionOption(id: 'a', text: 'homem e mulher'),
        QuestionOption(id: 'b', text: 'céu e terra'),
        QuestionOption(id: 'c', text: 'dia e noite'),
        QuestionOption(id: 'd', text: 'bem e mal'),
      ],
      correctAnswer: 'a',
      feedbackCorrect: 'Homem e mulher — juntos, à imagem de Deus.',
      feedbackWrong: {
        'default': 'Relê Gênesis 1:27 até o fim do versículo.',
      },
    ),
    Exercise(
      id: 'gen-03-imagem-insight',
      type: ExerciseType.insight,
      skill: 'apply',
      beat: 'Insight',
      prompt: insightText,
      correctAnswer: 'insight',
      feedbackCorrect: '',
    ),
  ];

  static const _imagemReview = Exercise(
    id: 'gen-03-imagem-review',
    type: ExerciseType.tap,
    skill: 'observe',
    beat: 'Revisão',
    reference: 'Gênesis 1:27',
    passageText: 'À imagem de Deus o criou; homem e mulher os criou.',
    instruction: 'Toque no versículo.',
    cue: 'Quem foi criado à imagem?',
    prompt: 'Quem foi criado à imagem?',
    options: [
      QuestionOption(id: 'a', text: 'homem e mulher'),
      QuestionOption(id: 'b', text: 'imagem de Deus'),
      QuestionOption(id: 'c', text: 'Deus'),
    ],
    correctAnswer: 'a',
    feedbackCorrect: 'Isso — homem e mulher.',
    feedbackWrong: {
      'b': 'Imagem é o que recebem — não quem.',
      'c': 'Deus cria. Quem recebe a imagem está no versículo.',
      'default': 'Toque quem o texto nomeia.',
    },
  );
}
