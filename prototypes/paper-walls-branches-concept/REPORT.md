# Concept Prototype Report: Paper Walls — story branches with polyscene

> **Date**: 2026-11-03
> **Prototype Path**: Paper (rules) + Engine (polyscene, Python, no game engine)
> **Concept File**: design/gdd/game-concept.md

---

## Hypothesis

The first act of Paper Walls, written as a polyscene topic, yields an admissible
branch space the engine can enumerate exhaustively, fork and diagnose fast enough
to sit in the writers' loop — evidenced by grounding under 5 s, every value of
the three axes covered, `exhausted` True, and each branch carrying the assumption
it rests on.

---

## Riskiest Assumption Tested

That the engine's narrative laws (intentional, connected, no gap, warranted,
repeat, loop-free) admit a drama's beats rather than refusing everything. Proved
out: with preferences that give every action a reason and licences on the
surprising ones, the space is non-empty and varied.

---

## Approach

A PDDL domain of 21 fluents, 2 numeric functions and 16 actions; an opening
with five agents; a topic file of 24 preferences, 13 intensity/sign rows, 6
licences, 3 unknowns, one incompatibility and three feature axes; a Scenario
subclass that narrates beats as prose. About two hours of agent time including
reading the engine.

**Path chosen:** polyscene directly (the user's own engine)
**Reason for path:** the question is whether the story engine can generate the
branches; nothing else can answer it.

**Shortcuts taken (intentional):**
- Horizon 8, one place, one neighbour, placeholder names
- The assumption layer stated in the topic (the engine commit lacks it)
- Fate read off state at the close rather than told as a world move
- No topic laws yet (Pillar 3's "every heroic line has a cost" is not enforced)

---

## Result

Run of `run.py 8` (saved in `branches-h8.txt`):

- Six cheapest tellings in 0.1 s, assumption-free first: Vera reads; Vera leaks; Jan prints and distributes; the crowd and the order; the gate opens.
- Nine behaviours on (fate, vera_choice, jan_fate), exhaustive, 0.1 s. Coverage: fate 3/3, Vera 5/5, Jan 2/2.
- Branches rest on assumptions: "fell quietly" assumes the garrison wavers; "Jan arrested" assumes Kastan loyal.
- Diagnosis of "Vera files and the regime falls quietly" returns no forbidding law: it is admissible, which exposes that Vera's filing does not yet reach the other storylines.

---

## Metrics

| Metric | Value |
|--------|-------|
| Path used | polyscene (Python) |
| Iterations to playable | 3 (vocabulary spelling; assumption layer; fate from state) |
| Prototype duration | about 2 hours |
| Playtesters | N/A (technical question) |
| Feel assessment | N/A |
| Hypothesis verdict | CONFIRMED |

---

## Recommendation: PROCEED

Polyscene is the story engine. The Reactive Event Rules & Story Simulator
system becomes a polyscene topic whose dossier flags are the fluents; the
Chapter & Story Structure system reads branches off `classes()` and `forks()`
instead of hand-authored trees; endings are behaviour classes. The engine runs
at design and build time in Python; the generated branch graph ships as data the
Godot game reads (ADR-2 and ADR-3 to state this).

---

## If Proceeding

- **Core tuning values discovered:** horizon 8 grounds in under a second; 24 preferences suffice for five agents; three unknowns give the space its "rests on" structure.
- **Assumptions confirmed:** laws keep the space sound (no silent beats, every beat motivated or in reply, every world move read).
- **Assumptions disproved:** the concept's "facts drop into a dossier" is a Fact System matter; the engine only sees what the state knows.
- **Emergent:** the leak → expose → crowd → gate chain is a cross-life consequence the writers did not author; it fell out of the preferences.

**Next steps:**
1. `/design-system dossier-state-model` with the fluent list as its schema candidate
2. `/design-system reactive-event-rules-story-simulator` as a polyscene topic specification; add the Pillar 3 cost law and the dossier-flag reads that make Vera's choice reach Jan and Tomas
3. `/architecture-decision` ADR-2 (rule format = polyscene topic; simulator = `classes()`/`diagnose()`) and ADR-3 (branch data exported for Godot)

---

## Lessons Learned

- **What assumptions were broken by building this?** The README's assumption mechanism is not in the encodings at the commit in use; the topic now states it.
- **What surprised us?** How little topic text is needed before the engine produces a readable, exhaustive flowchart.
- **What would we test differently next time?** Add the topic laws first; a space without the cost law lets courage be free, which Pillar 3 forbids.

## Note for the polyscene maintainer (draft, not submitted)

At commit 0a0e8cb: (1) `examples/toy.lp` and `tests/fixtures/*` still write `stake/3` while `laws.lp` reads `preference/4`; (2) the toy's `scheduled(dry_spell, 3)` is unsatisfiable under the new no-gap pulse unless beats precede step 3 (removing it yields 63 tellings with preferences); (3) `README.md` documents `unknown/1`, `assumed/2`, `assumptionCost/2`, `assume_min` and the `no_idle_assumption` law, none of which exist in `encodings/`; (4) `encodings/README.md`, named as the documentation of record, is absent from the repository. 39 of 46 tests fail for these reasons; the engine itself solves correctly.

> *Prototype code location: `prototypes/paper-walls-branches-concept/`*
> *This code is throwaway. Never refactor into production.*
