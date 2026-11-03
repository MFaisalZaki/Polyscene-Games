# Dossier State Model

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: In Design
> **Author**: Mustafa Faisal (user) + systems-designer, technical-director, narrative-director (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 1 Every fact is a weapon · 2 The state is a character · 4 Consequences cross lives

## Summary

The Dossier State Model is the state's file on every character: what the regime knows, believes and has decided about each of them, plus how steady the regime itself is. It is the only way one protagonist's choice reaches another protagonist's chapter, and the only source from which the game decides how closely a character is watched and how the story ends. It exists because Paper Walls is a game about consequences carried on paper, and this is the paper.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `None` (read by 11 systems; written only through its effect-record API)

## Overview

Every character in Paper Walls, protagonist or not, has a record held by the state: a set of yes/no facts (watched, flagged, cleared, arrested), a few numbers (how much attention the regime pays to them) and a standing (open, closed, released). One record, the city's, holds the regime's own stability and unrest. Nothing in the game changes these records directly. Instead, when the player files a report, burns one, warns a neighbour, confesses, or lets a courier through, that act produces an **effect record**: a small declarative note saying which record, which field, what change, and who caused it. The model applies these at scene boundaries, in one batch, in a fixed order, and answers with **change records** saying what actually changed. Other systems only ever read: the rules that fire reactive events, the function that decides whether the regime is confident, paranoid, panicking or collapsing, the stamp-red overlay that shows a character is being watched, the audio mix, and the Paper UI. Each protagonist is shown a different projection of the same records: Vera the archivist reads the files themselves; Jan the dissident sees only the signs (a car outside, a phone that goes dead); Tomas the conscript receives orders. The player never sees a meter. The model exists so that a choice made as one protagonist can land, weeks later and unannounced, in another's life, and so that the same logic that runs the game can run headless to prove every ending is reachable.

## Player Fantasy

**Framing: your handwriting in someone else's life.** The emotion the dossier serves is recognition that turns into guilt. The player is not meant to feel this system as a system at all. They meet it indirectly, through what it enables and what it reveals.

The anchor moment: in Jan's chapter a phone goes dead mid-sentence. Nothing explains it. Two chapters earlier, playing Vera, the player entered the note that named this flat. The game never draws the line, there is no "because you", no popup, no highlighted cause. The file is the only witness, and only the player has seen both sides of it. The language of the system, wherever it surfaces, is clerical and passive: *a note was entered*, *the line was disconnected*. The state never says who did it, so the player supplies the "I" themselves.

The two other feelings the dossier produces are subordinate to that one. **Complicity at the moment of writing** (the carbon forming under Vera's sheet, the stamp coming down red; the Papers, Please moment of stamping what the rule requires) is the cause side of the same recognition. **Being noticed** (the same man at the tram stop twice, stamp red seeping into the edges of Jan's street; the regime growing louder and clumsier as it moves from confident to panicking) is the effect side, carried by the signs projection and the attention aggregate. Both are designed in so that the first can happen; neither is the fantasy on its own.

Pillars served, in the concept's own words: Pillar 4, "the most important result of a choice lands in another protagonist's chapter, through dossier states, never bespoke branch trees"; Pillar 1, "anything learned can be written into, leaked from, or used against someone's dossier"; Pillar 3, "the act can succeed; the actor is never absolved"; Pillar 2, "whether it fires and at whom is read from the dossier". Reference moment: in Orwell, a fragment you uploaded comes back days later as an arrest in the news feed.

Design consequences for the sections below: the model must keep provenance (who caused a change, in which chapter) so the payoff can be staged without being explained; the signs projection must be able to express a change without naming its cause; and nothing in the model may be rendered as a number to the player.

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

The model depends on nothing at runtime: it is the Foundation layer's first system and must build and test alone. Eleven systems depend on it. Direction and nature follow the systems index boundary rules.

| System | Direction | Nature of Dependency |
|--------|-----------|---------------------|
| Narrative Content Format & Strings | Content depends on this (schema); this depends on Content at authoring time only | The field schema (`schema/dossier-fields.yaml`) is authored here and consumed by the content format as the vocabulary for effect records; every chapter's effect data is validated against it. No runtime import either way. |
| Investigation & Fact System | Fact depends on this | Reads flags for unlock conditions (a fact becomes available when the state has acted). Never writes. Player-held facts are Fact's own state, not dossier state. |
| Reactive Event Rules & Story Simulator | Rules depend on this | Reads the full record set and the change records of the current boundary; writes only by returning effect records (source tag `rules`). The simulator runs the same evaluator headless over the same schema; the polyscene topic's fluents map one-to-one to dossier fields. |
| Calendar, Regime Phase & Attention | Phase depends on this | Two pure functions of dossier aggregates: regime phase from the city record; per-character attention from the character record. Never writes. |
| Scene Flow | Scene Flow depends on this | Owns the scene-boundary sequence; calls `apply` exactly once per batch in the order decision → rules, then hands the boundary's change records to Paper UI. The boundary counter here is Scene Flow's clock. |
| Overlay & Surveillance Rendering | Overlay depends on this (indirectly) | Reads the attention value through Calendar, Regime Phase & Attention, never raw fields. Carbon double-strike on objects the state has a copy of is driven by the `has_copy` projection rule in Core Rule 7. |
| Dialogue & Interrogation | Dialogue depends on this | Reads flags as line conditions; writes by producing effect records (source tag `dialogue`) at the end of a conversation, never mid-line. |
| Filing & Decision | Filing depends on this | The main writer: each filing act (file, burn, doctor, warn, leak, take blame, report) is content data that expands to effect records (source tag `decision`). |
| Paper UI | Paper UI depends on this | Renders the three projections (files / signs / orders) and the scene-end reveal from change records. Owns seen/unseen; this model holds no UI state. |
| Chapter & Story Structure | Chapter depends on this | Reads the ending aggregates and the declared cross-life flags at chapter start and act end; declares each chapter's flag budget in content. |
| Save/Load | Save/Load depends on this | Persistence contract: `serialize()` / `deserialize()` of plain data with `schema_version`; Save/Load owns the registry and migration. |
| Audio & Adaptive Surveillance Mix | Audio depends on this (indirectly) | Reads phase and attention through Calendar, Regime Phase & Attention; listens to change records tagged `cross_life` for the overprint cue. Never raw fields. |

## Tuning Knobs

[To be designed]

## Visual/Audio Requirements

The model has no presentation of its own; every row below is a requirement placed on the system that renders it. Art bible references in brackets.

| Event | Visual Feedback | Audio Feedback | Priority |
|-------|----------------|---------------|----------|
| Change record revealed at scene end (own chapter) | The dossier sheet's changed line gains the carbon double-strike ghost and the `cc` mark (art bible §4.5); the stamp is the field's state stamp (WATCHED, FLAGGED, CLEARED, ARRESTED) in stamp red at the phase's ink reach (§2.2) | A single stamp impression; weight by phase (audio-director to specify) | High |
| Change record tagged `cross_life` revealed (another protagonist's payoff lands) | The originating chapter's ink and letterform overprinted on this chapter's page (§1.3, §4.6): archivist grey-green cursive, dissident soot hand-set, conscript khaki stencil | The overprint cue, the one cue that is not paper (audio-director to specify, art bible §7.4 audio backup) | High |
| Attention rises past a band threshold for the current protagonist | Stamp red reaches further into the plate per the phase budget table (§4.3); never a meter | Surveillance bed rises one step | High |
| Attention falls to 0 | Red withdraws to margin and official stamps only | Bed drops out | Medium |
| Regime phase changes | The whole plate's light recipe changes at the next scene (§2.2); the date stamp's ink reach changes | Phase bed changes at the calendar transition | High |
| Record closed (ARCHIVED / DESTROYED / RELEASED) | The file's closing stamp on its last page (§2.2 Epilogue row); no triumphant colour on any closing | Final stamp, then silence | High |
| Effect dropped at runtime (budget guard, release build) | None to the player; a `dropped` change record goes to the debug log only | None | Low |

## Game Feel

Not applicable: the model has no input, animation or impact of its own. The feel of filing, reveal and interrogation is owned by Filing & Decision, Paper UI and Dialogue & Interrogation respectively, and each of those GDDs carries its own Game Feel section. The one feel requirement this model imposes on them is in Player Fantasy: a cross-life payoff is staged, never explained.

## UI Requirements

The player never sees a dossier field as a value. The three projections are the only player-facing form of this model; Paper UI designs the sheets, this document fixes what reaches each sheet (Core Rule 7).

| Information | Display Location | Update Frequency | Condition |
|-------------|-----------------|-----------------|-----------|
| Files projection (full record text for every character the archivist has pulled) | Archivist dossier sheet, gridded form (art bible §5.1) | At each scene boundary reveal | Protagonist is Vera; record is `opened` or later; field is in the files projection set |
| Signs projection (a sign per flag the dissident can infer, never the flag's name) | Dissident pinboard of torn fragments (§5.1); also in-scene props (the car, the dead phone) placed by Scene Flow | At scene start, from the previous boundary | Protagonist is Jan; the flag has a sign entry in the signs table; the sign's `shown_at` chapter condition holds |
| Orders projection (the state's instruction for today, a list of names) | Conscript order sheet, stencil (§5.1) | At scene start | Protagonist is Tomas; the record is on the day's list |
| Scene-end change reveal (what changed, in whose ink) | The open dossier's changed lines, in the dossier tab (§9.1 HUD) | Once per scene boundary | At least one change record was emitted this boundary and is visible in the current projection |
| Closing stamp of a record | The file's last page at the epilogue | Once | Record transitions to a closed state |
| Nothing: regime stability, unrest, attention, flag names | Never displayed as numbers or names | — | The dossier is never a meter (Player Fantasy) |

## Cross-References

[To be designed]

## Acceptance Criteria

[To be designed]

## Open Questions

[To be designed]
