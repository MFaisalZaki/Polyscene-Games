# Reactive Event Rules & Story Simulator

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: In Design
> **Author**: Mustafa Faisal (user) + systems-designer, technical-director, ai-programmer, narrative-director (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 2 The state is a character · 3 No one is clean · 4 Consequences cross lives

## Summary

Reactive Event Rules & Story Simulator is the system that makes the state and the other people act: writer-authored rule data (who wants what, what a move needs on paper, what the world does on its own, what may be assumed, what the story may never do) is compiled once and read by two consumers. At design and build time it becomes a polyscene topic, and the story engine enumerates every admissible telling, proves which endings are reachable and which are forbidden by which law, and diagnoses any telling the writers ask about. At runtime a small deterministic evaluator fires the same rules at scene boundaries only, with a fixed order, caps and a bounded cascade, writing the dossier as the `rules` writer; a parity suite proves the two agree. It exists because Pillar 2 is only true if the state's moves are read off paper, Pillar 4 only if a filing in one chapter can become a raid in another without a hand-authored branch, and Pillar 3 only if "every heroic line costs" is a law the engine checks.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Dossier State Model` (effects, change records, the ending table), `Narrative Content Format & Strings` (the condition grammar, beats by class, the player's actions), `Calendar, Regime Phase & Attention` (beats, windows, the phase function); read by Scene Flow, Chapter & Story Structure, Save/Load, Audio; polyscene at build time

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

*Drafted with the systems designer (primary), the technical director, the AI programmer and the narrative director. Rulings where they differed are stated in place. Items marked **(PROV)** rest on a system whose GDD is not yet written; one amendment to GDD 2 is applied (Rule 4). Engine facts are quoted only from the pinned reference; the rest is marked **NOT SOURCEABLE**.*

**0. Vocabulary.** A *rule* is one authored row: an NPC `move`, a `world_move`, a `drift`, an `unknown`, a `law`, an `incompatible` pair, or an `agent` preference row. A *boundary* is one `begin_boundary … end_boundary` sequence (GDD 1 Rule 4a); the *beat* is GDD 1's boundary counter within the act. A *step* is one polyscene action occurrence in the solver, which is one event, not one beat. A *candidate* is a rule whose `needs` hold and whose licence is satisfied at the current cascade step. The *policy* is the deterministic choice among candidates. A *telling* is one ordered sequence of player decisions, fired rules and world moves from act open to act close: the simulator's unit and the runtime's trace. The *world space* is every admissible telling; the *game space* is the subset the shipped policy can produce.

**1. One source of truth: writer-authored rule data; everything else is generated (ADR-2, option A).** Rules live in `assets/data/rules/<act>.rules.yaml` in GDD 2's style (the same effect and condition grammar; never ASP). The build tool `tools/sim/topic_gen.py` reads the compiled content (the player's effectful decision options and dialogue answers become the PDDL's player actions: preconditions from `when`, effects from the batch tagged `filing` or `dialogue`, principal the protagonist; effectless options are omitted because they do not branch the state), the dossier schema (fluents, ranges, defaults) and the rules file, and emits: the act's PDDL domain and instance; `act.lp` (preferences, licences, windows, drift, incompatibles, the unknowns block with `#const assume_min`, the laws' `broken/2` rules, the axes), which must state the assumption mechanism itself because the pinned polyscene encodings lack it; `policy.lp` (Rule 5); the Topic subclass; and `assets/data/rules/<act>.rules.json`, the flat compiled form the GDScript evaluator loads. Neither consumer is authoritative over the other; the parity suite (Rule 12) is the contract between them. The prototype's hand-written `act1.lp`, transcribed into the YAML, is a golden fixture (`tests/fixtures/act1-golden/`): the generator's output must be *semantically* equal (the same `classes()` table over the flow axes, the same 136 end states at the prototype's horizon, `diagnose(E0) = {no_one_unchanged}`), checked in CI, never byte-equal; when the brief changes (the V1 amendment of GDD 5 is the first such change) the fixture is re-cut formally, never edited until it passes. *Rationale:* writers never write ASP; one source cannot drift from itself; the player's actions come from content, which nobody else owns. *Rejected:* a hand-authored `.lp` exported to JSON (it makes the solver file the writers' editing surface, which the narrative director will not maintain, and hides the player's actions inside a file nobody else owns).

**2. The rule format.** Seven record kinds; fields marked `K` are keys the generator maps to `.lp` rows. Every condition uses GDD 2's grammar evaluated by the one `Condition.evaluate`; constants appear by name only.

- `move` (an NPC's action, the brief's §4 rows): `id` (`K`, `[a-z0-9_]+`, unique, cited at fire time as `rules:<chapter>/<scene>:<id>`), `agent` (`K`, a registered entity, never a protagonist), `class` (`K`, the beat key and the `world_classes.json` action class), `kind` (`K`, `C+`, `C-` or `N`), `turning_point` (`K`, meaningful for `C+`; selects `cost_is_a_person`), `priority` (0–100, default `PRIORITY_DEFAULT`), `pick` (`fixed` | `seeded`), `delay` (beats, default 0: the move becomes a candidate at the boundary `delay` beats after its needs first held, so Berta's memo arrives "a beat later"), `needs` (the grammar plus the three wrapper leaves of Rule 4), `licences` (named **any-of**; empty = always licensed; a licence may read an unknown through `was_assumed`, `needs` may not, because a need on an assumption is a hidden licence), `effects` (GDD 1 effect records; `source` is generated, never authored), `cost` and `protects` (terms over the actor's `weighs` row), `beat` (`insert` | `paper`; the protagonists' own moves are `chapter` scenes and are never rules), `crosses_to` (the receiving protagonist, for `crossing_read`).
- `agent` (one per NPC): `id`, `weighs: [{field, want: true|false|up|down, w: 1–3}]`, the preference rows the generator emits as `pref/5`; a *cost term* is a preference of the actor's that the move lowers, a *protect term* one it raises or keeps; weights are the actor's own weighing (V5 costs Berta at 3 in Berta's row and Vera lists it at 2; the law reads the actor's row); `attention` is never a term (it is weather, not a price).
- `world_move`: `id`, `class` (`K`, kind `event`), `window: [lo, hi]` (`K`, beats, inclusive, within `[1, HORIZON_ACT]`), `pick` (`fixed` = the earliest licensed beat; `seeded` = a seeded beat in the window), `licences` (named any-of), `effects`, `beat` (`insert` | `paper`).
- `drift`: `id`, `field` (a scalar, or a `calendar.*` clock **(PROV: Calendar)**), `op: add`, `value`, `period` (a constant name, e.g. `DRIFT_PERIOD_ATTENTION`), `while` (a condition; omitted = unconditional).
- `unknown`: `id`, `field` (the chapter's `assumes` entry, GDD 1 Rule 8), `licenses: [move ids]` (documentation and the licence-coverage check), `settles_as` (a tag, GDD 1's settlement rule).
- `law`: `id`, `pattern` from a closed set (`class_cost` for costless_courage, unprotected_cowardice and cost_is_a_person; `licensed_silence`; `standing_unanswered` for gap_is_noticed, gate_decides and breath_is_a_clock; `cross_read_within` for crossing_read; `touched_at_close` for no_one_unchanged; `event_at_close` for review_sits; `licensed_only` for attention_precedes_action and no_panic_before_crowd), `params`, `pillar`, `tier` (Rule 10).
- `incompatible`: state pairs, emitted verbatim and asserted at runtime in debug after every `apply`.
- `axes` and the ending classes are GDD 1's (Formulas §5); this file only cites them.

*Rationale per sub-rule:* licences as named any-of match polyscene's `licence/3` and keep `diagnose()` able to name *which* licence a telling rests on (the unknowns' whole point); cost and protect terms over the actor's `weighs` row let polyscene's gain machinery decide per step whether the actor lost or gained, with a static authoring check that a `C+` move names a cost the actor weighs, a `C-` move a protect term, and a turning point a non-`attention` cost with a person as carrier; laws from a closed pattern set keep ASP out of the writers' file. *Rejected:* a Rules-only expression language (breaks the single-evaluator invariant and the read-budget count); folding licences into `needs` (loses the diagnosis); numeric cost scores on the move (two numbers for one fact; the solver would not use them); free-form ASP bodies in YAML (option B with a wrapper).

**3. When: scene boundaries only.** The evaluator runs exactly once per boundary, inside Scene Flow's rules step, after the decision batch and before phase, attention and reveal **(PROV: Scene Flow owns the order)**; a calendar beat is a boundary with an empty decision batch **(PROV: Calendar)**. Never mid-scene, never from Feature code; the evaluator has no signal inputs and emits no signals: Scene Flow calls `run_boundary` and emits `rule_fired` from the returned list. *Rejected:* evaluating on every dossier change (the state would react inside a scene it has not yet seen, and the simulator's grain would no longer match the runtime's).

**4. Reads.** The evaluator reads only through GDD 2's `Condition.evaluate` with an injected `RulesConditionReader` that composes GDD 5's reader shape (`read`, `has_fact`, `phase`) with the boundary-local change list: `has_fact` always returns false, and the loader rejects `has_fact` in rule data (held facts are the player's, GDD 5). The wrapper adds three leaves, legal only in rule data and a V18 error in content: `{changed: F}` (a change record for F exists in this boundary so far), `{contradicted: F}` (such a record has `contradicts ≠ null`), and `{beat_in: [lo, hi]}` (the compiled form of a window, never hand-written in `needs`, because it is history by GDD 2's own rule). `was_assumed` is already a core leaf; its reader is GDD 1's `last_source`. **Amendment applied to GDD 2 Rule 6:** `Condition.evaluate` consults a reader fallback `leaf(name, args) → bool` for any leaf name outside the core grammar, so a wrapper can add leaves without re-implementing `all`/`any`/`not`. The boundary-local change list is the decision batch's records plus the evaluator's own `apply` returns; no earlier boundary is read. *Rejected:* a separate change-log reader (near-redundant; `was_assumed` reads provenance from the dossier).

**5. Evaluation: candidates, policy, fire, cascade.** For cascade step `s` from 0:
1. *Drift first.* At step 0 every `drift` whose `while` holds and whose period gate ticks (Formulas §4) is applied as one batch before any candidate is considered; drift is exempt from the caps below.
2. *Candidates.* Every `move` and `world_move` whose `needs` evaluate true against the current boundary view (pre-boundary state plus batches applied so far), whose licence any-of holds, whose `delay` has elapsed, that has not fired this boundary (one fire per rule per boundary) and, for a world move, whose window contains the beat and which has not fired this act.
3. *Policy.* Group candidates by `agent` (world moves under the pseudo-agent `world`, exempt from the per-boundary cap); in each group order by `(priority desc, id asc)` and keep `RULES_PER_AGENT_PER_BOUNDARY` (1); across groups order the survivors by the same key and keep `RULES_PER_BOUNDARY_MAX − fired_so_far` agent moves (the cap counts across all steps, so an agent cannot react to a reaction within one boundary). The ordering is total because ids are unique; a losing candidate is dropped, not queued, and is simply re-evaluated at the next step or boundary, so the evaluator holds no queue. `pick: seeded` is the one exception: among candidates of *equal* priority in one group the saved RNG chooses; **act-one data may not use it** (the generator rejects it; Open Questions).
4. *Fire.* Build one rules batch from the selected rules' effects in selection order, each effect stamped `source: rules:<chapter>/<scene>:<id>`; `apply(batch)`; append the change records to the boundary-local list; append `{rule_id, kind, class, agent, effects, source, step}` to the result.
5. *Cascade.* If the step produced at least one change record and `s + 1 < CASCADE_MAX`, repeat from 2 with `s + 1`; otherwise stop. The result carries `cascade_steps`, `truncated` (candidates remained when the cap was reached: a runtime log, a build failure in the simulator, because a telling that needs four reactions to one decision is a pacing bug, brief §8) and the fired list.

*Rationale:* the runtime is not a solver; the solver enumerates every policy and the runtime realises one, so the runtime's policy must be a function of state that the simulator can reproduce, and priority-then-id is the smallest total order the writers can read off the file. *Rejected:* a utility score summing the actor's `weighs` over the move's effects (a second preference model; when it disagrees with polyscene's gain semantics the parity test fails for reasons no writer can see); capping world moves and drift (a clock that skips a tick because Kastan was busy is a bug); a fixpoint with no cap (unprovable, and the solver's grain assumes a bound).

**6. The policy is an encoding, not a post-filter.** The generator emits `policy.lp`, switched on by a constant, that constrains the solver to the runtime's choice (`:- occurs(A, t), cand(B, t), agentOf(A, G), agentOf(B, G), prio(B) > prio(A)`, with the tie-break and the boundary grouping). Two spaces follow: the world space (policy off: what can happen) and the game space (policy on, player choices free: what the shipped game does), game ⊆ world. "E0 unreachable" is proved once in the world space and carries over; "E1–E9 reachable" is proved in the game space, because that is what players can reach. *Rationale:* a post-filter sees only a sample of tellings; `classes()` projects over the whole space only if the policy is a constraint inside it.

**7. Beats, steps and the horizon.** The beat is GDD 1's boundary counter, read and never written by Rules. In the solver one step is one action (polyscene `core.lp`), so a beat is a counter fluent that advances on every player action and world move and not on an NPC reaction, and windows and drift periods are stated over the beat fluent, never over the step index. `BEATS_PER_ACT` (12, registry) is the act's beat length; `HORIZON_ACT = BEATS_PER_ACT + HORIZON_SLACK` (14) is the beat horizon, the two slack beats being the act-close boundaries at which world moves may still fire (the review sits at the closing bell, window 10–14) but no decision is offered **(PROV: Chapter & Story Structure)**; `HORIZON_EVENTS` is the solver's step horizon, an event budget (decisions plus reactions plus world moves), set from measurement in the first sprint (the prototype's 14 steps were 14 beats because it had one action per beat; act one may need 20–30) and bounded by `GROUND_BUDGET_S`; if it fails, the simulator solves per chapter with the instance seeded from the previous chapter's end state, which the dossier as the only channel makes natural. The generator rejects a window with `hi > HORIZON_ACT`.

**8. World moves fire at the earliest licensed beat in their window; drift is anchored.** A world move whose licence holds at a boundary with beat in `[lo, hi]` fires at the first such beat, once per act; if the window closes unlicensed it never fires (the review that is never convened is a telling; `review_sits` says whether it is admissible). Under `pick: seeded` the firing beat is drawn once when first licensed and held, discarded if the licence lapses. A drift fires at a boundary iff `while` holds and `(beat − anchor) mod period = 0 ∧ beat > anchor`, where `anchor` is the beat `while` last became true; when `while` turns false the anchor clears and the count restarts, it does not resume. The generator pins the same anchoring in `driftWhile`. Breath is a Calendar clock declared here as a drift on `calendar.breath_marta` **(PROV)**, and `marta_collapses` is a world move licensed by `{at_most: [calendar.breath_marta, BREATH_ZERO]}`. *Rejected:* always-seeded windows (every playthrough differs for no authored reason and the pacing targets become statistical); a separate drift scheduler in the Calendar (two writers of `add` on one scalar with no shared order; GDD 1 names `rules` the writer for drift).

**9. A fired rule becomes a scene.** `run_boundary` returns `RulesResult {fired[], cascade_steps, truncated, calendar_effects[]}`. Scene Flow **(PROV)** takes each firing in order and, by `class` and the rule's `beat` field, resolves GDD 2's `beat(class)`: `insert` becomes an insert scene queued before the next authored scene (a person in the room with the protagonist: Rybar's call, the raid, the review card, Berta's memo, the captain reading the log, the hospital asking for papers); `paper` becomes a line in the reveal step with no scene (Kastan's slip Jan never sees, a knock at the gate, more paper on every desk, a drift tick); `calendar.*` effects are routed to the Calendar by Scene Flow, never applied by the dossier. Rules never calls Scene Flow, Feature code or the beat store; it returns a value. *Rejected:* a signal per fire (a signal is a call into whatever is connected; a returned list is replayable headlessly and keeps "Scene Flow calls Rules, never back").

**10. Laws in three tiers.** (a) *Space-level*, simulator only: all twelve brief laws plus `review_sits` and `gate_decides`, as polyscene `broken/2` over every telling. (b) *Trace-level*, CI: every runtime trace replayed through `diagnose()`; a broken law here is a policy bug, since the space already forbids it. (c) *Runtime debug asserts*, cheap and history-free: `attention_precedes_action` (a Rybar move fires only if its target is flagged or at `attention ≥ ATTN_LOOK`, enforced by its `needs` and asserted after selection), `no_panic_before_crowd` (a phase announcement fires only when licensed, by construction), the `incompatible` pairs after every `apply`, `one_file_per_household` (an incompatible), and a firing whose effects all no-op (an authoring smell). History laws (`gap_is_noticed`, `crossing_read`, `licensed_silence`, `no_one_unchanged`, `breath_is_a_clock`) are never asserted at runtime: they need beats of trace, and a violation at runtime would have no remedy but a crash. *Rejected:* a runtime law engine over the change log (a second solver; every violation it could find the CI replay finds first).

**11. The simulator (`tools/sim/`).** Four commands over one evaluator: `topic_gen` (Rule 1); `space` (`ground()`, `classes()`, `coverage_table()`, `forks()`, `diagnose()` over the world and game spaces, producing `world_classes.json` `{class, kind}` for GDD 2's V22–V24, `branches.json` `{class, witness telling, axes, assumptions, crosses}` for ADR-3 and Chapter & Story Structure **(PROV)**, `rules_export.json` with `R_c^rules` and `W_c^rules` per chapter computed from the **reachable firings in the game space** (never a static over-approximation of every rule at every boundary, which exceeds `WRITE_MAX`) for GDD 2's V20, and `fact_use.json`, the join of the Fact registry's gates against the schema for GDD 5); `replay` (headless Godot, `--import` first and retried once because exit 139 has been observed on 4.7.x, then a script that drives `NullSceneHost → Scene Flow → the evaluator` from scripted intents `decide`, `hold`, `pair`, `answer`, with NPC and world choices from the runtime policy or forced from a witness through an injected `ChoiceSource`, writing a trace); `parity` (Rule 12). Writers' outputs: one witness telling per ending class as prose with the paper line under each beat; a forbidden telling's diagnosis in plain words naming one law and the beats; the "rests on" assumption list per telling; the coverage table per axis value with a witness id per cell and empty cells named; a per-chapter "what fired" list (beat, rule, agent, class, beat type); the emergent-chain report as a named chain. Never: probabilities, scores, summed weights, raw state counts, grounding times or rankings; the engine says admissible or forbidden and why, never likely. The simulator imports the model, the content store and the evaluator, never the reverse (GDD 1 Rule 11); polyscene is pinned at commit 0a0e8cb in the tools venv (an ADR decision, because an upgrade that adds the assumption mechanism would duplicate the generated block); nothing from this repo goes upstream (coordination rule 7). The trace is JSONL, one line per boundary so a crash leaves a partial file: header `{seed, rules_hash, content_hash, tuning_hash}`, per boundary `{beat, day, scene_id, chapter_id, decision_batch, steps: [{candidates (sorted), firings, rng_draws, changes}]}`, footer `{axes, ending}`; `candidates` lets parity tell "the policy chose X" from "X was the only option"; `explain(rule_id, ctx) → {holds, failing_leaves[]}` serves diagnosis parity and the debug inspector.

**12. Parity and acceptance.** Two directions. *Completeness (solver → runtime):* every polyscene witness telling, its NPC and world choices forced through the `ChoiceSource`, is realised by the runtime through Scene Flow on `NullSceneHost` and ends with the same key-axis values and ending class; a forced choice that is not a candidate fails as `CHOICE_NOT_ADMISSIBLE {rule, failing_leaves}`, which is the parity signal. *Soundness (runtime → solver):* every runtime trace, pinned as `occurs(a, t)` facts, returns `diagnose() = ∅` (an empty list means admissible; `None` means the physics itself forbids the trace, an encoder bug, and also fails). Because the policy is deterministic and act-one data has no RNG, the runtime tree branches only on player inputs, so CI enumerates the player-input tree exhaustively (a DAG merged by `(boundary, dossier digest)`), replays every leaf and diagnoses each: at MVP tens of traces, exhaustive verification rather than sampling; if the tree later exceeds `PLAYER_DAG_MAX` leaves, CI falls back to `SIM_RUNS_CI` seeded runs and records the fallback as debt. Acceptance: E1–E9 each reachable with a witness in the game space; E0 unreachable in the world space and `diagnose(E0)` names exactly `{no_one_unchanged}`; every axis value reachable; `act_fallback` selected in no witness (GDD 1 Formulas §5); `ground()` within `GROUND_BUDGET_S` at `HORIZON_EVENTS`; admissibility and realisability rates equal `PARITY_MIN`; the golden act-one fixture regenerates in meaning; every effectful content option maps to exactly one generated action and the reverse (`Topic.check()` under warnings-as-errors is a gate).

**13. The MVP rule file and its reactive event (content, not rules; the narrative director's enumeration).** `act1-mvp.rules.yaml` holds V1–V3's player actions (from content), R1 `query_ledger` (Rybar, `N`, needs `(is_true vera.discrepancy ∨ (is_true office.border_report ∧ ¬filed) ∨ at_least [vera.attention, ATTN_LOOK]) ∧ ¬is_true vera.under_observation`, no licence, effects `vera.under_observation set true`, `vera.attention add 2`, `beat: insert`, priority 70), K1 `inform` (Kastan, `C-`, licences `rewarded: is_true kastan.rewarded` or `loyal: was_assumed kastan.rewarded`, effects `jan.under_observation set true`, `jan.attention add 1`, protects `kastan.rewarded`, `beat: paper`), B1 `report_colleague` (Berta, `C-`, needs `knows_gap(berta)` as the derived `is_true vera.discrepancy ∨ is_true vera.carbon_missing` and `¬is_true berta.reported`, licences `implicated` or `years: was_assumed berta.reported`, effects `berta.reported set true`, `vera.under_observation set true`, `vera.attention add 2`, `berta.implicated set false`, protects `berta.implicated` wanted false at 3, `beat: insert`, `delay: 1`), the attention drift, and laws 1, 5, 6 and 10. The reactive event is R1 at the boundary that closes Vera's turn scene, cascade step 0, after V3 wrote `vera.discrepancy`; the insert scene `rybar_query_ledger` plays before "the person" scene; B1 is also a candidate at that boundary (V3 sets the gap and `berta.implicated`) and `delay: 1` makes it the next boundary's event, so the MVP boundary carries exactly one, and B1 becomes the act-one test of `gap_is_noticed`. On the V2 branch `discrepancy` stays false and `vera.attention` stays 0, so R1 does not fire and the test asserts the silence; K1 fires and writes only Jan's dossier, which is Pillar 4 working. The regime announcement `regime_paranoid` (a world move, window `[PARANOID_EARLIEST, HORIZON_ACT]`, licences any of `jan.leaflets_distributed`, `vera.discrepancy`, `office.border_report`, `kastan.exposed`, effects `regime.paranoid set true`, `regime.phase_reached max 1`, `regime.stability add −1`, `attention add 1` for every agent at `attention ≥ 1`, `beat: paper`) never writes a phase: the phase stays GDD 1's pure function of the aggregates, and the writers extend the state's turns by adding licensing facts, never by setting a phase (the reconciliation with GDD 1 Formulas §2 is a Calendar question). Act two is not in the act-one file: `crowd_gathers`, `regime_wavers`, `regime_panics`, the `garrison_wavers` unknown, the panicking and collapsing phases, windows beyond `HORIZON_ACT`, the second review sitting. The prototype-only world moves `ledger_called`, `press_runs_dry` and `review_convened` are re-homed as `paper` world moves on calendar windows (the narrative director confirms).

**14. What the system cannot do.** Never writes a phase; never reads a held fact; never fires mid-scene; never calls Feature code; never explains itself to a character (the clerical passive is a content rule, GDD 2 Rule 11); never uses randomness unless content marks it and the seed is saved; never persists anything but its per-act state (`fired_this_boundary`, `drift_anchor[]`, `world_move_state[]`, the RNG) through Save/Load **(PROV)**; never holds dossier state. The RNG, when used, is a small own generator (xorshift32, seed 0 remapped, `{seed, state, draws}` serialised, a Python twin bit-for-bit, a golden list of the first 1,000 draws checked in), because the engine's `RandomNumberGenerator` seed persistence and cross-platform stability are **NOT SOURCEABLE** (GDD 1's spike).

### States and Transitions

**Per rule instance, within one boundary (reset at `end_boundary`):** `dormant` (needs false or unlicensed) → `candidate` (needs and licence hold, delay elapsed, not spent) → `selected` (survived the policy) → `fired` (effects applied, in the result) → `spent` (cannot fire again this boundary). `candidate` → `deferred` when it lost the policy; a deferred rule may be a candidate again at the next step or boundary.

**World moves, per act:** `pending` (beat < lo) → `open` (beat in the window) → `armed` (licensed; `pick: seeded` draws its beat here) → `fired` (terminal for the act) or `lapsed` (beat > hi, terminal).

**Drift, per act:** `idle` (while false; anchor null) → `counting` (while true; anchor set) → ticks `fired` at each period multiple → `idle` when while turns false (anchor cleared).

**The evaluator:** `idle` → `evaluating` (inside Scene Flow's rules step) → `idle`; its state is `fired_this_boundary`, `drift_anchor[]`, `world_move_state[]`, `delay_anchor[]` and the RNG, all serialised by Save/Load **(PROV)**; it holds no dossier state and no queue.

### Interactions with Other Systems

| System | In (to Rules) | Out (from Rules) | Interface owner |
|---|---|---|---|
| **Dossier State Model** (GDD 1) | Reads through the reader; the boundary's change records (`changed`, `contradicted`); `was_assumed` from provenance; the schema as the fluent set; `apply` passed in by Scene Flow | Rules batches (writer `rules`) including drift, world moves, `regime.*`, `status`; the cascade cap, tie-break and drift semantics GDD 1 delegates here | GDD 1 owns reads and effects; Rules owns rule format, cascade, tie-break |
| **Narrative Content Format** (GDD 2) | `Condition.evaluate` with the reader fallback; compiled decision and dialogue effects as player actions; beats by class | `world_classes.json`; `rules_export.json` (V20, reachable firings); the Rules-only leaves and the V18 rule against them in content | GDD 2 owns the grammar; Rules owns its wrapper |
| **Scene Flow (PROV)** | `run_boundary(ctx, apply, choices)` at the rules step; the beat, day, chapter and scene ids for `source` | `RulesResult` (fired list, `calendar.*` effects, `truncated`) | Scene Flow calls Rules; never back |
| **Calendar, Regime Phase & Attention (PROV)** | `phase()` for the reader; the beat and day; calendar windows | `calendar.*` effects via Scene Flow; drift ticks; the announcement moves' aggregate writes | Phase is never written by Rules |
| **Investigation & Fact** (GDD 5) | The Fact registry for the use join | `fact_use.json`; the simulator's `hold`/`pair`/`has` driving | Rules never reads held facts |
| **Chapter & Story Structure (PROV)** | Nothing (the simulator never reads chapter structure) | `branches.json` | One direction |
| **Save/Load (PROV)** | `deserialize` of the evaluator's per-act state and the RNG | `serialize()` | Save/Load owns the save; Rules owns the shape |
| **Audio (PROV)** | Nothing | `rule_fired` by class, through Scene Flow | Audio |


## Formulas

*Proposed by the systems designer; the RNG from the AI programmer. Conventions as GDD 1: `[p]` is the Iverson bracket; values are integers unless stated; constants are names in `assets/data/rules/tuning.json` (D) or GDD 1's (by pointer).*

### 1. Candidate selection key

The selection formula is defined as:

`key(r) = (−priority(r), id(r))`; within a group `sel_agent = sort_key(candidates(agent))[0 : RULES_PER_AGENT_PER_BOUNDARY]`; across groups `sel = sort_key(∪ sel_agent)[0 : RULES_PER_BOUNDARY_MAX − fired_so_far]` for agent moves, with world moves appended unbounded; under `pick: seeded`, ties on `priority` within one group are broken by `rng.next_int(n)` instead of `id`.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `priority(r)` | int | 0–100 | data file (rule) | Authored ordering; default `PRIORITY_DEFAULT` |
| `id(r)` | string | `[a-z0-9_]+` | data file | Lexicographic tie-break; unique, so the order is total |
| `fired_so_far` | int | 0–`RULES_PER_BOUNDARY_MAX` | calculated | Agent fires already applied this boundary, all steps |
| `RULES_PER_AGENT_PER_BOUNDARY` | int | 1–2 | constant (1) | Fires per agent per boundary |
| `RULES_PER_BOUNDARY_MAX` | int | 1–8 | constant (4) | Agent fires per boundary across steps; world moves and drift exempt |
| `sel` | list | 0–`RULES_PER_BOUNDARY_MAX` + world moves | calculated | Rules fired this step, in order |

**Output Range:** a list of length 0 to the remaining cap plus world moves, total and deterministic. **Example:** Vera's s3 boundary after `burn_report`: candidates `r1_query_ledger` (rybar, 70), `b1_report_colleague` (berta, 60, `delay: 1` so not yet), `b2_cover_vera` (berta, 55) → `[r1, b2]`; cap 4 → both fire; at step 1 nothing new → stop. *Rejected:* a utility score from `weighs` (a second preference model).

### 2. Cascade bound

The cascade bound is defined as:

`fires_max = RULES_PER_BOUNDARY_MAX` (agent moves, across steps); `steps ≤ CASCADE_MAX`; `truncated = [candidates(step = CASCADE_MAX) ≠ ∅]`.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `CASCADE_MAX` | int | 1–5 | constant (3) | Re-evaluation steps per boundary |
| `steps` | int | 1–`CASCADE_MAX` | calculated | Steps run |
| `truncated` | bool | — | calculated | Runtime: logged; simulator: build failure |

**Output Range:** bounded; one step minimum (no change), `CASCADE_MAX` maximum; cycles are impossible by construction because each rule fires at most once per boundary. **Example:** decision → K2 (step 0) → R1 reads `under_observation` (step 1) → nothing (step 2 ends early): `steps = 2`. *Rejected:* an unbounded fixpoint.

### 3. World-move firing beat

The world-move beat is defined as:

`b_fire(m) = min{b ∈ [lo, hi] : licensed(m, b)}` for `pick: fixed`; for `pick: seeded`, `b_fire = b_arm + rng.next_int(hi − b_arm + 1)` drawn once at `b_arm` (the first licensed beat) and discarded if the licence lapses before it; `b_fire = ∅` if never licensed in the window.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `lo`, `hi` | int | 1–`HORIZON_ACT`, `lo ≤ hi` | data file | Window in beats |
| `licensed(m, b)` | bool | — | calculated | Any licence true at beat `b` |
| `b_arm` | int | `[lo, hi]` | calculated | First licensed beat |
| `b_fire` | int or ∅ | `[lo, hi]` | calculated | Firing beat |

**Output Range:** in the window or empty. **Example:** `inquiry_at_post [5, 10]`, `border.log_gap` set at beat 3 → `b_fire = 5`; the gap covered at 4 and `log_covered` licensing → still 5. *Rejected:* always-seeded windows.

### 4. Drift tick

The drift tick is defined as:

`tick(d, b) = [while(d, b)] · [b > a_d] · [(b − a_d) mod period_d = 0]`; the effect `add value_d` applies when `tick = 1`; `a_d` is the beat at which `while` last became true, cleared when it turns false.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `period_d` | int | 2–8 (0 off) | constant name (`DRIFT_PERIOD_ATTENTION` 3, `DRIFT_PERIOD_STABILITY` 3, GDD 1) | Beats per point |
| `value_d` | int | −2–+2 | data file | Signed step |
| `a_d` | int or null | 0–`HORIZON_ACT` | calculated (evaluator state) | Anchor beat |
| `tick` | int | 0–1 | calculated | Fire this beat |

**Output Range:** 0 or 1; the scalar is clamped by GDD 1's `scalar_apply`; over an act a drift contributes at most `⌊(HORIZON_ACT − a_d) / period⌋ · value`. **Example:** `vera.discrepancy` true at beat 3 → `vera.attention +1` at 6, 9, 12; with V3's own +1 the count reaches `ATTN_LOOK` at beat 9, which is why R1's flag licence, not the number, is what the writers rely on (`gap_is_noticed` needs an answer by beat 7). *Rejected:* stateless `beat mod period` (a drift that began at beat 4 would tick at 6, not 7, and the generator could not pin the same reading).

### 5. Parity predicate

The parity predicate is defined as:

`parity(T) = [diagnose(T) = ∅] ∧ ⋀_i [K_i^rt(T) = K_i^sol(T)] ∧ [ending^rt(T) = ending^sol(T)]`; `adm = |{T ∈ RUNS : diagnose(T) = ∅}| / |RUNS|` (soundness) and `real = |{W ∈ WITNESSES : axes and ending match}| / |WITNESSES|` (completeness); both must equal `PARITY_MIN`.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `K_i^rt`, `K_i^sol` | enum | per key axis | calculated | Axis `i` at close, runtime versus solver |
| `RUNS` | set | the player-input DAG's leaves, or `SIM_RUNS_CI` seeded runs on fallback | calculated | Runtime traces |
| `WITNESSES` | set | one per ending class | calculated (`branches.json`) | Forced replays |
| `PLAYER_DAG_MAX` | int | 100–5,000 | constant (1,000) | Leaves above which CI falls back to sampling (recorded as debt) |
| `SIM_RUNS_CI` | int | 20–200 | constant (50) | Seeded runs on fallback |
| `PARITY_MIN` | float | 0.9–1.0 | constant (1.0) | Required rate |

**Output Range:** 0.0–1.0 each; the build fails below `PARITY_MIN`, naming the trace and the law (`adm`) or the axis (`real`), so a failure says "policy bug" or "realisation bug". **Example:** 23 DAG leaves and 9 witnesses, one leaf whose end state the solver calls `broken(crossing_read)` → `adm` 22/23 → fail naming the trace and the law. *Rejected:* a sampled rate accepted below 1.0 (an inadmissible telling would ship).

### 6. Coverage

The coverage formulas are defined as:

`class_cov = |{c ∈ C_req : witness_game(c)}| / |C_req|`; `axis_cov = Σ_a |reach(a)| / Σ_a |dom(a)|`; `e0_ok = [¬witness_world(E0)] ∧ [diagnose(E0) = {no_one_unchanged}]`; `fallback_ok = [∀ W : ending(W) ≠ act_fallback]`.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `C_req` | set | E1–E9 | data file (GDD 1's ending table) | Required classes |
| `reach(a)`, `dom(a)` | sets | per axis | calculated / data file | Reachable and declared values |
| `class_cov`, `axis_cov` | float | 0.0–1.0 | calculated | Must both be 1.0 |
| `e0_ok`, `fallback_ok` | bool | — | calculated | Must be true |

**Output Range:** 0–1 and booleans; acceptance needs 1.0, 1.0, true, true. **Example (prototype, world space):** 9/9, every axis value, E0 by exactly one law → pass; the game-space run is the one that must also pass. *Rejected:* a class threshold below 1.0.

### 7. Grounding-time budget

The grounding check is defined as:

`ground_ok = [median_{GROUND_SAMPLES}(t_ground(HORIZON_EVENTS)) ≤ GROUND_BUDGET_S]`

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `t_ground` | float s | > 0 | measured | polyscene `ground()` wall time |
| `HORIZON_ACT` | int | 12–16 | constant (14 = `BEATS_PER_ACT` + `HORIZON_SLACK` 2) | Beat horizon |
| `HORIZON_EVENTS` | int | 14–40 | constant (set from measurement; prototype 14) | Solver step horizon |
| `GROUND_BUDGET_S` | float s | 2–15 | constant (5) | CI budget |
| `GROUND_SAMPLES` | int | 1–5 | constant (3) | Median sample count |

**Output Range:** boolean. **Example:** the prototype grounds in 1.3 s at 14 steps; act one at 24 steps is the first measurement; if it fails, solve per chapter (Rule 7). *Rejected:* a budget per `classes()` call only (grounding is the fixed cost every call pays).

### 8. Seeded RNG

The RNG is defined as:

`s ← s ⊕ (s ≪ 13); s ← s ⊕ (s ≫ 17); s ← s ⊕ (s ≪ 5)` over 32 bits; `next_int(n) = s mod n`; seed 0 is remapped to `0x9E3779B9`.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `seed` | int | 1–2³²−1 | data file (Save/Load) | The saved seed |
| `s` | int | 32-bit | calculated (evaluator state) | Current state |
| `draws` | int | ≥ 0 | calculated | Draws consumed; a replay asserts the same count |
| `n` | int | 2–8 | calculated | Candidates or window length |

**Output Range:** `[0, n)`; modulo bias is irrelevant at `n ≤ 8`. **Example:** seed 1, the first 1,000 draws equal a checked-in golden list produced by the Python twin. *Rejected:* the engine's `RandomNumberGenerator` (seed persistence and cross-platform stability **NOT SOURCEABLE**).

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

All in `assets/data/rules/tuning.json` (D) unless marked GDD 1 (by pointer) or B (CI config).

| Knob | Default | Safe range | Too low | Too high | Interacts with |
|---|---|---|---|---|---|
| `CASCADE_MAX` (D) | 3 | 1–5 | The state reacts once and stops; K2 → R1 chains need two boundaries | Four reactions to one decision; pacing breaks; `truncated` never trips | `RULES_PER_BOUNDARY_MAX` |
| `RULES_PER_AGENT_PER_BOUNDARY` (D) | 1 | 1–2 | — | Berta reports and covers in one beat; preference ordering stops meaning anything | `priority` |
| `RULES_PER_BOUNDARY_MAX` (D) | 4 | 1–8 | Rules starve; `gap_is_noticed` fails in the simulator | Every beat is a state beat; the brief's 2–3 state beats per telling are exceeded | `CASCADE_MAX`; product ≤ 12 |
| `PRIORITY_DEFAULT` (D) | 50 | 0–100 | — | — | per-rule `priority` |
| `HORIZON_SLACK` (D) | 2 | 0–3 | The review window cannot sit; E1 and E6 unreachable | Grounding time; tellings the runtime cannot reach | `BEATS_PER_ACT` (GDD 1), `GROUND_BUDGET_S` |
| `HORIZON_EVENTS` (D) | measured (14 at the prototype) | 14–40 | Admissible tellings cut short; endings unreachable in the solver | Grounding over budget | `GROUND_BUDGET_S`; per-chapter solving |
| `PARANOID_EARLIEST` (D) | 6 | 4–8 | The state turns in week one | The announcement never fires in act one | GDD 1 Formulas §2; the Calendar |
| `BREATH_ZERO` (D) | 0 | 0–1 | — | Marta collapses with breath left | Calendar clock **(PROV)** |
| `GROUND_BUDGET_S` (B) | 5 | 2–15 | CI flakes on slow runners | A regression in the space goes unnoticed | `HORIZON_EVENTS` |
| `GROUND_SAMPLES` (B) | 3 | 1–5 | Noise fails the gate | CI time | `GROUND_BUDGET_S` |
| `PLAYER_DAG_MAX` (B) | 1,000 | 100–5,000 | CI falls back to sampling too early | CI time | `SIM_RUNS_CI` |
| `SIM_RUNS_CI` (B) | 50 | 20–200 | Rare policy paths untested on fallback | CI time | `PARITY_MIN` |
| `PARITY_MIN` (B) | 1.0 | 0.9–1.0 | Inadmissible tellings ship | — (1.0 is the design intent) | `SIM_RUNS_CI` |
| `SIM_JOB_BUDGET_MIN` (B) | 10 | 5–20 | The simulator is skipped on busy runners | Nobody runs it locally | the whole simulator job |
| Drift periods, `ATTN_LOOK`, `ASSUME_BUDGET`, `BEATS_PER_ACT` | GDD 1's | by pointer | — | — | Read here by constant name, never redefined |

Interaction clusters: (a) `RULES_PER_BOUNDARY_MAX × CASCADE_MAX` bounds agent fires per boundary; keep the product at or below 12 or the simulator's pacing checks lose meaning; (b) `HORIZON_EVENTS` and `GROUND_BUDGET_S` move together, and per-chapter solving is the release valve; (c) `PLAYER_DAG_MAX` and `SIM_RUNS_CI` set the verification depth together, exhaustive first.

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

| Question | Owner | Needed by | Status |
|---|---|---|---|
| ADR-2 (rule format and evaluation semantics) and ADR-3 (branch data for Godot), as the technical director drafted them: rules JSON as the single semantic source; `topic_gen`; the deterministic policy with caps, cascade and quiescence; the parity suite (witness completeness, diagnose soundness over the exhaustive player-input DAG, game ⊆ world); polyscene pinned at 0a0e8cb; `world_classes.json` and `branches.json` as build artefacts versioned with the rules digest and read as data only | technical-director via `/architecture-decision` | Before Technical Setup | Open; this GDD is the input |
| The regime phase: GDD 1 Formulas §2 computes it from stability and unrest thresholds; this GDD's announcement move is licensed by facts and writes the aggregates. Confirm the two compose (facts license the announcement; the announcement moves the aggregates; the function reads them) and whether `PARANOID_EARLIEST` belongs here or in the Calendar | Calendar, Regime Phase & Attention GDD; Dossier owner | Calendar GDD | Open; assumed to compose |
| `HORIZON_EVENTS`: measure grounding at act one's real event count in the first sprint; if over `GROUND_BUDGET_S`, solve per chapter seeded from the previous chapter's end state; make drift a derived fluent of the beat where the encoding allows | technical-director, systems-designer | First sprint of Technical Setup | Open |
| The golden act-one fixture must be re-cut after GDD 5's V1 amendment to the brief (the parcel link), never patched; the generator's semantic equivalence is measured against the re-cut fixture | systems-designer, narrative-director | Before the simulator's first CI run | Open |
| Whether the two slack beats exist as act-close boundaries (chapter close, act epilogue) with no decision offered, so the review can sit at the closing bell | Chapter & Story Structure GDD | Vertical Slice | Open; assumed yes |
| The prototype-only world moves `ledger_called`, `press_runs_dry`, `review_convened` are re-homed as `paper` world moves on calendar windows; the brief's §4 names are canon | narrative-director | Act-one rule file | Open; confirm |
| The MVP insert scene `rybar_query_ledger`: text and staging (the office telephone, Rybar polite, asking for the week's ledger with 4471's line; Vera's replies as dialogue) | narrative-director, writer | MVP content | Open |
| The `agent.weighs` rows for every NPC (the preference table) and the cost and protect terms per move: the writers fill the authoring table from the brief's §4 columns | narrative-director, writer | Act-one rule file | Open |
| The seeded RNG: `RandomNumberGenerator` seed persistence and cross-platform stability are NOT SOURCEABLE; the own xorshift32 with a Python twin stands until a spike says otherwise; act one uses no randomness | technical-director (GDD 1's spike list) | Before any `pick: seeded` content | Open |
| polyscene at commit 0a0e8cb lacks the assumption mechanism its README documents; the generated `.lp` states it; an engine upgrade would duplicate it. A draft note for the maintainer exists in the prototype's REPORT; nothing goes upstream from this repo (coordination rule 7); the user submits it if they choose | user | Whenever polyscene is upgraded | Open |
| Which laws the writers extend for act two (the crowd clause, act-two cross-life flags and turn sets, the garrison as a licensed agent, attention under a crowd) | narrative-director | Act two design | Open; recorded from the narrative director |
| Performance budgets proposed in Acceptance Criteria (evaluate per step, cascade, the simulator job) | technical-director | ADR | To be confirmed |
