# Reactive Event Rules & Story Simulator

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: In Design
> **Author**: Mustafa Faisal (user) + systems-designer, technical-director, ai-programmer, narrative-director (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 2 The state is a character · 3 No one is clean · 4 Consequences cross lives

## Summary

[To be designed]

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `[To be designed]`

## Overview

Reactive Event Rules & Story Simulator is the system that makes the state and the other people in Paper Walls act. Every scene is hand-written, but whether a raid, a query slip, a memo from the next desk, a courier at the gate or a review card fires, and at whom, is decided at each scene boundary by rules that read the dossier, never by a script that knows what the player did. The rules are the writers' material: who wants what (preferences), what a move needs on paper before it may happen (licences), what the world does on its own (world moves within calendar windows, drift), what may be assumed at the opening (the unknowns), and what the story may never do (the laws). The same rules are the source of two things. At design and build time they become a polyscene topic, and the story engine enumerates every admissible telling, proves which ending classes are reachable and which are forbidden by which law, and diagnoses any telling the writers ask about; that is the story simulator, and it is the acceptance criterion for the dossier budgets, the fact uses and the ending table. At runtime the same rules are evaluated by a small deterministic evaluator inside the game, at scene boundaries only, with a capped cascade and a fixed tie-break, writing the dossier through GDD 1's effect records as the `rules` writer. The system exists because Pillar 2 is only true if the state's moves are read off paper, Pillar 4 is only true if a filing in one chapter can become a raid in another without a hand-authored branch, and Pillar 3 is only enforceable if "every heroic line costs something" is a law the engine checks rather than a note the writers remember. The index describes the system as "a polyscene topic: dossier flags as fluents, rules as preferences, licences and laws; `classes()` enumerates the branches, `diagnose()` says why a branch is forbidden", evaluating at scene boundaries only, emitting events and never calling Feature code; this GDD keeps that scope. It does not own the dossier (GDD 1), the content a rule fires (GDD 2's beats and scenes), the scene-boundary order (Scene Flow), the regime phase and attention functions (Calendar), or the chapter graph (Chapter & Story Structure). Which evaluator is the source of truth and how parity between them is proved is ADR-2's decision; how the enumerated branches ship as data is ADR-3's.

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
