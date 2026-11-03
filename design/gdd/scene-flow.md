# Scene Flow

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: In Design
> **Author**: Mustafa Faisal (user) + systems-designer, gameplay-programmer, engine-programmer, creative-director (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 4 Consequences cross lives · 1 Every fact is a weapon · 5 Pressure comes from attention, not reflexes

## Summary

[To be designed]

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `Dossier State Model`, `Reactive Event Rules & Story Simulator`, `Calendar, Regime Phase & Attention`, `Scene & Interaction Framework`, `Narrative Content Format & Strings`, `Investigation & Fact System`

## Overview

*Framing: infrastructure (Category `Core`, Layer Foundation), with its player-facing effect named because the player feels this system as the rhythm of every scene. No ADR cites it yet; ADR-1 (the dossier) is to confirm the boundary bracket it drives.*

Scene Flow is the conductor of Paper Walls. It is the one system that knows what happens next: it opens a chapter, puts its first room on screen through the Scene & Interaction Framework, turns a touched hotspot into the content action it names (a document to read, a conversation to have, a decision to make), stages what the player did, and when the room is left runs the **boundary**, the fixed sequence in which everything lands at once: the decision batch into the dossier, the rules evaluated over the result, the Calendar's phase and attention read, the next room preloaded, and the reveal step that shows the player which files changed. It queues the state's inserted scene when a rule fires one, plays the tear-off when the day turns, runs the decision-free calendar beats, closes the chapter and opens the next in play order, and at the end of the act hands the ending class to the epilogue. The player never operates it and never sees it; they feel it as a room that waits while they read, a scene that ends by showing what it cost, and a knock in the next room that answers something filed in the last one. Without it the seven systems it calls would have no order among them: effects would land twice or never, rules would fire mid-scene, the simulator could not replay a telling through the same path the game runs, and Pillar 4 would have no mechanism by which a filing in one chapter becomes paper in another. It owns no game state of its own beyond where the player is; it calls the dossier, the rules evaluator, the Calendar, the fact system, the content store, the host and a presentation sink, each injected, and it runs headless on the null host so the story simulator drives it with scripted intents.

## Player Fantasy

*Framing: indirect. The player never sees Scene Flow; they feel its rhythm, a room that waits and then a page that turns. Shaped with the creative director (three candidate framings; "nothing lands until you leave the room" chosen; "the scene ends; the file opens" kept as the anchor moment, since how the reveal is drawn is Paper UI's; "the page turns without asking" left to the Calendar's transition, GDD 7).*

**Nothing lands until you leave the room.** This system serves two feelings that take turns. The first is being left alone with paper: while a scene is open, the room holds still. What you have learned is yours at once, and a fact you hold can open the next drawer. But nothing you have said or signed has reached the file yet, and nothing the state does can reach you. The second is the moment that stillness ends. You walk through the door, and everything you did in that room lands together, in one order, on every file it touches. Only then does the next room open.

The anchor moment: Vera burns the report and leaves the office. The room wipes to paper. Her own file shows one line changed, and the other two files show nothing yet. The wipe has hardly settled when the telephone rings. It is not her next scene; it is Rybar, asking politely after a copy his ledger says was sent. He hangs up, and only then does the room she chose open, the person waiting on the other side of it. The player did not see a rule fire. They saw the file change, then the state arrive, then their own scene resume, always in that order. By the third chapter they wait for the reveal the way you wait for the post.

Pillar alignment. Pillar 5, "pressure comes from attention, not reflexes": inside a scene there is no clock of Scene Flow's own. The only timed sheet is Dialogue's under interrogation, and even then the room behind it is suspended. A player can sit with a sheet as long as they like, because nothing they have done is in effect until they choose to leave. Pillar 2, "the state is a character": the state only ever answers at a boundary, after the paper has been filed, so its arrival reads as a reply, never an ambush, and it comes through the next threshold, never into the middle of the reading. Pillar 4, "consequences cross lives": the reveal is the one place the game shows that a choice in this room has reached someone else's file; a change in one dossier is noticed here and paid off in another protagonist's chapter. Pillar 3, "no one is clean": the reveal shows *which files changed*, never a verdict on whether that was right.

**The one rule this system must obey: a scene's consequences land once, all together, at its end, and the player is shown which files changed before anything else happens.** Every effect the player stages in a room (an answer, an action, the filing) waits for the boundary. The room reacts to held facts and to the file as it stood when the player walked in, never to what they have just staged. At the boundary everything runs in a fixed order that nothing can reorder: the decision, the state's answer, the phase and attention, then the reveal. Then comes at most one inserted scene, then the tear-off if the day has turned, then the next room. Scene Flow never reads a wall clock and never changes a room while the player is idle. The same intents always produce the same boundaries, in the same order, so the story simulator replays what the player felt, page for page.

*Cost accepted:* the room cannot react within a scene to what the player has just done to the file. A cruel answer in conversation shows nothing until the door, and a filing has no effect in the room where it was signed; writers write every in-room reaction against held facts or the file as it stood when the player walked in, and the payoff for the act itself waits for the next room. An inserted scene closes no boundary of its own, so what is said in it is revealed one scene late, at the end of the next authored scene. Two firings at one boundary never become two scenes: one insert plays and the other comes as a line of paper in the reveal, so the state sometimes answers quietly when the plot would like it loud. And because the only save point is the boundary, quitting mid-scene returns the player to the room's start with nothing staged.

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
