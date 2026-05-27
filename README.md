# Life Calendar

A native macOS app that turns your desktop wallpaper into a calendar of your life. One dot per year — filled for the years you've lived, outlined for the years to come. A quiet, daily reminder of how much time you have.

![Mockup](docs/preview.png)

## Why

We tend to measure life in days and weeks. Seeing all of it laid out as a grid on your desktop changes the scale. The first ten years grow in from nothing (the years you can barely remember). The last ten fade out (the unknown ahead). The dot for this year sits in the middle, marked.

## Features

- **Yearly grid** — 100 dots by default, configurable from 40 to 130 years and 4 to 24 columns.
- **Lived / current / remaining** — solid dots for years lived, an emphasis ring on the current year, outlined dots for years to come.
- **Fade curves** — the first N years grow in by size; the last N fade out by opacity. Smoothstep-eased, configurable.
- **Background image** — pick any image; choose whether it fills the wallpaper, masks to the inside of each remaining-year ring, or only paints the ring outline itself.
- **Dot image** — give the filled dots their own image. The image is masked to each circle, so the dots become little windows.
- **Multi-display** — renders at each connected screen's native resolution and applies per `NSScreen`.
- **Headless background updates** — a `LaunchAgent` runs the binary with `--apply` at login and at 03:00 daily. The wallpaper stays current without keeping the app open.
- **Liquid Glass UI** — onboarding, settings, and every panel built with macOS 26's glass design system.

## How it works

The `.app` is purely a configuration tool. You launch it when you want to change something; you close it when you're done. The actual wallpaper updates are handled by a tiny headless mode of the same binary:

```
LifeCalendar              # launches the SwiftUI config app
LifeCalendar --apply      # reads UserDefaults, renders, sets wallpaper, exits
```

A `LaunchAgent` plist shipped inside the bundle (`Contents/Library/LaunchAgents/com.philippsolay.LifeCalendar.plist`) registers via `SMAppService` and invokes `--apply` on the right schedule. Toggle it on/off from the Schedule section in Settings.

## Requirements

- macOS 26 (Tahoe) or later
- Xcode 26 / Swift 6.2 to build

## Build

```bash
./build.sh
open "build/Life Calendar.app"
```

The script runs `swift build -c release` against the full Xcode toolchain, wraps the binary in a `.app` bundle with the right `Info.plist`, drops the LaunchAgent plist into `Contents/Library/LaunchAgents/`, and ad-hoc signs.

For real use, drag `build/Life Calendar.app` to `/Applications` (so the LaunchAgent's path stays stable across app rebuilds).

## Architecture

```
Sources/LifeCalendar/
├── main.swift                    # entry: --apply branch vs SwiftUI app
├── LifeCalendarApp.swift         # App scene, AppDelegate, RootView
├── Models/
│   ├── LifeProgress.swift        # birthdate → cells (state, scale, opacity)
│   ├── Settings.swift            # @MainActor ObservableObject, UserDefaults-backed
│   └── Color+Hex.swift           # hex ↔ Color
├── Views/
│   ├── LifeGridView.swift        # the centerpiece visual — pure SwiftUI
│   ├── OnboardingView.swift      # 4-step glass flow
│   ├── SettingsView.swift        # glass sidebar + live preview + schedule toggle
│   └── View+Glass.swift          # .glassCard / .glassCircle helpers
└── Services/
    ├── WallpaperRenderer.swift   # SwiftUI → PNG via ImageRenderer
    ├── WallpaperSetter.swift     # per-NSScreen, native resolution
    ├── WallpaperApply.swift      # shared helper: render + set
    ├── ApplyMode.swift           # headless --apply entry (guards on hasOnboarded)
    └── ScheduleService.swift     # SMAppService wrapper for the LaunchAgent
```

The grid is a pure function of `(birthdate, totalYears, columns, fadeInYears, fadeOutYears) → cells`. The same `LifeGridView` drives the onboarding preview, the settings preview, and the rasterized wallpaper PNG written by `--apply`.

## License

MIT
