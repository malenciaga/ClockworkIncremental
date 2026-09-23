# Clockwork Incremental — foundation

This project implements the initial Ticks loop and two early upgrades, Stronger
Spring and Precision Gears: authoritative server data, Tick generation,
purchasing at a physical upgrade wall, and a compact left-side stats HUD. It
intentionally contains no later progression systems.

## Roblox Studio placement

The included `default.project.json` can be served with Rojo. If creating the
instances manually in Studio, reproduce this exact Explorer tree:

```text
ReplicatedStorage
└─ Clockwork (Folder)
   ├─ Shared (Folder)
   │  └─ NumberFormatter (ModuleScript)
   └─ Remotes (Folder)
      ├─ EconomySnapshot (RemoteEvent)
      └─ PurchaseUpgrade (RemoteEvent)

ServerScriptService
└─ ClockworkServer (Folder)
   ├─ Data (Folder)
   │  ├─ BalanceConfig (ModuleScript)
   │  └─ PlayerDataTemplate (ModuleScript)
   ├─ Services (Folder)
   │  ├─ PlayerDataService (ModuleScript)
   │  ├─ EconomyService (ModuleScript)
   │  ├─ KioskService (ModuleScript)
   │  ├─ TickService (ModuleScript)
   │  └─ UpgradeService (ModuleScript)
   └─ ServerBootstrap (Script)

StarterPlayer
└─ StarterPlayerScripts
   └─ ClockworkUI (LocalScript)
```

Copy each source file's contents into the matching Studio instance. The file
suffixes used by Rojo map as follows:

- `.server.lua` becomes a `Script`.
- `.client.lua` becomes a `LocalScript`.
- A plain `.lua` source file becomes a `ModuleScript`.
- `EconomySnapshot` and `PurchaseUpgrade` are declared directly in
  `default.project.json`, so they are real `RemoteEvent` instances, not Lua files.

## Responsibilities

- `BalanceConfig` is the single source of truth for base production, upgrade
  definitions, exponential costs, and the ordered flat-then-multiplicative
  production formula.
- `PlayerDataTemplate` is the versioned shape of a new player's data. Currency
  balances, upgrade levels, and production rates are separate dictionaries.
- `PlayerDataService` owns loaded server profiles. It is deliberately the only
  service that knows how profiles are obtained and released; persistence can be
  added here later without rewriting the economy, generator, or UI.
- `EconomyService` is the reusable server-only API for balances, production
  rates, and client snapshots.
- `KioskService` constructs one clockwork Tick Upgrades wall near the player
  spawn, including separate display and BUY plates for each upgrade row.
- `TickService` performs the one-second server loop and awards the configured
  `Ticks` production rate.
- `UpgradeService` validates purchase requests, spends Ticks, increments the
  level, recalculates production, and publishes the result.
- `ServerBootstrap` wires players, services, the RemoteEvents, and shutdown
  cleanup together.
- `NumberFormatter` is shared display code. It abbreviates thousands through
  vigintillions and uses scientific notation beyond its named suffix list.
- `ClockworkUI` creates the compact left-side stats HUD and client-local
  `SurfaceGui` displays and BUY buttons attached to the shared wall rows. It
  renders server snapshots and sends only upgrade identifiers when clicked.

## Authority and networking

The live profile exists only under `ServerScriptService`; clients cannot require
or edit it. Every balance change goes through `EconomyService` on the server.
The server sends full display snapshots through `EconomySnapshot` after each
award. A client can ask the same RemoteEvent for a fresh snapshot, but it sends
no amount or rate, and the server throttles requests to one per second.

Clicking or tapping a wall-row BUY button sends only its configured upgrade
identifier through `PurchaseUpgrade`. `ServerBootstrap` passes the requesting
player and identifier to `UpgradeService.TryPurchase`, which confirms the player
and upgrade, calculates the current cost from `BalanceConfig`, checks and
subtracts the server balance, increments the server
level, recalculates Ticks per second, and publishes a new snapshot. Failed
requests do not mutate data. No price, level, or production value comes from the
client. There are no purchase `ProximityPrompt` objects.

The wall geometry is constructed by `KioskService` from normal Roblox parts at
server startup. Because the whole `ClockworkServer` directory is already mapped
through `default.project.json`, the new module is part of the Rojo source of
truth without adding a manual Workspace object. The project mapping declares
the purchase RemoteEvent used by the client-owned wall buttons.

The wall uses a vertically segmented upgrade list. Extending its ordered
upgrade-ID list with another `BalanceConfig` upgrade creates another row; it
does not use a world-space scrolling gesture. Each player's row `SurfaceGui`
instances live under that player's `PlayerGui`
and adorn the shared display and BUY plates. Level, cost, and affordability are
rendered from that player's snapshot, so one player's purchase cannot replace
another player's wall state. The client dims an unaffordable button for display;
the server remains the final authority for every purchase.

## Current persistence scope

Profiles are session-only in this foundation because cross-session saving was
not part of the requested feature set. The `PlayerDataService` boundary is the
single place to add a DataStore/profile implementation later; the rest of the
game can continue calling the same service and economy APIs.

## Quick Studio test

1. Start a Play test, not Run, so a player and `PlayerGui` are created.
2. A compact left-middle HUD should show `0 Ticks`, `+1 Ticks / second`, and
   Level 0 for both upgrades.
3. The balance should rise by one each second.
4. One large Tick Upgrades wall should appear near spawn, with separate,
   readable Stronger Spring and Precision Gears rows and clickable BUY buttons.
5. Stronger Spring should begin at Level 0 with a cost of 10 Ticks.
6. Below 10 Ticks, its BUY button should appear unavailable and make no change.
7. At 10 or more Ticks, clicking BUY should subtract 10 Ticks, show Level 1,
   update the next cost to 15 Ticks, and change production to
   `+2 Ticks / second`.
8. The next successful purchase should show Level 2 and `+3 Ticks / second`.
9. Precision Gears should begin at Level 0 with a cost of 50 Ticks.
10. With Stronger Spring at Level 3, buying Precision Gears once should change
   production from `+4` to `+5 Ticks / second`; buying it twice should change
   production to `+6.25 Ticks / second`.
11. Precision Gears' next costs should be 88 Ticks at Level 1 and 153 Ticks at
    Level 2.
12. In a server-side test, setting a balance to `1000`, `1000000`, or
    `1000000000` through `EconomyService` displays `1K`, `1M`, or `1B` after
    `EconomyService.Publish(player)`.
13. Test desktop and mobile viewports: the smaller left HUD and both wall rows
    should remain readable; each BUY button should respond to mouse or touch,
    with hover/pressed feedback on desktop and no E-key purchase prompt.
14. In a two-player Play test, each player should see their own wall levels and
    costs after only one player purchases an upgrade.
