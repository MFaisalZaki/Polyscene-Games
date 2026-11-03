# Calendar, Regime Phase & Attention

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: In Design
> **Author**: Mustafa Faisal (user) + systems-designer, gameplay-programmer, engine-programmer, creative-director (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 2 The state is a character · 5 Pressure comes from attention, not reflexes

## Summary

[To be designed]

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` (phase and per-character attention) / `Vertical Slice` (calendar) · Key deps: `Dossier State Model`

## Overview

*Framing: infrastructure first (Category `Core`, Layer Foundation), with its player-facing effect named because this is the one Core system the player reads off the frame every scene. No ADR cites it yet; ADR-1 (the dossier) is to confirm Core Rule 1a's `calendar.*` channel.*

Calendar, Regime Phase & Attention is the clock and the barometer of Paper Walls. It owns three things that nothing else may own: **the beat**, the act-wide count of scene boundaries that every window, drift period and law is stated over; **the regime phase**, a pure function of the dossier's regime aggregates (stability, unrest, the `paranoid` flag and the `phase_reached` ratchet) that yields one of four values, confident, paranoid, panicking, collapsing, and never falls; and **effective attention**, the per-character reading of the state's eye (the stored `attention` scalar, whether the person is listed, and the phase) rendered as tiers, never as numbers: how far stamp red reaches on this person's paper. At the Vertical Slice it also becomes the calendar proper: the authored timetable that gives each scene a day, a weekday and a Plan Week for the date stamp and the tear-off transition, and the small `calendar.*` store of world clocks and window suspensions (Marta's breath, the paused route) that rules read and write through the same effect records as the dossier. The player never operates it. They read it: the typed date in the top-left corner, the ink reach of that date stamp, the surveillance stamp filling on an open sheet, the day that turns over while they were not there. Without it the state would have no tempo and no face: rules could not be timed, red could not know how far to reach, the simulator could not say which week an ending belongs to, and Pillar 5 (pressure comes from attention, not reflexes) would have nothing to show the pressure with. It writes nothing to the dossier; it is read by Rules, Scene Flow, Overlay & Surveillance Rendering, Paper UI, Audio and the simulator, and it is pure logic that runs headless.

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
