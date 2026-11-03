# Overlay & Surveillance Rendering

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: In Design
> **Author**: Mustafa Faisal (user) + systems-designer, technical-artist, engine-programmer, art-director, creative-director (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 5 Pressure comes from attention, not reflexes · 2 The state is a character

## Summary

[To be designed]

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `Calendar, Regime Phase & Attention` (the snapshot's tiers), `Scene & Interaction Framework` (the plate, layers and hotspots), `Settings Store` (`flicker`, `motion`, `red_as_hatching`)

## Overview

*Framing: infrastructure first (Category `Core`, Layer Foundation), with its player-facing effect named because this is the one Core system whose whole output is pixels. No ADR cites it yet; ADR-5 (the renderer) will be built from it.*

Overlay & Surveillance Rendering is the system that puts the state's attention on the screen. It never computes a tier and never reads a file: it takes the Calendar's per-boundary snapshot (the regime phase, the red reach per character, the ink reach, the stamp tier) and the scene's authored overlay data, and from them builds a plan of what to draw above the painted plate, the four layers of the art bible's overlay stack: grain on everything; the carbon ghost that makes a filed object look read; the stamp instances placed where the phase's reach allows; the red that climbs from the paper margin to the props to the state's key light and withdraws when the state collapses. It also owns the lighting switches a plate has (the lamp, the window, the threshold light when the state arrives), the Panicking flicker under the accessibility cap, and the rendering of the interrogation timer's margin fill, the one continuous motion in the game. The player never operates it; they read it: a room that is a little redder than the last one, a telephone that has turned red since this morning, a drawer that has gone carbon blue because they read what was in it. Without it Principle A ("attention has a colour") would have no pixels, Pillar 5 would have no pressure the player could see, and every other system's tiers would be numbers nobody rendered. Its logic is headless (a plan, plain data, byte-equal across hosts); its drawing lives behind a host seam with a null twin, like the Scene & Interaction Framework's, so the simulator and the unit tests run without a frame. It reads three settings (`flicker`, `motion`, `red_as_hatching`) and changes how the room is shown, never what is in it.

## Player Fantasy

*Framing: indirect. The player never sees a meter, a counter or a gradient of attention; they read it off the frame the way they read a page. Shaped with the creative director (three candidate framings; "attention has a colour" chosen, art bible §1.2 Principle A, as GDD 7 left it to this system; "a read room looks read" kept as the anchor moment's last beat, from §6.4; "the room knows what the file knows" rejected, because this system never reads the file and the room never reacts within a scene).*

**Attention has a colour.** This system serves two feelings that share one room. The first is being looked at without being told. Stamp red belongs to the state alone. It sits on the margin when the state is merely keeping records, reaches the telephone when it starts counting, and stains the light itself when it panics. Sodium is the state's light and the desk lamp is yours, and the player learns to tell them apart without being taught. The second feeling is leaving a mark. When you file something, the room keeps a carbon of it: the thing you filed carries a blue double strike, so a room you have read looks read. Red is the state reading you. Blue is what you have handed it.

The anchor moment: Vera's office, Friday 6 October, the day slot. Bone window, the lamp lit, one red stamp on the cover sheet of report 4471 in the margin of the frame, and nothing else red in the room. She files the ledger line, and the ledger's ghost appears beside it by a cut, blue and two pixels off true. In week three it is the same office at night. The window is soot, the lamp pool is lower, and the telephone and one folder on the desk are red. Nobody has said the state is paranoid. Then Rybar comes. The lamp does not dim, it is replaced: a torch through the door, a hard shadow from the threshold, a stamp on the door frame. By week five the overhead light in a portrait is red and flickers. In week six the red goes, the sodium poles go dark one by one, and the player finds this is the worst room of all. Nothing in any of these rooms counted down. The player learned to read the room the way Vera reads a file: from the edge in.

Pillar alignment. Pillar 5, "pressure comes from attention, not reflexes": the tension is how far the red has reached, and the room never makes the player hurry. The only red that moves is the interrogation timer filling the page margin, in five ticks and with no numerals, and it exists only where the pillar allows a clock. Pillar 2, "the state is a character": its moods are four kinds of light, tidy, counting, noise and ash, and it always arrives the same way: through a threshold, replacing your light with its own, never as a flash, a sting or a vignette. Pillar 4, "consequences cross lives": attention is tracked per character, so red in Jan's room can be the reach of something Vera filed. Pillar 3, "no one is clean": red is never drawn on a person, their clothing or their paper. Colour here says who is watching, never who is guilty.

**The one rule this system must obey: the plate shows the state's attention as it stood when the player walked in, in one of four steps and never on a person, and nothing on it changes state while the player reads except by the player's own act.** Red reach comes only from the tiers handed over at the boundary. The system never computes attention, never infers it from the file, and never draws a gradient the player could watch creep. A tier change lands with the next room, by a cut; a slot change is a cut; the state's arrival is a cut. Within a scene, the carbon ghost is the only thing that appears, and it appears because the player filed something. Two things move and neither is a change of state: the Panicking flicker was in the room when the player entered, at 3 Hz or less, or not at all if they asked for none; and the timer is Dialogue's clock in the margin, under interrogation only. And red never carries meaning by colour alone: every stamp and fill is a bordered shape with hatching, so a player who turns red into hatching loses the colour and keeps the lesson.

*Cost accepted:* the room cannot answer the state's interest while the player is in it. A filing that will draw the state's eye shows only its own ghost until the door, and the red arrives one room late. Attention is felt in four coarse steps, so a room looks exactly as calm one filing before it turns as it did a week earlier. Every red the player sees is authored: each room needs its margin, prop and key-light layers and its threshold light drawn by hand, and a room built without a red prop can show the Paranoid phase only in its margin. The Collapsing phase withdraws the red, and some players will read the empty room as safety; soot, loose paper and dark sodium have to carry the dread the colour no longer does. Players who turn flicker off lose the Panicking noise in the light, so the state's own misregistered paper has to carry it alone.

## Detailed Design

### Core Rules

[To be designed]

### States and Transitions

[To be designed]

### Interactions with Other Systems

[To be designed]

## Formulas

[To be designed]

## Edge Cases

[To be designed]

## Dependencies

[To be designed]

## Tuning Knobs

[To be designed]

## Visual/Audio Requirements

[To be designed]

## Game Feel

[To be designed]

## UI Requirements

[To be designed]

## Cross-References

[To be designed]

## Acceptance Criteria

[To be designed]

## Open Questions

[To be designed]
