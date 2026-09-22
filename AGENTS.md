# Repository Workflow

Keep work in this repository small, reviewable, and grounded in its current state.

## Source of truth

- The repository—code, documentation, tests, configuration, and Git history—is the source of truth. Chat memory is not.
- Read the files relevant to a task before editing them. Check `PRODUCT.md` when product intent or scope matters.
- Update documentation only when the implemented reality or a confirmed product decision changes.

## Change discipline

- Work on one bounded task at a time.
- Make the smallest coherent change that fully satisfies the task.
- Do not introduce unrelated refactors, cleanup, features, or architecture.
- Keep process and tooling lightweight and proportional to this Roblox project.
- Do not modify established product decisions in `PRODUCT.md` without an explicit reason and user agreement.

## Architecture invariants

- Preserve the server-authoritative economy and progression architecture.
- Clients request actions; the server validates requests and owns balances, prices, rewards, upgrades, prestige gains, and progression state.
- UI renders authoritative server state and must not become a gameplay authority.
- Keep shared formulas and balance values in clear authoritative locations rather than duplicating them across client and server.

## Verification and handoff

- Run the verification relevant to the files and behavior changed. Prefer focused checks over broad ceremony.
- Inspect the full Git diff after implementation and review it critically for correctness, scope, regressions, and accidental edits.
- Report results as **verified**, **unverified**, or **blocked**. Never invent test results or imply a check ran when it did not.
- State any important limitation that could not be verified in Roblox Studio or the current environment.

