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

*Framing: indirect. The player never sees a rule; they see the state move. Shaped with the creative director (three candidate framings; "the state keeps its books" chosen, with one line from "it had been looking for weeks"; "the answer comes to someone else" left as GDD 1's payoff, not this system's identity).*

**The state keeps its books.** The emotion this system serves is being audited, not being hunted. The state is not angry and it is not clever. It is thorough. Every page that leaves a desk is expected somewhere else, and every gap is noticed.

The anchor moment: Vera burns the report. The scene ends quietly and nothing happens in the archive. A beat later, in the next scene, the telephone on her desk rings. It is Rybar. He is polite and he does not raise his voice. He only asks whether the report reached her, because his copy shows it was sent. He accuses no one. He is balancing a ledger, and the player feels the column that does not add up.

Pillar 2 as feel: the state is a character with habits the player comes to recognise. It always balances the ledger. It never strikes where it has not looked. Its attention is visible before its action, so its action reads as a verdict on what the player failed to see, not as an ambush. As it moves from confident to paranoid it does not get crueller; it sends more paper, thicker and closer together, not louder. The dread is that the player can see where its next query is going to land.

*Cost accepted:* the state can only answer what can be framed as a discrepancy. Every reactive event needs a "missing or contradicting page" reading, which narrows what writers can author.

**Pillar alignment.** Pillar 2, "the state is a character": every move is a habit read off paper, never a script. Pillar 3, "no one is clean": the laws make a costless heroic line and a protectionless cowardly line impossible in the world, not merely discouraged. Pillar 4, "consequences cross lives": a filing in one chapter licenses a move in another without a hand-authored branch.

**The one rule this system must obey: the state only moves on paper the player could have read, and when that paper is there, it always moves.** The first half keeps the state from being a random hazard: nothing fires without a cause in the dossier that a protagonist wrote, read, filed, withheld or was seen near. The second half keeps it from being a scripted villain: if the licence is there, the move comes, every time, whatever the plot would prefer; remove the licence and the move cannot happen. Two clarifications carried into Detailed Design: calendar clocks are the world, not the state (Marta's collapse and the review convening run on time, but the state's response to them, the ambulance, who gets summoned, must still be licensed by the dossier); and the state speaks only in the clerical passive (*a query was raised*, *the line was disconnected*), never naming a cause to a character, so the brief's "nobody is told what they did to the others" holds by construction.

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
