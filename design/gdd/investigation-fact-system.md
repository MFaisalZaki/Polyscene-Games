# Investigation & Fact System

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: In Design
> **Author**: Mustafa Faisal (user) + game-designer, systems-designer, narrative-director, gameplay-programmer (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 1 Every fact is a weapon · 5 Pressure comes from attention, not reflexes

## Summary

[To be designed]

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `[To be designed]`

## Overview

The Investigation & Fact System is the half of the core loop that happens before the pen touches the ledger: it turns what the player reads, examines and hears into *held facts* (a name, a date, an address, a serial), lets two held facts be tested against each other so that a connection unlocks a question, an option or a line, and keeps the fact board that shows what this protagonist knows in this chapter. A held fact is the player's, not the state's: it is never dossier state (GDD 1's sorting rule), it dies with the chapter unless a decision writes its paper, and it may unlock content only through the condition grammar's `has_fact` leaf (GDD 2 Rule 6). The system reads dossier flags for unlock conditions and never writes one. It exists because Pillar 1, "every fact is a weapon", is only true if a fact is an object the player can hold, connect and spend, and because the MVP's second requirement is exactly this: fact extraction and connection, two facts linking to unlock a question. The archivist prototype proved the loop is expressible on one screen, read → hold → connect → ask → decide, and that held facts and filed facts must be different objects. The index describes the system as depending on "Narrative Content Format & Strings, Scene & Interaction Framework, Dossier State Model (reads for unlock conditions; never writes)" and requires the simulator acceptance criterion that every authored fact has at least one dossier use; this GDD keeps that scope. It does not own the board's rendering (Paper UI), the hotspot (GDD 3), what a document says (GDD 2), the decision that spends a fact (Filing & Decision), or the line a fact unlocks (Dialogue & Interrogation).

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
