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

[To be designed]

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
