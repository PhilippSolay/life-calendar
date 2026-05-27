# Life Calendar — Design Brief

A reference document for visual design of a native macOS app that turns the desktop wallpaper into a calendar of one human life. Written for designers (and design agents) who need to produce mockups, polish, and new screens that fit the established system.

---

## 1. Product in one breath

Life Calendar paints 100 dots on your desktop wallpaper — one per year. Filled for the years you have lived. Outlined for the years to come. The current year is marked. The first ten years grow in from nothing (childhood, barely remembered). The last ten fade out (the unknown ahead). It updates once a year on its own.

The artifact is the wallpaper. The app is the tool you use to shape that wallpaper, then close.

## 2. Emotional intent

- **Quiet.** Not motivational. Not productivity-flavored. No streaks, no goals, no celebrations.
- **Honest.** A factual visualization of finite time. The fade is the point.
- **Premium.** Feels expensive. Feels like Apple made it. Glass, restraint, white-on-near-black.
- **Personal.** Sits on *your* desktop with *your* image showing through *your* rings.

Words to avoid in copy and visual treatment: *journey, milestones, achievements, productivity, goals, reminders, motivation, dashboard*.

Words that fit: *life, time, year, decade, lived, remaining, anchor, calendar*.

## 3. Platform and constraints

- **macOS 26 (Tahoe).** Liquid Glass is the design system — `glassEffect`, `glassButtonStyle`, `GlassEffectContainer` are first-class. Do not invent custom glass shaders.
- **Native window chrome only.** No custom title bars. Onboarding hides the traffic-light controls; Settings shows them.
- **Single SwiftUI `Window` scene.** One window at a time. Content swaps between onboarding and settings based on `hasOnboarded`.
- **Dock app, not menu bar.** The app is launched, configured, and closed. A `LaunchAgent` runs the headless wallpaper renderer on a schedule.
- **No notifications, no badges, no haptics (irrelevant on Mac).** The artifact speaks for itself.

## 4. Design system

### 4.1 Materials

Liquid Glass is used as the **container language** — every interactive surface that isn't the wallpaper preview is a glass card or glass button. Glass sits over a dark gradient backdrop so the refraction has something to refract.

| Surface | Treatment | Radius |
|---|---|---|
| Step container card | `.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))` | 22–24 |
| Inline control card (column / matrix / stat block) | `.glassCard(cornerRadius: 18)` | 18 |
| Date picker card on Birthdate step | `.glassCard(cornerRadius: 32)` | 32 — larger because the calendar is the only content |
| Primary CTA | `.buttonStyle(.glassProminent)` `.controlSize(.extraLarge)` | system capsule |
| Secondary action | `.buttonStyle(.glass)` `.controlSize(.extraLarge)` for footers, `.small` inline | system capsule |
| Footer button cluster | wrapped in `GlassEffectContainer(spacing: 12)` so they morph | — |

### 4.2 Backdrop

Two layers, always present behind glass:

```
LinearGradient(
    top    rgb(0.08, 0.07, 0.13)   -- deep aubergine
    bottom rgb(0.02, 0.02, 0.04)   -- near-black
)
+ RadialGradient(
    center (0.5, 0.15)
    color  white at 8% opacity
    radius 500pt
)
```

The radial sits high so the top of the window has a faint atmospheric highlight that glass picks up. Settings nudges the radial off-center (`(0.2, 0.1)`) so the form sidebar feels lit from above-left.

### 4.3 Typography

System font (San Francisco). All weights are deliberately light or regular — no bold anywhere.

| Role | Size | Weight | Tracking | Color |
|---|---|---|---|---|
| Step title | 36 | `.light` | -0.3 | white 100% |
| Section label (small caps) | caption2 (~11) | `.regular` | 0.8 | white 50% |
| Inline label | 12–13 | `.regular` | 0 | white 70% |
| Value (column card) | 26 | `.light` | 0 | white 100% |
| Value (inline row) | 13 | `.light` | 0 | white 95% |
| Stat block value | 36 | `.light` | 0 | white 100% |
| Stat block caption | caption (~12) | `.regular` | 0 | white 55% |
| Body / subtitle | 13 | `.regular` | 0 | white 55% |
| Helper / disabled hint | caption2 (~11) | `.regular` | 0 | white 45% |
| Filename strings | 11 | `.regular` | 0 | white 55% |

All numeric values use `.monospacedDigit()` so they don't shift while incrementing.

### 4.4 Color

The palette is intentionally tiny:

- **Backdrop**: see §4.2.
- **Ink**: white at percentile opacities — 100, 95, 70, 65, 55, 50, 45, 22, 18, 15, 12, 8.
- **Accent (selection / tint)**: pure `Color.white`. Never use system blue.
- **User palette**: the user picks their own background color and dot color for the wallpaper output. Inside the app UI, treat those colors as content, not chrome.
- **Destructive**: none. There is no destructive action in this app worth a red treatment.

### 4.5 Spacing

| Token | Value |
|---|---|
| Window outer padding | 36pt top, 28pt bottom, 44pt sides (onboarding) / 20pt (settings) |
| Card padding | 20–24pt |
| Section spacing inside a card | 18–22pt |
| Inline row spacing | 6–12pt |
| Inter-card spacing | 16–24pt |
| Capsule pill height | 6pt — for the progress indicator |

### 4.6 Motion

- **Step transitions**: `withAnimation(.smooth(duration: 0.3))` on Continue/Back. Glass cards and buttons re-flow.
- **Progress capsule resize**: `spring(response: 0.5, dampingFraction: 0.75)` — the active pill stretches from 8pt to 36pt wide.
- **Anchor matrix dot selection**: `spring(response: 0.3, dampingFraction: 0.7)` — the chosen dot grows from 7pt to 10pt.
- **No bouncy or overshoot easing**. Nothing should feel playful.
- **No micro-illustrations.** The interface is content-only.

### 4.7 Iconography

The app deliberately uses **no decorative iconography in onboarding step headers** — the title carries the meaning. SF Symbols appear only in three places:

- The "Use current wallpaper" button — `photo.on.rectangle`
- The image-picker "remove" button — `xmark`
- The system file-picker dialog (out of our control)

Reach for symbols only when they replace literal language. If a label reads naturally, skip the icon.

---

## 5. The wallpaper artifact

The wallpaper is the thing the app produces. It is rendered as a PNG per `NSScreen`, at native resolution × `backingScaleFactor`, then set via `NSWorkspace.setDesktopImageURL(_:for:options:)`.

### 5.1 Layout

- A grid of `columns × rows` cells. Default 10 × 10 = 100 years. Configurable: total years 40–130, columns 4–24, rows derived.
- Cell size: `min(canvasW / columns, canvasH / rows) × gridScale`. The grid is positioned by `gridAnchor` (one of nine) with optional `sidePadding` (0–20% of canvas) when not centered.
- Each cell holds a circle with diameter = `cellSize × (1 − 2 × cellPadding) × sizeScale(year)`. `cellPadding` is 0.18 internal (per-cell margin); `sizeScale(year)` is the fade-in curve (see §5.3).

### 5.2 Cell states

| State | Years | Default rendering | When `dotImage` is set | When `backgroundImageMode == .ringOutlines` |
|---|---|---|---|---|
| Lived | `year < yearsLived` | Filled disc in foreground color | Filled disc clipped from `dotImage` | Same as default |
| Current | `year == yearsLived` | Filled disc + faint outer halo ring | Image-clipped disc + halo ring | Image-clipped disc + halo ring |
| Remaining | `year > yearsLived` | Outlined ring in foreground color | Outlined ring in foreground color | **Ring stroke is image-clipped** (foreground color stroke is suppressed) |

The current-year halo is a stroke at `60%` foreground opacity, `1.2 × strokeRatio` line width, sized at `1.45 ×` the dot.

### 5.3 Fade curves

Two independent smoothstep curves applied to opacity and size:

- **`fadeInYears`** (default 10): cells `0..<fadeInYears` have `sizeScale` ramping from `minScale` (default 0.08) → 1.0, smoothstep-eased.
- **`fadeOutYears`** (default 10): cells `(totalYears - fadeOutYears)..<totalYears` have `opacity` ramping from 1.0 → `minOpacity` (default 0.12), smoothstep-eased.

The curves multiply through the cell's individual opacity, then through the global `gridOpacity` multiplier (0.0–1.0).

### 5.4 Background image modes

The user's chosen image can occupy one of three positions on the wallpaper, picked via a segmented control:

- **Fill wallpaper** — image covers the canvas behind everything else. Default.
- **Inside the rings** — image is masked to the disk of each *remaining-year* ring. Everywhere else is the solid background color. The outlined rings appear as little portholes.
- **On ring outlines** — image is masked to the stroke path of each *remaining-year* ring. Replaces the foreground-color outline. The interiors are background color.

### 5.5 Dot image

If the user supplies a separate "dot image", the *lived* and *current* cells are masked from that image instead of filled with foreground color. This is independent of background image mode. The two image features compose freely.

### 5.6 Grid anchor + padding

Nine anchor positions in a 3 × 3 matrix. Center is default. When the anchor is anything other than center, a `sidePadding` slider becomes meaningful (0–20% of the canvas width/height, depending on which edge is anchored). Padding has no visible effect when centered, so the slider is hidden with an explanatory caption.

### 5.7 Multi-display

Each connected `NSScreen` gets its own PNG at that screen's native resolution. The grid relative to each screen uses the same anchor/padding settings but scales to that screen's dimensions.

---

## 6. Screens

### 6.1 Window dimensions and chrome

| Window | Size | Resizable | Title bar | Traffic lights |
|---|---|---|---|---|
| Onboarding | 920 × 920 (square, fixed) | No | Transparent, hidden | **Hidden** via `WindowConfigurator` |
| Settings | min 1000 × 680, resizable | Yes | Transparent, hidden | Visible |

Both windows: `titlebarAppearsTransparent = true`, `styleMask.insert(.fullSizeContentView)`, `backgroundColor = .clear`. The dark gradient lives inside the SwiftUI content and bleeds to the window edges.

### 6.2 Onboarding shell

A vertical stack inside every onboarding step:

```
┌─────────────────────────────────────┐
│  · 36pt top spacer                  │
│                                     │
│  Step title (36pt light)            │
│  Step subtitle (13pt 55% white)     │
│                                     │
│  · 28pt                             │
│                                     │
│  ─── step content (flex) ───        │
│                                     │
│  · 24pt                             │
│  · · · · ●         (progress)       │
│  · 18pt                             │
│                                     │
│  [ Back ]            [ Continue ]   │
│  · 28pt bottom                      │
└─────────────────────────────────────┘
```

- **Header**: title + subtitle, centered, max subtitle width 580pt. **No icon.** Pure type.
- **Step content**: flexible region between header and progress indicator.
- **Progress indicator**: row of capsules, 8pt wide × 6pt tall, with the active step at 36pt wide. White 100% for active, white 50% for completed, white 15% for future. Spring animation.
- **Footer**: `GlassEffectContainer` with `Back` (omitted on step 1) on the left and `Continue` (or `Save & set wallpaper` on step 5) on the right.

The five steps in order:

#### Step 1 — Birthdate

- **Title**: "When were you born?"
- **Subtitle**: "Every dot in your calendar is anchored to this date."
- **Content**: a single centered glass card (radius 32, 60pt padding) holding a `.graphical` `DatePicker` at `scaleEffect(1.7)`. Forced dark color scheme, white tint. Frame after scale: 544 × 476pt.
- **Validation**: birthdate is constrained to `...Date()`. No empty state — defaults to 30 years ago.

#### Step 2 — Lifespan

- **Title**: "Your lifespan"
- **Subtitle**: "How many years should the grid hold, and how should the edges fade?"
- **Content**: vertical stack.
  - Top: a **borderless, transparent-background** preview of the grid (just dots floating on the backdrop, max 540 × 320pt, 16:10 aspect, white dots regardless of user color choice — colors come in step 4).
  - Bottom: a row of **four equal-width column cards** (`.glassCard(cornerRadius: 18)`). Each column has, vertically stacked:
    - Section label (caption2, uppercased, tracking 0.8, 50% white): `TOTAL YEARS` / `COLUMNS` / `GROW FIRST` / `FADE LAST`
    - Value (26pt light, monospaced digit): `100`, `10`, `20 yrs`, `20 yrs`
    - Small stepper

Ranges: total years 40–130 (step 1), columns 4–24, grow first 0–30, fade last 0–30.

#### Step 3 — Layout

- **Title**: "Layout"
- **Subtitle**: "Where should the grid sit on your wallpaper?"
- **Content**: vertical stack.
  - Top: full preview (max 360pt tall, 16:10 aspect) — this preview is **not** transparent; it uses the current background color and image so the user can see where the grid will sit on the actual wallpaper.
  - Bottom: a row of **three glass cards** (radius 18, 20pt padding):
    - **Size** card: section label + slider (30–100%) + percentage caption
    - **Position** card: section label + the 9-dot anchor matrix
    - **Side padding** card: section label + either a slider with percentage *or* the disabled caption "No effect when centered."

The anchor matrix is a 132 × 84pt rounded rectangle (radius 8, 18% white stroke, 1pt) framing a 3 × 3 grid of clickable dots. Selected dot is solid white at 10pt; unselected dots are 22% white at 7pt. Spring grow on selection.

#### Step 4 — Look

- **Title**: "Make it yours"
- **Subtitle**: "Background, dots, and how much the grid stands out."
- **Content**: horizontal split.
  - Left (320pt wide, glass card radius 22, 20pt padding) — controls list:
    - `BACKGROUND` section label
    - Inline row: `Color` label + color well
    - Image controls: either `[ Choose image… ]` button, or a row showing `filename · [Replace] [×]`
    - `[ Use current wallpaper ]` glass button with `photo.on.rectangle` symbol
    - Segmented `Picker` for background image mode (visible only when an image is set): `Fill wallpaper / Inside the rings / On ring outlines`
    - Slim divider (1pt white 8%)
    - `DOTS` section label
    - Inline row: `Color` label + color well
    - Image controls for the dot image (Choose / Replace / ×)
    - Slim divider
    - Inline labeled slider: `Grid opacity` + percentage caption + slider (0–100%)
  - Right: live preview (16:10 aspect, fills remaining width, no border, no shadow, no clip overlay).

#### Step 5 — Save

- **Title**: "Ready"
- **Subtitle**: "Set your wallpaper now. Everything stays editable from the menu bar."  *(Note: edit this string to "from the app" — the app is no longer a menu-bar app.)*
- **Content**: vertical stack.
  - A row of **three stat cards** (each is a glass card radius 18, equal-width, 16pt vertical padding):
    - `42` / years lived
    - `58` / years remaining
    - `42%` / of 100
  - Full live preview below.
- **Primary button**: `Save & set wallpaper` (`.glassProminent`, `controlSize(.extraLarge)`, `.keyboardShortcut(.defaultAction)`).

### 6.3 Settings window

The persistent configuration panel shown after onboarding. Same backdrop, but split horizontally:

```
┌─ Settings (≥1000 × 680) ─────────────────────────────┐
│ ┌───────────────────┐  ┌───────────────────────────┐ │
│ │ Glass card 360pt  │  │ Live wallpaper preview    │ │
│ │ scrollable form   │  │ (no border, fills rest)   │ │
│ │                   │  │                           │ │
│ │ Birthdate         │  │                           │ │
│ │ Grid capacity     │  │                           │ │
│ │ Fade              │  │                           │ │
│ │ Background        │  │                           │ │
│ │ Dots              │  │                           │ │
│ │ Layout            │  │                           │ │
│ │ Grid opacity      │  │                           │ │
│ │ Schedule          │  │                           │ │
│ │                   │  │                           │ │
│ │ [ Update now ]    │  │                           │ │
│ └───────────────────┘  └───────────────────────────┘ │
└──────────────────────────────────────────────────────┘
```

Sections (each starts with an uppercase caption2 label):

1. **Birthdate** — DatePicker.
2. **Grid capacity** — slim steppers for total years, columns. Derived rows count as a caption underneath.
3. **Fade** — slim steppers for grow-first and fade-last; sliders for min scale (0.0–0.5) and min opacity (0.0–0.5).
4. **Background** — color well; image controls (Choose / Replace + ×); "Use current wallpaper" glass button; mode segmented picker when image set.
5. **Dots** — color well; image controls; "Highlight current year" toggle.
6. **Layout** — size slider; "Position" caption + anchor matrix; side-padding slider (or "no effect when centered" caption).
7. **Grid opacity** — slider.
8. **Schedule** — toggle "Auto-update at login and daily"; live status text underneath:
   - `enabled` → "Running. Refreshes at login and at 3:00 AM daily."
   - `requiresApproval` → "Waiting for approval in System Settings → Login Items." + a glass button "Open Login Items in System Settings…"
   - `notRegistered` → "Not installed. The wallpaper only updates while the app is open."
   - `notFound` → "Schedule plist missing from app bundle."

Bottom of the form: a full-width **`Update wallpaper now`** glass-prominent button (`controlSize(.large)`).

The preview pane on the right re-renders live as every control updates — no apply step needed inside the app.

### 6.4 The wallpaper itself

This is what the user sees most of the time. Designers should treat it as **the main artifact** and the in-app surfaces as supporting infrastructure.

Three variants worth mocking against a real macOS desktop screenshot (dock + menu bar visible at small contrast to ground the design):

1. **Pure dots, dark background.** Default settings: black wallpaper, white dots, centered, 100% scale, fade-in 10 / fade-out 10. The canonical reference.
2. **Photo background, dots on top.** A landscape photo with a 100-dot grid sitting on it. Use this to show that the dots are subtle enough to coexist with a real wallpaper, but visible enough to register the metaphor.
3. **Photo "inside the rings".** Solid background color (e.g. `#0a0a0a`), 60 lived dots filled white, 40 remaining dots showing portholes onto a landscape photo. This is the most surprising mode and worth showing prominently.

---

## 7. Components

### 7.1 Glass card

```
View
  .padding(20)
  .glassCard(cornerRadius: 22)          // .glassEffect(.regular, in: continuous RoundedRect)
```

Three sizes you will use repeatedly:

- **Container card** — radius 22–24, holds an entire step's controls or one column.
- **Inline card** — radius 18, holds a single control (column, anchor matrix, stat block).
- **Date card** — radius 32, holds the calendar.

### 7.2 Buttons

| Use | Style | Size |
|---|---|---|
| Primary footer (Continue / Save) | `.glassProminent` | `.extraLarge` |
| Secondary footer (Back) | `.glass` | `.extraLarge` |
| Inline secondary (Replace, Remove, Choose image, Use current wallpaper) | `.glass` | `.small` |
| Settings apply-now CTA | `.glassProminent` | `.large` |
| Schedule helper (Open Login Items) | `.glass` | `.small` |

Wrap the footer pair in `GlassEffectContainer(spacing: 12)` so the two buttons share the glass field and morph during step transitions.

### 7.3 Progress capsule indicator

A horizontal row of `Capsule()` shapes, 6pt tall:

- Active: 36pt wide, white 100%
- Completed: 8pt wide, white 50%
- Future: 8pt wide, white 15%
- Spring animation on resize

### 7.4 Section label

```
Text(string.uppercased())
  .font(.caption2)
  .tracking(0.8)
  .foregroundStyle(.white.opacity(0.5))
```

Always uppercase, always tracked. Used everywhere a group needs a quiet heading.

### 7.5 Inline labeled row

`HStack`: label on the left (12–13pt, 70% white), `Spacer()`, control on the right. Used for color rows and any single-value control.

### 7.6 Slim stepper

For the Settings sidebar's compact rows:

```
HStack {
  Text(label)        — 12pt, 70% white
  Spacer()
  Text(value)        — 13pt light, monospaced, 95% white
  Stepper("", …)     — labelsHidden, controlSize(.small)
}
```

### 7.7 Column stepper card (Lifespan step)

A vertical card variant of the above:

```
VStack(spacing: 8) {
  Text(LABEL.uppercased())   — caption2, tracking 0.8, 50% white
  Text("\(value)\(suffix)")  — 26pt light, monospaced, 100% white
  Stepper("", …)             — small
}
.padding(.vertical, 16)
.glassCard(cornerRadius: 18)
```

### 7.8 Image controls

Two visual states, swap based on whether an image is selected:

- **Empty**: a single `[ Choose image… ]` glass button.
- **Set**: `HStack { filename (truncated middle) · Spacer · [Replace] · [×] }` — filename is 11pt white 55%, both buttons are glass small. The × button uses an `xmark` SF Symbol at 10pt semibold.

### 7.9 Anchor matrix

A 132 × 84pt rounded-rect frame (radius 8, 18% white stroke at 1pt) containing a 3 × 3 grid of dots:

- Each cell is a transparent button with a `contentShape(Rectangle())` (so the whole cell area is clickable).
- The dot inside scales between 7pt (unselected, 22% white) and 10pt (selected, 100% white).
- Spring animation on selection.

### 7.10 Stat block

Used only on the Save step:

```
VStack(spacing: 4) {
  Text(value)    — 36pt light, monospaced
  Text(caption)  — caption, 55% white
}
.padding(.vertical, 16)
.frame(maxWidth: .infinity)
.glassCard(cornerRadius: 18)
```

Always rendered as a row of three, equal widths.

### 7.11 Slider

System slider with `.tint(.white)`. Almost always paired with a small percentage caption underneath (caption2, 55% white). Use `.controlSize(.small)` inside compact sidebars.

### 7.12 Color well

`ColorPicker("", selection: …, supportsOpacity: false).labelsHidden()`. The user picks freely. We never constrain to a palette. Hex is the persistence format.

---

## 8. Flows

### 8.1 First launch

1. User opens `Life Calendar.app` from the dock.
2. The single `Window` scene materializes at 920 × 920. Traffic lights are hidden.
3. `hasOnboarded` is false → `RootView` shows `OnboardingView` at step 1 (Birthdate).
4. User progresses through steps 1 → 5 with `Continue`. Each step animates with `smooth(0.3)`.
5. On step 5, `Save & set wallpaper`:
   - Sets `hasOnboarded = true`.
   - Calls `WallpaperApply.apply(using: settings)` — renders + sets the wallpaper synchronously.
   - Calls `ScheduleService.shared.install()` — registers the LaunchAgent. macOS may prompt for approval in Login Items.
   - Dismisses the window. The window content swaps to `SettingsView` (and shows traffic lights) the next time the user opens the app.

### 8.2 Returning launch

1. User opens the app. `hasOnboarded` is true → `RootView` shows `SettingsView`.
2. User adjusts settings. The live preview updates immediately. No apply is needed unless they explicitly hit `Update wallpaper now`.
3. User closes the window. App quits (`applicationShouldTerminateAfterLastWindowClosed`). The LaunchAgent keeps the wallpaper fresh.

### 8.3 Headless (LaunchAgent)

1. macOS triggers the agent at login or 03:00 daily.
2. The binary launches with `--apply`, no UI, no dock icon.
3. `ApplyMode.run()` reads `Settings.shared` from UserDefaults, renders, sets wallpaper, exits in <1s.
4. The user sees nothing — only the wallpaper has changed.

### 8.4 Schedule states

Designers should treat the Schedule toggle as having four possible states and account for each in mockups:

- **Enabled** (default after onboarding): toggle on, green-equivalent status text.
- **Requires approval**: toggle on, orange-equivalent status text + the "Open Login Items" button.
- **Not installed**: toggle off, neutral status text explaining the consequence.
- **Not found** (broken bundle): toggle off, red-equivalent status text. Should be rare.

Because the palette is monochrome white, "green / orange / red" here mean **content density**, not color. Status text varies in opacity (55% / 75% / 95%) but stays white. The status of the toggle itself carries the affordance.

---

## 9. Copy

All copy is short, plainspoken, and lowercase-by-default except for proper nouns and step titles. Verbatim strings currently in the app:

**Titles**

- "When were you born?"
- "Your lifespan"
- "Layout"
- "Make it yours"
- "Ready"

**Subtitles**

- "Every dot in your calendar is anchored to this date."
- "How many years should the grid hold, and how should the edges fade?"
- "Where should the grid sit on your wallpaper?"
- "Background, dots, and how much the grid stands out."
- "Set your wallpaper now. Everything stays editable from the menu bar." *(needs revision: replace "from the menu bar" with "from the app".)*

**Buttons**

- `Continue`, `Back`, `Save & set wallpaper`
- `Choose image…`, `Replace`, `Use current wallpaper`
- `Update wallpaper now`, `Open Login Items in System Settings…`

**Section labels (always uppercase)**

- `BIRTHDATE`, `GRID CAPACITY`, `FADE`, `BACKGROUND`, `DOTS`, `LAYOUT`, `GRID OPACITY`, `SCHEDULE`
- Within steps: `TOTAL YEARS`, `COLUMNS`, `GROW FIRST`, `FADE LAST`, `SIZE`, `POSITION`, `SIDE PADDING`, `COLOR`

**Stat captions**

- `years lived`, `years remaining`, `of 100` (literal "of {totalYears}")

---

## 10. Design opportunities (open invitations)

Areas where the app's current design is honest but not yet polished. A designer is welcome to redesign these — they are not "done."

1. **Empty / pre-onboarding state for the wallpaper.** Today the LaunchAgent silently does nothing until `hasOnboarded` is true. Is there a graceful "we set a default" wallpaper for users who install but never open?
2. **Schedule approval prompt UX.** macOS's Login Items approval is jarring. A pre-state "we'll ask the system next" interstitial could soften it.
3. **Multi-display preview.** Today the preview shows a single 16:10 frame. Users with multiple monitors may want to see each one previewed.
4. **Monthly mode (planned).** A 12 × N layout for users who want month-level granularity. Needs its own anchor and fade rules; the column-card metaphor probably extends.
5. **Birthday transition moment.** When the year increments, the wallpaper changes by one dot. There may be space for a small in-app moment (only when the user opens the app on or near their birthday) — never a notification, never push, but a quiet welcome.
6. **Anchor matrix iconography.** Currently nine dots inside a framed rectangle. A designer might prefer a 3 × 3 array of mini-grid thumbnails that each preview the actual position.
7. **Onboarding step transitions.** Currently a 0.3s smooth fade. There may be room for a subtle horizontal slide between steps that doesn't compete with the glass-morphing footer.
8. **Settings rhythm.** The sidebar is currently a single scrolling stack. A two-column layout, or collapsible sections, could improve scannability for users who only want to change one thing.
9. **Dark / light split.** Today the app is dark-only and the wallpaper output respects the user's chosen colors. Should the in-app UI follow the system appearance? The wallpaper artifact probably shouldn't.

---

## 11. Reference files

The codebase is the canonical source for any pixel value or behavior implied above:

| Concern | File |
|---|---|
| Settings model, enums, defaults | `Sources/LifeCalendar/Models/Settings.swift` |
| Grid math (cells, fades) | `Sources/LifeCalendar/Models/LifeProgress.swift` |
| Hex ↔ Color | `Sources/LifeCalendar/Models/Color+Hex.swift` |
| The wallpaper render | `Sources/LifeCalendar/Views/LifeGridView.swift` |
| Onboarding shell + steps | `Sources/LifeCalendar/Views/OnboardingView.swift` |
| Settings window | `Sources/LifeCalendar/Views/SettingsView.swift` |
| Glass helpers | `Sources/LifeCalendar/Views/View+Glass.swift` |
| Traffic-light toggle | `Sources/LifeCalendar/Views/WindowConfigurator.swift` |
| Wallpaper PNG render | `Sources/LifeCalendar/Services/WallpaperRenderer.swift` |
| Wallpaper set-per-screen | `Sources/LifeCalendar/Services/WallpaperSetter.swift` |
| Headless `--apply` | `Sources/LifeCalendar/Services/ApplyMode.swift`, `main.swift` |
| LaunchAgent registration | `Sources/LifeCalendar/Services/ScheduleService.swift`, `Resources/com.philippsolay.LifeCalendar.plist` |
