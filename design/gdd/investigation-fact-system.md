# Investigation & Fact System

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: In Design
> **Author**: Mustafa Faisal (user) + game-designer, systems-designer, narrative-director, gameplay-programmer (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 1 Every fact is a weapon · 5 Pressure comes from attention, not reflexes

## Summary

The Investigation & Fact System turns what the player reads and hears into held facts, lets two held facts be tested against each other so that an authored link yields a derived fact, and keeps the board that shows what this protagonist knows in this chapter. A fact is the player's, never the state's: it is held by a deliberate press on a line (or automatically when a line is spoken), it never crosses a chapter, it unlocks content only through the `has_fact` gate, a failed pairing costs nothing and leaves no mark, and the board carries no numbers. It exists because Pillar 1 is only true if a fact is an object the player can hold, connect and spend, and the system enforces that at build time: every authored fact must reach something that writes paper, or the content does not ship.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Narrative Content Format & Strings` (fact declarations, links, the condition evaluator), `Dossier State Model` (read-only, through the evaluator); read by Scene Flow, Paper UI, Dialogue & Interrogation, Filing & Decision, the story simulator

## Overview

The Investigation & Fact System is the half of the core loop that happens before the pen touches the ledger: it turns what the player reads, examines and hears into *held facts* (a name, a date, an address, a serial), lets two held facts be tested against each other so that a connection unlocks a question, an option or a line, and keeps the fact board that shows what this protagonist knows in this chapter. A held fact is the player's, not the state's: it is never dossier state (GDD 1's sorting rule), it dies with the chapter unless a decision writes its paper, and it may unlock content only through the condition grammar's `has_fact` leaf (GDD 2 Rule 6). The system reads dossier flags for unlock conditions and never writes one. It exists because Pillar 1, "every fact is a weapon", is only true if a fact is an object the player can hold, connect and spend, and because the MVP's second requirement is exactly this: fact extraction and connection, two facts linking to unlock a question. The archivist prototype proved the loop is expressible on one screen, read → hold → connect → ask → decide, and that held facts and filed facts must be different objects. The index describes the system as depending on "Narrative Content Format & Strings, Scene & Interaction Framework, Dossier State Model (reads for unlock conditions; never writes)" and requires the simulator acceptance criterion that every authored fact has at least one dossier use; this GDD keeps that scope. It does not own the board's rendering (Paper UI), the hotspot (GDD 3), what a document says (GDD 2), the decision that spends a fact (Filing & Decision), or the line a fact unlocks (Dialogue & Interrogation).

## Player Fantasy

*Framing: direct; this is the system the player operates most. Shaped with the creative director (three candidate framings; "the name you kept" chosen, with one beat from "what you know, they can know"; "two papers that disagree" kept as an authoring pattern for some links, not the fantasy for all).*

**Noticing is the act.** The emotion this system serves is a reader's private certainty: you saw it, nobody pointed at it, and now it is yours. A name in a file does nothing until the player chooses to keep it. Keeping it is a small, deliberate press, like a pencil tick in a margin. The board in front of Vera is a tray of index cards she wrote herself; each card is something she chose to keep.

The anchor is the parcel slip. Its serial, IV/4471/R.31, is typed on the slip and appears again, word for word, on a register leaf in a different folder. The player sees the match before trying it. Putting the two cards together is a check, not a guess. They click, the line *the parcel was medicine* appears in typed carbon, and the ledger's WARN, which was VOID, can now be chosen. As in Return of the Obra Dinn, the click confirms what you already worked out. As in Her Story, nobody else has read both papers. And every fact you hold is one the state could learn from you; it becomes theirs only when you write it down.

*Cost accepted:* every link has to be readable from its two facts' own text (a shared serial, name, date or address), which limits how indirect a deduction can be.

**Pillar alignment.** Pillar 1, "every fact is a weapon": a held fact exists to be spent, and the validator refuses one that can never reach a file. Pillar 5, "pressure comes from attention, not reflexes": nothing here is timed, and a wrong pairing costs nothing.

**The one rule the system must obey: the board is a table, not a tally, and a link is read, never guessed.** A held fact is never a point. A failed pairing never costs anything. Every authored link is visible in its two facts' own text before the player tests it. Consequences, enforced in Detailed Design: no numbers anywhere on the board (no count of facts held or links found, no percentage, no completion state); a failed test costs no time, no attention, no dossier read and no line of dialogue, and its reply is a plain typed *no connection*; failed tests leave no mark (a grid of tried pairs turns the board into a checklist to sweep); brute force is answered by authoring, not by a cap: the content lint rejects a link whose two facts share no visible token (name, serial, date, address or object), so the player never needs to try every pair; no decision is gated by how many links have been made (facts change which options exist, never whether the decision itself is available, Pillars 3 and 5); facts and links are never graded, only true or not yet known (anti-pillar: not a morality meter). *Design test:* can the player tell, from the board alone, how well they are doing? If yes, it is a defect.

## Detailed Design

### Core Rules

*Drafted with the game designer (primary), the systems designer, the narrative director and the gameplay programmer. Rulings where they differed are stated in place; the creative director's Player Fantasy rule overrides three of them. Items marked **(PROV)** rest on a system whose GDD is not yet written; two small amendments to GDD 2 are requested in Rule 2.*

**0. Vocabulary.** A *fact* is a thing a protagonist knows, held by the player; it is never dossier state (GDD 1 Core Rule 1). A *primary* fact is yielded by a document line or a dialogue item; a *derived* fact is yielded by a *link*, an authored pair of facts. The *held set* is the facts a protagonist holds in the current chapter. The *board* is the held set as the player sees it. A *use* of a fact is a path from it, through `has_fact` gates, to something that carries an effect (Rule 5). A hotspot is *filed* when at least one fact its content yields is held (GDD 3 Rule 0).

**1. A fact is a thing a protagonist knows; it is never dossier state.** `Fact {id, text: fact.<id>, kind, yielded_by[], derived: bool, depth, chapter}`. `kind ∈ {name, date, place, serial, object, statement}` is the narrative director's closed list: a fact is anything that fits in a register column (serial, subject, address, status, cross-reference, receipt); if the state could type it into one cell it is a fact, and if it needs a sentence it is a conclusion, which only links produce. `kind` is display and lint data only; no rule branches on it. A `statement` is what a document *states*, prefixed by its stating verb (`Stated:`, `Status:`, `Seen:`, `Leaves:`), never what it means. `yielded_by` is a list because the same fact may be born on two sources; the first hold wins and the second is idempotent. The held set is one set of fact ids per chapter with, per entry, the `source` it was held from and a monotonic `seq` (board order and save replay). *Rationale:* GDD 1's sorting rule puts `knows_parcel(vera)` here precisely because no organ of the state has "Vera knows" on paper. *Rejected:* a `kind`-dependent rule (a writer could be wrong in a way that breaks play).

*Lifetime: no fact crosses a chapter, ever.* The held set is wiped at `chapter_close`, like GDD 1's chapter sheet, and there is no `carried` flag. Pillar 4 taken literally: consequences cross "through dossier states, never bespoke branch trees". A fact that followed Vera into Jan's chapter would be a second cross-chapter channel, outside GDD 1's read budget, invisible to the Rules system, and Jan would "know" something no paper says, breaking "every fact learned is one the state could learn". The brief's cross-life channels are all paper: V7 gives Jan a *document* whose lines yield Jan's own facts; V2 reaches Tomas as a list; V9 reaches Jan as `under_observation`; GDD 2's Edge Case 27 is the clincher (Jan holds the courier's name as a fact; Vera's forms print "name not established" until a dossier field says otherwise, and then the name renders from the cast table: the knowing crosses as a field, never as a held fact). *Rejected:* `carried: true` (cheap to build, expensive to reason about; the use check would need a cross-chapter path search). **(PROV: Chapter & Story Structure owns `chapter_close`; this GDD registers a hook on it.)**

**2. Facts are yielded three ways, and the rule differs by surface because the act of knowing differs.**

*(a) Document lines: explicit hold.* When the player activates a `paper` or `object` hotspot, Scene Flow resolves the content action (GDD 2's scene action table; this system never imports the scene vocabulary) and calls `open(document_id)`; this system returns the document for Paper UI to open and marks every fact on its lines **holdable** whose line currently prints in its entry form. The player holds a fact by one `activate` (press and release, GDD 3's closed set; no drag) on the carbon-blue underlined span (art bible C4); `hold(fact_id, source)` runs, `fact_held` fires, the span gains its double-strike ghost and "cc". Opening a document holds nothing. *Rationale:* noticing is the competence the game tests, and the prototype's board only made sense once holding was a deliberate act; a player who holds nothing from a memo has a board that reflects their reading. *Rejected:* automatic hold on open (every document becomes a loot bag; the first-session board would carry twelve facts the player never read).

*(b) Dialogue lines and answers: automatic.* A fact declared on a dialogue `line` (heard) or `answer` (chosen) is held when the item is shown or chosen, before the answer's `effects` run, through the same `hold()` call, with source `dialogue_id/item_id`. Berta's paper answers are document lines and are held explicitly, consistent with her never saying a name aloud. *Rationale:* dialogue is forward-only (GDD 2 Rule 5c), so there is no re-read; you heard it, you have it. **(Amendment requested of GDD 2: `yields[]` on the `line` and `answer` rows of Core Rule 5, which Rule 9's `fact_index()` and V28 already assume; the ungated fallback answer may yield nothing.)**

*(c) Links: derived (Rule 3).*

*Gating at source.* A document line yields **only while it prints in its entry (`true`) form** or is unbound (always prints). Struck lines and gaps yield nothing: a strike is readable but it is the absence of a record, and "this was struck" is authored, if needed, as its own marginalia line bound to the field that struck it. So the dossier gate on a paper fact is the line's `bind`, which GDD 1's projection already evaluates and GDD 2's lint already counts in `R_c`; this system adds no reads of its own. A dialogue item's gate is its existing `when`. The narrative director's act-one gated facts map onto binds: the carbon-box line bound to `vera.discrepancy` (the carbon exists to be found once the report was burned), Kastan's book line bound to `vera.household_flagged`. *Rejected:* a `when` on `yields` (a second condition site on a line; GDD 2 wants one place to look for a fact's birth, and lines have no `when` by design, Rule 4).

*Re-reading a `filed` hotspot* (GDD 3 Edge Case 13) opens the same document; held spans show their ghost; unheld holdable spans remain holdable, because a player who took one name from a forty-leaf folder may come back for the date; re-holding is idempotent (no second `fact_held`, no change to `seq`). A document whose binding changed since the first read shows the struck form and that span is no longer holdable; a fact already held from it **stays held**, because knowledge is not un-known when the paper is corrected. That last point is the real reason facts are not dossier state. A line never loses a fact on re-read.

**3. A link is an authored pair that yields a derived fact; one mechanism, not two.** `Link {id, from: [a, b], yields: derived_fact_id, text: fact.link.<id>}` is a GDD 2 object type this GDD asks GDD 2 to add (its syntax is GDD 2's; its meaning is here). `pair(a, b)` with `a ≠ b`, both held, keyed on the unordered pair: if a link exists, the derived fact is held with source `link:<id>`, `fact_held` and `link_made` fire, and the link's `text` is returned for Paper UI to type out (the "click"). Everything a link "unlocks" is then an ordinary `{has_fact: derived}` gate (Rule 4). A link is **pure**: two held facts in, one derived fact out, always; it never takes a dossier condition as a third input (a click that fails today and succeeds tomorrow with no change on the board is state leaking into the player's possessions; gate the yielding source or the target instead). *Rationale:* the prototype's surprise was that "each link either unlocks an option, a question, or changes what the ledger says you know"; all three are `has_fact` gates on the derived fact. *Rejected:* `Link.unlocks[]` of content ids (two unlock grammars, two lint paths, ids that drift when a dialogue is renamed); three-input links (two cards click, three is a puzzle).

*Failed pairs.* If no link matches, `pair` returns `{linked: false, derived: null, text: fact.no_link.<protagonist>}`, `pair_failed(a, b)` fires, and the pair enters a *tried set* that is **telemetry only**: it is never drawn, never saved, and never changes a reply. The reply is one typed line per protagonist register, neutral, never mocking (`No cross-reference.` / `Nothing between them.` / `Not on the same line.`), never per pair (per-pair prose would leak which pairs are nearly right). There is no cost, no counter, no cooldown and no attention effect (Pillar 5: a wrong guess in your own head is not attention). *Ruling:* the game designer and the systems designer proposed a faint tried-mark so a keyboard user can tell a tried pair from an untried one; the creative director's rule that the board is a table, not a tally, overrides it, because a grid of marked pairs turns the board into a checklist to sweep, and a re-tried pair costs nothing. Brute force is answered by authoring (Rule 5's lint: a link's two facts must share a visible token), not by a cap or a mark. *Rejected:* a hint after N failures (a counter in disguise).

*Chaining and depth.* A derived fact may be an input to a further link, with `LINK_DEPTH_MAX` = 2: a primary fact has depth 0, a derived fact's depth is 1 + max(input depths), links form a DAG, and the lint errors on a link whose derived fact would exceed the cap. Two is enough for "name + address → the neighbour; the caretaker's receipt + the address → the watched stair" and keeps Jan's pinboard a tree the eye can follow. *Rejected:* unbounded chaining.

**4. A fact unlocks only through `has_fact`, and never a hotspot or a line.** Legal gate sites: a dialogue `answer.when` or `line.when`, a decision `option.when`, a scene `exits[].when` (a door is a threshold, not an object to file; **PROV: Scene Flow**), and a scene `action.when` only where the hotspot has another action with no `has_fact` leaf (a new lint check: the gate selects *which* action runs on a present hotspot, never whether the hotspot exists). A fact cannot make a `hidden` hotspot appear (GDD 3's Player Fantasy forbids late-appearing hotspots, and availability changes only in answer to the player through a hotspot event, not through the board). A fact cannot unlock a document line: lines have no `when` and must not get one, because paper shows what the *state* has on paper (GDD 1 Core Rule 1), and a line that appeared because Vera knows something would be the player's knowledge printed on the state's form. If a writer wants "once you know the parcel, the folder reads differently", that is an answer or an option that reads differently, or an effect that writes the paper. *Rejected:* `has_fact` in `bind` (the projection memo would depend on the held set, which GDD 1 never sees).

**5. "Every fact has a dossier use" is a compiled registry, and this is the exact definition of a use.** At build time GDD 2's compiler produces, and this GDD owns the meaning of, `FactRegistry`: `facts[{id, kind, text_id, sources[{doc, line} | {dialogue, item}], derived_from: link_id | null, depth, uses[]}]`, `links[{id, from (sorted), yields, text_id}]`. `uses` is derived, never authored. A **use** of fact F is a path F → `{has_fact: F}` (possibly inside `all`/`any`/`not`, possibly through a link to a derived fact G and then G's uses, to `LINK_DEPTH_MAX`) → a target that carries at least one effect: an `answer` or `option` with non-empty `effects[]`, a scene `action` with `effects[]`, or an `exits[].when` that routes. Explicitly not uses: a gate on prose or a `stage` line (V29); a gate on an answer whose only effect is `carry: true` (declining is always available, so gating a decline is not a weapon); a fact whose only use is to feed a link whose derived fact has no use (uses are computed bottom-up, so this falls out). A fact with `uses = []` is V29's error; a link whose derived fact has `uses = []` is the same error naming the link; a link whose two facts share no visible token (a name, serial, date, address or object substring after normalisation) is an error (the link must be readable before it is tested, Player Fantasy). The registry is what switches GDD 2's V28–V29 from registry-absent warnings to errors, what GDD 3's X01 joins against (a hotspot is filable iff some fact in its content action has `uses ≠ []`), and what the simulator's acceptance criterion reads (the registry joined against the dossier schema's field list, GDD 1's Interactions row). *Rationale:* Pillar 1 as a lint, not a review item. *Rejected:* "a fact with a reader anywhere counts" (a `has_fact` on an epilogue line would pass a fact that changes nothing).

**6. API.** `FactSystem extends RefCounted`, constructed `new(content_store, registry, condition_reader)`; no autoload.
- `open(document_id) → {holdable: [{fact_id, line_id, held}]}` and `open_dialogue(dialogue_id)`: Scene Flow calls them after resolving the hotspot's action; `holdable` is computed by evaluating each yielding line's bind through the injected evaluator (the one place this system reads the dossier; the reads land in GDD 1's per-chapter read set automatically); the `held` flag lets Paper UI draw the ghost on re-open without a second query.
- `hold(fact_id, source) → {ok, reason: UNKNOWN_FACT | NOT_YIELDED_HERE | ALREADY_HELD}` (`ALREADY_HELD` is a no-op that still returns ok).
- `pair(a, b) → {linked, link_id, derived, text_id}`.
- `held() → [fact_id]` in `seq` order; `has(fact_id) → bool`. This system **is** the `has_fact` provider of GDD 2 Rule 6's reader: a `ConditionReader` class in `src/investigation/` composes `{read, has_fact, phase}` from the dossier reader, this system and the Calendar, is built at chapter open, and is what Dialogue and Filing evaluate against (a testable object, not a closure).
- `board() → view` (Rule 7); `filed_documents() → [document_id]` so Scene Flow maps document to hotspot and calls `set_hotspot_state(id, filed)` itself, synchronously on `fact_held` and again after a load (GDD 3 persists nothing).
- `serialize() → {schema_version, chapter_id, held: [{fact, source, seq}], made: [link_id], next_seq}`, all sorted; `deserialize(data)` only at a scene boundary, rejecting any other `schema_version` whole (GDD 1 Rule 10's shape; Save/Load owns the registry and migration). Plain data, never a resource. The tried set is not saved (telemetry only, Rule 3).
- `chapter_close()` wipes held, made and the tried set and resets `next_seq`.
- Signals: `fact_held(fact_id, source)`, `link_made(link_id, derived_fact_id)`, `pair_failed(a, b)`, `document_filed(document_id)` (emitted once, on the first hold from that document).

*6a. Which hotspots are filed.* A hotspot is filed when **at least one** fact yielded by its content action is held (`≥ 1`, not all). *Rationale:* the ghost means "I have been here and took something", and the read count is "documents mined", not "documents exhausted"; under "all", a folder with one line struck by the dossier could never read as read, and the count would quietly punish the player for the state's redactions. *Rejected:* "all facts held" (above); "filed on open" (filing would be a click, not an act of knowing, and X01's "filable" would mean "openable").

**7. The board is data; Paper UI renders three forms.** `board() → {protagonist, form: cards | pinboard | margin, facts: [{id, kind, text, source, seq, derived, depth}], links_made: [{id, a, b}]}`. Vera's form is index cards in a tray, in her hand, in pencil (pencil rubs out; nothing on a card is yet the state's), a small source cite in the corner; Jan's is torn fragments of the source with his press's typed caption; Tomas's is the stencil margin of the list he was issued (he annotates the state's paper because he has none of his own). The data is identical in all three; only `form` differs, read from the chapter's protagonist. The board **never exposes which facts have been used** or which gates they pass (a "used" tick would project a `when` evaluation and leak the dossier), carries **no numbers** (no count, no percentage, no completion state), and draws no tried pairs. *Rejected:* a per-protagonist data shape (three renderers is already the cost).

**8. Reads.** This system reads the dossier only through GDD 2's `Condition.evaluate` with the injected reader (`is_true/is_false/is_unknown`, `at_least/at_most` by constant name), and only where content already placed a condition (a line's bind, an item's `when`). It evaluates nothing of its own invention, so every read it causes is a content read already counted in `R_c` by `Condition.fields_in`; `has_fact` counts zero. It never writes: no effect, no sheet field, no tag.

**9. Headless.** `RefCounted`, constructor-injected, no autoload, no scene tree, no file I/O (the content store and registry are handed in already loaded); the held set is a sorted array so `serialize()` is byte-stable and `has()` is a bisect; `tools/sim/` drives it by calling `hold`/`pair` from a script of player intents and asserting `has()`; the CI path check forbids any import from `src/scene/engine/*` or the scene vocabulary. **NOT SOURCEABLE** and routed to GDD 3's spike: `signal` on a `RefCounted` emitting with no scene tree; `@abstract` syntax for the reader interface; and, for Paper UI, the `RichTextLabel` meta-click and hover API (only `push_meta`'s tooltip parameter is in the pinned reference, ui.md line 31), with one Control per fact span as the fallback that also gives AccessKit a role per fact.

**10. What the player cannot do.** No deleting a fact (knowledge is not un-known; the only wipe is the chapter's). No sharing between protagonists. No "search" verb, no "investigate room" button, no auto-link: the reveal hold (GDD 3 Rule 6) is the whole of "search", and it shows hotspots, not facts. No holding from the dossier's Files view (a projection of the state's paper, never a yield source, so the registry compiles from content alone). No pairing a fact with itself, no three-fact links, no ordering of inputs. No count gate on any decision (`MIN_LINKS_FOR_DECISION` does not exist: the decision is always available and facts change its options, Pillars 3 and 5). No hold budget (a fact you are not allowed to take is not a weapon, Pillar 1).

**11. Fact and link text rules (the narrative director's; enforced by GDD 2's lint).** A display string is a noun phrase of at most `FACT_TEXT_CAP` characters: no terminal full stop, no `if`/`so`/`because`/`then`/`means`, no second-person pronoun; a `statement` begins with a stating-verb token. A link line is at most `LINE_CAP` characters, present tense, in the protagonist's voice (free indirect, third person, as the beats are, never "you"), states the connection and nothing after it, and never names its unlock (reject an action or option display name, a question's text, or the tokens `unlock`, `option`, `question`, `can now`, `may now`). No fact text contains a dossier field's projected value string (`incomplete`, `pending`, `ACTIVE, observation`, `deferred`): a fact's text is frozen at hold and must stay true after the dossier moves, so F8 names "the household card", never "incomplete". A primary fact's string is quotable from its yielding line after normalisation or carries a source cite. Every `statement` fact has at least one link or `has_fact` gate (the kind most likely to be flavour).

**12. Act-one example (Vera's office; content, not rules; the narrative director's enumeration).** Six documents: 4471 (K-1 cover, leaf 40, parcel slip), the intake log, the District Register, the Halm household card with the university slip, Kastan's building book, the carbon-box sheet. Twelve primary facts holdable at once and a thirteenth gated by a bind, under `FACTS_PER_SCENE_MAX`: `serial_4471` (serial), `subject_sokol` (name), `vrba_9_3` (place), `parcel_was_medicine` (statement, `Stated: medicine, foreign`, the brief's locked `knows_parcel`, the `has_fact` gate on V6 `warn`), `source_riba_118` (serial), `intake_bl` (name), `leaves_blank` (statement), `household_card_halm` (serial), `ilona_review_slip` (object), `rcpt_118_caretaker` (name), `cellar_tenant_rusek` (name), `ilona_on_cellar_stairs` (statement, Kastan's spoken line, held automatically), `carbon_leaf40` (object, bound to `vera.discrepancy`, the gate on V4 `recover-report`). Six links: `subject_sokol + vrba_9_3 → her_neighbour` (Berta's "I know her. She is sick." question); `serial_4471 + household_card_halm → missing_entry_4471` (a variant cost line on V2); `intake_bl + leaves_blank → gap_under_berta` (a variant on V3 and the gate on V8 `take-blame`); `source_riba_118 + rcpt_118_caretaker → riba_is_kastan` (Kastan's "Receipt 118" question); `cellar_tenant_rusek + ilona_on_cellar_stairs → ilona_in_circle` (the brief's `knows_ilona_circle`, the gate on V9); `riba_is_kastan + vrba_9_3 → stair_is_watched` (depth 2; a variant cost line on V6). Three links make the filing decision informed, the prototype's 3 of 6; V2 and V3 are never gated by count. Click lines in Vera's voice: "Flat 3. One landing down. Eleven years of the same stair, and she knows the cough." The narrative director's open question, recorded in Open Questions: whether `parcel_was_medicine` stays a direct yield of leaf 40 (locked) or becomes the link of `Stated: medicine, foreign` with the subject line, so that V6 `warn` costs a noticing rather than a read.

### States and Transitions

**Fact (per chapter, per id):** `unheld` → `holdable` (its document is open and the line prints in entry form; transient, recomputed on every `open`) → `held` (on `hold`; or directly `unheld → held` for a dialogue yield or a link). `held` is absorbing until `chapter_close`, which returns every fact to `unheld` and clears `seq`. A `holdable` fact whose document closes returns to `unheld` silently.

**Link (per chapter, per id):** `untried` → `made` (its inputs were paired). `made` is absorbing until `chapter_close`. The tried set of failed pairs is telemetry, not a state. A pair that is later authored into a link (a content patch mid-save) is simply `untried` in the registry.

**Hotspot filed-ness (not stored here):** derived at any moment as `∃ f ∈ facts(hotspot's action): held(f)`; Scene Flow transitions availability on `document_filed` and re-derives from `filed_documents()` after a load.

**Save:** `serialize()` is legal at any scene boundary mid-chapter; after `chapter_close` the payload's `held` and `made` are empty and `chapter_id` is the closed chapter's (GDD 1's "after `chapter_close` the sheet is empty", mirrored).

### Interactions with Other Systems

| System | Receives from this GDD | Gives to this GDD | Interface owner |
|---|---|---|---|
| **Scene & Interaction Framework** (GDD 3) | nothing directly; Scene Flow mediates | `hotspot_activated`, `hotspot_examined` via Scene Flow; the filed meaning (Rule 0) | GDD 3 (events); this GDD (what a hotspot yields, when it is filed) |
| **Scene Flow (PROV)** | `open`/`open_dialogue` results, `fact_held`, `document_filed`, `filed_documents()` | the resolved document or dialogue id after a hotspot event; it calls `set_hotspot_state(filed)` itself | Scene Flow (availability, the boundary order); this GDD (the filed rule) |
| **Narrative Content Format** (GDD 2) | the registry's semantics (Rule 5), the `link` object's meaning, the legal `has_fact` sites (Rule 4), the text rules (Rule 11), the `fact.no_link.*` and `fact.link.*` ids | `fact_index()`, `link` declarations, `yields[]` on lines and dialogue items, `Condition.evaluate` and `fields_in`, the `fact.*` namespace, V28–V29 switched to errors, V42 | GDD 2 (syntax); this GDD (semantics) |
| **Dossier State Model** (GDD 1) | nothing (never writes) | `read(target, field)` only through the evaluator; the schema field list for the registry join | GDD 1 (read API); this GDD (held facts) |
| **Paper UI (PROV)** | `board()`, the opened document and `holdable` list with `held` flags, link text to type, `fact.no_link.*`, the signals for the "click" | the player's `activate` on a span → `hold`; two selected cards → `pair` | Paper UI (rendering, the three forms' look); this GDD (data, events) |
| **Dialogue & Interrogation (PROV)** | `has()` through the `ConditionReader` for item gates | the shown line's or chosen answer's `yields[]` → `hold()` before effects | Dialogue (when); this GDD (that it is held) |
| **Filing & Decision (PROV)** | `has()` through the `ConditionReader` for option gates | nothing | Filing (the cost rule); this GDD (what is held) |
| **Calendar, Regime Phase & Attention (PROV)** | nothing | `phase()` for the `ConditionReader` | Calendar |
| **Save/Load (PROV)** | `serialize()/deserialize()`, `SCHEMA_VERSION` | the payload at a scene boundary | this GDD (shape); Save/Load (registry, migration) |
| **Chapter & Story Structure (PROV)** | `chapter_close()` hook | the chapter's protagonist (board `form`) and id | Chapter (when); this GDD (what is wiped) |
| **Reactive Event Rules & Story Simulator (PROV)** | `hold`/`pair`/`has` for programmatic play; the registry for the acceptance criterion | scripted intents | the simulator (the run); this GDD (the check) |


## Formulas

*Proposed by the systems designer. `F_c` = primary facts of chapter `c`, `D_c` = derived facts, `L_c` = authored links, `H_c(t)` = the held set at time `t`. Constants live in `assets/data/investigation/tuning.json` (D) unless marked.*

### 1. Fact density per scene

The fact density formula is defined as:

`facts_per_scene(s) = Σ_{h ∈ paper(s)} |yields(h)| + Σ_{d ∈ dialogues(s)} |yields(d)|`, with the checks `|yields(h)| ≤ FACTS_PER_DOC_MAX` (error) and `facts_per_scene(s) ≤ FACTS_PER_SCENE_MAX` (error). Derived facts are excluded (counted by §6), and so are bind-gated facts (lines bound to a dossier field, which print only when the state has acted): the count is of facts holdable at scene open, so Core Rule 12's twelve plus one gated fact passes. The runtime never refuses a hold (§6).

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `paper(s)` | set | 0–8 | data file (GDD 3 `hotspot_counts.total`, kind ≠ person) | Paper and object hotspots in scene `s` |
| `yields(h)` | set | 1–`FACTS_PER_DOC_MAX` | data file (GDD 2 `yields:`) | Facts declared on the hotspot's document lines (V42: at least one) |
| `yields(d)` | set | 0–`FACTS_PER_DOC_MAX` | data file | Facts on a dialogue's items |
| `FACTS_PER_DOC_MAX` | int | 2–6 | constant (4) | Facts one document may declare |
| `FACTS_PER_SCENE_MAX` | int | 8–16 | constant (12) | The prototype's noise threshold |
| `facts_per_scene` | int | 1–`FACTS_PER_SCENE_MAX` | calculated | Primary facts the scene can put on the board |

**Output Range:** 1 to 12 at defaults. The theoretical ceiling from the parts (8 × 4 = 32) is far above the scene cap on purpose: `FACTS_PER_DOC_MAX` bounds one document's reading load, `FACTS_PER_SCENE_MAX` bounds the board; at 8 paper hotspots the mean is 1.5 facts per document.
**Example:** the MVP office: six documents yielding {2, 2, 1, 2, 1, 1} = 9, two conversations {1, 0} = 1 → 10 ≤ 12, two facts of headroom. *Rejected:* a pure product `n_h × FACTS_PER_DOC_MAX` (a six-document scene could hold 24, double the prototype's noise line).

### 2. Link coverage

The link coverage formula is defined as:

`link_coverage(c) = |L_c| / C(|F_c| + |D_c|, 2)`, with `C(n, 2) = n(n − 1)/2`; an authoring warning outside `[LINK_COVERAGE_LOW, LINK_COVERAGE_HIGH]`, never an error.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `L_c` | set | `LINKS_PER_SCENE` × scenes | data file (`link` objects) | Authored links whose inputs are holdable in `c` |
| `F_c`, `D_c` | set | 1–`HELD_MAX_WARN` | calculated (registry) | Primary and derived facts of `c` |
| `LINK_COVERAGE_LOW` | float | 0.05–0.20 | constant (0.10) | Below it most pairs fail; the board reads as guessing |
| `LINK_COVERAGE_HIGH` | float | 0.35–0.70 | constant (0.50) | Above it everything connects; noticing stops mattering |
| `link_coverage` | float | 0–1 | calculated | Fraction of possible pairs that click |

**Output Range:** 0 to 1; undefined below two facts (the check is skipped with a warning "chapter has no board"). 1.0 is a warning, not an error, because an epilogue chapter with two facts and one link is legitimately 1.0.
**Example:** the MVP chapter, 10 primary + 4 derived = 14; `C(14, 2) = 91`; 6 links → 0.066, below 0.10 → warning; the lever that works is links, not facts (the prototype's 6 over 8 facts was 0.21, inside the band). *Rejected:* coverage over `|F_c|` only (derived facts are on the board and pairable).

### 3. Dossier-use predicate and dead ends

The dossier-use predicate is defined as:

`use(f) = [∃ t ∈ targets(c): effects(t) ≠ ∅ ∧ has_fact(g) ∈ leaves(when(t)) ∧ g ∈ reach(f)]`, with `reach(f) = {f} ∪ {yields(l) : l ∈ L_c, f ∈ from(l)} ∪ …` to depth `LINK_DEPTH_MAX`; the build gate `dead_end_facts(c) = {f ∈ F_c ∪ D_c : ¬use(f)} = ∅` (error; GDD 2 V29 in registry-present mode).

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `targets(c)` | set | — | data file (GDD 2) | Actions, decision options, dialogue items and routed exits of `c` |
| `effects(t)` | set | — | data file | Dossier writes on `t` (or a routed exit); empty = flavour; `carry` alone does not count |
| `reach(f)` | set | 1–`1 + 2^LINK_DEPTH_MAX` | calculated | `f` and everything a link chain from `f` can yield |
| `dead_end_facts` | set | ∅ expected | calculated | Facts with no path to a consequence |
| `use` | bool | — | calculated | Pillar 1's test per fact |

**Output Range:** boolean per fact; the gate is the empty set. Not a use: a gate on prose, a gate on a decline, a gate whose only effect yields another fact that itself has no use (uses are computed bottom-up).
**Example:** `cellar_tenant_rusek` feeds the link to `ilona_in_circle`, which gates V9 `report-jan`, which writes `jan.under_observation` → `use = true` at depth 1. A fact `clerk_shift_time` with no link and no gate → in `dead_end_facts` → build error "fact has no dossier use". *Rejected:* counting "participates in a link" as a use (the derived fact could then be the dead end).

### 4. Pairing cost and the informed-decision ratio

The pairing cost is defined as:

`cost(a, b) = 0` for every pair; `pair_attempts(c) = |tried_c|` and `informed(c) = links_made(c) / |L_c|` are telemetry, never read by any condition.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `tried_c` | set of pairs | 0–`C(n, 2)` | runtime (telemetry, not saved) | Distinct failed pairs tested in `c` |
| `links_made(c)` | int | 0–`|L_c|` | runtime | Authored links clicked |
| `informed` | float | 0–1 | calculated (telemetry) | The prototype's "3 of 6" = 0.5 |
| `INFORMED_HYPOTHESIS` | float | 0.3–0.7 | constant (0.5), PROV | The playtest band, not a gate |

**Output Range:** `cost` is identically 0 (Pillar 5: no guessing tax); `informed` 0 to 1, and 0 is a legal way to reach the filing decision (Pillar 3).
**Example:** MVP with 6 links; a player makes 3 → 0.5; another makes 0 and files on instinct → 0; both reach the pen-in-hand screen. The playtest question is whether the 0 player says "I didn't know enough", not whether the game stopped them. *Rejected:* `MIN_LINKS_FOR_DECISION` (a lock-and-key that tells the player how many facts exist).

### 5. Read-budget contribution (restated from GDD 2 §7; not redefined)

The Fact system's contribution to GDD 1 §6's `R_c` is defined as:

`R_c^fact = ⋃_{src ∈ yielding(c)} fields_in(bind(src) | when(src))`, already a subset of GDD 2's `⋃ fields_in(conds(c))`; `fields_in(has_fact(·)) = ∅`; links contribute nothing (they carry no condition, Rule 3).

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `yielding(c)` | set | — | calculated (`fact_index`) | Sources that declare `yields` in `c` |
| `fields_in` | map | — | GDD 2 Formulas §7 | Condition leaf → dossier fields; `has_fact → ∅` |
| `R_c^fact` | set | 0–`READ_MAX` | calculated | Fact-gated reads; counted once by GDD 2's lint, never again here |

**Output Range:** 0 to `READ_MAX` (20); this GDD adds no threshold. **Example:** the carbon-box line bound to `vera.discrepancy` → `{vera.discrepancy} ∈ R_c`; V9's `has_fact(ilona_in_circle)` → ∅. *Rejected:* a separate `FACT_READ_MAX` (one budget, one lint).

### 6. Held-set size (authoring warning, no runtime cap)

The held-set bound is defined as:

`held_peak(c) ≤ |F_c| + |D_c|`, with the authoring warning `|F_c| + |D_c| > held_warn(c)`, `held_warn(c) = min(HELD_MAX_WARN, BOARD_CAPACITY[form(c)])`. At runtime nothing refuses a hold.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `held_peak` | int | 0–`|F_c| + |D_c|` | runtime (telemetry) | Largest `|H_c(t)|` in the chapter |
| `HELD_MAX_WARN` | int | 10–24 | constant (16) | Board-noise line at chapter level |
| `BOARD_CAPACITY[form]` | int | §7 | constant | Per-form board page size |
| `held_warn` | int | ≤ 16 | calculated | Effective warning threshold |

**Output Range:** warning only. A runtime cap would force a discard, and "which fact is worthless?" is a question the game must never ask (Pillar 1). Overflow is a presentation problem (a second tray page, Paper UI's) and a content problem (the warning, this GDD's).
**Example:** MVP, 13 + 6 = 19 > 16 for Vera → warning "tray overflows one page": the writers trim or accept two pages. *Rejected:* a hold budget as a spend (facts are the player's and cost nothing to keep).

### 7. Board capacity per protagonist form

The board page formula is defined as:

`board_pages(c, t) = max(1, ⌈|H_c(t)| / BOARD_CAPACITY[form(c)]⌉)`

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `BOARD_CAPACITY[vera]` | int | 12–20 | constant (16) | Index cards visible in the tray (two rows of eight) |
| `BOARD_CAPACITY[jan]` | int | 8–16 | constant (12) | Pinboard fragments with typed captions; dense art, fewer slots |
| `BOARD_CAPACITY[tomas]` | int | 12–24 | constant (20) | Margin lines of the log; a line is cheap |
| `board_pages` | int | 1–3 | calculated | Pages Paper UI renders |

**Output Range:** 1 to 2 at defaults; 3 only if a chapter ignores §6's warning. **Example:** Vera at 14 held → 1 page; Jan at 14 → 2 pages (and §6 warned). *Rejected:* one capacity for all forms (Jan's fragments are physically larger than Vera's cards, art bible §7.2).

### 8. Chain depth for derived facts

The chain depth formula is defined as:

`depth(f) = 0` for `f ∈ F_c`; `depth(yields(l)) = 1 + max(depth(a), depth(b))` for `from(l) = [a, b]`; check `depth(f) ≤ LINK_DEPTH_MAX` (error); links form a DAG (`yields(l) ∉ from(l)`, no cycle; error).

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `from(l)` | pair | exactly 2 | data file | The two input facts (unordered) |
| `LINK_DEPTH_MAX` | int | 1–3 | constant (2) | Longest chain a board must show |
| `depth` | int | 0–`LINK_DEPTH_MAX` | calculated | Per fact |

**Output Range:** 0 to 2. **Example:** `riba_is_kastan` (1) + `vrba_9_3` (0) → `stair_is_watched` (2); a link consuming that → error. *Rejected:* depth 3 (five primary facts in one line of reasoning, which the tray cannot lay out).

### 9. Playtest telemetry (observed, never gates)

The investigation telemetry is defined as:

`t_first_link(c) = t(link_made₁) − t(scene_ready₁)`; `facts_held_at_decision(c) = |H_c(t_decision)|`; `held_fraction(c) = facts_held_at_decision / (|F_c| + |D_c|)`.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `t_first_link` | float s | 0–∞, null if none | runtime | Time from the first scene ready to the first click |
| `facts_held_at_decision` | int | 0–`|F_c| + |D_c|` | runtime | Board size at the filing decision |
| `held_fraction` | float | 0–1 | calculated | Completionism signal (the prototype's open question) |
| `T_FIRST_LINK_HYPOTHESIS` | float s | 120–600 | constant (300), PROV | The band to test, not to tune against |

**Output Range:** unbounded above; `null` is a real value (a player who never linked) and is recorded, not dropped. **Example:** 240 s, 11 of 19 held, 3 of 6 links → within hypothesis. *Rejected:* a hint timer keyed to `t_first_link` (a reflex of the system on behalf of the player, Pillar 5).

## Edge Cases

*From the systems designer over the rule and formula space; entry 22 settles the fact-count semantics with Formulas §1.*

1. **If the same fact is declared on two sources and is held from both**: the first `hold` wins (`source` and `seq` are set once); the second returns `{ok: true, reason: ALREADY_HELD}`, fires nothing and leaves `seq` untouched. Both documents are filed, because filed-ness is derived from the held fact, so Scene Flow ghosts the second hotspot on the first `fact_held` even if that paper was never opened. *One knowing, two papers.*

2. **If a fact is held and a dossier write then strikes its yielding line**: the fact stays held, its text frozen as at hold, its card unchanged. On re-open the line prints in its struck form, is omitted from `holdable`, and carries neither the carbon-blue underline nor the ghost (a strike has no span). *Knowledge is not un-known when the paper is corrected.*

3. **If a document is re-opened after a line newly prints in entry form**: `open()` lists the new fact in `holdable` with `held: false`; earlier holds keep their `seq`; the document's filed state does not change. *The bind is the only gate, so flipping it is the authored way to let a document grow.*

4. **If `pair(a, a)` is called, or either input is unheld**: returns `{linked: false, link_id: null, derived: null, text_id: null}`; no `pair_failed`, no tried-set entry, no typed line. *These are malformed calls (a script or a stale UI), not guesses; Paper UI never offers a selected card to itself.*

5. **If `pair` is called on a link already made, in either ordering**: the key is unordered, so it is the same link; it returns `{linked: true, link_id, derived, text_id}` so Paper UI may retype the click, but no `fact_held`, no `link_made`, and `made` and `seq` are unchanged. *`derived_from` is singular, so two links declaring the same `yields` is a build error and "derived fact already held by another route" cannot arise.*

6. **If a derived fact is also declared primary on a line or dialogue item**: build error (`sources ≠ []` while `derived_from ≠ null`). *Its depth would be ambiguous, and a primary hold would make the link's click yield nothing.*

7. **If a link's derived fact would reach depth 3**: build error naming the link (§8). The same check errors on a cycle or on `yields(l) ∈ from(l)`. *Five primary facts in one line of reasoning is more than the tray can lay out.*

8. **If a link's two facts share no visible token after normalisation**: build error naming the link (Rule 5). *The pair must be readable before it is tested; an unreadable link invites the brute force the tried set no longer marks.*

9. **If a `has_fact` gate sits on an action of a hotspot authored `hidden`, or on an action with no sibling action free of a `has_fact` leaf**: build error (GDD 3's new check). *In both cases the fact decides whether the hotspot does anything at all, which is existence, not selection.*

10. **If `has_fact` appears in a document line's `bind`**: GDD 2's lint errors on the leaf. *The projection never sees the held set; a bind it cannot evaluate would print the player's knowledge on the state's form.*

11. **If a fact's only path is a gate on a decline answer (`carry: true` alone)**: `dead_end_facts` error naming the fact and the answer; the writer gates a non-decline answer or removes the yield. *Declining is always available, so gating it changes nothing (§3).*

12. **If `deserialize` finds a held fact or made link the registry no longer declares, or declares for another chapter**: drop that entry, log a warning, keep the rest, keep `next_seq`. *A content patch must not void a save; a `schema_version` mismatch is the only whole refusal.*

13. **If `deserialize` is called mid-dialogue, or anywhere but a scene boundary**: refused with `BOUNDARY_ONLY`, state untouched. *A dialogue yield is held before its effects run; splitting that pair across a load would desynchronise the board from the sheet.*

14. **If `chapter_close` fires while a document is open**: the wipe is immediate and also clears the open document's holdable set; a late `hold` returns `NOT_YIELDED_HERE`, a late `pair` returns `linked: false`, nothing fires. *Chapter owns the order of the boundary; this system is safe when the order is wrong.*

15. **If a dialogue `line` with `yields` is shown twice (the dialogue re-entered)**: `hold` returns `ALREADY_HELD`, ok, no signal, no `seq` change. *Hearing it again is not knowing it twice.*

16. **If a thirteenth fact is held on a twelve-fact board**: `hold` returns ok, `seq` increments, `board_pages` recomputes (§7); nothing refuses. *§1's scene cap is a lint on declarations and §6 is a warning; the held set has no runtime cap, because "which fact is worthless?" is never asked.*

17. **If the `ConditionReader` is asked `has_fact` before any chapter is open**: `false`, no error. *The held set between chapters is empty, and a condition evaluated at the first `scene_ready` must get an answer, not an exception.*

18. **If `open()` is called for a document in another chapter's content**: error `WRONG_CHAPTER`, nothing holdable, no signal; the registry's `chapter` on each fact decides. *Jan's copy of Vera's paper (V7) is Jan's document yielding Jan's facts; no fact crosses a chapter.*

19. **If a scripted `hold` names a fact not holdable in the open document**: `NOT_YIELDED_HERE` (no document open, the line struck, or the fact declared elsewhere); `UNKNOWN_FACT` if the registry lacks it. *The simulator asserts the refusal; it never bypasses `open()`.*

20. **If `fact_held` fires while Scene Flow holds `set_hotspot_state` in a block**: this system fires regardless and waits on nothing; if the block still refuses, Scene Flow re-derives from `filed_documents()` when it lifts, the same path it uses after a load. *A hold is the player's act (an `activate` on a span, or a line they chose to hear), so GDD 3's "only in answer to the player" is satisfied.*

21. **If a chapter resumes from a save**: telemetry is not saved, so `t_first_link` restarts from the resumed session's first `scene_ready`, is flagged `resumed: true` and is excluded from the hypothesis band; if `made` is non-empty on load, no `t_first_link` is recorded for the chapter. *The hypothesis measures an unbroken first encounter, not the time the game was closed.*

22. **If a scene declares more primary facts than `FACTS_PER_SCENE_MAX` once bind-gated lines are counted**: Formulas §1 counts only facts on unbound lines and dialogue items; a fact whose yielding line is bound to a dossier field is excluded from `facts_per_scene(s)`, so Core Rule 12's twelve holdable facts plus one gated fact passes the check at 12 ≤ 12. The runtime never refuses a hold whatever the count. *The cap bounds what the board can show at once; a gated fact prints only after the state moves, and by then the player has usually paired the board down to what matters.*

## Dependencies

*Hard* means the system cannot function without the other; *soft* means it works without it and is improved by it. Rows marked **(PROV)** name a system whose GDD is not yet written. Reciprocity today: GDD 1 lists this system as a reader that never writes; GDD 2 lists it as the owner of fact semantics; GDD 3 lists it as the consumer of hotspot events that decides what a hotspot yields. All three match the rows below.

| System | Direction | Hard/Soft | Interface |
|---|---|---|---|
| Narrative Content Format & Strings (GDD 2) | This depends on it | Hard | `fact_index()`, `link` declarations, `yields[]` on document lines and dialogue items, `Condition.evaluate` and `fields_in`, the `fact.*` namespace; this GDD supplies the registry's semantics, the use definition (V29) and the text rules (Rule 11) |
| Dossier State Model (GDD 1) | This depends on it, read-only | Hard | `read(target, field)` only through GDD 2's evaluator where content placed a bind or a `when`; the schema field list for the registry join; never a write |
| Scene & Interaction Framework (GDD 3) | This depends on it through Scene Flow | Soft | `hotspot_activated`/`hotspot_examined` arrive via Scene Flow; this GDD defines when a hotspot is filed (any fact held) and X01 joins against its registry |
| Scene Flow | Depends on this **(PROV)** | Hard | Calls `open`/`open_dialogue` after resolving a hotspot's action; subscribes to `document_filed` and reads `filed_documents()` to set availability, synchronously and after a load; calls `chapter_close()` |
| Paper UI | Depends on this **(PROV)** | Hard | `board()`, `holdable` lists with `held` flags, link text and `fact.no_link.*`; calls `hold` on a span press and `pair` on two selected cards; draws the three forms |
| Dialogue & Interrogation | Depends on this **(PROV)** | Hard | `has()` through the `ConditionReader` for item gates; hands shown lines' and chosen answers' `yields[]` to `hold()` before effects |
| Filing & Decision | Depends on this **(PROV)** | Hard | `has()` through the `ConditionReader` for option gates; its options are where most uses terminate |
| Calendar, Regime Phase & Attention | This depends on it **(PROV)** | Soft | `phase()` for the `ConditionReader`'s `phase_at_least` leaf |
| Save/Load | Depends on this **(PROV)** | Soft | `serialize()/deserialize()` at a scene boundary; `SCHEMA_VERSION` |
| Chapter & Story Structure | This depends on it **(PROV)** | Soft | The chapter's protagonist (board form) and the `chapter_close` hook |
| Reactive Event Rules & Story Simulator | Depends on this **(PROV)** | Soft | Drives `hold`/`pair`/`has` programmatically; reads the registry for the "every fact has a dossier use" acceptance criterion |
| Art pipeline and Overlay & Surveillance Rendering | None **(PROV)** | — | The carbon ghost on a filed hotspot is Overlay's; this GDD only decides when a hotspot is filed |

## Tuning Knobs

Column key: **D** = `assets/data/investigation/tuning.json`; **B** = build-tool or playtest config; **A** = art bible, by pointer.

| Knob | Default | Safe range | Too low | Too high | Interacts with |
|---|---|---|---|---|---|
| `FACTS_PER_SCENE_MAX` (D) | 12 | 8–16 | Scenes cannot carry enough names to link; writers cut facts, not flavour | The board is noise (the prototype's own line); dead ends creep in | Formulas §1, §6; GDD 3 `hotspot_counts` |
| `FACTS_PER_DOC_MAX` (D) | 4 | 2–6 | Every document is one name; reading stops rewarding | One file dumps the scene's budget; the rest are flavour-only (V42) | §1 |
| `LINKS_PER_SCENE` (B, author target) | 3–6 | 2–8 | Nothing clicks; `informed` floors at 0 | Everything clicks; surprise gone | §2, §4 |
| `LINK_COVERAGE_LOW` / `HIGH` (D) | 0.10 / 0.50 | 0.05–0.20 / 0.35–0.70 | A guessing board | A trivial board | §2 |
| `LINK_DEPTH_MAX` (D) | 2 | 1–3 | No second-order "what you know changed" moments | Chains the board cannot lay out; `reach` explodes | §3, §8, Paper UI |
| `HELD_MAX_WARN` (D) | 16 | 10–24 | Warnings on every chapter; writers ignore them | Overflowing trays go unflagged | §6, §7 |
| `BOARD_CAPACITY[vera / jan / tomas]` (D) | 16 / 12 / 20 | 12–20 / 8–16 / 12–24 | Paging on normal chapters | Cards shrink below the art bible's legibility | §6, §7; art bible §7.2 |
| `FACT_TEXT_CAP` (D) | 48 | 32–64 | Serials and addresses truncate | Cards wrap to a second line | Rule 11; GDD 2 `LABEL_CAP` |
| `LINE_CAP` (GDD 2) | 120 | by pointer | — | — | Link lines |
| `INFORMED_HYPOTHESIS` (B, PROV) | 0.5 | 0.3–0.7 | — (telemetry) | — (telemetry) | §4; the playtest plan |
| `T_FIRST_LINK_HYPOTHESIS` (B, PROV) | 300 s | 120–600 | — | — | §9 |

Interaction clusters: (a) `FACTS_PER_SCENE_MAX` and `LINKS_PER_SCENE` set `link_coverage` together, and the lever that moves coverage is links; (b) `HELD_MAX_WARN` should not exceed the smallest `BOARD_CAPACITY` by more than one page; (c) `LINK_DEPTH_MAX` bounds both the use search and the board's layout, so raising it is a Paper UI change as much as a lint change.

## Visual/Audio Requirements

*Required for a Gameplay system; written with the art director from art bible §4.1–4.2, §4.5, §6.4, §7.1–7.4 and §7.6. Constraints and vocabulary only; Paper UI renders, Overlay draws the room. Nothing here adds a colour, face, icon or motion the art bible does not already permit.*

**1. The holdable span (document).** Four states, each distinguishable by shape alone (§4.5, C4). *Unheld, holdable:* text in UI carbon `#2E3559` (never world carbon for text), one typed rule underline, one margin tick (a 2 px typed mark, pixel-aligned, in the marginalia column). *Focused:* the tick thickens 2 → 3 px and the typewriter caret sits at the span's first character (§7.3); no underline change, no colour change, no lift, because text never moves (§7.4); pointer hover, keyboard focus and a gamepad cursor produce the same state (C2). *Held:* the double-strike ghost plus a typed `cc` in the margin column where the tick was; the underline stays, the tick is replaced, never stacked. *Line now struck (the dossier moved):* the strike only, no underline, no tick, not focusable; a fact already held from it keeps its `cc` (Core Rule 2). Reviewer test: a struck line with a `cc` is correct; a struck line with an underline is a defect. *Keyboard:* spans are Controls in reading order (one Control per span, the Rule 9 fallback, AccessKit role `button` with the fact text as its name); Tab moves span to span within the open sheet; `activate` holds; a held span stays focusable and re-holding is a no-op. No drag, no modifier.

**2. The three board forms** (Core Rule 7; identical data, three renderers). Carbon appears nowhere on the board: the board is the player's copy, in the protagonist's hand, and nothing on it is yet the state's.
- *Vera: index cards in a tray.* Each card a bone sheet at UI value, fact text in her pencil (grey-green cursive; hand registry key `vera_pencil`, a tint variant of her cursive hand, never a fifth face). `kind` → a one- or two-letter typed corner code top-left (N, D, P, S, O, St), a clerk's mark permitted by §7.3. `source` → a typed cite bottom-right at label size, the only typed element on the card, because cursive below 1.2× body is forbidden (§7.2). `derived` → a paperclip over the card's top edge. `depth` → the card's row: depth 0 front, 1 behind, 2 behind that.
- *Jan: torn fragments on the pinboard.* Each primary fact is the source line's own rendered region torn out (a baked torn silhouette, no bend) in whatever hand the source carried, with a typed caption beneath in soot from his press (machine hand `press_jan`). `kind` → a typed code at the caption's head; `source` → the fragment is the cite, the caption repeats the serial; `derived` → a caption-only slip pinned with string from its two inputs; `depth` → tree level left to right, three columns at `LINK_DEPTH_MAX` 2.
- *Tomas: stencil entries in the margin of the issued list.* Khaki stencil capitals (`tomas_stencil`) in the right margin of the state's typed list. `kind` → a stencilled single letter before the entry; `source` → a stencilled abbreviated cite on the same line; `derived` → a stencil bracket joining two entries with the derived entry at its point; `depth` → indent level.

**No number appears on the board.** No count, fraction, percentage, completion mark, card numbering or "of". Numerals inside a fact's own text or cite (`4471`, `118`) are content; any numeral the board generates is a defect. No tried-pair mark of any kind (Rule 3).

**3. The click.** Selecting a card, fragment or entry uses the §3.5 focus grammar (card corner lifts 120 ms; fragment keyline 3 px; margin caret). Two selected and `pair` succeeds: the link line types out at the transcript's character cadence (Paper UI owns the rate; Dialogue's, not a new one) in the protagonist's voice, in the typewriter face in the form's ink (annotation rules bar cursive from body-length lines); then the derived item arrives by sheet slide, 180 ms, ease-out, rigid translate, no rotation beyond 2°: Vera, a pencil tick on each source card's corner and the derived card slides into the tray; Jan, a pin sets on the new slip (90 ms down, no overshoot; the overshoot is the stamp's alone) and the string appears whole with it, never drawn on; Tomas, the bracket appears in one frame, as a stencil does, and the entry types beneath. No glow, particle, pulse, scale, colour shift or shake. *No connection:* a typed slip lifts from under the cursor (the §7.1 tooltip grammar), 120 ms up, holds for reading length, 120 ms down; the selection clears; nothing else on the board changes.

**4. One idea, two layers.** The carbon ghost on a filed hotspot in the room (Overlay, world carbon `#434C7C`, §6.4) and the `cc` plus double-strike on a held span (Paper UI, `#2E3559`) are one mark family: identical offset vector at 720 and 1080, hard edge, no blur, the same typewriter `cc` glyph at label size. Reviewer test: screenshot both side by side; a viewer names them as one thing, "that's been copied". The board carries neither.

**5. Colourblind backups (§4.5).** Unheld = underline and tick; focused = tick thickness and caret; held = double-strike and `cc`; derived = paperclip, string-from-two, or bracket; struck = the strike. Vera's grey-green versus Tomas's khaki = cursive versus stencil plus the chapter tab. On Jan's fragments any carbon span in the torn region renders inert: no underline, no tick, not focusable; the fragment is a cite, not a document.

**6. Hands.** All letterforms resolve through GDD 2's closed hand registry; narrative names keys, art draws them. Proposed keys for the narrative director to confirm: `vera_pencil` (cursive, grey-green tint), `jan_block` (hand-set block, soot) for Jan's own marks, `press_jan` (typewriter, soot, a new machine hand; needs a registry row, GDD 2 Edge Case 24), `tomas_stencil` (stencil, khaki). Typed cites and link lines use the body face in the form's ink. The kind corner codes are the first typed abbreviation codes in the UI and need `ui.kind.*` string ids for localisation.

**7. Audio** (named for the audio director; no layering, timing or trigger detail here). *Hold:* one dry mark in the form's medium: a pencil tick (Vera), a paper tear (Jan), a stencil tap (Tomas). *Click:* the typewriter keys of the line typing out, plus the set of the clip, pin or bracket; nothing after the last character. *No connection:* the slip's type-tick, or silence; never a buzzer, never a falling tone. **Never a reward sting, chord or rise: a link is read, never scored.** The mood: a desk at night, one lamp, someone writing something down that they will not be allowed to keep.

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:investigation-fact-system` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## Game Feel

Feel targets, because this is the system the player operates most.

- **A hold is one press and lands at once.** The span's ghost and "cc" appear on the same frame; the card appears on the board within `LIFT_MS` (GDD 3's one authored duration), never later, and never with a flourish.
- **A click is read, not rewarded.** When two cards connect, the link line types out in the protagonist's voice and the derived card appears; nothing flashes, nothing counts up, no sting plays (Visual/Audio). The satisfaction is the sentence.
- **A miss costs nothing and shows nothing.** "No cross-reference." lifts as a typed slip and drops; the cards return to where they were; no mark remains.
- **The board is calm.** Cards never auto-sort, never animate on idle, never pulse to suggest a pair; the only motion is the one the player caused.
- **Re-reading is free.** Reopening a filed document is as fast as opening it the first time, and held spans are already marked, so a careful second pass is a reading, not a search.

## UI Requirements

This system owns no screen. It supplies Paper UI with everything the fact board and the document sheet need, and it consumes two player gestures.

- **In a document sheet (Paper UI, PROV):** per holdable span, the fact id, its `held` flag and its line id; the span is activatable by pointer and by keyboard (Tab through holdable spans within the sheet; `activate` holds), with an accessible name `{fact.<id>}` and state `held`/`holdable`; a span whose line is struck is not a target.
- **On the fact board (Paper UI, PROV):** the `board()` view (protagonist form, facts in `seq` order with kind, text, source cite, derived flag and depth, links made); two-card selection by pointer or keyboard and `pair` on the second selection; the link line typed out on success; the protagonist's `fact.no_link` slip on failure; no number, counter, percentage or completion state anywhere on the board; no tried-mark; paging by `BOARD_CAPACITY` when the held set overflows a page.
- **Read count:** not this system's. GDD 3's `hotspot_counts` prints "4 of 6 documents" on the dossier sheet; this GDD only decides when a hotspot is filed.
- **Accessibility inputs** (recorded in `design/accessibility-requirements.md` by the accessibility specialist): every holdable span and every card reachable by keyboard; the hold and the click announced (`{fact.<id>} held`; `{link line}`); the "no connection" slip announced once; no timed input; board paging announced as "page 2 of 2" only to the screen reader, never printed.

> **📌 UX Flag — Investigation & Fact System**: this system contributes holdable spans to the document sheet and the whole fact board to Paper UI. In Pre-Production, run `/ux-design` for the document sheet and the fact board (three forms) **before** writing epics; stories cite `design/ux/[screen].md`, not this GDD. The `RichTextLabel` span API is a spike (Core Rule 9); the UX spec must not assume it.

## Cross-References

| This GDD references | In | Owner | Nature |
|---|---|---|---|
| The sorting rule: held facts are the player's, never dossier state; `knows_*` are Fact's; derived knowledge from fields | GDD 1 Core Rule 1 | Dossier State Model | Rule 1; the reason facts are not un-known when paper is corrected |
| Reads through `is_true/is_false/is_unknown`; the read budget `R_c` (`READ_MAX` 20); the headless rule; the persistence shape and boundary-only `deserialize` | GDD 1 Core Rules 6–7, 10, 11; Formulas §6 | Dossier State Model | Rules 6, 8, 9 |
| The simulator acceptance criterion "every authored fact has at least one dossier use"; the Fact row in Interactions and Dependencies | GDD 1 Interactions, Dependencies, Cross-References | Dossier State Model | Rule 5 defines the use; GDD 1's cross-reference path corrected to this file |
| `yields` on lines and dialogue items; the `link` object type; `fact_index()`; the condition grammar and `has_fact`; `fields_in`; V28–V29, V42; `LINE_CAP`, `LABEL_CAP` | GDD 2 Core Rules 5, 5b, 6, 9; validator table; Formulas §2, §7 | Narrative Content Format | Rules 2–5, 8, 11; two rows and one object type added to GDD 2 by this GDD |
| `hotspot_activated`/`hotspot_examined`; availability set only by Scene Flow in answer to the player; `filed` = a fact collected; re-activating a filed hotspot; X01; no late-appearing hotspots; the closed input set; `LIFT_MS` | GDD 3 Core Rules 0, 3, 5, 6; Edge Case 13; Player Fantasy | Scene & Interaction Framework | Rules 2, 4, 6a; Game Feel |
| Interactive facts: carbon blue, typed rule underline, margin tick; filed facts: double-strike ghost and "cc"; the dissident's pinboard fragments; durations | Art bible §7.2, §7.4, §7.6 C4 | Art | Rule 2; Visual/Audio |
| Colourblind backups (carbon vs soot) | Art bible §4.5 | Art | Visual/Audio |
| Act-one knowledge facts and the V-action unlock conditions; the cross-life channels as paper | Narrative brief §3–§4 | Narrative | Rules 1, 12 |
| The archivist prototype: hold by click, six links, 12-fact noise line, 3-of-6 informed decision, held versus filed as different objects | prototypes/paper-walls-archivist-concept/REPORT.md | Prototype | Rules 2, 3; Formulas §1, §4; Tuning Knobs |
| Core loop and MVP requirement 2; Pillars 1, 3, 4, 5; anti-pillar "not a morality meter" | design/gdd/game-concept.md | Concept | Overview; Player Fantasy; Rules 1, 3, 10 |
| `RichTextLabel.push_meta` tooltip parameter (the only sourced span fact) | docs/engine-reference/godot/modules/ui.md line 31 | Engine reference | Rule 9 (spike) |

## Acceptance Criteria

[To be designed]

## Open Questions

| Question | Owner | Needed by | Status |
|---|---|---|---|
| Whether `parcel_was_medicine` stays a direct yield of leaf 40 (the brief's locked V1 `read-file`) or becomes the link of `Stated: medicine, foreign` with the subject line, so that V6 `warn` costs a noticing rather than a read | narrative-director, user | Before act-one content is frozen | Open; locked value stands |
| The second MVP conversation: Kastan (the brief's assumption; yields `ilona_on_cellar_stairs`) or Rybar (then link L4's unlock moves to Berta's paper answer) | narrative-director | MVP content | Open |
| `has_fact` on `exits[].when` (a door is a threshold, not an object to file): allowed by this GDD, confirmed by Scene Flow | Scene Flow GDD | Scene Flow GDD | Open; assumed yes |
| Whether act one needs a struck line to yield (this GDD says no: a strike yields nothing; "this was struck" is its own marginalia line) | narrative-director | Act-one content | Open; assumed no |
| Engine spike (NOT SOURCEABLE): `RichTextLabel` meta-click and hover API for holdable spans (fallback: one Control per span); `signal` on `RefCounted` without a scene tree; `@abstract` for the reader interface | technical-director, ui-programmer | Before the document-sheet UX spec | Open; shares GDD 3's spike |
| The `FactSystem` seam and the `ConditionReader` composite deserve an ADR alongside GDD 3's host seam | technical-director | `/create-architecture` | Open |
| `design/accessibility-requirements.md` does not exist; this GDD's inputs are listed in UI Requirements | accessibility-specialist | Before `/gate-check technical-setup` | Open |
| The playtest hypotheses `INFORMED_HYPOTHESIS` 0.5 and `T_FIRST_LINK_HYPOTHESIS` 300 s, and the prototype's completionism question (`held_fraction`), are observed in the MVP playtest, never tuned against | ux-designer, analytics-engineer | MVP playtest | Open |
| Art-director flags: Vera's card cite is typed, not pencil (art bible §7.2's 1.2× minimum for hand letterforms; a pencil cite needs a larger card); `press_jan` is a new machine hand needing a GDD 2 registry row; the kind corner codes need `ui.kind.*` string ids | narrative-director, art-director, writer | Before the fact-board UX spec | Open |
| Performance budgets proposed in Acceptance Criteria | technical-director | ADR | To be confirmed |
