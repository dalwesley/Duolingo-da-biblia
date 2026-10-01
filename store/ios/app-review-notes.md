# App Review — reply and Notes field

Paste the text below into the App Review reply and into
App Store Connect › App Review Information › Notes.
Fill in the items marked [ ] before sending.

---

Hello App Review team,

Thank you for the review. Here is the information you requested.

**1. Screen recording**

Recorded on [iPhone model], iOS [version], build 1.0.33 (33):
[link to the video]

The recording shows, in order: launching the app, onboarding, signing in with Apple, completing one daily lesson, the Bible reader with the Hebrew/Greek word view, study groups and rankings, reporting and blocking another user, and deleting the account (Settings › Account › Delete account).

**2. Purpose and target audience**

STWAY helps Portuguese-speaking Christians build a daily habit of reading and studying the Bible. Many people want to read the Bible every day but give up, or read without understanding. STWAY turns one short passage per day (5–12 minutes) into a guided study. The passage stays on screen while the user answers short exercises at three levels: observation (what the text says), comprehension (how the parts connect) and interpretation (what it means).

The audience is adults and teenagers in Brazil and other Portuguese-speaking countries: church members, small groups and Sunday school classes. The app also has English and Spanish interface translations. The Bible text is in Portuguese.

**3. How to access the main features**

- Sign-in is required, with Sign in with Apple or Google. You can use any Apple ID, so no demo credentials are needed. [If you prefer a demo Google account: email / password]
- After sign-in, the onboarding asks for a name and a first study path. The first tab then shows the lesson of the day.
- "Bíblia" (Bible) tab: offline Bible reader. Tap a word to see the original Hebrew/Greek word.
- Groups and rankings: create a study group in the "Juntos" (Together) tab and invite someone with a code or QR code.
- Report and block: tap any person in the rankings, a group invitation, a challenge or a recognition, then tap the flag icon. The user can report (offensive name, inappropriate photo, harassment, spam or other, with an optional comment) and/or block. Blocked people disappear from that user's rankings and inbox. Our server rules also stop them from sending invitations, challenges, recognitions or group nudges to that user. Blocked people can be managed in Settings › Account › Blocked people.
- Account deletion: Settings › Account › Delete account. The app asks for confirmation, then permanently deletes the account and the data linked to it. Users who signed in with Apple confirm with Apple again, so the app can revoke the Sign in with Apple token. Google users are asked to sign in again only if their session is old.

**4. External services**

- Firebase Authentication (Google), with Sign in with Apple and Google Sign-In: login.
- Cloud Firestore and Cloud Functions (Google): progress backup, study content, groups, rankings and account data cleanup.
- Firebase Cloud Messaging: reminders and study-partner notifications.
- Firebase Analytics, Crashlytics and Remote Config: usage metrics, crash reports and feature flags.

The app does not call any AI service at runtime. The study content is written in advance and published from our admin panel.

**User-generated content**

There are no posts, chat or media uploads. The only content other users can see is a display name, a profile photo (from the Apple/Google account, or a letter avatar), study group names and short preset nudge messages. Names, group names and group notes go through a word filter (Portuguese, English and Spanish) before they are saved. On the sign-in screen, users accept the Terms of Use (https://stway.com.br/termos), which state that offensive content and abusive users are not tolerated. Every place where another person appears has the report and block option described above. Reports go to our moderation queue in the admin panel. We review them within 24 hours and remove the content or disable the account when needed.

**In-app purchases**

The app is free. This version has no in-app purchases or paid features.

**5. Regional differences**

The app works the same way in every region where it is available. The interface follows the device language (Portuguese, English or Spanish). The Bible text and the study content are in Portuguese in all regions.

**6. Third-party material**

- Tradução Brasileira (1917): public domain.
- João Ferreira de Almeida Atualizada Livre (JFAAL): © Marcos Cristiano Alves Ferreira, licensed under CC BY 3.0 BR.
- Hebrew/Greek lexicon and tagged text: STEPBible / Tyndale House Cambridge, CC BY 4.0.
- Cross-references: openbible.info, CC BY.

Attributions are shown in the app under Settings › About › Credits. The app does not operate in a regulated industry.

Contact: stway.app@gmail.com

Best regards,
[name]
