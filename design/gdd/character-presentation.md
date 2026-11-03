# Character Presentation

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: In Design
> **Author**: Mustafa Faisal (user) + systems-designer, art-director, technical-artist, gameplay-programmer, creative-director (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 3 No one is clean · 2 The state is a character

## Summary

[To be designed]

> **Quick reference** — Layer: `Foundation` · Priority: `MVP (stub) / Vertical Slice (full)` · Key deps: `Scene & Interaction Framework` (figure layers, person hotspots, `baseline_y`, the focus signal), `Narrative Content Format & Strings` (the cast table, portrait requests), `Scene Flow` (the insert's figure)

## Overview

*Framing: infrastructure first (Category `Core`, Layer Foundation), with its player-facing effect named because people are what the player looks at. A stub at MVP: this GDD fixes the interface and ships the standing-layer behaviour; the walking outcome stays a conditional paragraph until the art-pipeline proof decides `presentation.mode`. No ADR cites it yet; ADR-5 (the renderer) and ADR-6 (assets) will read it.*

Character Presentation puts people in rooms and faces on sheets. It decides which named characters are present in a scene and in which pose, from content conditions resolved at scene entry and never mid-scene; it draws each as a standing figure layer on the plate, y-sorted with the hotspots by its baseline, at the second-highest contrast in the frame, with its printed keyline and the thicker keyline when the player's focus is on it; it hands Paper UI the ID-photo portrait for the transcript sheet in one of four states (neutral, guarded, evasive, exposed) that the writer chose for that line and the engine never infers; it places the state's person on the threshold line when a reactive event cuts in; and it supplies the one mark that turns a citizen into an informer, the carbon "cc" overprint on the portrait, only once the player holds the fact. The player never operates it; they read it: a figure where the file said someone would be, a face that will not meet the lens, a door with a captain in it. Without it Pillar 3 would have no faces to be unclean in and Pillar 2 no body to arrive with; with more than it (a mood meter on a face, a figure that breathes while you read) Pillar 5 and the art bible's stiff, printed people would be gone. Its logic is headless (a cast plan per scene entry, plain data, byte-equal across hosts) and its drawing lives behind a host seam with a null twin, like the Scene & Interaction Framework's and Overlay's. Under the walking outcome it would also own the player's avatar, its walk, facing and hand-over; that paragraph is written and dormant.

## Player Fantasy

*Framing: indirect. The player never sees Character Presentation; they see people standing in rooms and faces pinned to paper, and learn that neither one gives a verdict. Shaped with the creative director (three candidate framings; "nobody looks guilty" chosen, from art bible §5.2–5.3 and Pillar 3; "the face is the writer's, the mark is yours" kept as the one rule; "the file has a face, the room has a body" kept as how the plate and the sheet divide a person, §5.5).*

**Nobody looks guilty.** This system serves two feelings that pull against each other. The first is uncertainty about people. Everyone in the city stands the same way: stiff, weight on both feet, hands low, faces too small to read at plate scale. The informer on the stairs is drawn exactly like the woman in the bread queue, and the room will never tell you which is which. The second is the moment that changes, and it comes only from paper. When you hold the fact, the face on the sheet gets a carbon double of its own outline, two pixels off true, and a small "cc" in its corner. It is the same blue mark your own filings leave, because knowing someone informs and having it on file are one thing. The figure in the room stays unmarked. The room shows people; only the file can mark one.

The anchor moment: Vera's office, Friday 6 October. Berta is at the next desk as a standing layer, seated, still, at second-highest contrast, with a 2 px soot keyline that thickens to 3 px when Vera's attention rests on her. In conversation Berta's ID photo is stapled top-left on the transcript sheet. When Vera asks after the missing copy, the photo changes because the writer asked it to: chin down five degrees, mouth tightened. That is Guarded, the look of anyone asked a question at work, and it proves nothing. The same week Vera reads report 4471 to the end and holds the fact that the hand is Kastan's, the caretaker at Vrba Street. The next time Kastan's face is on a sheet, on the landing asking after the parcel, it carries the blue double strike and the "cc". Kastan is still on his stairs, drawn as he always was. Then Rybar comes. His figure is on the threshold line on the first cut, and the light around him is replaced on the second. He does not walk in, he does not gesture, and the camera does not move. The state arrives the way people do in this game: already standing there when you look up.

Pillar alignment. Pillar 3, "no one is clean": expression is the only acting in this game, and it is limited to gaze, chin and mouth in four checkable states, Neutral, Guarded, Evasive, Exposed (§5.4). Evasive is how a frightened innocent looks too. Shame is carried by the eyes looking away, not by performance, and no face tells the player whom to condemn. Pillar 1, "every fact is a weapon": the informer's mark is a fact turned into a drawing, and it exists only because the player holds that fact; no fact ever lives on a figure at plate scale (§5.5). Pillar 2, "the state is a character": the state has a body here too, and it enters through a threshold, standing where the light changes, never in a cutscene. Pillar 5, "pressure comes from attention, not reflexes": nobody moves while the player reads. Figures do not breathe, shift or wander. A person is present or absent from the moment the room opens, decided by the file as it stood at the door.

**The one rule this system must obey: a face shows only what the writer asked of it, and a person is marked only by what the player holds.** Every portrait state comes from a one-word request on a dialogue item. If a line has no request, the face is Neutral. The engine never infers an expression from attention, suspicion, phase or anything else in the dossier, so a frightened face is always a choice someone made and never a reading of the meter. The informer overprint is a layer, not a fifth state. It appears on the portrait once the fact is held, and it never appears on the figure, the costume or the plate. Who stands in a room is settled when the player walks in, and a held fact never makes someone appear, so no one becomes an option just because the player learned something. No figure is tinted red; colour says who is watching, never who is guilty.

*Cost accepted:* this is a stub at MVP and honest about it. Vera's chapter ships the standing outcome: each named character is a per-scene plate layer with one pose per scene state, removed when the file says they are absent; the player's own figure is never shown; and the portraits carry all the expression. Whether protagonists later walk to the desk (walk cycles, facing, idle, hand-over, page-turn) waits for the MVP art-pipeline proof; it is written as a conditional so the switch costs nothing, and plate-scale detail is identical under both outcomes. Until then a person cannot cross a room, and the player may feel the rooms are tableaux. Restrained faces mean some players will misread a Guarded face as guilt; the game lets them, because the city did too. And the player who spots the informer early, from instinct, gets no confirmation from the drawing. Until the paper says so, Kastan looks like everyone else, and some players will find that frustrating. That frustration is the cost of the pillar, and it is accepted.

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
