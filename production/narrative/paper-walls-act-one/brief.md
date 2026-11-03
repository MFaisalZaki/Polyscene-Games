# PAPER WALLS — Act One Narrative Brief

> **Scope**: weeks one and two of six; the vertical slice. One chapter per protagonist; the three must cross.
> **Written for**: a polyscene topic (PDDL domain + topic file). Nothing here is a flowchart. The act is a world (state, motives, licences, laws, unknowns) and a set of end states (axes). The engine finds the tellings.
> **Builds on**: `prototypes/paper-walls-branches-concept/` revision 2. Fluent and action names below reuse the prototype's where they exist and extend them where they do not; the prototype is reference, not a base to extend in place.
> **Mode**: autonomous. Decisions are stated, not asked. Open questions are listed at the end as CONCERNS.
> **Date**: 2026-11-03

---

## 0. Decisions made up front

1. **One route binds all three lives.** Marta's son in Vienna sends her asthma medicine by a courier; the same courier carries Jan's paper and ink; the drop is Jan's cellar; the courier enters through Tomas's gate. Report 4471 ("the parcel was medicine") exists because that route crossed Kastan's stairwell last month. So the border, the cellar and the desk are already one story before anyone acts.
2. **Act one's regime phases are `confident -> paranoid`.** `wavering` and `panicking`, the crowd and the order to fire belong to acts two and three. Their world moves keep windows beyond the act-one horizon. The state's attention in act one is a list at the gate, a query to the desk, and a deferred review — not a rifle.
3. **Courage costs a person.** Every turning-point action writes a cost onto a named person's fluent (Berta implicated, Ondra liable, Ilona's review flagged, Marta's breath), never only `attention`. `attention` remains as the pressure numeric that makes the state look, not as the price of a deed.
4. **Marta, Ilona, Berta and Ondra are agents** with preferences; the courier is a person-object (he never chooses on screen; he arrives, passes or is held).
5. **Names**: Vera Halm, Ilona Halm (daughter), Jan Rusek, Tomas Bren, Marta Sokol, Berta Lisk, Kastan (caretaker; one name, the building's), Captain Rybar, Ondra Petrik (new: Tomas's bunkmate), the courier (Marek; a person, not an agent). The city, regime and ministry names are the game concept's. All fictional.
6. **Beat budget**: horizon 12 for the act (roughly six beats a week). Each chapter contributes three to five of those beats; the rest are the state's and the world's.

---

## 1. Dramatic question and the three arcs

**Act one's dramatic question: *Whose name completes the file?***
The household file is one entry short; the gate log is one line short; the press is one ream short. The act asks each protagonist what they will write down to close their own gap, and on whom. By the end of week two a name has gone into the ledger — the only question the engine cannot answer for the player is whether it is Marta's, Jan's, Berta's, the courier's, or the protagonist's own.

### Vera Halm — the archivist (Vrba Street: the desk)

| Stage | Content | Fluents |
|---|---|---|
| Introduction | Report 4471 on her desk, Kastan's hand: a parcel at Marta Sokol's door, flat 3. Household file for Halm, flat 5: *incomplete*. Ilona's admission: *pending review*. Berta at the next desk initialled the intake log. | `report_received(vera, marta)`, `household_complete(vera) = false`, `review_pending(ilona)` |
| Pressure | Marta is short of breath on the landing. Rybar wants the ledger reconciled before the inspection. If Tomas held the courier, a second report (`border_report`) corroborates 4471 and the gap becomes a question. If Ilona is in Jan's circle, Vera is one Kastan report from learning it. | `border_report(vera)`, `discrepancy(vera)`, `knows_parcel(vera)`, `breath(marta)` falling |
| Turning point | 4471 leaves *pending*. **The turn flag is `ledger_4471` resolving**: `filed(marta)` (cowardice: Marta watched, Ilona's review clears) or `burned(marta)` (courage: a gap with Berta's initials beside it). A third, dirtier close is `doctored(vera)` (she re-writes the intake line so there is no gap; Berta's initials now sit on a forgery). | `filed(marta)` / `burned(marta)` / `doctored(vera)` |
| Reversal (available) | Having burned, she can `recover-report` under query (Berta cleared, Marta watched) or `take-blame` (Berta cleared, Vera watched, Ilona's household flagged). Having learned Ilona is in the circle, she can `report-jan`: the cleanest household on Vrba Street bought with the cellar's address. | `took_blame(vera)`, `under_observation(jan)` via Vera |

Vera's arc in one line: an archivist who believed she only copies learns that every copy is a choice, and that the cheapest choice is always paid by someone at the next desk or the next door.

### Jan Rusek — the dissident (Vrba Street: the cellar)

| Stage | Content | Fluents |
|---|---|---|
| Introduction | A press, no paper. The paper is on the courier. Ilona Halm (perhaps already) sits in on the circle: the archivist's daughter, who could carry a carbon. | `has_paper(jan) = false`, `in_circle(ilona)` (unknown) |
| Pressure | The courier comes through or does not (Tomas). Kastan watches the cellar steps. The leaflets, once out, bring `paranoid` and tighten the gate — which Jan never sees but Tomas does. | `courier_through(border)`, `has_paper(jan)`, `under_observation(jan)` |
| Turning point | **The turn flag is `leaflets_distributed(jan)`** — he goes public with what he has, or `has_file(jan)` becomes true by his asking Ilona for her mother's carbon (`asked_carbon(jan)`): the moment he uses a person as a source. | `leaflets_distributed(jan)`, `asked_carbon(jan)` |
| Reversal (available) | Under observation or arrest he can `recant` (the press goes quiet, Ilona is safe), `cut-ilona` (she is out, and hates him for it) or `give-name` — the courier's (Marta's breath stops), Ilona's (her review is refused), or Vera's. | `recanted(jan)`, `cut(ilona)`, `gave_name(jan, X)` |

Jan's arc in one line: a man who prints the truth discovers that his route runs on an old woman's lungs and a girl's future, and that the state knows how to price both.

### Tomas Bren — the conscript (the crossing)

| Stage | Content | Fluents |
|---|---|---|
| Introduction | Week one, night shift, the log is Ondra's; the courier at the gate with a parcel. Nobody has told the post anything yet — unless the route is already on a list (`route_watched`, unknown) or Vera has filed and Rybar has listed it. | `courier_at_gate(border)`, `courier_listed(border)` |
| Pressure | `inquiry_at_post`: a captain's visit about the log (licensed by a gap or a listed name). Then in week two, if the leaflets are out, the gate is tightened and a family tries it. | `log_gap(border)`, `inquiry(border)`, `border_tightened(border)`, `family_at_gate(border)` |
| Turning point | **The turn flag is `courier_through(border)` or `courier_detained(border)`** — this is the act's earliest turn, in week one, and the one the other two chapters inherit: through means Marta breathes and Jan prints; held means `border_report` lands on Vera's desk and the press stays silent. | `courier_through` / `courier_detained` |
| Reversal (available) | Under inquiry: `confess-gap` (his record, not Ondra's), or `name-route` (the courier's name, Ondra clear, Marta's route burned). Ondra, independently, can `cover-log` or `report-tomas`. The family at the gate in week two is the second test, taken with whatever record he now has. | `on_report(tomas)`, `route_burned(border)`, `liable(ondra)` |

Tomas's arc in one line: a nineteen-year-old discovers the gate is a pen — whatever he lets through or holds becomes a line on someone else's desk — and that the only names he can keep off the log are bought with his bunkmate's.

### How the three cross (the act's required crossings)

| From | Through the dossier | Lands in |
|---|---|---|
| Tomas holds the courier | `border_report(vera)` corroborates 4471; `has_medicine(marta)` stays false; `has_paper(jan)` stays false | Vera's desk (the gap becomes a question); Jan's cellar (nothing to print); Marta's lungs |
| Vera files Marta | Rybar lists the route: `courier_listed(border)` | Tomas's gate (the next crosser is on a list) |
| Vera leaks / Ilona takes the carbon | `has_file(jan)`, `carbon_missing(vera)` | Jan's press (Kastan's name); Berta's intake count |
| Jan distributes | `paranoid(city)`, `border_tightened(border)` | Tomas's gate (the family); every desk's `attention` |
| Jan gives the courier's name / Tomas names the route | `route_burned(border)` | Marta's breath; Vera's neighbour in hospital, asking for papers |
| Ilona renounces / Vera reports Jan | `under_observation(jan)` | Jan's cellar (raid) |

---

## 2. The cast as agents

Every agent carries weighted preferences over fluent values. Weights are 1–4, the prototype's scale. "Will not" is a hard absence: no action in the repertoire lets them do it.

### Vera Halm — archivist, Records Office, flat 5 Vrba Street
- **Role**: the hand that copies. Protagonist one.
- **Wants** (weighted): `household_complete(vera)` true 4; `under_observation(vera)` false 3; `admitted(ilona)` true 4; `implicated(berta)` false 2; `under_observation(marta)` false 1; `breath(marta)` up 2; `has_file(jan)` true 1; `attention(vera)` down 1.
- **Fear**: Ilona's letter arriving with *refused* and her own initials in the reason.
- **Will not**: file on Ilona. There is no action in which Vera writes her daughter into the ledger. (She *can* write Jan in to keep Ilona out.)
- **Courage costs**: Berta (burn), Ilona (warn), herself (take-blame). **Cowardice protects**: Ilona (file, recover, report-jan), herself (doctor).

### Jan Rusek — dissident, cellar press, Vrba Street
- **Role**: the hand that prints. Protagonist two.
- **Wants**: `leaflets_distributed(jan)` true 3; `leaflets_printed(jan)` true 2; `exposed(kastan)` true 2; `arrested(jan)` false 4; `under_observation(jan)` false 2; `recanted(jan)` false 1; `at_risk(ilona)` false 3; `source_traced(jan)` false 2; `has_medicine(marta)` true 1; `attention(jan)` down 1.
- **Fear**: the name of someone he recruited read aloud in a corridor.
- **Will not**: print a lie. (He can print a true name that gets someone hurt; he cannot print a false one. No action fabricates.)
- **Courage costs**: Ilona (ask-carbon, print while she is in the circle), Vera (expose: the file is traced to its source). **Cowardice protects**: himself (recant, give-name), Ilona (cut-ilona).

### Tomas Bren — conscript, 19, the crossing
- **Role**: the hand that holds the gate. Protagonist three.
- **Wants**: `courier_detained(border)` false 2 (he does not want to be the one who held an old woman's medicine; he knows what the parcel is from the first scene); `on_report(tomas)` false 3; `liable(ondra)` false 3; `route_burned(border)` false 1; `family_detained(border)` false 3; `unit_commended(border)` true 1.
- **Fear**: the stockade, and Ondra in it for his line in the log.
- **Will not**: fire. (Out of scope for act one; stated so the topic never offers it before act two.)
- **Courage costs**: Ondra (let-pass puts the gap on Ondra's log), himself (confess). **Cowardice protects**: Ondra and his record (detain, name-route).

### Marta Sokol — widow, flat 3, asthmatic
- **Role**: the person the first fact is about. Agent, not object.
- **Wants**: `breath(marta)` up 4; `route_burned(border)` false 3 (her son's one line to her); `admitted(ilona)` true 2 (she minded Ilona as a child); `under_observation(marta)` false 1; `hospitalised(marta)` false 2.
- **Fear**: her son coming himself, and being held at the gate Tomas stands.
- **Will not**: name her son. (No action gives the sender; she can give the route's *other* end — Jan's cellar — or Ilona.)
- **Courage costs**: her own breath (send-word pauses the route). **Cowardice protects**: her breath and the route (plead-kastan sells Ilona's cellar visits).

### Ilona Halm — 18, applicant, flat 5
- **Role**: the lever. The state's hold on Vera, Jan's possible source, Marta's second daughter.
- **Wants**: `admitted(ilona)` true 3; `in_circle(ilona)` true 2; `under_observation(vera)` false 2; `arrested(jan)` false 2; `renounced(ilona)` false 1.
- **Fear**: being the reason — for either of them.
- **Will not**: name her mother. (`renounce` names the cellar, never the desk.)
- **Courage costs**: her mother (take-carbon: `carbon_missing(vera)`), her review (join-circle: `attention(ilona)` and `at_risk(ilona)`). **Cowardice protects**: her admission (renounce: the cellar's address in exchange).

### Berta Lisk — archivist, the next desk, four years from pension
- **Role**: the witness at the desk. The person Vera's courage costs.
- **Wants**: `implicated(berta)` false 4; `ledger_reconciled(office)` true 2; `under_observation(vera)` false 1 (she likes Vera; it weighs one); `reported(berta)` false 1 (she would rather not have been the one).
- **Fear**: her initials under a gap.
- **Will not**: say a name aloud. Everything Berta does, she does on paper — her `report-colleague` is a memo, her `cover-vera` a re-initialled line. (Scene direction: Berta never has a spoken line that accuses.)
- **Courage costs**: herself (cover-vera: `liable(berta)`). **Cowardice protects**: herself (report-colleague).

### Kastan — caretaker, Vrba Street, paid informer
- **Role**: the state's eye in the building. The informer the prototype had; he keeps `paid_silence`.
- **Wants**: `under_observation(jan)` true 2; `under_observation(vera)` true 2; `rewarded(kastan)` true 3; `exposed(kastan)` false 4.
- **Fear**: his name on a landing.
- **Will not**: report Marta directly. (He reported her parcel once — 4471 — and it has sat for a month; he reports *visitors*: Vera at her door, the courier on the stairs. The old woman herself he leaves to the desk. This is the one soft spot that makes him a person.)
- **Cowardice protects**: his pay (inform, report-neighbour). He has no courage class.

### Captain Rybar — state security, the Section
- **Role**: the state's attention, embodied. Pillar 2's face.
- **Wants**: `ledger_reconciled(office)` true 3; `under_observation(jan)` true 3; `arrested(jan)` true 2 (act one: he prefers to watch); `courier_listed(border)` true 2; `unrest(city)` down 2; `under_observation(vera)` true 1.
- **Fear**: a gap he did not see first.
- **Will not**: strike where he has not looked. (Law `attention_precedes_action`: every Rybar action's precondition is a flag or an `attention` threshold the player can see.)
- Neutral class only: the state is weather, not a moral actor.

### Ondra Petrik — conscript, Tomas's bunkmate, keeps the log
- **Role**: the person Tomas's courage costs.
- **Wants**: `liable(ondra)` false 4; `on_report(tomas)` false 2; `unit_commended(border)` true 1.
- **Fear**: carrying someone else's line.
- **Will not**: lie to the captain's face. (`cover-log` is a rewritten line before the inquiry, never a spoken denial during it; once `inquiry(border)` holds, cover-log is no longer available.)
- **Courage costs**: himself (cover-log). **Cowardice protects**: himself (report-tomas).

### The courier (Marek) — person, not agent
Arrives (world move), passes or is held (Tomas), is sheltered or seen (Jan, Kastan), is named or not (Jan, Tomas). He never chooses on screen. His fluents live on the border place.

---

## 3. The state space

### Places (two)
| Place | Meaning |
|---|---|
| `vrba` — Vrba Street: the building (flats 3 and 5, the cellar, the stairwell) and the Records Office at its end | **Where facts are written.** Everything that happens here becomes a line on paper within a beat. |
| `border` — the crossing | **Where facts are enforced.** Nothing here is written by the people who act; the log is kept by someone else, and the lists arrive from Vrba Street. |

### Dossier flags (booleans), per character

**Vera**: `report_received(vera, marta)` (init true), `knows_parcel(vera)`, `border_report(vera)`, `filed(marta)`, `burned(marta)`, `doctored(vera)`, `discrepancy(vera)`, `carbon_missing(vera)`, `household_complete(vera)`, `household_flagged(vera)`, `took_blame(vera)`, `under_observation(vera)`, `knows_ilona_circle(vera)`.

**Jan**: `has_paper(jan)`, `has_file(jan)`, `leaflets_printed(jan)`, `leaflets_distributed(jan)`, `asked_carbon(jan)`, `courier_sheltered(jan)`, `source_traced(jan)`, `press_raided(jan)`, `arrested(jan)`, `recanted(jan)`, `gave_name(jan, X)` for X in {courier, ilona, vera}, `under_observation(jan)`.

**Tomas**: `on_report(tomas)`, `named_route(tomas)`, `confessed(tomas)`.

**Marta**: `has_medicine(marta)`, `warned(marta)`, `route_paused(marta)`, `pleaded(marta)`, `under_observation(marta)`, `hospitalised(marta)`.

**Ilona**: `in_circle(ilona)`, `at_risk(ilona)`, `took_carbon(ilona)`, `renounced(ilona)`, `review_pending(ilona)` (init true), `admitted(ilona)`, `review_deferred(ilona)`, `review_refused(ilona)`, `under_observation(ilona)`.

**Berta**: `implicated(berta)`, `reported(berta)`, `liable(berta)`, `knows_gap(berta)`.

**Kastan**: `rewarded(kastan)`, `exposed(kastan)`, `knows_ilona(kastan)`.

**Ondra**: `liable(ondra)`, `reported_tomas(ondra)`.

**The state / the office**: `ledger_reconciled(office)`, `paranoid(city)`, `review_sat(office)`.

**The border**: `courier_at_gate`, `courier_through`, `courier_detained`, `courier_listed`, `log_gap`, `log_covered`, `inquiry`, `border_tightened`, `family_at_gate`, `family_through`, `family_detained`, `route_burned`, `unit_commended`.

### Numeric pressures
| Fluent | Range | Opening | Meaning |
|---|---|---|---|
| `unrest(city)` | 0–12 | 1 | How loud the street is. Act one tops out around 5. |
| `stability(regime)` | 0–10 | 9 | How sure the state is. `paranoid` needs it ≤ 7; `wavering` (act two) ≤ 5. |
| `attention(x)` for every agent and the courier | 0–6 | vera 0, jan 1, tomas 0, marta 1, ilona 0, berta 0, kastan 0, ondra 0, courier 0 | The visible weight of the state's eye on one person. ≥ 3 licenses Rybar to look; ≥ 4 is `under_observation` in all but name. |
| `breath(marta)` | 0–4 | 2 | Marta's lungs. 0 is the hospital, and the hospital asks for papers. **This is the act's clock.** |

### Opening state (Friday, week one)
4471 on Vera's desk, one month old; household file incomplete; Ilona's review pending. Jan: a press, no paper, a circle of four (five if Ilona). Tomas: night shift tonight; Ondra has the log. Marta: two days of medicine left (`breath = 2`). The courier: crosses tonight or tomorrow (window 2–4). The regime: confident.

### Drift
| Numeric | Rate | While |
|---|---|---|
| `breath(marta)` | −1 per 3 beats | `has_medicine(marta)` false |
| `unrest(city)` | +1 per 2 beats | `leaflets_distributed(jan)` |
| `stability(regime)` | −1 per 3 beats | `paranoid(city)` |
| `attention(vera)` | +1 per 3 beats | `discrepancy(vera)` (a gap is a thing the office keeps looking at) |

---

## 4. The action repertoire (36)

Legend. **Class**: C+ courage (must cost its actor, by law), C− cowardice (must protect something its actor wants, by law), N neutral (the state's moves and plain acts of knowing). **Cost** and **Protects** name the actor's own preference that moves; a person in brackets is who ultimately carries it. Numeric effects on `attention` are listed last and are never the only cost of a C+ action at a turning point (law `cost_is_a_person`).

### Vera (9)

| # | Action | Needs | Changes | Cost → / Protects ← | Class |
|---|---|---|---|---|---|
| V1 | `read-file` | `report_received`, not `knows_parcel` | `knows_parcel(vera)` | — | N |
| V2 | `file-report` (marta, kastan) | `report_received`, not `filed`, not `burned` | `filed(marta)`, `under_observation(marta)`, `household_complete(vera)`, `rewarded(kastan)`, `ledger_reconciled`, `attention(marta)+2` | Cost → Marta watched. Protects ← Ilona (household complete) | C− |
| V3 | `burn-report` (marta) | `report_received`, not `filed`, not `burned`, not `doctored` | `burned(marta)`, `discrepancy(vera)`, `implicated(berta)`, `knows_gap(berta)`, `attention(vera)+1` | Cost → Berta implicated [Berta] | C+ |
| V4 | `recover-report` (marta, kastan) | `burned`, `discrepancy`, queried (`under_observation(vera)` or `reported(berta)`) | as V2, plus `discrepancy` false, `implicated(berta)` false | Cost → Marta. Protects ← Berta cleared, Ilona | C− |
| V5 | `doctor-ledger` | `discrepancy(vera)`, not `under_observation(vera)` | `doctored(vera)`, `discrepancy` false, `ledger_reconciled`, `implicated(berta)` true (her initials now sit on a forged line), `household_complete` | Protects ← herself, Ilona. Cost falls on Berta, which Vera weighs at 2 — this is the act's dirtiest C− and it still passes the law because it protects | C− |
| V6 | `warn` (marta) | `knows_parcel`, not `warned(marta)` | `warned(marta)`, `household_flagged(vera)` (Kastan's building book: *Halm at Sokol's door, 23:10*), `attention(vera)+2` | Cost → Ilona's review flagged [Ilona] | C+ |
| V7 | `leak-file` (jan) | `report_received`, not `has_file(jan)`, not `arrested(jan)` | `has_file(jan)`, `carbon_missing(vera)`, `knows_gap(berta)`, `attention(vera)+1` | Cost → Berta's count [Berta], herself | C+ |
| V8 | `take-blame` | `implicated(berta)`, (`under_observation(vera)` or `reported(berta)` or `inquiry` at the office) | `took_blame(vera)`, `implicated(berta)` false, `under_observation(vera)`, `household_flagged(vera)`, `attention(vera)+2` | Cost → herself watched, Ilona flagged. Protects ← Berta | C+ (reversal) |
| V9 | `report-jan` | `knows_ilona_circle(vera)`, not `under_observation(jan)` | `under_observation(jan)`, `household_complete(vera)` (the file closes on a *different* name), `attention(jan)+2` | Cost → Jan [Jan]. Protects ← Ilona (the circle is broken before the review) | C− (cross-life) |

Vera's cross-life actions: V2 (through Rybar's R4 to Tomas's gate), V7 (to Jan), V9 (to Jan). Reversals: V4, V8.

### Jan (8)

| # | Action | Needs | Changes | Cost → / Protects ← | Class |
|---|---|---|---|---|---|
| J1 | `receive-courier` | `courier_through`, not `courier_sheltered` | `courier_sheltered(jan)`, `has_paper(jan)`, `has_medicine(marta)`, `attention(jan)+1` | — (the route doing what it is for) | N |
| J2 | `print-leaflets` | `has_paper`, not `press_raided`, not `printed`, not `arrested`, not `recanted` | `leaflets_printed`, `unrest+1`, `attention(jan)+1`; if `in_circle(ilona)`: `at_risk(ilona)` | Cost → Ilona at risk [Ilona] when she is in the circle; else attention only (not a turning point, so permitted) | C+ |
| J3 | `distribute` | `leaflets_printed`, not `distributed`, not `arrested`, not `recanted` | `leaflets_distributed`, `unrest+2`, `stability−1`, `border_tightened(border)`, `attention(jan)+2`, `at_risk(ilona)` if in circle | Cost → Ilona [Ilona]; and the gate tightens on Tomas, which Jan never sees | C+ (turn; cross-life to Tomas) |
| J4 | `expose-informer` (kastan) | `has_file`, not `exposed(kastan)`, not `arrested`, not `recanted` | `exposed(kastan)`, `source_traced(jan)`, `attention(vera)+2`, `unrest+1`, `stability−1` | Cost → his source [Vera] | C+ (cross-life to Vera) |
| J5 | `ask-carbon` (ilona) | `in_circle(ilona)`, not `has_file`, not `asked_carbon` | `asked_carbon(jan)`, `at_risk(ilona)` | Cost → Ilona [Ilona] | C+ (cross-life to Vera via I2) |
| J6 | `cut-ilona` | `in_circle(ilona)`, not `arrested` | `in_circle(ilona)` false, `at_risk(ilona)` false, `cut(ilona)` | Protects ← Ilona, himself (one fewer who knows the cellar) | C− |
| J7 | `recant` | `under_observation(jan)`, not `arrested`, not `recanted` | `recanted`, `under_observation(jan)` false, `attention(jan)−2`, `at_risk(ilona)` false | Protects ← himself, Ilona | C− (reversal) |
| J8 | `give-name` (X ∈ courier, ilona, vera) | `arrested(jan)` or (`under_observation(jan)` and `paranoid`) | `gave_name(jan, X)`, `arrested` false; X=courier: `route_burned`; X=ilona: `under_observation(ilona)`, `review_refused` on the next review; X=vera: `under_observation(vera)` | Protects ← himself. Cost lands on Marta / Ilona / Vera | C− (reversal; cross-life) |

Jan's cross-life actions: J3 (to Tomas), J4 (to Vera), J5 (to Vera), J8 (to Marta/Vera). Reversals: J7, J8.

### Tomas (4)

| # | Action | Needs | Changes | Cost → / Protects ← | Class |
|---|---|---|---|---|---|
| T1 | `let-pass` (crosser ∈ courier, family) | `<crosser>_at_gate`, not through/detained; for the family: `border_tightened` | `<crosser>_through`, `log_gap(border)`, `liable(ondra)` (the log is his); if `courier_listed` or `border_tightened`: `attention(tomas)+2` | Cost → Ondra [Ondra] | C+ (turn; cross-life to Marta, Jan, Vera) |
| T2 | `detain` (crosser) | `<crosser>_at_gate`, not through/detained | `<crosser>_detained`; courier: `border_report(vera)`, `attention(marta)+2`, `attention(jan)+1` (the parcel's drop address); family: `unrest+1`; both: `unit_commended` | Protects ← Ondra, his record. Cost lands on Marta's breath and Jan's paper, and the desk | C− (cross-life to Vera, Jan) |
| T3 | `confess-gap` | `log_gap`, `inquiry(border)`, `liable(ondra)` | `confessed(tomas)`, `on_report(tomas)`, `liable(ondra)` false, `log_gap` false | Cost → himself. Protects ← Ondra | C+ (reversal) |
| T4 | `name-route` | `log_gap` or `on_report(tomas)`, `inquiry(border)` | `named_route(tomas)`, `route_burned(border)`, `liable(ondra)` false, `on_report(tomas)` false, `attention(marta)+2` | Protects ← himself, Ondra. Cost lands on Marta [Marta], through Vera's door | C− (reversal; cross-life to Marta/Vera) |

### Ondra (2)

| # | Action | Needs | Changes | Cost → / Protects ← | Class |
|---|---|---|---|---|---|
| O1 | `cover-log` | `log_gap`, not `inquiry(border)` | `log_covered`, `log_gap` false, `liable(ondra)` true (now his line is false, not merely short) | Cost → himself | C+ |
| O2 | `report-tomas` | `log_gap` or `log_covered`, `inquiry(border)` | `reported_tomas(ondra)`, `on_report(tomas)`, `liable(ondra)` false | Protects ← himself. Cost lands on Tomas | C− |

### Ilona (3)

| # | Action | Needs | Changes | Cost → / Protects ← | Class |
|---|---|---|---|---|---|
| I1 | `join-circle` | not `in_circle`, not `renounced`, not `arrested(jan)` | `in_circle(ilona)`, `at_risk(ilona)`, `attention(ilona)+1` | Cost → her review (at_risk) | C+ |
| I2 | `take-carbon` | `in_circle`, `asked_carbon(jan)`, not `has_file(jan)`, not `carbon_missing(vera)` | `took_carbon(ilona)`, `has_file(jan)`, `carbon_missing(vera)`, `knows_gap(berta)` | Cost → her mother [Vera] | C+ (cross-life to Vera) |
| I3 | `renounce` | `in_circle`, (`review_deferred` or `under_observation(ilona)`) | `renounced(ilona)`, `in_circle` false, `under_observation(jan)`, `review_pending` restored (a second sitting), `at_risk` false | Protects ← her admission. Cost lands on Jan [Jan] | C− (cross-life to Jan) |

### Marta (2)

| # | Action | Needs | Changes | Cost → / Protects ← | Class |
|---|---|---|---|---|---|
| M1 | `send-word` | `warned(marta)` or `border_report` known to her (`knows_parcel(vera)` and `warned`), not `route_paused` | `route_paused(marta)`: the next crossing is cancelled; `family_at_gate` cannot be the courier's run; `has_medicine` cannot become true this act | Cost → her own breath | C+ |
| M2 | `plead-kastan` | `in_circle(ilona)` (she has seen the girl on the cellar stairs), `breath ≤ 1`, not `pleaded` | `pleaded(marta)`, `knows_ilona(kastan)`, `attention(ilona)+2`, `route_paused` false / `attention(marta)−1` (Kastan looks away from flat 3) | Protects ← her breath, the route. Cost lands on Ilona | C− (cross-life to Vera's household) |

### Berta (2)

| # | Action | Needs | Changes | Cost → / Protects ← | Class |
|---|---|---|---|---|---|
| B1 | `report-colleague` | `knows_gap(berta)`, not `reported(berta)` | `reported(berta)`, `discrepancy(vera)` (if not already), `under_observation(vera)`, `attention(vera)+2`, `implicated(berta)` false | Protects ← herself | C− |
| B2 | `cover-vera` | `knows_gap(berta)`, `implicated(berta)`, not `under_observation(vera)` | `liable(berta)`, `ledger_reconciled`, `discrepancy` false, `carbon_missing` false | Cost → herself. Protects Vera and, through the household file, Ilona | C+ |

### Kastan (2)

| # | Action | Needs | Changes | Cost → / Protects ← | Class |
|---|---|---|---|---|---|
| K1 | `inform` (jan) | not `exposed(kastan)`, not `under_observation(jan)`, not `recanted(jan)` | `under_observation(jan)`, `attention(jan)+1`; if `knows_ilona(kastan)`: `attention(ilona)+1` | Protects ← his pay | C− |
| K2 | `report-neighbour` (vera) | `household_flagged(vera)` or `courier_sheltered(jan)` seen from the stairs, not `exposed`, not `under_observation(vera)` | `under_observation(vera)`, `attention(vera)+2` | Protects ← his pay | C− |

### Rybar (4)

| # | Action | Needs | Changes | Class |
|---|---|---|---|---|
| R1 | `query-ledger` (vera) | `discrepancy(vera)` or `border_report(vera)` and not `filed(marta)`, or `attention(vera) ≥ 3`; not `under_observation(vera)` | `under_observation(vera)`, `attention(vera)+2` | N |
| R2 | `raid` (jan) | `under_observation(jan)`, not `press_raided`, not `recanted`; before `paranoid` only if `rybar_vindictive` (licence) | `press_raided`, `arrested(jan)`, `unrest+2`; if `in_circle(ilona)`: `under_observation(ilona)` | N |
| R3 | `hold-review` (ilona) | `review_pending`, (`household_flagged` or `discrepancy(vera)` or `under_observation(ilona)` or `rybar_vindictive`) | `review_deferred(ilona)` — the state saying, in writing, that it is waiting for Vera | N (cross-life: the state reaches Ilona to move Vera) |
| R4 | `list-route` (border) | `filed(marta)` or `route_watched` (unknown) or `named_route(tomas)`, not `courier_listed` | `courier_listed(border)`; the next crosser at Tomas's gate is on a list | N (cross-life: the desk reaches the gate) |

### World moves (not counted in the 36)

| Move | Window | Licence | Effect |
|---|---|---|---|
| `courier_at_gate` | 2–4 | none (he is already on the road) | `courier_at_gate(border)` |
| `inquiry_at_post` | 5–10 | `log_gap` or `log_covered` or `courier_listed` | `inquiry(border)`; closes O1 |
| `regime_paranoid` | 6–12 | `leaflets_distributed` or `discrepancy(vera)` or `border_report(vera)` or `exposed(kastan)` | `paranoid(city)`, `stability−1`, `attention(x)+1` for every agent with attention ≥ 1 |
| `family_at_gate` | 7–11 | `border_tightened` or `route_paused` (someone else uses the route's gap) | `family_at_gate(border)` |
| `review_admits` | 9–12 | precondition: `review_pending`, `household_complete`, not `household_flagged`, not `under_observation(ilona)`, not `renounced` pending | `admitted(ilona)`, `review_sat` |
| `review_defers` | 9–12 | precondition: `review_pending`, not the above | `review_deferred(ilona)` or, if `under_observation(ilona)` or `gave_name(jan, ilona)`: `review_refused(ilona)`; `review_sat` |
| `marta_collapses` | any | precondition: `breath(marta) = 0` | `hospitalised(marta)`, `under_observation(marta)` (the hospital asks for papers), `attention(vera)+1` |

Act-two world moves (`crowd_gathers`, `regime_wavers`, `regime_panics`) are declared with windows starting at 13 so the act-one horizon never reaches them and the topic file is the same file across acts.

---

## 5. The unknowns

Five premises the opening may assume. Each costs one (the prototype's `assume_min` mechanism). Each licenses actions that would otherwise be unmotivated; the engine reports which tellings rest on which.

| Unknown | Premise | Licenses | What it means for the act |
|---|---|---|---|
| `kastan_loyal` | Kastan still reports without being paid | K1 `inform`, K2 `report-neighbour` (otherwise these need `rewarded(kastan)` — i.e. Vera's filing) | Whether Vera's filing is what turns Kastan on Jan, or whether he was already turned |
| `berta_reports` | Berta has been reporting on the next desk for years | B1 `report-colleague` without `implicated(berta)`; and `knows_gap(berta)` is set by any of V3/V5/V7 at once instead of a beat later | Whether Vera's desk was ever private |
| `ilona_in_circle` | Ilona already sits in Jan's circle at the opening | sets `in_circle(ilona)` at the opening; licenses J5 `ask-carbon`, M2 `plead-kastan`, V9 `report-jan` (through `knows_ilona_circle`, which K1-with-`knows_ilona` or M2 produces) | Whether the household file was ever completable with Marta's name alone |
| `rybar_vindictive` | Rybar wants Vera, not just the ledger | R2 `raid` before `paranoid`; R3 `hold-review` with no flag on the household | Whether the state is procedure or appetite in week one |
| `route_watched` | The Vienna route was on a list before the act began | R4 `list-route` without `filed(marta)`; `inquiry_at_post` without a gap | Whether Vera's courage at the desk was ever more than a gesture: if the route was watched, burning 4471 protects no one and still costs Berta. This is Pillar 3's cruellest telling and it must be reachable |

Not an unknown in act one: `garrison_wavers` (act two).

---

## 6. The laws

The engine's own (intentional, connected, loop_free, repeat, warranted, incompatible) are assumed. The topic adds these; the first three exist in the prototype and are kept.

| Law | Forbidden pattern (one sentence) | Pillar |
|---|---|---|
| `costless_courage` | A courage beat whose actor loses nothing they weigh at that step. | 3 |
| `unprotected_cowardice` | A cowardice beat whose actor gains nothing they weigh at that step. | 3 |
| `paid_silence` | A paid, unexposed informer who files nothing for two beats after being paid. | 1, 3 |
| `licensed_silence` | Any agent holding a live licence to inform (`kastan_loyal`/`rewarded`, `berta_reports`, `knows_gap`) and a fact to inform on who stays silent for three beats — generalises `paid_silence` to Berta and Ondra. | 1 |
| `cost_is_a_person` | A turning-point courage beat (V3, V6, V7, J3, J5, T1, I2) whose only cost term is `attention`. | 3 |
| `attention_precedes_action` | A Rybar beat against a person who is neither flagged nor at `attention ≥ 3` at that step: the state never strikes where it has not looked. | 2 |
| `no_panic_before_crowd` | `regime_panics` at a step with no `crowd_at`; and `regime_paranoid` at a step with none of its licensing facts true — the state's phases are read, never spontaneous. | 2 |
| `crossing_read` | A cross-life flag (`border_report`, `courier_listed`, `has_file` via I2, `border_tightened`, `route_burned`, `under_observation(jan)` via V9/I3, `knows_ilona(kastan)` via M2) that is set and then not read as a precondition or licence by an action in the *receiving* protagonist's chapter within four beats. | 4 |
| `no_one_unchanged` | A close at which any protagonist's turn-flag set is untouched: Vera's `{filed, burned, doctored, warned, has_file(jan), under_observation(jan) via V9}`, Jan's `{leaflets_distributed, asked_carbon, recanted, gave_name, arrested}`, Tomas's `{courier_through, courier_detained, family_through, family_detained}`. | 3, 4 |
| `gap_is_noticed` | A `discrepancy(vera)` that stands four beats with neither `query-ledger` nor `report-colleague` nor `cover-vera` — the office always balances. | 2 |
| `breath_is_a_clock` | A close at which `breath(marta)` has not moved and `has_medicine(marta)` is false — Marta cannot be a backdrop; if nobody acts on her the drift must. (Implementation: a world-move check rather than a law, if drift already guarantees it.) | 4 |
| `one_file_per_household` | `filed(marta)` and `under_observation(jan)`-via-V9 both true at the close with `household_complete` set twice — Vera closes the file on one name, not two. (Implementation: an `incompatible` pair rather than a law.) | 1 |

Incompatible pairs (state, not sequence): `filed(marta)` / `burned(marta)`; `courier_through` / `courier_detained` (same for family); `admitted(ilona)` / `review_refused(ilona)`; `recanted(jan)` / `arrested(jan)`; `confessed(tomas)` / `named_route(tomas)`.

---

## 7. End-state axes and the ending classes of act one

### Axes (read off the state at the close)

| Axis | Values |
|---|---|
| `vera_ledger` | `filed` / `burned` / `doctored` / `pending` |
| `vera_reach` | `none` / `warned` / `leaked` / `reported_jan` (what she did beyond the desk; `leaked` includes Ilona's carbon) |
| `vera_fate` | `unwatched` / `watched` / `blamed` (watched by her own hand: `took_blame`) |
| `ilona_review` | `admitted` / `deferred` / `refused` / `renounced` |
| `jan_press` | `silent` / `printed` / `distributed` / `named_kastan` |
| `jan_fate` | `free` / `watched` / `arrested` / `recanted` / `gave_name` |
| `tomas_gate` | `untested` / `passed` / `held` / `split` (one through, one held) |
| `tomas_cost` | `none` / `self` (on report) / `ondra` (liable at close) / `route` (named) |
| `marta_fate` | `supplied` / `cut_off` / `hospital` — crossed with `watched` yes/no |
| `berta_fate` | `clean` / `implicated` / `liable` / `reporter` |
| `regime` | `confident` / `paranoid` |
| `kastan` | `hidden` / `exposed` |

Twelve axes is more than the prototype's five. The engine returns one witness per distinct *combination*, so the raw behaviour count will be large (hundreds, not 23). The ending classes below are the clusters the writers care about; the topic should define `endingClass` as a feature over the axes so `classes()` can be asked at either grain.

### Ending classes (state of the three lives at the end of week two)

Cross-life endings are marked **X**: one protagonist's choice is visible in another's state.

| # | Class | One sentence | Cross |
|---|---|---|---|
| E1 | **The complete file** | Vera filed; Ilona admitted; Rybar listed the route and Tomas, who had let the courier through in week one, holds the family in week two with a list in his hand; Marta is watched and short of breath; Jan printed once and went quiet. | **X** Vera → Tomas; Tomas → Marta |
| E2 | **The gap** | Vera burned; Berta's initials sat beside the gap and Berta reported it; Vera is watched and Ilona deferred; the courier came through, Ondra carries the line, and Jan has paper but, seeing the stairwell watched, has not printed. | — (Vera → Berta; the desk only) |
| E3 | **The carbon** | Ilona took the carbon for Jan; Jan printed Kastan's name; the file was traced to the Records Office and Vera queried; Kastan exposed; the regime paranoid, the gate tightened, and Tomas holds a family he would have let through a week earlier. | **X** Ilona → Vera; Jan → Vera; Jan → Tomas |
| E4 | **The seized parcel** | Tomas held the courier on night one; the border report corroborated 4471 and Vera, queried, filed or recovered; Marta is in hospital, which asked for papers; Jan has nothing to print; the regime is confident and the gate commended. | **X** Tomas → Vera; Tomas → Jan; Tomas → Marta |
| E5 | **The open gate** | Tomas let him through and confessed under inquiry; Jan printed and distributed; the regime paranoid; Kastan, paid or loyal, put Jan under observation; Vera, learning Ilona is in the circle, closed the household file on Jan's name. | **X** Tomas → Jan; Vera → Jan |
| E6 | **The mother's trade** | Vera reported Jan to keep Ilona clear; raid; Ilona, swept up in it, renounced; Ilona admitted; Vera unwatched; Marta supplied — the cleanest flat on Vrba Street. | **X** Vera → Jan; Ilona → Jan |
| E7 | **The daughter's statement** | Vera never resolved 4471 (`pending`); the review was held; Ilona renounced and gave the cellar; Jan raided; Vera unwatched and unchanged at the desk — which `no_one_unchanged` forbids unless the deferred review itself is read as Vera's turn; this class is the one the law must decide, and the writers' answer is that it is *not* a turn: E7 is admissible only with Vera's `warned` or `leaked`. | **X** Ilona → Jan |
| E8 | **Marta's breath** | Marta, at one breath, pleaded with Kastan and gave him Ilona's visits to the cellar; the route stayed open and she is supplied; Ilona watched and refused; Vera, who warned Marta and paid for it with the household flag, learns what the warning bought. | **X** Marta → Ilona/Vera |
| E9 | **The route burned** | Tomas, or Jan under arrest, named the courier; Ondra clear, Jan released; the route is gone, Marta cut off and failing; Vera's desk receives the name of the widow's son, the sender, from the hospital's papers and the call tape; the regime confident. | **X** Tomas/Jan → Marta → Vera |
| E0 | **Nothing moved** (must be *unreachable*) | 4471 pending, the press silent, the gate untested, the review deferred for want of anything to read. `no_one_unchanged` must forbid it, and `diagnose()` on it must name that law and no other. | diagnostic |

Coverage target for the topic: every axis value reachable; E1–E9 each reachable with at least one witness at horizon 12; E0 forbidden by exactly `no_one_unchanged`; "Vera burns and nobody at the office notices for a week" forbidden by `gap_is_noticed`; "Tomas lets the courier through and no one pays" forbidden by `costless_courage` (the Ondra line is the pay).

---

## 8. Tone, pacing, and the scene beats

### Tone
- **Procedural, interior, dry.** The sound of the stamp, the carbon's smudge, a log line in another man's handwriting. No villain speaks as a villain; Rybar is polite and never raises his voice.
- **Every cost is shown as a person in a room**, not as a number: Berta re-reading her own initials; Ondra turning the log towards himself; Ilona reading *deferred* on a card; Marta on the third-floor landing counting steps.
- **The state's attention is visible as paper arriving**: a list at the gate, a query slip on the desk, a review card. Pillar 2's phase change (`paranoid`) is shown as more paper, not more police.
- **Nobody is told what they did to the others.** The player sees the crossing in the next chapter, through the dossier; the characters do not. The irony is the player's alone.

### Pacing targets (horizon 12, two weeks)
- Week one (beats 1–6): the courier, the gate, the parcel, 4471; Vera's turn no earlier than beat 3; Tomas's turn by beat 4; Jan's paper (or not) by beat 5.
- Week two (beats 7–12): the inquiry, the leaflets, `paranoid`, the family, the review. Every reversal lives here. The review (beats 9–12) is the act's closing bell.
- No two protagonist turning points on consecutive beats: each needs a state beat or world move between them to be read (`crossing_read`).
- Target distribution per telling: 4 Vera beats, 4 Jan beats, 3 Tomas beats, 2–3 state/supporting beats, 2–3 world moves. Chapters are presented per protagonist in the game; the telling interleaves them.

### Scene beats that must be written (by action class, not order)

**Vera — the desk** (four to five)
1. *Reading* (V1): 4471 read to the end. The parcel was medicine. Marta on the landing.
2. *The pressure beat* (one of R1 `query-ledger`, R3 `hold-review`, B1's memo, or the `border_report` slip arriving): the state's paper on her desk.
3. *The turn* (V2 / V3 / V5): the stamp, the stove, or the pen. Three scenes, one chosen.
4. *The person* (V4 `recover` or V8 `take-blame`, or V6 `warn` at Marta's door at 23:10): the scene where the cost has a face.
5. *The other name* (V9 `report-jan`, reachable only with `ilona_in_circle`): the household file closes on Jan.

**Jan — the cellar** (four to five)
1. *The route* (J1 `receive-courier`, or its absence while Kastan watches the stairs): the paper and the medicine in the same bag.
2. *The press* (J2 `print-leaflets`): all night; Ilona feeding the sheets if she is there.
3. *The turn* (J3 `distribute` / J4 `expose-informer` / J5 `ask-carbon`): the landing, the name, or the question to the archivist's daughter.
4. *The person* (J6 `cut-ilona`): Jan tells her not to come back; she does not know why.
5. *The reversal* (J7 `recant` / J8 `give-name`): the statement, or the name — courier, Ilona, Vera — spoken to Rybar in a polite room.

**Tomas — the gate** (three to four)
1. *The turn* (T1 / T2, courier): night one, the parcel, the log in Ondra's hand. The act's earliest turning point.
2. *The pressure beat* (`inquiry_at_post` with R4's list, or O1 `cover-log` the night before): the captain reads the log.
3. *The person* (T3 `confess-gap` / T4 `name-route` / O2 `report-tomas`): Ondra and Tomas, one line, one name.
4. *The second test* (T1 / T2, family, under `border_tightened`): the same gate with a list in his hand and a record on his back.

**Supporting scenes required by the crossings** (written as insert scenes, not chapters): Berta initialling (B1/B2); Ilona at the review card; Marta on Kastan's doorstep (M2); Rybar's `list-route` as a telephone call heard from the gate.

---

## Contradictions check
- Against `prototypes/paper-walls-branches-concept/`: action names `read-file`, `file-report`, `burn-report`, `recover-report`, `warn`, `leak-file`, `print-leaflets`, `distribute`, `expose-informer`, `recant`, `inform`, `report-neighbour`, `raid`, `query-ledger` keep their prototype meaning; `turn-informer`, `inform-on-archivist`, `order-fire`, `obey-order`, `stand-down`, `crowd-gathers`, `regime-wavers`, `regime-panics` are deferred to act two and not contradicted. `kastan-rewarded` becomes `rewarded(kastan)`; `household-complete`, `discrepancy`, `under-observation` keep their names. The prototype's `warn` cost (attention only) is replaced by `household_flagged`, per decision 3.
- Against the pillars: no action is reflexive (5); no morality meter (axes read state, not virtue); no history (the regime's phases are fluents, not dates); no sandbox (every action has preconditions a licence or a flag must open).
- Against the game concept's cast: all named characters present; Ondra and the courier (Marek) added as the border's two persons; no real country, emblem, script or name.
