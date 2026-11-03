<!-- PROTOTYPE - NOT FOR PRODUCTION -->
<!-- Question: Does reading six documents, connecting two facts and deciding what to file about a neighbour feel tense without a timer, and does the dossier change read unaided? -->
<!-- Date: 2026-11-03 -->

# Paper Walls — archivist scene concept prototype

**Hypothesis.** If the player reads six documents in the archivist's office,
connects two facts, and decides what to file about a named neighbour, they will
feel the weight of the decision and understand the dossier change without
explanation. Signals: at least two facts connected unprompted within 5 minutes;
more than 10 seconds with "the pen in hand" on the ledger screen; the player can
say afterwards what changed in the files and who the state is now looking at.

**Riskiest assumption.** Reading-and-filing is tense with no timer at all, and
the stamp-red bleed at the frame edge reads as "the state is looking" with no
explanation.

## How to run

Open `prototype.html` in any browser. No server, no install. Fixed 1280×720
stage. Mouse only (Tab/Enter also works on the paper hotspots).

Play it as a new player would: read, click names and numbers to hold them as
facts, click two held facts to see whether they connect, talk to Berta at the
next desk, then open the ledger. There is no timer and no fail state. The scene
ends after one decision; reload to try another.

## What is in it

One office plate drawn with flat CSS boxes in the Carbon Copy palette, six
documents as paper hotspots (keyline, lifted corner on focus, no glow), a fact
board, six fact links, one colleague with three unlockable questions, one filing
decision with three options (one is VOID until a specific link is found), one
reactive phone call per outcome, and the two dossiers (Dusek, Halm) shown before
and after with changed lines in carbon double-strike and state attention in
stamp red. A red bleed at the frame edge rises with attention on the player.

Deliberate shortcuts: hardcoded content, no art, no audio, no save, no other
protagonists, no calendar, no timers, debug line under the stage.

## Status

**Concluded — built, not yet played by a person.** Verified by a scripted
click-through (Playwright) on 2026-11-03: all three decisions reachable, no page
errors, screenshots in `screenshots/`. Verdict in `REPORT.md` is NOT ASSESSED
until someone plays it and answers the debrief questions.

## Findings

Pending the playtest. See `REPORT.md`.
