// Escopo próprio: main.js também roda nesta página e já declara nomes globais (root, ...).
{
// Advento 2026: calendário com postais velados até o dia de cada cena.
// Dados: marketing/advento-2026/dias.json (regerar se mudar o roteiro).
const START = [2026, 10, 29]; // 29/11/2026 (mês 0-based)
const DAYS = [{"d": 1, "t": "O Verbo se fez carne", "h": "Deus se aproximou"}, {"d": 2, "t": "No princípio", "h": "Deus é o centro, não eu"}, {"d": 3, "t": "Imagem", "h": "Fomos feitos para refletir"}, {"d": 4, "t": "Chamado", "h": "A fé anda quando Deus chama"}, {"d": 5, "t": "Estrelas", "h": "A promessa é maior que o medo"}, {"d": 6, "t": "Moriá", "h": "Deus proverá o cordeiro"}, {"d": 7, "t": "Moisés", "h": "Deus levanta libertador"}, {"d": 8, "t": "Páscoa", "h": "O sangue guarda a casa"}, {"d": 9, "t": "O Rei no monte", "h": "O Reino tem voz"}, {"d": 10, "t": "Pobres de espírito", "h": "O Reino cabe no vazio"}, {"d": 11, "t": "Os que choram", "h": "Há conforto para quem chora"}, {"d": 12, "t": "Pacificadores", "h": "Shalom é missão"}, {"d": 13, "t": "Batismo", "h": "O céu se abre sobre o Filho"}, {"d": 14, "t": "Sermão", "h": "O monte ensina o Reino"}, {"d": 15, "t": "Pai nosso", "h": "Orar é pedir o Reino"}, {"d": 16, "t": "Meu pastor", "h": "Nada me faltará"}, {"d": 17, "t": "Humildade", "h": "Cristo desceu até a cruz"}, {"d": 18, "t": "Parábolas", "h": "O Reino se escuta em história"}, {"d": 19, "t": "Milagres", "h": "O Reino toca o corpo"}, {"d": 20, "t": "Ansiedade", "h": "O tesouro puxa o coração"}, {"d": 21, "t": "Ceia", "h": "O pão antecipa a entrega"}, {"d": 22, "t": "Cruz", "h": "O Rei reina pregado"}, {"d": 23, "t": "Ressurreição", "h": "A espera não foi vã"}, {"d": 24, "t": "Descanso", "h": "O sétimo dia é dádiva"}, {"d": 25, "t": "Alegria", "h": "Alegrai-vos no Senhor"}, {"d": 26, "t": "Fome de justiça", "h": "Quem tem fome será farto"}];

const MONTHS = ["jan", "fev", "mar", "abr", "mai", "jun", "jul", "ago", "set", "out", "nov", "dez"];
const WEEK_LABELS = ["1ª semana", "2ª semana", "3ª semana", "4ª semana"];

const today = new Date();
today.setHours(0, 0, 0, 0);

function dateOf(n) {
  return new Date(START[0], START[1], START[2] + n - 1);
}

const root = document.getElementById("calendario");
const tilts = [-1.6, 1.2, -0.6, 1.8, -1.2, 0.8, -2];
let html = "";
for (let w = 0; w < 4; w++) {
  const week = DAYS.slice(w * 7, w * 7 + 7);
  if (!week.length) break;
  const a = dateOf(week[0].d);
  const b = dateOf(week[week.length - 1].d);
  html += `<h2 class="advento-week">${WEEK_LABELS[w]}<small>${a.getDate()} ${MONTHS[a.getMonth()]} – ${b.getDate()} ${MONTHS[b.getMonth()]}</small></h2><ul class="advento-grid">`;
  for (const day of week) {
    const when = dateOf(day.d);
    const isToday = when.getTime() === today.getTime();
    // Dia 1 fica sempre à mostra, como amostra.
    const veiled = day.d > 1 && when > today;
    const nn = String(day.d).padStart(2, "0");
    html += `<li class="postal${veiled ? " is-veiled" : ""}${isToday ? " is-today" : ""}" style="--tilt:${tilts[day.d % tilts.length]}deg">
      <div class="art"><img src="/advento/img/dia-${nn}.webp" alt="" loading="lazy" width="300" height="200" /></div>
      ${veiled ? `<span class="veil-note">abre em ${when.getDate()}/${when.getMonth() + 1}</span>` : ""}
      <span class="when">Dia ${day.d} · ${when.getDate()} ${MONTHS[when.getMonth()]}${isToday ? " · hoje" : ""}</span>
      <h3>${day.t}</h3>
      <p>${veiled ? "&nbsp;" : day.h}</p>
    </li>`;
  }
  html += "</ul>";
}
root.innerHTML = html;
}
