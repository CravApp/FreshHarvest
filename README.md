# Fresh Harvest — SwiftUI

A pixel-faithful **SwiftUI (iOS 17+) port** of the "Fresh Harvest Delivery" grocery/culinary
delivery screen, converted from the original Stitch HTML export
(`stitch_app_delivery_ui_m_vil.zip`: `code.html` + `DESIGN.md` + `screen.png`).

Nothing was invented: every colour, type scale, spacing value, string, price, rating and icon
codepoint comes from the source design.

---

## Quick start

```bash
cd FreshHarvest
open FreshHarvest.xcodeproj      # Xcode 15+, iOS 17 simulator
# or regenerate the project after editing project.yml:
xcodegen generate --spec project.yml
```

Build and run the `FreshHarvest` scheme. No signing team is required for the simulator.

---

## What was converted

### Design tokens → `DesignSystem/`

| Source | Swift |
|---|---|
| `DESIGN.md` colour front-matter (48 tokens) | `Palette.swift` — every token transcribed verbatim |
| `typography:` block (11 scales) | `Typography.swift` — `TypeScale` with exact size/weight/line-height/tracking |
| `spacing:` block | `Layout.swift` — `Spacing` (4px rhythm, 20px margin, 16px gutter) |
| `rounded:` block | `Layout.swift` — `Radius` (4/8/12/16/24/full) |
| Elevation levels 1–3 + overlay | `Layout.swift` — `Elevation` with the exact CSS shadow values |
| `rgba()` shadows | `elevation1/2/3()`, `elevationHairline()`, `elevationNav()` modifiers |
| Hex literals | `Color+Hex.swift` |

The `em`-based letter-spacing values are pre-multiplied by their font size so they feed
straight into `.tracking(_:)` (e.g. `-0.02em` at 36px → `-0.72`).

### Fonts

Both families are **bundled and registered at launch** (`FontLoader.swift`), so rendering does
not depend on anything installed on the device:

- **Plus Jakarta Sans** — variable font instanced to four static weights
  (Regular 400 / SemiBold 600 / Bold 700 / ExtraBold 800) with Google Fonts naming, so
  `Font.custom("PlusJakartaSans-SemiBold", …)` resolves correctly.
- **Material Symbols Outlined** — the real icon font the HTML uses
  (`<span class="material-symbols-outlined">`), subset from 6,618 glyphs to the 76 this screen
  needs, instanced to two faces for the `FILL` axis (outlined + filled).

### Icons — `DesignSystem/Icons.swift`

Material Symbols is *ligature*-based on the web, but ligatures are unreliable through Core Text.
Each icon is therefore addressed by its **Private-Use-Area codepoint, extracted from the font's
own `GSUB` ligature table** (e.g. `search` → `U+E8B6`, `eco` → `U+EA35`). This preserves exact
glyph shapes instead of approximating them with SF Symbols. SF Symbol names are kept only as a
graceful fallback if font registration ever fails.

### Logo — `DesignSystem/LogoMark.swift`

The source logo is served from a hot-link-protected CDN that returns **HTTP 403** to third-party
requests (verified against every URL variant). It is rebuilt as resolution-independent vector
shapes traced from the reference render: emerald rounded-square tile → white leaf oval →
emerald stem → amber four-point sparkle (`SparkleShape`).

### Components — `DesignSystem/Components/`

| Component | Source markup |
|---|---|
| `HeaderBar` | `<header … bg-surface/85 backdrop-blur-xl>` + `h-16 px-margin` |
| `SearchBar` | `rounded-full … focus-within:ring-2 ring-primary/20` + `w-12 h-12` filter |
| `ModeSwitcher` | `bg-surface-container p-1 rounded-full` segmented control |
| `PromoBanner` | `rounded-2xl bg-gradient-to-br from-primary via-primary to-on-primary-fixed-variant` |
| `CategoryRail` | `-mx-margin` edge-to-edge carousel, `w-16 h-16 rounded-2xl` tiles |
| `QuickFilterStrip` | `.filter-chip` toggle chips |
| `RestaurantCard` | `<article rounded-2xl shadow-sm>` + `h-44` photo + quick-add rows |
| `Badges` | `ETABadge`, `PromoBadge`, `RatingBadge`, `DeliveryMetaLine`, `SectionHeader` |
| `BottomNavBar` | `fixed bottom-0 … shadow-[0_-4px_20px]`, five `w-16` items |
| `FloatingCartBar` | DESIGN.md "Floating Cart & Checkout Bar" (Level 2 pill) |

### Behaviour — `App/AppStore.swift`

The source's loose DOM listeners are now a typed `@MainActor @Observable` store. All four
micro-interactions are ported one-for-one:

- **Delivery / pickup switcher** — active pill slides via `matchedGeometryEffect`.
- **Favourite heart** — outline ⇄ filled, secondary ⇄ error tint.
- **Quick add** — shows a check mark for **1.2 s** (`setTimeout(…, 1200)`), then reverts.
- **Filter chips** — toggle between surface and emerald fills.

Search and filters are wired to real filtering, and the cart flow (add / stepper / delete /
subtotal / free-delivery note) is fully functional.

---

## Fidelity notes

Details that are easy to get wrong and were handled deliberately:

1. **Two-level margin system.** `<main>` carries `px-margin` (20px), but the category rail and
   filter strip use `-mx-margin` to bleed back out to the screen edges. Here the 20px inset is
   applied per-section and the two rails own their own padding so they scroll edge-to-edge.
2. **`pt-16 pb-28`.** The fixed header (64) and nav (112) reserve space; the scroll view uses
   `safeAreaPadding(.top, 64)` plus a 112pt bottom inset so the last card clears the dock.
3. **Translucency.** `bg-surface/85` + `backdrop-blur-xl` becomes `.ultraThinMaterial` over a
   translucent surface tint, so content genuinely blurs behind the bars.
4. **Free-delivery emphasis.** `Envío 0,00 €` renders its truck icon in emerald while paid
   delivery stays slate — as in the source.
5. **Light-only.** The design is a light canvas, so `preferredColorScheme(.light)` and
   `UIUserInterfaceStyle = Light` are set.

---

## Project layout

```
FreshHarvest/
├── project.yml                     # XcodeGen spec (project.pbxproj is generated)
├── FreshHarvest.xcodeproj/         # generated — open this
├── tools/lint_swift.py             # cross-reference linter (see Validation)
└── FreshHarvest/
    ├── App/
    │   ├── FreshHarvestApp.swift    # @main + RootView
    │   ├── AppStore.swift           # @Observable state + intents
    │   └── FontLoader.swift         # Core Text registration
    ├── DesignSystem/
    │   ├── Color+Hex.swift  Palette.swift  Typography.swift
    │   ├── Layout.swift     Icons.swift    LogoMark.swift
    │   └── Components/              # 10 components, each with #Preview
    ├── Models/Models.swift          # value types + euro formatting
    ├── Data/SampleData.swift        # exact source content
    ├── Features/
    │   ├── Home/HomeScreen.swift    # the delivered screen
    │   ├── Home/CartSheet.swift     # Level 3 bottom sheet + stepper
    │   └── Placeholders/            # 4 remaining tabs, same design system
    └── Resources/
        ├── Assets.xcassets/         # 8 imagesets @1x/2x/3x + AccentColor/LaunchBackground/AppIcon
        ├── Fonts/                   # 4 text + 2 icon faces
        └── Info.plist               # UIAppFonts, light-only, portrait
```

---

## Validation

There is no Swift toolchain on the build machine (Linux, no iOS SDK), so two complementary
checks were run instead of `xcodebuild`:

**1. Syntax — every file parsed with the real compiler** (Swift 6.1):
```
swiftc -parse <file>   →  OK: all 24 files parse
```

**2. Cross-reference linter** (`tools/lint_swift.py`) — checks the things that actually break
in this codebase:
- every `Palette.*` / `TypeScale.*` / `Spacing.*` / `Radius.*` / `Metrics.*` / `Elevation.*` /
  `IconFont.*` / `SampleData.*` / `AppTab.*` reference resolves to a declaration;
- every `Icon(.case)` exists in `MaterialIcon`;
- every `Image("…")` and `imageName:` has a matching `.imageset`;
- every font PostScript name referenced in Swift is among the bundled faces;
- no duplicate type declarations, no unbalanced braces/parens.

```
Scanned 24 Swift files
MaterialIcon cases declared : 67
Asset imagesets found       : 8
Bundled PostScript names    : 6
No errors. Cross-references are consistent.
```

**Bugs this caught and fixed** (all would have been compile- or render-time failures):
`Icon(.chevronRight)` used but never declared · `Models.swift` using `Color`/`Palette` while
importing only `Foundation` · a corrupted `#Preview` block · main-actor isolation on the store's
deferred revert · a placeholder accessibility label in `QuantityStepper`.

**3. Bundle verification** — the generated `project.pbxproj` Resources phase was inspected to
confirm all six `.ttf` faces and both asset catalogs are copied into the app bundle, and
`Info.plist` lists all six fonts under `UIAppFonts`.

### Not yet verified
Layout has **not** been rendered — no simulator is available here. Expect minor optical tweaks
(icon nudges, banner copy width) on first run. Run the `#Preview`s or the simulator to confirm.

---

## Fidelity & licensing

- **Text, prices and ratings** are the source's own Spanish copy, transcribed exactly.
- **Photography** is downloaded from the URLs embedded in `code.html` (Google `lh3` CDN, which
  serves these `aida-public` assets with `access-control-allow-origin: *`), at the highest
  resolution offered (`=w1080`) and stored as 1x/2x/3x imagesets. These are AI-generated food
  images from the original design, not commercial stock — but they are inherited from the source
  file, so **replace them with licensed photography before shipping**.
- **The logo** is a vector reconstruction, not the original asset (see above).

---

## Remaining work

- [ ] Render in the simulator and fine-tune optical spacing.
- [ ] Supply a real `AppIcon` 1024×1024 (the set is an empty placeholder).
- [ ] Replace the inherited food photography with licensed assets.
- [ ] Flesh out the four placeholder tabs (Explorar / Pedidos / Favoritos / Perfil are wired and
      built from the design system, but are not part of the original design).
- [ ] Add a `#Preview`-driven snapshot test suite if regression coverage is wanted.

---

## Tech stack

SwiftUI · iOS 17+ · Observation (`@Observable`) · XcodeGen · Swift 6 strict concurrency
