# Clockwork Incremental — foundation

This project implements the initial Ticks loop and two early upgrades, Stronger
Spring and Precision Gears: authoritative server data, Tick generation,
purchasing, and a server-driven economy UI. It intentionally contains no later
progression systems.

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
  `default.project.json`, so they are real `RemoteEvent` instances, not Lua
  files.

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
- `TickService` performs the one-second server loop and awards the configured
  `Ticks` production rate.
- `UpgradeService` validates purchase requests, spends Ticks, increments the
  level, recalculates production, and publishes the result.
- `ServerBootstrap` wires players, services, the RemoteEvents, and shutdown
  cleanup together.
- `NumberFormatter` is shared display code. It abbreviates thousands through
  vigintillions and uses scientific notation beyond its named suffix list.
- `ClockworkUI` creates the economy and upgrade panels. It only renders snapshots
  received from the server and never predicts costs, levels, or currency.

## Authority and networking

The live profile exists only under `ServerScriptService`; clients cannot require
or edit it. Every balance change goes through `EconomyService` on the server.
The server sends full display snapshots through `EconomySnapshot` after each
award. A client can ask the same RemoteEvent for a fresh snapshot, but it sends
no amount or rate, and the server throttles requests to one per second.

Clicking BUY sends only an upgrade identifier through `PurchaseUpgrade`.
`UpgradeService` confirms the player and configured upgrade, calculates the
current cost from `BalanceConfig`, checks and subtracts the server balance,
increments the server level, recalculates Ticks per second, and publishes a new
snapshot. Failed requests do not mutate data.

## Current persistence scope

Profiles are session-only in this foundation because cross-session saving was
not part of the requested feature set. The `PlayerDataService` boundary is the
single place to add a DataStore/profile implementation later; the rest of the
game can continue calling the same service and economy APIs.

## Quick Studio test

1. Start a Play test, not Run, so a player and `PlayerGui` are created.
2. The panel should begin at `0 Ticks` and `+1 Ticks / second`.
3. The balance should rise by one each second.
4. Stronger Spring should begin at Level 0 with a cost of 10 Ticks.
5. Clicking BUY below 10 Ticks should make no change.
6. At 10 or more Ticks, BUY should subtract 10 Ticks, show Level 1, update the
   next cost to 15 Ticks, and change production to `+2 Ticks / second`.
7. The next successful purchase should show Level 2 and `+3 Ticks / second`.
8. Precision Gears should begin at Level 0 with a cost of 50 Ticks.
9. With Stronger Spring at Level 3, buying Precision Gears once should change
   production from `+4` to `+5 Ticks / second`; buying it twice should change
   production to `+6.25 Ticks / second`.
10. Precision Gears' next costs should be 88 Ticks at Level 1 and 153 Ticks at
    Level 2.
11. In a server-side test, setting a balance to `1000`, `1000000`, or
   `1000000000` through `EconomyService` displays `1K`, `1M`, or `1B` after
   `EconomyService.Publish(player)`.
