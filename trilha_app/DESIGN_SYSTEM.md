# STWAY design system

Rules for every screen and widget in `lib/`. If you need a piece that is
not listed here, add it to the design system first. Do not hand-roll it
in the screen.

## Where things live

| Thing | Use | File |
|---|---|---|
| Type | `AppTypography.display / title / body / label / verse / cta` | `lib/theme/app_theme.dart` |
| Type scale | `AppTypeScale`: every size snaps to a step | `lib/theme/app_theme.dart` |
| Radius | `AppRadii.hair / xs / sm / md / lg / xl / sheet / pill` | `lib/theme/app_theme.dart` |
| Spacing | `AppSpace.xs … xxxl`, `AppSpace.screen`, `AppSpace.section` | `lib/theme/app_theme.dart` |
| Color | `AppColors.*` | `lib/theme/app_colors.dart` |
| Card | `GlassCard`. Add `glow:` + `tint:` for a stage card (duel, pair, passport, hero). Juntos: Companhia=`presence`, Caravana/Desafio=`reward` | `lib/widgets/immersive_background.dart` |
| Nested panel inside a card | `InsetPanel` | `lib/widgets/ui_primitives.dart` |
| Kicker / section label | `SectionLabel(text, color:)`. Card header with glyph: `CardHeader` | `lib/widgets/ui_primitives.dart` |
| Primary action | `CopperCta` | `lib/widgets/ui_primitives.dart` |
| Secondary action | `GhostCta` (`danger: true` for destructive) / `OutlineCta` | `lib/widgets/ui_primitives.dart` |
| Tertiary text action | `TextCta`. Never use `TextButton` | `lib/widgets/ui_primitives.dart` |
| Badge / chip | `SoftBadge` (`solid: true` for reward / "Ativo"), `CountBadge`, `AppSelectChip` | `lib/widgets/ui_primitives.dart` |
| Bottom sheet | `showAppSheet(context, builder:)` + `AppSheetPanel(tint:)` | `lib/widgets/app_sheet.dart` |
| Dialog | `showAppDialog` + `AppDialog`, or `showAppConfirm` | `lib/widgets/app_sheet.dart` |
| Screen header | `TopBar` | `lib/widgets/top_bar.dart` |
| Segmented tabs | `AppSegmentedTabs(accent:)` — active = dark fill + accent rim. **Top** tabs=`reward` (gold); **nested** submenu=`presence` (glow). Never scene white. | `lib/widgets/juntos_chrome.dart` |

## Type scale (sizes are snapped automatically)

- display: 18 · 20 · 24 · 28 · 32 · 40 · 48 (screen / stage titles, hero numerals)
- title: 12 · 14 · 16 · 18 · 20 · 24 (card title 17→16, row title 14–16, HUD numbers)
- body: 11 · 12 · 13 · 14 · 16 (14 body, 13 secondary, 12 caption, 11 fine print)
- label: 10 · 11 · 12 · 13 (uppercase kickers, chips)
- verse: 14 · 16 · 18 · 21 · 24 · 28

Pass `exact: true` only when a size is proportional to a drawing (medal,
logo, chapter grid). Never use it to get an off-scale size.

## Rules

1. No `TextStyle(` or `GoogleFonts.` outside `lib/theme/`.
2. No `BorderRadius.circular(<number>)`. Use `AppRadii`. Hairlines and
   grabbers use `AppRadii.hair`.
3. No `Color(0x…)` for UI chrome outside `lib/theme/`. Painter palettes
   (medals, atmospheres) may keep local tables.
4. Every bottom sheet goes through `showAppSheet` + `AppSheetPanel`. The
   scrim is always `AppColors.scrim`.
5. Uppercase labels are `SectionLabel`. Do not uppercase
   `AppTypography.label` by hand.
6. A card-sized panel is `GlassCard`. A panel inside a card is `InsetPanel`.
7. Screens are always dark (`AppearanceStyle.onDark == true`). Text on
   cards uses `Appearance.of(context).text / textMuted(x)`.
