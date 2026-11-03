<!-- PROTOTYPE - NOT FOR PRODUCTION -->
<!-- Question: Can polyscene enumerate the admissible story branches of Paper Walls? -->
<!-- Date: 2026-11-03 -->

# Paper Walls — story-branch generation with polyscene (technical spike)

**Hypothesis.** The first act of Paper Walls, written as a polyscene topic (a
PDDL domain of dossier flags and agent actions, a topic file of preferences,
licences, unknowns and axes), yields an admissible branch space that the engine
can enumerate exhaustively, fork and diagnose, fast enough to sit in the
writers' loop. Signals: grounding under 5 s; every value of the fate,
Vera-choice and Jan-fate axes covered; `exhausted` True; each branch carries
the assumption it rests on.

**Riskiest assumption.** That the engine's laws (intentional, connected, no
gap, warranted) admit a drama's beats at all rather than refusing everything.

## How to run

```sh
/home/user/polyscene/venv/bin/python run.py 8      # horizon 8; output in branches-h8.txt
```

Needs polyscene installed with its dependencies (`./setup.sh` in the polyscene
repository). `topic.py` is the Topic; `paper-walls.pddl` is what can happen;
`paper-walls-init.pddl` is the opening; `paper-walls.lp` is who wants what,
how each action reads, the world's own move, the three unknowns and the axes.

## What is in it

Five agents (archivist Vera, dissident Jan, conscript Tomas, officer Rybar,
informer Kastan), one person (Marta), one place (the border). Twenty agent
actions and three world moves (the crowd; the regime wavers; the regime panics),
with the world's own drift (unrest climbs while leaflets are out, stability
drains while a crowd stands at the gate). Three unknowns a telling may assume:
Kastan loyal, the garrison wavering, Rybar vindictive. Three topic laws: a
courage beat must cost its actor, a cowardice beat must protect something its
actor wants (Pillar 3), and a paid informer may not stay silent. Five axes read
off the end state: fate (fell quietly / fell in blood / held / held in blood),
Vera's choice, Vera's fate (watched / unwatched), Jan's fate (free / arrested /
recanted / turned), Tomas's choice (none / fired / stood down).

## Status

**Concluded.** See `REPORT.md`: PROCEED on the technical question. The
assumption layer is stated in the topic file because the engine commit in use
(0a0e8cb) documents it in its README but does not carry it in `encodings/`.

## Findings

- Revision 2 (cross-life flags, Pillar 3 laws, regime phase, reversals): ground
  1.0 s; 23 behaviours on five axes, exhaustive, 0.4 s at horizon 10 and the same
  23 at horizon 12, so the first act saturates by ten beats. Every axis value is
  covered (`branches-h10.txt`, `branches-h12.txt`).
- Vera's choice now reaches the other lives through the dossier: filing pays
  Kastan, a paid Kastan reports Jan, Jan is raided, recants or is turned, and a
  turned Jan can hand Vera's leak back to the state. Diagnosis of "Vera files and
  nothing ever happens to Jan" now names the law that forbids it (`paid_silence`).
- Courage costs: "Vera warns Marta and pays nothing" is forbidden by the physics
  itself (no law to waive). The regime falls only after it wavers and panics.
- Revision 1 (for the record): nine behaviours, Vera's choice independent of the
  fall (`branches-h8.txt`).
- Polyscene at commit 0a0e8cb: the toy world and 39 tests fail against its own
  latest encodings (the fixtures still write `stake/3`, the no-gap pulse refuses
  the toy's scheduled shock at step 3, the assumption rules are absent). The
  engine itself is sound; a note for the maintainer is in `REPORT.md`.
