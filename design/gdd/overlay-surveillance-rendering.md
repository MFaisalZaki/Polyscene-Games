# Overlay & Surveillance Rendering

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: In Design
> **Author**: Mustafa Faisal (user) + systems-designer, technical-artist, engine-programmer, art-director, creative-director (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 5 Pressure comes from attention, not reflexes · 2 The state is a character

## Summary

[To be designed]

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `Calendar, Regime Phase & Attention` (the snapshot's tiers), `Scene & Interaction Framework` (the plate, layers and hotspots), `Settings Store` (`flicker`, `motion`, `red_as_hatching`)

## Overview

*Framing: infrastructure first (Category `Core`, Layer Foundation), with its player-facing effect named because this is the one Core system whose whole output is pixels. No ADR cites it yet; ADR-5 (the renderer) will be built from it.*

Overlay & Surveillance Rendering is the system that puts the state's attention on the screen. It never computes a tier and never reads a file: it takes the Calendar's per-boundary snapshot (the regime phase, the red reach per character, the ink reach, the stamp tier) and the scene's authored overlay data, and from them builds a plan of what to draw above the painted plate, the four layers of the art bible's overlay stack: grain on everything; the carbon ghost that makes a filed object look read; the stamp instances placed where the phase's reach allows; the red that climbs from the paper margin to the props to the state's key light and withdraws when the state collapses. It also owns the lighting switches a plate has (the lamp, the window, the threshold light when the state arrives), the Panicking flicker under the accessibility cap, and the rendering of the interrogation timer's margin fill, the one continuous motion in the game. The player never operates it; they read it: a room that is a little redder than the last one, a telephone that has turned red since this morning, a drawer that has gone carbon blue because they read what was in it. Without it Principle A ("attention has a colour") would have no pixels, Pillar 5 would have no pressure the player could see, and every other system's tiers would be numbers nobody rendered. Its logic is headless (a plan, plain data, byte-equal across hosts); its drawing lives behind a host seam with a null twin, like the Scene & Interaction Framework's, so the simulator and the unit tests run without a frame. It reads three settings (`flicker`, `motion`, `red_as_hatching`) and changes how the room is shown, never what is in it.

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
