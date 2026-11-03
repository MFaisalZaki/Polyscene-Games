# Scene & Interaction Framework

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: In Design
> **Author**: Mustafa Faisal (user) + game-designer, ux-designer, godot-specialist, gameplay-programmer, systems-designer (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 1 Every fact is a weapon · 5 Pressure comes from attention, not reflexes

## Summary

[To be designed]

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `[To be designed]`

## Overview

The Scene & Interaction Framework is the part of Paper Walls that puts a painted room on screen and lets the player touch it. It loads a scene's isometric plate and its layers, registers the room's hotspots (a lifted paper corner, a drawer out one notch, a receiver off its cradle) under the ids the content format names, routes mouse and keyboard input into a small set of actions (focus, activate, reveal, cancel, open dossier), owns the cursor and the single focus state that hover, keyboard and a later gamepad all share, and tells Scene Flow which hotspot the player activated. It exists because every other visible system, Investigation & Fact, Dialogue, Character Presentation, Overlay Rendering and Paper UI, needs one answer to "what is on screen, where is it, and what did the player just do", and because the art bible's legibility rules (one hero, three to eight keylined hotspots, a clean figure band, no glow) are only enforceable if hotspots are registered objects rather than painted-in guesses. Whether a protagonist walks across the plate or the camera cuts between standing layers is not decided here: navigation and walkable regions are a conditional section whose activation the MVP art-pipeline proof decides. The index describes the system as "isometric plate, layers, hotspot registration, scene loading, input actions, cursor and focus; navigation and walkable regions as a conditional section decided by the MVP pipeline proof", and this GDD keeps that scope. It does not decide what a hotspot yields (Investigation & Fact), when a scene ends (Scene Flow), how a figure looks (Character Presentation), or how stamps and red are drawn (Overlay & Surveillance Rendering). Implementation questions raised here (CanvasLayer ordering, the pixel-snap setting, the stretch aspect) are recorded for the renderer and plate-authoring ADRs, not decided in this document.

## Player Fantasy

*Framing: indirect. The player sees a room, a cursor and the few objects that sit one unit off the grid; they never see the framework. Shaped with the creative director (three candidate framings; "the room is a page" chosen, with one line from "someone was here before you" and the rule from "the room waits").*

**The room is a page.** The emotion this system serves is a reader's attention. Entering a room is like turning to a new page: the player takes it in whole and at rest before touching anything, and the plate tells them which lines to read. Six or so objects are each disturbed by one unit, keylined and waiting. Moving the cursor across the room is like running a finger down a column. A corner lifts under it, the keyline thickens, and a typed slip offers one word. Nothing else answers. The cursor touches; it never knocks anything over and never moves anything the player did not choose to open.

The anchor is the drawer of the desk Vera inherited, pulled out one notch. It is the only drawer in the room that is not flush. The player sees it before they decide to look for it, and moving to it feels like reading the next word, not searching. As in Disco Elysium, the room is something you read. As in Pentiment, a hand chose every mark. A room the player has read looks read: carbon ghosts where the keylines were.

*Cost accepted:* the fantasy depends entirely on art discipline (art bible §6.3–6.6). A stray disturbance or a ninth hotspot lies to the reader, so the plate rules are load-time asserts in this system, not review notes.

**Pillar alignment.** Pillar 1, "every fact is a weapon": every marked object is there to be read and filed, and a detail that implies an unfilable fact is cut (art bible §6.5). Pillar 5, "pressure comes from attention, not reflexes": the room is the one place where the state is not watching the clock.

**The one rule this framework must obey: the room waits, and the room is fair.** The framework owns no clock and no precision test. Every hotspot is found because it is drawn. Every hotspot can be reached by focus (keyboard, later gamepad) as fully as by the pointer. Every activation is one discrete press, and the result does not depend on when the press lands, how fast, or where inside the hotspot's footprint. Required: hotspot margins of at least half the object's width; focus cycling as a full equal to the mouse; the reveal key as a guarantee that nothing is found by luck; cancel always available; if walking avatars win the pipeline proof, a click-to-walk target snaps to the hotspot's arrival point and the world never interrupts the walk. Forbidden inside this system: any timer or timed input; hold-to-complete, drag, double-click; hotspots that move, appear late, or show only on hover; sub-object pixel targets; any outcome triggered by a misclick that cannot be cancelled; any change in room state while the player is idle. Timed choices under interrogation or search, Pillar 5's one exception, belong to Dialogue & Interrogation and Scene Flow and are never a property of the room. *Design test:* could a player with a tremor, or one who has stepped away for coffee, lose anything in this room? If yes, it is a defect.

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
