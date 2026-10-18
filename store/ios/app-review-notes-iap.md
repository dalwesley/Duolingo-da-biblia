# App Review: first version with in-app purchases (Peregrino+)

Use this for the first build that ships Peregrino+ and the support tips.
`app-review-notes.md` is the reply for build 1.0.33 and stays as it is.

## Before submitting (checklist)

- [ ] Paid Apps agreement, tax and banking are active in App Store Connect.
- [ ] Subscription group "Peregrino+" with `plus_annual` (14-day free
      trial as an introductory offer) and `plus_monthly`. Add
      `plus_lifetime` (non-consumable) only if the lifetime plan ships.
- [ ] Consumables `apoio_5`, `apoio_15` and `apoio_30` (support tips).
- [ ] Every product has a pt-BR display name, a description and a
      **review screenshot** of the paywall (for tips, the "Apoiar o Stway"
      screen). The screenshots can come from a debug build with the lab's
      fake store turned on (Settings › Laboratório Peregrino+).
- [ ] Submit the products **with** the new app version. Apple reviews the
      first in-app purchases only together with a build.
- [ ] RevenueCat: entitlement `peregrino_plus`, default offering (annual,
      monthly, and lifetime if shipped) and offering `apoio` (the tips).
      The iOS key is in `SubscriptionService`.
- [ ] **Leave Remote Config `plus_launch_free_until` empty during review.**
      While the launch promo is on, the paywall shows "Free at launch" and
      no buy button, so the reviewer cannot find the purchase and the build
      gets rejected (Guideline 2.1). Set the date after approval.
- [ ] Publish the site with the new Terms and Privacy pages
      (stway.com.br/termos and /privacidade). Both cover the subscription.
- [ ] In App Store Connect, the app description links to the Terms of Use
      (Apple's standard EULA or stway.com.br/termos).
- [ ] Test in sandbox: buy, trial, restore, manage and cancel, and a tip.

## Notes field (paste into App Review Information › Notes)

Character count: about 2,300, under the 4,000 limit.

---

STWAY helps Portuguese-speaking Christians build a daily habit of reading and studying the Bible: one short passage a day, studied in three levels (observation, comprehension, interpretation). Sign in with Apple; any Apple ID works.

NEW IN THIS VERSION: PEREGRINO+ (OPTIONAL SUBSCRIPTION)
The Bible, every lesson in all three levels, rankings and study partners stay free. Peregrino+ adds:
- The liturgical season (Advent, and later seasons when they exist): days 1–3 are free; from day 4 the Home card opens the paywall. The same lesson stays available on the Trails tab. Each week's season review is included.
- Weekly review: each lesson's key idea from the week plus 3 questions.
- On the profile: the weekly streak history and accuracy by level and by question type.
- Practice of the weak spot: questions of the type the user misses most.
- A supporter badge on the profile.

Plans: annual (with a 14-day free trial) and monthly, auto-renewable, in one subscription group.

How to find the purchase:
1. Settings › tap the "Peregrino+" card, or
2. Profile › "Sua caminhada no Peregrino+" card › "Conhecer o Peregrino+", or
3. After 7 lessons, a sheet offers Peregrino+ on the home screen (at most once a week).
4. During Advent (or the next season), from day 4 the season card on Home opens the paywall. Days 1–3 of the season open the calendar.
The paywall shows the plans, the price per period, the trial terms, the auto-renew notice, Restore, Terms of Use, Privacy Policy and Apple's EULA. Subscribers see their plan, renewal date and a "Gerenciar assinatura" (Manage subscription) button that opens the App Store subscriptions page.

SUPPORT TIPS (CONSUMABLE)
Settings › "Ajude a continuar" opens "Apoiar o Stway": one-time tips of three amounts. They unlock nothing and only add the supporter badge. All purchases use In-App Purchase; the app has no links to outside payment.

ACCOUNT DELETION
Settings › Account › Delete account. The screen tells the user that deleting the account does not cancel a subscription and how to cancel it in the App Store.

EXTERNAL SERVICES
Firebase (Authentication, Firestore, Cloud Functions, Cloud Messaging, Analytics, Crashlytics, Remote Config) and RevenueCat for purchase status. No AI service is called at runtime.

USER-GENERATED CONTENT
Only display names, profile photos, group names and short preset nudges are visible to others. Names go through a word filter. Every place where another person appears has report and block (flag icon). Reports are reviewed within 24 hours.

Terms of Use: https://stway.com.br/termos
Privacy Policy: https://stway.com.br/privacidade
Contact: stway.app@gmail.com
