# Zones

A macOS menu-bar app that shows the time zones you work with on one shared
timeline. Each zone has a name you choose ("West Coast", "Mexico City"), its local
time, and a bar showing how far along its workday is.

## Using it

Click the globe in the menu bar, or press the global shortcut set in Settings. The
shortcut opens the same view in a panel under the icon; Esc, a click elsewhere, or
the shortcut again closes it.

Every bar spans your local day, midnight to midnight, so the zones line up. Each bar
is labeled with that zone's own hours every three hours. The filled part is the
workday already past; the tick marks now. Each row also shows the zone's offset
from you, "Tomorrow" or "Yesterday" when its date differs, and, outside working
hours, when the workday starts, "Done for the day", or "Day off" (weekends).

Settings (the gear, or ⌘,) holds:

- **Time zones** — rename, set each zone's workday hours, remove, drag to reorder,
  and add more by searching cities, regions, or zone names.
- **General** — the global shortcut, 24-hour clock, and start at login.

New York, West Coast, and Mexico City are the defaults. Settings live in
`UserDefaults` under `me.kvnd.Zones`.

## Architecture

- **`ZonesKit`** (SwiftPM library) — UI-agnostic core: zones, workday windows,
  workday status, timeline layout, time-zone search, and clock text. Tested with
  swift-testing.
- **`Zones`** (Xcode app target, SwiftUI) — the `MenuBarExtra`, the timeline views,
  and the Settings window.

## Requirements

macOS 26 or later, Xcode 26.4 or 27, and [`mise`](https://mise.jdx.dev) with
XcodeGen. The global shortcut uses
[KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts).

## Development

```bash
mise run test       # ZonesKit tests
mise run check      # lint then test
mise run format     # format Swift sources in place
mise run xcodegen   # regenerate Zones.xcodeproj from project.yml
mise run run        # build the Debug app and launch it
mise run install    # Developer ID build into /Applications
mise run archive    # notarized, stapled DMG in dist/
mise run release    # bump the version, build the DMG, and publish a GitHub release
```

`signing:check` verifies the Developer ID certificate and the notary profile
before `archive` or `release`.

The Xcode project is generated from `project.yml`; edit that file, not the
`.xcodeproj`.
