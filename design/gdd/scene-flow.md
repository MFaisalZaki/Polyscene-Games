# Scene Flow

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: In Design
> **Author**: Mustafa Faisal (user) + systems-designer, gameplay-programmer, engine-programmer, creative-director (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 4 Consequences cross lives · 1 Every fact is a weapon · 5 Pressure comes from attention, not reflexes

## Summary

Scene Flow is the conductor of Paper Walls: the one system that knows what happens next. It opens a chapter and its rooms, turns a touched hotspot into the document, conversation or decision the content names, stages everything the player does in a room, and when the room is left runs the boundary in a fixed order, the decision batch into the dossier, the rules over the result, the Calendar's phase and attention, the next room preloaded, the reveal that shows which files changed, then at most one inserted scene, the tear-off if the day turned, and the next room. It exists so that effects land once and in one order, so the state answers only at a boundary, so the story simulator replays a telling through the same path the game runs, and so Pillar 4 has a mechanism by which a filing in one chapter becomes paper in another. It owns no state but the cursor and runs headless on the null host.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `Dossier State Model` (the bracket), `Reactive Event Rules & Story Simulator` (`run_boundary`, the presentation rule, the replay runner), `Calendar, Regime Phase & Attention` (`ctx`, the outer bracket, transitions, the snapshot), `Scene & Interaction Framework` (the host), `Narrative Content Format & Strings` (scenes and exits), `Investigation & Fact System` (actions resolved, availability); drives Paper UI, Overlay, Audio, Dialogue & Interrogation, Filing & Decision, Chapter & Story Structure, Save/Load through the presentation sink and the injected runners

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `Dossier State Model`, `Reactive Event Rules & Story Simulator`, `Calendar, Regime Phase & Attention`, `Scene & Interaction Framework`, `Narrative Content Format & Strings`, `Investigation & Fact System`

## Overview

*Framing: infrastructure (Category `Core`, Layer Foundation), with its player-facing effect named because the player feels this system as the rhythm of every scene. No ADR cites it yet; ADR-1 (the dossier) is to confirm the boundary bracket it drives.*

Scene Flow is the conductor of Paper Walls. It is the one system that knows what happens next: it opens a chapter, puts its first room on screen through the Scene & Interaction Framework, turns a touched hotspot into the content action it names (a document to read, a conversation to have, a decision to make), stages what the player did, and when the room is left runs the **boundary**, the fixed sequence in which everything lands at once: the decision batch into the dossier, the rules evaluated over the result, the Calendar's phase and attention read, the next room preloaded, and the reveal step that shows the player which files changed. It queues the state's inserted scene when a rule fires one, plays the tear-off when the day turns, runs the decision-free calendar beats, closes the chapter and opens the next in play order, and at the end of the act hands the ending class to the epilogue. The player never operates it and never sees it; they feel it as a room that waits while they read, a scene that ends by showing what it cost, and a knock in the next room that answers something filed in the last one. Without it the seven systems it calls would have no order among them: effects would land twice or never, rules would fire mid-scene, the simulator could not replay a telling through the same path the game runs, and Pillar 4 would have no mechanism by which a filing in one chapter becomes paper in another. It owns no game state of its own beyond where the player is; it calls the dossier, the rules evaluator, the Calendar, the fact system, the content store, the host and a presentation sink, each injected, and it runs headless on the null host so the story simulator drives it with scripted intents.

## Player Fantasy

*Framing: indirect. The player never sees Scene Flow; they feel its rhythm, a room that waits and then a page that turns. Shaped with the creative director (three candidate framings; "nothing lands until you leave the room" chosen; "the scene ends; the file opens" kept as the anchor moment, since how the reveal is drawn is Paper UI's; "the page turns without asking" left to the Calendar's transition, GDD 7).*

**Nothing lands until you leave the room.** This system serves two feelings that take turns. The first is being left alone with paper: while a scene is open, the room holds still. What you have learned is yours at once, and a fact you hold can open the next drawer. But nothing you have said or signed has reached the file yet, and nothing the state does can reach you. The second is the moment that stillness ends. You walk through the door, and everything you did in that room lands together, in one order, on every file it touches. Only then does the next room open.

The anchor moment: Vera burns the report and leaves the office. The room wipes to paper. Her own file shows one line changed, and the other two files show nothing yet. The wipe has hardly settled when the telephone rings. It is not her next scene; it is Rybar, asking politely after a copy his ledger says was sent. He hangs up, and only then does the room she chose open, the person waiting on the other side of it. The player did not see a rule fire. They saw the file change, then the state arrive, then their own scene resume, always in that order. By the third chapter they wait for the reveal the way you wait for the post.

Pillar alignment. Pillar 5, "pressure comes from attention, not reflexes": inside a scene there is no clock of Scene Flow's own. The only timed sheet is Dialogue's under interrogation, and even then the room behind it is suspended. A player can sit with a sheet as long as they like, because nothing they have done is in effect until they choose to leave. Pillar 2, "the state is a character": the state only ever answers at a boundary, after the paper has been filed, so its arrival reads as a reply, never an ambush, and it comes through the next threshold, never into the middle of the reading. Pillar 4, "consequences cross lives": the reveal is the one place the game shows that a choice in this room has reached someone else's file; a change in one dossier is noticed here and paid off in another protagonist's chapter. Pillar 3, "no one is clean": the reveal shows *which files changed*, never a verdict on whether that was right.

**The one rule this system must obey: a scene's consequences land once, all together, at its end, and the player is shown which files changed before anything else happens.** Every effect the player stages in a room (an answer, an action, the filing) waits for the boundary. The room reacts to held facts and to the file as it stood when the player walked in, never to what they have just staged. At the boundary everything runs in a fixed order that nothing can reorder: the decision, the state's answer, the phase and attention, then the reveal. Then comes at most one inserted scene, then the tear-off if the day has turned, then the next room. Scene Flow never reads a wall clock and never changes a room while the player is idle. The same intents always produce the same boundaries, in the same order, so the story simulator replays what the player felt, page for page.

*Cost accepted:* the room cannot react within a scene to what the player has just done to the file. A cruel answer in conversation shows nothing until the door, and a filing has no effect in the room where it was signed; writers write every in-room reaction against held facts or the file as it stood when the player walked in, and the payoff for the act itself waits for the next room. An inserted scene closes no boundary of its own, so what is said in it is revealed one scene late, at the end of the next authored scene. Two firings at one boundary never become two scenes: one insert plays and the other comes as a line of paper in the reveal, so the state sometimes answers quietly when the plot would like it loud. And because the only save point is the boundary, quitting mid-scene returns the player to the room's start with nothing staged.

## Detailed Design

### Core Rules

*Drafted with the systems designer (primary), the gameplay programmer (feasibility) and the engine programmer (engine integration); rulings where they differed are stated in place. Engine facts are quoted only from the pinned reference, which has no `core.md`: nothing on `RefCounted`, signals on non-Nodes, `Callable` or `await` is sourced, and this design leans on none of them (Rule 16). Items marked **(PROV)** rest on a GDD not yet written (Paper UI 13, Dialogue & Interrogation 11, Filing & Decision 12, Chapter & Story Structure 14, Save/Load, Audio 16). The amendments to GDDs 1, 2, 3, 5, 6 and 7 that this section needed are applied there and named where they bite; the MVP chapter is GDD 7's MVP fixture (`v_office`, `v_cal_weekend`, `v_turn`, `v_person`, a calendar beat over the weekend), while the act file keeps `v_night` in its place.*

**0. Vocabulary.** The *cursor* is the only state Scene Flow owns: which act, chapter and scene are in progress, and whether an insert is pending. An *authored scene* is a scene row of `kind: authored` or `kind: calendar` in a chapter's scene list; each closes exactly one boundary and spends exactly one beat (GDD 7 Core Rule 2). An *insert scene* is a scene row of `kind: insert`, played by a fired rule between two authored boundaries and closing none. The *boundary* is GDD 1's bracket `begin_boundary … end_boundary` wrapped in the Calendar's, run by this system in the fixed order of Rule 8. The *staging batch* is the list of effect records produced inside a scene (decision options, dialogue answers, action effects) that has not yet been applied; it lands once, at the boundary, as GDD 1's decision batch. An *exit hotspot* is a `threshold` hotspot named in the sidecar's `exits[]` (GDD 3 Rule 1); activating one is the only way an authored scene ends. The *route* is the `exits[]` entry that wins (GDD 2 Rule 5, Scene Flow the semantics owner). A *firing* is one entry of `RulesResult.fired[]` (GDD 6 Rule 9). The *sink* is `PresentationSink`, the one seam through which Scene Flow shows anything (Rule 13). The *reveal* is the step at which the boundary's change records are shown ("the scene ends by showing which dossiers changed", game concept). The *save point* is the one moment at which Save/Load may serialise (Rule 14).

---

**1. Scene Flow is an orchestrator that calls and returns; it owns no state but the cursor.** `SceneFlow.new(host, dossier, content_store, rules, calendar, facts, dialogue, filing, presentation, choices, debug)` is constructed by the main scene (GDD 3 Rule 8: no autoload) with every collaborator injected and a null twin for each: `NullSceneHost` (GDD 3), the dossier model itself in tests (it is already headless, GDD 1 Rule 11), `ContentStore` loaded from the compiled files (GDD 2 Rule 9), the rules evaluator (GDD 6), the Calendar (GDD 7), `FactSystem` (GDD 5), `NullDialogueRunner` and `NullFilingRunner` **(PROV)**, `NullPresentationSink` (Rule 13), a `ChoiceSource` (GDD 6 Rule 11; the policy-only source in release) and a `DebugSink` (GDD 6 Rule 14's shape, shared). Scene Flow holds no dossier field, no held fact, no calendar value, no rule state and no string; it reads them through the systems that own them and hands the results on. Its persistent state is the cursor of Rule 14 and nothing else. The composed `ConditionReader` (GDD 5 Rule 6) is built here once, in `new()`, from `{dossier.read, calendar.read for target calendar, facts.has, calendar.phase, leaf → false}`, because GDD 7 Core Rule 7 makes the routing of target `calendar` a requirement on this system's reader assembly; it is *bound* to a chapter at chapter open (Rule 2), which is this draft's reading of GDD 5's "built at chapter open" (Conflicts, item 9).
*Rationale:* the one system that sequences every other must be the easiest to run headless, and the simulator's whole argument (GDD 6 Rule 11, GDD 3 Rule 14) is that `NullSceneHost → Scene Flow → the evaluator` is the same code as the shipped game with the engine host swapped out. A system that owned state would need a second serialisation and a second twin.
*Rejected:* Scene Flow as an autoload with signals the other systems subscribe to (unreplayable; GDD 6 Rule 9 and GDD 7 Rule 4 both rejected signals for the same reason, and a `signal` on a non-Node is NOT SOURCEABLE in the pinned reference anyway).

---

**2. The act and chapter run: Chapter & Story Structure owns the plan's shape; Scene Flow executes it.** `run_act(plan)` takes an `ActPlan {act, play_order[], chapters{chapter_id → chapter (GDD 2's object)}, act_close: [scene ids], ending_table}` from Chapter & Story Structure **(PROV)** and drives it in this order and no other:

1. For each `chapter_id` in `play_order`:
   a. `presentation.chapter_card(chapter_id, chapter.title, chapter.opening[])` — the cold card (GDD 7 Rule 4: chapter open has no transition); Scene Flow waits for `on_continue()` (Rule 13).
   b. `calendar.open_chapter(chapter_id)` — resets the last-served date (GDD 7 Rule 1).
   c. `dossier.chapter_open(chapter_id, chapter.reads, chapter.writes, chapter.assumes)` — applies the assumptions; resets the beat counter if this is the first chapter of `play_order` (GDD 1 Rule 4a).
   d. `reader.bind(chapter_id)`; `writer = DossierWriter.new(self, chapter_id)` — the staging facade (Rule 5) handed to `dialogue` and `filing` for the chapter.
   e. `enter(chapter.entry_scene)` (Rule 3), and then the scene loop of Rules 3–12 until a boundary's route is `chapter_end`.
   f. After that boundary's reveal closes: `facts.chapter_close()` (wipes the held set, GDD 5 Rule 1), `dossier.chapter_close()` (wipes the sheet, GDD 1 Rule 2), `writer` discarded. No insert plays at a `chapter_end` boundary (Rule 10).
2. The act close: `presentation.chapter_card(<act>_close, …)` **(PROV: Chapter & Story Structure decides what the pseudo-chapter's card is, if anything)**; `calendar.open_chapter(<act>_close)`; `dossier.chapter_open(<act>_close, [], [], [])` (GDD 7 Edge Case 5); then each id in `plan.act_close` runs as a calendar scene (Rule 12) with `ctx.chapter_id = <act>_close`; the archive batch (writer `chapter`, supplied by Chapter & Story Structure as `plan.archive_batch`) is applied inside the **last** act-close boundary after the rules step (Rule 8 step 9; Conflicts, item 3); `dossier.chapter_close()`.
3. `ending = dossier.select_ending(plan.ending_table)` (GDD 1 Formulas §5, `ending_select`); `presentation.epilogue(ending, content_store.epilogue(ending))`; wait for `on_continue()`; `run_act` returns `{ending, boundaries_run}` to the caller.

Scene order inside a chapter is never chosen here: it is the route of each scene's `exits[]` (Rule 7). Chapter order is never chosen here: it is `play_order`. A chapter opened out of `play_order` (a debug jump) runs anyway and the Calendar logs it (GDD 7 Edge Case 22).
*Rationale:* GDD 1's Interactions row gives Chapter & Story Structure `chapter_open/close`, `archive`, `release` and the ending table, and GDD 7's gives it `play_order` and the act-close placement; those are plan facts. Executing the plan in one fixed procedure is what lets every GDD say "Scene Flow owns the order" and mean one thing.
*Rejected:* Chapter & Story Structure as a second orchestrator calling Scene Flow per chapter (two call stacks that must agree on where the bracket is; the act-close beats, which belong to no chapter, would have no home).

---

**3. The scene: `enter(scene_id)`.** The preload was issued at the previous reveal (Rule 8 step 12), so `enter` is the activation:

1. `scene = content_store.scene(chapter_id, scene_id)`; if `scene.kind == calendar`, Rule 12 applies instead and nothing below runs.
2. `transition = calendar.transition_between(prev_authored_id, scene_id)` when `prev_authored_id` exists in this chapter (never across a chapter edge, never with an insert as either argument; GDD 7 Rule 4, Edge Cases 2 and 20); `kind: day` → `presentation.transition(transition)` and wait for `on_continue()`; `kind: slot` → `presentation.transition(transition)` with no wait (a plate light, Overlay's, GDD 7 Visual/Audio §5); `kind: none` → nothing.
3. Derive availability for every id in `host.hotspot_ids(scene_id)` (Rule 6) and call `host.set_hotspot_state(id, availability)` for each, before activation (GDD 3 Interactions: "`set_hotspot_state` before activation").
4. `host.push_input_block("enter:<scene_id>")`; `host.activate_scene(scene_id, wipe)` with `wipe = true` for an authored scene following another plate and `wipe = false` for an insert (Rule 11) and for the first scene after a chapter card or a transition screen (the card or the calendar is the busy signal there; a wipe from paper to paper is a double transition).
5. On `on_scene_ready(scene_id)`: `host.set_focus(entry_focus)` where `entry_focus` is the first id in the sidecar's `focus_order` whose availability is not `hidden` — deterministic, the same for every player, the GDD 3 Rule 4 rule for KEY users applies on top (focus none for POINTER); then `host.pop_input_block("enter:<scene_id>")`. The room is now `active`.
6. `cursor.scene_id = scene_id`; `cursor.pending_insert = null`; the scene's `decided` set (Rule 4) is empty.

*Rationale:* every call here is one GDD 3 already promised in this order; the one choice this system makes, entry focus, is made from the sidecar's own ring so that a screen-reader user lands on the same object every time (GDD 3 Rule 4, "a screen-reader user needs a landing point").
*Rejected:* entry focus on the hero or on the "most important" hotspot (a per-scene authored field, one more thing to lint, and the hero has no ring privilege by GDD 3 Rule 4).

---

**4. In the scene: a hotspot event is dispatched through the scene's action table, and nothing else happens in a room.** On `on_hotspot_activated(id)` (the host's signal; GDD 3 Rule 8):

1. If `id` is an exit hotspot: the scene ends (Rule 7). An exit hotspot carries no content action (lint SF-E7, Rule 7), so there is nothing else it could mean.
2. Otherwise find the actions of this scene whose `hotspot == id` and whose `when` evaluates true through the reader (pre-boundary dossier state plus held facts, Rule 5), in authored order; take the first. GDD 5 Rule 4 guarantees that a hotspot with any `has_fact`-gated action has a sibling free of `has_fact`, so the gate selects *which* action, never whether one exists.
3. Dispatch by the action's one payload:
   - `document` → `holdable = facts.open(document_id)` (GDD 5 Rule 6; the one place the dossier is read for a document, through the bind); `presentation.open_document(document_id, holdable)`; Paper UI opens the sheet and pushes its own block **(PROV)**. `facts.hold` and `facts.pair` are Paper UI's calls on the player's `activate` on a span, not this system's.
   - `dialogue` → `facts.open_dialogue(dialogue_id)`; `dialogue.run(dialogue_id, reader, writer)` **(PROV)**: Dialogue drives its transcript sheet, holds `yields` through `facts.hold`, stages every chosen answer's `effects[]` through `writer` (Rule 5) and calls `on_dialogue_end(dialogue_id)` at `end`.
   - `decision` → if `decision_id ∈ decided`, fall through to the slip (step 4: a decision is made once per scene; the spent hotspot re-activates to its examine slip); else `filing.run(decision_id, reader, writer)` **(PROV)**: Filing shows the options whose `when` holds (hidden, never greyed, GDD 2 Rule 5c's rule for answers applied to options), stages the chosen option's `effects[]` and calls `on_decision_made(decision_id, option_id)`; Scene Flow adds `decision_id` to `decided`.
   - `effects[]` → `writer.submit(effects)` directly (the action's own effects, writer `filing` by GDD 2 Rule 7's derivation); then the slip, so the player sees the room answer (`presentation` is not called; the host's examine path draws the typed bracket).
4. No applicable action (a `person` whose only dialogue is gated off, a `phone` with nothing to say, a spent decision): Scene Flow calls `host`'s examine path by re-dispatching as `on_hotspot_examined(id)`; nothing is staged, nothing is logged, and lint SF-W2 warns at build time on a `person` or `phone` hotspot whose actions can all be false under some state (GDD 2 V06b's satisfiability check, reused).

On `on_hotspot_examined(id)`: nothing; Paper UI draws the slip from the host's event (GDD 3 Rule 6). Scene Flow never reacts to focus, hover, dwell, the reveal hold or the camera. The room is `suspended` whenever any sheet is open (the host's block count is above zero, GDD 3 Rule 13); Scene Flow owns no clock and runs nothing while a scene is `active` (GDD 3 Rule 13: no Scene Flow clock exists; a timed choice is Dialogue's sheet, and the room is suspended under it).
*Rationale:* GDD 2 fixes an action as "one of `effects[]`, `dialogue`, `decision`, `document`"; dispatching on exactly that, with the owning system called by name, keeps the brief's line that Scene Flow never decides what a hotspot yields, what a filing costs or what a line says.
*Rejected:* Scene Flow opening sheets itself and reading the player's choices back from Paper UI (Paper UI would own a piece of the game's logic; the simulator would need a Paper UI twin).

---

**5. Staging: one decision batch per boundary; in-scene gating reads held facts and the pre-boundary dossier, never a staged effect.** `DossierWriter` is the facade GDD 1 Rule 4a says every writer holds; in this game it is a *staging* facade: `submit(batch)` validates each record's `source` parses to the open chapter (GDD 1 Edge Case 18's check, made early) and appends it to the cursor's `staged[]`; nothing reaches `dossier.apply` until Rule 8 step 5, where `staged[]` is applied **once**, in staging order, as GDD 1's decision batch (writers `filing`, `dialogue`). Within a scene every condition — an answer's `when`, an option's `when`, an action's `when`, a document line's bind — is evaluated against the dossier *as it was when the scene was entered* plus the chapter sheet as it was, plus the held set *as it is now*. There is no overlay of staged effects on reads, and there is no in-scene boundary.

What this costs the writers, stated so they decide with eyes open: a scene cannot gate a later line on a write the same scene made. Lint **SF-W1** warns when a scene's `when` (any action, option, answer or exit of that scene; exits are exempt because they are read after the boundary, Rule 7) names a field that an effect in the same scene writes ("read-after-write in one scene: this gate will never see this write"); the writer's fix is the next scene, which is where the state has read it. GDD 2's own rule already says the same thing from the other side: "content is gated by state, never by history" (Rule 6), and GDD 2's States say an answer's effects are "batched for the scene boundary".
*Rationale (what GDD 1 and GDD 2 say):* GDD 1 Rule 4a makes a boundary atomic precisely so that "effects land once, in one place, in one order"; reads inside the bracket see applied batches *for the cascade*, and a scene is not inside the bracket. GDD 6 Rule 3 forbids evaluating rules mid-scene so that "the state would [not] react inside a scene it has not yet seen"; an overlay would give the *player* a state the rules have not seen, so the room would be ahead of the file, which is the one thing the game's fiction forbids (Pillar 1: a fact is a weapon because the state has it on paper, and the paper is written at the boundary). The simulator's grain is one state per beat (GDD 6 Rule 7); an in-scene overlay is a state the solver cannot name. Held facts are immediate because GDD 5 says so and because they are the player's, not the state's.
*Rejected:* an overlay of staged effects on reads (above); a per-decision mini-boundary (two beats for one scene, every window in GDD 6 would mean something else); gating from held facts only with no dossier reads in-scene (a document's bind is a dossier read by GDD 5 Rule 2, and the Files view must print what the state has).

---

**6. Availability is derived at entry, and after a load by the same function; one synchronous path changes it in a scene.** For every hotspot `h` of the scene (ids from `host.hotspot_ids`, kinds from the sidecar vocabulary `scene_vocab.json`, which the content store carries for the lint and Scene Flow reads at load):

```
availability(h) =
  hidden   never at MVP (no content field produces it; reserved)
  void     iff kind(h) ∈ {paper, object}
           and every action a with a.hotspot == h and no has_fact leaf in a.when
               has a.when false under the reader at entry
           (an action with no when is true; a hotspot with no actions is never void)
  filed    iff not void and ∃ action a with a.hotspot == h, a.document == d,
               d ∈ facts.filed_documents()
  unfiled  otherwise
```

| Symbol | Type | Range | Description |
|---|---|---|---|
| `kind(h)` | enum | `paper, object, door, phone, person` | the sidecar's hotspot kind (GDD 3 Rule 1) |
| `a.when` | condition | GDD 2 Rule 6 grammar | evaluated through the chapter's `ConditionReader` at entry |
| `facts.filed_documents()` | set of ids | 0..documents in chapter | GDD 5 Rule 6; "at least one fact held from it" |
| `availability(h)` | enum | `unfiled, filed, void, hidden` | GDD 3 Rule 5's axis |

Output is total (every hotspot gets exactly one value); `void` and `filed` are exclusive by construction (void is tested first), so a document struck off by the dossier reads as removed even if the player held a fact from it earlier, which is GDD 5 Edge Case 2's "the fact stays held, the line prints struck". `void` reads only `has_fact`-free actions, so **`void` is a function of the pre-boundary dossier alone and cannot change inside a scene**; `filed` moves one way, `unfiled → filed`, by the single synchronous path: `on_document_filed(document_id)` (GDD 5 Rule 6's signal, emitted under the open document sheet's block) → `host.set_hotspot_state(hotspot_of(document_id), filed)`. That path runs under a block, which GDD 3 Rule 5 permits; nothing else in this system calls `set_hotspot_state` after `scene_ready`, so GDD 3 Edge Case 14's "a Scene Flow defect" cannot be reached from here. After a load the cursor names the scene about to be entered (Rule 14), so `enter` runs the same derivation with `facts.filed_documents()` already restored; there is no second path. `worked example` (Vera's office at entry, GDD 5 Rule 12): six `paper` hotspots; the carbon-box sheet's only action is bound through its document's line to `vera.discrepancy`, but its `action.when` is absent, so it is `unfiled` (the *line* is gated by GDD 5's bind, not the hotspot); on a fresh chapter `filed_documents()` is empty, so all six are `unfiled`; a save restored after the player held `serial_4471` from folder 4471 re-derives that one hotspot `filed`.
*Rationale:* GDD 3 Rule 5 forbids the framework deriving availability and forbids changes on idle or a clock; GDD 5 Rule 4 forbids a fact changing whether a hotspot exists. Deriving `void` from `has_fact`-free actions only is the one definition that satisfies both and is a pure function of state the simulator can assert.
*Rejected:* `void` from all actions including fact-gated ones (a held fact would un-void a hotspot from the board, GDD 5 Rule 4's forbidden case); `filed` on open (GDD 5 Rule 6a rejected it); deriving availability lazily on first focus (an availability that depends on the player's cursor path is not deterministic).

---

**7. A scene ends on an exit hotspot and nothing else; the route is read after the boundary; `exits[]` is linted.** The scene ends when `on_hotspot_activated(id)` names an exit hotspot (Rule 4 step 1). A decision does not end a scene; a dialogue's `end` does not end a scene; an insert ends on its dialogue's `end` (Rule 11) because it has no exits. The player may read, hold and pair after deciding; nothing in the room changes (Rule 5), so there is nothing to exploit, and the walk to the door is where "the scene ends by showing which dossiers changed" happens.

The route is resolved at Rule 8 step 10, after `end_boundary` and after the Calendar's bracket closes: `route(scene.exits, reader) = first e in authored order with e.when absent or true` → `e.to` (a scene id of this chapter) or `chapter_end`. The reads are content reads already in `R_c` (GDD 2 V18–V20 count `exits[].when`), served post-boundary, which is why GDD 3 can promise `preload_scene` "after the rules step and before the reveal" with the next id known. A `has_fact` leaf in an exit's `when` may choose where a present door leads, never whether it works (GDD 5 Rule 4, Edge Case 23; this is the reciprocal lint). Which door: at MVP every exit hotspot of a scene resolves the same `exits[]` list; an optional `exits[].via: <hotspot id>` (amendment to GDD 2, GDD 2 Rule 5 amendment) lets a two-door scene route by door, and an entry without `via` matches any exit hotspot.

Lint rules on `exits[]`, run by GDD 2's validator with this system as semantics owner (severity as GDD 2 Rule 15; `E` fails the build):

| # | Check | Sev |
|---|---|---|
| SF-E1 | Every scene of kind `authored` or `calendar` has a non-empty `exits[]`; the last entry has no `when` (GDD 2 V05 restated from this side) | E |
| SF-E2 | Every `to` names a scene of kind `authored` or `calendar` **in the same chapter**; never an insert, never the scene itself, never another chapter's scene | E |
| SF-E3 | An exit `when` containing `has_fact` has a sibling entry (any position) with no `has_fact` leaf (GDD 5 Edge Case 23) | E |
| SF-E4 | The exit graph from `entry_scene` is acyclic, every scene of kind `authored`/`calendar` is reachable from `entry_scene`, and every path from `entry_scene` to `chapter_end` crosses the **same number** of scenes, `chapter.beats` (see the invariant below) | E |
| SF-E5 | `exits[].via`, when present, names a `threshold` hotspot of the scene's sidecar that is in the sidecar's `exits[]` | E |
| SF-E6 | A scene of kind `calendar` has `exits[]` and nothing else: no `location`, `actions[]`, `documents[]`, `dialogues[]` | E |
| SF-E7 | A sidecar exit hotspot carries no content action (cross-check in `tools/`, beside GDD 3's X01) | E |
| SF-W1 | Same-scene read-after-write (Rule 5) | W |
| SF-W2 | A `person`/`phone` hotspot whose actions can all be false under some state | W |
| SF-W3 | More than one `decision` action in one scene, or a `decision` and a dialogue with effectful answers in one scene (GDD 6 Rule 7 amendment: the solver's beat is one player action) | W |

The path-length invariant, which the Calendar's beat spans and GDD 6's windows both assume:

`path_len(p) = |{s ∈ p : kind(s) ∈ {authored, calendar}}|` and `∀ p, q ∈ paths(entry_scene → chapter_end): path_len(p) = path_len(q) = chapter.beats`

| Symbol | Type | Range | Description |
|---|---|---|---|
| `p`, `q` | path | — | a sequence of scenes following `exits[].to` from `entry_scene` to an entry whose `to` is `chapter_end` |
| `kind(s)` | enum | `authored, calendar, insert` | the scene row's kind; inserts are never on a path (SF-E2) |
| `chapter.beats` | int | 1..`BEATS_PER_ACT` | the chapter's beat span length (act one: Vera 4, Jan 4, Tomas 4; GDD 7 Rule 3) |
| `path_len(p)` | int | ≥ 1 | boundaries the path closes |

Output: bounded by `BEATS_PER_ACT` (12, registry); the sum over `play_order` of `chapter.beats` plus `HORIZON_SLACK` (2) must equal `HORIZON_ACT` (14), checked once per act by the same lint (SF-E4b). *Worked example:* Vera's chapter `v_office → v_night → v_turn → v_person → chapter_end` has one path of length 4; a turn scene with three conditional exits to three "person" scenes that each exit to `chapter_end` still has every path at length 4; a turn scene with one exit that skips the person scene would have paths of 4 and 3 and fails SF-E4 naming both.
*Rationale:* the brief's beat spans (Vera 1–4, Jan 5–8, Tomas 9–12, close 13–14) are what every window in the act rules file is authored against; a chapter whose length depends on the route would move the review's window and `breath_is_a_clock`'s answer per telling. Reading the route after the boundary is what makes the exit the first honest read of the state the player just wrote.
*Rejected:* a scene ending on its decision (the room could never show the player what the decision did before the reveal, and a keyboard user would be yanked from the sheet to the wipe); `exits[]` evaluated at the moment of activation against pre-boundary state (a turn scene's route could never depend on its own turn; and GDD 3's preload timing would have the next id a step too early for nothing); variable-length chapters with windows re-based per telling (the solver would need the route in the domain).

---

**8. The boundary, in order, with every call named.** Triggered by Rule 7 (an exit hotspot) or by Rule 12 (a calendar scene, where steps 1–2 are the scene itself). Nothing in this procedure yields to input between steps 3 and 13; the host's block count is above zero throughout.

```
exit(scene_id):
 1. host.push_input_block("boundary:<scene_id>")           # the room is suspended; the reveal sheet will add its own
 2. date  = calendar.date_for(chapter_id, scene_id)          # {day, slot}; stale-served if the row is missing (GDD 7 EC 4)
    ctx   = { beat: dossier.beat() + 1, scene_id, chapter_id,
              day: date.day, slot: date.slot,
              day_high: calendar.day_high(), step: "decision" }
            # beat is the post-increment value GDD 1 Rule 4a and GDD 7 Rule 1 both name;
            # dossier.beat() is a non-mutating read (GDD 1 Rule 4a amendment)
    apply = CompositeApply.new(dossier, calendar, ctx)        # Rule 9; built once per boundary, before any bracket opens
 3. calendar.begin_boundary(ctx)                             # outer bracket (GDD 7 Rule 1)
 4. dossier.begin_boundary(scene_id, ctx.day)                # inner bracket (GDD 1 Rule 4a)
 5. dossier.apply(cursor.staged)                             # the decision batch, once, staging order; writers filing/dialogue
    cursor.staged = []                                       # (for a calendar scene: apply([]))
 6. ctx.step = "rules"
    result = rules.run_boundary(ctx, apply, choices)         # GDD 6 Rule 5: drift, candidates, policy, fire, cascade;
                                                             # every rules batch goes through `apply` (Rule 9)
 7. (debug) rules' incompatibles were asserted inside run_boundary through the shared DebugSink
 8. ctx.step = "phase_attention"
 9. if scene_id is the act's last act-close id: dossier.apply(plan.archive_batch)   # writer chapter; GDD 1 Rule 4a amendment
10. records   = dossier.end_boundary()                       # increments the beat; dossier change records in application order
    calendar.end_boundary()                                  # closes the outer bracket
    snapshot  = calendar.snapshot(ctx)                       # BoundaryView, memoised by beat (GDD 7 Rule 9)
    route     = route(scene.exits, reader)                   # Rule 7: post-boundary reads; scene id or chapter_end
    staging   = stage_firings(result.fired, chapter_id, route)   # Rule 10: {insert: scene_id|null, paper[], degraded[]}
    cursor.pending_insert = staging.insert
11. next_to_load = staging.insert ?? (route == chapter_end ? null : route)
    if next_to_load and content_store.scene(chapter_id, next_to_load).kind != calendar:
        host.preload_scene(next_to_load)                     # GDD 3 Rule 7: after rules, before the reveal; the reveal hides the load
12. ctx.step = "reveal"
    paper = [ f for f in staging.paper if paper_visible(f, protagonist(chapter_id)) ]   # Rule 10
    counts = host.hotspot_counts(scene_id)                   # GDD 3 Rule 6's read count, for the dossier sheet
    for f in staging.paper: presentation.rule_fired(f.class, "paper")   # Audio: the paper is in the frame now (GDD 6 VA §7)
    presentation.reveal(records, snapshot, paper, counts)    # Paper UI, Overlay, Audio read this one call (Rule 13)
13. wait on_continue()                                       # the player closes the reveal; this is the save point (Rule 14)
    host.pop_input_block("boundary:<scene_id>")
14. trace_line = BoundaryRecord{ctx, decision_batch, result, records, route, staging, snapshot_digest}   # Rule 15; returned, never written
15. if staging.insert: play_insert(staging.insert)           # Rule 11; cut, no transition, no boundary
    elif route == chapter_end: close the chapter (Rule 2.1f)
    else: enter(route)                                       # Rule 3: the transition, if any, plays here
```

Reads during steps 4–10 see pre-boundary state plus the batches applied so far (GDD 1 Rule 4a; GDD 7 Rule 7), which is what the cascade and `phase_at_least` need (GDD 7 Edge Case 11). `ctx.step` takes exactly GDD 7's four values in this order; `snapshot` is asked for only at step 10 after both brackets close, so GDD 7 Edge Case 16's `SNAPSHOT_EARLY` is unreachable from this procedure. `day_high` is read from the Calendar at step 2 so that `rules`-written records carry the receipt day (GDD 1 Rule 5, GDD 7 Rule 1); a scene whose `day` exceeds the old `day_high` raises it inside `calendar.begin_boundary` (the Calendar's store state, GDD 7 Rule 11), so a rules record at this boundary is dated no earlier than the page the player just read.
*Rationale:* GDD 1 (decision → effects → rules → phase and attention → reveal), GDD 6 (`run_boundary` after the decision batch and before phase/attention/reveal), GDD 7 (`begin_boundary(ctx)`/`end_boundary()` in the dossier's order; the snapshot at the phase-and-attention step) and GDD 3 (`preload_scene` after rules, before the reveal) each fix two or three adjacent steps; this is the one total order that satisfies all four, with the Calendar's bracket outermost so its store is closed and `day_high` final before the snapshot reads the aggregates.
*Rejected:* the dossier's bracket outermost (the Calendar would be asked to snapshot while the dossier is still open and the aggregates could move); resolving the route before the bracket (Rule 7); preloading at activation of the exit hotspot (the route is unknown; GDD 3's two-scene ceiling forbids preloading candidates).

---

**9. The composite apply and the boundary context are built by Scene Flow, once per boundary.** `CompositeApply.apply(batch) → [change]`: partition `batch` by `target`; records with `target == calendar` go to `calendar.apply_calendar(sub, ctx)` (writer must parse to `rules`, `migrate` or `sim`, GDD 7 Edge Case 6; anything else is the Calendar's to drop and log), the rest to `dossier.apply(sub)`; the return is the dossier's records followed by the Calendar's, each store's in its own application order. The two stores share no field, so no consumer depends on the interleaving; the Rules evaluator appends the returned list to its boundary-local change list (GDD 6 Rule 4), which is how `{changed: calendar.breath_marta}` becomes a legal leaf at the next cascade step (GDD 7 Rule 6). The composite accumulates every Calendar record it routed into `calendar_records[]` for the trace; **Calendar records are not handed to the reveal** (their `projections` are `[]`, GDD 7 Rule 6, and GDD 7 Visual/Audio §6 forbids a clock reaching the screen), and `RulesResult.calendar_effects[]` remains Rules' own trace of the same routing. The composite is also the object the decision batch does *not* go through: step 5 calls `dossier.apply` directly, because the content validator already rejects a `calendar` target in any content effect (GDD 7 Edge Case 6) and a direct call keeps the stale-batch check (GDD 1 Edge Case 18) at one site.
`ctx` is plain data assembled at step 2 and never mutated except its `step` field; it carries `{beat, scene_id, chapter_id, day, slot, day_high, step}` exactly as GDD 7 Rule 1 lists, and Rules reads `chapter_id`/`scene_id` from it for `source: rules:<chapter>/<scene>:<id>` (GDD 6 Rule 9). An insert scene never has a `ctx` because it never has a boundary (Rule 11).
*Rationale:* GDD 7 Rule 5 and GDD 6 Rule 5.4 both say the composite is "the apply Scene Flow injects"; building it per boundary with the `ctx` closed over is what lets the Calendar stamp the beat on its records without a counter of its own (GDD 7 Rule 1).
*Rejected:* the dossier routing `calendar.*` itself (GDD 1 Rule 1a and GDD 7 Rule 5 both forbid it); one apply for the whole boundary including the decision batch (loses the single stale-batch site; invites a content effect on `calendar.*` reaching the Calendar).

---

**10. Firings become one insert and the rest paper; the presentation rule is a procedure.** `stage_firings(fired, chapter_id, route)` walks `fired[]` in the order Rules returned it (selection order, GDD 6 Rule 5.4) and resolves each by `class` and the rule's `beat` field and nothing else (GDD 6 Rule 9: `licence`, `source`, `rule_id`, `agent` are trace fields, never bound):

```
insert  = null; paper = []; degraded = []
for f in fired (in order):
    b = content_store.beat(f.class)                       # GDD 2's beat object; exists by V22
    match f.beat:
      "none"   -> continue                                 # bookkeeping; nothing is placed (GDD 6 Rule 2)
      "paper"  -> paper.append({class: f.class, beat: b, changes: f.changes})
      "insert" ->
          s = insert_scene_for(chapter_id, f.class)        # the open chapter's scene row with kind: insert and this class
          if insert == null and s != null and route != chapter_end and chapter_id is not <act>_close:
              insert = s.id; insert_firing = f
          else:
              paper.append({class: f.class, beat: b, changes: f.changes}); degraded.append(f.rule_id)
return {insert, insert_firing, paper, degraded}
```

| Symbol | Type | Range | Description |
|---|---|---|---|
| `fired` | list | 0..`RULES_PER_BOUNDARY_MAX` + world moves + drift | `RulesResult.fired[]` in selection order |
| `f.beat` | enum | `insert, paper, none` | the rule row's `beat` (GDD 6 Rule 2) |
| `insert_scene_for` | function | scene id or null | the open chapter's `kind: insert` row whose `class == f.class`; at most one per class per chapter (lint SF-E8) |
| `route` | id or `chapter_end` | — | Rule 7's result |
| `insert` | id or null | 0..1 | the one insert queued at this boundary |
| `paper` | list | 0..|fired| | handed to the reveal, filtered by `paper_visible` |
| `degraded` | list of rule ids | 0..|fired| | inserts that became paper; a trace field and a simulator report line ("second person at one boundary became paper") |

Output: at most one insert per boundary, always (GDD 6 Visual/Audio §3: "never two inserts at one boundary"); a second `insert` firing becomes its beat's `paper` line, which exists for every class (GDD 2 V23), so nothing fired is lost. An `insert` firing at a boundary whose route is `chapter_end`, or at an act-close beat, or in a chapter with no insert row for the class, degrades the same way: the state writes instead of visiting. A truncated cascade changes nothing here because only `fired[]` is read (GDD 6 Visual/Audio §3: "a truncated cascade shows nothing extra"). `paper_visible(f, protagonist)` is `protagonist == null` (the act close: the player reads the closing bell, not a protagonist) or `∃ c ∈ f.changes : view(protagonist) ∈ c.projections` with `view = {vera: files, jan: signs, tomas: orders}`; it is the one place this system reads a change record's `projections`, and it implements GDD 6 Visual/Audio §1's "a `paper` beat the protagonist never sees renders nowhere in that chapter" **(PROV: Paper UI to confirm the filter lives here and not in its renderer)**. `presentation.rule_fired(class, "paper")` is emitted at the reveal (Rule 8 step 12) and `rule_fired(class, "insert")` at the insert's `scene_ready` (Rule 11), never at firing time, so Audio never hears the state before the paper or the person is in the frame (GDD 6 Visual/Audio §7). *Worked example (GDD 6 Rule 13):* at `v_turn`'s boundary R1 `query_ledger` (`insert`) fires at step 0 and B1 is a candidate but Berta's `delay: 1` holds it; `fired = [R1]`, `insert_scene_for(a1_vera, query_ledger) = rybar_query_ledger`, `route = v_person`, so `insert = rybar_query_ledger`, `paper = []`. Were B1 to fire at the same boundary with `beat: insert` too, it would be second in selection order (priority 70 vs Berta's), degrade to its paper line (the memo) and appear in the reveal after the call.
*Rationale:* GDD 6 says the presentation rule is Scene Flow's and that "no rule data is written to arrange it"; a pure function over `fired[]` and the open chapter's content is the smallest implementation and the one the simulator can diff.
*Rejected:* queueing the second insert for the next boundary (a reaction delayed by presentation, which GDD 6 Rule 5 forbids: "a losing candidate is dropped, not queued" is the evaluator's rule and this would re-create a queue one layer up); a global `beats` table `class → insert scene id` (Rybar's telephone call exists only in Vera's room; a per-chapter row is what makes "no room for this person here" a content fact, GDD 2 Rule 5 amendment).

---

**11. An insert scene plays through the same host, closes no boundary, and its effects ride the next authored boundary.** Content (amendment to GDD 2, GDD 2 Rule 5 amendment): an insert is a scene row in the chapter's `scenes[]` with `kind: insert`, `class` (the rule class it answers; at most one row per class per chapter, lint SF-E8), `location`, `register`, exactly one `dialogues[]` entry (its entry dialogue), optional `documents[]` the dialogue's answers may open, no `actions[]` beyond the dialogue's own, no `exits[]` and no timetable row (GDD 7 Edge Case 20). Its sidecar has a `threshold` hotspot through which the person enters (GDD 6 Visual/Audio §1).

`play_insert(scene_id)`:
1. Availability for its hotspots is derived as in Rule 6 (the room is the same room; filed ghosts stay filed).
2. `host.push_input_block("insert:<scene_id>")`; `host.activate_scene(scene_id, wipe = false)` — a **cut**, the floor goes (art bible §2.1 "replaced abruptly"); no transition is asked for (GDD 7 Rule 2); the previous authored scene unloads after `scene_exited` as usual, which frees the second residency slot.
3. On `on_scene_ready`: `presentation.rule_fired(insert_firing.class, "insert")` (the figure is on the threshold line now, GDD 6 VA §7); `host.set_focus(threshold)`; `host.preload_scene(route)` for the pending authored scene when it is not a calendar scene (GDD 3 Rule 7's ceiling is respected: the insert and the next authored scene are the two residents); `facts.open_dialogue(entry_dialogue)`; `dialogue.run(entry_dialogue, reader, writer)` — the conversation starts without a click; the room stays blocked under the transcript sheet for the insert's whole life.
4. The dialogue's answers stage their `effects[]` through `writer` as any dialogue does (writer `dialogue`, `source: dialogue:<chapter>/<insert scene id>:<dialogue>_<ask>_<answer>`; GDD 1's parser accepts it, the chapter matches, so the stale-batch check passes); its `yields` are held (same chapter). They land as part of the **next authored boundary's** decision batch (GDD 7 Rule 2), which is why an insert is never queued at a `chapter_end` boundary (Rule 10): there would be no next boundary in the chapter to carry them.
5. On `on_dialogue_end`: `host.pop_input_block("insert:<scene_id>")`; `cursor.pending_insert = null`; `enter(route)` (Rule 3; the transition between the two *authored* scenes plays now, computed as if the insert were not there, GDD 7 Edge Case 20).

An insert inherits the firing boundary's `day`/`slot` for everything that asks (the HUD date stamp still shows the snapshot already in force; GDD 7 Visual/Audio §1 and §3). It has no `ctx`, no beat, no snapshot, no reveal, no save point (Rule 14) and no exits; it cannot fire rules (nothing is evaluated mid-scene, GDD 6 Rule 3) and cannot queue another insert.
*Rationale:* GDD 7 Rule 2 and GDD 6 Rule 7 agree only if an NPC reaction has no boundary; GDD 6 Visual/Audio §1 fixes what the player sees (a person through a threshold, nothing before the figure is on the line); the narrative brief writes the supporting scenes "as insert scenes, not chapters". Autoplaying the entry dialogue is the mechanical form of "the state has arrived": the state does not wait to be clicked.
*Rejected:* an insert as an overlay on the current plate with no host activation (Overlay and Character Presentation would need a second entry path, and the relit room is a second sidecar in any case); an insert with free hotspots and a door (it would need exits, a boundary and a beat, which is a chapter scene); carrying an insert's effects to the next chapter (GDD 1 Edge Case 18 rejects the batch as stale, and GDD 5 says no fact crosses).

---

**12. Calendar scenes, transitions, the act-close beats.** A scene row of `kind: calendar` is run by `enter` as: `transition = calendar.transition_between(prev, id)`; if `kind: day`, `presentation.transition(transition)` and wait for `on_continue()` (the leaves tear, the stamp strikes, the screen **holds**, GDD 7 Visual/Audio §3); then Rule 8 from step 1 with `cursor.staged` empty, `apply([])` at step 5, no `preload` of itself at step 11 (there is no plate), and the reveal at step 12 pinned onto the held transition screen; after `on_continue` the next plate is entered (or the insert cuts in first, Rule 10). If the transition is `slot` or `none` (GDD 7 Edge Cases 3 and 21) no calendar screen is shown and the reveal is a sheet over the suspended previous plate, or over the still-held calendar screen when the previous scene was itself a calendar scene (the act-close pair) — the screen persists across consecutive calendar scenes and the second reveal pins beside the first **(PROV: Paper UI)**. The act-close beats are two calendar scenes under `<act>_close` (Rule 2 step 2; GDD 7 Edge Case 5); no decision is offered at either; the review sits at the first and the card arrives at the second (GDD 7 Edge Case 21), both as `paper` firings in their reveals.
A `day` transition before an **authored** scene with a plate plays, strikes and cuts to the plate; nothing is pinned, because nothing moved (GDD 7 Visual/Audio §3). `transition_between` is never called across a chapter edge or with an insert id (GDD 7 Edge Cases 2 and 20); a `TRANSITION_ILLEGAL` return plays nothing and the next scene is stamped cold, and this system's DebugSink asserts because the call was its own bug.
*Rationale:* GDD 7 fixed every piece of this except the order "hold → boundary → reveal → cut", which it marked Scene Flow's; this is that order.
*Rejected:* running the calendar beat's boundary *before* the transition so the leaves tear onto the notices (the strike would then announce a snapshot the player has not seen, which GDD 7 Visual/Audio §3 forbids: "the strike restates, never announces").

---

**13. One presentation seam, calls both ways, no signals from Scene Flow.** `PresentationSink` is the one object through which Scene Flow shows anything; the engine implementation fans out to Paper UI, Overlay and Audio **(PROV)**, and `NullPresentationSink` records every call in order for the simulator and the tests. Outbound calls (all return nothing):

| Call | When | Who consumes |
|---|---|---|
| `chapter_card(chapter_id, title_id, opening[])` | Rule 2 | Paper UI (the cold card; Chapter & Story Structure's design) |
| `transition(data)` | Rule 3 step 2, Rule 12 | Paper UI (the leaves and the strike), Overlay (slot light), Audio (leaf tear, strike) |
| `reveal(records, snapshot, paper[], counts)` | Rule 8 step 12 | Paper UI (change notices, the "changed" marker, the paper lines, the read count, `stamp_tier` per sheet); Overlay (`phase`, `ink_reach`, `red_reach` from the snapshot, cut at the reveal); Audio (`phase`, per-character `looked/watched/tier`, `stamp_tier` cues) — GDD 7 Rule 9 and Visual/Audio §1–§7 |
| `rule_fired(class, kind ∈ {insert, paper})` | Rule 8 step 12 (paper), Rule 11 step 3 (insert) | Audio (GDD 6 Visual/Audio §6's cue families, named by threshold or paper) |
| `open_document(document_id, holdable[])` | Rule 4 | Paper UI (the sheet; it pushes its own block and calls `facts.hold`/`pair`) |
| `epilogue(ending_class, epilogue)` | Rule 2 step 3 | Paper UI (the last page and the closing stamp, art bible §2.1) |

Dialogue and Filing are *systems*, not sink calls: Scene Flow calls `dialogue.run(...)` and `filing.run(...)` and they present their own sheets **(PROV)**. Inbound, Scene Flow exposes exactly these entry points and is driven by nothing else: from the host's signals, `on_scene_preloaded(id)`, `on_scene_ready(id)`, `on_hotspot_activated(id)`, `on_hotspot_examined(id)`, `on_scene_exited(id)`; from the fact system, `on_document_filed(document_id)`; from Dialogue, `on_dialogue_end(dialogue_id)`; from Filing, `on_decision_made(decision_id, option_id)`; from the presentation layer, `on_continue()` (the open card, transition, reveal or epilogue was closed by the player). The engine wires the host's and the fact system's signals to these in `new()` (`signal.connect(callable)` is the sourced idiom, deprecated-apis.md line 28; whether a `signal` declared on a `RefCounted` emits with no scene tree is **NOT SOURCEABLE** and is GDD 3's spike; if it fails, the fallback is a listener object handed to the host and the fact system, and the entry points above do not change). Scene Flow declares no signal of its own: a recorded call list is replayable headlessly and diffable; a signal is a call into whatever is connected (GDD 6 Rule 9, GDD 7 Rule 4).
*Rationale:* the simulator must drive and observe Scene Flow with no engine; two interfaces (one in, one out) with null twins are what make `tools/sim/` and `tests/unit/scene_flow/` the same harness.
*Rejected:* Paper UI calling Scene Flow's internals (`enter`, `exit`) directly (the order would live in two places); Scene Flow emitting `boundary_closed` and letting consumers pull the snapshot (each consumer would call the Calendar mid-scene, which GDD 7 Rule 9 forbids).

---

**14. Save points are the closed reveal; Scene Flow serialises the cursor and nothing staged.** The only save point is Rule 8 step 13, after `on_continue` closes the reveal and before the insert plays or the next scene is entered. At that moment the dossier and the Calendar are outside their brackets (GDD 1 Rule 10, GDD 7 Edge Case 15), the fact system is at a boundary (GDD 5 Rule 6's `at_boundary: true`), the rules evaluator is idle (GDD 6 States), and `cursor.staged` is empty by construction (an insert's effects are staged only when it plays, and it plays *after* the save point). `serialize() → {sf_schema_version, act, chapter_id, cursor: {next: scene_id | chapter_end, pending_insert: scene_id | null}, phase ∈ {in_chapter, act_close}}` — plain data, no resource, no string, no availability (re-derived, Rule 6), no focus or camera (GDD 3 Interactions), no staged effects, ever. `deserialize(data)` accepts only the current `SF_SCHEMA_VERSION`, whole or not at all (GDD 1 Edge Case 13's shape), and is legal only before `run_act` has entered a scene. Load order, which Save/Load owns **(PROV)** but which this system requires: content, then `dossier.deserialize`, `calendar.deserialize`, `rules.deserialize`, `facts.deserialize(data, at_boundary = true)`, then Scene Flow's; then Scene Flow calls `calendar.open_chapter(chapter_id)` again (GDD 7 Rule 1 amendment), `reader.bind`, rebuilds `writer`, and runs `play_insert(pending_insert)` if set, else `enter(next)` — the same path as an unloaded game, which is what makes "re-derived on load" (GDD 3 Rule 5) a single function. The dossier's own `chapter_id` and beat come from its payload; Scene Flow does not call `chapter_open` again (it would re-apply the assumptions).
A quit inside a scene resumes at that scene's start: the documents already read in the abandoned scene are re-read, facts held there are not restored (GDD 5 Edge Case 13 forbids a mid-dialogue load, and a mid-scene held set with no board-to-sheet synchrony is what it forbids it for). This is a player-experience ruling for the creative director to confirm (Open Questions); the alternative is in "Rejected".
Hot reload (GDD 2 Rule 13, "between scene boundaries") is answered the same way: `SceneFlow.reload_window() → bool` is true exactly at the save point, and `ContentStore.reload()` is legal only then; a reload inside a scene would change the action table under the player's cursor.
*Rationale:* every stateful system already refuses a mid-bracket load; choosing the closed reveal makes "at a boundary" one instant every GDD agrees on, and makes the cursor two ids.
*Rejected:* saving `staged[]` for a mid-scene resume (GDD 5 forbids the matching fact restore, so the sheet would resume ahead of the board; and a save inside a scene is a save of a room the rules have not seen); a save point before the reveal (the player would resume onto a reveal of records already seen, and Paper UI's seen state is not saved by anyone, GDD 1 Rule 5); continuous save of held facts (requires a GDD 5 amendment and a second save point class; raised in Open Questions).

---

**15. The simulator driver: `step(intent)` and the boundary record.** For `tools/sim/` and the unit tests Scene Flow exposes `step(intent) → StepResult {accepted: bool, reason: string | null, at: {chapter_id, scene_id, open: none | document | dialogue | decision | reveal | transition | card | epilogue, beat}, boundary: BoundaryRecord | null}`. Intents, mapped one-to-one onto the inbound surface of Rule 13 and the null twins' driver methods:

| Intent | Precondition | Effect |
|---|---|---|
| `activate(hotspot_id)` | room active | `host.activate(hotspot_id)` (NullSceneHost's driver; emits `hotspot_activated` or `hotspot_examined` by availability) |
| `examine(hotspot_id)` | room active | `host.examine(hotspot_id)` |
| `hold(fact_id)` | a document is open | `facts.hold(fact_id, source)` with the open document as source; refusal reasons pass through (GDD 5 Edge Case 19) |
| `pair(a, b)` | chapter open | `facts.pair(a, b)`; the result is in `StepResult.reason` |
| `answer(answer_id)` | a dialogue is open | `dialogue.answer(answer_id)` (the null runner stages the answer's effects through `writer` and calls `on_dialogue_end` on `end`) |
| `decide(option_id)` | a decision is open | `filing.choose(option_id)` (the null runner stages and calls `on_decision_made`) |
| `leave(expect_to?)` | room active | `host.activate(first exit hotspot in focus_order, or the one `expect_via` names)`; after the boundary, `accepted = false, reason = ROUTE_MISMATCH(expected, got)` when `expect_to` is given and differs — the parity signal for a route |
| `continue` | a card, transition, reveal or epilogue is open | `on_continue()` |

`step` returns `boundary` non-null exactly when the intent closed a boundary; `BoundaryRecord {ctx, decision_batch, result (RulesResult), records (dossier), calendar_records, route, insert: {scene_id, class} | null, paper: [class], degraded: [rule_id], transition: {kind, days_elapsed} | null, snapshot_digest}`. The replay runner (GDD 6 Rule 11) writes the JSONL line from it: GDD 6's fields `{beat, day, scene_id, chapter_id, decision_batch, steps[...]}` plus Scene Flow's `route`, `insert`, `paper`, `degraded`, `transition` and `snapshot_digest`; the header gains `play_order_actual` (GDD 7 Edge Case 22). Scene Flow writes no file (no file I/O; the trace is the runner's). NPC and world choices come from the `choices` source injected at construction (the policy, or a witness forced through GDD 6's `ChoiceSource`); in release the forcing path is stripped at export and Scene Flow holds the policy-only source. The player-input tree CI enumerates (GDD 6 Rule 12) is the tree of `decide`, `answer` and `leave` intents, merged by `(boundary, dossier digest)`; `hold` and `pair` branch it only where a `has_fact` gate is reachable, which the Fact registry's `uses[]` names.
*Rationale:* GDD 6's parity argument needs the runtime to be driven from the same scripted intents the solver's witness lists; a `step` that returns the boundary record is what lets the runner assert per beat without reaching into any system.
*Rejected:* a scripted `exit(to)` intent that sets the route (bypasses `exits[]`, so a witness could realise a route the content cannot); the runner reading Scene Flow's cursor fields (a second interface to keep in step).

---

**16. Headless rule.** `SceneFlow`, `CompositeApply`, `DossierWriter`, `ConditionReader` (GDD 5's, in `src/investigation/`), `PresentationSink`, `NullPresentationSink`, the null dialogue and filing runners and the `BoundaryRecord` shape import nothing from the scene tree, from `tools/` or from `tests/`; `src/scene_flow/` may import `scene_host.gd` and never `src/scene/engine/*` (GDD 3 Rule 8's path rule, extended); the engine `PresentationSink` lives in the presentation layer. The story simulator and `tests/unit/scene_flow/` bind `NullSceneHost` and `NullPresentationSink`. The CI path check of GDD 1 Rule 11 / GDD 2 Rule 14 / GDD 3 Rule 14 enforces the direction. **NOT SOURCEABLE** and routed to the existing spikes: `RefCounted` as the base class, a `signal` on a `RefCounted` emitting with no tree (GDD 3), `@abstract` for the sink interface (GDD 3, sourced for 4.5 syntax only), and `await`/`Callable` for the wait points, which this design does not use (every wait is an inbound call, Rule 13). What only run-and-observe verifies, with retained screenshots: the cut into an insert, the wipe after it, the reveal over a held calendar screen, the chapter card's cold stamp.
*Rationale:* the brief's headless rule, restated so that a path check can enforce it.
*Rejected:* a `SceneFlow` Node (the simulator would need a tree; every other Foundation system already refused this).

---

**17. What the system can never do.** Never reads a wall clock, a frame time or a timer (GDD 7 Rule 10's argument; the only engine-time fact in the pinned reference is a deprecation line and this system calls neither name). Never evaluates a rule mid-scene, never calls `run_boundary` twice for one scene, never skips a boundary for an authored scene (a debug jump to a scene still closes that scene's boundary). Never applies an effect outside the bracket of Rule 8, never applies the staging batch twice, never applies a `calendar.*` target to the dossier or a dossier target to the Calendar. Never reads `branches.json` or any simulator output at runtime. Never decides what a hotspot yields (GDD 5), what a filing costs (Filing), what a line says or when a timed choice expires (Dialogue), what the phase or a tier is (Calendar), which rule fires (Rules), or how anything is drawn, stamped or sounded (Paper UI, Overlay, Audio). Never changes availability on idle, on a clock, on focus or from the board; never sets `hidden` at MVP. Never plays two inserts at one boundary, never plays an insert at a `chapter_end` or act-close boundary, never gives an insert a boundary, a beat or a save point. Never calls `transition_between` across a chapter edge or with an insert id. Never invents a scene id, a chapter id or a route: every id comes from content and every route from `exits[]`. Never emits a signal; never reads a Settings key (GDD 4: `timer_mode` is Dialogue's, `motion` is Paper UI's); never holds a string; never persists anything but the cursor; never writes a file. Never activates a scene the host has not reported `ready`.
*Rationale:* each line is a promise another GDD made about this one; listing them in one place is what the consistency check greps.
*Rejected:* a shorter list (every item above has already been proposed, somewhere in the seven GDDs, as something Scene Flow might "just" do).

---

### States and Transitions

**The act** (`run_act`): `unopened` → `chapter(i)` for `i` over `play_order` (each: `card → open → scenes… → closing → closed`) → `act_close` (the pseudo-chapter: `open → calendar beat 1 → calendar beat 2 → archive applied in beat 2's bracket → closed`) → `ending_selected` → `epilogue` → `done`. Chapter edges call no transition (GDD 7 Edge Case 1).

**The chapter**: `card` (sink `chapter_card`; waiting on `on_continue`) → `open` (`calendar.open_chapter`, `dossier.chapter_open`, reader bound, writer built) → `in_scene` (Rule 3–11 loop) → `closing` (the `chapter_end` boundary's reveal closed) → `closed` (`facts.chapter_close`, `dossier.chapter_close`). Forward only; a load re-enters at `in_scene` through Rule 14.

**The scene cursor**: `entering` (transition if any; availability derived; `activate_scene` issued; block held) → `active` (`scene_ready`; block released; focus placed) ⇄ `suspended` (any sheet open: the host's block count > 0; Scene Flow's own pushes are `enter:`, `boundary:`, `insert:`) → `leaving` (an exit hotspot activated; Rule 8 runs) → `revealed` (the reveal sheet is open; the save point is its close) → `entering` the next scene, or `insert` first. A calendar scene goes `entering → leaving` with no `active`.

**The boundary** (Rule 8): `assembled` (ctx and composite built) → `open` (Calendar then dossier brackets) → `decision_applied` → `rules_run` → `archived` (last act-close boundary only) → `closed` (dossier then Calendar) → `snapshotted` → `routed` (route resolved; firings staged) → `preloading` (next id issued) → `revealed` → `done` (record returned). No state is re-entered; a failure inside any step asserts through the DebugSink and the procedure continues to `done` with the failure in the record (the simulator fails the telling; release logs).

**The sheet stack** (as Scene Flow sees it): the host's counted block (GDD 3 Rule 13) is the only stack. Scene Flow pushes and pops its own three reasons and never pops another system's; Paper UI pushes `sheet:<id>` around every sheet including the reveal; Dialogue's transcript and Filing's sheet go through Paper UI. The room is `active` iff the count is zero. A timed choice is a sheet with the count above zero for its whole life, so no Scene Flow path runs under it.

**The insert queue**: capacity one. `empty` → `queued(scene_id, class, firing)` at Rule 8 step 10 → `playing` (Rule 11; `cut`, dialogue running, block held) → `empty` on `on_dialogue_end`. A load with `pending_insert` set re-enters at `queued`. A second `insert` firing never enters the queue; it is `paper` (Rule 10).

**The staging batch**: `empty` at `enter` → `staged(n)` as `writer.submit` appends → `empty` at Rule 8 step 5. An insert's submissions append to the batch of the *next* authored scene, which is empty when the insert begins (the previous boundary consumed it) and may be non-empty when that scene is entered.

---

### Interactions with Other Systems

| System | In (to Scene Flow) | Out (from Scene Flow) | Interface owner |
|---|---|---|---|
| **Dossier State Model** (GDD 1) | `beat()` (read; GDD 1 Rule 4a amendment), `read` through the reader, `apply → [change]`, `end_boundary → [change]`, `select_ending` | The bracket in Rule 8's order: `begin_boundary(scene_id, day)` → `apply(staged)` once → `apply` per cascade step through the composite → (`apply(archive_batch)` at the act's last boundary) → `end_boundary()`; `chapter_open(id, reads, writes, assumes)` / `chapter_close()`; the `DossierWriter` staging facade handed to Filing and Dialogue | GDD 1 owns the bracket's calls and the effect/change formats; Scene Flow owns the order and the staging |
| **Narrative Content Format** (GDD 2) | `chapter(id)`, `scene(chapter_id, scene_id)` with `kind`, `class`, `exits[]`, `actions[]`; `beat(class)`; `epilogue(class)`; `Condition.evaluate` and the reader shape; `scene_vocab.json` kinds | `scene_id`/`chapter_id` for every `source`; the semantics of `scene`, `exits[]`, `kind`, `class`, `via`; lint rules SF-E1–E8, SF-W1–W3; the hot-reload window | GDD 2 owns syntax and the validator; Scene Flow owns scene and exit semantics |
| **Scene & Interaction Framework** (GDD 3) | `SceneHost`: `scene_preloaded`, `scene_ready`, `hotspot_activated`, `hotspot_examined`, `scene_exited`; `hotspot_ids`, `hotspot_counts`, `focus`; `NullSceneHost` drivers | `preload_scene` (after rules, before the reveal), `activate_scene(id, wipe)`, `unload_scene`, `set_hotspot_state` (before activation; `filed` on `document_filed`), `set_focus` at entry, `push/pop_input_block` for `enter:`, `boundary:`, `insert:` | GDD 3 owns the host; Scene Flow owns door semantics, availability values and the order of calls |
| **Investigation & Fact** (GDD 5) | `open(document_id) → holdable`, `open_dialogue`, `filed_documents()`, `has` (through the reader), `document_filed` (signal), `serialize/deserialize(at_boundary)`, `chapter_close()` | The resolved document or dialogue id after a hotspot event; `set_hotspot_state(filed)` on its signal and after a load; `at_boundary = true` at the save point; the `ConditionReader` composition (built here, bound per chapter) | GDD 5 owns yields, the held set and the filed rule; Scene Flow owns availability and the boundary |
| **Reactive Event Rules & Simulator** (GDD 6) | `run_boundary(ctx, apply, choices) → RulesResult`; `ChoiceSource`; the replay runner driving `step(intent)` | `ctx` with chapter and scene ids; the composite `apply`; one call per boundary at the rules step; `rule_fired(class, kind)` to Audio through the sink; `BoundaryRecord` for the trace; the presentation rule's `degraded[]` | Scene Flow calls Rules, never back; Rules owns the evaluator; Scene Flow owns `stage_firings` |
| **Calendar, Regime Phase & Attention** (GDD 7) | `date_for(chapter, scene)`, `day_high()`, `transition_between(a, b)`, `snapshot(ctx)`, `apply_calendar(batch, ctx)` (via the composite), `read(calendar.*)` and `phase()` through the reader, `open_chapter` | `open_chapter(chapter_id)` at every chapter edge and the act close (and again after a load); `begin_boundary(ctx)` / `end_boundary()` as the outer bracket; `ctx.step` in GDD 7's four values; `transition` calls only between consecutive authored scenes of one chapter | Scene Flow owns the step order and every call; the Calendar returns values |
| **Settings Store** (GDD 4) | Nothing | Nothing (no key read; the CI path check may add `scene_flow` to the never-import list) | — |
| **Paper UI** (PROV) | `on_continue()` for the card, transition, reveal and epilogue; `hold`/`pair` calls go to GDD 5 directly | `reveal(records, snapshot, paper[], counts)`, `open_document(id, holdable)`, `chapter_card`, `transition`, `epilogue` through the sink; the `paper_visible` filter; the sheet-stack contract | Paper UI owns rendering, seen/unseen and stamping; Scene Flow owns what is handed and when |
| **Overlay & Surveillance Rendering** (PROV) | Nothing | The snapshot inside `reveal` (phase, `ink_reach`, `red_reach`), the `slot` transition inside `transition`, the insert cut via the host | Overlay owns pixels; the Calendar owns tiers; Scene Flow owns the moment |
| **Audio** (PROV) | Nothing | `rule_fired(class, insert|paper)` at the moment the person or paper is in the frame; the snapshot's booleans inside `reveal`; `transition` for leaf and strike cues | Audio owns the mix; Scene Flow owns the timing of the hand-off |
| **Dialogue & Interrogation** (PROV) | `on_dialogue_end(dialogue_id)`; the null runner's `answer(id)` | `run(dialogue_id, reader, writer)`; the staging `writer`; the room suspended under its sheet; no clock of this system's | Dialogue owns the transcript, timers and `pace`; Scene Flow owns when a dialogue starts and that its effects are staged |
| **Filing & Decision** (PROV) | `on_decision_made(decision_id, option_id)`; the null runner's `choose(id)` | `run(decision_id, reader, writer)`; `decided` (one decision per scene); the staging `writer` | Filing owns the cost rule and the sheet; Scene Flow owns staging and the once-per-scene rule |
| **Chapter & Story Structure** (PROV) | `ActPlan {play_order, chapters, act_close, archive_batch, ending_table}`; the pseudo-chapter declaration | `run_act(plan) → {ending, boundaries_run}`; `chapter_card` content requests; every `chapter_open/close` call made on its behalf | Chapter structure owns the plan's shape, death and the story continuing; Scene Flow executes |
| **Save/Load** (PROV) | `deserialize(data)` before the first `enter`; the load order of Rule 14 | `serialize() → {sf_schema_version, act, chapter_id, cursor, phase}`; `SF_SCHEMA_VERSION`; `reload_window()`; the save point definition | Save/Load owns the registry and migration; Scene Flow owns the cursor's shape and the save point |
| **Character Presentation** (PROV) | Nothing | Nothing direct: it listens to the host's `scene_ready`/`hotspot_activated` (GDD 3 Rule 10) | GDD 3 |

## Formulas

[To be designed]

## Edge Cases

[To be designed]

## Dependencies

*Hard* means the system cannot function without the other; *soft* means it works without it and is improved by it. Rows marked **(PROV)** name a system whose GDD is not yet written. Reciprocity today: GDD 1 names Scene Flow as the owner of the bracket's order; GDD 2 as the semantics owner of `scene` and `exits[]`; GDD 3 as the caller of the host and the owner of availability and door semantics; GDD 5 as the resolver of hotspot actions and the caller of `set_hotspot_state(filed)`; GDD 6 as the caller of `run_boundary` and the owner of the presentation rule; GDD 7 as the assembler of `ctx` and the caller of `open_chapter`, `begin/end_boundary`, `transition_between` and `snapshot`. All six match the rows below.

| System | Direction | Hard/Soft | Interface |
|---|---|---|---|
| Dossier State Model (GDD 1) | This depends on it | Hard | The bracket (`begin_boundary(scene_id, day)`, `apply`, `end_boundary`, `beat()`), `chapter_open/close`, the `DossierWriter` staging facade, `select_ending`; the archive batch admitted at the act's last boundary |
| Narrative Content Format & Strings (GDD 2) | Mutual | Hard | `chapter`, `scene` (`kind`, `class`, `exits[{to, when, via}]`, `actions[]`), `beat(class)`, `epilogue(class)`, `Condition.evaluate`; this system owns the semantics of scenes and exits and the lints SF-E1–E8, SF-W1–W3; hot reload only at the save point |
| Scene & Interaction Framework (GDD 3) | Mutual | Hard | `SceneHost` calls and signals; `NullSceneHost` for the simulator; availability set only here; `preload_scene` after the rules step; the input block for `enter:`, `boundary:`, `insert:` |
| Investigation & Fact System (GDD 5) | Mutual | Hard | `open`, `open_dialogue`, `filed_documents`, `document_filed`, `serialize/deserialize(at_boundary)`, `chapter_close`; the `ConditionReader` built here and bound per chapter |
| Reactive Event Rules & Story Simulator (GDD 6) | Mutual | Hard | `run_boundary(ctx, apply, choices)` once per boundary; `stage_firings` (one insert, the rest paper); `rule_fired` through the sink; `step(intent)` and the `BoundaryRecord` for the replay runner; `ChoiceSource` |
| Calendar, Regime Phase & Attention (GDD 7) | Mutual | Hard | `open_chapter(id, resumed)`, `begin_boundary(ctx)`/`end_boundary()` as the outer bracket, `date_for`, `day_high`, `transition_between`, `snapshot(ctx)`, `apply_calendar` through the composite |
| Settings Store (GDD 4) | None, by rule | — | No key is read here; the CI path check adds `src/scene_flow/` to the never-import list |
| Paper UI | Depends on this **(PROV)** | Hard | The sink's `reveal`, `open_document`, `chapter_card`, `transition`, `epilogue` and `on_continue`; `paper_visible`; the sheet-stack contract |
| Overlay & Surveillance Rendering | Depends on this **(PROV)** | Soft | The snapshot inside `reveal`; the slot transition; the insert's cut through the host |
| Audio & Adaptive Surveillance Mix | Depends on this **(PROV)** | Soft | `rule_fired(class, insert|paper)` at the moment the person or paper is in the frame; the snapshot's booleans; `transition` |
| Dialogue & Interrogation | Mutual **(PROV)** | Hard | `run(dialogue_id, reader, writer)` and `on_dialogue_end`; effects staged through the writer; the room suspended under its sheet; timers are its own |
| Filing & Decision | Mutual **(PROV)** | Hard | `run(decision_id, reader, writer)` and `on_decision_made`; one decision per scene; effects staged |
| Chapter & Story Structure | Mutual **(PROV)** | Hard | `ActPlan {play_order, chapters, act_close, archive_batch, ending_table}`; `run_act(plan)`; the pseudo-chapter `<act>_close`; chapter cards |
| Save/Load | Depends on this **(PROV)** | Soft | `serialize()`/`deserialize(data)` of the cursor; `SF_SCHEMA_VERSION`; the save point is the closed reveal; `reload_window()` |
| Character Presentation | None direct **(PROV)** | — | Listens to the host's signals (GDD 3 Rule 10) |

## Tuning Knobs

[To be designed]

## Visual/Audio Requirements

[To be designed]

## Game Feel

Optional for a Core system; three feel properties follow from it and are stated so Paper UI, Overlay and Audio inherit them as targets.

- **The room waits.** Nothing in a scene changes on idle, on a clock or on focus; availability changes only in answer to the player's own act, and every effect waits for the door. A player who reads a sheet for ten minutes finds the room as they left it.
- **The boundary is one motion.** Wipe, reveal, at most one person through a threshold, the tear-off if the day turned, the next room: always in that order, never interleaved, with no spinner and no wait the player can see (the reveal's reading time hides the load, GDD 3 Rule 7). The paper tempo is §7.4's.
- **The state arrives as a cut, never a wipe.** An insert enters by a cut ("the floor goes", art bible §2.1); the figure is on the threshold line before any light changes; the authored room resumes afterwards by the ordinary wipe.

## UI Requirements

This system has no screen and must not have one. Every sheet the player sees at a boundary (the reveal, the chapter card, the tear-off, the epilogue) is Paper UI's, fed by the sink; every room is the Scene & Interaction Framework's; every transcript is Dialogue's and every filing sheet is Filing's. Scene Flow renders no text, no counter and no indicator; the one number it hands on is GDD 3's read count inside `reveal`, which Paper UI prints in typed form. Debug builds only: an inspector that prints the cursor, the staged batch, the pending insert, the last `BoundaryRecord` and the sink's last calls, reachable through the debug menu and absent from release (the same rule as GDD 2's, GDD 6's and GDD 7's debug surfaces). The simulator's reports under `tools/sim/` are the writers' tools.

> **📌 UX Flag — Scene Flow**: no player-facing UI of its own. The reveal sheet, the empty reveal ("no files changed"), the chapter card and the epilogue are Paper UI's `/ux-design` work; the insert's entry is Character Presentation's and Overlay's; `design/accessibility-requirements.md` must state that every boundary sheet is dismissed by `on_continue` with no timeout and that the input block during a wipe is announced to a screen reader.

## Cross-References

| This GDD references | In | Owner | Nature |
|---|---|---|---|
| The atomic bracket, `beat()`, the archive batch, `chapter_open/close`, the `DossierWriter` staging facade, change records, `select_ending`, the stale-source rejection | GDD 1 Core Rules 2, 4, 4a, 5, 6; Formulas §5; Edge Cases 12–14; States | Dossier State Model | Consumed; three amendments applied there for this GDD |
| `chapter`, `scene` (`kind`, `class`, `exits[].via`), `action`, `decision`, `dialogue`, `beat`, `epilogue`; `Condition.evaluate`; `source` grammar; hot reload; the validator's rule table | GDD 2 Core Rules 5, 5c, 6, 7, 9, 13, 15 | Narrative Content Format | Consumed and extended; one amendment applied (the scene row), the lints SF-E/SF-W owned here |
| `SceneHost` and `NullSceneHost`, availability, the two-scene residency and the preload moment, the input block stack, the wipe, timers as sheets, the constructor | GDD 3 Core Rules 5, 6, 7, 8, 13, 14; Edge Cases 14, 15, 17 | Scene & Interaction Framework | Consumed; one amendment applied (the constructor sentence) |
| `open`/`open_dialogue`, `filed_documents`, `document_filed`, the `ConditionReader`, `deserialize(at_boundary)`, the filed rule, `when` never hiding an exit | GDD 5 Core Rules 4, 6, 9; Edge Case 19 | Investigation & Fact | Consumed; one amendment applied (the reader bound per chapter) |
| `run_boundary`, `RulesResult`, the composite apply, the presentation rule, `rule_fired`, the trace, `ChoiceSource`, the solver's beat | GDD 6 Core Rules 3, 5, 7, 9, 11, 12; Visual/Audio §1, §3 | Reactive Event Rules | Consumed; one amendment applied (Rule 7, `close_scene`) |
| `ctx`, `open_chapter`, the Calendar's bracket, `date_for`, `transition_between`, `snapshot`, calendar scenes, the act-close pseudo-chapter, `day_high`, the timetable validation | GDD 7 Core Rules 1, 2, 3, 4, 5, 9, 11; Edge Cases 1, 2, 4, 5, 16, 20, 22; Visual/Audio §3 | Calendar | Consumed; two amendments applied there |
| "A setting changes how the game asks, never what it asks"; the never-import list | GDD 4 Player Fantasy; Core Rules 11, 13 | Settings Store | Consumed |
| The arcs and the scene beats per chapter; insert scenes "written as inserts, not chapters" | Narrative brief §1, §8 | Narrative | The shape of a chapter's exit graph |
| The game states, the reactive-event entry, paper animation, the UX alignment | Art bible §2.1, §7.4, §7.6 | Art direction | Visual/Audio |
| Pillars 1, 2, 3, 4, 5; "not a sandbox" | design/gdd/game-concept.md | Creative direction | Player Fantasy; the exit lints |
| Headless CI, `--check-only`, lambda capture, `@abstract`, typed-return overrides, `await` only as `yield`'s replacement, `signal.connect` | docs/engine-reference/godot/current-best-practices.md lines 19–40, 46–47, 190–223; breaking-changes.md lines 17, 69; deprecated-apis.md lines 27, 28, 47 | Engine reference | Rule 16; the test runner |
| Signals on `RefCounted`, `Callable`, awaiting a tween, threaded loading, `queue_free`, the recursive input-disable property name | NOT SOURCEABLE from the pinned reference (no `core.md`) | Engine reference | Open Questions; the host twins' spikes |

## Acceptance Criteria

[To be designed]

## Open Questions

| Question | Owner | Needed by | Status |
|---|---|---|---|
| ADR-1 confirms the bracket as Scene Flow drives it (the Calendar's bracket outside the dossier's; `beat()`; the archive batch at the act's last boundary; the composite apply; the staging facade) and ADR-5 (the renderer) the `SceneHost`/`PresentationSink` twins | technical-director via `/architecture-decision` | Before Technical Setup | Open; this GDD is the input |
| GDD 2 amendments applied here in outline (scene `kind`, `class`, `exits[].via`; the lints SF-E1–E8 and SF-W1–W3 joining Rule 15's table with Scene Flow as owner; `source` naming the insert scene id): the content compiler and validator implement them when built | Narrative Content owner | Before the content compiler is built | Open; requested and recorded |
| `paper_visible` (a `paper` beat the protagonist never sees renders nowhere in that chapter): filtered here over the firing's change-record projections; Paper UI may prefer to own it | Paper UI GDD | Paper UI | Open; proposed here |
| Mid-scene quit resumes at the scene's start with that scene's held facts lost (Core Rule 14); the alternative, a continuous fact save, needs a GDD 5 amendment and a second class of save point | creative-director (at the gate), Save/Load GDD | Save/Load GDD | Open; ruled here, confirmation pending |
| The MVP chapter is GDD 7's MVP fixture (`v_office`, `v_cal_weekend`, `v_turn`, `v_person`) while the act file keeps `v_night`; Chapter & Story Structure decides whether the shipped Vera chapter carries the calendar beat or the night scene | Chapter & Story Structure GDD; narrative-director | Vertical Slice | Open; both are run by this system |
| `PLAYER_ACTIONS_PER_SCENE_MAX` (3) and the solver's `close_scene` action (GDD 6 Rule 7 amendment): the generator models a boundary's player actions as steps at one beat; `HORIZON_EVENTS` is re-measured with them | technical-director, systems-designer | First simulator run | Open |
| The insert scenes' content for act one (`rybar_query_ledger` in Vera's chapter; Berta's memo; Kastan's slip is paper; the captain at the post): one `kind: insert` row per class per chapter, written by the narrative team | narrative-director, writer | Act-one content | Open |
| Engine spikes, NOT SOURCEABLE from the pinned reference (no `core.md`): signals on a `RefCounted` and connecting the host's signals to a headless object; the `Callable`/`RefCounted` reference cycle (`dispose()` plus a `weakref` test); `await` semantics (avoided by design); the recursive input-disable property name (GDD 3's); synchronous versus deferred signal emission (a `DeferredNullSceneHost` twin, the contract suite runs both); `@abstract` on the base classes versus a plain base with `push_error` bodies until `/setup-engine refresh` records the installed editor | technical-director, engine-programmer | ADR; before the first host twin | Open |
| The zero-test trap: gdUnit4 exits 0 on "No test cases found"; CI must fail on the runner's zero-tests row or a minimum count | devops-engineer (`/test-setup`) | Test setup | Open |
| `design/accessibility-requirements.md` must state that every boundary sheet is dismissed by `on_continue` with no timeout and that the input block during a wipe is announced | `/ux-design accessibility` | Before this GDD's criteria are checked | Open |
