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
