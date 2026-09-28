# CLAUDE.md — Zones

Menu-bar app showing chosen time zones on one shared timeline with workday
progress. Global instructions in `~/.claude/CLAUDE.md` still
apply; this file adds only project-specific facts. Structure follows
`/Users/kevin/git/bearthingy`.

## Architecture

- `ZonesKit` (SwiftPM library) — pure, UI-agnostic logic. All time math lives here
  and is tested: `DailyWindow` (repeating wall-clock span, overnight when end ≤
  start), `WorkdayStatus`, `TimelineAxis` (maps intervals to 0–1 fractions),
  `ZoneCatalog` (search), `ClockText` (formatting).
- `Zones` (Xcode app target, `App/`) — SwiftUI `MenuBarExtra` with `.window` style.
  The menu-bar label hosts two AppKit windows: `SettingsWindow` (a menu-bar app has
  no main window for a `Settings` scene) and `ZonesPanel`, which the global
  shortcut toggles. SwiftUI cannot open the `MenuBarExtra` window from code, and
  `performClick` on its status button does nothing.

## Rules

- The timeline axis is the viewer's local day. Zone workdays and hour labels are
  computed in their own time zone, then mapped onto that axis. Build wall-clock
  times with `Calendar.date(bySettingHour:)` so DST days stay correct; never add
  seconds to a start of day.
- Sandboxed; no integrations. Preferences live in
  `~/Library/Containers/me.kvnd.Zones/Data/Library/Preferences/`, not
  `~/Library/Preferences/`.
- Swift 6 strict concurrency. Kit models are `Sendable` value types; UI is `@MainActor`.
- Edit `project.yml`, then `mise run xcodegen`. Never edit the `.xcodeproj`.

## Commands

```bash
mise run test    # swift test
mise run check   # lint + test
mise run run     # build Debug app and launch
mise run release # version bump, notarized DMG, tag, GitHub release
```
