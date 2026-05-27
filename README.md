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
- **Multi-display** — renders at each connected screen's native resolution and applies per `NSScreen`.
- **Menu-bar app** — lives quietly in the menu bar (`LSUIElement`). Refreshes daily, on wake-from-sleep, and on screen-parameter changes.
- **Liquid Glass UI** — onboarding, settings, and menu-bar popover all built with macOS 26's glass design system.

## Requirements

- macOS 26 (Tahoe) or later
- Xcode 26 / Swift 6.2

The full Xcode toolchain is required; Command Line Tools alone won't link the SwiftPM manifest on macOS 26.

## Build

```bash
./build.sh
open "build/Life Calendar.app"
```

The script runs `swift build -c release` against the Xcode toolchain (auto-detected via `DEVELOPER_DIR`), wraps the binary in a `.app` bundle with the right `Info.plist`, and ad-hoc signs it.

## Architecture

```
Sources/LifeCalendar/
├── LifeCalendarApp.swift         # @main, MenuBarExtra, WindowManager
├── Models/
│   ├── LifeProgress.swift        # birthdate → cells (state, scale, opacity)
│   ├── Settings.swift            # @MainActor ObservableObject, UserDefaults-backed
│   └── Color+Hex.swift           # hex ↔ Color
├── Views/
│   ├── LifeGridView.swift        # the centerpiece visual — pure SwiftUI
│   ├── OnboardingView.swift      # 4-step glass flow
│   ├── SettingsView.swift        # glass sidebar + live preview
│   ├── MenuBarContent.swift      # glass menu popover
│   └── View+Glass.swift          # .glassCard / .glassCircle helpers
└── Services/
    ├── WallpaperRenderer.swift   # SwiftUI → PNG via ImageRenderer
    ├── WallpaperSetter.swift     # per-NSScreen, native resolution
    └── Scheduler.swift           # daily timer + screen-change + wake
```

The grid is a pure function of `(birthdate, totalYears, columns, fadeInYears, fadeOutYears) → cells`. The same `LifeGridView` drives the onboarding preview, the settings preview, and the rasterized wallpaper PNG — one source of truth.

## License

MIT
