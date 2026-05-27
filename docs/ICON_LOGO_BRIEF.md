# Life Calendar — Icon & Logo Brief

A short brief for the app icon, the wordmark, and the cases they need to cover. Sister doc to `DESIGN_BRIEF.md`; reuses its design language, vocabulary, and emotional intent.

---

## 1. What the product is, in one breath

Life Calendar paints one hundred dots on your Mac wallpaper — one per year. Filled for the years lived. Outlined for the years to come. The current year is gently marked. The first ten years grow in from nothing. The last ten fade out. It updates once a year, then disappears.

The artifact is the wallpaper. The app is the tool you open to shape it, then close. There's no menu bar item, no dock badges, no notifications.

## 2. The icon's job

The macOS app icon will live in three places that matter:

| Surface | Size | What it has to do |
|---|---|---|
| Dock | 80–128pt | Be instantly recognizable as *this* app, not generic |
| Launchpad | 88–256pt | Sit comfortably next to native Apple icons (Notes, Mail, Calendar) |
| Mac App Store / Finder previews | 512–1024pt | Carry the product's emotional intent — quiet, finite, contemplative |

It must **not** look like:
- Apple's Calendar app (red square, white number, fold). Borrow nothing from it.
- A productivity / streaks / habit-tracker app.
- A clock, hourglass, or any literal "time" symbol.
- A pie chart, progress ring, or fitness ring.

It must look like:
- A wallpaper, in miniature.
- A thing that knows you're going to die one day and doesn't apologize for it.

## 3. Visual language (locked from the app)

These come from the existing design system. The icon must sit inside this vocabulary.

| Token | Value |
|---|---|
| Backdrop · linear | top `rgb(20,18,33)` → bottom `rgb(5,5,10)` |
| Backdrop · radial highlight | center `(0.5, 0.15)`, white 8% opacity, fades to clear at ~55% |
| Ink · primary | pure white (#FFFFFF) |
| Ink · faded | white at 22% / 45% / 55% / 70% opacity |
| Accent | pure white. No system blue. No coloured highlights. |
| Type | San Francisco, **light** (300) and **ultralight** (100) weights. Tracking -0.3 to -0.5pt. |
| Corner radius | macOS standard squircle (continuous) — Apple's icon mask, not a fixed pixel value. |

The wallpaper artifact itself uses three cell states that the icon can lean on:

- **Filled** — solid white disc
- **Current** — solid disc with a soft halo ring at 60% foreground opacity, 1.45× cell size
- **Remaining** — outlined ring, 6% stroke ratio of cell diameter

## 4. Recommended icon direction

**Primary concept: a miniature wallpaper**

Make the icon the wallpaper, scaled down. The viewer sees a tiny version of what their desktop will look like after running the app.

```
┌─────────────────────────┐
│  ·  ·  ·  ·             │   row 1: faint, growing (childhood)
│                         │
│  ●  ●  ●  ●             │   row 2: solid filled dots
│                         │
│  ●  ●  ⦿  ○             │   row 3: filled, current (haloed), outlined
│                         │
│  ○  ○  ·  ·             │   row 4: outlined, then fading (unknown)
└─────────────────────────┘
```

**Specifics**:

- 4 × 4 grid of dots inside the icon's safe area (the central 70% of the squircle).
- Dot diameter ≈ 14% of the icon's edge length at 1024pt. Scales proportionally down.
- Generous spacing: dots take ~64% of cell width, gutters take the rest. (Same `iconSize` value the app defaults to.)
- **Fade-in**: the first three dots (top row) at 0.40 / 0.65 / 0.85 / 1.0 size. The smallest is barely a pinprick.
- **Fade-out**: the last three dots (bottom row) at 1.0 / 0.85 / 0.60 / 0.30 *opacity* (not size).
- **Current-year dot**: row 3, column 3. Solid white disc + a faint 60%-opacity ring at 1.45× the dot, drawn behind.
- One row of outlined rings between the filled rows and the faded-out tail.
- The background fills with the in-app vertical gradient. The radial highlight sits at the top of the icon, slightly off-center.

**Why 4 × 4 and not 10 × 10**: 100 dots become noise at icon scales. 16 dots preserve the metaphor (a grid of years), the fade curves, and the current-year accent — and stay legible all the way down to a 32pt menu-bar render if we ever need one.

## 5. Alternate directions worth exploring

If the primary feels too literal, try these:

### B. The single dot

One large filled white disc, centered, with the halo ring at 1.45×. The mark of "now". Strong, abstract, immediately ownable. **Risk**: doesn't say *calendar*. Use this only if the wordmark always travels alongside.

### C. The fade arc

A single horizontal row of dots, left to right: tiny → tiny → growing → full → full → full → outlined → outlined → fading → fading. Reads as a life-timeline. **Risk**: looks like a slider, a loading bar, or a progress indicator. Avoid unless you're confident the spacing breaks that pattern.

### D. Pencil-mark grid

The grid drawn as if by a draftsman — hairline strokes only, no fills, with a single dot solidly inked at the current-year position. **Risk**: doesn't read as filled-versus-empty at small sizes.

The team's default if there's no time to explore: **A (the miniature wallpaper)**.

## 6. Iconography requirements (Apple)

For macOS submission:

| Size | Notes |
|---|---|
| 1024 × 1024 | Marketing master. PNG, sRGB, no embedded mask — Apple applies the squircle. |
| 512 × 512, 256 × 256, 128 × 128, 64 × 64, 32 × 32, 16 × 16 | Asset catalog renditions. Test the 32 and 16 specifically — the fade-in and current-year halo will become single pixels. Hand-tune. |
| Dark / Tinted | macOS 14+ supports user-tinted icons. The white-on-dark style here tints cleanly to monochrome out of the box. |

**Safe area**: keep the dot grid inside the inner ~70% of the icon canvas; macOS rounds and inset-scales these in different contexts.

**Format**: Apple Asset Catalog. Provide an `Assets.xcassets/AppIcon.appiconset` with the renditions above and the `Contents.json` template Xcode generates. Optional but nice: a vector PDF master for the App Store Connect upload.

## 7. Wordmark / logo

The wordmark is the **type-only** treatment of the product name. It appears in:

- The macOS "About" panel
- The landing-page hero, when there is one
- Documentation, README
- Any future merchandise / press

### 7.1 Recommended treatment

```
Life Calendar
```

- **Typeface**: San Francisco (use SF Pro Display at headline sizes; SF Pro Text at body)
- **Weight**: ultralight (100) at large sizes, light (300) at small sizes
- **Tracking**: -0.5pt at 64pt+, -0.3pt at 32pt, 0 at body
- **Case**: title case as written; "Life" and "Calendar" both capitalized
- **Color**: pure white on the in-app gradient. Pure black `#0a0a0a` on warm cream for printed surfaces.
- **No tagline.** "Life Calendar" stands alone. If a tagline is unavoidable, use *"One dot per year."* in 11pt regular at 55% opacity, placed below on a separate line.

### 7.2 Lockups

Two lockups should exist:

1. **Mark + wordmark, horizontal** — icon on the left, wordmark to the right. Vertical center aligned. Icon height = wordmark cap-height × 1.6. Gap between = wordmark cap-height × 0.6.
2. **Wordmark only** — when the icon would compete (e.g. inside the icon itself's About panel).

A stacked lockup (icon above, wordmark below) is **not** recommended; the product name is two words and reads better wide.

### 7.3 Forbidden combinations

- Do not combine the wordmark with an Apple Calendar–style red.
- Do not set the wordmark in a serif, monospace, condensed, or italic style.
- Do not stretch, skew, outline, drop-shadow, emboss, or rainbow-fill.
- Do not animate the wordmark for promotional use; let the dots animate, not the type.

## 8. Color palettes

### Light / on-dark (canonical, in-app)

| Role | Value |
|---|---|
| Background | linear `rgb(20,18,33) → rgb(5,5,10)` |
| Ink | white #FFFFFF |
| Faded ink | white at 22% / 45% / 55% |
| Highlight | radial white 8% top-center |

### Print / cream (for documentation, packaging, About copy)

| Role | Value |
|---|---|
| Background | `#F0EEE9` (matches the design canvas) |
| Ink | `#0a0a0a` near-black |
| Faded ink | black at 35% / 55% |
| Accent | none — the dots themselves carry the meaning |

### Tinted (macOS dark/tinted icon mode)

Provide a single monochrome layer. The icon's existing white-on-dark composition tints cleanly; no additional work required for this mode.

## 9. Tone of voice (so the designer knows what *feels* right)

- "It already happened." Not "it could happen."
- "How much remains." Not "what's next."
- "Quiet." Not "calm."
- "Finite." Not "limited."
- "Personal." Not "user-centric."

The icon and wordmark should both feel like they belong on the home screen of someone who reads slowly.

## 10. Deliverables checklist

- [ ] `AppIcon.appiconset` with 16/32/64/128/256/512/1024 renditions, sRGB, no rounded mask
- [ ] PDF vector master of the icon at 1024pt
- [ ] PNG @1x and @2x of the **mark + wordmark horizontal lockup** at 64pt, 128pt, 256pt heights
- [ ] PNG @1x and @2x of the **wordmark only** at the same heights
- [ ] SVG of both lockups (for the README and any future web surface)
- [ ] One paragraph of usage notes — minimum clear-space, minimum size, do-not-do list

## 11. Reference

- `docs/DESIGN_BRIEF.md` — the full app design brief. Section 4 has typography, color, motion. Section 5 has the wallpaper grid spec.
- `Sources/LifeCalendar/Views/LifeGridView.swift` — the canonical rendering. The icon is its 4 × 4 cousin.
- The in-app live preview behind the setup panel is the truest existing depiction of what the icon should look like, in miniature.
