# AimNade

AimNade is a 2D tactical utility tool for Counter-Strike players. It helps you learn common
lineups through map markers, categorized lists, and per-lineup screenshots of the standing
position, the aim point, and the result.

Everything ships inside the app: no network access, no account, no backend.

The Xcode project, target, scheme, build product, and on-device display name are all `AimNade`.

## What it does

- **2D tactical map** — Mirage with one-finger pan, pinch-to-zoom, double-tap zoom, marker
  clustering, and filters by area and by utility type.
- **Utility list** — lineups grouped by area (A site / B site / mid / T side / CT side).
- **Search** — full-text search that works across both the Chinese and English content.
- **Favorites** — star a whole utility group or a single lineup; stored locally.
- **Detail pages** — spawn requirement, start and target area, throw method, step notes,
  difficulty, and a screenshot set per lineup.
- **Two languages** — Simplified Chinese and English, plus a "follow system" option.
- **Developer mode** — overlay, drag, and copy map coordinates while laying out new content.

All content lives in `AimNade/Data/lineups_mirage.json` and is loaded by `LineupStore`.

## Status

Early MVP. V1 is deliberately scoped to the **Mirage** map only — no 3D view, no video, no
login, no backend, no user submissions.

> ⚠️ **The bundled lineup data is placeholder content.** The coordinates were picked by hand,
> the teaching screenshots do not exist yet, and nothing has been checked against the real
> game. Do not treat it as verified real lineup data.

Progress is tracked in [`PROJECT_STATUS.md`](PROJECT_STATUS.md); the working rules for this
repository are in [`AGENTS.md`](AGENTS.md).

## Requirements

- iOS 17.0 or later
- Xcode — last verified with Xcode 27.0 and an iOS 26.5 simulator
- No third-party dependencies (no SPM, CocoaPods, or Carthage)

## Running it

Open `AimNade.xcodeproj` in Xcode, pick a simulator, and run.

Or from the command line:

```bash
xcodebuild -project AimNade.xcodeproj -scheme AimNade \
  -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug build
```

## Documentation

| File | Purpose |
|---|---|
| `AGENTS.md` | Working rules and handoff protocol for AI agents in this repo |
| `PROJECT_STATUS.md` | Progress snapshot, priorities, and known issues |
| `docs/LOCALIZATION.md` | Localization conventions |
