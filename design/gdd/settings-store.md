# Settings Store

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: In Design
> **Author**: Mustafa Faisal (user) + ux-designer, systems-designer, gameplay-programmer (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 5 Pressure comes from attention, not reflexes (the timer and reveal options keep the room fair for every player)

## Summary

[To be designed]

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `[To be designed]`

## Overview

The Settings Store is the one place a player preference lives: a small, typed catalogue of plain-data settings (the interrogation timer mode, UI scale, cursor scale, flicker and motion limits, red-as-hatching, the hotspot reveal and tooltip modes, locale, audio levels, and the bindings of the seven input actions) with declared defaults, ranges and owners, read by the systems that act on them and written only by the settings sheets of Paper UI. It loads once at start-up, validates every value against its declaration, persists to the user's profile outside the save files, and tells its readers when a value changes. It exists because the technical director split it out of the HUD so that Dialogue, Overlay Rendering, the Scene framework, Paper UI and the string lookup read one source of truth instead of each keeping its own, and because the accessibility promises the art bible and the first three GDDs make (a timer that can be turned off or doubled, text that scales, red that can become hatching, nothing that needs a held key) are only promises if the values behind them are declared, persisted and reachable from one sheet. The index describes it as "plain-data settings (timer mode, UI scale, flicker, red-as-hatching) read by others, written by the HUD settings screens", and this GDD keeps that scope while adding the keys the later GDDs have since required (locale, reveal and tooltip modes, cursor scale, action bindings). It does not own how a setting is presented (Paper UI), what a setting does (each reader), or save-game state (Save/Load). Implementation questions raised here (which engine file API persists it, how bindings reach the input map) are recorded for the ADRs, not decided in this document.

## Player Fantasy

*Framing: indirect. The player never sees the store; they see a settings sheet that Paper UI draws from the store's declared keys. Shaped with the creative director (three candidate framings; "the form you fill in about yourself" chosen, with the head line and the phase-invariance rule from "the back of the page"; "the state's form, filled in by you" rejected because it makes accessibility feel like being registered).*

**The form you fill in about yourself.** The settings sheet is the one form in Paper Walls that the player fills in about themselves, and nobody files it. It is a sheet at UI value like every other sheet (art bible §7.1), typed, with field labels down the left and typed brackets for the answers. It has no surveillance stamp, no carbon and no "cc", because nothing on it is copied anywhere, and it looks the same in Confident week as in Collapsing week: no phase ink reaches it. The anchor is the timer line, `INTERROGATION TIMER: [ OFF ] [ 2× ] [ DEFAULT ]`, with one bracket double-struck. Choosing a bracket is the same press that chooses an answer in a transcript, so the sheet teaches the game's grammar, and it promises that this answer, unlike every other one, costs nothing. At its head, above every field, one typed line is the only sentence in the game addressed to the player instead of a protagonist: *nothing in this room needs a steady hand.* It states openly what GDD 3 guarantees. A player with a tremor, low vision or a slow reading pace should feel that the game made room for them before they had to ask. The feeling is the small relief of a form that asks only what it needs and keeps the answers to itself.

*Costs accepted:* the settings sheet is exempt from §7.5's surveillance stamp and from phase styling (the art director records the exemption); the head line is one piece of out-of-fiction copy the narrative director approves and localises.

**Pillar alignment.** Pillar 3, "no one is clean": with no "safer" setting, no option can soften a cost or buy absolution. Pillar 5, "pressure comes from attention, not reflexes": pressure comes from the state's attention, which no setting touches, so "timer off" removes the reflex test without removing the pressure.

**The one rule the store must obey: a setting changes how the game asks, never what it asks or what an answer costs.** Every key changes only presentation, input or pace. No key changes which choices exist, what they cost, when they are available, what they write to a dossier, how attention rises, or which ending is reached. *Required:* story systems (dossier, attention, rules, chapter structure, the simulator) never read a setting value; settings are never written into a save; if the timer running out produces an outcome (silence as an answer), turning the timer off keeps that outcome available as an explicit choice (Dialogue & Interrogation decides how). *Forbidden:* any "easy", "story" or "recommended" label, or any option framed as reducing difficulty; a consequence preview, undo or rewind presented as a setting; a setting that adds a timer anywhere outside interrogation or search; an achievement, ending or text line that depends on a setting; a warning or confirmation shown when an accessibility option is chosen. *Design test (headless, an acceptance criterion):* two simulated runs with the same choices and opposite values for every setting produce identical dossiers, attention and ending state; any difference is a defect.

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
