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
informer Kastan), one person (Marta), one place (the border). Fifteen agent
actions and one world move (the crowd). Three unknowns a telling may assume:
Kastan loyal, the garrison wavering, Rybar vindictive. Three axes: fate
(fell quietly / fell in blood / held), Vera's choice (filed / burned / warned /
leaked / silent), Jan's fate (free / arrested).

## Status

**Concluded.** See `REPORT.md`: PROCEED on the technical question. The
assumption layer is stated in the topic file because the engine commit in use
(0a0e8cb) documents it in its README but does not carry it in `encodings/`.

## Findings

- Compile and ground: 0.8 s. Six cheapest tellings: 0.1 s. Nine behaviours on
  three axes, exhaustive: 0.1 s. Diagnosis: instant.
- Every axis value is covered. Branches rest on named assumptions.
- The space shows the Pillar 4 gap: Vera's choice and the fall are independent
  in this first topic. The real topic must make the filing feed the dossier
  flags the other storylines read (the leak → expose → crowd → gate chain is the
  one cross-life consequence present).
- Polyscene at commit 0a0e8cb: the toy world and 39 tests fail against its own
  latest encodings (the fixtures still write `stake/3`, the no-gap pulse refuses
  the toy's scheduled shock at step 3, the assumption rules are absent). The
  engine itself is sound; a note for the maintainer is in `REPORT.md`.
