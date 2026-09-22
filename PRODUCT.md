# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

The primary audience is Roblox players who enjoy focused incremental and prestige games, including both active grinders and players who prefer semi-idle progression. The game must remain approachable to players with no prior incremental-game knowledge.

A typical session should deliver immediate visible number growth, a quick first meaningful upgrade, and regular acceleration without long dead waits. The core session target is approximately 15–30 minutes, while longer grind sessions remain viable. Returning players should always have a clear next goal.

Desktop and mobile Roblox players are required launch audiences. Gamepad and console support are not launch requirements, but current architecture and UI decisions should not make later support unnecessarily difficult.

## Product Purpose

Clockwork Incremental is a lightweight, focused incremental game about turning slow mechanical production into dramatic time-bending growth. Its intended progression rhythm is:

start slow → buy upgrades → accelerate rapidly → unlock a reset layer → become dramatically stronger → discover the next system.

The simple core loop should feel satisfying through clear feedback, meaningful acceleration, and an understandable next objective. The product should remain an incremental game rather than drifting into a traditional tycoon, combat game, or pet simulator.

## Positioning

The clock and time theme is part of the progression mechanics rather than cosmetic dressing. The long-term progression path is:

Ticks → Rewind → Time Shards → Timeline → Timeline Fragments → Temporal Glyphs → Paradox.

Its signature planned system is a clock-face Temporal Glyph loadout. Players equip rarity-based Glyphs into positions corresponding to hours on a clock. A small number of positions are available initially, with long-term progression unlocking up to all 12. Glyphs can affect production, prestige, luck, and global multipliers.

Every new progression layer should eventually add a decision, mechanic, automation, or interaction. New prestige layers must not exist solely to add currencies or multipliers.

## Operating Context

Players watch Ticks accumulate, purchase upgrades, and work toward increasingly deep reset layers. Sessions must support active play and semi-idle progression, with clear acceleration and goals across both short and extended play.

The planned progression layers are:

- **Rewind:** the first prestige layer; resets early Tick progression and grants permanent Time Shards.
- **Timeline:** a deeper reset layer; resets more progression and grants Timeline Fragments.
- **Temporal Glyphs:** a rarity-based collectible and roll system whose clock-face loadout becomes a recognizable product mechanic.
- **Paradox:** a later prestige layer introducing stronger permanent upgrades and increased automation.

Systems beyond Paradox should be considered only after the preceding layers are proven fun.

## Capabilities and Constraints

- The current foundation produces Ticks once per second and offers two early upgrades: Stronger Spring adds one Tick per second per level, then Precision Gears multiplies total Tick production by 1.25 per level. Both use exponentially increasing costs.
- Economy and progression remain server-authoritative. Clients may request actions but never decide balances, prices, rewards, prestige gains, or progression state.
- The UI renders authoritative snapshots and must not become a source of gameplay truth.
- Shared formulas and balance values require clear authoritative locations rather than duplication.
- Systems must remain modular enough to add currencies and reset layers without rewriting the foundation.
- Work should stay bounded and avoid unrelated feature creep.
- Session-only data is acceptable during early development but is not a permanent constraint. Persistent Roblox DataStore-backed saving is required before public release and should be introduced as its own deliberate task.
- Avoid unnecessary enterprise architecture or infrastructure unless actual project complexity requires it.
- Desktop and mobile support must be considered from the beginning of UI implementation.
- Console-specific navigation is deliberately deferred. Future gamepad support should remain feasible.

## Brand Commitments

The product name is **Clockwork Incremental**. Its durable identity is a focused incremental game in which clockwork and time concepts materially shape progression systems. The current terminology—Ticks, Rewind, Time Shards, Timeline, Timeline Fragments, Temporal Glyphs, and Paradox—is product language to preserve unless intentionally revised.

## Evidence on Hand

- `README.md` documents the current Ticks loop, Stronger Spring upgrade, server authority model, test expectations, and intentionally limited foundation scope.
- `default.project.json` defines the Roblox/Rojo project structure and networking instances.
- `src/ServerScriptService/ClockworkServer/Data/BalanceConfig.lua` is the current authority for base production and Stronger Spring balance.
- `src/ServerScriptService/ClockworkServer/Data/PlayerDataTemplate.lua` defines the versioned player-data shape.
- `src/ServerScriptService/ClockworkServer/Services/` contains modular player-data, economy, Tick-generation, and upgrade services.
- `src/StarterPlayer/StarterPlayerScripts/ClockworkUI.client.lua` is the existing authoritative-snapshot UI implementation.
- No testimonials, player research, public performance claims, launch metrics, or production persistence implementation are currently present. Future work must not fabricate them.

## Product Principles

1. **Make growth legible and gratifying.** Players should quickly understand what is increasing, why it is increasing, and what purchase or reset will accelerate it next.
2. **Turn time into mechanics.** Clock and time concepts should shape progression and decisions, not merely label generic systems.
3. **Earn every new layer.** Each progression layer should introduce a meaningful choice, mechanic, automation, or interaction after its basic multiplier value is established.
4. **Keep authority trustworthy and extensible.** The server owns progression truth, while shared formulas and modular services make later currencies and reset layers deliberate additions.
5. **Stay focused.** Favor a polished incremental loop over genre drift, unnecessary infrastructure, or speculative feature breadth.

## Accessibility & Inclusion

The game must be understandable without prior incremental-game knowledge. UI must support both desktop and mobile Roblox players from the start, keep current goals and outcomes clear, and avoid relying on console-only or pointer-only interaction assumptions that would obstruct later input support.
