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

*Framing: indirect. The player never sees a counter, a meter or a quantity of attention or phase; the only numerals on screen are dates typed on in-world paper. Shaped with the creative director (three candidate framings; "the date is stamped, and so are you" chosen; "time passes without you" kept as the calendar transition's own line from art bible §2.1; "attention has a colour" left as the Overlay's identity, not this system's).*

**The date is stamped, and so are you.** This system serves two feelings that share one red. The first is time going by without you: the city keeps its dates whether or not anyone has done anything. The second is being looked at. It is not being chased. The state's interest is a colour that spreads across the page a little further each time a scene ends, and it only gets further if you give it a reason to.

The anchor moment: it is Friday of week one and the date stamp in the corner is black, with red only in the margin. A few scenes later a memo is circulated, typed and passive: *heightened vigilance is requested*. The scene ends and the wall calendar tears a page off. In the next scene the stamp's ink has bled past its border. There is a red telephone on Vera's desk. In the corner of Jan's sheet the surveillance stamp is half filled, but in the corner of Tomas's it is still only hatched. Nobody says the state is now paranoid, and nobody says it is looking at Jan. The memo said one and the paper shows the other. The player works out that the second came from the first, and that it came from something they filed.

Pillar alignment. Pillar 5, "pressure comes from attention, not reflexes": the tension is how far the red has spread, never a running clock, and the player may sit with a sheet as long as they like. Pillar 2, "the state is a character": its moods are four kinds of paper, tidy, counting, noise and ash, and the reader learns them the way they would learn a person's moods. Its last mood is the worst one, because then the red withdraws: stamps go unanswered, and the date keeps stamping with no one behind it. Pillar 4, "consequences cross lives": attention is tracked per character, so a filing in one chapter turns up as red on someone else's page.

**The one rule this system must obey: time moves only between scenes, and red moves only with it.** No day turns, no phase rises and no stamp fills while the player is reading. The calendar has no wall clock, and the state's attention never animates; it changes at a scene boundary, and only because of something on paper. A phase is announced on paper before its red appears. The red's reach is one of four fixed steps, never a gradient the player could watch creep. So when the red has moved, there is always a page behind it the player could have read.

*Cost accepted:* the calendar cannot be a ticking clock. A player who stalls feels no pressure until they act, so urgency has to be written as windows counted in scenes, not in seconds. Attention is felt in four coarse steps: a small gain stays invisible until it crosses into the next step, so the warning comes late and comes all at once. Marta's breath is the act's real clock, and it is felt only through paper; some players will not notice it until the ambulance comes.

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
