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

*Hard* means the system cannot function without the other; *soft* means it works without it and is improved by it. Rows marked **(PROV)** name a system whose GDD is not yet written. Reciprocity today: GDD 1 lists this system as the `rules` writer with the cascade cap as Rules' own; GDD 2 lists it as the producer of `world_classes.json` and the Rules export and the owner of the `changed`/`contradicted` wrapper leaves; GDD 5 lists it as a driver of the simulator. All three match the rows below.

| System | Direction | Hard/Soft | Interface |
|---|---|---|---|
| Dossier State Model (GDD 1) | This depends on it | Hard | The effect record and the `rules` writer; `apply(batch) → [change]` inside Scene Flow's boundary bracket; change records with `contradicts`; `was_assumed`; assumptions at chapter open; the regime aggregates the phase function reads; the ending selector whose table the simulator proves total and whose E0 it proves unreachable |
| Narrative Content Format & Strings (GDD 2) | Mutual | Hard | This system reads conditions through `Condition.evaluate` and `fields_in` and needs a reader fallback for its three wrapper leaves (an amendment requested of GDD 2, Core Rule 6); compiled content supplies the player's effectful options as world actions; this system supplies `world_classes.json`, the Rules budget export (`rules_export_required`), and the beat placement of fired classes |
| Investigation & Fact (GDD 5) | Mutual | Soft | Rules never read held facts (`has_fact` is rejected in rule data); the simulator drives `hold`/`pair`/`has` by id and runs the fact-use join |
| Calendar, Regime Phase & Attention | This depends on it **(PROV)** | Hard | The beat and day counters, the phase function (a pure function of dossier aggregates; never written by rules), `phase()` for the reader, calendar windows for world moves; `calendar.*` effects are produced only here and routed by Scene Flow |
| Scene Flow | Depends on this **(PROV)** | Hard | Calls `run_boundary(ctx, apply, choices)` at the rules step inside its boundary bracket; emits `rule_fired` from the returned firings; places each fired class's beat (`insert`, `paper` or none) and routes `calendar.*` effects |
| Chapter & Story Structure | Depends on this **(PROV)** | Soft | Reads `branches.json` (classes, forks, witnesses over the game space) as data at Vertical Slice; never decides a branch from it at runtime |
| Save/Load | Depends on this **(PROV)** | Soft | The seeded RNG's `{seed, state, draws}` and the evaluator's nothing else (it holds no cross-boundary state) |
| Audio & Adaptive Surveillance Mix | Depends on this **(PROV)** | Soft | `rule_fired` events by class (a telephone, a knock, a card arriving) |
| polyscene (the story engine, pinned at commit 0a0e8cb, under the tools venv) | This depends on it at design and build time | Hard (authoring and CI) | `ScenarioEngine.outcome/forks/diagnose/classes/coverage_table` over the generated topic; the assumption mechanism stated in the generated `.lp` because the pinned encodings lack it; nothing from this repo goes upstream (coordination rule 7) |
| The story simulator (`tools/sim/`, this GDD's own tooling) | Owned here | — | `topic_gen`, the policy encoding, the exports, the headless replay runner, the parity suite; it imports the model, the content store and the evaluator, never the reverse |

## Tuning Knobs

[To be designed]

## Visual/Audio Requirements

[To be designed]

## Game Feel

Not a feel system in itself, but two feel properties follow from it.

- **The state moves only at scene boundaries.** Nothing fires mid-scene; a room never changes while the player is reading it (GDD 3's "the room waits"). The evaluation and its cascade complete within the transition, under the technical director's budget, so the paper wipe never waits on a rule.
- **A move is felt as paper, a beat late.** A fired class reaches the player as an inserted scene or a paper line at the next boundary, in the clerical passive, never as a pop-up and never explained. The dread is the lag, not a jump scare.

## UI Requirements

This system has no screen and must not have one in release builds. It owns no HUD element, no event log the player can read, and no indicator of attention or phase (those are the Calendar's signal rendered by Overlay). Debug builds only: an inspector that lists the boundary's candidates with `explain(rule_id, ctx)` (which leaves held and which failed), the firings and the cascade steps, reachable only through the debug menu and absent from release (the same rule as GDD 2's debug surfaces). The writers' tools are command-line under `tools/sim/`: the coverage table, the witness tellings, the plain-words diagnosis, the "rests on" list, the per-chapter "what fired" list and the emergent-chain report; none of them is in-game.

> **📌 UX Flag — Reactive Event Rules & Story Simulator**: no player-facing UI. The one player-visible consequence of this system, the inserted scene and the paper line, is Scene Flow's and Paper UI's; the `/ux-design` work belongs to those systems.

## Cross-References

| This GDD references | In | Owner | Nature |
|---|---|---|---|
| The effect record, the `rules` writer, batch precedence, the boundary API (`apply` × N cascade steps, the cap being Rules' own), change records with `contradicts`, `was_assumed`, assumptions and `ASSUME_BUDGET`, drift periods, regime aggregates, the ending selector and E0 | GDD 1 Core Rules 4, 4a, 5, 6, 8; Formulas §2, §3, §5, §9; Tuning Knobs | Dossier State Model | Consumed; the cascade cap, tie-break and drift rules are defined here as GDD 1's Cross-References promise |
| The condition grammar, `Condition.evaluate` with an injected reader, `fields_in`, the ban on history leaves in content and the Rules wrapper's `changed`/`contradicted` leaves, the `rules:` source citation, `world_classes.json`, the beat object keyed on class, V20's Rules export | GDD 2 Core Rules 5, 6, 7, 15; Formulas §6, §7 | Narrative Content Format | Consumed and extended (the reader fallback hook is requested) |
| Held facts never read by rules; the simulator's acceptance criterion on fact uses | GDD 5 Core Rules 5, 8, 9 | Investigation & Fact | Consumed |
| The host seam and null twin pattern; the simulator drives Scene Flow on `NullSceneHost` | GDD 3 Core Rules 8, 14 | Scene & Interaction Framework | Pattern reused |
| The 36 actions with Needs, Changes, Cost, Protects and Class; the world moves and their windows; the five unknowns; the twelve laws; the incompatible pairs; the axes and E1–E9; pacing | Narrative brief §4–§8 | Narrative | The source of the rule tables and the laws |
| The branches doc: beats keyed on class, never on path | design/narrative/paper-walls-act-one-branches.md | Narrative | The narrator convention |
| The branches prototype: act1.pddl, act1.lp, act1_topic.py, the horizon-14 results, the PROCEED verdict and the ADR-2/ADR-3 recommendation | prototypes/paper-walls-branches-concept/ | Prototype | The golden fixture and the evidence |
| polyscene: the Topic contract, `outcome/forks/diagnose/classes/coverage_table`, one action per step, the assumption mechanism absent from the pinned encodings | /home/user/polyscene README and engine.py at commit 0a0e8cb | The user's engine | The build-time evaluator |
| Pillars 2, 3, 4; the anti-pillar "not a sandbox" | design/gdd/game-concept.md | Creative direction | Player Fantasy; the laws |
| Coordination rule 7 (nothing goes upstream) | .claude/docs/coordination-rules.md | Studio | Dependencies |
| Headless CI: `--import` first, exit codes on 4.7.x | docs/engine-reference/godot/current-best-practices.md lines 180–230 | Engine reference | The replay runner |
| `RandomNumberGenerator`, `JSON` coercion, `Thread` | NOT SOURCEABLE from the pinned reference | Engine reference | Open Questions; an own PRNG |

## Acceptance Criteria

[To be designed]

## Open Questions

[To be designed]
