# Dossier State Model

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: Designed
> **Author**: Mustafa Faisal (user) + systems-designer, technical-director, narrative-director (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 1 Every fact is a weapon · 2 The state is a character · 4 Consequences cross lives
> **Gates**: CD-GDD-ALIGN 2026-11-03 CONCERNS (6), all applied: scalars never project; red as four bands; overprint only on another protagonist's change after the sign's lag; broken count barred from act-one rows; released files in the Files form only; `calendar.*` writes by rules only. ND ruling 2026-11-03 applied (ending rows, no press flag, Tomas defiance, signs, settlement placement). `/design-review` pending.

## Summary

The Dossier State Model is the state's file on every character: what the regime knows, believes and has decided about each of them, plus how steady the regime itself is. It is the only way one protagonist's choice reaches another protagonist's chapter, and the only source from which the game decides how closely a character is watched and how the story ends. It exists because Paper Walls is a game about consequences carried on paper, and this is the paper.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `None` (read by 11 systems; written only through its effect-record API)

## Overview

Every character in Paper Walls, protagonist or not, has a record held by the state: a set of yes/no facts (watched, flagged, cleared, arrested), a few numbers (how much attention the regime pays to them) and a standing (open, closed, released). One record, the city's, holds the regime's own stability and unrest. Nothing in the game changes these records directly. Instead, when the player files a report, burns one, warns a neighbour, confesses, or lets a courier through, that act produces an **effect record**: a small declarative note saying which record, which field, what change, and who caused it. The model applies these at scene boundaries, in one batch, in a fixed order, and answers with **change records** saying what actually changed. Other systems only ever read: the rules that fire reactive events, the function that decides whether the regime is confident, paranoid, panicking or collapsing, the stamp-red overlay that shows a character is being watched, the audio mix, and the Paper UI. Each protagonist is shown a different projection of the same records: Vera the archivist reads the files themselves; Jan the dissident sees only the signs (a car outside, a phone that goes dead); Tomas the conscript receives orders. The player never sees a meter. The model exists so that a choice made as one protagonist can land, weeks later and unannounced, in another's life, and so that the same logic that runs the game can run headless to prove every ending is reachable.

## Player Fantasy

**Framing: your handwriting in someone else's life.** The emotion the dossier serves is recognition that turns into guilt. The player is not meant to feel this system as a system at all. They meet it indirectly, through what it enables and what it reveals.

The anchor moment: in Jan's chapter a phone goes dead mid-sentence. Nothing explains it. Two chapters earlier, playing Vera, the player entered the note that named this flat. The game never draws the line, there is no "because you", no popup, no highlighted cause. The file is the only witness, and only the player has seen both sides of it. The language of the system, wherever it surfaces, is clerical and passive: *a note was entered*, *the line was disconnected*. The state never says who did it, so the player supplies the "I" themselves.

The two other feelings the dossier produces are subordinate to that one. **Complicity at the moment of writing** (the carbon forming under Vera's sheet, the stamp coming down red; the Papers, Please moment of stamping what the rule requires) is the cause side of the same recognition. **Being noticed** (the same man at the tram stop twice, stamp red seeping into the edges of Jan's street; the regime growing louder and clumsier as it moves from confident to panicking) is the effect side, carried by the signs projection and the attention aggregate. Both are designed in so that the first can happen; neither is the fantasy on its own.

Pillars served, in the concept's own words: Pillar 4, "the most important result of a choice lands in another protagonist's chapter, through dossier states, never bespoke branch trees"; Pillar 1, "anything learned can be written into, leaked from, or used against someone's dossier"; Pillar 3, "the act can succeed; the actor is never absolved"; Pillar 2, "whether it fires and at whom is read from the dossier". Reference moment: in Orwell, a fragment you uploaded comes back days later as an arrest in the news feed.

Design consequences for the sections below: the model must keep provenance (who caused a change, in which chapter) so the payoff can be staged without being explained; the signs projection must be able to express a change without naming its cause; and nothing in the model may be rendered as a number to the player.

## Detailed Design

### Core Rules

**0. Vocabulary.** A *record* is the state's file on one subject. A *field* is one named flag or scalar on a record. A *beat* is one scene boundary (the Calendar's unit; the brief's "horizon 12" is twelve beats). A *chapter* is one protagonist's playable run inside an act. A *writer* is one of the systems allowed to produce effect records.

**1. What is dossier state and what is not — the sorting rule.** A fluent is dossier state if and only if an organ of the state (the Records Section, the security officer, the border post, the hospital, an informer) has it on paper. Everything else is one of three other things, and the act-one fluents sort as follows.

| Home | Rule | Act-one fluents |
|---|---|---|
| **Dossier** (this model, persisted, budgeted, the only player-written thing that crosses chapters; `calendar.*` crosses only through rules that read it, Core Rule 1a) | On paper somewhere in the state | `vera.{discrepancy, carbon_missing, household_complete, household_flagged, took_blame, reported_jan, under_observation, attention}` · `marta.{report_4471 (enum: none/received/filed), under_observation, hospitalised, treated, pleaded, attention}` · `jan.{leaflets_distributed, source_traced, press_raided, arrested, recanted, gave_courier, gave_ilona, gave_vera, under_observation, attention}` · `tomas.{on_report, named_route, confessed, under_observation, attention}` · `ilona.{known_in_circle (the informer's note; PDDL knows_ilona), review_pending, review_sat, review_deferred, review_refused, admitted, renounced, under_observation, attention}` · `berta.{implicated, reported, cleared, liable, under_observation, attention}` · `kastan.{rewarded, exposed, attention}` · `ondra.{liable, reported_tomas, attention}` · `courier.{attention}` · unit `border.{courier_through, courier_detained, courier_listed, log_gap, log_covered, inquiry, border_tightened, family_through, family_detained, route_burned, unit_commended, line_held}` · unit `office.{border_report, ledger_reconciled}` · global `regime.{stability, unrest, paranoid, phase_reached}` |
| **Fact System** (player's held facts; never here) | Something a protagonist knows | `knows_parcel(vera)`, `knows_ilona_circle(vera)`, `knows_gap(berta)` is not a held fact but is *derived*: `knows_gap ≡ vera.discrepancy ∨ vera.carbon_missing` (V3 and V7 each set one of these alongside it) |
| **Calendar / Scene Flow** (world schedule and scene state) | A scheduled or in-progress world event, or a clock | events `ledger_due`, `review_called`, `needs_paper`, `courier_at_gate`, `family_at_gate` (the Calendar's windows); clock `breath(marta)` (0–4, −1 per 3 beats while unsupplied, +3 when `border.courier_through` becomes true; at 0 the Calendar fires `marta_collapses`, whose effects — `marta.hospitalised`, `marta.under_observation`, `vera.attention +1` — enter the dossier); `route_paused(marta)` is a Calendar window suspension (see §1a) |
| **Chapter sheet** (private character state; see §2) | True in the world but on no paper; dies with the chapter unless an effect writes its paper | `burned`, `doctored`, `warned(marta)`, `has_medicine`, `son_safe`, `has_paper`, `has_file`, `leaflets_printed`, `asked_carbon`, `courier_sheltered`, `in_circle(ilona)`, `at_risk(ilona)`, `took_carbon(ilona)`, `cut(ilona)` |

*How each private fact crosses, when it must (its paper):* `burned` → `vera.discrepancy`; `doctored` → `office.ledger_reconciled ∧ ¬marta.filed`; `warned` → `vera.household_flagged` (Kastan's building book); `has_file(jan)` → `vera.carbon_missing` (both V7 and I2 set the pair); `has_paper(jan)` → `border.courier_through`; `has_medicine` → `border.courier_through ∧ ¬border.route_burned`; `courier_sheltered` → K2's report (`vera.under_observation`); `in_circle(ilona)` → `ilona.known_in_circle` (Kastan via M2, or the raid) or the assumption mechanism (§8); `took_carbon` → `vera.carbon_missing` with tag `taken_by:ilona`; `leaflets_printed` → nothing until distributed or raided.

*What the discipline loses, stated so the writers decide with eyes open:* the only act-one axis value that paper cannot tell apart is `jan_press = printed` vs `silent` (E2's "has paper, has not printed"). Narrative-director ruling: the distinction is dropped and no `jan.press_heard` flag is added. The state cannot tell a quiet press from an empty one, and E2 depends on that (the stairwell sign stopped him; nobody heard him). The `press` axis collapses to `silent / distributed / raided / named`; the epilogue lines for E1 and E2 become "no leaflet reached the street", and the printed-once detail is told in Jan's own closing scene from his chapter sheet, before the wipe. Everything else in the twelve axes is readable off paper.

*Rationale:* this is the literal reading of "holds only what the state knows," and it is the reading that makes the state a character (Pillar 2): the file can be wrong, late, or blank, and the ending is read off the file the way the state would read it. *Alternative rejected:* storing every PDDL fluent in the dossier. It is the god object the risk register names, it makes "the state knows" meaningless, and the flag budget stops meaning anything because private bookkeeping consumes it.

**1a. *(ADR-1 to confirm)* World facts that gate Calendar events.** `route_paused` (Marta's M1 suspends the courier window) and the event windows are Calendar state, not dossier state. The Calendar receives them through the *same effect-record format* with target namespace `calendar.*`, routed by Scene Flow; this model applies only `dossier.*` and `sheet.*` targets. `calendar.*` effects are produced by the `rules` writer only, from conditions that read dossier fields, so every consequence that crosses chapters still starts from something on paper. *Rationale:* one write format everywhere keeps Filing & Decision data-driven and the simulator able to see every write; the Calendar already crosses chapters (the date does), so this does not open a second cross-life channel so much as name the one that exists. *Alternative rejected:* record the pause as paper (`courier.route_quiet`, Kastan noting "no visitor at flat 3"). It is thematically pretty but forces an informer into every pause; the writers would resent it. Per-chapter cross-life read budget counts `calendar.*` reads too (Formulas §7).

**2. *(ADR-1 to confirm)* Two stores behind one read API.** The model hosts the **dossier** (records; persisted for the game; the sole cross-chapter channel) and the **chapter sheet** (one flat set of private flags and scalars declared per chapter; serialised inside a mid-chapter save; wiped at chapter close with no migration path except an effect into the dossier). Reads of both go through `read(target, field)`; effects to both go through the same effect record; only the dossier takes `cross_life` fields; nothing on the sheet survives `chapter_close`. *Rationale:* NPC moves are reactive rules (K2 reads `courier_sheltered`, B1 reads `knows_gap`, M2 reads `in_circle`), rules read only through this model, and "the state can only learn private state through an effect" becomes mechanically true: the wipe at chapter close is the enforcement. *Alternative rejected:* Scene Flow owns the sheet and rules receive it as a second read context. It works, but it splits the read budget tool across two owners and gives the headless simulator a second data source to mock.

**3. Schema of a dossier record** (plain data; one schema file `assets/data/dossier/schema.json` declares every record id, kind, field, type, range, default, writers, flags, so nothing below is hardcoded):

```yaml
record:
  id: vera                        # string; unique; declared in schema
  kind: person | unit | regime    # unit = an organ's own log (border post, records office)
  custodian: records_office | security | post | hospital | none   # which organ holds the folder; drives the files view (§7)
  status: absent | opened | active | closed | archived | destroyed | released   # lifecycle (States and Transitions)
  opened_on: int | null           # calendar day of first effect
  flags:                          # every declared flag, tri-state
    under_observation: true | false | unknown
    ...
  scalars:                        # every declared scalar, int, declared [lo, hi] and default
    attention: 0
  tags: [ { tag: "initialled_by:berta", source: "<source tag>", day: 3 } ]   # ordered set, record-level annotations
  last_source: { field: "<source tag>" }   # last writer per field (provenance; the change log is the history)
```

Schema per field: `name, type (flag|scalar|enum), range or enum values, default (unknown for flags, declared int for scalars), cross_life (bool), key (bool — may appear in an ending axis), writers (allow-list), ratchet (bool — `set false`/`clear` only from rules|migrate), projections (files|signs|orders, with form id)`. Fixed schema: an effect naming an undeclared record or field is rejected at authoring (build fails) and at runtime (no write, error log). *Rationale for tri-state flags:* the state's file has blanks, and "household file incomplete" is not "household file complete = false"; the unknowns mechanism (§8) needs the third value; and "a flag read before it is written" gets a defined answer. *Alternative rejected:* plain booleans defaulting to false — closed-world, simpler, and the PDDL uses it, but it collapses "not on file" into "on file as no."

**4. The effect record** — the only mutation API:

```yaml
effect:
  target: vera | border | regime | sheet       # record id, or `sheet` for the chapter sheet
  field: under_observation                     # declared field; omitted only for op tag at record level
  op: set | clear | add | max | min | tag
  value: true | false | int | "tag[:value]"
  source: "filing:a1_vera/s3:burn_report"      # writer:chapter_id/scene_id:action_id — mandatory, parsed, validated
```

Op semantics (all deterministic, all clamped to the field's declared range):

| op | flag | scalar | tags |
|---|---|---|---|
| `set v` | flag := v (true/false) | scalar := clamp(v); writers rules/migrate/sim only | — |
| `clear` | flag := unknown; ratchet fields rules/migrate only | rejected except migrate (use `set 0`) | removes the named tag |
| `add k` | rejected | scalar := clamp(scalar + k) | — |
| `max v` | rejected | scalar := clamp(max(scalar, v)) — the ratchet op (phase_reached) | — |
| `min v` | rejected | scalar := clamp(min(scalar, v)) — the cap op | — |
| `tag t` | — | — | appends `{t, source, day}`; idempotent on same t |

Writers (fixed enum): `filing` (Filing & Decision), `dialogue` (Dialogue & Interrogation), `rules` (Reactive Event Rules — includes drift and world moves), `chapter` (Chapter & Story Structure: open, close, archive, release), `assume` (the unknowns, §8), `migrate` (Save/Load), `sim` (story simulator and tests). Batch precedence for same-field conflicts in one boundary: `rules > chapter > filing > dialogue > assume`; within one writer, list order; see Edge Cases for the exact resolution. *Rationale for the small op set:* `set/clear` cover every flag transition, `add` is every authored `attention+2`, `max/min` give ratchets and caps without a special field type, `tag` carries provenance the epilogues need ("Berta's initials beside the gap") without adding flags. *Alternative rejected:* a `toggle` op and a `copy` op (from one field to another); both are nondeterministic in a batch or create hidden reads outside the budget.

**4a. API shape and the boundary.** The model exposes exactly these calls and nothing else that mutates: `begin_boundary(scene_id, day)` (the calendar day Scene Flow reads from the Calendar's `date_for`; the dossier cannot import the Calendar, so the day is handed in; the `beat` a boundary's change records carry is the post-increment value, `boundary_counter + 1` during the bracket; `chapter_open` of the first chapter in the act's play order resets `boundary_counter` to 0; amendments applied for GDD 7), `apply(batch) → [change]`, `end_boundary() → [change]`, `chapter_open(chapter_id, reads, writes, assumes)`, `chapter_close()`, `deserialize(data)`. The field store is private and typed; there is no setter, and an effect record cannot be built without a parseable `source`. Writers hold a `DossierWriter` facade that accepts batches, never the model. A boundary is **atomic**: Scene Flow calls `apply` once with the decision batch (writers `filing`, `dialogue`), then once per rules cascade step with the rules batch (writer `rules`; the cascade cap is Rules' own), then `end_boundary`, which increments the **boundary counter** and returns the boundary's change records in application order. A rules batch may target a field the decision batch already wrote this boundary; the precedence rule in §4 and Edge Case 1 decide the outcome, and one change record per field per boundary is emitted with `before` the pre-boundary value. Reads between `begin_boundary` and `end_boundary` see the pre-boundary state plus the batches already applied, in order, which is what the cascade needs. *Rationale:* Scene Flow's step order (decision → effects → rules → phase and attention → reveal) is only well defined if effects land once, in one place, in one order; the counter is the clock every memo and every save keys on.

**5. The change record** — emitted once per effect that changed something; a no-op effect (set true on true) emits nothing; a `tag` always emits:

```yaml
change:
  id: 418                     # monotonic per save; survives serialize
  day: 9                      # calendar day: the scene's authored day for writers filing/dialogue/assume; for writer rules (clocks, world moves, drift) the Calendar's high-water day `day_high`, the latest day any played scene has reached, so a file dates what the state did by receipt and never earlier than a page already read (GDD 7 Core Rule 1; amendment applied)
  beat: 7                     # scene-boundary index within the act
  boundary: a1_vera/s3        # the scene whose boundary applied the batch
  target: vera
  field: discrepancy
  op: set
  before: unknown
  after: true
  source: "filing:a1_vera/s3:burn_report"
  source_protagonist: vera    # parsed from the chapter id (a chapter id with no protagonist, the act-close pseudo-chapter `<act>_close` of GDD 7, parses to null; amendment applied for GDD 7); null for rules/chapter/migrate
  cross_life: true            # schema.cross_life of the field
  status_change: null         # or { before: opened, after: active } when the write moved the record's lifecycle
  contradicts: null           # the source tag of an assumption this write overturned (§8)
  projections: [files, signs] # which views carry this field (§7) — Paper UI decides seen/unseen, when and where to stamp
```

The change log is kept in full for the current act and compacted to a per-act digest (one line per field: final value, first source, last source) at `archive`. Scene Flow hands the boundary's batch of change records to Paper UI for the reveal step; this model keeps no "seen" state.

**6. Ownership and write rules.** The Calendar's phase and attention functions read `regime.{stability, unrest, paranoid, phase_reached}` and `x.{attention, under_observation}` through an injected `aggregates()` accessor that is **not** logged against any chapter's read budget (GDD 7 Core Rule 7; amendment applied): content that wants the phase pays one virtual read `regime.phase` through `phase_at_least` and nothing else.
1. Nothing writes a field except an effect record applied by this model; there is no setter.
2. Every effect carries a parseable `source`; an unparseable source is rejected (authoring: build fails; runtime: logged, not applied).
3. A chapter declares, in its content data, `reads: []`, `writes: []` (field ids), and `assumes: []`. Filing and Dialogue effects fired inside the chapter may write only fields in `writes`. Rules fired at that chapter's boundaries may write any dossier field; their writes count toward the chapter's write budget all the same (Formulas §6), so a chapter that provokes the state pays for it.
4. `regime.*` and every `status` are written by `rules`, `chapter`, `migrate` only. `attention` accepts `add/max/min` from any writer and `set` from `rules/migrate` only (nobody zeroes the state's eye by authoring a decision).
5. Cross-life fields (`schema.cross_life: true`) may be written from any chapter; a non-cross-life field may be written only by chapters of the protagonist named in `schema.owner` (so Jan's chapter cannot quietly set `vera.took_blame`).
6. Reads are free of side effects, never emit change records, and are logged per chapter as a set of distinct field ids (the read budget's input).
7. A read of an absent record or an unwritten field returns `unknown` (flag) or the schema default (scalar). Rule conditions use three predicates — `is_true`, `is_false`, `is_unknown` — and bare `not x` means `¬is_true(x)` (closed-world, matching the PDDL).

**7. The three views as projection rules.** A view is a pure function `project(view, protagonist, dossier) → [line]`, memoised once per view per boundary counter and invalidated by `end_boundary`, holding no state of its own; Paper UI renders lines, owns seen/unseen and the changed marker. The schema's `projections` attribute per field declares which views carry it and in what form; the rule for each view is:

| View | Who | What projects | Form | Rule |
|---|---|---|---|---|
| **Files** (archivist) | Vera | Every field of every record whose `custodian = records_office` — `marta`, `ilona` (the Halm household file), `berta`, `office`, and `jan` once `office.border_report` or `vera.reported_jan` puts his name in her section | A document line per field: `true` → the entry text; `false` → the struck entry; `unknown` → a blank (an *incomplete* file). Tags render as marginalia ("initialled B.L."). **Scalars never project**: a single form line appears when a threshold is crossed (`attention requested` at `ATTN_LOOK`, `observation ordered` at `ATTN_WATCHED`), never a count | Exact and complete for what the office holds; **her own record (`custodian = security`) is never a file** — she meets the state's attention on herself only as signs, like everyone |
| **Signs** (dissident) | Jan | Fields declared with a sign form, each with a `threshold` and a `lag` (beats): `jan.attention ≥ 2` → the car in the street; `jan.under_observation` → the stairwell watched; `border.courier_detained` and `border.route_burned` → the paper did not come (one shared string); `ilona.under_observation` → Ilona does not come to the cellar (the review letter is Calendar, not surveillance); `marta.hospitalised` → the ambulance at flat 3 (lag 0; a Tomas-to-Jan payoff); **no sign** for `kastan.rewarded` (an informer paid is invisible), `vera.reported_jan` and `jan.source_traced` | A sign string id from Narrative Content, never a field name or value | Lossy and late by design: a sign appears `lag` beats after the change and only if the field is in the chapter's `reads`; two fields may share one sign, so Jan cannot tell which. A cross-life overprint rides the sign object, fires only when `source_protagonist` is another protagonist, and keeps the sign's `lag`, so the ink says *someone's hand*, never which field moved |
| **Orders** (conscript) | Tomas | `border.*` unit fields plus `tomas.on_report`, `ondra.liable`, `courier.*` as a list entry | An order line: `courier_listed` → a name on the list; `border_tightened` → standing order; `inquiry` → the captain's visit; `log_gap` → nothing (he knows; the log does not say) | Exact and immediate for his post, blind to every person record: a list has a name, never a reason. `unknown` never renders (no order is issued for a blank) |

*Rationale:* the three forms are the three ways a state reaches a person — the file you keep, the signs you read, the order you receive — and the projection table is the one place the writers can see which flag will be felt by whom. *Alternative rejected:* one generic "visible fields per protagonist" list; it loses the lag and lossiness that make signs tense (Pillar 5) and makes orders explain themselves.

**8. The unknowns (assumption-licensed branches).** A chapter may list `assumes: [{field, value}]` for fields that are `unknown` at chapter open (act one: `ilona.known_in_circle`, `border.courier_listed` for "the route already watched", `kastan.rewarded` for "Kastan loyal", `berta.reported` for "Berta has reported for years", and the Rybar-vindictive licence as `regime` tag `rybar_vindictive`). At chapter open the `chapter` writer applies `set` with writer `assume`; the field then reads as its assumed value everywhere. Any later non-`assume` write to that field overrides it unconditionally and emits a change record with `contradicts: <assume source>`, which rules may read (`was_assumed(field)`) to let the state be wrong out loud. Assumptions per act are capped (`ASSUME_BUDGET`, Formulas §9). Each assumption declares in content where it settles if never contradicted: `border.courier_listed` and the `rybar_vindictive` tag settle as the field itself; `kastan.rewarded`, `berta.reported` and `ilona.known_in_circle` settle as record tags (`kastan: loyal`, `berta: long_informer`, `ilona: in_circle_before_the_act`), never as the act's flags, so a payment, a report or a knowledge the telling never produced is not put on paper (Edge Case 11).

**9. The flag budget — how it is enforced.** Four counts per chapter (Formulas §6, §7): distinct fields read, distinct fields written, cross-life fields read, cross-life fields written. *Authoring:* the content validator (run by the story simulator over the chapter's scenes, decisions, dialogue and the rules that can fire inside it) computes the four counts from actual references, checks them against the chapter's declared `reads`/`writes` (a reference not declared is an error; a declaration never referenced is a warning) and against the budgets; any excess fails the build and names the offending fields. *Runtime:* never blocks the player. An undeclared read returns `unknown`/default and logs an error; an undeclared write is rejected and logged; an over-budget count is logged with the field list. Debug builds assert on all three. *Rationale:* budgets are a writers' discipline, so they bite at authoring; at runtime the only honest options are "serve a safe default" or "crash," and the first is right for a story game.

**10. Persistence contract.** `serialize()` returns plain data: `{schema_version, boundary_counter, chapter_id, records, sheet, change_log, next_change_id}`; `deserialize(data)` accepts only the current `SCHEMA_VERSION` and only at a scene boundary (Edge Case 13). Projection memos are never saved; they are rebuilt on the first read after load. Random state, save points and the registry of stateful systems belong to Save/Load; this model consumes no randomness (every op is deterministic), so the saved seed is for other systems. Save files are data, never engine resources: nothing in a save path is loaded as a script-bearing resource (ADR-4).

**11. Headless rule.** The model, the projections and the validator import nothing from the scene tree, from `tools/` or from `tests/`; the story simulator (under `tools/`) and the unit tests (under `tests/unit/dossier/`) import the model, never the reverse. A CI path check enforces the direction.

### States and Transitions

A record's lifecycle. `status` is a schema field written by effects (`set`), writers `rules | chapter | migrate`, except the automatic `absent → opened → active` moves, which any applied effect triggers.

| State | Entered on | Accepts | Reads return | Projects | Leaves to |
|---|---|---|---|---|---|
| **absent** | Record declared in schema, never touched | Any effect (auto-opens) | `unknown` / defaults | Nothing | `opened` on first `tag`; `active` on first `set/add/max/min` |
| **opened** | First effect was a `tag` or `set unknown`; the state has a folder with a name and nothing in it | All ops | Values | Files: a blank folder. Signs/orders: nothing | `active` on first substantive write |
| **active** | First flag set true/false or scalar changed from default | All ops | Values | All views per §7 | `closed` (rules: a case concluded — `admitted`, `cleared`, `confessed`, `recanted`, or tag `deceased`); `archived` (chapter: act close) |
| **closed** | The state is done with the subject for now | `tag`; any `set/add/max/min` **reopens** (→ `active`, change record `status_change`, tag `reopened:<day>`) | Values | Files: the folder with a closed stamp; signs: nothing new; orders: as before | `active` (reopen); `archived`; `destroyed` |
| **archived** | Act close (`chapter` writer, all records at once) | `tag` only; `migrate` may write; everything else rejected with error | Values (frozen) | As at close, read-only | `released` (regime falls); `destroyed` (collapsing phase, rules) |
| **destroyed** | Rules, only in phase `collapsing`: the paper is burned | Nothing (rejected, logged) | `unknown` / defaults, with `record.status = destroyed` readable | Files: ash (a line); signs/orders: nothing | Terminal |
| **released** | Chapter structure at regime fall: the files are opened to their subjects | `tag` only | Values | Every released record projects to every protagonist **in the Files form only** (everyone may read everyone's file): scalars suppressed as in Core Rule 7, provenance as marginalia initials, unknowns left blank. The reckoning is a file, not an audit | Terminal |

The **regime record** is global, kind `regime`, status always `active`: `stability` (0–10, opening 9), `unrest` (0–12, opening 1), `paranoid` (flag), `phase_reached` (0–3 scalar, `max` only — the ratchet). Phase itself is not stored; the Calendar's pure function reads these four (Formulas §2). Lifecycle of the regime is the phase sequence confident → paranoid → panicking → collapsing, never backward (the ratchet), ending in `released` for every record when Chapter & Story Structure declares the fall.

### Interactions with Other Systems

| System | Data in (to this model) | Data out (from this model) | Interface owner |
|---|---|---|---|
| **Filing & Decision** | Effect-record batches per decision (writer `filing`); the chapter's declared `writes` | Change records (for the reveal); reads for option gating (`is_true/is_false/is_unknown`) | This model owns the effect and change formats; Filing owns decision data and its content check that every option writes at least one cost effect |
| **Reactive Event Rules & Story Simulator** | Effect batches from fired rules, drift and world moves (writer `rules`); the simulator's `sim` writes in headless runs | Reads at scene boundaries (dossier + chapter sheet + change records of the current boundary, including `contradicts`); the schema as the simulator's fluent set; the four budget counts per chapter | This model owns read semantics and the schema; Rules owns rule format, cascade cap, tie-break |
| **Dialogue & Interrogation** | Effect batches (writer `dialogue`), e.g. `jan.gave_ilona`, `tomas.confessed` | Reads for line gating | This model (format); Dialogue (transcript logic) |
| **Calendar, Regime Phase & Attention** | Nothing written here by the Calendar. Calendar events (`marta_collapses`, `review_convened`) are fired as rules | Two pure functions read: `regime.{stability, unrest, paranoid, phase_reached}` → phase; `x.{attention, under_observation}` + phase → effective attention and stamp intensity (Formulas §2–§3). `calendar.*` effects pass through Scene Flow, not here (ADR-1 to confirm) | This model owns the aggregates and the threshold constants; Calendar owns the functions and clocks |
| **Scene Flow** | The boundary sequence: `begin_boundary(scene_id, day)` → `apply(batch)` ×N → `end_boundary()` returning the ordered change records; `chapter_open(chapter_id, declared sets, assumes)`, `chapter_close()` (wipes the sheet) | Change records for the reveal step; status changes | This model owns `apply/end_boundary`; Scene Flow owns the order of the sequence |
| **Paper UI** | Nothing | `project(view, protagonist)` lines; change records with `projections`; never raw field access outside projections | This model owns projection rules (§7); Paper UI owns rendering, seen/unseen, the changed marker, stamping |
| **Save/Load** | `deserialize(data)` at a scene boundary; migration output (writer `migrate`) | `serialize() → {schema_version, records, sheet, change_log, next_change_id}`; `SCHEMA_VERSION` constant; `defaults()` | This model owns the payload shape and version; Save/Load owns the registry, migration, save points, RNG state |
| **Chapter & Story Structure** | `chapter_open/close`, `assume` writes, `archive`, `release` (writer `chapter`); the ending table data | The ending aggregates: `phase`, `broken_count`, the key axes (Formulas §4–§5); `select_ending(table)` | This model owns the selector formula and axis derivations; Chapter structure owns the table content, death and the story continuing |
| **Overlay & Surveillance Rendering** | Nothing | Nothing direct — it reads the Calendar's attention/phase outputs, never raw fields (index rule kept) | Calendar |
| **Audio** | Nothing | Nothing direct — phase and attention via the Calendar; events via Rules | Calendar / Rules |
| **Investigation & Fact** | Nothing (held facts are not dossier state) | Reads for unlock conditions (`is_true(field)`), counted in the chapter's read budget; the simulator's acceptance criterion "every authored fact has at least one dossier use" is checked by joining Fact data against this schema's field list | This model (read API); Fact system (held facts, the board) |

---

## Formulas

Conventions: `[p]` is the Iverson bracket (1 if `p`, else 0). `clamp(x, lo, hi) = min(hi, max(lo, x))`. All scalars are integers. Act-one calibration values come from the brief's numeric pressures; every constant is a tuning knob (Section G) and a data-file value, never a literal in code.

### 1. Scalar effect application

The scalar application formula is defined as: `v' = clamp( min( max( set ?? v + Σ add_i , max_j ), min_k ), lo, hi )` — within one boundary batch, for one scalar: the last `set` (if any) replaces `v`; all `add`s are summed onto it; every `max` is applied; every `min` is applied last; the result is clamped to the field's declared range.

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `v` | int | `[lo, hi]` | calculated | Value before the batch |
| `set` | int or none | `[lo, hi]` | data file (effect) | Last `set` in the batch, by precedence then list order; none if absent |
| `add_i` | int | `[-hi, hi]` | data file (effects) | Each `add` value in the batch |
| `max_j`, `min_k` | int | `[lo, hi]` | data file (effects) | Each `max` / `min` value |
| `lo, hi` | int | schema | data file (schema) | Declared range (attention 0–6, stability 0–10, unrest 0–12, phase_reached 0–3) |
| `v'` | int | `[lo, hi]` | calculated | Value after the batch |

Output range: clamped to `[lo, hi]`; the minimum is `lo` (any batch summing below it), the maximum `hi`. Order-independent for `add`s, so two chapters' effects commute. Example: `vera.attention = 2`; batch `{add 1 (V6 warn), add 2 (K2 report), min 4 (an act-one cap rule)}` → `2 + 3 = 5`, `min(5, 4) = 4`, clamp → **4**: one change record `before 2, after 4`.

### 2. Regime stability and phase

The regime stability update is defined as: `stability_b = clamp( stability_0 − Σ hits + Σ relief − ⌊ beats_paranoid_b / DRIFT_PERIOD_STABILITY ⌋ , 0, STABILITY_MAX )` — the stored scalar, mutated only by `add` effects (hits and relief) and by the drift rule, which issues `add −1` every `DRIFT_PERIOD_STABILITY` beats while `regime.paranoid`.

The regime phase (the Calendar's pure function; defined here because it reads only this model's aggregates) is defined as:
`phase = max( phase_reached, band(stability, unrest) )` where
`band = 3 if stability ≤ T_COLLAPSE ∧ unrest ≥ U_COLLAPSE; 2 if stability ≤ T_PANIC ∧ unrest ≥ U_CROWD; 1 if stability ≤ T_PARANOID ∨ paranoid; 0 otherwise`
and a boundary rule writes `max regime.phase_reached = phase` so the phase never falls.

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `stability_0` | int | 0–10 | data file (act opening; act one 9) | Opening stability |
| `hits`, `relief` | int | 0–3 each | data file (effects: J3 −1, J4 −1, regime_paranoid −1; relief authored in acts two–three) | Authored `add` effects on `regime.stability` |
| `beats_paranoid_b` | int | 0–36 | calculated (Rules' drift anchor, GDD 6 Core Rule 8) | Beats elapsed since `paranoid` became true |
| `DRIFT_PERIOD_STABILITY` | int | 2–6 | constant (3) | Beats per drift point while paranoid |
| `STABILITY_MAX` | int | 10 | constant | Scalar cap |
| `unrest` | int | 0–12 | calculated (stored scalar; effects J2 +1, J3 +2, raid +2, detain-family +1; drift +1 per 2 beats while `leaflets_distributed`) | How loud the street is |
| `paranoid` | tri-state | — | calculated (rule `regime_paranoid`, licensed by `leaflets_distributed ∨ discrepancy ∨ border_report ∨ exposed`) | The state has named a phase |
| `T_PARANOID`, `T_PANIC`, `T_COLLAPSE` | int | see G | constants (7, 5, 2) | Stability ceilings for bands 1, 2, 3 |
| `U_CROWD`, `U_COLLAPSE` | int | see G | constants (6, 9) | Unrest floors for bands 2, 3 (law `no_panic_before_crowd`: no panic without a street) |
| `phase_reached` | int | 0–3 | calculated (ratchet scalar, `max` op) | Highest phase so far |
| `phase` | int | 0–3 | calculated | 0 confident · 1 paranoid · 2 panicking · 3 collapsing |

Output range: `stability` clamped 0–10; `phase` bounded 0–3, monotone non-decreasing over a playthrough. Minimum phase 0 at act-one opening (9, 1, unknown, 0); maximum 3 needs `stability ≤ 2 ∧ unrest ≥ 9` or a ratchet already at 3. Act one is required to stop at 1 (GDD 7's acceptance `first_beat(2) = ∅`); the by-construction argument (authored hits at most 3, 9 → 6 ≥ T_PANIC+1, unrest near 5 < U_CROWD) omits the unrest and stability drifts over the act-close beats, under which the band can reach 2 at beat 13 (GDD 7 Open Questions; fix by tuning, never by freezing the closing bell; amendment applied for GDD 7), matching the brief's "act one is confident → paranoid." Example: after J3 (−1), J4 (−1), `regime_paranoid` (−1) and 4 beats paranoid: `9 − 3 + 0 − ⌊4/3⌋ = 5`; `unrest = 1 + 1 + 2 + 1 + ⌊4/2⌋ = 7`; band: `5 ≤ T_PANIC ∧ 7 ≥ U_CROWD` → 2 — which the act-one horizon prevents only because the drift needs beats the act does not have; the writers should see that E3/E5 sit one beat from panicking and either accept it or raise `T_PANIC` to 4 (G).

### 3. Per-character attention

The effective attention formula is defined as: `A_eff(x) = clamp( attention(x) + OBS_BONUS · [under_observation(x)] + PHASE_BONUS · [phase ≥ 2] , 0, ATTENTION_CAP )` and the stamp-red reach handed to the Calendar is a step, never a float: `red_band(x) = 0 if A_eff = 0; 1 if A_eff < ATTN_LOOK; 2 if A_eff ≤ ATTN_WATCHED; 3 otherwise` (none, margin, prop, light, matching art bible Principle A's steps so tension reads off the frame without a meter).

What raises `attention(x)`: authored `add` effects (the brief's `+1`/`+2`; never the only cost of a turning-point courage beat, law `cost_is_a_person`); the drift rule `add +1` every `DRIFT_PERIOD_ATTENTION` beats while the field's declared drift condition holds (act one: `vera` while `discrepancy`); the `regime_paranoid` rule's `+1` to everyone with `attention ≥ 1`. What lowers it: authored `add −k` (recant −2, Marta's plea −1 on herself); the decay rule `add −1` every `DECAY_PERIOD_ATTENTION` beats while `¬under_observation ∧ phase = 0 ∧ no raise this period` — **off in act one** (`DECAY_PERIOD_ATTENTION = 0`), because the brief's act has no decay and twelve beats are too few for it to read. Thresholds: `attention ≥ ATTN_LOOK` licenses the state to look (R1 query); `A_eff ≥ ATTN_WATCHED` is "under observation in all but name" and the sign table treats it as such.

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `attention(x)` | int | 0–6 | calculated (stored scalar) | The visible weight of the state's eye on `x` |
| `under_observation(x)` | tri-state | — | calculated (flag) | On the officer's list |
| `phase` | int | 0–3 | calculated (§2) | Regime phase |
| `OBS_BONUS` | int | 0–2 | constant (1) | Being listed adds weight beyond the number |
| `PHASE_BONUS` | int | 0–2 | constant (1) | A panicking state looks harder at everyone |
| `ATTENTION_CAP` | int | 4–8 | constant (6) | Scalar cap; at the cap the state acts rather than watches |
| `ATTN_LOOK`, `ATTN_WATCHED` | int | 1–cap | constants (3, 4) | Rule-licence thresholds |
| `DRIFT_PERIOD_ATTENTION`, `DECAY_PERIOD_ATTENTION` | int | 0 (off) or 2–8 | constants (3, 0) | Beats per drift / decay point |
| `A_eff(x)` | int | 0–6 | calculated | Effective attention |
| `red_band(x)` | int | 0–3 | calculated | Stamp-red reach step (none, margin, prop, light); Overlay Rendering's phase budget (art bible §4.3) is applied downstream |

Output range: clamped 0–`ATTENTION_CAP`; minimum 0 (never raised), maximum the cap (attention 5 + listed, or 4 + listed in panic). `red_band` is bounded 0–3 by construction; with the defaults, 1–2 is margin, 3–4 prop, 5–6 light. Example: `jan.attention` opens at 1; K1 inform `+1`, J2 print `+1`, J3 distribute `+2` → 5; `under_observation` true (K1) → `A_eff = min(6, 5 + 1 + 0) = 6`, `red_band = 3`: the raid is licensed and red reaches the key light — the state has stopped watching.

### 4. Broken-from-compliance count

The broken count is defined as: `B = Σ_{p ∈ protagonists} broken(p)` with `broken(p) = [ OR(defiance_p) ∧ ¬OR(retraction_p) ]` over field lists declared per act in chapter data (act one below). A dead or arrested protagonist keeps the value their paper shows at the moment they left (the act can succeed; the actor is never absolved — Pillar 3).

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `defiance_vera` | flags | — | data file | `{vera.discrepancy, vera.carbon_missing, vera.household_flagged, vera.took_blame}` — paper left by burning, leaking, warning, taking the blame |
| `retraction_vera` | flags | — | data file | `{vera.reported_jan}` — she bought the file's closure with Jan's name |
| `defiance_jan` | flags | — | data file | `{jan.leaflets_distributed, kastan.exposed}` |
| `retraction_jan` | flags | — | data file | `{jan.recanted, jan.gave_courier, jan.gave_ilona, jan.gave_vera}` |
| `defiance_tomas` | flags | — | data file | `{border.log_gap, tomas.confessed, border.family_through}` (letting the family through with a list in his hand is his second courage beat and leaves paper) |
| `retraction_tomas` | flags | — | data file | `{tomas.named_route}` |
| `broken(p)` | int | 0–1 | calculated | 1 if the paper says `p` acted against the state and did not unsay it |
| `B` | int | 0–3 | calculated | Protagonists broken from compliance |

Output range: bounded 0–3; 0 when no protagonist's defiance paper exists or each was retracted; 3 when all three act and none retract. `unknown` reads as not-true in both lists. Example: Vera burned (`discrepancy` true) and later reported Jan (`reported_jan` true) → `broken(vera) = 1 ∧ ¬1 = 0`; Jan distributed, never recanted → 1; Tomas let the courier through (`log_gap`) then named the route → 0 (`confessed` and `named_route` are an incompatible pair, so the formula cannot cancel itself). `B = 1`.

### 5. Ending-class selector

The ending selector is defined as: `ending = first r ∈ ENDING_TABLE_act such that match(r, phase, B, K_1..K_n)`, where each row `r` is a conjunction of constraints (`=`, `≠`, `∈`, `≥`) over the aggregates and `K_i` are the act's **key axes** — small enums, each a pure derivation of at most four dossier fields, at most `KEY_AXES_MAX` per act. The table is data; the last row is a declared fallback and is never E0. Chapter & Story Structure owns the rows; this model owns the derivations and the selector. Act-one key axes (five):

| Axis | Derivation (first true wins) |
|---|---|
| `ledger` | `filed` if `marta.report_4471 = filed`; `gap` if `vera.discrepancy`; `reconciled` if `office.ledger_reconciled` (doctored); else `pending` |
| `review` | `admitted` if `ilona.admitted`; `renounced` if `ilona.renounced`; `refused` if `ilona.review_refused`; `deferred` if `ilona.review_deferred`; else `pending` |
| `gate` | `split` if `border.courier_through ∧ border.family_detained`; `held` if `courier_detained ∨ family_detained`; `passed` if `courier_through ∨ family_through`; else `untested` |
| `route` | `burned` if `border.route_burned`; `listed` if `border.courier_listed`; else `open` |
| `press` | `named` if `kastan.exposed`; `raided` if `jan.press_raided`; `distributed` if `jan.leaflets_distributed`; else `silent` |

Act-one table (priority order; rows corrected by the narrative-director against §7 of the brief and the `act1.lp` class rules, so each row selects exactly the class's situation). A row may test a schema field marked `key: true` outside the five axes; such fields count toward `KEY_AXES_MAX` as a sixth axis only if the act declares them so:

| # | Class | Match |
|---|---|---|
| 1 | E9 The route burned | `route = burned ∧ ¬jan.arrested` |
| 2 | E4 The seized parcel | `border.courier_detained ∧ office.border_report ∧ marta.hospitalised ∧ press = silent ∧ phase = 0` |
| 3 | E3 The carbon | `press = named ∧ vera.under_observation ∧ border.family_detained` |
| 4 | E6 The mother's trade | `press = raided ∧ review = admitted ∧ ilona.renounced ∧ vera.reported_jan ∧ ¬vera.under_observation` |
| 5 | E7 The daughter's statement | `press = raided ∧ review = renounced ∧ ledger = pending ∧ (vera.household_flagged ∨ vera.carbon_missing)` |
| 6 | E8 Marta's breath | `review = refused ∧ route = open ∧ gate ∈ {passed, split} ∧ marta.pleaded ∧ vera.household_flagged` |
| 7 | E1 The complete file | `ledger = filed ∧ route = listed ∧ gate = split ∧ review = admitted` |
| 8 | E5 The open gate | `border.courier_through ∧ tomas.confessed ∧ press = distributed ∧ vera.reported_jan` |
| 9 | E2 The gap | `ledger = gap ∧ berta.reported ∧ vera.under_observation ∧ border.courier_through ∧ press = silent` |
| 10 | fallback | `true` → `act_fallback`, a generic epilogue that reads only the axes it is handed and asserts no event (never E7, which asserts a raid and a renunciation that may be false); logged as `ending_fallback` |

The corrected rows are mutually exclusive, so order masks nothing; it is kept as the tie-break against future rows.

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `phase` | int | 0–3 | calculated (§2) | Regime phase at act close |
| `B` | int | 0–3 | calculated (§4) | Broken count. **Rule:** no ending row may condition on `B` unless it also conditions on at least one key axis, and no act-one row uses it; `B` is an aggregate for the regime's fall in later acts, never a heroism score |
| `K_i` | enum | per axis | calculated | Key axis values |
| `KEY_AXES_MAX` | int | 3–5 | constant (5) | Axes an act may declare |
| `ENDING_TABLE_act` | rows | 1–N | data file | Ordered rows, total by construction (last row `true`) |
| `ending` | enum | act's class set | calculated | Selected class |

Output range: exactly one class, always (the table is total); E0 is unreachable at runtime because no row names it; the simulator proves E0 unreachable in the *world* (`no_one_unchanged`) separately, which is why the fallback should fire in no witnessed telling — a fallback hit in a simulator run is a build failure. Example: close state `phase 1, B 2, ledger = gap, review = deferred, gate = passed, route = open, press = distributed, border.courier_through, tomas.confessed, vera.reported_jan` → rows 1–7 fail; row 8 matches → **E5**. The same state with `vera.reported_jan` unknown matches no class row and reaches `act_fallback`, which in a simulator run is a build failure: the world admitted a telling the table does not name.

### 6. Flag-budget check

The chapter flag-budget check is defined as: `budget_ok(c) = [ |R_c| ≤ READ_MAX ] ∧ [ |W_c| ≤ WRITE_MAX ] ∧ [ |R_c ∩ X| ≤ CROSS_READ_MAX ] ∧ [ |W_c ∩ X| ≤ CROSS_WRITE_MAX ]` where `R_c`, `W_c` are the sets of distinct field ids referenced (authoring: statically, including every rule that can fire at the chapter's boundaries; runtime: actually read/written), and `X` is the set of schema fields with `cross_life: true` plus every `calendar.*` target.

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `R_c` | set | 0–schema size | calculated | Distinct dossier, sheet and calendar fields read in chapter `c` |
| `W_c` | set | 0–schema size | calculated | Distinct fields written in `c` (filing, dialogue, and rules fired at its boundaries) |
| `X` | set | — | data file (schema) | Cross-life fields |
| `READ_MAX` | int | 8–32 | constant (20) | Distinct reads per chapter |
| `WRITE_MAX` | int | 8–32 | constant (24) | Distinct writes per chapter |
| `CROSS_READ_MAX` | int | 2–10 | constant (6) | Cross-life reads per chapter (the act-one brief's `crossing_read` list has seven across all chapters) |
| `CROSS_WRITE_MAX` | int | 2–10 | constant (8) | Cross-life writes per chapter |
| `budget_ok` | bool | — | calculated | Authoring: build gate; runtime: log only |

Output range: boolean. Example, Vera's act-one chapter from the PDDL V1–V9 plus rules R1, R3, B1, K2, M2 and world moves: writes `vera.{discrepancy, carbon_missing, household_complete, household_flagged, took_blame, reported_jan, under_observation, attention}`, `marta.{report_4471, under_observation, attention, pleaded}`, `office.ledger_reconciled`, `kastan.rewarded`, `berta.{implicated, reported, cleared}`, `jan.{under_observation, attention}`, `ilona.{review_deferred, known_in_circle, attention}` = 22 ≤ 24; cross-life writes `{carbon_missing, household_flagged, reported_jan, jan.under_observation, jan.attention, ilona.known_in_circle, marta.report_4471}` = 7 ≤ 8. `budget_ok = true`, with two writes of headroom — tight on purpose.

### 7. Per-chapter cross-life read budget (the payoff budget)

The cross-life read formula is defined as: `payoff_reads(c) = |{ f ∈ R_c ∩ X : last_source_protagonist(f) ∉ {protagonist(c), null} }|` and the check is `payoff_reads(c) ≤ CROSS_READ_MAX` with the authoring warning `payoff_reads(c) ≥ CROSS_READ_MIN` for every chapter after the first of an act (Pillar 4: a chapter that reads nothing of the others has no payoff).

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `R_c ∩ X` | set | 0–`|X|` | calculated | Cross-life fields the chapter reads |
| `last_source_protagonist(f)` | enum/null | vera, jan, tomas, null | calculated (field provenance) | Who last wrote `f`; null for rules/chapter/assume |
| `CROSS_READ_MIN` | int | 0–3 | constant (1) | Minimum payoff reads per non-first chapter (warning, not failure) |
| `payoff_reads` | int | 0–`CROSS_READ_MAX` | calculated | Reads that land another life's consequence |

Output range: 0 to `CROSS_READ_MAX`; 0 is legal only for the first chapter of an act. Example: Tomas's act-one chapter reads `border.courier_listed` (last written by Vera's filing via R4), `border.border_tightened` (Jan's J3), `border.inquiry` (rules → null) → `payoff_reads = 2`; passes, and the brief's own law `crossing_read` additionally demands each is read within four beats.

### 8. Record status derivation on write

The status transition on an applied effect is defined as: `status' = active if status ∈ {absent, opened, closed} ∧ op ∈ {set, add, max, min}; opened if status = absent ∧ op = tag; status otherwise` — and for `status ∈ {archived, destroyed, released}` the effect is rejected unless writer = `migrate` (archived only). No variable table beyond the enum above; output is the status enum. Example: `berta` is `absent`; V3 applies `set berta.implicated = true` → `active`, change records for the field and `status_change {absent → active}`.

### 9. Assumption budget

The assumption budget check is defined as: `assume_ok(act) = [ |A_act| ≤ ASSUME_BUDGET ]` with `A_act` the set of `assume`-sourced fields still uncontradicted at any point in the act.

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `A_act` | set | 0–5 | calculated | Live assumptions |
| `ASSUME_BUDGET` | int | 0–3 | constant (2) | Matches the prototype's `assume_min` cost of one per unknown; two is the most a telling may rest on |

Output range: boolean; authoring failure if exceeded. Example: a telling assuming `ilona.known_in_circle` and `border.courier_listed` → 2 ≤ 2, ok; adding `kastan.rewarded` fails.

---

## Edge Cases

1. **If two effects in one scene boundary set the same flag to different values:** the write from the higher-precedence writer wins (`rules > chapter > filing > dialogue > assume`); at equal precedence the later in list order wins; exactly one change record is emitted, with `before` the pre-batch value and a tag `conflict:<losing source>` on the record. *Rationale:* the state's reaction is the last word in a scene (Pillar 2); the loser is kept on paper so the simulator can flag the collision as an authoring smell (it is one), without the runtime ever having two truths.
2. **If two effects in one boundary `add` the same scalar:** they sum (§1); `max`/`min` apply after; one change record. *Rationale:* commutativity makes chapter order irrelevant for scalars, which is what "consequences flow forward only" needs.
3. **If an effect targets a `closed` record:** `tag` applies without reopening; any other op reopens the record to `active`, applies, and emits two change records (`status_change`, then the field) plus tag `reopened:<day>`. *Rationale:* a closed case is a state's promise it does not keep; reopening must be visible as its own change so Paper UI can stamp it.
4. **If an effect targets an `archived`, `destroyed` or `released` record:** rejected, no change record, error log with the source tag; `migrate` may write `archived` only. *Rationale:* the past act is fixed data the simulator and the epilogues already read; silently rewriting it would make the ending drift from the telling.
5. **If `attention` is at `ATTENTION_CAP` and an effect adds more:** clamped, no change record, no overflow stored; the authored cost must already be a flag (law `cost_is_a_person`). *Rationale:* the cap is where the state acts rather than looks; "pressure beyond the cap" is a raid or an arrest, which are flags.
6. **If `attention` is at 0 and an effect subtracts:** clamped at 0, no change record; the sign table shows nothing. *Rationale:* a negative eye has no meaning; `set` below `lo` by a `rules` writer is also clamped and logged as an authoring error.
7. **If a protagonist is arrested mid-act:** `arrested` is set; the record stays `active`; rules keep writing it (interrogation writes `gave_*`); `broken(p)` is read from paper as normal; the chapter sheet is **not** wiped until Chapter & Story Structure closes the chapter (it owns death and the story continuing); the arrested protagonist's view is still computable (Paper UI may show the cell's version: orders only). *Rationale:* the file does not stop when the person does.
8. **If a character dies mid-act:** the `chapter` writer sets `status = closed` with tag `deceased:<day>`; all pending flag effects in that boundary still apply (paper outlives people); further effects reopen as in case 3 (a dead man's file can still name people); `attention` is frozen (further `add` rejected with a log) and excluded from nothing, since no aggregate sums attention; `broken(p)` keeps the value the paper shows. *Rationale:* Pillar 3 and 4 — the act's consequences land in other lives whether or not the actor survives.
9. **If a flag is read before it is ever written:** returns `unknown`; `is_true` and `is_false` are both false, `is_unknown` true; a scalar returns its schema default; no change record; the read counts toward the budget. *Rationale:* a blank in the file is a value the state can act on ("household file incomplete"), so it must be distinguishable from a recorded no.
10. **If an undeclared field or record is referenced:** authoring — build fails naming the reference; runtime — reads return `unknown`/default and log an error, writes are rejected and log an error, debug builds assert. *Rationale:* fixed schema is the god-object guard; runtime never breaks a player's game over a content typo.
11. **If an assumption-licensed branch runs and the unknown is never resolved in the act:** at `archive` the assumed value is settled as the real value with source `assume:<chapter>:settled`, a change record with `contradicts: null` and tag `settled_by_assumption`; aggregates and the ending read it as settled; where the assumption declares a tag placement (Core Rule 8) the settled value is a record tag and the act's flag stays `unknown`; the epilogue may read the tag to say what the player never learned (narrative rule: mysteries have true answers). If it is contradicted earlier by any non-`assume` write, the real value wins at once and the change record's `contradicts` names the assumption, which rules may read to let the state be visibly wrong. *Rationale:* the telling rested on the premise and was admitted on that basis (the prototype's `assume_min`); settling it makes the save and the ending deterministic, and flagging it keeps the lie findable.
12. **If two protagonists' chapters write the same flag:** allowed only for `cross_life` fields; applied in play order; identical values are a no-op (no change record, provenance unchanged, tag `also:<source>` appended so the file shows both hands); different values — the later chapter wins and emits a normal change record with `before/after`; the earlier chapter is never re-read. Non-cross-life fields: the second chapter's write is rejected at authoring (owner rule §6.5). *Rationale:* time order is the truth of a file (it was amended); consequences flow forward only, which is what keeps the cross-life channel a set of flags rather than a tree.
13. **If `deserialize` receives a payload with a different `schema_version`:** rejected whole with `SCHEMA_MISMATCH(expected, got)`; nothing partial is loaded; Save/Load runs its migration (writer `migrate`, producing a payload at the current version) and calls again. A payload with an undeclared field or record at the current version is rejected the same way; a declared field missing from the payload is rejected too (migrations fill with `defaults()`). A payload newer than the code is rejected (no downgrade). *Rationale:* strictness both ways is what lets the simulator and the unit tests trust a save; leniency would hide a migration bug as a blank file.
14. **If a chapter exceeds its flag budget at authoring time:** the validator fails the build, listing `|R_c|, |W_c|`, the cross-life subsets and every field over the line, and which rules contributed (rules' writes count for the chapter whose boundary fired them). **If it happens at runtime** (hot-loaded content, or a rule cascade longer than the static analysis assumed): reads are served and writes applied, an error is logged with the same listing, a telemetry counter increments, debug builds assert. *Rationale:* budgets are a writers' discipline; at runtime the only alternatives to serving the read are a wrong default or a crash.
15. **If a chapter opens with a declared `assumes` on a field that is not `unknown`:** the assumption is skipped (no write, no change record), logged as `assume_unneeded`; the real value stands. *Rationale:* an assumption is a licence to proceed without knowledge, not a way to overwrite it.
16. **If the ending selector reaches the fallback row:** the fallback class is returned and `ending_fallback` logged with the full aggregate vector; in a simulator run this is a failure (the world admitted a telling the table does not classify). *Rationale:* a player must always get an ending; the writers must always learn that one was unnamed.
17. **If `phase` would fall (stability recovers):** it does not; `phase_reached` holds it. *Rationale:* the concept fixes the sequence confident → paranoid → panicking → collapsing; relief effects change stability for the *next* band threshold, not the current phase.
18. **If an effect's `source` names a chapter other than the one Scene Flow has open:** rejected and logged (a stale batch). *Rationale:* chapter attribution drives the budgets and `source_protagonist`; a mis-attributed write corrupts both.

## Dependencies

The model depends on nothing at runtime: it is the Foundation layer's first system and must build and test alone. Eleven systems depend on it. Direction and nature follow the systems index boundary rules.

| System | Direction | Nature of Dependency |
|--------|-----------|---------------------|
| Narrative Content Format & Strings | Content depends on this (schema); this depends on Content at authoring time only | The field schema (`schema/dossier-fields.yaml`) is authored here and consumed by the content format as the vocabulary for effect records; every chapter's effect data is validated against it. No runtime import either way. |
| Investigation & Fact System | Fact depends on this | Reads flags for unlock conditions (a fact becomes available when the state has acted). Never writes. Player-held facts are Fact's own state, not dossier state. |
| Reactive Event Rules & Story Simulator | Rules depend on this | Reads the full record set and the change records of the current boundary; writes only by returning effect records (source tag `rules`). The simulator runs the same evaluator headless over the same schema; the polyscene topic's fluents map one-to-one to dossier fields. |
| Calendar, Regime Phase & Attention | Phase depends on this | Two pure functions of dossier aggregates: regime phase from the city record; per-character attention from the character record. Never writes. |
| Scene Flow | Scene Flow depends on this | Owns the scene-boundary sequence; calls `apply` exactly once per batch in the order decision → rules, then hands the boundary's change records to Paper UI. The boundary counter here is Scene Flow's clock. |
| Overlay & Surveillance Rendering | Overlay depends on this (indirectly) | Reads the attention value through Calendar, Regime Phase & Attention, never raw fields. Carbon double-strike on objects the state has a copy of is driven by the `has_copy` projection rule in Core Rule 7. |
| Dialogue & Interrogation | Dialogue depends on this | Reads flags as line conditions; writes by producing effect records (source tag `dialogue`) at the end of a conversation, never mid-line. |
| Filing & Decision | Filing depends on this | The main writer: each filing act (file, burn, doctor, warn, leak, take blame, report) is content data that expands to effect records (source tag `decision`). |
| Paper UI | Paper UI depends on this | Renders the three projections (files / signs / orders) and the scene-end reveal from change records. Owns seen/unseen; this model holds no UI state. |
| Chapter & Story Structure | Chapter depends on this | Reads the ending aggregates and the declared cross-life flags at chapter start and act end; declares each chapter's flag budget in content. |
| Save/Load | Save/Load depends on this | Persistence contract: `serialize()` / `deserialize()` of plain data with `schema_version`; Save/Load owns the registry and migration. |
| Audio & Adaptive Surveillance Mix | Audio depends on this (indirectly) | Reads phase and attention through Calendar, Regime Phase & Attention; listens to change records tagged `cross_life` for the overprint cue. Never raw fields. |

## Tuning Knobs

All live in `assets/data/dossier/tuning.json` (names below are the registry names); the act-one value is the default.

| Knob | Default | Safe range | Too low | Too high | Interacts with |
|---|---|---|---|---|---|
| `ATTENTION_CAP` | 6 | 4–8 | Everyone is "watched" after two acts; signs saturate; red reaches the light band before the raid is licensed | Attention never reaches the licences; the state looks but never acts | `ATTN_LOOK`, `ATTN_WATCHED` (must stay < cap), `OBS_BONUS`, stamp-red phase budgets (art bible) |
| `ATTN_LOOK` | 3 | 2–cap−1 | The query fires on the first act of any kind; no quiet first week | Rybar never licensed by number alone; only flags move him, so `attention` is decoration | `ATTENTION_CAP`, the drift period |
| `ATTN_WATCHED` | 4 | `ATTN_LOOK`–cap | Signs say "watched" before the officer has looked (contradicts `attention_precedes_action`) | The sign table is silent until the raid | `ATTN_LOOK`, sign thresholds in Narrative Content |
| `OBS_BONUS` | 1 | 0–2 | Being listed feels like nothing | Listing alone maxes `A_eff`; red jumps to the light band in one beat | `ATTENTION_CAP` |
| `PHASE_BONUS` | 1 | 0–2 | Panic looks the same as calm on a person | Panic puts everyone at cap; the per-character signal dies | `ATTENTION_CAP`, `T_PANIC` |
| `DRIFT_PERIOD_ATTENTION` | 3 | 2–8 (0 off) | A gap alone brings the query in two beats; burning becomes unplayable | A gap is never noticed; law `gap_is_noticed` fails in the simulator | `ATTN_LOOK`, horizon (12 beats per act) |
| `DECAY_PERIOD_ATTENTION` | 0 (off) | 0, 4–8 | Attention melts; recanting is free | — | Only meaningful with acts ≥ 18 beats; keep off while acts are 12 |
| `STABILITY_OPENING` | 9 | 7–10 | Act one goes paranoid on its first hit | Three hits cannot reach paranoid; `regime_paranoid` is licensed but costless | `T_PARANOID`, `DRIFT_PERIOD_STABILITY` |
| `DRIFT_PERIOD_STABILITY` | 3 | 2–6 | Paranoia alone collapses the regime without players (violates "the regime falls only if the players' acts bring it down") | Drift irrelevant; only authored hits matter (acceptable for act one) | `T_PANIC`, `U_CROWD`, act horizon |
| `T_PARANOID` / `T_PANIC` / `T_COLLAPSE` | 7 / 5 / 2 | 6–8 / 3–6 / 0–3, strictly decreasing | Phases arrive before the writers' licences; `no_panic_before_crowd` masks it only if `U_*` hold | Act three cannot reach collapsing without unreachable hit totals | `STABILITY_OPENING`, `U_CROWD`, `U_COLLAPSE` |
| `U_CROWD` / `U_COLLAPSE` | 6 / 9 | 4–8 / 7–12 | Panic without a street (law violation) | The crowd never counts; collapse impossible | `T_PANIC`, `T_COLLAPSE`, unrest drift (+1 per 2 beats while distributed — a Rules knob, read here) |
| `READ_MAX` / `WRITE_MAX` | 20 / 24 | 12–32 | Act-one Vera (22 writes) fails the build; writers hide state on the sheet | The budget never bites; the god object returns by content | `CROSS_*` (must be ≤ the totals) |
| `CROSS_READ_MAX` / `CROSS_WRITE_MAX` | 6 / 8 | 2–10 | One payoff per chapter; Pillar 4 thins | Chapters read a tree of each other; the simulator's branch count explodes | `CROSS_READ_MIN`, `KEY_AXES_MAX` |
| `CROSS_READ_MIN` | 1 | 0–3 | Chapters with no payoff pass silently | First-chapter-of-act warnings everywhere | `CROSS_READ_MAX` |
| `KEY_AXES_MAX` | 5 | 3–5 | Nine classes cannot be told apart; fallback fires | Endings read a tree again | Ending table rows, `CROSS_READ_MAX` |
| `ASSUME_BUDGET` | 2 | 0–3 | No unknowns; Vera's chapter cannot start before Jan's | Tellings rest on premises; `diagnose()` loses meaning | Chapter order (Chapter & Story Structure) |
| `SIGN_LAG_DEFAULT` | 1 beat | 0–3 | Signs are instant; the dissident reads the file as plainly as the archivist | Signs arrive after the raid | Sign table lags in Narrative Content; `ATTN_WATCHED` |
| `CHANGE_LOG_RETENTION` | act | scene–act | Reveal and `contradicts` lose history mid-act | Save size grows (negligible at these counts) | Save/Load payload |

Interaction clusters: (a) `ATTENTION_CAP`–`ATTN_LOOK`–`ATTN_WATCHED`–`OBS_BONUS` must satisfy `ATTN_LOOK < ATTN_WATCHED ≤ ATTENTION_CAP` and `ATTN_WATCHED − OBS_BONUS ≥ ATTN_LOOK` or listing alone makes someone "watched" before the state looked; (b) `STABILITY_OPENING`, the three `T_*`, the two `U_*`, and the drift periods decide which phase each act can reach — change one, re-run the simulator's phase-reachability check for every act; (c) the four budget maxima are ordered `CROSS_* ≤ *_MAX` and `KEY_AXES_MAX ≤ CROSS_READ_MAX`.

## Visual/Audio Requirements

The model has no presentation of its own; every row below is a requirement placed on the system that renders it. Art bible references in brackets.

| Event | Visual Feedback | Audio Feedback | Priority |
|-------|----------------|---------------|----------|
| Change record revealed at scene end (own chapter) | The dossier sheet's changed line gains the carbon double-strike ghost and the `cc` mark (art bible §4.5); the stamp is the field's state stamp (WATCHED, FLAGGED, CLEARED, ARRESTED) in stamp red at the phase's ink reach (§2.2) | A single stamp impression; weight by phase (audio-director to specify) | High |
| Change record with `source_protagonist` set and not the current protagonist is revealed (another protagonist's payoff lands), after the sign's `lag` where the field projects as a sign | The originating chapter's ink and letterform overprinted on the sign object or file line that carries it, never on a bare field line (§1.3, §4.6): archivist grey-green cursive, dissident soot hand-set, conscript khaki stencil. A `cross_life` change by rules or by the current protagonist gets no overprint | The overprint cue, the one cue that is not paper (audio-director to specify, art bible §7.4 audio backup) | High |
| Attention rises past a band threshold for the current protagonist | Stamp red reaches further into the plate per the phase budget table (§4.3); never a meter | Surveillance bed rises one step | High |
| Attention falls to 0 | Red withdraws to margin and official stamps only | Bed drops out | Medium |
| Regime phase changes | The whole plate's light recipe changes at the next scene (§2.2); the date stamp's ink reach changes | Phase bed changes at the calendar transition | High |
| Record closed (ARCHIVED / DESTROYED / RELEASED) | The file's closing stamp on its last page (§2.2 Epilogue row); no triumphant colour on any closing | Final stamp, then silence | High |
| Effect dropped at runtime (budget guard, release build) | None to the player; a `dropped` change record goes to the debug log only | None | Low |

## Game Feel

Not applicable: the model has no input, animation or impact of its own. The feel of filing, reveal and interrogation is owned by Filing & Decision, Paper UI and Dialogue & Interrogation respectively, and each of those GDDs carries its own Game Feel section. The one feel requirement this model imposes on them is in Player Fantasy: a cross-life payoff is staged, never explained.

## UI Requirements

The player never sees a dossier field as a value. The three projections are the only player-facing form of this model; Paper UI designs the sheets, this document fixes what reaches each sheet (Core Rule 7).

| Information | Display Location | Update Frequency | Condition |
|-------------|-----------------|-----------------|-----------|
| Files projection (full record text for every character the archivist has pulled) | Archivist dossier sheet, gridded form (art bible §5.1) | At each scene boundary reveal | Protagonist is Vera; record is `opened` or later; field is in the files projection set |
| Signs projection (a sign per flag the dissident can infer, never the flag's name) | Dissident pinboard of torn fragments (§5.1); also in-scene props (the car, the dead phone) placed by Scene Flow | At scene start, from the previous boundary | Protagonist is Jan; the flag has a sign entry in the signs table; the sign's `shown_at` chapter condition holds |
| Orders projection (the state's instruction for today, a list of names) | Conscript order sheet, stencil (§5.1) | At scene start | Protagonist is Tomas; the record is on the day's list |
| Scene-end change reveal (what changed, in whose ink) | The open dossier's changed lines, in the dossier tab (§9.1 HUD) | Once per scene boundary | At least one change record was emitted this boundary and is visible in the current projection |
| Closing stamp of a record | The file's last page at the epilogue | Once | Record transitions to a closed state |
| Nothing: regime stability, unrest, attention, flag names | Never displayed as numbers or names | — | The dossier is never a meter (Player Fantasy) |

## Cross-References

| This Document References | Target GDD | Specific Element Referenced | Nature |
|--------------------------|-----------|----------------------------|--------|
| Scene boundary sequence decision → effects → rules → phase and attention → reveal → calendar | `design/gdd/scene-flow.md` (not yet written) | Boundary step order; `begin_boundary` / `apply` / `end_boundary` call order | Rule dependency |
| Rules cascade cap and tie-break; drift and world moves as rules | `design/gdd/reactive-event-rules.md` (not yet written) | Cascade cap; rule format; drift rules `DRIFT_PERIOD_*` | Rule dependency |
| Regime phase and effective attention are computed by the Calendar from this model's aggregates (Formulas §2, §3) | `design/gdd/calendar-regime-phase.md` (not yet written) | `regime_phase`, `attention_effective` functions; beat clock | Ownership handoff |
| Stamp-red bleed input `red(x)` and phase budgets | `design/art/art-bible.md` | §4.3 phase red budgets; §2.2 state table; §4.5 carbon ghost; §1.3 three inks | Data dependency |
| Signs, orders and file line forms are string ids | `design/gdd/narrative-content-format.md` (not yet written) | Sign table (`threshold`, `lag`, string id); document line ids; chapter declarations `reads` / `writes` / `assumes` | Data dependency |
| Filing acts expand to effect batches; every option writes a cost | `design/gdd/filing-and-decision.md` (not yet written) | Decision data → effect records, writer `filing` | Ownership handoff |
| Dialogue writes effects at conversation end | `design/gdd/dialogue-interrogation.md` (not yet written) | Writer `dialogue`; line gating reads | Data dependency |
| Paper UI renders projections and the reveal; owns seen/unseen | `design/gdd/paper-ui.md` (not yet written) | Reveal step consumes change records; three view grammars | Ownership handoff |
| Ending table rows, chapter open/close, archive and release, death | `design/gdd/chapter-story-structure.md` (not yet written) | `ENDING_TABLE_act`; writer `chapter`; act-one classes E1–E9 | Data dependency |
| Act-one classes, axes, laws and unknowns | `design/narrative/paper-walls-act-one-brief.md` | §4 fluent ownership; §5 unknowns; §7 axes and ending classes | Data dependency |
| Act-one world as proven by polyscene | `prototypes/paper-walls-branches-concept/act1.pddl`, `act1.lp` | Fluent list (field candidates); `act_ending` class rules; `no_one_unchanged` | Rule dependency |
| Save registry, migration, save points, RNG state | `design/gdd/save-load.md` (not yet written) | `serialize` / `deserialize` payload; `SCHEMA_VERSION`; writer `migrate` | Ownership handoff |
| Held facts are not dossier state; every fact has a dossier use | `design/gdd/investigation-fact-system.md` | Fact board state; unlock reads | Rule dependency |
| Headless boundary and flag budget as named risks | `design/gdd/systems-index.md` | Boundary review rules; risk register | Rule dependency |
| Model representation, change-record delivery, node-free rule | `docs/architecture/` ADR-1 (not yet written) | Chapter sheet hosted here; `calendar.*` namespace; RefCounted vs Resource | Rule dependency |
| Save format and the no-resource-from-save rule | `docs/architecture/` ADR-4 (not yet written) | JSON plain data; schema version first | Rule dependency |

## Acceptance Criteria

Citations: **CR§n** = Core Rules, **ST** = States and Transitions, **IX** = Interactions table, **F§n** = Formulas, **EC n** = Edge Cases, **G** = Tuning Knobs. Test files follow `.claude/rules/test-standards.md`. All constants are read from `assets/data/dossier/tuning.json` and `schema.json` fixtures, never inlined, except where the boundary value is the point.

**Logic** (gdUnit4, `tests/unit/dossier/`, BLOCKING)

- [ ] **Scalar batch application (F§1, EC 5, EC 6)**, `dossier_scalar_apply_test.gd`: with `vera.attention = 2`, the batch `{add 1, add 2, min 4}` yields 4 and exactly one change record `before 2, after 4`; every permutation of the two `add`s yields the same result; an `add 1` at `ATTENTION_CAP` and an `add −1` at 0 each yield no change record and leave the value unchanged.
- [ ] **Same-field flag conflict (CR§4, EC 1)**, `dossier_batch_precedence_test.gd`: a `filing set true` and a `rules set false` on one flag in one boundary resolve to `false`, emit exactly one change record whose `before` is the pre-batch value, and append tag `conflict:<filing source>`; two `dialogue` writes at equal precedence resolve to the later in list order.
- [ ] **Writer and op rejection (CR§3, CR§4, CR§6.2, CR§6.4, CR§6.5, EC 10, EC 18)**, `dossier_write_rules_test.gd`: each of the following is rejected with no change record, unchanged state, and one error log naming the source tag: `filing set attention`; `add` on a flag; `clear` on a ratchet field from `filing`; a `jan`-chapter write to non-cross-life `vera.took_blame`; an effect on an undeclared field or record; an unparseable `source`; a `source` naming a chapter other than the open one.
- [ ] **Tri-state reads (CR§6.6, CR§6.7, EC 9)**, `dossier_read_semantics_test.gd`: a never-written flag returns `unknown` with `is_true = false`, `is_false = false`, `is_unknown = true`; a never-written scalar returns its schema default; neither read emits a change record; both appear in the chapter's logged read set `R_c`.
- [ ] **Record lifecycle (ST, F§8, EC 3, EC 4, EC 8)**, `dossier_lifecycle_test.gd`: `absent` + `tag` → `opened`; `absent` + `set` → `active` with `status_change {absent → active}` on the change record; `closed` + `set` → `active`, two change records in order (`status_change`, then the field) and tag `reopened:<day>`; `closed` + `tag` stays `closed`; `set` from `filing` on `archived`, `destroyed`, `released` is rejected and `migrate set` on `archived` is applied; after `chapter` sets `closed` + `deceased:<day>`, pending flag effects in that boundary still apply and a later `add attention` is rejected with a log.
- [ ] **Regime stability and phase (F§2, EC 17)**, `dossier_regime_phase_test.gd`: with G defaults, `phase(stability, unrest, paranoid, phase_reached)` returns `(9,1,unknown,0) → 0`, `(7,1,unknown,0) → 1`, `(8,1,true,0) → 1`, `(5,6,·,0) → 2`, `(5,5,·,0) → 1` (no panic before a crowd), `(2,9,·,0) → 3`, `(2,8,·,0) → 2`, `(10,0,unknown,2) → 2` (the ratchet); the F§2 worked example yields stability 5.
- [ ] **Effective attention (F§3)**, `dossier_attention_test.gd`: `A_eff(5, under_observation = true, phase 0) = 6` and `red_band = 3`; `A_eff(3, unknown, phase 2) = 4`; `A_eff(6, true, phase 2) = 6` (clamped); `red_band` is 0, 1, 1, 2, 2, 3, 3 for `A_eff` 0 to 6 with the default thresholds.
- [ ] **Broken count (F§4)**, `dossier_broken_count_test.gd`: the F§4 example yields `B = 1`; all three defiant and unretracted yields 3; an all-`unknown` dossier yields 0.
- [ ] **Key-axis derivation (F§5 axis table)**, `dossier_key_axes_test.gd`: first-true-wins per axis: `report_4471 = filed ∧ discrepancy` → `ledger = filed`; `courier_through ∧ family_detained` → `gate = split`; `kastan.exposed ∧ jan.press_raided` → `press = named`; `route_burned ∧ courier_listed` → `route = burned`; an all-`unknown` dossier yields `pending / pending / untested / open / silent`.
- [ ] **Ending selector (F§5, EC 16)**, `dossier_ending_select_test.gd`: the F§5 example vector returns E5; one fixture vector per table row returns that row's class; the all-pending vector returns the declared fallback class and logs `ending_fallback` with the full aggregate vector; no fixture, including the fallback, returns E0.
- [ ] **Assumptions (CR§8, EC 11, EC 15)**, `dossier_assume_test.gd`: `assume` on an `unknown` field makes it read as the assumed value; a later `filing set` emits a change record with `contradicts = <assume source>`; `assume` on a non-`unknown` field is skipped with log `assume_unneeded` and no change record; `archive` with an uncontradicted assumption emits a change record with source `assume:<chapter>:settled` and tag `settled_by_assumption`, and aggregates read the settled value.
- [ ] **Budget and payoff arithmetic (F§6, F§7, EC 12)**, `dossier_budget_test.gd`: the F§6 act-one Vera fixture (22 writes, 7 cross-life) returns `budget_ok = true`; the same fixture plus three distinct extra writes returns `false` and names the fields over `WRITE_MAX`; the F§7 Tomas fixture returns `payoff_reads = 2`; two chapters writing the same cross-life flag to the same value emit no change record, keep provenance and append tag `also:<source>`; different values emit one change record with the later chapter's value.

**Determinism and headless** (BLOCKING)

- [ ] **Shuffle invariance (CR§4, CR§4a, F§1, EC 1, EC 2)**, `dossier_determinism_test.gd`: a boundary batch of at least 24 effects covering all six ops and all five runtime writers, shuffled 100 times under a fixed seed across writers (list order within one writer preserved, since CR§4 makes that order the tie-break), produces an identical ordered list of change records and identical `serialize()` output every time.
- [ ] **Simulator and game agree (IX Rules row; CR§11)**, `tests/integration/dossier/dossier_sim_game_parity_test.gd`: one scripted act-one telling, driven once through the story simulator and once through Scene Flow's `begin_boundary / apply / end_boundary` sequence with the same effect batches, yields byte-equal change logs and the same ending class; both paths load the evaluator from the same `src/dossier/` script.
- [ ] **Pure logic, no orphans (CR§11)**: `godot --headless` with gdUnit4 over `tests/unit/dossier/` exits 0, never 101; a grep of `src/dossier/` for `extends Node`, `get_tree(`, `Engine.get_main_loop(`, `randi(`, `randf(`, `randomize(` returns 0 matches; a grep for `res://tools` and `res://tests` across `src/` returns 0 matches.
- [ ] **Replay from save (CR§5, CR§10)**, `dossier_replay_test.gd`: two runs from the same deserialized payload and the same batch sequence produce identical change records and identical `next_change_id`; change ids continue monotonically from the loaded `next_change_id`.
- [ ] **Nine classes reachable, E0 unreachable (F§5, EC 16)**: the simulator's act-one enumeration records at least one telling whose selector output is each of E1 to E9, zero tellings selecting E0, and zero `ending_fallback` logs; the per-class telling ids are retained as a fixture under `tests/unit/dossier/fixtures/endings/`.

**Content validation** (the authoring validator run by the story simulator; CR§9; BLOCKING at build)

- [ ] **Undeclared reference (CR§3, EC 10)**: chapter content with an effect on an undeclared record or field fails the build with a non-zero exit and a message naming the record, field and source tag; the same content with the field added to `schema.json` passes.
- [ ] **Budget overrun (F§6, EC 14)**: a chapter fixture at exactly `WRITE_MAX` static writes passes; at `WRITE_MAX + 1` the build fails listing `|R_c|`, `|W_c|`, both cross-life subsets, every field over the line and the rule ids that contributed; the same holds for `READ_MAX`, `CROSS_READ_MAX` and `CROSS_WRITE_MAX`.
- [ ] **Declaration drift (CR§6.3, CR§9, EC 1, F§7)**: a referenced field absent from the chapter's declared `reads` / `writes` is an error; a declared field never referenced is a warning; two effects setting one flag to different values in one boundary are reported as a warning with both source tags; a non-first chapter with `payoff_reads < CROSS_READ_MIN` is a warning.
- [ ] **Assumption budget (F§9)**: an act fixture with two live assumptions passes; with three, the build fails naming the third `assume` source.
- [ ] **Fallback and fact coverage (EC 16; IX Fact row)**: any simulator telling that reaches the fallback row fails the run and prints the full aggregate vector; the validator joins Investigation & Fact data against the schema field list and fails naming any authored fact that no unlock condition references.

**Performance and persistence** (BLOCKING; profile in `tests/performance/dossier/`)

- [ ] **Boundary budget (CR§4a, CR§7)**, `dossier_boundary_perf_test.gd`: a boundary of 256 effects across all 12 act-one records, run 1,000 times under `godot --headless`, completes `begin_boundary → apply → end_boundary` in at most 2 ms median and 5 ms at p99; projecting all three views after that boundary costs at most 1 ms, and a second `project()` call at the same boundary counter performs zero evaluations (instrumented counter). Budgets are the QA lead's proposal, sized against act one's 24 writes per chapter; the technical director confirms them at `/create-architecture`.
- [ ] **Round-trip (CR§10, IX Save/Load row)**, `dossier_serialize_test.gd`: `serialize() → JSON → deserialize() → serialize()` is byte-equal to the first output, `schema_version` is the first key, a mid-chapter payload includes `records`, `sheet`, `change_log` and `next_change_id`; after `chapter_close` the payload's `sheet` is empty.
- [ ] **Schema mismatch rejected whole (EC 13)**, `dossier_schema_mismatch_test.gd`: payloads with an older `schema_version`, a newer one, an undeclared field, and a missing declared field are each rejected with `SCHEMA_MISMATCH(expected, got)` or the matching error, and `serialize()` before and after the rejected call is byte-equal.
- [ ] **Migration path (EC 13; `migrate` writer)**: a retained fixture `tests/unit/dossier/fixtures/save_v1.json` migrated by Save/Load's `migrate` writer deserializes at the current `SCHEMA_VERSION`, fills absent declared fields from `defaults()`, and selects the same ending class as its source run; every prior-version fixture keeps passing when `SCHEMA_VERSION` increments.
- [ ] **No hardcoded values**: every constant in Tuning Knobs is read from `assets/data/dossier/tuning.json`; a grep of `src/dossier/` for the default literals in a numeric context finds only the schema loader's defaults path.

**MVP done gate.** Three criteria must pass before this system is called done at MVP: (1) shuffle invariance and simulator/game parity, since this model is the only cross-life channel and the only input to the ending; (2) nine classes reachable, E0 unreachable, no fallback hit, which is the concept's promise stated as one observable result; (3) round-trip byte-equal and schema mismatch rejected whole, since Save/Load, the simulator and the tests all rest on trusting a payload. Everything else above blocks its own story but not the system's MVP sign-off.

## Open Questions

| Question | Owner | Deadline | Resolution |
|----------|-------|----------|-----------|
| ADR-1: confirm the chapter sheet hosted inside this model (Core Rule 2) and the `calendar.*` effect namespace routed by Scene Flow (Core Rule 1a) | technical-director | Before `/create-architecture` | Pending |
| ADR-1 spike: RefCounted vs Resource for the model under headless gdUnit4; signals on a RefCounted headless; JSON round-trip of typed dictionaries (int vs float). None is sourceable from `docs/engine-reference/godot/` | engine-programmer | Technical Setup gate | Pending; a one-day spike |
| Act-one ending table (Formulas §5): rows and priority against the brief §7 and the `act1.lp` class rules | narrative-director | Before Chapter & Story Structure GDD | Resolved 2026-11-03: nine rows corrected to the class rules, mutually exclusive; generic `act_fallback` epilogue instead of E7 |
| The generic `act_fallback` epilogue is one new piece of content | producer | Chapter & Story Structure GDD | Pending producer approval |
| `jan_press = printed` vs `silent` cannot be told from paper | narrative-director | Before Narrative Content Format GDD | Resolved 2026-11-03: dropped; no `press_heard` flag; Jan's closing scene tells it from the chapter sheet |
| `T_PANIC = 5` leaves E3 and E5 one drift beat from `panicking` inside act one | systems-designer | When the simulator's phase-reachability check runs on the production schema | Keep 5; re-run the check; set to 4 if the act reaches panicking |
| Whether Overlay Rendering can measure the red budget per plate on export (art bible §4.3) | technical-artist | Art-pipeline proof | Not this GDD's; recorded because `red(x)` feeds it |
