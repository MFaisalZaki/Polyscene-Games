# Systems Index: Paper Walls

> **Status**: Draft
> **Created**: 2026-11-03
> **Last Updated**: 2026-11-03
> **Source Concept**: design/gdd/game-concept.md
> **Technical Director Review (TD-SYSTEM-BOUNDARY)**: CONCERNS (applied) 2026-11-03 — effect-record dossier API, Scene Flow system, persistence contract, Settings Store split, simulator decoupled from chapter structure, phase as a pure function at MVP.
> **Producer Review (PR-SCOPE)**: OPTIMISTIC (adjustments applied) 2026-11-03 — 17 MVP GDDs merged to 13; MVP clock restated as 8–12 weeks from 2026-11-03 including design and Technical Setup; slice 5–8 months; `/prototype` of the archivist scene recommended now.
> **Creative Director Review (CD-SYSTEMS)**: CONCERNS (applied) 2026-11-03 — per-character attention signal added to system 7; Scene Flow gains a reveal-changes step; Paper UI gains the fact board; dossier views owned by GDD 1; two-protagonist slice floor planned in advance (option B).

---

## Overview

Paper Walls is mechanically small and data-heavy. The 30-second loop is read → connect → file: documents, objects and lines yield facts; connected facts unlock questions; a scene ends in a filing or decision that writes to the **living dossier**, the per-character state-security file that is the game's central object (Pillar 1: every fact is a weapon; Pillar 2: the state is a character). Everything else serves that object. The dossier is the only channel between the three protagonists' storylines (Pillar 4: consequences cross lives), so it is the project's bottleneck by design: a single, fixed-schema model with one effect-record mutation API, read by rules, rendering, audio and UI, and written only by Filing & Decision, Reactive Event Rules and Dialogue through tagged effect records. Facts the player holds are not dossier state; they live in Investigation & Fact. A pure function of dossier aggregates yields the **regime phase** (confident → paranoid → panicking → collapsing) that rendering and audio read instead of raw dossier fields. **Scene Flow** owns the deterministic scene-boundary sequence: decision → effects → rules → phase → calendar → next scene or save. Rules evaluate only there, in a single pass or capped cascade with a deterministic tie-break, and emit events that scenes, dialogue and rendering subscribe to; the **Story Simulator** runs the same headless evaluator over rule and content data to prove every ending reachable. Presentation is one paper language (art bible): a Paper UI that is split into dossier, document and HUD systems once the second and third dossier views arrive at the slice. Audio is phase-driven. Character presentation (walking sprites or standing layers) is deliberately a stub until the MVP art-pipeline proof decides it.

Relationship analysis: four systems carry most of the dependency weight — Dossier State Model (11 dependents), Narrative Content Format & Strings (8), Scene & Interaction Framework (5) and Calendar & Regime Phase (6). The first two are designed first and time-boxed; the others are mid-order. The headless boundary is a hard rule: Dossier, Investigation & Fact, Rules, Phase, Scene Flow and Filing are pure logic with no Node or SceneTree dependency, so the simulator and the unit tests run under `--headless` on the same code the game runs. Asset Pipeline Tools (export script, offset sidecars, red-budget gates) are build-time tooling under `tools/`, specified in art bible §8 and ADR-6, and are not a runtime system. Accessibility requirements are written into the systems that implement them (timer modes in Dialogue, red-as-hatching and flicker limits in Overlay Rendering, UI scale and AccessKit roles in Paper UI) and recorded project-wide in `design/accessibility-requirements.md` by `/ux-design`.

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | Dossier State Model | Core | MVP | Not Started | — | — |
| 2 | Narrative Content Format & Strings (inferred) | Narrative | MVP | Not Started | — | — |
| 3 | Scene & Interaction Framework (inferred) | Core | MVP | Not Started | — | — |
| 4 | Settings Store (inferred) | Meta | MVP | Not Started | — | — |
| 5 | Investigation & Fact System | Gameplay | MVP | Not Started | — | Narrative Content Format & Strings, Scene & Interaction Framework, Dossier State Model (read only) |
| 6 | Reactive Event Rules & Story Simulator | Gameplay | MVP | Not Started | — | Dossier State Model, Narrative Content Format & Strings, Calendar & Regime Phase |
| 7 | Calendar, Regime Phase & Attention | Core | MVP (phase and per-character attention) / Vertical Slice (calendar) | Not Started | — | Dossier State Model |
| 8 | Scene Flow (inferred) | Core | MVP | Not Started | — | Dossier State Model, Reactive Event Rules & Story Simulator, Calendar, Regime Phase & Attention, Scene & Interaction Framework, Paper UI (reveal step hands change records to it) |
| 9 | Overlay & Surveillance Rendering (inferred) | Core | MVP | Not Started | — | Scene & Interaction Framework, Calendar & Regime Phase, Settings Store |
| 10 | Character Presentation (inferred) | Core | MVP (stub) / Vertical Slice (full) | Not Started | — | Scene & Interaction Framework |
| 11 | Dialogue & Interrogation | Narrative | MVP (no timers) / Vertical Slice (timers) | Not Started | — | Narrative Content Format & Strings, Investigation & Fact System, Dossier State Model, Scene & Interaction Framework, Settings Store |
| 12 | Filing & Decision | Gameplay | MVP | Not Started | — | Investigation & Fact System, Dossier State Model, Narrative Content Format & Strings |
| 13 | Paper UI (inferred) | UI | MVP (archivist dossier view, fact board where held facts click together, document and transcript sheets, scene-end change reveal, minimal HUD) / Vertical Slice (split into Dossier UI, Document & Transcript UI, HUD, Menus & Calendar UI) | Not Started | — | Dossier State Model, Character Presentation, Overlay & Surveillance Rendering, Narrative Content Format & Strings, Investigation & Fact System, Dialogue & Interrogation, Settings Store |
| 14 | Chapter & Story Structure | Narrative | Vertical Slice | Not Started | — | Dossier State Model, Narrative Content Format & Strings, Calendar & Regime Phase, Scene Flow |
| 15 | Save/Load (inferred) | Persistence | Vertical Slice (contract at MVP) | Not Started | — | Persistence registry: every stateful system (1, 5, 6, 7, 13, 14) exposes serialize/deserialize with a schema version |
| 16 | Audio & Adaptive Surveillance Mix (inferred) | Audio | Vertical Slice | Not Started | — | Calendar & Regime Phase, Reactive Event Rules & Story Simulator, Dialogue & Interrogation |

---

## Categories

| Category | Description | Typical Systems |
|----------|-------------|-----------------|
| **Core** | Foundation systems everything depends on | Dossier State Model, Scene & Interaction Framework, Calendar & Regime Phase, Scene Flow, Overlay Rendering, Character Presentation |
| **Gameplay** | The systems that make the game fun | Investigation & Fact, Reactive Event Rules, Filing & Decision |
| **Narrative** | Story and dialogue delivery | Narrative Content Format & Strings, Dialogue & Interrogation, Chapter & Story Structure |
| **Persistence** | Save state and continuity | Save/Load |
| **UI** | Player-facing information displays | Paper UI (dossier, documents, HUD) |
| **Audio** | Sound and music systems | Audio & Adaptive Surveillance Mix |
| **Meta** | Systems outside the core game loop | Settings Store |

Progression and Economy do not apply: progress is knowledge and standing, held in the dossier; there is no currency.

---

## Priority Tiers

| Tier | Definition | Target Milestone | Design Urgency |
|------|------------|------------------|----------------|
| **MVP** | Required for the core loop to function. Without these, you can't test "is this fun?" | One archivist scene plus the art-pipeline proof; 8–12 weeks from 2026-11-03 including design and Technical Setup | Design FIRST |
| **Vertical Slice** | Required for one complete, polished area. Demonstrates the full experience. | One chapter per protagonist, closes on an ending beat, ships as a prologue; go/no-go gate; 5–8 months from start | Design SECOND |
| **Alpha** | All features present in rough form. Complete mechanical scope, placeholder content OK. | Skeleton (every act and ending wired) then the 3-act core; 14–24 months | Design THIRD |
| **Full Vision** | Polish, edge cases, nice-to-haves, and content-complete features. | Stretch acts 4–5; content only, no new systems | Design as needed |

> **Producer Note** (MVP): the 4–6 week MVP figure in the concept counts build time after the Technical Setup gate; from today, design plus Technical Setup plus build is 8–12 weeks at 10–20 h/week. To answer the core hypothesis sooner, run the concept's planned `/prototype` of the archivist scene now (throwaway, 1–2 weeks, outside the rigor gates). Start the art-pipeline proof alongside GDD writing at about 20% of weekly capacity; it depends on the art bible, not on any GDD. Two rigor levers were offered and **not** applied here because they are the user's call: a `standard` per-system override for Overlay Rendering and the Character Presentation stub (`workflow_overrides.system_overrides`), and a "slice minimum" of two protagonists plus one cross-chapter payoff with the third chapter as slice-plus (a scope change for creative-director).
> **Creative Director Note** (Vertical Slice): plan three protagonist chapters, with **archivist plus dissident declared now as the agreed fallback** that still passes go/no-go: the required cross-chapter payoff runs archivist → dissident (a filing becomes a raid or a sign); the conscript appears in the slice as a presence (an order or dossier entry seen through the other two chapters); the go/no-go criteria list what a two-chapter slice leaves untested (orders-view readability, the three-way weave); the conscript chapter is the first work after the gate, before the skeleton.
> **Creative Director Note** (GDD requirements): Investigation & Fact — simulator acceptance criterion that every authored fact has at least one dossier use (Pillar 1); Filing & Decision — content check that every option writes at least one cost effect (Pillar 3); Dialogue & Interrogation — timed *search* scenes (checkpoint, border) in scope, not only interrogation (Pillar 5); Chapter & Story Structure — owns protagonist death and the story continuing. The concept's wording that facts "drop into a dossier" is reconciled at the next concept revision: held facts live on the fact board; only filed facts enter the dossier.
> **Producer Note** (Vertical Slice): 5–8 months from start, expected about 7 at 15 h/week; re-run `/estimate` after the MVP produces velocity data. The likely cut point under pressure is the third protagonist's chapter or the signs/orders dossier views.

---

## Dependency Map

### Foundation Layer (no dependencies)

1. Dossier State Model — the sole cross-storyline channel; single effect-record mutation API; emits change records; holds only what the state knows; its GDD owns the three read-only protagonist views (files / signs / orders) as a design rule for which facts reach each protagonist and how — Paper UI renders them
2. Narrative Content Format & Strings — documents, dialogue, scene/chapter graph, decision and effect data, string-ID scheme, lookup and export; all text is a string
3. Scene & Interaction Framework — isometric plate, layers, hotspot registration, scene loading, input actions, cursor and focus; navigation and walkable regions as a conditional section decided by the MVP pipeline proof
4. Settings Store — plain-data settings (timer mode, UI scale, flicker, red-as-hatching) read by others, written by the HUD settings screens

### Core Layer (depends on foundation)

1. Investigation & Fact System — depends on: Narrative Content Format & Strings, Scene & Interaction Framework, Dossier State Model (reads for unlock conditions; never writes)
2. Calendar, Regime Phase & Attention — depends on: Dossier State Model (two pure functions of dossier aggregates: the global regime phase and per-character attention — the signal that drives stamp red and the surveillance stamp within a single scene; never written by rules)
3. Reactive Event Rules & Story Simulator — depends on: Dossier State Model, Narrative Content Format & Strings, Calendar & Regime Phase (evaluates at scene boundaries only; emits events; never calls Feature code)
4. Scene Flow — depends on: Dossier State Model, Reactive Event Rules, Calendar, Regime Phase & Attention, Scene & Interaction Framework (owns the scene-boundary sequence: decision → effects → rules → phase and attention → **reveal changes** (change records, including another protagonist's overprint when a payoff lands, handed to Paper UI) → calendar → next scene or save)
5. Overlay & Surveillance Rendering — depends on: Scene & Interaction Framework, Calendar & Regime Phase, Settings Store (owns stamp and overprint rendering and the red-budget gates; never reads raw dossier fields)
6. Character Presentation — depends on: Scene & Interaction Framework (owns y-sort and portrait rendering; Dialogue requests a portrait state, this system owns how it looks)

### Feature Layer (depends on core)

1. Filing & Decision — depends on: Investigation & Fact System, Dossier State Model, Narrative Content Format & Strings (decisions are effect-record data, never code)
2. Dialogue & Interrogation — depends on: Narrative Content Format & Strings, Investigation & Fact System, Dossier State Model, Scene & Interaction Framework, Settings Store (transcript logic only; no UI)
3. Chapter & Story Structure — depends on: Dossier State Model, Narrative Content Format & Strings, Calendar & Regime Phase, Scene Flow (runtime progression only; the graph is content)
4. Save/Load — depends on: the persistence registry (every stateful system's serialize/deserialize with a schema version); owns versioning and migration; scene-boundary saves; seeded RNG state

### Presentation Layer (depends on features)

1. Paper UI — depends on: Dossier State Model, Character Presentation, Overlay & Surveillance Rendering, Narrative Content Format & Strings, Investigation & Fact System, Dialogue & Interrogation, Settings Store (owns seen/unseen and the changed marker; decides when and where to stamp; AccessKit roles from the start)
2. Audio & Adaptive Surveillance Mix — depends on: Calendar & Regime Phase, Reactive Event Rules, Dialogue & Interrogation

### Polish Layer (depends on everything)

None. Accessibility is a requirement inside the implementing systems, not a late layer.

---

## Recommended Design Order

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | Dossier State Model | MVP | Foundation | systems-designer, technical-director | L |
| 2 | Narrative Content Format & Strings | MVP | Foundation | narrative-director, localization-lead | M |
| 3 | Scene & Interaction Framework | MVP | Foundation | game-designer, godot-specialist | M |
| 4 | Settings Store | MVP | Foundation | ux-designer | S |
| 5 | Investigation & Fact System | MVP | Core | game-designer | M |
| 6 | Reactive Event Rules & Story Simulator | MVP | Core | systems-designer, technical-director | M |
| 7 | Calendar, Regime Phase & Attention | MVP | Core | systems-designer | S |
| 8 | Scene Flow | MVP | Core | game-designer, lead-programmer | S |
| 9 | Filing & Decision | MVP | Feature | game-designer, narrative-director | S |
| 10 | Dialogue & Interrogation | MVP | Feature | narrative-director, writer | M |
| 11 | Overlay & Surveillance Rendering | MVP | Core | technical-artist, godot-shader-specialist | M (after the stamp-red spike) |
| 12 | Character Presentation | MVP (stub) | Core | art-director, technical-artist | S stub now, M full after the pipeline proof |
| 13 | Paper UI | MVP | Presentation | ux-designer, ui-programmer | M |
| — | *Technical Setup gate* (`/review-all-gdds`, `/create-architecture`, six ADRs, `/gate-check`) | | | | |
| 14 | Chapter & Story Structure | Vertical Slice | Feature | narrative-director | L |
| 15 | Save/Load | Vertical Slice | Feature | lead-programmer | S (the persistence contract is a subsection of GDD 1 and ADR-4) |
| 16 | Audio & Adaptive Surveillance Mix | Vertical Slice | Presentation | audio-director, sound-designer | M |

Producer estimate for GDDs 1–13 at full rigor: 55–75 hours of human approval time plus the cross-review. Log hours per GDD from GDD 1 and re-check the estimate after GDD 3.

---

## Circular Dependencies

- None found. Three near-cycles were resolved by boundary rules: the regime phase is a pure function of dossier state and is never written by rules (Rules → Phase, not Phase → Rules); the Story Simulator reads content and rule data, never Chapter & Story Structure; Scene Flow calls Rules and Phase and neither calls back.

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| Dossier State Model | Design / Technical | Becomes a god object or an unconstrained write surface; flag budget unenforceable; sole channel between storylines | Single effect-record API with tagged writers; fixed schema with a per-chapter flag budget; endings from aggregates; time-box the GDD to 2 weeks; open schema questions go to ADR-1 |
| Reactive Event Rules & Story Simulator | Technical | Rule format and evaluation semantics undefined; determinism | Scene-boundary evaluation, capped cascade, deterministic tie-break, seeded RNG saved; simulator as acceptance criteria on the same evaluator; ADR-2 |
| Chapter & Story Structure | Design / Scope | Player-determined fall multiplies final-act branches | Endings computed from a few aggregates; ending-first skeleton after the slice; one cross-chapter payoff as a slice criterion |
| Character Presentation | Scope / Pipeline | Walking sprites with no human artist | MVP pipeline proof (one plate, one character, one walk cycle, timed) decides walking vs standing layers; stub GDD until then |
| Overlay & Surveillance Rendering | Technical | CanvasModulate / overlay compositing NOT SOURCEABLE for Godot 4.7 | MVP spike owned by technical-artist and shader specialist; GDD written after the spike; ADR-5 |
| Dialogue & Interrogation | Technical | Addon compatibility with 4.7 not sourceable; custom tooling is a scope trap | One-day spike per candidate; plain-text format with a small GDScript interpreter as fallback; ADR-3 |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 16 |
| Design docs started | 0 |
| Design docs reviewed | 0 |
| Design docs approved | 0 |
| MVP systems designed | 0/13 |
| Vertical Slice systems designed | 0/3 |

---

## Next Steps

- [x] Review and approve this systems enumeration (CD-SYSTEMS: CONCERNS, applied)
- [ ] `/prototype` the archivist scene (HTML, throwaway) to answer "is reading-and-filing tense?" before the full-rigor MVP
- [ ] Design MVP-tier systems in the order above (`/design-system [system-name]`), logging human hours per GDD
- [ ] Start the art-pipeline proof alongside GDD writing (about 20% of weekly capacity)
- [ ] Run `/design-review` on each completed GDD, then `/review-all-gdds`
- [ ] `/create-architecture` and the six ADRs; `/gate-check technical-setup` when MVP systems are designed
