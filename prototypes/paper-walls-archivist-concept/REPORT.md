# Concept Prototype Report: Paper Walls — archivist scene

> **Date**: 2026-11-03
> **Prototype Path**: HTML
> **Concept File**: design/gdd/game-concept.md

---

## Hypothesis

If the player reads six documents in the archivist's office, connects two facts
and decides what to file about a named neighbour, they will feel the weight of
the decision and understand the dossier change without explanation — evidenced
by: at least two facts connected unprompted within 5 minutes; more than 10
seconds "with the pen in hand" on the ledger screen before choosing; and the
player stating afterwards, unprompted, what changed in the files and who the
state is now looking at.

---

## Riskiest Assumption Tested

That reading-and-filing is tense with no timer at all, and that stamp red
creeping in at the frame edge reads as "the state is looking" without a word of
explanation. Not yet proved out: nobody has played it.

---

## Approach

One self-contained `prototype.html`: an office plate in flat CSS boxes using the
art bible palette, six documents as keylined paper hotspots, a fact board where
clicking a name or number in a document holds it and clicking two held facts
tests a link (six authored links), a colleague with questions unlocked by links,
a ledger with three decisions (FILE / BURN / WARN, the last VOID until the
"parcel was medicine" link is made), one reactive phone call per outcome, and
the two dossiers shown before and after with new lines in carbon double-strike
and the state's attention in stamp red. A red bleed at the frame edge rises with
attention on the player. Build time about one hour of agent time.

**Path chosen:** HTML
**Reason for path:** the question is logic and clarity, not input feel; it runs
in the cloud session with no engine and can be shared as a single file.

**Shortcuts taken (intentional):**
- Hardcoded content and links; placeholder names (Halm, Dusek, Kastan, Rybar, Berta) for narrative-director to replace
- No art: flat rectangles, no figures beyond one colleague silhouette
- No audio, no save, no calendar, no timers, no other protagonists
- Debug line under the stage; playtest signals printed at scene end

---

## Result

Scripted click-through only (Playwright, 2026-11-03): all three decisions are
reachable, the VOID option unlocks only after the medicine link, the colleague's
questions appear only after their links, dossier changes render with the red
stamp per outcome, the red bleed steps 1 / 2 / 3 for FILE / BURN / WARN, zero
page errors. Screenshots in `screenshots/`. **No human has played it.**

---

## Metrics

| Metric | Value |
|--------|-------|
| Path used | HTML |
| Iterations to playable | N/A (one scripted fix pass: right panel overflow) |
| Prototype duration | about 1 hour |
| Playtesters | 0 internal / 0 external |
| Feel assessment | NOT ASSESSED — not played |
| Hypothesis verdict | NOT ASSESSED |

---

## Recommendation: NOT ASSESSED — built but nobody has played it

PROCEED, PIVOT and KILL are all unreachable until a person plays the scene and
answers the debrief. The build itself proves only that the loop is expressible
in one screen: read → hold a fact → connect → ask → decide → see the file
change. The scene prints its own signals at the end (facts held, links made,
time to first link, time with the pen in hand, decision) so the debrief has
numbers.

---

## If Proceeding

To be filled after the playtest. Candidate learnings to check:
- **Core tuning values:** how many facts per scene before the board is noise (12 here); how many links are needed to make the decision feel informed (3 of 6 here)
- **Assumptions to confirm:** the VOID option teaches that investigation opens choices; the "pen in hand" screen is where hesitation happens
- **Assumptions to disprove:** that the red bleed is self-explanatory; that the scene-end dossier read is enough without a "what changed" summary
- **Emergent:** whether players try to link everything (completionism) or stop at the first useful link

**Next steps after PROCEED:** `/design-review design/gdd/game-concept.md` →
`/design-system dossier-state-model` (first in the systems index order), using
these numbers in Tuning Knobs.

---

## If Pivoting

To be filled after the playtest.

---

## If Killing

To be filled after the playtest.

---

## Lessons Learned

- **What assumptions were broken by building this?** The concept says facts "drop into a dossier"; building the board made it obvious that held facts and filed facts must be different objects, which the systems index already records.
- **What surprised us?** Three decisions were enough to make every link matter: each link either unlocks an option, a question, or changes what the ledger screen says you know.
- **What to test differently next time?** Put the scene in front of a player who has not read the concept; the debrief question "who is the state looking at?" is the one that tests the red.

---

> *Prototype code location: `prototypes/paper-walls-archivist-concept/`*
> *This code is throwaway. Never refactor into production.*
