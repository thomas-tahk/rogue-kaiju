# Rogue Kaiju — vision (DRAFT, in Shape; not signed off)

## Intent
Play a giant monster smashing a city, with roguelike runs. Defense force built to fight kaiju is the opposition. Original world.

## Goals (round 1, 2026-11-08)
- Solo. Couch co-op = stretch goal, later.
- Roguelite structure borrowed from Slay-the-Spire-style acts + branching route map; "one more run" pull is the point. Numbers found by play-testing, not decided up front.
- Core node = destroy a city (Rampage-faithful). Other node types possible: kaiju-vs-kaiju fights, events, etc.
- Twist (tentative, expect several passes): mutations as the run choice + escalating defense force as pressure.
- Light meta: unlock monsters + starting mutations; no permanent stat grind.
- PC first. Mobile/console ports decided later.

## Non-goals
- Co-op in the first version.
- Mobile/console in the first version.

## Anti-goals
- Arcade sameness: Rampage loses its luster fast; the only reason to keep playing is an outside score chase. The run itself must keep changing what you're trying to do.
- Wall of difficulty: StS felt too hard to make progress or win consistently. A normal player should win runs and feel progress even when losing.
- Dozing between decisions: long deliberation stalls the run. Decisions are short; action carries the pace.
- A Rampage clone: no copied names, characters, rule set (see CLAUDE.md originality rule).

## Done-gate (proposed, unconfirmed)
On my Windows PC I play one full run, from picking a monster to dying or beating the last city, choose upgrades between cities, and want to start another.

## Still open
- View: 2D side / 2.5D / 3D — he wants to play it before deciding (Rampage's later games had 3D elements).
- Tone: classic comedic Rampage vs kaiju-vs-kaiju vs a mix across node types.

## What the scaffold already assumes (from code on `placeholder-art`)
- **Assumption:** 2D side view, gravity, jump, wall climb, punch left/right/up (`scripts/monsters/PlayerMonster.gd`).
- ~~local 2-player~~ refuted: solo first. Scaffold only spawns one monster, but `InputMapper.gd` + `PlayerMonster.gd` still bind P2 keys → strip when building (`player_index` 0/1, `scripts/autoloads/InputMapper.gd`).
- **Assumption:** run = sequence of cities; upgrade pick between cities; run state resets (`scripts/autoloads/RunManager.gd`).
- **Assumption:** meta progression with a currency ("kaiju_coins") and monster unlocks, saved to disk (`scripts/autoloads/MetaProgression.gd`).
- **Assumption:** soldiers as basic enemies; helicopters implied by the upward punch.
- Starter monster id `george` is Rampage's character name → rename (originality rule), not a design question.

## Open questions
Round 1: GitHub issue labelled needs-you (link in STATE.md).
