"""Panoramas de Mateus, Marcos, Lucas e João para as trilhas."""


def S(q_s, q_c, q_p, answer, wrong, verse):
    return {
        "q_s": q_s, "q_c": q_c, "q_p": q_p, "answer": answer,
        "wrong": wrong, "verse": verse,
    }


def T(ref, text, context, keyword, gloss, question, prompts):
    return {
        "passageRef": ref, "passageText": text, "context": context,
        "keyword": keyword, "keywordGloss": gloss,
        "focusQuestion": question, "reflectionPrompts": prompts,
    }


def M(slug, title, subtitle, intro, study, seeds, boss=False):
    if len(seeds) != 5:
        raise ValueError(f"{slug} deve ter exatamente cinco sementes")
    if boss and study is not None:
        raise ValueError(f"{slug} é boss e deve ter study=None")
    if not boss and study is None:
        raise ValueError(f"{slug} não é boss e precisa de estudo")
    return {
        "slug": slug, "title": title, "subtitle": subtitle, "intro": intro,
        "boss": boss, "study": study, "seeds": seeds,
    }


def seeds(ref, facts):
    """Cria cinco perguntas a partir de fatos centrais do panorama."""
    return [
        S(question, "O que este texto revela sobre Jesus?",
          "Como essa verdade orienta sua fé?", answer, wrong, verse)
        for question, answer, wrong, verse in facts
    ]


EVANGELHOS_BOOKS = {
    "mateus": {
        "module": {"title": "Mateus", "icon": "crown", "section": "Evangelhos"},
        "missions": [
            M("mt-01-rei-prometido", "O Rei prometido", "Nascimento e identidade de Jesus",
              "Mateus apresenta Jesus como o Messias prometido, Filho de Davi e Rei que veio cumprir as Escrituras.",
              T("Mateus 1:21-23", "Ela dará à luz um filho e lhe porás o nome de Jesus, porque ele salvará o seu povo dos pecados deles.",
                "A genealogia liga Jesus a Abraão e Davi. Seu nascimento pelo Espírito Santo cumpre a promessa de Emanuel: Deus conosco.",
                "Emanuel", "Nome que significa Deus conosco.", "Por que o nascimento de Jesus é boa notícia para pecadores?",
                ["De que você precisa ser salvo?", "Como Deus se aproximou de nós em Cristo?", "Como honrar Jesus como Rei?"]),
              seeds("Mateus 1-2", [
                  ("Qual era a missão de Jesus anunciada pelo anjo?", "Salvar seu povo dos pecados", ["Dar riqueza a todos", "Fundar um império político", "Apenas ensinar moral"], "Mateus 1:21"),
                  ("Que título mostra que Deus veio habitar com seu povo?", "Emanuel", ["Raboni", "César", "Elias"], "Mateus 1:23"),
                  ("De qual rei Jesus é chamado filho?", "Davi", ["Saul", "Herodes", "Faraó"], "Mateus 1:1"),
                  ("Quem adorou o menino Jesus reconhecendo sua realeza?", "Os magos do Oriente", ["Os soldados de Herodes", "Os fariseus", "Pilatos"], "Mateus 2:1-2"),
                  ("Como Mateus descreve a chegada de Jesus?", "Cumprimento das promessas de Deus", ["Acidente da história", "Lenda sem testemunhas", "Vitória de Roma"], "Mateus 1:22"),
              ])),
            M("mt-02-reino-ensino", "O Reino e seu ensino", "O Sermão do Monte",
              "Jesus ensina a vida do Reino: os discípulos dependem do Pai, praticam justiça e ouvem suas palavras.",
              T("Mateus 5:3", "Bem-aventurados os humildes de espírito, porque deles é o reino dos céus.",
                "No Sermão do Monte, Jesus não oferece um caminho para merecer Deus; ele descreve a vida daqueles que pertencem ao Reino e dependem dele.",
                "bem-aventurados", "Pessoas verdadeiramente felizes por receberem o favor de Deus.", "Como a dependência de Deus muda sua maneira de viver?",
                ["Onde você precisa reconhecer sua necessidade?", "Como buscar primeiro o Reino?", "Que ensino de Jesus você praticará?"]),
              seeds("Mateus 5-7", [
                  ("Quem recebe o Reino dos céus em Mateus 5:3?", "Os humildes de espírito", ["Os autossuficientes", "Os mais ricos", "Os mais famosos"], "Mateus 5:3"),
                  ("Como Jesus chama seus discípulos no mundo?", "Sal da terra e luz do mundo", ["Juízes de todos", "Donos da verdade", "Pessoas escondidas"], "Mateus 5:13-14"),
                  ("O que Jesus manda buscar primeiro?", "O Reino de Deus e sua justiça", ["A aprovação humana", "Bens materiais", "Vingança"], "Mateus 6:33"),
                  ("Como devemos orar segundo Jesus?", "Ao Pai, com confiança e reverência", ["Para sermos vistos", "Com muitas repetições vazias", "A ídolos"], "Mateus 6:9"),
                  ("Quem é sábio ao final do Sermão do Monte?", "Quem ouve e pratica as palavras de Jesus", ["Quem apenas admira Jesus", "Quem conhece muitas regras", "Quem evita a igreja"], "Mateus 7:24"),
              ])),
            M("mt-03-autoridade", "Autoridade do Rei", "Milagres e chamado",
              "Jesus demonstra autoridade sobre doenças, demônios, natureza e pecado, chamando pessoas a segui-lo com fé.",
              T("Mateus 8:26-27", "Quem é este que até os ventos e o mar lhe obedecem?",
                "Os milagres em Mateus não são truques: revelam a autoridade do Messias e apontam para sua compaixão e seu Reino.",
                "autoridade", "Poder legítimo de Jesus para agir e governar.", "O que os milagres revelam sobre quem Jesus é?",
                ["Que medo você precisa levar a Cristo?", "Como sua autoridade gera confiança?", "Quem você pode convidar a segui-lo?"]),
              seeds("Mateus 8-10", [
                  ("A que a natureza obedece quando Jesus fala?", "Aos ventos e ao mar", ["Aos discípulos", "A Roma", "A Herodes"], "Mateus 8:26-27"),
                  ("Que autoridade Jesus deu aos discípulos?", "Sobre espíritos imundos e enfermidades", ["Para cobrar impostos", "Para dominar povos", "Para criar novas Escrituras"], "Mateus 10:1"),
                  ("Como Jesus respondeu às multidões aflitas?", "Com compaixão", ["Com desprezo", "Com indiferença", "Com medo"], "Mateus 9:36"),
                  ("O que Jesus disse sobre a seara?", "É grande, mas os trabalhadores são poucos", ["Já está vazia", "Não precisa de oração", "Pertence aos fariseus"], "Mateus 9:37-38"),
                  ("Quem Jesus chama para segui-lo?", "Pecadores que precisam de misericórdia", ["Somente os perfeitos", "Apenas os ricos", "Somente líderes religiosos"], "Mateus 9:12-13"),
              ])),
            M("mt-04-cruz-vitoria", "A cruz e a vitória", "Paixão e ressurreição",
              "O Rei serve, entrega sua vida pelos pecadores, ressuscita corporalmente e envia discípulos a todas as nações.",
              T("Mateus 28:5-6", "Não temais; porque sei que buscais Jesus, que foi crucificado. Ele não está aqui; ressuscitou.",
                "A morte de Jesus é voluntária e sacrificial. Sua ressurreição confirma sua vitória e fundamenta a missão da igreja.",
                "ressuscitou", "Jesus venceu a morte e vive corporalmente.", "Como a ressurreição de Jesus sustenta a esperança e a missão da igreja?",
                ["Por que a cruz importa?", "Que esperança a ressurreição traz?", "Como fazer discípulos onde você está?"]),
              seeds("Mateus 26-28", [
                  ("Por que Jesus deu sua vida, segundo Mateus 20?", "Como resgate por muitos", ["Para evitar o sofrimento", "Para conquistar Roma", "Para ser admirado"], "Mateus 20:28"),
                  ("O que Jesus instituiu na ceia?", "A nova aliança em seu sangue", ["Uma festa política", "Uma lei sem graça", "Um sacrifício repetido"], "Mateus 26:28"),
                  ("O que o anjo anunciou às mulheres?", "Jesus ressuscitou", ["Jesus foi escondido", "Jesus ainda estava morto", "Jesus deixou de existir"], "Mateus 28:5-6"),
                  ("Que autoridade Jesus declara possuir?", "Toda autoridade no céu e na terra", ["Somente autoridade em Israel", "Autoridade emprestada de Roma", "Nenhuma autoridade"], "Mateus 28:18"),
                  ("Qual missão Jesus dá aos seus discípulos?", "Fazer discípulos de todas as nações", ["Construir palácios", "Evitar os povos", "Buscar fama"], "Mateus 28:19-20"),
              ])),
            M("mt-boss-revisao", "Desafio: O Rei e seu Reino", "Revisão de Mateus",
              "Revise Jesus, o Rei prometido, seu ensino, sua autoridade, sua morte e ressurreição.",
              None,
              seeds("Mateus 1-28", [
                  ("Quem é Jesus no início de Mateus?", "O Messias, Filho de Davi", ["Um rei romano", "Apenas um profeta comum", "Um anjo criado"], "Mateus 1:1"),
                  ("Que tipo de vida Jesus ensina no Sermão do Monte?", "Uma vida dependente do Pai e obediente", ["Uma vida de orgulho", "Uma vida sem misericórdia", "Uma vida sem oração"], "Mateus 5-7"),
                  ("O que os milagres revelam?", "A autoridade e compaixão de Jesus", ["O poder dos discípulos por si só", "A força de Roma", "A inutilidade da fé"], "Mateus 8-9"),
                  ("Qual é o sentido da morte de Jesus?", "Ele deu sua vida em resgate por muitos", ["Foi apenas um exemplo político", "Foi uma derrota final", "Não teve relação com o pecado"], "Mateus 20:28"),
                  ("O que confirma a vitória de Cristo?", "Sua ressurreição dentre os mortos", ["A aprovação de Pilatos", "A fuga dos discípulos", "O poder do templo"], "Mateus 28:6"),
              ]), True),
        ],
    },
    "marcos": {
        "module": {"title": "Marcos", "icon": "zap", "section": "Evangelhos"},
        "missions": [
            M("mc-01-servo-autoridade", "O Servo com autoridade", "Início, poder e boas-novas",
              "Marcos apresenta Jesus em ação: o Filho de Deus anuncia o Reino e serve com autoridade sobre o mal e a enfermidade.",
              T("Marcos 1:15", "O tempo está cumprido, e o reino de Deus está próximo; arrependei-vos e crede no evangelho.",
                "Desde o começo, Jesus convoca pessoas a abandonar o pecado e confiar nas boas-novas do Reino de Deus.",
                "evangelho", "As boas-novas da obra salvadora de Deus em Jesus.", "Como arrependimento e fé respondem ao anúncio de Jesus?",
                ["Do que você precisa se arrepender?", "Em que você precisa confiar?", "Como anunciar boas-novas a alguém?"]),
              seeds("Marcos 1-5", [
                  ("O que Jesus anuncia como próximo?", "O Reino de Deus", ["O império romano", "Um reino de violência", "O fim da criação"], "Marcos 1:15"),
                  ("Como as pessoas reagiam ao ensino de Jesus?", "Admiravam sua autoridade", ["Diziam que era vazio", "Ignoravam completamente", "Achavam que era de Roma"], "Marcos 1:22"),
                  ("O que Jesus fez ao leproso que lhe pediu ajuda?", "Teve compaixão e o curou", ["Afastou-o sem falar", "Culpou-o", "Pediu dinheiro"], "Marcos 1:41"),
                  ("O que Jesus declarou ao paralítico antes de curá-lo?", "Seus pecados estão perdoados", ["Você não tem esperança", "Vá procurar Roma", "Seu esforço o salvará"], "Marcos 2:5"),
                  ("Quem Jesus acalmou durante a tempestade?", "O vento e o mar", ["Os soldados romanos", "A multidão no templo", "Os fariseus"], "Marcos 4:39"),
              ])),
            M("mc-02-caminho-cruz", "O caminho da cruz", "Discipulado e serviço",
              "Quando Pedro reconhece Jesus como Cristo, Jesus ensina que segui-lo inclui negar a si mesmo, tomar a cruz e servir.",
              T("Marcos 8:34", "Se alguém quer vir após mim, negue-se a si mesmo, tome a sua cruz e siga-me.",
                "Jesus corrige expectativas de glória sem sofrimento. Ele é o Cristo que sofre, e seus discípulos o seguem no caminho do serviço.",
                "discipulado", "Vida de seguir Jesus com fé, obediência e entrega.", "O que significa seguir Jesus acima de sua própria vontade?",
                ["Que desejo precisa ser submetido a Cristo?", "Como servir alguém?", "Por que Jesus é digno de ser seguido?"]),
              seeds("Marcos 8-10", [
                  ("Quem Pedro disse que Jesus é?", "O Cristo", ["Um soldado romano", "João Batista ressuscitado", "Um escriba"], "Marcos 8:29"),
                  ("O que Jesus manda fazer para segui-lo?", "Negar-se, tomar a cruz e segui-lo", ["Buscar poder pessoal", "Evitar todo sacrifício", "Seguir a multidão"], "Marcos 8:34"),
                  ("Quem é o maior no Reino, segundo Jesus?", "Quem serve", ["Quem manda em todos", "Quem tem mais dinheiro", "Quem recebe aplausos"], "Marcos 9:35"),
                  ("Para que o Filho do Homem veio?", "Para servir e dar sua vida em resgate por muitos", ["Para ser servido", "Para tomar o trono de Roma", "Para condenar sem misericórdia"], "Marcos 10:45"),
                  ("O que Bartimeu pediu a Jesus?", "Que tivesse misericórdia dele", ["Uma posição no governo", "Uma coroa", "Uma espada"], "Marcos 10:47"),
              ])),
            M("mc-03-cruz-ressurreicao", "O Servo vence pela cruz", "Paixão, morte e ressurreição",
              "Jesus entra em Jerusalém, entrega-se conforme o plano de Deus, morre e ressuscita, vencendo a morte.",
              T("Marcos 15:39", "Verdadeiramente este homem era o Filho de Deus.",
                "Na cruz, o Servo sofredor revela sua identidade. O túmulo vazio anuncia que a morte não teve a última palavra.",
                "Filho de Deus", "Título que confessa a identidade singular e divina de Jesus.", "Por que a cruz e a ressurreição devem permanecer no centro da fé?",
                ["O que Jesus sofreu por nós?", "O que a ressurreição confirma?", "Como responder à sua graça?"]),
              seeds("Marcos 11-16", [
                  ("O que Jesus fez ao entrar em Jerusalém?", "Entrou como o Rei prometido", ["Fugiu da cidade", "Pediu apoio de Roma", "Negou sua missão"], "Marcos 11:9-10"),
                  ("O que Jesus disse sobre seu sangue na ceia?", "É o sangue da aliança, derramado por muitos", ["Não tem significado", "É apenas símbolo de poder romano", "Compra riqueza"], "Marcos 14:24"),
                  ("O que o centurião confessou ao ver Jesus morrer?", "Verdadeiramente este homem era o Filho de Deus", ["Ele era César", "Ele era apenas um criminoso", "Ele era Elias"], "Marcos 15:39"),
                  ("Que notícia as mulheres receberam no túmulo?", "Jesus ressuscitou; não está ali", ["O corpo foi perdido", "Nada aconteceu", "Jesus nunca morreu"], "Marcos 16:6"),
                  ("Qual mensagem deve ser anunciada?", "O evangelho a toda criatura", ["Somente tradições humanas", "Boas obras sem Cristo", "Poder político"], "Marcos 16:15"),
              ])),
            M("mc-boss-revisao", "Desafio: O Servo poderoso", "Revisão de Marcos",
              "Revise o anúncio do Reino, o discipulado que serve e a vitória de Jesus na cruz.",
              None,
              seeds("Marcos 1-16", [
                  ("Que mensagem Jesus pregou no início?", "Arrependimento e fé no evangelho", ["Orgulho e independência", "Violência contra Roma", "Riqueza como salvação"], "Marcos 1:15"),
                  ("O que os milagres mostram?", "A autoridade de Jesus", ["A superioridade dos discípulos", "A força da multidão", "O poder do dinheiro"], "Marcos 1-5"),
                  ("Qual caminho Jesus ensinou aos discípulos?", "O caminho da cruz e do serviço", ["O caminho da autopromoção", "O caminho da vingança", "O caminho do isolamento"], "Marcos 8:34"),
                  ("Como Jesus define grandeza?", "Servir aos outros", ["Receber honras", "Controlar pessoas", "Ser temido"], "Marcos 10:43-45"),
                  ("Que evento declara a vitória de Jesus sobre a morte?", "A ressurreição", ["A prisão", "O julgamento", "A negação de Pedro"], "Marcos 16:6"),
              ]), True),
        ],
    },
    "lucas": {
        "module": {"title": "Lucas", "icon": "heart", "section": "Evangelhos"},
        "missions": [
            M("lc-01-salvador-humilde", "O Salvador dos humildes", "Nascimento e boas-novas aos pobres",
              "Lucas mostra Jesus chegando em humildade e trazendo boas-novas para pobres, pecadores e pessoas deixadas à margem.",
              T("Lucas 2:10-11", "Eis aqui vos trago boa-nova de grande alegria... é que hoje vos nasceu, na cidade de Davi, o Salvador, que é Cristo, o Senhor.",
                "O nascimento de Jesus é anunciado a pastores. Lucas destaca a alegria da salvação e a graça de Deus que alcança os humildes.",
                "Salvador", "Aquele que resgata seu povo do pecado e da morte.", "Como o nascimento de Jesus revela a graça de Deus?",
                ["Que boa notícia você recebeu?", "Como acolher pessoas esquecidas?", "Como louvar a Deus por seu Salvador?"]),
              seeds("Lucas 1-4", [
                  ("Como o anjo chama Jesus ao anunciar seu nascimento?", "Salvador, Cristo, o Senhor", ["Um rei apenas humano", "Um novo César", "Um anjo criado"], "Lucas 2:11"),
                  ("A quem os anjos anunciaram o nascimento de Jesus?", "A pastores", ["Ao imperador", "Aos líderes de Roma", "Aos sacerdotes somente"], "Lucas 2:8-12"),
                  ("Qual missão Jesus leu em Isaías?", "Anunciar boas-novas aos pobres", ["Servir aos ricos somente", "Conquistar nações pela espada", "Evitar pecadores"], "Lucas 4:18"),
                  ("O que Jesus afirma em Nazaré sobre a Escritura?", "Hoje se cumpriu", ["Ainda não tem sentido", "Foi cancelada", "Pertence apenas ao passado"], "Lucas 4:21"),
                  ("Como Maria responde ao favor de Deus?", "Com louvor e humildade", ["Com orgulho", "Com incredulidade permanente", "Com desprezo"], "Lucas 1:46-49"),
              ])),
            M("lc-02-misericordia", "A misericórdia que busca", "Parábolas e perdão",
              "Lucas destaca a alegria de Deus em buscar pecadores e chama seus filhos a amar o próximo com misericórdia.",
              T("Lucas 19:10", "Porque o Filho do Homem veio buscar e salvar o perdido.",
                "As parábolas da ovelha, da moeda e do filho perdido revelam o coração de Deus. Jesus recebe pecadores e os chama ao arrependimento.",
                "misericórdia", "Compaixão ativa que socorre quem está em necessidade.", "Como a misericórdia de Deus muda a forma como você vê pessoas perdidas?",
                ["Quem precisa ser recebido com amor?", "Como você pode ser um próximo?", "Por que o arrependimento traz alegria?"]),
              seeds("Lucas 10; 15; 19", [
                  ("Quem é o próximo na parábola do bom samaritano?", "Quem demonstra misericórdia", ["Somente quem pertence ao meu grupo", "Apenas quem pode retribuir", "Quem tem mais poder"], "Lucas 10:36-37"),
                  ("O que acontece no céu quando um pecador se arrepende?", "Há alegria", ["Há indiferença", "Há medo", "Nada acontece"], "Lucas 15:7"),
                  ("Por que o pai recebeu o filho perdido?", "Porque ele voltou arrependido", ["Porque mereceu por obras", "Porque não havia pecado", "Porque comprou o perdão"], "Lucas 15:20-24"),
                  ("Quem Jesus veio buscar e salvar?", "O perdido", ["Somente os autossuficientes", "Apenas os ricos", "Quem nunca pecou"], "Lucas 19:10"),
                  ("Qual mudança Zaqueu demonstrou?", "Arrependimento que produziu reparação", ["Fuga de Jesus", "Orgulho da riqueza", "Desprezo pelos pobres"], "Lucas 19:8-9"),
              ])),
            M("lc-03-caminho-jerusalem", "Rumo a Jerusalém", "Discipulado no caminho",
              "Jesus caminha resolutamente para Jerusalém, ensinando oração, humildade, serviço e o custo de segui-lo.",
              T("Lucas 9:51", "Manifestou, no semblante, a intrépida resolução de ir para Jerusalém.",
                "A viagem a Jerusalém organiza grande parte de Lucas. Jesus sabe que sua missão envolve sofrimento, mas segue obediente ao plano do Pai.",
                "resolução", "Firmeza para cumprir a vontade de Deus.", "Como a determinação de Jesus encoraja sua obediência?",
                ["Que chamado exige perseverança?", "Como sua oração pode ser mais dependente?", "Onde você pode servir com humildade?"]),
              seeds("Lucas 9-18", [
                  ("Para onde Jesus decidiu ir?", "Jerusalém", ["Roma", "Egito", "Nazaré para fugir"], "Lucas 9:51"),
                  ("Como Jesus ensina seus discípulos a orar?", "Chamando Deus de Pai e buscando sua vontade", ["Para exibir espiritualidade", "Sem confiança", "Somente em público"], "Lucas 11:2-4"),
                  ("O que Jesus diz sobre quem se exalta?", "Será humilhado", ["Será salvo por seu orgulho", "Será o maior no Reino", "Não precisa de graça"], "Lucas 14:11"),
                  ("Quem deve ser convidado para a mesa, segundo Jesus?", "Pobres, aleijados, coxos e cegos", ["Somente amigos ricos", "Apenas pessoas influentes", "Quem pode pagar de volta"], "Lucas 14:13"),
                  ("O que o rico governante precisava reconhecer?", "Que precisava seguir Jesus acima de suas riquezas", ["Que dinheiro salva", "Que não tinha pecado", "Que não precisava mudar"], "Lucas 18:22-23"),
              ])),
            M("lc-04-vitoria-ressurreicao", "A vitória do Cristo", "Cruz, ressurreição e testemunho",
              "Jesus sofre e morre como o Cristo prometido, ressuscita e abre o entendimento dos discípulos para as Escrituras.",
              T("Lucas 24:26-27", "Porventura, não convinha que o Cristo padecesse e entrasse na sua glória?",
                "O Cristo não foi derrotado pela cruz. Seu sofrimento e sua glória cumprem o plano de Deus anunciado nas Escrituras.",
                "cumprimento", "Realização das promessas de Deus em Cristo.", "Como as Escrituras ajudam a entender a cruz e a ressurreição?",
                ["O que a cruz realizou?", "Por que Jesus precisava ressuscitar?", "Como testemunhar sobre Cristo?"]),
              seeds("Lucas 22-24", [
                  ("O que Jesus disse que seu corpo seria dado por nós?", "Na ceia", ["No templo como riqueza", "Para os anjos", "Sem relação conosco"], "Lucas 22:19"),
                  ("Como Jesus orou no Getsêmani?", "Que seja feita a vontade do Pai", ["Que sua própria vontade prevalecesse", "Sem confiar no Pai", "Pedindo vingança"], "Lucas 22:42"),
                  ("O que o malfeitor arrependido pediu a Jesus?", "Lembra-te de mim", ["Dá-me um reino terreno", "Salva-me sem arrependimento", "Condena os outros"], "Lucas 23:42-43"),
                  ("O que as mulheres encontraram no túmulo?", "O túmulo vazio e a notícia da ressurreição", ["Jesus ainda morto", "Guardas celebrando", "Uma coroa de Roma"], "Lucas 24:1-6"),
                  ("Do que os discípulos seriam testemunhas?", "Da morte e ressurreição de Cristo", ["De uma filosofia secreta", "Da glória de Roma", "De regras humanas"], "Lucas 24:46-48"),
              ])),
            M("lc-boss-revisao", "Desafio: O Salvador que busca", "Revisão de Lucas",
              "Revise as boas-novas aos humildes, a misericórdia, o caminho de Jerusalém e a vitória de Cristo.",
              None,
              seeds("Lucas 1-24", [
                  ("Como Lucas apresenta Jesus no nascimento?", "Como Salvador, Cristo e Senhor", ["Como um governante romano", "Como apenas mestre humano", "Como anjo"], "Lucas 2:11"),
                  ("A quem Jesus anuncia boas-novas?", "Aos pobres e necessitados", ["Somente aos poderosos", "Apenas aos sem pecado", "Somente a Israel rico"], "Lucas 4:18"),
                  ("Qual atitude identifica o próximo?", "Misericórdia", ["Indiferença", "Orgulho", "Vingança"], "Lucas 10:36-37"),
                  ("Qual era a missão do Filho do Homem?", "Buscar e salvar o perdido", ["Buscar riqueza", "Conquistar Roma", "Evitar pecadores"], "Lucas 19:10"),
                  ("O que Jesus explicou após ressuscitar?", "Que o Cristo devia sofrer e ressuscitar", ["Que a cruz não importava", "Que as Escrituras falharam", "Que não havia missão"], "Lucas 24:26-27"),
              ]), True),
        ],
    },
    "joao": {
        "module": {"title": "João", "icon": "sun", "section": "Evangelhos"},
        "missions": [
            M("jo-01-verbo-sinais", "O Verbo e os sinais", "Jesus revela a glória do Pai",
              "João anuncia Jesus como o Verbo eterno feito carne. Seus sinais revelam sua glória e convidam à fé.",
              T("João 1:14", "E o Verbo se fez carne e habitou entre nós, cheio de graça e de verdade.",
                "João começa antes da criação: o Filho eterno estava com Deus e é Deus. Ao tornar-se homem, ele revela o Pai sem deixar de ser Deus.",
                "Verbo", "O Filho eterno de Deus, que revela plenamente o Pai.", "O que significa crer que Jesus é plenamente Deus e plenamente homem?",
                ["O que Jesus revela sobre o Pai?", "Como responder aos seus sinais?", "Onde você precisa confiar em sua graça?"]),
              seeds("João 1-6", [
                  ("Quem é o Verbo no início do Evangelho?", "Jesus Cristo", ["João Batista", "Moisés", "Um anjo"], "João 1:1,14"),
                  ("O que o Verbo fez?", "Fez-se carne e habitou entre nós", ["Deixou de ser Deus", "Tornou-se apenas uma ideia", "Evitou a humanidade"], "João 1:14"),
                  ("Qual foi o primeiro sinal de Jesus em João?", "Transformar água em vinho", ["Multiplicar pães", "Acalmar o mar", "Curar um cego"], "João 2:1-11"),
                  ("O que Jesus oferece a quem crê nele?", "Vida eterna", ["Apenas sucesso terreno", "Independência de Deus", "Ausência de lutas"], "João 3:16"),
                  ("Quem Jesus diz ser o pão da vida?", "Ele mesmo", ["Moisés", "A multidão", "O templo"], "João 6:35"),
              ])),
            M("jo-02-eu-sou", "Eu Sou", "A identidade e a vida em Jesus",
              "Jesus usa imagens profundas para revelar sua identidade: ele é luz, porta, bom pastor, ressurreição, caminho e vida.",
              T("João 11:25-26", "Eu sou a ressurreição e a vida. Quem crê em mim, ainda que morra, viverá.",
                "As declarações Eu Sou mostram que Jesus é suficiente para seu povo e compartilham ecos do nome de Deus revelado no Antigo Testamento.",
                "Eu Sou", "Expressão que destaca a identidade única e divina de Jesus.", "Qual declaração de Jesus responde mais diretamente à sua necessidade hoje?",
                ["Onde você busca vida?", "Como ouvir a voz do Bom Pastor?", "Como compartilhar essa esperança?"]),
              seeds("João 8-11; 14", [
                  ("Quem Jesus diz ser para o mundo?", "A luz do mundo", ["Uma luz entre muitas", "A escuridão", "Um guia sem verdade"], "João 8:12"),
                  ("Quem é o bom pastor?", "Jesus", ["Um líder humano perfeito", "O imperador", "Qualquer voz religiosa"], "João 10:11"),
                  ("O que o bom pastor faz pelas ovelhas?", "Dá a vida por elas", ["Abandona-as ao perigo", "Explora-as", "Não as conhece"], "João 10:11,14"),
                  ("Quem é a ressurreição e a vida?", "Jesus", ["Lázaro", "Marta", "Moisés"], "João 11:25"),
                  ("Como Jesus se apresenta como acesso ao Pai?", "O caminho, a verdade e a vida", ["Uma entre várias opções iguais", "Um caminho sem verdade", "Uma lei para merecer salvação"], "João 14:6"),
              ])),
            M("jo-03-adeus-espirito", "Permaneçam em mim", "Despedida, amor e Espírito Santo",
              "Antes da cruz, Jesus consola seus discípulos, ordena amor sacrificial e promete o Espírito Santo para fortalecê-los.",
              T("João 14:16-17", "E eu rogarei ao Pai, e ele vos dará outro Consolador... o Espírito da verdade.",
                "Nos discursos de despedida, Jesus não deixa seus discípulos órfãos. O Espírito aplica a obra de Cristo e os conduz na verdade.",
                "Consolador", "O Espírito Santo, presença e auxílio de Deus com seu povo.", "Como a promessa do Espírito fortalece sua vida e seu testemunho?",
                ["Como permanecer em Cristo?", "Quem você precisa amar de modo sacrificial?", "Onde precisa da ajuda do Espírito?"]),
              seeds("João 13-17", [
                  ("Que novo mandamento Jesus deu?", "Amar uns aos outros como ele nos amou", ["Vencer os outros", "Buscar o primeiro lugar", "Evitar servir"], "João 13:34"),
                  ("Quem Jesus promete enviar?", "O Espírito Santo, o Consolador", ["Um novo imperador", "Apenas regras", "Um anjo para substituir Cristo"], "João 14:16-17"),
                  ("O que acontece com quem permanece em Jesus?", "Produz fruto", ["Vive sem depender dele", "Não precisa obedecer", "Pode ignorar sua palavra"], "João 15:5"),
                  ("Qual é o maior amor, segundo Jesus?", "Dar a vida pelos amigos", ["Buscar aplauso", "Receber presentes", "Evitar todo sacrifício"], "João 15:13"),
                  ("O que Jesus ora para seus discípulos?", "Que sejam santificados na verdade", ["Que saiam do mundo imediatamente", "Que sejam admirados por todos", "Que nunca precisem de Deus"], "João 17:17"),
              ])),
            M("jo-04-cruz-tome", "O Crucificado e o Ressuscitado", "Vitória, paz e fé",
              "Jesus entrega sua vida por amor, ressuscita e chama Tomé — e todos os leitores — a crer nele como Senhor e Deus.",
              T("João 20:28-29", "Senhor meu e Deus meu! ... Bem-aventurados os que não viram e creram.",
                "João mostra a cruz como a hora da glorificação de Jesus. O Ressuscitado aparece aos discípulos e transforma dúvida em confissão de fé.",
                "Senhor", "Título de honra e governo que Tomé aplica a Jesus ressuscitado.", "Como a confissão de Tomé resume a resposta correta a Jesus?",
                ["O que a cruz revela sobre o amor?", "Como a ressurreição responde à dúvida?", "Como viver pela fé?"]),
              seeds("João 18-21", [
                  ("O que Jesus declarou na cruz?", "Está consumado", ["Ainda falta pagar pelo pecado", "Tudo foi perdido", "O Reino acabou"], "João 19:30"),
                  ("O que Maria Madalena encontrou no primeiro dia da semana?", "O túmulo vazio", ["Jesus ainda sepultado", "Uma guarda celebrando", "Uma nova lei"], "João 20:1"),
                  ("Que paz Jesus ofereceu aos discípulos ressuscitado?", "Paz seja convosco", ["Paz baseada em mérito", "Paz sem sua presença", "Paz somente para alguns"], "João 20:19"),
                  ("Como Tomé chamou Jesus?", "Senhor meu e Deus meu", ["Apenas mestre humano", "Um fantasma", "Um anjo"], "João 20:28"),
                  ("Por que João registrou seus sinais?", "Para que creiamos que Jesus é o Cristo, o Filho de Deus", ["Para entreter curiosos", "Para ensinar política", "Para substituir a fé"], "João 20:31"),
              ])),
            M("jo-boss-revisao", "Desafio: Creia e tenha vida", "Revisão de João",
              "Revise o Verbo feito carne, os sinais, as declarações Eu Sou, o Espírito e a fé no Ressuscitado.",
              None,
              seeds("João 1-21", [
                  ("Quem se fez carne em João 1?", "O Verbo eterno, Jesus Cristo", ["João Batista", "Moisés", "Um anjo"], "João 1:14"),
                  ("Para que os sinais de Jesus foram registrados?", "Para levar pessoas a crer em Jesus", ["Para criar superstição", "Para exaltar discípulos", "Para provar poder humano"], "João 20:30-31"),
                  ("Quem Jesus declara ser em relação à vida?", "A ressurreição e a vida", ["Um mestre sem poder", "A morte", "Um caminho opcional sem verdade"], "João 11:25"),
                  ("Quem Jesus promete aos discípulos?", "O Espírito Santo, o Consolador", ["Um novo sistema religioso", "Riqueza material", "Um exército"], "João 14:16-17"),
                  ("Qual foi a confissão de Tomé?", "Senhor meu e Deus meu", ["Tu és apenas mestre", "Não creio em ti", "Tu és César"], "João 20:28"),
              ]), True),
        ],
    },
}
