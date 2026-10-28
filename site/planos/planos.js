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

const PLAY_URL = "https://play.google.com/store/apps/details?id=com.trilha.trilha_app";
const IOS_URL = "https://apps.apple.com/br/search?term=STWAY";

const $ = (id) => document.getElementById(id);
const ua = navigator.userAgent || "";
const isIos = /iPhone|iPad|iPod/i.test(ua) || (/Macintosh/.test(ua) && "ontouchend" in document);
const isAndroid = /Android/i.test(ua);
const storeUrl = isIos ? IOS_URL : isAndroid ? PLAY_URL : null;

// "Baixar o app": loja do aparelho; no computador, segue para o teste.
document.querySelectorAll("[data-store]").forEach((a) => {
  if (storeUrl) a.href = storeUrl;
});

const buttons = document.querySelectorAll(".billing-opt");
const saveEl = $("billing-save");

function render(billing) {
  const annual = billing === "anual";
  const pioneer = annual && PIONEER_ON_SALE;
  const price = annual ? (pioneer ? PRICES.pioneiro : PRICES.anual) : PRICES.mensal;

  buttons.forEach((b) => b.setAttribute("aria-pressed", String(b.dataset.billing === billing)));
  saveEl.hidden = !annual;

  $("plus-tag").textContent = pioneer ? "Preço de Pioneiro" : annual ? "O mais escolhido" : "Mês a mês";
  $("plus-was").textContent = pioneer ? price.was : "";
  $("plus-amount").textContent = price.amount;
  $("plus-note").textContent = price.note;
  $("plus-fine").textContent = pioneer
    ? "Preço travado enquanto a assinatura renovar. Para os primeiros assinantes."
    : annual
      ? "Metade do mensal ao longo do ano."
      : "Cancele quando quiser. Sem teste grátis no mensal.";

  const cta = $("plus-cta");
  const ctaNote = $("plus-cta-note");
  const link = CHECKOUT[billing];
  if (link) {
    cta.href = link;
    cta.textContent = annual ? "Começar 14 dias grátis" : "Assinar o mensal";
    ctaNote.textContent = annual ? "Sem cobrança nos primeiros 14 dias. Cancele quando quiser." : "";
  } else {
    // Sem checkout no site ainda: assina pela loja do celular.
    cta.href = storeUrl || "/#teste";
    cta.textContent = annual ? "Começar 14 dias grátis no app" : "Assinar no app";
    ctaNote.textContent = "Por enquanto, a assinatura é feita dentro do app.";
  }
}

// Passo a passo e perguntas da compra no site só aparecem com checkout.
const webCheckout = Boolean(CHECKOUT.anual || CHECKOUT.mensal);
document.querySelectorAll("[data-web]").forEach((el) => {
  el.hidden = !webCheckout;
});

buttons.forEach((b) => b.addEventListener("click", () => render(b.dataset.billing)));
render("anual");
