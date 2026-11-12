# Rogue Kaiju — vision (Shape complete 2026-11-12, awaiting his confirm)

## Intent
Play a giant monster smashing cities, Rampage-style, inside a roguelite run with a Slay-the-Spire-style route map. A defense force built to fight kaiju is the opposition. Original world.

## Goals
- **Solo**, PC (Windows), keyboard + gamepad.
- **Run = acts on a branching map.** Node types: City (smash it — main node), Rival kaiju (harder fight, better reward), Event (short text choice), Lab (heal / swap a mutation). Each act ends in a boss. Counts and lengths tuned by play-testing.
- **City clears by destruction**, Rampage-faithful.
- **One combat system**: rival kaiju fights happen in a city with the same moves as smashing.
- **Twist (tentative, expect several passes):** mutations are the run's choices; the defense force escalates as pressure.
- **Tone mix:** cities comedic chaos; rival fights and bosses dramatic monster-movie moments.
- **Light meta:** unlock monsters + starting mutations; no permanent stat grind.
- **Winnable:** an average player wins a run within ~5 tries; harder modes unlock after, optional.
- **Fast decisions:** pick 1 of 3, readable at a glance.

## Non-goals (for now)
- Co-op (stretch goal, later). Mobile / console (decide after it's fun; no touch constraints now).

## Anti-goals
- Arcade sameness: each run keeps changing what you're trying to do; no reliance on an outside score chase.
- Wall of difficulty: normal players win and feel progress even when losing.
- Dozing between decisions: action carries the pace.
- A Rampage clone: no copied names, characters or rule set (CLAUDE.md originality rule).

## Done-gate
On my Windows PC I play one full run, from picking a monster to dying or beating the final boss, choose mutations along the route map, and want to start another.

## Decided by playing, not talking
- **View:** first build is a throwaway feel test — one city smash in grey-box 2D side, 2.5D (depth lanes), and low-poly 3D. He plays all three and picks.

## Assumptions (Research queue)
- **Assumption:** Godot 4.7 handles all three view styles with CC0 stand-in art (Kenney city/character kits exist for 2D and 3D).
- **Assumption:** the existing scaffold (2D side, climb, punch L/R/up, soldiers) can serve as the 2D feel-test version.
- **Assumption:** a Windows build can be exported from cloud runs and handed to him as a download (GitHub release/artifact).

## Scaffold cleanup when building
- Strip P2 key bindings (`InputMapper.gd`, `PlayerMonster.gd`).
- Rename starter monster `george` (Rampage name).
