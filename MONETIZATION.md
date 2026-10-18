# Monetização STWAY

Não cobramos para começar. Não cobramos para ler a Palavra.
Não preencher as chaves RevenueCat antes do D7 ok.

16 out 2026. O produto no código é o **Peregrino+**, e a Caminhada a partir do dia 4 faz parte dele. Áudio, célula e gelo não.

---

## Estado no app

Chaves `_apiKeyAndroid` / `_apiKeyIos` **vazias**. O SDK não inicia, ninguém compra, e `plusFeaturesOpen` deixa a Caminhada, a revisão, a constância e o reforço **abertos**. Sem loja e sem promoção, a faixa some.

| Peça | Código | Hoje |
|------|--------|------|
| RevenueCat (`purchases_flutter`) | Sim | Não inicializa |
| Paywall | Sim — Ajustes, perfil, revisão, oferta da Home | Sem botão de compra |
| Entitlement `peregrino_plus` | Sim | Sempre falso |
| Promoção `plus_launch_free_until` | Sim | Vazia = sem promoção. Ligada, todo mundo tem o Plus e a compra some |
| Revisão da semana | Sim, com trava | Aberta enquanto não há loja |
| Constância + reforço do ponto fraco | Sim, no perfil | Abertos enquanto não há loja |
| Selo de apoiador | Sim, na Caravana (`users/{uid}.supporter`) | Não aparece no herói do próprio perfil |
| Apoio avulso (`apoio`) | Sim | Some sem a oferta na loja |
| Caminhada | Sim, a partir do dia 4 | Aberta enquanto não há loja. Dias 1–3 sempre abertos. A cena segue na aba Trilhas |
| Família / Igreja / Stripe / `isPro` no Firestore | Não | — |

Checklist da loja, ainda em aberto: [`store/ios/app-review-notes-iap.md`](store/ios/app-review-notes-iap.md).

---

## O que o Peregrino+ dá

Quem assina ganha isto. Seis coisas.

**1. A Caminhada**
A temporada no cartão da Home. Os 3 primeiros dias são de todo mundo. Do 4º em diante, o cartão abre o Peregrino+, e a revisão daquela semana também. A cena do dia continua na aba Trilhas. Sem loja, nada trava.

**2. Revisão da semana**
O “Hoje:” de cada cena feita na semana e 3 perguntas, de preferência as que a pessoa errou. Sem o Plus, a Home ainda mostra que a revisão existe; a tela lista as cenas e leva ao paywall. Não é a fila de erros (essa continua grátis).

**3. Planos de leitura guiados**
Evangelhos em 30 dias, Salmos e Provérbios em 31, Atos em 28, Gênesis em 25 e Novo Testamento em 90. Cada dia já vem pronto; o dia só avança quando a pessoa marca a leitura, então não há atraso. Catálogo em `trilha_app/lib/data/guided_reading_plans.dart`. O plano da Bíblia inteira, no ritmo da pessoa, continua grátis.

**4. Sua constância**
No perfil: sequência contra a meta, a semana dia a dia, e as últimas 12 semanas (cada coluna é uma lamparina).

**5. Reforço do ponto fraco**
Acerto por modo e por gesto, e até 5 perguntas do gesto que mais erra, em modo prática.

**6. Selo de apoiador**
No perfil que a Caravana abre. Quem assina ou quem fez um apoio avulso. A promoção de lançamento não dá selo.

O texto do paywall: o apoio mantém o Stway grátis para quem não pode pagar, e estes benefícios vêm junto.

---

## O que continua grátis

- Cena do dia, sequência, missões, gelo, lâmpadas, reparo, Strong
- Cânon nos 3 modos (Observação / Compreensão / Interpretação), inclusive Profundezas
- Bíblia offline e áudio da cena (passagem + “Hoje:”)
- Plano de leitura da Bíblia inteira (canônico ou cronológico, no tempo que couber) e o lembrete diário de qualquer plano
- Os 3 primeiros dias da Caminhada (o restante pede o Peregrino+; a cena segue na aba Trilhas)
- 1 companhia, Caravana, grupo, Desafio
- Fila de erros

---

## Apoio avulso

Oferta RevenueCat `apoio`. Pagamento único. Não libera recurso. Dá o mesmo selo.

Previsto na loja: `apoio_5`, `apoio_15`, `apoio_30`. Some de Ajustes, Trilhas, Bíblia e do fim de trilha enquanto a oferta não existe.

---

## Preços

O app não grava preço. Mostra o que a loja devolver. Anual primeiro na lista.

| | Plano de 28 ago | Laboratório (debug) | Decisão |
|---|---|---|---|
| Anual | R$ 119,90 | R$ 79,90 | Ainda não cravado na loja |
| Mensal | R$ 24,90 (âncora) | R$ 12,90 | Mensal continua âncora: existe para o anual parecer barato |
| Teste | 7 dias, no 7º streak ou na véspera da Caminhada | 14 dias no anual falso | O teste real é o da App Store / Play. Notas de revisão pedem **14 dias** |
| Vitalício | Proibido | O código mostra se a oferta tiver | Não criar o produto na loja |
| Família | R$ 179,90/ano, 5 contas | Não existe | Depois |

Paywall diz o preço por mês e o total do período. Nunca “2 meses grátis”.

Na revisão da Apple, `plus_launch_free_until` fica **vazio**. Com a data preenchida o revisor não acha o botão de compra.

---

## Onde aparece

Nunca: splash, login, onboarding, primeira trilha, no meio da cena.

**Sozinho, no máximo 1 vez por semana** (Home, sem outra folha aberta):

- Promoção acabando (faltam 7 dias ou menos)
- Promoção acabou
- 7 cenas concluídas, fora da promoção

Cada uma dessas, uma vez.

**No ponto do recurso**

- Dia 4+ da Caminhada, no cartão da Home → conhecer o Peregrino+
- Revisão da semana da temporada, e a revisão comum, sem Plus → o mesmo paywall
- Perfil sem Plus → o mesmo cartão, no lugar da constância e do acerto
- Ajustes → plano, restaurar, gerenciar
- Apoio → Ajustes, Trilhas, Bíblia, fim de trilha

Trial no dia 0 continua recusado. A oferta das 7 cenas é o substituto do “7º dia” — e é pior se a pessoa fizer as 7 no mesmo dia. Ver comparação.

---

## O que não vender

- Packs de gelo, reparo ou lâmpada
- Travar o cânon, o áudio, o Strong ou as Profundezas. A Caminhada trava no dia 4; a cena não
- Battle pass / skin / anúncio na cena
- Vitalício
- Sala maior, UGC, Kahoot
- Mais companheiros como benefício (o teto é 1; o código antigo que ouvia a assinatura não muda isso)

Se o anual converter mal, o motivo de pagar não ficou claro. Não abrir loja de energia.

---

## Comparação — plano de 28 ago e o que ficou

O plano antigo vendia a **temporada**. O app volta a vender isso: a Caminhada a partir do dia 4. Áudio, célula e gelo continuam de fora. A cena do cânon continua grátis.

| | Plano 28 ago | No app agora | Leitura |
|---|---|---|---|
| Motivo de pagar | Caminhada (dia 4+), áudio, revisão, preparo de célula | Caminhada (dia 4+), revisão, constância, reforço, selo | A temporada voltou. Áudio e célula não |
| Caminhada | 3 dias grátis, o resto Pro | 3 dias grátis, o resto Plus. A cena segue na aba Trilhas | Igual ao plano, sem esconder o texto |
| Áudio da cena | Pro | Grátis | Melhor para o ônibus. Deixou de ser razão de assinar |
| Revisão | 7 “Hoje:” + fecho da temporada | “Hoje:” da semana + 3 perguntas | A revisão semanal **existe** e trava. O fecho da temporada, não |
| Preparo de célula | Página no Pro, ponte para Igreja | Não existe | Adiado. O Pro individual não apresenta mais o plano Igreja |
| Gelo / lâmpada / Strong | Pro alivia o teto | Grátis, sem teto pago | Melhor. Era o caminho para a loja de energia que o plano pedia para não abrir |
| Companhia | Docs da casca: 3→6 | Teto 1, para todo mundo | Melhor. Mais dupla não ensina a ler |
| Quando cobra | 7º streak **ou** véspera da Caminhada | 7 cenas concluídas (vida inteira), 1× | Pior se houver maratona: o paywall pode abrir no dia 1. Igual ao D7 só quando é uma cena por dia |
| Teste | 7 dias | 14 dias nas notas de revisão e no lab | Em aberto. 14 dias protege o D7 e atrasa a cobrança. Cravar na loja, não nos dois lugares |
| Vitalício | Nunca | Código e termos aceitam, se a oferta existir | Pior se alguém criar o SKU. Mata o anual |
| Avulso | Proibido (packs) | Gorjeta, só selo, três valores | Não é pack de energia. Mesmo assim chegou **antes** da Família — a ordem antiga era o contrário |
| Família / Igreja | Perto, antes do avulso | Fora | Adiado, não cancelado |
| `isPro` no Firestore | Webhook | Só o selo (`supporter`) | O aparelho é a fonte da compra. Bolsa pastoral e família não têm onde gravar |
| Tom | A temporada | “Seu apoio mantém o app grátis” | Honesto se for verdade. Mais fácil de ler como culpa. O cânon grátis desarma “estão vendendo a Bíblia”; a frase do paywall puxa de volta |

O que **não** piorou: Bíblia, cânon e Profundezas seguem grátis. O paywall não entra na cena. Restaurar, gerenciar, EULA, termos e o aviso de que excluir a conta não cancela a loja estão feitos. Sem chave, nada trava sem saída.

A Caminhada no dia 4 é o motivo de pagar. Gelo e lâmpada continuam fora: se o anual converter mal, não abrir loja de energia.

---

## Ordem daqui pra frente

Só depois do D7 com testers.

1. Apple Small Business 15% + o equivalente no Play
2. Produtos na loja: `plus_annual` (teste de 14 dias, salvo decisão contrária), `plus_monthly`, `apoio_5` / `apoio_15` / `apoio_30`. Sem vitalício
3. RevenueCat: entitlement `peregrino_plus`, oferta padrão, oferta `apoio`. Preencher as duas chaves
4. Sandbox: comprar, teste, restaurar, gerenciar, cancelar, um apoio
5. Revisão da Apple com `plus_launch_free_until` vazio. A data entra depois da aprovação
6. Selo no herói do próprio perfil (a Caravana já vê)
7. Sair da conta também desliga o RevenueCat (hoje só excluir conta desliga)

Depois, se o anual existir de verdade:

8. `isPro` no Firestore via webhook — bolsa e família dependem disso
9. Família (até 5) antes de qualquer outro avulso
10. Winback (semana 2 e dia 330) e cobrança recusada no Android
11. Igreja na web (Stripe + Pix). App só mostra status
12. Bolsa pastoral no admin

Preparo de célula, playlist da sala e Encontro continuam no plano Igreja. Não entram no Peregrino+.

---

## Metas (90 dias depois de ligar)

As de 28 ago seguem como hipótese, não como medida. Ainda não há D7.

| | Base | Esticar |
|---|---|---|
| Trial entre quem chegou em D7 | 8–12% | 15% |
| Trial vira pago | 28–38% | 42% |
| Free vira Plus sem trial | 1,5–3% | 4% |
| Pagantes / D7 | **4–6%** | 8% |
| $ novo em anual | ≥ 60% | ≥ 75% |
| D7 vs antes do paywall | não cair > **5%** | 0% |

A oferta nas 7 cenas é o risco desse −5%. Se a pessoa ainda não voltou no sétimo dia, a folha não deveria abrir.
