// Escopo próprio: main.js também roda nesta página e já declara nomes globais (root, ...).
{
// Planos — preços e checkout do Peregrino+ no site.
//
// CHECKOUT: Web Purchase Links do RevenueCat (Web Billing / Stripe), um por
// plano. Vazio = a assinatura pelo site ainda não está ligada: o botão leva
// para a loja do celular. O RevenueCat devolve um link de resgate
// (stway://redeem_web_purchase?…) que o app troca pelo Peregrino+ na conta.
const CHECKOUT = {
  anual: "",
  mensal: "",
};

// Pioneiro: o único anual enquanto houver vaga (MONETIZATION.md). Desligue
// junto com o `pioneer_until` do Remote Config.
const PIONEER_ON_SALE = true;

const PRICES = {
  mensal: { amount: "R$ 19,90", note: "por mês" },
  anual: { amount: "R$ 119,90", note: "por ano · R$ 9,99/mês" },
  pioneiro: { amount: "R$ 89,90", note: "por ano · R$ 7,49/mês", was: "R$ 119,90" },
};

const PLAY_URL =
  "https://play.google.com/store/apps/details?id=com.trilha.trilha_app&pcampaignid=web_share";

const $ = (id) => document.getElementById(id);

document.querySelectorAll("[data-store]").forEach((a) => {
  a.href = PLAY_URL;
  a.target = "_blank";
  a.rel = "noopener";
});

const buttons = document.querySelectorAll(".billing-opt");
const saveEl = $("billing-save");

function render(billing) {
  const annual = billing === "anual";
  const pioneer = annual && PIONEER_ON_SALE;
  const price = annual ? (pioneer ? PRICES.pioneiro : PRICES.anual) : PRICES.mensal;
  const tag = pioneer ? "Preço de Pioneiro" : annual ? "O mais escolhido" : "Mês a mês";
  const link = CHECKOUT[billing];
  const href = link || PLAY_URL;
  const ctaText = link
    ? (annual ? "Começar 14 dias grátis" : "Assinar o mensal")
    : (annual ? "Começar 14 dias grátis no app" : "Assinar no app");
  const set = (id, text) => { const el = $(id); if (el) el.textContent = text; };

  buttons.forEach((b) => b.setAttribute("aria-pressed", String(b.dataset.billing === billing)));
  if (saveEl) saveEl.hidden = !annual;

  // Cartão do Peregrino+ (página de Planos)
  set("plus-tag", tag);
  set("plus-was", pioneer ? price.was : "");
  set("plus-amount", price.amount);
  set("plus-note", price.note);
  set("plus-fine", pioneer
    ? "Preço travado enquanto a assinatura renovar. Para os primeiros assinantes."
    : annual ? "Metade do mensal ao longo do ano." : "Cancele quando quiser. Sem teste grátis no mensal.");
  set("plus-cta-note", link
    ? (annual ? "Sem cobrança nos primeiros 14 dias. Cancele quando quiser." : "")
    : "Por enquanto, a assinatura é feita dentro do app.");
  const cta = $("plus-cta");
  if (cta) { cta.href = href; cta.textContent = ctaText; if (!link) { cta.target = "_blank"; cta.rel = "noopener"; } }

  // O mesmo preço e o mesmo botão em todo lugar (herói, fecho, barra fixa, bloco da home).
  document.querySelectorAll('[data-plus="tag"]').forEach((el) => { el.textContent = tag; });
  document.querySelectorAll('[data-plus="was"]').forEach((el) => { el.textContent = pioneer ? price.was : ""; });
  document.querySelectorAll('[data-plus="amount"]').forEach((el) => { el.textContent = price.amount; });
  document.querySelectorAll('[data-plus="note"]').forEach((el) => { el.textContent = price.note; });
  document.querySelectorAll("[data-plus-cta]").forEach((a) => {
    a.href = href;
    if (!link) { a.target = "_blank"; a.rel = "noopener"; }
    a.textContent = a.classList.contains("btn-sm") ? (annual ? "14 dias grátis" : "Assinar") : ctaText;
  });
  document.querySelectorAll(".pl-cta-note").forEach((el, i) => {
    if (i === 0) el.textContent = annual ? "Sem cobrança nos primeiros 14 dias. Cancele antes e nada é cobrado." : "Cancele quando quiser. Sem teste grátis no mensal.";
  });
}

// Barra fixa: aparece depois do herói e some quando o bloco de planos ou o fecho estão na tela.
{
  const bar = document.querySelector(".pl-sticky");
  const hero = document.querySelector(".pl-hero");
  const hide = [...document.querySelectorAll(".pl-plans, .pl-final")];
  if (bar && hero && "IntersectionObserver" in window) {
    const seen = new Map();
    const update = () => {
      const show = !seen.get(hero) && !hide.some((h) => seen.get(h));
      bar.classList.toggle("is-on", show);
      document.documentElement.classList.toggle("has-sticky", show);
      bar.querySelector("a").tabIndex = show ? 0 : -1;
      bar.setAttribute("aria-hidden", String(!show));
    };
    const io = new IntersectionObserver((entries) => {
      entries.forEach((e) => seen.set(e.target, e.isIntersecting));
      update();
    }, { threshold: 0.15 });
    [hero, ...hide].forEach((el) => io.observe(el));
  }
}

// Cartões trancados: destrancam em sequência quando a grade entra na tela.
{
  const bento = document.querySelector(".pl-bento");
  if (bento && "IntersectionObserver" in window && !matchMedia("(prefers-reduced-motion: reduce)").matches) {
    const io = new IntersectionObserver((entries) => {
      if (!entries.some((e) => e.isIntersecting)) return;
      bento.classList.add("is-open");
      io.disconnect();
    }, { threshold: 0.2 });
    io.observe(bento);
  } else bento?.classList.add("is-open");
}

// Passo a passo e perguntas da compra no site só aparecem com checkout.
const webCheckout = Boolean(CHECKOUT.anual || CHECKOUT.mensal);
document.querySelectorAll("[data-web]").forEach((el) => {
  el.hidden = !webCheckout;
});

buttons.forEach((b) => b.addEventListener("click", () => render(b.dataset.billing)));
render("anual");
}
