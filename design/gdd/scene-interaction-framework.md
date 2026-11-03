# Scene & Interaction Framework

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: In Design
> **Author**: Mustafa Faisal (user) + game-designer, ux-designer, godot-specialist, gameplay-programmer, systems-designer (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 1 Every fact is a weapon · 5 Pressure comes from attention, not reflexes

## Summary

[To be designed]

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `[To be designed]`

## Overview

The Scene & Interaction Framework is the part of Paper Walls that puts a painted room on screen and lets the player touch it. It loads a scene's isometric plate and its layers, registers the room's hotspots (a lifted paper corner, a drawer out one notch, a receiver off its cradle) under the ids the content format names, routes mouse and keyboard input into a small set of actions (focus, activate, reveal, cancel, open dossier), owns the cursor and the single focus state that hover, keyboard and a later gamepad all share, and tells Scene Flow which hotspot the player activated. It exists because every other visible system, Investigation & Fact, Dialogue, Character Presentation, Overlay Rendering and Paper UI, needs one answer to "what is on screen, where is it, and what did the player just do", and because the art bible's legibility rules (one hero, three to eight keylined hotspots, a clean figure band, no glow) are only enforceable if hotspots are registered objects rather than painted-in guesses. Whether a protagonist walks across the plate or the camera cuts between standing layers is not decided here: navigation and walkable regions are a conditional section whose activation the MVP art-pipeline proof decides. The index describes the system as "isometric plate, layers, hotspot registration, scene loading, input actions, cursor and focus; navigation and walkable regions as a conditional section decided by the MVP pipeline proof", and this GDD keeps that scope. It does not decide what a hotspot yields (Investigation & Fact), when a scene ends (Scene Flow), how a figure looks (Character Presentation), or how stamps and red are drawn (Overlay & Surveillance Rendering). Implementation questions raised here (CanvasLayer ordering, the pixel-snap setting, the stretch aspect) are recorded for the renderer and plate-authoring ADRs, not decided in this document.

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
