# Family Controls entitlement request ("Primeiro a Palavra")

Submit at developer.apple.com › Account › Request "Family Controls
(Distribution)" entitlement. Apple reviews these requests by hand and can take
weeks, so send it before the feature is built. Development builds already work
with the development entitlement.

## Fields

**App name:** STWAY
**Bundle ID:** [fill in]
**Platform:** iOS 16 or later (individual authorization, `.individual`)

**How will your app use the Family Controls framework?**

STWAY is a daily Bible study app. "Primeiro a Palavra" (Word First) is an
optional focus mode that the user turns on for themselves. The user picks apps
with FamilyActivityPicker (for example, social media and video apps). Until
they finish or mark today's Bible reading in STWAY, those apps show a shield
that says "Primeiro a Palavra" with a button to open STWAY. Once the reading is
done, STWAY removes the shield until the next day.

- Authorization uses AuthorizationCenter with `.individual`. The user manages
  their own device. There is no parent/child or remote control.
- The user chooses which apps are covered, can change the list at any time,
  and can turn the mode off in STWAY's settings. A "Liberar por hoje" (unlock
  for today) button is always available on the shield.
- We use ManagedSettings (shields), DeviceActivity (daily schedule) and a
  ShieldConfiguration extension (the shield's text and button).
- We do not read, store or send app usage data. Selected apps stay as opaque
  tokens on the device and never leave it.
- The feature is part of the optional Peregrino+ subscription. It is never
  turned on by default.

**Why does your app need this entitlement?**

Many users want to read the Bible every day but open social apps first. A
shield the user sets up for themselves helps them keep that commitment. Screen
Time APIs are the only supported way to do this on iOS.

**Contact:** stway.app@gmail.com
