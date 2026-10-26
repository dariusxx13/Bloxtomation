# Reel the Storm: prototype (`stormcatch`)

The playable prototype of Reel the Storm, built from the studio template (Rojo, strict Luau). It answers the approved go/stop question: is each weather a different way to fish (twist test A), and do players follow the fronts (twist test B)? Design: `../docs/specs/prototype.md` (requirements 1-14), GDD v3.1 §2.4, §4.1-§4.3 and §13, economy sheet v2 §14, world plan v2 §12. It sells nothing: every pass and product id is 0 and there is no store UI.

## What is in it

| Area | Where |
|---|---|
| Fishing: cast, bite, Sea Fog hook, server-owned ring, land, scripted first catch and first rain catch | `src/server/Systems/Fishing.luau`, `src/client/Controllers/Reel.luau`, pure rules in `src/shared/Util/Catch.luau` and `Util/Ring.luau` |
| Weather timetable (identical in every server), QA overrides, WeatherState | `src/shared/Util/WeatherSchedule.luau`, `src/server/Systems/Weather.luau`, `src/client/Controllers/Weather.luau` (visuals), `Controllers/SkyDial.luau` |
| Great Storm lightning and the co-op pull | `src/server/Systems/StormPull.luau`, `src/client/Controllers/StormHUD.luau`, pure rules in `src/shared/Util/Pull.luau` |
| Placeholder world (Pebble Cove harbour edge) built from data | `src/shared/Config/WorldLayout.luau`, `src/server/Systems/World.luau` |
| Catch log, `twistStats`, `exportLog` | `src/server/Systems/CatchLog.luau`, `src/shared/Util/TwistLog.luau`, `src/server/Systems/QA.luau` |
| Numbers (economy sheet v2 §14) | `src/shared/Config/Species.luau`, `Config/Fishing.luau`, `Config/Upgrades.luau`, `Config/Weather.luau` |
| Reused template platform | `PlayerData` + `Core/ProfileStore` (session lock, `UpdateAsync`, autosave, leave/shutdown saves, kick on failed load, schema v2 + migration), `Net` (rate limits), `Util/Validate`, `Currency`, `Upgrades` (the Rod), `Onboarding` (7 steps), `ClientEvents`, `Purchases` (idempotent `ProcessReceipt`, nothing for sale), `Social`, `Leaderstats`, `Characters`, `QA`, analytics, live config, UI kit |

Template features outside the prototype's scope (zones 2-5, eggs, pets, rebirth, daily and playtime rewards, codes, the store tabs, server luck) are not in this project; `template/` keeps them for the build stage.

## Run it

1. Tools: `bash scripts/install-tools.sh` (Linux, into `.tools/`) or `rokit install`.
2. `rojo serve`, connect the Rojo plugin in Studio, press Play. The server builds the world (no `Workspace.World` is authored). Or open `build.rbxl` after `rojo build -o build.rbxl`.
3. Settings shows the QA tools in Studio. From automation, call the real remote from the Client data model, for example `game.ReplicatedStorage.Remotes.QACommand:InvokeServer("forceWeather", "cove_shallows fog 120")`.

QA commands (Studio, or live servers for user ids in `Config/Game.qaUserIds`; every use is printed): `state`, `addCoins <n>`, `setOnboarding <0..7>`, `forceWeather "<spot> <clear|showers|fog> <seconds <= 120>"`, `forceStorm`, `forceStormborn`, `setScheduleOffset <seconds>`, `twistStats`, `exportLog`, `wipeData` (Studio only; rejoin afterwards for a fresh run).

## Checks

```bash
bash scripts/check.sh                       # format, lint, strict types, unit tests, config gate, build
lune run scripts/economy-sheet              # live config, to compare with economy sheet v2 §14
lune run scripts/inspect-build build.rbxl   # what rojo build produced (ORDER lists, streaming, removed modules)
```

Unit tests (`tests/`, Lune): WeatherSchedule, Ring, Catch (tables, sizes, marks, values, bite payload), Pull (meter, shares, Charged, angler invariance), SheetConfig (config equals sheet §14), TwistLog, WorldLayout, Remotes (Net-only, declared, rate-limited, one handler each), NoPurchase, Config, Data (schema v2 migration), Economy, Odds, Format, Validate.

Related: [Prototype brief](../docs/specs/prototype.md) · [GDD](../docs/gdd.md) · [Economy sheet](../docs/economy-sheet.md) · [World plan](../docs/world-plan.md)
