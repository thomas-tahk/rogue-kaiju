# Rogue Kaiju — vision (DRAFT, in Shape; not signed off)

## Intent
Play a giant monster smashing a city, with roguelike runs. Defense force built to fight kaiju is the opposition. Original world.

## Goals
- TBD in Shape round 1

## Non-goals
- TBD

## Anti-goals
- A Rampage clone: no copied names, characters, rule set (see CLAUDE.md originality rule).

## Done-gate (proposed, unconfirmed)
On my Windows PC I play one full run, from picking a monster to dying or beating the last city, choose upgrades between cities, and want to start another.

## What the scaffold already assumes (from code on `placeholder-art`)
- **Assumption:** 2D side view, gravity, jump, wall climb, punch left/right/up (`scripts/monsters/PlayerMonster.gd`).
- **Assumption:** local 2-player on one keyboard (`player_index` 0/1, `scripts/autoloads/InputMapper.gd`).
- **Assumption:** run = sequence of cities; upgrade pick between cities; run state resets (`scripts/autoloads/RunManager.gd`).
- **Assumption:** meta progression with a currency ("kaiju_coins") and monster unlocks, saved to disk (`scripts/autoloads/MetaProgression.gd`).
- **Assumption:** soldiers as basic enemies; helicopters implied by the upward punch.
- Starter monster id `george` is Rampage's character name → rename (originality rule), not a design question.

## Open questions
Round 1: GitHub issue labelled needs-you (link in STATE.md).
