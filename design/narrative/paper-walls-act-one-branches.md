# Paper Walls — Act One: the branch structure

> **Status**: Approved for act one (team-narrative, 2026-11-03)
> **Source of truth**: the polyscene topic in `prototypes/paper-walls-branches-concept/act1.{pddl,lp}` (to be re-homed under the Reactive Event Rules & Story Simulator system when its GDD is written). The story is a WORLD (state, motives, licences, laws, unknowns) and a set of END STATES; the engine finds every admissible telling. No path is scripted.

## How the structure is generated

- `act1.pddl` — what can happen: 48 action classes for nine agents (Vera, Jan, Tomas, Ondra, Rybar, Kastan, Marta, Ilona, Berta) and seven world moves (the ledger is called in, the press runs dry, the review is convened, the courier arrives, the inquiry at the post, the regime turns paranoid, a family tries the gate).
- `act1.lp` — who wants what (weighted preferences), how each class reads (courage / cowardice / neutral), the world's drift (Marta's breath, the street's unrest, the regime's stability, the office's attention to a gap), five unknowns a telling may assume (Kastan loyal; Berta has reported for years; Ilona already in the circle; Rybar vindictive; the route already watched), twelve laws, thirteen end-state axes and the nine ending classes.
- Laws of the game (beyond the engine's own): a courage beat must cost its actor; a cowardice beat must protect something its actor wants; a turning-point courage beat must cost a person, not only attention; a paid or long-standing informer cannot stay silent over a live fact; a cross-life flag must be read by another chapter within four beats; no protagonist ends the act unchanged; a gap in the ledger is noticed within four beats; the review sits by the end of week two; Marta's breath is a clock; a crosser at the gate is decided within two beats.

## The nine ending classes (end of Plan Week 41)

| Class | One sentence | Crosses |
|---|---|---|
| E1 The complete file | Vera filed; the route listed; Tomas, who let the courier through, holds the family with a list in his hand; Ilona admitted; Marta watched. | Vera → Tomas; Tomas → Marta |
| E2 The gap | Vera burned; Berta's initials beside the gap and Berta reported it; Vera watched, Ilona deferred; the courier came through on Ondra's line. | Vera → Berta |
| E3 The carbon | Ilona took the carbon; Jan printed Kastan's name; the file traced to the Records Section; Vera queried; the gate tightened. | Ilona → Vera; Jan → Vera; Jan → Tomas |
| E4 The seized parcel | Tomas held the courier; the border report corroborated 4471; Marta in hospital, which asked for papers; Jan with nothing to print. | Tomas → Vera, Jan, Marta |
| E5 The open gate | Tomas let him through and confessed; Jan printed and distributed; Vera closed the household file on Jan's name. | Tomas → Jan; Vera → Jan |
| E6 The mother's trade | Vera reported Jan to keep Ilona clear; raid; Ilona renounced; Ilona admitted. | Vera → Jan; Ilona → Jan |
| E7 The daughter's statement | 4471 unresolved; the review held; Ilona renounced and gave the cellar; Jan raided. | Ilona → Jan |
| E8 Marta's breath | Marta pleaded with Kastan and gave him Ilona's cellar visits; the route stayed open; Ilona refused; Vera learns what her warning bought. | Marta → Ilona, Vera |
| E9 The route burned | Tomas, or Jan under arrest, named the courier; the route gone; Marta failing; the widow's son's name on Vera's desk. | Tomas / Jan → Marta → Vera |
| E0 Nothing moved | Forbidden. `diagnose()` names exactly `no_one_unchanged`. | — |

Measured 2026-11-03 at horizon 14: all nine reachable; E0 forbidden by exactly `no_one_unchanged`; "Vera burns and the office never looks" forbidden by `gap_is_noticed`; "Tomas lets the courier through and nobody pays" impossible by the physics. 136 distinct end states on (ending class, Vera's ledger, Jan's fate, Tomas's gate), exhaustive in 33 s; more than 600 on all thirteen axes. One witness per class: `prototypes/paper-walls-branches-concept/act1-h14.txt`; the flowchart: `act1-flowchart.html`.

## How the writing attaches

`design/narrative/dialogue/act-one-beats.md` holds one beat per action class and one epilogue per ending class. The narrator (`act1_topic.py`) keys beats on the class name, so every telling the engine admits reads as prose with the state's paper line under each beat. A beat never refers to another beat by name; it refers to the object in the room. Writers add scenes by adding action classes to the world and beats to the file; they never add branches by hand.
