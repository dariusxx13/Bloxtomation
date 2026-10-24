# Starter Simulator template

A complete, working Roblox game you can rename and reskin: a tap-to-earn simulator with zones, eggs, pets, upgrades, rebirths, daily and playtime rewards, codes, a Robux shop, onboarding, analytics and live configs. Every rule in the [knowledge vault](../vault/README.md) that applies to this genre is built in, and the whole project passes a strict quality gate (format, lint, strict types, unit tests, config checks, build) locally and in CI.

The art is deliberately placeholder (coloured parts, built-in sounds). The systems are production code.

## What the player gets

| Loop | How it works |
|---|---|
| Core action | Tap a crystal node to earn coins. Nodes break after 12 hits and pay a bonus, then respawn. Tapping a far node walks you to it. |
| Upgrades | Power (coins per hit), Speed, Luck, Pet Storage, bought with coins. |
| Zones | Five zones, each paying more per hit, unlocked in order at their gates. |
| Eggs and pets | One egg per zone with displayed odds (luck-adjusted, same code the server rolls with), hard pity, a reveal with anticipation, "NEW!" for first finds, equip best, lock, multi-delete. |
| Rebirth | Trade coins and Power/Speed for a permanent multiplier. The panel shows exactly what resets and what stays. |
| Retention | 7-day calendar with a gentle streak, playtime gifts for this session, codes, friend and group bonuses. |
| Shop | Passes (2x Coins, Auto Hit, +3 Pet Slots, Triple Hatch, Lucky, VIP) and products (starter pack, coins, luck potion, server luck), hidden until you add their ids. |
| Onboarding | An 11-step guided first session (beam to world targets, pulsing outline on buttons) logged as an onboarding funnel. |

## Quick start

1. Install the toolchain: `rokit install` (any OS, versions pinned in `rokit.toml`), or on Linux `bash scripts/install-tools.sh` (installs into `.tools/`).
2. Start syncing: `rojo serve`, then connect with the Rojo plugin in Roblox Studio.
3. Press Play. With no `Workspace.World` folder the server builds a placeholder world from config.
4. Open **Settings** in game: in Studio you get the QA tools (coins, unlock zones, rebirth-ready, restricted-policy toggle, egg simulator and more).

To keep data between Studio sessions, enable *Game Settings > Security > Enable Studio Access to API Services*. Without it the template stores profiles in memory and says so in the output.

## Checks

```bash
bash scripts/check.sh            # format, lint, strict types, unit tests, config gate, build
bash scripts/check.sh --release  # also fails on release blockers (template defaults, missing ids)
lune run scripts/economy-sheet economy-sheet.md   # pacing, costs, odds tables from live config
```

CI runs the same gate on every push that touches `template/` ([workflow](../.github/workflows/template-ci.yml)) and uploads `build.rbxl` and the economy sheet as artifacts.

## Layout

```text
template/
├── default.project.json      Rojo: shared -> ReplicatedStorage.Shared, server -> ServerScriptService.Server,
│                             client -> StarterPlayerScripts.Client; StreamingEnabled on
├── rokit.toml                pinned tools (rojo, selene, stylua, lune, luau-lsp, wally)
├── src/
│   ├── shared/               pure modules both sides use (no Roblox globals except Net and Signal)
│   │   ├── Types.luau        every type that crosses the network or is saved
│   │   ├── Net.luau          the only remote layer: creation, rate limits, protected handlers
│   │   ├── Config/           all tuning: Game, Economy, Upgrades, Zones, Pets, Eggs, Products,
│   │   │                     Rewards, Codes, Onboarding, Remotes, Analytics
│   │   ├── Data/             profile Schema (versioned) and Migrations
│   │   └── Util/             Odds, EconomyMath, Stats, Daily, Format, Validate, RateLimiter, TableUtil, Signal
│   ├── server/
│   │   ├── init.server.luau  the only Script: ordered init() then start()
│   │   ├── Core/ProfileStore.luau     session-locked DataStore profiles
│   │   ├── Services/         Analytics, Policy, LiveConfig
│   │   └── Systems/          one module per game system (below)
│   └── client/
│       ├── init.client.luau  the only LocalScript
│       ├── UI/               Theme, Builder, Root (scaling and layers), Panels, Sounds
│       └── Controllers/      one module per screen or behaviour (below)
├── tests/                    Lune unit tests for every pure module (`lune run tests/run`)
└── scripts/                  check.sh, install-tools.sh, check-config, economy-sheet, upload-place
```

## Architecture in one page

- **Two entry points.** `init.server.luau` creates every remote (`Net.initServer`), starts live configs, then runs each system's `init()` and then `start()` in a fixed order, with `PlayerData` last so every listener exists before the first profile loads. The client does the same with its controllers.
- **Server owns all state.** Clients send requests through `Net`; every handler validates type, range, permission and plausibility (`Util/Validate`), and `Net.handle` adds a per-player token-bucket rate limit and a protected call. Prices, odds, rewards and cooldowns are read from server config, never from arguments.
- **One source of truth per player.** `PlayerData` holds the profile and session state, sends the owner a snapshot on join and batched deltas every 0.1 s. Systems mutate the profile and call `PlayerData.changed(...)`. The client mirrors it in `Controllers/State` and recomputes derived stats with the same pure `Util/Stats`, so timers and multipliers match the server.
- **Systems talk through signals.** `Nodes.Hit`, `Upgrades.Bought`, `Hatching.Hatched`, `Zones.Unlocked`, `Purchases.ProductGranted` and others let Onboarding, Leaderstats and future systems react without reaching into each other.
- **Pure where possible.** Config, odds, economy math, stats, validation, the daily calendar and the data schema have no Roblox dependencies and are unit-tested in Lune.

### Server systems

| System | Responsibility |
|---|---|
| `PlayerData` | Load with session lock, autosave (staggered), save on leave and shutdown, snapshot and delta replication. Kicks instead of playing on a default profile when a load fails. |
| `Currency` | The only module that changes coins and gems; logs every change to economy analytics (hits are batched). |
| `Grants` | Pays rewards (minutes-of-income coins, gems, boosts) for daily, playtime, codes and products. |
| `World` | Registry of nodes, gates, egg stands, zone bounds and spawn; builds the placeholder world when none is authored. |
| `Nodes` | Validates hits (zone, range, cooldown, node state) and pays coins. |
| `Upgrades`, `Zones`, `Rebirth` | Purchases and resets with server-side prices. |
| `Hatching` | Luck-adjusted rolls, hard pity, results saved before the reveal, rare-pull announcements (server and cross-server). |
| `PetInventory` | Equip, unequip, equip best, lock, multi-delete; broadcasts equipped pets for rendering. |
| `Rewards`, `Codes` | Daily calendar, playtime gifts, code redemption. |
| `Purchases` | Pass ownership, idempotent `ProcessReceipt` (receipt ids stored, saved before granting), server luck, per-player policy. |
| `Social` | Friends-in-server and group coin bonus. |
| `Onboarding` | Advances and logs the onboarding funnel in order. |
| `ClientEvents` | Settings and low-trust UI reports (panel opens, purchase prompts) for funnels. |
| `Leaderstats`, `Characters` | Player list; walk speed from stats; returns players found inside locked zones to spawn. |
| `QA` | Test commands, Studio and allowlisted testers only; every use is logged. |

### Client controllers

`State` (mirror), `Toasts` (messages and announcements), `HUD` (currencies with count-up, boosts, menu, badges), `Shop`, `PetsPanel`, `RebirthPanel`, `RewardsPanel` (calendar, gifts, codes), `SettingsPanel` (preferences and QA tools), `Hatch` (odds panel and reveal), `Gates` (local gate collision and unlock prompts), `Interact` (tap to hit, auto hit, predicted feedback), `PetFollow` (local pet rendering), `Guide` (onboarding pointer).

The UI is built in code with `UI/Builder` on a 1280x720 design canvas scaled to every screen (`UI/Root`), with 56 px minimum touch targets, safe-area insets, and a reduce-motion setting.

## Data

The profile (`Types.ProfileData`, `Data/Schema.luau`) is plain JSON-safe data: currencies, upgrades, zones, pets, equipped list, collection index, pity counters, rebirths, daily state, onboarding step, redeemed codes, recent receipt ids, one-time products, boost expiries, settings and lifetime stats.

- Every save goes through `UpdateAsync` with a session lock (`lockId`, `lockTime`); a lock older than `Config/Game.sessionLockStaleSeconds` is treated as abandoned.
- Shape changes bump `Schema.VERSION` and add a step in `Data/Migrations.luau`; data from a newer version is refused, never overwritten.
- `ProfileStore` by loleris is a proven drop-in alternative (commented in `wally.toml`).

## Monetization and compliance

- Ids of `0` hide a pass or product. Create them in Creator Hub, paste the ids into `Config/Products.luau`. Robux prices are fetched at runtime.
- Coins can be bought with Robux, so eggs count as paid random items: odds are always shown (from the same tables the server rolls), and for players whose policy restricts paid random items the coin products, luck products and Lucky pass are hidden and paid luck is ignored by `Stats.derive`. If such a player buys one from another surface, the receipt is held, not granted. The policy lookup defaults to restricted when it fails.
- Products marked `oncePerPlayer` (starter pack) disappear after purchase.

## Analytics and live configs

- Economy events for every currency source and sink, an onboarding funnel (11 steps), a shop funnel (opened, prompted, purchased), and custom events: `Hits`, `HatchEgg`, `Rebirth`, `ZoneUnlocked`, `CodeRedeemed`, `DailyClaimed`, `PlaytimeClaimed`, `UiOpened` (`Config/Analytics.luau`). Events record only in published games.
- `Services/LiveConfig.luau` reads Roblox configs with typed defaults: `featureDailyRewards`, `featurePlaytimeRewards`, `featureCodes`, `featureServerLuck` (also published to clients so the UI hides disabled features), `nodeValueMultiplier`, `hatchPriceMultiplier`, `announceMinRarity`. Create the same keys in Creator Hub to change them without publishing.

## Making it your game

1. **Identity:** set `name` and `isTemplateDefault = false` in `Config/Game.luau`; add your group id and QA tester ids.
2. **Economy:** edit `Config/Economy`, `Upgrades`, `Zones`, `Eggs`, `Pets`, then run the economy sheet and the tests. The pacing tests in `tests/Economy.spec.luau` encode the targets (zone 2 at 8-16 minutes for a casual player, first rebirth at 20-90); change them deliberately, not to make a failing build pass.
3. **World:** author `Workspace.World` in Studio and the placeholder is skipped. The contract: parts tagged `ResourceNode` (attributes `NodeId`, `ZoneId`), `ZoneGate` (`ZoneId`, with a ProximityPrompt named `UnlockPrompt`), `EggStand` (`EggId`, `ZoneId`, with a ProximityPrompt named `HatchPrompt`), `ZoneBounds` (`ZoneId`), and a `SpawnLocation` named `PlayerSpawn`.
4. **Look and sound:** restyle with `client/UI/Theme.luau`; replace sound ids in `Config/Game.sounds`; swap pet shapes for models in `PetFollow` and the UI cards.
5. **New system:** add a module to `server/Systems` with `init`/`start`, its remotes to `Config/Remotes` (with rate limits), its types to `Types.luau`, its client controller, and add both to the startup `ORDER` lists. The bootstrap warns about modules missing from the order.

## Shipping

1. `bash scripts/check.sh --release` must pass (it blocks template defaults and products without ids).
2. Build and upload a Saved version: `rojo build -o build.rbxl` then `lune run scripts/upload-place build.rbxl` with `ROBLOX_API_KEY`, `ROBLOX_UNIVERSE_ID` and `ROBLOX_PLACE_ID` set, or run the CI workflow manually with *upload_saved*. The script only ever uploads `versionType=Saved`.
3. A person playtests that version and publishes it from Studio or Creator Hub. Automation never publishes.
4. Walk the [pre-launch checklist](../vault/18-templates-and-checklists/pre-launch-checklist.md).

## Further reading in the vault

[Project architecture](../vault/13-building-it-right/project-architecture.md) · [Networking and remotes](../vault/13-building-it-right/networking-and-remotes.md) · [Data persistence](../vault/13-building-it-right/data-persistence.md) · [Security](../vault/13-building-it-right/security-and-anti-exploit.md) · [Economy math](../vault/04-progression-and-economy/economy-math.md) · [RNG systems and pity](../vault/03-rarity-and-rng/rng-systems-and-pity.md) · [Monetization compliance](../vault/09-monetization/monetization-compliance.md) · [Measuring onboarding](../vault/01-first-five-minutes/measuring-onboarding.md) · [Tooling and CI](../vault/13-building-it-right/tooling-and-ci.md)
