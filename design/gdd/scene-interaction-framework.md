# Scene & Interaction Framework

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: Designed
> **Author**: Mustafa Faisal (user) + game-designer, ux-designer, godot-specialist, gameplay-programmer, systems-designer (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 1 Every fact is a weapon · 5 Pressure comes from attention, not reflexes
> **Gates**: CD-GDD-ALIGN 2026-11-03 CONCERNS (9), all applied: timed choices only as sheets with the room suspended; availability changes only in answer to the player; press-and-release targeting; X01 every paper or object hotspot is filable; the read count counts paper only, never sums, never rewards informing, and shows struck to everyone; walking guarantees and `HOP_S` as a hard gate; no engine focus styles; dwell is presentation, not idle state; housekeeping. `/design-review` pending.

## Summary

The Scene & Interaction Framework puts a painted room on screen and lets the player touch it: it loads a plate and its hotspot layers from a validated sidecar, keeps one focus that mouse, keyboard and a later gamepad all share, routes seven input actions, draws the corner lift and the paper wipe, and tells Scene Flow which hotspot was activated through a thin host interface that has a null twin for the story simulator. It exists so that every visible system reads one answer to "what is on screen and what did the player just do", so that the art bible's legibility rules are enforced by a build gate instead of a review note, and so that the room never asks for reflexes or luck: no timer, no drag, no pixel hunting, every hotspot reachable by keyboard. Whether a protagonist walks or the camera cuts is left to the MVP art-pipeline proof.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `Narrative Content Format & Strings` (vocabulary and one string); read by Scene Flow, Investigation & Fact, Overlay & Surveillance Rendering, Character Presentation, Dialogue & Interrogation, Paper UI, Audio

## Overview

The Scene & Interaction Framework is the part of Paper Walls that puts a painted room on screen and lets the player touch it. It loads a scene's isometric plate and its layers, registers the room's hotspots (a lifted paper corner, a drawer out one notch, a receiver off its cradle) under the ids the content format names, routes mouse and keyboard input into a small set of actions (focus, activate, reveal, cancel, open dossier), owns the cursor and the single focus state that hover, keyboard and a later gamepad all share, and tells Scene Flow which hotspot the player activated. It exists because every other visible system, Investigation & Fact, Dialogue, Character Presentation, Overlay Rendering and Paper UI, needs one answer to "what is on screen, where is it, and what did the player just do", and because the art bible's legibility rules (one hero, three to eight keylined hotspots, a clean figure band, no glow) are only enforceable if hotspots are registered objects rather than painted-in guesses. Whether a protagonist walks across the plate or the camera cuts between standing layers is not decided here: navigation and walkable regions are a conditional section whose activation the MVP art-pipeline proof decides. The index describes the system as "isometric plate, layers, hotspot registration, scene loading, input actions, cursor and focus; navigation and walkable regions as a conditional section decided by the MVP pipeline proof", and this GDD keeps that scope. It does not decide what a hotspot yields (Investigation & Fact), when a scene ends (Scene Flow), how a figure looks (Character Presentation), or how stamps and red are drawn (Overlay & Surveillance Rendering). Implementation questions raised here (CanvasLayer ordering, the pixel-snap setting, the stretch aspect) are recorded for the renderer and plate-authoring ADRs, not decided in this document.

## Player Fantasy

*Framing: indirect. The player sees a room, a cursor and the few objects that sit one unit off the grid; they never see the framework. Shaped with the creative director (three candidate framings; "the room is a page" chosen, with one line from "someone was here before you" and the rule from "the room waits").*

**The room is a page.** The emotion this system serves is a reader's attention. Entering a room is like turning to a new page: the player takes it in whole and at rest before touching anything, and the plate tells them which lines to read. Six or so objects are each disturbed by one unit, keylined and waiting. Moving the cursor across the room is like running a finger down a column. A corner lifts under it, the keyline thickens, and a typed slip offers one word. Nothing else answers. The cursor touches; it never knocks anything over and never moves anything the player did not choose to open.

The anchor is the drawer of the desk Vera inherited, pulled out one notch. It is the only drawer in the room that is not flush. The player sees it before they decide to look for it, and moving to it feels like reading the next word, not searching. As in Disco Elysium, the room is something you read. As in Pentiment, a hand chose every mark. A room the player has read looks read: carbon ghosts where the keylines were.

*Cost accepted:* the fantasy depends entirely on art discipline (art bible §6.3–6.6). A stray disturbance or a ninth hotspot lies to the reader, so the plate rules are load-time asserts in this system, not review notes.

**Pillar alignment.** Pillar 1, "every fact is a weapon": every marked object is there to be read and filed, and a detail that implies an unfilable fact is cut (art bible §6.5). Pillar 5, "pressure comes from attention, not reflexes": the room is the one place where the state is not watching the clock.

**The one rule this framework must obey: the room waits, and the room is fair.** The framework owns no clock and no precision test. Every hotspot is found because it is drawn. Every hotspot can be reached by focus (keyboard, later gamepad) as fully as by the pointer. Every activation is one discrete press, and the result does not depend on when the press lands, how fast, or where inside the hotspot's footprint. The target is the focus at press; release activates it if focus has not changed to another id; release over bare plate or another hotspot does nothing and loses nothing. Required: hotspot margins of at least half the object's width; focus cycling as a full equal to the mouse; the reveal key as a guarantee that nothing is found by luck; cancel always available; if walking avatars win the pipeline proof, a click-to-walk target snaps to the hotspot's arrival point and the world never interrupts the walk. Forbidden inside this system: any timer or timed input; hold-to-complete, drag, double-click; hotspots that move, appear late, or show only on hover; sub-object pixel targets; any outcome triggered by a misclick that cannot be cancelled; any change in room state while the player is idle (the idle rule covers room and availability state, not presentation answering the player's last input, so a slip that follows a focus dwell is not a violation). Timed choices under interrogation or search, Pillar 5's one exception, belong to Dialogue & Interrogation and Scene Flow and are never a property of the room. *Design test:* could a player with a tremor, or one who has stepped away for coffee, lose anything in this room? If yes, it is a defect.

## Detailed Design

### Core Rules

*Drafted with the game designer (primary), the UX designer, the Godot specialist and the gameplay programmer. Where they disagreed, the ruling is stated in the rule with the alternative it displaced. Engine facts are quoted only from `docs/engine-reference/godot/`; anything else is marked **NOT SOURCEABLE** and listed as a spike. Items marked **(PROV)** rest on a system whose GDD is not yet written.*

**0. Vocabulary.** A *scene* is one painted plate and its sidecar. A *hotspot* is an object on the plate disturbed from the grid by one unit (art bible §6.4), registered under an id the content format references. The *hero* is the plate's one full-value object (§3.4); it is not a hotspot unless its id is also a hotspot id. A *threshold* is a door, window or telephone, drawn thick because reactive events enter through them (§3.3). *Focus* is the one hotspot the next `activate` will hit. *Availability* is a hotspot's content state (`unfiled`, `filed`, `void`, `hidden`), set by Scene Flow; `filed` means "its fact has been collected" and never "a filing decision was made", so no counter in this system ever rewards informing. The *host* is the thin interface through which headless systems drive this one.

**1. A scene is one plate plus one sidecar.** A scene is a 1920×1080 PNG (scrolling plates ≤ 3840×1080, one texture; art bible §8.3, §8.7 T2) and a `scene.json` written by the art export script and normalised by a compiler under `tools/scene/` (sorted hotspots, integer coordinates, `schema_version` first), never hand-edited and read by the game only at load. Every coordinate is an **integer in 1080 plate space** (§8.5, §8.7 T6); the framework performs no coordinate conversion, since 720 is the engine's ⅔ `canvas_items` stretch of the same file (stretch defaults SOURCED: breaking-changes.md line 39; aspect and letterboxing are the stretch ADR's, **PROV**).

| Field | Type | Owner of meaning |
|---|---|---|
| `schema_version` | int | this system |
| `scene_id` | global id in GDD 1's form `a1_vera/s3` | GDD 1 / Scene Flow **(PROV)** |
| `location` | opaque id; the vocabulary GDD 2's lint checks `scene.location` against | this system |
| `plate` | `{png, width, height}`; `height` must be 1080 | this system |
| `camera` | `{start_x, min_x, max_x}`; omitted on static plates | this system |
| `hero` | `{id, rect}`, exactly one; may share an id with a hotspot | this system (validation); Overlay for stamp avoidance **(PROV)** |
| `figure_band` | polygon (walkable floor plus one figure-height of wall, §6.6) | this system (validation); Character Presentation **(PROV)** |
| `walkable` | polygon; present only under the walking-avatar outcome (Rule 10) | this system |
| `hotspots[]` | hotspot records, below | this system |
| `focus_order[]` | permutation of hotspot ids (Rule 4) | this system |
| `exits[]` | `[{hotspot, wipe_from: left/right/top/bottom}]`, presentation only | this system; route semantics are Scene Flow's `exits[{to, when}]` **(PROV)** |

*The hotspot record:* `id` (`^[a-z0-9_]+$`, unique within the scene; the vocabulary GDD 2's `action.hotspot` lints against), `kind` ∈ {`paper`, `object`, `door`, `phone`, `person`}, `threshold: bool`, `hit` (rect, or polygon when a crop's bounding box would overlap a neighbour), `baseline_y` (the y-sort key Character Presentation reads **(PROV)**), `lift_anchor` (the corner the §3.5 lift pivots on; also the focus-order key), `layer {png, x, y}` (bounding-box crop ≤ 512², integer offset, §8.5), `focus_layer {png, x, y}` (the lifted-corner, 3 px keyline variant; same bounds as `layer`), `layer_filed {png, x, y}` (the same crop with the keyline removed; same bounds; the pose for `filed` and `void`), `approach` (a point inside `walkable`; walking outcome only), `name_key` (one `acc.*` string id, Rule 9). *Rationale:* a closed record lets the content lint, the art export and the runtime agree on one vocabulary, which is all GDD 2 asks of this system. *Rejected:* deriving hit regions from layer alpha at runtime (a painter's stray pixel becomes an input bug, and it cannot be linted offline).

**2. The validator runs at build time first and at load second; art-bible rules become asserts.** `SceneDataValidator` is a headless `RefCounted` with no scene-tree imports. `tools/scene/validate_scenes.gd` runs it over every sidecar in CI (the primary gate: errors fail the build, warnings print, the release branch treats warnings as errors) and emits `scene_vocab.json` (location, hotspot and exit ids with kinds), which GDD 2's lint consumes for dangling references. Debug builds re-run the full set at load as asserts; release builds run only the structural rules (a malformed sidecar would otherwise crash) and degrade on the rest (a missing layer hides the hotspot and logs; a malformed `walkable` disables walking for that scene).

| # | Check | Sev |
|---|---|---|
| E01 | `schema_version` present and current | E |
| E02 | 3 ≤ hotspots ≤ 8 (§6.3) | E |
| E03 | Exactly one `hero` | E |
| E04 | Ids match the grammar and are unique within the scene; `location` unique across all scenes; `scene_id` matches GDD 1's form; `focus_order` is a permutation of the hotspot ids | E |
| E05 | Clear margin (§6.4): each hit region expanded by half its width intersects no other hit region; the *midtone* half of the margin rule is the asset-pipeline gate's, and a figure standing over a hotspot is the dynamic debug warning in E06 | E |
| E06 | A non-threshold hotspot's hit region ∩ `figure_band` ≠ ∅ (§6.6): error. A `threshold: true` hotspot may intersect the wall portion of the band (warning) and may never intersect `walkable` (error). Art-director ruling, Visual/Audio item 7b. The dynamic case, a moving figure's head over a focused hotspot, is a debug runtime warning | E / W |
| E07 | Every coordinate integer and inside the plate; `plate.height == 1080`; width may exceed 1920 only with `camera`; `camera` bounds inside the plate | E |
| E08 | Layer files exist; offsets integer; crops ≤ 512²; `focus_layer` and `layer_filed` bounds equal `layer` bounds (otherwise the lift shifts); a PNG whose pixel size exceeds ship size (a 2× paint imported at 2×) | E |
| E09 | `exits[].hotspot` resolve and are `threshold: true` | E |
| E10 | Walking outcome: `walkable` is a simple polygon (≥ 3 vertices, no self-intersection, non-zero area) inside the plate; `figure_band ⊇ walkable`; every `approach` and `baseline_y` inside it | E |
| E11 | `kind` in the closed set; `threshold: true` on a kind other than `door`/`phone` | E / W |
| E12 | Target size (UX): the hit rect, padded into its clear margin, is at least `HIT_MIN` × `HIT_MIN` px in 1080 space; hit rects never overlap and keep ≥ `HIT_GAP` px between edges | E |
| W13 | Resident-byte sheet over `SCENE_BUDGET_WARN`; error over `SCENE_BUDGET_MAX` (Rule 7) | W / E |
| W14 | Runtime observation (debug builds only; release builds have no debug surfaces): `draw_warn(draws_est, measured) = measured − draws_est > 17` (T3's reserve), a pure function unit-tested with an injected count; the measured count comes from the draw-call monitor (spike; Vertical Slice) | W |
| W15 | Walking outcome: the top quarter of the figure box standing at `approach` intersects its own hotspot's hit rect (§6.4 "never behind a figure's head", made checkable) | W |

Two cross-checks live in `tools/` only, where importing both the content store and this validator is allowed: every content `hotspot` ref exists in the vocabulary (the lint's side), and **X01 (error): every hotspot of kind `paper` or `object` resolves through its content action to at least one fact that passes GDD 2's V42 (the fact has a dossier use)**, so "every hotspot is filable" (Pillar 1) is enforced, not assumed; `door`, `phone` and `person` are exempt by kind. Art bible §6.5's rule for non-hotspot plate details (a detail that implies an unfilable fact is cut) cannot be checked by this system and is a line on the art director's plate sign-off in `production/qa/evidence/scene/signoff.md`. *Rationale:* every rule here is one the art bible already calls *checkable*; making the build the checker means a plate that breaks a rule cannot ship by accident, and the load-time re-run catches a sidecar edited after the build. *Rejected:* validating only at load (too late for the artist; the pipeline proof needs the gate in the export loop).

**3. The input action set is closed.** Seven actions (eleven action names, since `focus_next`/`focus_prev` are two and `focus_dir` is four: `focus_up`, `focus_down`, `focus_left`, `focus_right`), declared once in `assets/data/input_actions.json` so Settings Store can remap them; the framework never hardcodes a binding.

| Action | Mouse + keyboard default | Gamepad (reserved, not MVP) | Effect |
|---|---|---|---|
| `activate` | LMB on a hotspot / Enter / Space | A | activate the focused hotspot |
| `focus_next` / `focus_prev` | Tab / Shift+Tab | bumpers | walk the focus ring (Rule 4) |
| `focus_dir` | arrow keys | d-pad | spatial focus step (Rule 4) |
| `reveal` | hold Alt | hold X | every hotspot shows its state at once (Rule 6) |
| `examine` | RMB on a hotspot / E | right trigger | the typed slip (Rule 6) |
| `cancel` | Esc | B | abort a walk (walking outcome), close the slip; otherwise forwarded to Paper UI |
| `dossier` | D | Y | forwarded to Paper UI **(PROV)** |

Pointer movement is not an action; it sets focus (Rule 4). Events are identified by type, never by `device == 0` (SOURCED: input.md lines 8–10; 4.7 uses `DEVICE_ID_MOUSE`/`DEVICE_ID_KEYBOARD`). Action names are `StringName`s in hot paths (input.md line 80). **Forbidden anywhere in this system:** drag, double-click, hold-to-confirm, press-with-deadline, chorded keys as the sole path, scroll-wheel-only or right-click-only paths, keyboard actions whose meaning depends on cursor position, and any input whose meaning depends on elapsed time. The `reveal` hold is permitted because it has no deadline: it is a view mode, and releasing it loses nothing. *Rationale:* Pillar 5, pressure comes from attention, so no input in a room may reward speed or dexterity; a closed set also makes keyboard and gamepad reach provable by enumeration. *Rejected:* a context-sensitive "use" that walks, opens and talks by cursor position (hides the hotspot vocabulary from the lint and from screen readers).

**4. One focus, and the controller is the only truth.** `FocusController` holds at most one `focused_id` and its `source` (`POINTER` or `KEY`). The engine keeps mouse focus and keyboard focus separate since 4.6 (SOURCED: input.md lines 16–18, 79; breaking-changes.md line 55), so neither engine state is presentation: the controller *drives* the engine, calling `grab_focus()` on the focused hotspot's Control from every source, and the corner lift (120 ms, §7.4) with the 2 → 3 px keyline is drawn by the controller for exactly one id. Each hotspot owns an invisible Control sized to its hit rect purely as the keyboard-focus and screen-reader carrier; carrier Controls draw no focus or hover style of the engine's (a default focus rectangle would be a non-paper border, an art bible §7.1 defect), and the lift is the only focus mark; hit-testing is a polygon test in script over the sidecar's `hit` regions (deterministic, headless-testable). **Setting rules:** pointer entering a hit region → `set_focus(id, POINTER)`; `focus_next`/`focus_prev`/`focus_dir` → `set_focus(id, KEY)`; the gamepad cursor follows the POINTER path. Last input wins, with a **pointer latch**: after a KEY set, a resting pointer's hover is ignored until the pointer moves at least `POINTER_LATCH_PX` (4 px in 720 space); then hover re-asserts. Pointer leaving a hit region clears focus only when the source is POINTER; KEY focus persists until another set, a sheet, `hidden`, or scene exit. On `scene_ready`, focus is none if the last source was POINTER and first-in-ring if KEY (a screen-reader user needs a landing point). **Order:** `focus_order` is authored by the export and defaults to screen reading order by `lift_anchor`: rows of `FOCUS_ROW_HEIGHT` px (72 at 1080), x ascending within a row, ties by id; the ring wraps. The hero has no privilege: it is in the ring only if its id is a hotspot id, otherwise it is a non-interactive image. Thresholds are in the same ring. `filed` hotspots stay in the ring; `void` stay with the disabled flag so a screen-reader user still learns a document was removed; `hidden` leave. `focus_dir` is spatial and deterministic: candidates are hotspots whose anchor lies in the 90° cone past the current anchor in screen space, cost = Euclidean distance + `OFF_AXIS_PENALTY` × perpendicular offset, lowest wins, ties by id, no wrap, no move if the cone is empty; computed from anchors at load, never from the engine's focus neighbours (which split across the dual focus). `FocusOrdering.next_focus(current, hotspots, direction)` is a pure function over `{id, lift_anchor, hit, availability}` and is unit-tested headless. The controller owns no clock: it takes an injected tick (`advance(ms)`), so the tooltip dwell, the lift and the wipe completions are deterministic in headless tests, and the real tweens are verified only by run-and-observe. *Rationale:* a player must always know what the next `activate` will hit, on any device, from one visual fact (art bible C2); AccessKit announces what has keyboard focus, so the controller must drive it or screen readers follow the wrong object. *Rejected:* letting the engine's two focuses each draw (two lifts on screen); hover without `grab_focus()` (Enter activates the wrong thing after hovering with one hand and confirming with the other); nearest-first ring order (changes with where you are; unpredictable for a screen reader); hero last (hides the most important object from the first Tab).

**5. Availability is one axis; focus is another.** `availability ∈ {unfiled, filed, void, hidden}` is set **only** by Scene Flow through `set_hotspot_state`; focus is set only by the controller. Presentation: `unfiled` — layer with permanent 2 px keyline; `filed` — `layer_filed` (keyline removed) and a carbon ghost *requested from Overlay* through `ghost_requested(hotspot_id)` on the `filed` transition, Overlay drawing a flat carbon silhouette of the `layer_filed` crop at `GHOST_OFFSET_PX` directly beneath the hotspot (GDD 9 Core Rules; amendment applied: the sidecar gains an `overlay` block validated by GDD 9's rules O01–W17, the export script writes `red_px` per red layer, and Formulas §8's resident-byte sheet gains `+ LIGHT_MAX` lighting layers) (§6.4, "a read room looks read"; this system toggles state and emits, Overlay draws); on focus a filed hotspot lifts without a keyline, and the gap opening against its unmoving ghost is the focus read (Visual/Audio item 7c); `void` — the greyed typed bracket struck VOID in the slip and the AccessKit disabled flag (art bible C3); `activate` on it emits `hotspot_examined` only, never `hotspot_activated`; `hidden` — no layer, no hit region, out of the ring. `filed` hotspots remain focusable and activatable (lift only, no keyline); what re-activation yields is Investigation & Fact's **(PROV)**. The framework never derives availability from the dossier: it cannot read it (GDD 1's headless rule) and must not (the same principle as Overlay's "never reads raw dossier fields"). Availability is re-derived by Scene Flow on load; this system persists nothing. **After `scene_ready`, Scene Flow may change availability only synchronously in response to a `hotspot_activated` or `hotspot_examined`, or under a block (a sheet the player opened), never on idle and never on a clock**; a hotspot leaving `hidden` mid-scene is announced through the live region and shown in its unfiled pose on the next frame. A change that arrives any other way is a Scene Flow defect caught by a debug assert (Edge Case 14). *Rejected:* a five-value enum with `focused` in it (two orthogonal axes in one field; a `filed` hotspot could not be focused); `filed` as inert (a screen-reader player loses the only way to re-check a document from the room, and the read count would hide a reachable object).

**6. Reveal, examine and the slip.** *Reveal* (`reveal` held, or toggled under `reveal_mode: toggle | always`): every `unfiled` hotspot lifts its corner at once, 120 ms ease-out, no stagger (no breathing, §7.4); keylines stay 2 px so the focused hotspot's 3 px still reads; `filed` show their ghost unchanged; `void` show the struck bracket without a lift; thresholds lift (a door ajar one more notch; confirmed by the art director); focus does not move; on release everything drops in 120 ms. There is no minimum hold and no hold-duration setting. *Examine* (`examine`, or a `TOOLTIP_DWELL_MS` focus dwell under `tooltip_mode: focus`, immediately on KEY focus): emits `hotspot_examined(id)` and Paper UI draws the typed slip (`[ PERSONNEL FILE ]`, `[ EXIT — CORRIDOR ]`, `[ VOID ]`) lifting 120 ms from under the cursor (POINTER) or below the anchor (KEY); it stays until focus changes or `cancel`, never on a timeout. The slip's bracket is the "cursor bracket" art bible §6.4 names; the cursor itself never changes shape for a hotspot (§7.3; the contradiction between §6.4 and §7.3 is resolved this way and recorded in Open Questions for the art director). *Read count:* `hotspot_counts(scene_id) → {kind: {total, filed, void}}`; Paper UI prints the `paper` kind only, in typed form with the void count visible to everyone ("4 of 6 documents, 1 struck"), on the dossier sheet at scene exit and whenever the dossier opens mid-scene (the exit-only count arrives too late to help). Conversations, doors and telephones are never counted (counting conversations turns interrogation into a checklist), the count is per scene and never sums to a chapter or game percentage on any surface, and sighted and screen-reader players receive the same figures. *Rationale:* discoverability without glow is a hypothesis to test at 720p (art bible C1; Acceptance Criteria carry the test); the reveal guarantees nothing is found by luck.

**7. Two scenes resident; the reveal step is the loading screen.** At most two scenes are resident: the `active` (or `suspended`) one and at most one `preloading`/`ready` one, each ≤ `SCENE_BUDGET_MAX` (256 MB, art bible §8.7 T1). Scene Flow calls `preload_scene` as soon as the next scene id is known, after the rules step and before the reveal, so the reveal sheet's reading time hides the load. The resident-byte sheet is computed at build time from the sidecar (`Σ layer width × height × 4`, worst-case RGBA8; plate 8.3 MB) until the import-options spike reports whether compression applies; a debug assert at `scene_ready` sums the loaded textures' dimensions and compares within 5%. Threaded versus blocking load is **NOT SOURCEABLE** (only `PackedScene.instantiate()` is sourced, deprecated-apis.md line 30) and goes to the spike; the load budget (≤ `LOAD_BUDGET_MS` to `scene_ready`, ≤ `SWAP_BUDGET_MS` for a preloaded swap) is the technical director's to confirm. Transition: `activate_scene(wipe = true)` plays the paper wipe drawn by this system (direction from `exits[].wipe_from`, duration `WIPE_MS`, never a fade, §7.4; `Tween.tween_await()` is sourced, animation.md line 8), input blocked throughout, cursor hidden (the wipe is the busy signal; no spinner); the previous scene unloads after `scene_exited`. *Rejected:* preloading every exit candidate (breaks the two-scene ceiling the moment a scene has three conditional exits).

**8. The host interface is thin and has a null twin.** Headless systems drive this one through `SceneHost extends RefCounted` (`@abstract` is sourced for 4.5, breaking-changes.md line 69; its GDScript syntax is verified in the spike; an override of a typed-return method needs an explicit `return`, line 17). Two implementations: `EngineSceneHost`, a `RefCounted` adapter that holds the `SceneRoot` Node and forwards, and `NullSceneHost` for the story simulator and tests. Keeping the Node out of the hierarchy is what lets the CI path check enforce the direction: `src/scene_flow/`, `src/investigation/` and `tools/sim/` may import `scene_host.gd` and never `src/scene/engine/*`. Injection is by constructor (`SceneFlow.new(host, dossier, content_store, …)`; the full signature is GDD 8 Core Rule 1's, amendment applied); the main scene constructs the engine host, then Scene Flow; there is no autoload.

Calls: `preload_scene(scene_id) → {ok, errors[]}`; `activate_scene(scene_id, wipe: bool)`; `unload_scene(scene_id)`; `set_hotspot_state(hotspot_id, availability)`; `set_focus(hotspot_id)` and `focus() → StringName` (Scene Flow places entry focus deterministically for keyboard users); `push_input_block(reason)` / `pop_input_block(reason)` (a counted block, so nested sheets and a wipe cannot re-enable input under each other); queries `hotspot_counts(scene_id)`, `hotspot_ids(scene_id)`.
Signals: `scene_preloaded(scene_id)` (this system's assets resident; dependents load theirs), `focus_changed(hotspot_id, prev_id, source)` (so Character Presentation swaps a person's painted focus twin; GDD 10 amendment), `scene_ready(scene_id)` (Rule 7's guarantees hold; input blocked until the block count is zero), `hotspot_activated(hotspot_id)`, `hotspot_examined(hotspot_id)`, `scene_exited(scene_id)` (wipe finished, resources released). **There is no exit signal:** a door is a `threshold` hotspot and emits `hotspot_activated` like everything else; Scene Flow owns what leaving means through GDD 2's `exits[{to, when}]`.
`NullSceneHost` validates ids against `scene_vocab.json`, emits both scene signals synchronously, records `set_hotspot_state` into a dictionary tests can read, and exposes driver methods `activate(hotspot_id)` and `hotspot_states()` so the simulator can script a player. The `SceneHost` contract suite runs against both hosts. *Rationale:* the one system that must run headless must not depend on the one system that cannot. *Rejected:* `exit_requested` as a separate signal (duplicates Scene Flow's conditional routes, which have no hotspot field); `enable_input(bool)` (fragile under nested sheets).

**9. Accessibility is a load-time property, not a pass.** Every hotspot's carrier Control has an AccessKit role (`button`; `link` for `door`/`phone`; the non-interactive hero is an `image`; the plate is a `region`), an accessible name and, when `void`, the disabled flag (AccessKit on Controls is SOURCED, ui.md line 29 and breaking-changes.md line 75; the role, name and disabled property names in GDScript are **NOT SOURCEABLE**, spike). The controller writes roles, names and flags through an injected `AccessibilityAdapter`: the null twin records them for tests, the engine twin maps them to AccessKit once the spike lands, and the engine-side behaviour is verified with a named screen reader and a retained transcript. The accessible name is the one string this system touches: `name_key` resolved through GDD 2's `StringLookup` at load and on locale change, used for the name, the examine slip and the focus announcement (`{acc.hotspot.<id>}, {acc.state.<state>}, {n} of {m}` → "Personnel file, unread, 2 of 6") and for nothing else; on `scene_ready` the region announces `{acc.location.<id>}` with the read count ("Archive office. 6 documents, 2 read."); a reveal press updates a live region with the count. Every ring member, including off-screen and `void`, is reachable by `focus_next`; nothing in a room is activatable only by pointer. Settings Store **(PROV)** must expose: `ui_scale` 100–150%, `cursor_scale`, `flicker: off`, `reveal_mode`, `tooltip_mode`, and full remap of the seven actions; the interrogation timer setting is Dialogue's. `design/accessibility-requirements.md` does not exist yet; the accessibility specialist writes it before this GDD's acceptance criteria are checked (the Pre-Production gate reads that exact path), with the tier "screen-reader-complete for all paper UI and plate hotspots" proposed (Open Questions). *Rejected:* Scene Flow pushing names per hotspot per scene (a call per hotspot per scene that ends in the same string); no names in this system (fails keyboard and screen-reader reach).

**10. Navigation (CONDITIONAL, decided by the MVP pipeline proof).** A project-level flag `presentation.mode: walking | standing` in `assets/data/scene_framework.json` is set once from the proof's measured times (the creative director owns the call). The flag selects which paragraph is live; the other stays in this document unimplemented.

*Walking avatars.* `walkable` is the walk surface. A path is the straight segment when it lies inside `walkable`; otherwise the dedicated 2D navigation server (SOURCED: navigation.md lines 11–13; `NavigationRegion2D` lost `avoidance_layers` in 4.3, line 16; no 4.7 changes, line 8) supplies it, with arrival polled by `is_navigation_finished()` (lines 44–58; the 2D arrival-distance property names and the `navigation_finished` signal are **NOT SOURCEABLE**, spike); avoidance is off (one figure). `activate` on a hotspot walks the avatar to its `approach` point and emits `hotspot_activated` on arrival (`ARRIVAL_TOLERANCE_PX`); `activate` on bare walkable floor walks there and emits nothing; `cancel` or a new `activate` aborts the walk; keyboard activation walks too (no device skips the walk). Facing is the dominant axis of the final segment, four directions, three authored (§8.7 T8), ≤ 12 fps. If no path exists the framework activates immediately and logs: walking is never a puzzle. Four more guarantees make that true: avatar position is never state (no system reads it, and no hotspot's yield, availability or reach depends on where the avatar stands or faces); every `approach` is reachable from every point of `walkable` because E10 requires a simple polygon; a walk whose path is consumed without arriving within `ARRIVAL_TOLERANCE_PX` activates anyway (no oscillation lock); and keyboard activation never waits for the camera. The camera follows the avatar during a walk, then returns to following focus. *Proof criteria:* the median hotspot-to-hotspot hop takes ≤ `HOP_S` (1.5 s) and crossing a plate ≤ `PLATE_CROSS_S` (4.5 s) at `WALK_SPEED_PX_S`, with the foot-slide ratio within 0.8–1.25 (Formulas §9); `HOP_S` is a hard proof gate, not only a measurement: a walking outcome that fails it is not adopted, because travel time is friction and must stay bounded.

*Standing layers.* No navigation, no `walkable`, no avatar; `activate` emits `hotspot_activated` immediately; any cut or pose change is Character Presentation's **(PROV)**, triggered by its own listener on the signal. `kind: person` hotspots are hit regions declared in the sidecar, so a conversation is reached exactly like a document.

**11. Camera.** Static per plate. Scrolling plates pan on x only (plates extend width, never height, §8.3), clamped to `camera.min_x..max_x`, and **follow focus, never the pointer**: a KEY-set focus outside a central dead zone (`CAMERA_DEAD_ZONE` of view width), or whose hit rect is not wholly in view, eases the camera over `CAMERA_PAN_MS` to centre it; a POINTER-set focus never pans (the pointer is already there); keyboard cycling onto an off-screen hotspot pans to it (keyboard reach). Edge-scroll is forbidden (a hover-only affordance, C2). For aspect ratios other than 16:9 the 4.7 `expand` default would show beyond the plate (concept, Technical Risks); the stretch ADR decides letterboxing **(PROV)**, and the framework clamps so the view never shows outside the plate regardless.

**12. Cursor.** Three silhouettes only (art bible §7.3), differing by shape, never colour: the thin pointing hand (default, over hotspots, over thresholds, over `void`), the caret over selectable text in sheets, and the stamp-hand during filing. No hotspot, exit or disabled cursor state exists: the hotspot lifts, the door shows its ajar notch and the slip's EXIT prefix, `void` shows in the slip. During a wipe the cursor is hidden and input is blocked. Size `CURSOR_PX` (32 at 720, 48 at 1080), hit point at the fingertip, scaled by `cursor_scale`. The cursor API is **NOT SOURCEABLE** (hardware cursor preferred; a software cursor must be drawn every frame with no lag; spike). *Rejected:* a five-state cursor (moves discoverability onto the pointer, which keyboard and gamepad players do not have).

**13. Modal layers.** When Paper UI opens a sheet it calls `push_input_block("sheet:<id>")`: the controller pushes `{focused_id, source}` onto a stack, drops the lift (one focus on screen, the sheet's), scene input is disabled recursively (the 4.5 single-property recursive disable is SOURCED as a feature, input.md line 23; the property name is **NOT SOURCEABLE**, spike; the block count gates this system's own input handling as belt and braces), and the sheet takes its first bracket. On `pop_input_block`: pop, `grab_focus()` on the saved id, re-lift; the pointer latch holds until the pointer moves. If the saved hotspot became `filed`, restore to it anyway; if `void` or `hidden`, move to the next in ring (KEY) or none (POINTER). Nested sheets and dialogue transcripts use the same stack. `cancel` on a bare plate does nothing in this system. **A timed choice (interrogation or search) is always presented as a sheet**: the room is `suspended` under it, owns no part of the timer, and no Scene Flow or Dialogue clock may run while a scene is `active` (with a timer running, the block count is always greater than zero). *Rejected:* keeping the lift raised under the sheet (two focuses); resetting to none on close (a keyboard user loses their place).

**14. Headless rule and what is observed.** `SceneHost`, `NullSceneHost`, `SceneDataValidator`, `FocusOrdering` and the input-action table import nothing from the scene tree; `EngineSceneHost` and everything under `src/scene/engine/` may. The story simulator and the unit tests bind `NullSceneHost`. A CI path check enforces the direction (GDD 1 Core Rule 11, GDD 2 Core Rule 14). Before gdUnit4 runs, `godot --headless --path . --import` must run or the suite exits having run nothing (SOURCED: current-best-practices.md lines 214–215). What only run-and-observe can verify, with retained screenshots: plate and layer compositing, the corner lift and 3 px keyline (4.7 draws `CanvasItem` lines without an anti-aliasing feather, rendering.md line 11, so coded keylines are widened), the cursor, hover feel, the 720p ⅔ stretch, pixel snap, the paper wipe.

**15. Spike list (NOT SOURCEABLE, in priority order; recorded for the renderer and plate-authoring ADRs).** `/setup-engine refresh` on the developer's machine (VERSION.md line 6: the installed editor is NOT DETERMINED, so every 4.5+ claim above may not exist locally); AccessKit role, name and disabled property names in GDScript, and whether a Control with mouse filter *ignore* still participates; the recursive-disable property name; the threaded `ResourceLoader` API and the 500 ms / 256 MB measurements; the cursor API; `CanvasLayer`, `CanvasModulate`, `y_sort_enabled` and `z_index` for the T4 stack; the pixel-snap setting; `Camera2D` limits (scrolling plates only); `NavigationAgent2D` 2D arrival-distance names and the `navigation_finished` signal (walking only); `Geometry2D.is_point_in_polygon` (else a hand-rolled test); `Control.offset_transform_*` (4.7, sourced at current-best-practices.md lines 138–141) as the corner-lift mechanism.

### States and Transitions

**Scene lifecycle:** `unloaded → preloading → ready → active ⇄ suspended → exiting → unloaded`, plus `failed`.

| Transition | Trigger | Effect |
|---|---|---|
| unloaded → preloading | `preload_scene` | validator runs (debug: full; release: structural); failure → `failed` with errors returned |
| preloading → ready | assets resident | emits `scene_preloaded`; dependents load their per-scene assets |
| ready → active | `activate_scene` (after the wipe if requested) | emits `scene_ready`; input blocked until the block count is zero |
| active → suspended | block count 0 → 1 (a sheet, a wipe, a walk in progress) | lift dropped, focus retained on the stack |
| suspended → active | block count 1 → 0 | focus restored (Rule 13) |
| active → exiting | `activate_scene(other)` | wipe out, input blocked |
| exiting → unloaded | wipe finished | emits `scene_exited`; resources released |

At most one scene is `active` or `suspended`; at most one is `preloading` or `ready`; a third `preload_scene` returns `error(residency)`.

**Hotspot lifecycle.** `declared` (in the sidecar) → `registered` (on `ready`; availability `unfiled`) → availability moves among `unfiled / filed / void / hidden` only through `set_hotspot_state`, in any direction (a reactive event may void a telephone and later restore it). Orthogonally, focus is entered by pointer-enter, ring step or spatial step and left by pointer-exit (POINTER source only), another set, `hidden`, a sheet (stacked), or scene exit; `hidden` forces focus off and, if the hotspot was focused, moves it to the next in ring. The walking outcome adds `approaching` (walk in progress; `cancel` returns to focused) → activated (signal emitted) → focused.

### Interactions with Other Systems

| System | This system provides | This system requires | Interface owner |
|---|---|---|---|
| **Investigation & Fact (PROV)** | `hotspot_activated`, `hotspot_examined`, `hotspot_ids` | nothing directly | Fact decides what a hotspot yields and tells Scene Flow which are filed |
| **Scene Flow (PROV)** | the whole `SceneHost` interface and `NullSceneHost` | `preload_scene` after rules, `activate_scene` at next-scene, `set_hotspot_state` before activation, `set_focus`, `push/pop_input_block` | Scene Flow owns door semantics (`exits[{to, when}]`) and the boundary order |
| **Overlay & Surveillance Rendering (GDD 9)** | the scene root for the overlay stack, per-hotspot `layer_filed` crop and offset for carbon ghosts, `hero.rect`, `figure_band`, `scene_preloaded`; a bound red prop replaces the hotspot's `layer` texture at equal bounds (the `focus_layer` swap mechanism; GDD 9 Core Rule 5), and a `layer_lit` variant per hotspot under the lamp pool is proposed as a Rule 1 / E08 data change (GDD 9 Open Questions) | its resident bytes via `report_resident_bytes(owner, scene_id, bytes)` (an observation shown in the debug overlay, never a verdict) | Carbon, stamps and tint are never drawn here |
| **Character Presentation (GDD 10)** | `figure_band`, `baseline_y` and `kind` per hotspot, the y-sort root, `focus_changed`, `walkable` and walk/arrival events (walking outcome), `scene_preloaded`; the sidecar's `figures` block (crops per pose per `kind: person` hotspot with `_focus`/`_lit` twins at equal bounds, `standing_point`) validated by GDD 10's `CastDataValidator` inside this system's validator; `kind: person` hotspots carry no `layer*` of their own (amendment applied) | the avatar node (walking) or pose layers (standing) parented under the scene root; `report_resident_bytes("character", …)` into W13 | Figures are never keylined by this system; their keylines are painted twins GDD 10 swaps |
| **Dialogue & Interrogation (PROV)** | `hotspot_activated` for `kind: person` | `push/pop_input_block` around its transcript sheet (via Paper UI) | Timers are its own; this system has none |
| **Dossier State Model** (GDD 1) | nothing | the scene id form `a1_vera/s3`; the headless rule | Never reads or writes fields |
| **Narrative Content Format** (GDD 2) | `scene_vocab.json` (location, hotspot, exit ids) for the lint | `StringLookup.text(name_key)`, the one string call | Content stays id-only |
| **Settings Store (PROV)** | the action list for remapping; the settings it must expose (Rule 9) | bindings, `reveal_mode`, `tooltip_mode`, `cursor_scale`, `ui_scale`, locale | No defaults hardcoded |
| **Paper UI (PROV)** | `hotspot_examined`, `hotspot_counts`, forwarded `dossier`/`cancel`, the focus position for the slip | `push/pop_input_block` around every sheet; draws the slip, the HUD and the read count | Documents stream on open; ≤ 4 resident is its rule |
| **Save/Load (PROV)** | nothing to persist | nothing | Availability is re-derived by Scene Flow from the dossier on load; camera and focus are not saved |
| **Audio (PROV)** | `hotspot_activated`, `hotspot_examined`, `scene_ready`, wipe start/end | nothing | Paper, stamp and wipe sounds are Audio's |

## Formulas

*Proposed by the systems designer. Every length is an integer in 1080 plate space unless a variable says otherwise; the ⅔ stretch is the engine's and appears only so the 720 case can be reasoned about (Core Rule 1: the framework converts nothing). Constants marked (D) live in `assets/data/scene_framework.json`, one copy read by `SceneDataValidator` at build and load and by the runtime; (B) are build-tool, CI or playtest config under `tools/scene/`; (A) are art-bible values read by pointer. Bytes are decimal MB, the unit art bible §8.7 uses. Four proposed constants were challenged and adopted (`HIT_MIN` 66, `SCENE_BUDGET_WARN` 224, the crossing criterion split into `HOP_S` and `PLATE_CROSS_S`, `WIPE_MS` 360 from the art director); each is recorded in place.*

### 1. Hit test

The hit-test formula is defined as:

`hit(p, h) = p ∈ region(h)`, with `region(h) = [x₀, x₁) × [y₀, y₁)` for a rect and the even-odd crossing number for a polygon; `hit_id(p) = argmin_{h : hit(p, h) ∧ avail(h) ≠ hidden} (area(h), id(h))`, `none` if the set is empty. The engine delivers `p` in plate space: `p₁₀₈₀ = p₇₂₀ × 1.5` under the ⅔ stretch.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `p` | Vector2i | 0–`plate_w`−1 × 0–1079 | calculated (engine stretch) | Pointer or gamepad-cursor position in plate space |
| `region(h)` | half-open rect or simple polygon | ≥ 3 vertices, inside the plate (E07) | data file (`hit`, after §2 padding) | The hotspot's hit region |
| `avail(h)` | enum | unfiled/filed/void/hidden | calculated (Scene Flow) | Availability; `hidden` has no region |
| `area(h)` | int | `HIT_MIN`²–(512 + 2·margin)² | calculated | Region area, the tie-break |
| `hit_id` | StringName or `none` | one id | calculated | What the next `activate` hits |

**Output Range:** at most one id; `none` over bare plate, figures (figures own no region) and `hidden`. E12 makes regions pairwise disjoint, so the `argmin` matters only in a release build that degraded past E12; there the smaller region wins (a slip lying inside a desk's margin is never shadowed by the desk), ties by id. Half-open edges put a point on a shared boundary in exactly one region.
**Example:** pointer (812, 420) in a 720 window arrives as (1218, 630). `drawer_desk` hit rect {1210, 599, 96, 66}: 1210 ≤ 1218 < 1306 and 599 ≤ 630 < 665 → hit. Polygon (400,900) (640,980) (640,996) (400,916): a ray from (500, 950) crosses one edge → odd → inside. *Rejected:* winding number (differs from even-odd only on self-intersecting polygons, which E07 and E10 forbid; even-odd is what the `Geometry2D.is_point_in_polygon` spike is expected to confirm, and the hand-rolled fallback is twelve lines).

### 2. Target padding

The target padding formula is defined as:

`m_x = max(0, ⌈(HIT_MIN − w)/2⌉)`, `m_y = max(0, ⌈(HIT_MIN − h)/2⌉)`, `hit_rect = clip(grow(bbox, m_x, m_y), plate)`; valid iff `max(m_x, m_y) ≤ ⌊w/2⌋` (padding stays inside the §6.4 clear margin) ∧ `∀ g ≠ h: gap(hit_rect_h, hit_rect_g) ≥ HIT_GAP` ∧ `min(w′, h′) ≥ HIT_MIN`. A polygon `hit` is not padded; its bounding box must already satisfy `HIT_MIN`.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `w`, `h` | int | 33–512 | data file (`layer` crop bbox) | Object width and height |
| `HIT_MIN` | int | 60–96 | constant (D, 66) | Smallest hit side; 44 px at 720 |
| `HIT_GAP` | int | 36–72 | constant (D, 48) | Minimum edge-to-edge distance between padded rects; 32 px at 720 |
| `m_x`, `m_y` | int | 0–⌊w/2⌋ | calculated | Padding per axis |
| `gap` | int | ≥ 0 | calculated | Axis-aligned distance between two rects |
| `hit_rect` | rect | ⊇ bbox | calculated (compiler, `tools/scene/`) | Region §1 tests |

**Output Range:** each side ≥ `HIT_MIN` unless the plate edge clips it (Edge Case 3). A derived floor: `w ≥ HIT_MIN/2 = 33 px` (22 at 720), because the margin is only `w/2` deep; anything narrower cannot be a hotspot and E12 says so at export. *Challenge adopted:* `HIT_MIN` 64 → 66. 64 × ⅔ = 42.67, neither a whole pixel (§8.3 asks multiples of 3) nor the 44 px platform minimum; 66 lands on exactly 44 at 720.
**Example:** `drawer_desk` bbox 96×40: `m_x = 0`, `m_y = ⌈26/2⌉ = 13 ≤ 48` → {1210, 599, 96, 66}. A slip 40×28: `m_x = 13`, `m_y = 19 ≤ 20` → 66×66. A 30 px key: `m_x = 18 > 15` → E12. *Rejected:* padding computed at runtime from the window size (E12 would then describe no particular build, and two players would have different rooms).

### 3. Focus ring order

The focus ring formula is defined as:

`row(h) = ⌊anchor_y(h) / FOCUS_ROW_HEIGHT⌋`, `key(h) = (row(h), anchor_x(h), id(h))`, `ring = sort(hotspots ∖ hidden, key)` unless `focus_order` is authored, then `ring = focus_order ∖ hidden`; `next(h) = ring[(i(h) + 1) mod |ring|]`, `prev` symmetric.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `anchor_x`, `anchor_y` | int | inside the plate | data file (`lift_anchor`) | Corner the lift pivots on |
| `FOCUS_ROW_HEIGHT` | int | 48–108 | constant (D, 72) | Row band; a third of a 216 px figure, 48 px at 720 |
| `row` | int | 0–14 | calculated | Reading row |
| `ring` | list | 1–8 ids | calculated (export writes the default) | Tab order |

**Output Range:** a permutation of the non-hidden ids; wraps; `|ring| = 1` → `next = self`; empty → focus `none`, Tab does nothing. Quantisation is real: anchors at y 700 and 640 sit in rows 9 and 8 although two desk objects 60 px apart could also share one, which is why the export writes the default into `focus_order` and the artist may reorder.
**Example:** anchors a(300,700) b(1210,612) c(900,640) d(1500,705) e(640,300) f(1300,290) → rows 9, 8, 8, 9, 4, 4 → ring `e, f, c, b, a, d`. *Rejected:* gap clustering (a new row wherever `Δy` exceeds a threshold): adding one hotspot can reorder the whole ring, so an authored override rots.

### 4. Spatial focus cost

The spatial focus formula is defined as:

`v = anchor(c) − anchor(f)`, `along = v · d`, `perp = v · d⊥`; candidate iff `along > 0 ∧ |perp| ≤ along` (the 90° cone); `cost(c) = √(along² + perp²) + OFF_AXIS_PENALTY × |perp|`; winner `argmin (cost, id)`; empty set → no move.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `f`, `c` | hotspot | ring members | calculated | Focused and candidate (`hidden` excluded; `void`, `filed` included) |
| `d` | unit vector | (±1,0), (0,±1) | calculated (`focus_dir`) | Pressed direction in plate space |
| `OFF_AXIS_PENALTY` | float | 0.5–3.0 | constant (D, 1.5) | Weight on perpendicular offset |
| `cost` | float | > 0 | calculated | Lower wins |

**Output Range:** `cost ∈ (0, (√2 + P) × along]`; at the cone edge cost is 2.91 × `along` against 1.0 on-axis, and along the iso axis (26.6°, `perp = 0.5 along`) 1.87, so the on-axis neighbour wins unless it is 1.87× further away.
**Example:** focus `c`(900,640), press right: `b` along 310, perp 28 → 311.3 + 42 = 353.3; `d` along 600, perp 65 → 701; `f` along 400, perp 350 → 1056.5; `a`, `e` behind → `b`. *Rejected:* the engine's focus neighbours (split across the 4.6 dual focus and dependent on Control order); plain Euclidean (pressing right picks a hotspot 40° off-axis over one straight ahead 1.1× further, which players read as random).

### 5. Pointer latch

The pointer latch formula is defined as:

`latch_holds = |p − p_latch| < POINTER_LATCH_PX × 1.5`, where `p_latch` is the pointer position recorded at the last KEY set or sheet pop; hover re-asserts on the first event where it fails. Displacement, not path length.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `p`, `p_latch` | Vector2i | plate space | calculated | Current and latched pointer positions |
| `POINTER_LATCH_PX` | int | 3–8 | constant (D, 4) | Authored in 720 window px (Core Rule 4's wording), the smallest window; one multiplication at load, never per event |
| `latch_holds` | bool | — | calculated | Hover ignored while true |

**Output Range:** physical threshold 4 px at 720, 6 at 1080, 12 at 4K, all above the 1–2 px sensor-jitter floor. Oscillation never crosses it; drift in one direction does.
**Example:** jitter 3 px at 720 → 4.5 < 6, holds; 5 px → 7.5, re-asserts. *Rejected:* a time latch (ignore hover for 300 ms): a clock in a system that owns none, and a resting pointer would steal focus when it ran out.

### 6. Camera follow

The camera follow formula is defined as:

`centre = cam_x + view_w/2`; `needs_pan = source = KEY ∧ (|anchor_x − centre| > CAMERA_DEAD_ZONE × view_w/2 ∨ hit_rect ⊄ view)`; `max_x_eff = min(camera.max_x, plate_w − view_w)`; `target_x = clamp(anchor_x − view_w/2, camera.min_x, max_x_eff)`; if `view_w > plate_w`, `target_x = (plate_w − view_w)/2`. Ease-out quadratic over `CAMERA_PAN_MS`.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `cam_x` | int | `min_x`–`max_x_eff` | calculated | View's left edge in plate space |
| `view_w` | int | 1440–2520 at 1080 high | calculated (stretch ADR) | Visible plate width; 1920 at 16:9 |
| `plate_w` | int | 1920–3840 | data file | Static plates imply `camera = {0, 0, 0}` |
| `CAMERA_DEAD_ZONE` | float | 0.3–0.8 | constant (D, 0.6) | Fraction of view width that does not pan; 576 px half-width at 1920 |
| `CAMERA_PAN_MS` | int | 180–400 | constant (D, 240, added) | Two corner lifts; the only camera motion |
| `target_x` | int | clamped | calculated | Pan destination |

**Output Range:** the view never shows outside the plate while `view_w ≤ plate_w`; wider views centre and the strip beyond is the stretch ADR's. *Challenge adopted:* the `hit_rect ⊄ view` clause. With 0.6 alone an anchor 400 px from the edge does not pan while a 512 px layer hanging off it is clipped by 112 px; keyboard reach needs the whole object on screen. A derived behaviour: at 4:3 (`view_w` 1440) a static 1920 plate gets `max_x_eff = 480` and pans like a scrolling one.
**Example:** plate 2880, `cam_x` 0, Tab onto anchor 2300: |2300 − 960| = 1340 > 576 → `target_x = clamp(1340, 0, 960) = 960`. Tab onto anchor 1400 with rect 1400–1496: 440 ≤ 576 and in view → no pan. *Rejected:* edge-scroll or pointer follow (a hover-only affordance, C2); centring on every KEY set (the room moves on every Tab; §7.4 forbids parallax and breathing).

### 7. Resident-byte sheet

The resident-byte formula is defined as:

`bytes(t) = w_t × h_t × 4 × (4/3 if mipmapped(t) else 1)`; `bytes_fw = bytes(plate) + Σ_h (bytes(layer_h) + bytes(focus_layer_h) + bytes(layer_filed_h))`; build `bytes_est = bytes_fw + bytes_overlay + OTHERS_RESERVE_MB` (`bytes_overlay` is GDD 9 Formulas §9's lighting, stamp-atlas and grain bytes; `OTHERS_RESERVE_MB` carries no overlay line; amendment applied for GDD 9); runtime `bytes_scene = bytes_fw + Σ_owner reported(owner, scene_id)`; W13 warns at `≥ SCENE_BUDGET_WARN`, errors at `> SCENE_BUDGET_MAX`.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `w_t`, `h_t` | int | ≤ 3840×1080 plate, ≤ 512² layer | data file | Texture dimensions; RGBA8 worst case until the import spike |
| `mipmapped` | bool | — | constant (A, §8.4: plates and layers yes, UI no) | 4/3 = 1 + ¼ + ¹⁄₁₆ + …, the bible's 1.33 |
| `OTHERS_RESERVE_MB` | int | 150–200 | constant (B, 181, added) | §8.7 T1 worksheet lines not this system's: sheet 16 + portraits 128 + UI atlas 16 + 4 documents 21 |
| `reported` | int | ≥ 0 | calculated (`report_resident_bytes`) | Each owner's observation |
| `SCENE_BUDGET_WARN` | int MB | 192–240 | constant (D, 224) | Warning line |
| `SCENE_BUDGET_MAX` | int MB | — | constant (A, §8.7 T1, 256) | Ceiling, not tunable here |

**Output Range:** `bytes_fw` ≤ 11.1 (static) or 22.1 (scrolling) + 24 crops × 1.40 ≈ 55.7 MB; `bytes_est` ≤ 237. *Challenge adopted:* a warning at 200 sits below the bible's own worst case (202), so the canonical scene would warn on every build and the line would become noise, the failure GDD 2 names for `PROSE_WARN`. 224 leaves 32 MB, which is the cost of the one mistake W13 exists to catch (a 2× paint imported at 2× adds 33 MB and trips it).
**Example:** MVP office, static plate 11.06 MB, six hotspots with 300×200 layer, focus and filed crops at 0.32 MB each = 5.76 → `bytes_fw` 16.8, `bytes_est` 197.8 < 224, pass. *Rejected:* counting only this system's bytes against 256 (every scene passes; the ceiling is per scene, not per owner).

### 8. Draw estimate

The draw estimate formula is defined as:

`draws_est = 1 + n_vis + n_lift + FIG_MAX + n_vis + STAMP_MAX + 2 + DOC_MAX + UI_MAX`, with `n_vis = |hotspots ∖ hidden|`, `n_lift = n_unfiled + [focused is filed]` (reveal held, the worst case), the second `n_vis` the carbon ghosts, and 2 for grain and tint.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `n_vis`, `n_unfiled` | int | 0–8 | calculated | From the sidecar (build) or availability (runtime) |
| `FIG_MAX`, `STAMP_MAX`, `DOC_MAX`, `UI_MAX` | int | 6, 12, 20, 60 | constant (A, §8.7 T3) | Other owners' ceilings, by pointer |
| `DRAW_TARGET` | int | — | constant (A, §8.7 T3, 150) | Steady-state target |
| `draws_est` | int | 101–125 | calculated | Expected count |

**Output Range:** with E02, `draws_est ≤ 125 < 150`: W14 cannot fire at build time. *Challenge adopted:* the formula is the debug overlay's expected value and W14 is a runtime observation: `measured − draws_est > 17` (T3's reserve) warns; the measured count comes from the draw-call monitor (spike). The walking avatar is one of `FIG_MAX`.
**Example:** MVP office, `n_vis` 6, all unfiled → 1 + 6 + 6 + 6 + 6 + 12 + 2 + 20 + 60 = 119. *Rejected:* a draw per keyline (the keyline is painted into the layer PNG, §8.5, and costs nothing).

### 9. Walk time (walking outcome only)

The walk time formula is defined as:

`t_walk = |path| / WALK_SPEED_PX_S`, `|path| = Σ segment lengths`; proof criteria `t_walk(diam(walkable)) ≤ PLATE_CROSS_S` and `median_{i≠j} t_walk(approach_i → approach_j) ≤ HOP_S`; skating `slide = WALK_SPEED_PX_S × WALK_FRAMES / WALK_FPS / STRIDE_PX`, pass in 0.8–1.25.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `WALK_SPEED_PX_S` | int | 280–480 | constant (D, 360) | Screen speed, plate px/s |
| `PLATE_CROSS_S` | float | 3.5–6 | constant (B, 4.5) | Longest path across `walkable` |
| `HOP_S` | float | 1–2 | constant (B, 1.5, added) | Median hotspot-to-hotspot path |
| `WALK_FRAMES`, `WALK_FPS` | int | 8, ≤ 12 | constant (A, §8.7 T8) | One walk cycle |
| `STRIDE_PX` | int | 150–260 | data file (sprite-sheet sidecar, Character Presentation) | Authored ground covered per cycle |
| `t_walk`, `slide` | float | > 0 | calculated | Travel time; foot-slide ratio (1.0 = no skating) |

**Output Range:** `t_walk` unbounded above by path; the criteria bound it. *Challenge adopted:* 1.5 s for a plate crossing needs 1,067 px/s over a 1,600 px floor, 5.6 figure heights per second; at 8 frames and 12 fps that is 711 px per stride cycle, which is a slide, not a walk. The 1.5 s becomes `HOP_S` (the hop the player makes sixty times a chapter) and the crossing gets 4.5 s at 360 px/s; the proof measures both beside authoring time, as Core Rule 10 asks.
**Example:** diameter 1,600 → 4.44 s ≤ 4.5; median hop 500 → 1.39 s ≤ 1.5; stride 230 → `slide` = 360 × 0.667 / 230 = 1.04. *Rejected:* speed scaled on the iso y axis (slower vertical travel, 2:1); a knob `WALK_ISO_Y` is reserved at 1.0 and the proof decides whether uniform speed reads as sliding on y.

### 10. Read count

The read count formula is defined as:

`counts[k] = {total: |{h : kind(h) = k ∧ avail ≠ hidden}|, filed: |{… ∧ avail = filed}|, void: |{… ∧ avail = void}|}`; Paper UI prints `filed` of `total`; the screen reader hears `total`, `filed`, `void`; `reachable = total − void`.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `k` | kind | paper/object/door/phone/person | data file | Count key |
| `total`, `filed`, `void` | int | 0 ≤ filed + void ≤ total ≤ 8 | calculated | Per scene, from availability |

**Output Range:** bounded by E02; `hidden` never counts (a hidden object was never in the room for the reader; Player Fantasy forbids a count that lies).
**Example:** MVP office: `paper {6, 4, 1}`, `person {2, 0, 0}` → "4 of 6 documents", read aloud "6 documents, 4 read, 1 void". *Rejected:* counting `hidden` in `total` (tells the player of a document they cannot find).

### 11. 720p discoverability pass

The discoverability pass rule is defined as:

`found_i = |{id : activated by player i within FIND_WINDOW_S, reveal disabled}|`; `miss_i = |activate presses with hit_id = none ∧ dist(p, nearest hit_rect) ≤ MISS_NEAR_PX|`; `pass = median_i found_i ≥ n_h − 1 ∧ Σ miss_i / Σ found_i ≤ MISS_RATIO ∧ |{i : found_i < n_h − 2}| ≤ FAIL_PLAYERS_MAX ∧ n ≥ N_MIN`.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `n_h` | int | 3–8 (6 in the MVP scene) | data file | Hotspots of `kind ≠ person` in the test scene (people are not "found"); thresholds 5 of 6, floor 4 |
| `FIND_WINDOW_S` | int | 180–360 | constant (B, 240) | Observation window per player |
| `MISS_NEAR_PX` | int | 64–128 | constant (B, 96) | Near-miss radius; a far click is exploration (or a walk) |
| `MISS_RATIO` | float | 1–3 | constant (B, 2.0) | Misses per find |
| `FAIL_PLAYERS_MAX`, `N_MIN` | int | 1; 5–10 | constant (B, 1; 5) | Tolerance and minimum sample |
| `pass` | bool | — | calculated | Acceptance Criteria read it |

**Output Range:** boolean; with `n < N_MIN` the run is a smoke, not a verdict. Reveal is disabled in the pass run because C1's hypothesis is the keyline; a second run with reveal enabled must reach `n_h` of `n_h` median, which verifies the guarantee rather than the hypothesis.
**Example:** n = 8, found 6, 5, 5, 6, 4, 5, 3, 6 → median 5 ≥ 5; one player below 4 ≤ 1; misses 52 / found 40 = 1.3 ≤ 2.0 → pass. *Rejected:* time-to-first-find (a speed metric in a Pillar 5 room; the test asks whether the room is readable, not how fast).

## Edge Cases

*From the systems designer over the rule and formula space; all resolutions are exact.*

1. **If a sidecar declares a ninth hotspot**: E02 fails the build; a release load registers the first eight of `focus_order` and sets the ninth `hidden` with a logged error; `set_hotspot_state` on it returns an error. *A crash on a hand-edited sidecar helps nobody; a deterministic drop keeps the ring valid.*
2. **If two padded hit rects overlap or sit closer than `HIT_GAP`**: the compiler shrinks both paddings equally along the conflict axis until the gap is exactly `HIT_GAP`; if either side then falls below `HIT_MIN`, E12 fails and the artist moves an object. Never resolved at runtime, so the room is the same for every player.
3. **If a padded rect leaves the plate**: it is clipped to the plate and the opposite side grows by the shortfall, still bounded by `⌊w/2⌋`; still short → E12. *The screen edge is itself an infinite target, so clipping costs nothing.*
4. **If the hero id equals a hotspot id**: one object; the hotspot record governs input, focus and role (`button`, not `image`); `hero.rect` governs Overlay's stamp avoidance and must contain the hotspot's `lift_anchor` or E04 fails (two objects wearing one id). No ring privilege (Core Rule 4).
5. **If a sheet closes while the restored focus is off-screen on a scrolling plate**: on pop, `hit_rect ⊄ view` pans the camera as for a KEY set regardless of source. *The camera does not move under a sheet, so this arises only when a sheet interrupted a pan; Formulas §6 handles it without a special case.*
6. **If `set_hotspot_state(hidden)` hits the focused hotspot while a sheet is open**: the layer and region go immediately; the stack entry is untouched; on pop the restore finds it hidden and moves to the next non-hidden id after its former position in `focus_order` (KEY) or `none` (POINTER). *Scene Flow caused the change and has the context; the controller only keeps the ring consistent.*
7. **If `preload_scene` is called for a third scene**: returns `{ok: false, errors: [residency]}` synchronously; nothing is evicted. `NullSceneHost` returns the same, so a boundary-order bug surfaces in the simulator, not in RAM.
8. **If `activate_scene` targets a scene that failed validation in release**: a structural failure (E01, E07, missing plate) leaves it `failed`; the call returns `{ok: false, errors}`, no wipe starts, the current scene stays active with input restored; Scene Flow routes around it. Non-structural failures degrade to `ready` with warnings and activate normally. *The wipe never starts for a scene that is not `ready`.*
9. **If the pointer rests on A, Tab moves focus to B, then the mouse jitters**: 3 px at 720 (4.5 plate px) holds the latch, B keeps focus; 5 px (7.5) re-asserts hover, A takes POINTER focus and B drops. Displacement from `p_latch`, so two 3 px moves in one direction re-assert and two opposed ones do not.
10. **If `reveal` is held when a sheet opens**: every lift drops with the block (one focus on screen); on pop the action's held state is re-read, not its edge, so lifts return if the key is still down; under `toggle` the toggle survives the sheet.
11. **If `reveal_mode: always` runs with `tooltip_mode: focus`**: not noise. The lifts are permanent and the focused hotspot shows only the 3 px keyline plus, after `TOOLTIP_DWELL_MS`, one slip; slips never appear for unfocused hotspots in any mode.
12. **If a `void` hotspot is activated**: `hotspot_examined(id)` is emitted (the slip shows the struck bracket) and `hotspot_activated` is not; no walk in the walking outcome. *A disabled AccessKit control that still activates lies to a screen reader; if narrative wants a line on touching a removed object, Scene Flow sets `unfiled` with a different content action.*
13. **If a `filed` hotspot is activated**: `hotspot_activated(id)` is emitted exactly as for `unfiled` (walk included); counts unchanged; what it yields is Investigation & Fact's. *Re-reading from the room is a keyboard user's only way to re-check a document.*
14. **If a walk is interrupted by `set_hotspot_state(hidden)` on its target**: the walk aborts where the avatar stands, facing from the last segment, nothing emitted; focus moves as in case 6; the camera returns to following focus. *A defensive case: Core Rule 5 forbids an availability change that the player did not cause, so this path is a Scene Flow defect caught by a debug assert, like case 15; the release behaviour above keeps the ring consistent. Emitting for an object that is no longer there would hand Scene Flow an id it just removed.*
15. **If no path exists to an `approach` point**: activation is immediate from where the avatar stands, `nav.no_path` is logged, facing is unchanged; debug asserts (E10 guarantees `approach ⊂ walkable`, and with avoidance off and no movers nothing blocks dynamically, so this is a malformed sidecar degrading in release). *Walking is never a puzzle.*
16. **If the avatar's head covers a focused hotspot**: nothing moves; the hotspot still hits (figures own no region) and the figure occludes the lift by y-sort, which is the correct drawing; a debug warning logs once per (scene, hotspot). Build-time W15 (walking outcome): the top quarter of the figure box standing at `approach` must not intersect its own hotspot's hit rect, which is §6.4's "never behind a figure's head" made checkable.
17. **If the window is 21:9 or 4:3 before the stretch ADR**: hit regions and focus are plate-space and unaffected. At 4:3, `view_w` 1440 makes a static plate pan (Formulas §6, `max_x_eff` 480); at 21:9, `view_w` 2520 > 1920 centres the plate and the strip beyond shows the project clear colour (soot) with a debug warning; letterboxing versus wider plates is the ADR's.
18. **If the locale changes mid-scene**: every registered hotspot's `name_key` is re-resolved; accessible names and the region name update; `hotspot_examined` is re-emitted for the open slip so Paper UI redraws; focus, availability and the camera are untouched; the live region updates the count only, never the list.
19. **If `focus_order` omits an id**: E04 fails the build; a release load appends the missing ids in default reading order (Formulas §3) and drops ids that are not hotspots, logging both. *A ring with a hole is a hotspot a keyboard user can never reach.*
20. **If `pop_input_block(reason)` names a reason that was never pushed**: ignored, count unchanged, error logged; debug asserts. Reasons are a multiset: pushing `"sheet:doc_7"` twice needs two pops, so nested identical sheets cannot unblock under each other.
21. **If `scene_vocab.json` is stale against the sidecars**: the vocab carries the sidecar hashes it was built from; the content lint compares and reports `vocab stale` as an error. CI runs `validate_scenes.gd` before the content lint, so CI never sees it stale; a local run warns and names the command.
22. **If a 720p window runs `ui_scale` 150%**: hit rects do not scale (they are painted geometry in plate space, 44 physical px minimum at 720); the cursor scales by `cursor_scale` only; sheets, HUD and the slip scale (Paper UI's), and the slip is never hit-tested (`mouse_filter` ignore), so an enlarged slip cannot steal hover from the hotspot beside it. *Scaling hit rects would move them off the objects they mark.*

## Dependencies

*Hard* means the system cannot function without the other; *soft* means it works without it and is improved by it. Rows marked **(PROV)** name a system whose GDD is not yet written; the interface is this GDD's offer until that GDD reciprocates. Reciprocity today: GDD 2 lists this system as a soft dependent supplying the `location` and `hotspot` vocabularies, which matches the row below; GDD 1 does not list this system, correctly, because the two never touch at runtime.

| System | Direction | Hard/Soft | Interface |
|---|---|---|---|
| Narrative Content Format & Strings (GDD 2) | Mutual at build time; this depends on it at runtime for one string | Soft | This system emits `scene_vocab.json` for GDD 2's lint (dangling `location`/`hotspot` refs); it resolves `name_key` through `StringLookup.text()` for the accessible name and the slip, and nothing else |
| Dossier State Model (GDD 1) | None at runtime | — | The scene id form `a1_vera/s3` and the headless rule are followed; no field is ever read or written here |
| Scene Flow | Depends on this **(PROV)** | Hard | The `SceneHost` interface: `preload_scene`, `activate_scene`, `unload_scene`, `set_hotspot_state`, `set_focus`, `push/pop_input_block`; signals `scene_preloaded`, `scene_ready`, `hotspot_activated`, `hotspot_examined`, `scene_exited`; `NullSceneHost` for the simulator |
| Investigation & Fact | Depends on this **(PROV)** | Hard | `hotspot_activated`, `hotspot_examined`, `hotspot_ids`; it decides what a hotspot yields |
| Overlay & Surveillance Rendering | Depends on this **(PROV)** | Hard | The scene root for the T4 stack; per-hotspot layer texture and offset for carbon ghosts; `hero.rect`; `scene_preloaded`; `report_resident_bytes` |
| Character Presentation | Depends on this **(PROV)** | Hard | `figure_band`, `baseline_y`, the y-sort root; under walking, `walkable` and walk/arrival events; parents its figures under the scene root |
| Dialogue & Interrogation | Depends on this **(PROV)** | Soft | `hotspot_activated` for `kind: person`; input blocks around its transcript sheet through Paper UI |
| Paper UI | Depends on this **(PROV)** | Hard | `hotspot_examined`, `hotspot_counts`, forwarded `dossier`/`cancel`, the focus position for the slip; it calls `push/pop_input_block` around every sheet and draws the slip, the HUD and the read count |
| Settings Store | This depends on it **(PROV)** | Soft | Bindings for the seven actions, `reveal_mode`, `tooltip_mode`, `cursor_scale`, `ui_scale`, locale; absent, the defaults in `assets/data/scene_framework.json` apply |
| Save/Load | None **(PROV)** | — | Nothing persisted here; availability is re-derived by Scene Flow from the dossier on load |
| Audio | Depends on this **(PROV)** | Soft | `hotspot_activated`, `hotspot_examined`, `scene_ready`, wipe start and end |
| Art pipeline tools (`tools/scene/`, art bible §8) | This depends on them at build time | Hard (authoring) | The export script writes the sidecar fields (Rule 1); `validate_scenes.gd` is the build gate; the red-budget and offset gates are art bible §8.7 T7 |
| MVP art-pipeline proof | This depends on its verdict | Hard (for Rule 10) | Sets `presentation.mode: walking | standing` once, from measured times and the plate-crossing feel criterion; the creative director owns the call |

## Tuning Knobs

Column key: **D** = `assets/data/scene_framework.json`, one copy read by `SceneDataValidator` (build and load) and the runtime; **B** = build-tool, CI or playtest config under `tools/scene/`, never shipped; **A** = owned by the art bible and read by pointer, not retuned here; **S** = the player value is Settings Store's, this system owns only the default.

| Knob | Default | Safe range | Too low | Too high | Interacts with |
|---|---|---|---|---|---|
| `HIT_MIN` (D) | 66 | 60–96 | Slips under 44 px at 720; tremor players miss (Player Fantasy test) | Padding exceeds `⌊w/2⌋` on small objects; E12 fails plates that are fine to read | `HIT_GAP`, §6.4 margin, derived floor `w ≥ HIT_MIN/2` |
| `HIT_GAP` (D) | 48 | 36–72 | Adjacent paper on one desk hit-tests as one | Dense desks (6 objects) cannot satisfy E12 | `HIT_MIN`, E05 |
| `FOCUS_ROW_HEIGHT` (D) | 72 | 48–108 | A desk's objects split across rows; Tab zigzags | Shelf and desk merge into one row ordered by x only | `focus_order` default, Formulas §3 |
| `OFF_AXIS_PENALTY` (D) | 1.5 | 0.5–3.0 | Arrow keys pick the nearest object in any direction | Only exact-axis neighbours are reachable; iso-diagonal rooms dead-end | Formulas §4 cone (fixed at 90°) |
| `POINTER_LATCH_PX` (D, 720 px) | 4 | 3–8 | Sensor jitter steals keyboard focus | A deliberate small mouse move is ignored; feels dead | Core Rule 4, sheet pop |
| `LIFT_PX` (A, §6.4, 1080) | 12 | multiple of 3 | — | — | The one-unit disturbance; `focus_layer` paint; 8 px at 720 |
| `LIFT_MS` (A, §7.4) | 120 | not tunable here | — | — | `CAMERA_PAN_MS`, reveal, slip lift |
| `CAMERA_DEAD_ZONE` (D) | 0.6 | 0.3–0.8 | Every Tab pans; the room never waits | Edge hotspots pan only via the `hit_rect ⊄ view` clause (the clause makes this safe) | `CAMERA_PAN_MS`, `camera.min_x/max_x` |
| `CAMERA_PAN_MS` (D) | 240 | 180–400 | A cut, not a pan; disorienting on scrolling plates | Keyboard users wait for the room | §7.4 ease-out, `LIFT_MS` (two lifts) |
| `SCENE_BUDGET_WARN` (D) | 224 | 192–240 | Fires on the bible's own worst case (202); ignored | A 2×-imported plate (+33 MB) reaches `SCENE_BUDGET_MAX` before any warning | `OTHERS_RESERVE_MB`, `SCENE_BUDGET_MAX` (A) |
| `SCENE_BUDGET_MAX` (A, §8.7 T1) | 256 | not tunable here | — | — | W13 error; two scenes resident ⇒ ≤ 2× T1 |
| `OTHERS_RESERVE_MB` (B) | 181 | 150–200 | Build passes scenes the runtime assert rejects | Every scrolling scene warns at build | Formulas §7, `report_resident_bytes` observations |
| `LOAD_BUDGET_MS` (D) | 500 | 300–800 (TD confirms) | Debug asserts on the CI runner's cold cache | The reveal sheet's reading time no longer hides the load | Scene Flow boundary order, `SWAP_BUDGET_MS` |
| `SWAP_BUDGET_MS` (D) | 50 | 16–100 | Asserts on the first frame of every wipe | A hitch visible inside the wipe | `WIPE_MS` (must stay well below) |
| `WIPE_MS` (D) | 360 | 300–400 (ceiling 400, art bible) | The cut reads as a glitch, not a page | Exceeds the ceiling and the player waits | `SWAP_BUDGET_MS`, Audio's wipe sound; 180 ms in, 180 ms out |
| `TOOLTIP_DWELL_MS` (D) | 400 | 250–700 | Slips flicker as the pointer runs down a column | The slip feels unresponsive | `tooltip_mode` (S); KEY focus is immediate |
| `CURSOR_PX` (D, at 1080) | 48 | 36–64 | Lost under grain at 720 (32 px) | Covers the slip's first word | `cursor_scale` (S), §7.3 |
| `ARRIVAL_TOLERANCE_PX` (D) | 8 | 4–16 | Oscillation at the approach point, no arrival | Activation before the avatar faces the object | `WALK_SPEED_PX_S`, NavigationAgent2D arrival (spike) |
| `WALK_SPEED_PX_S` (D) | 360 | 280–480 | Crossing exceeds `PLATE_CROSS_S`; travel becomes pressure | `slide` > 1.25; skating at 12 fps | `PLATE_CROSS_S`, `HOP_S`, `STRIDE_PX` |
| `PLATE_CROSS_S` (B) | 4.5 | 3.5–6 | Forces a sliding speed | Proof passes plates nobody wants to cross | `WALK_SPEED_PX_S`, `walkable` diameter |
| `HOP_S` (B) | 1.5 | 1–2 | Same as above | The sixty-times-a-chapter hop drags | `approach` placement |
| `WALK_ISO_Y` (D, reserved) | 1.0 | 0.5–1.0 | Vertical walks crawl | — | Proof decides |
| `DRAW_TARGET` (A, §8.7 T3) | 150 | not tunable here | — | — | Formulas §8 runtime observation, reserve 17 |
| `FIND_WINDOW_S`, `MISS_RATIO`, `FAIL_PLAYERS_MAX`, `N_MIN`, `MISS_NEAR_PX` (B) | 240, 2.0, 1, 5, 96 | ±60, 1–3, 1, 5–10, 64–128 | Test fails readable rooms; glow gets argued back in | Test passes rooms found by luck | Acceptance Criteria, C1 |
| `presentation.mode` (D) | `standing` until the proof | `walking` / `standing` | — | — | Core Rule 10; set once by the creative director |
| `reveal_mode` (S default) | `hold` | `hold` / `toggle` / `always` | — | `always` as default makes the keyline redundant and the discoverability test meaningless | Settings Store, Edge Case 11 |
| `tooltip_mode` (S default) | `examine` | `examine` / `focus` / `off` | — | `focus` as default puts a slip on every hover; the typed bracket is meant to be asked for | `TOOLTIP_DWELL_MS` |
| Keyline 2 px / 3 px focus (A, §6.4, §8.5) | pointer | not tunable here | — | — | Painted into `layer` / `focus_layer`; the coded fallback widens for 4.7's unfeathered lines |
| Layer crop ≤ 512², plate ≤ 3840×1080 (A, §8.7 T2) | pointer | not tunable here | — | — | E07, E08, Formulas §7 bounds |

Interaction clusters: (a) `HIT_MIN/2 ≤` the smallest authored hotspot width and `HIT_MIN + HIT_GAP ≤` the tightest desk spacing, or E12 fails plates that read fine; (b) `SWAP_BUDGET_MS < WIPE_MS` and `LIFT_MS × 2 = CAMERA_PAN_MS`, so every motion in the room is a multiple of the one authored duration; (c) `SCENE_BUDGET_WARN ≥ OTHERS_RESERVE_MB + bytes_fw(max static)` must hold or every scene warns; (d) `WALK_SPEED_PX_S` is bounded below by `PLATE_CROSS_S` and above by `slide ≤ 1.25` at the authored stride, which is why the proof measures both.

## Visual/Audio Requirements

*Written with the art director from art bible §3.3–3.5, §6.3–6.6, §7.1, §7.3–7.4, §7.6, §8.3, §8.5 and §8.7. Visual/Audio is optional for a Core system; it is written because hotspot legibility is this system's whole surface. Three contradictions found during design are ruled in item 7.*

**1. Art-bible rules this system enforces in data.** The validator (Core Rule 2) is the art bible's *checkable* clauses turned into asserts: one hero and 3–8 hotspots per plate (§6.3; E02, E03); the one-unit disturbance and permanent 2 px keyline painted into `layer`, the 3 px keyline and raised corner painted into `focus_layer` (§6.4, C2; E08 holds their bounds equal); clear margin at least half the hit width (§6.4; E05, with the midtone half of that rule left to the asset-pipeline gate); the figure band free of keylines (§6.6; E06, ruled below); the carbon ghost after filing (§6.4; Rule 5, requested from Overlay); thresholds thick (§3.3; E09 and E11 require `threshold: true` on doors and phones). Nothing visual is derived at runtime: every mark below is a painted crop or a 120 ms translate.

**2. Hotspot state vocabulary.** One axis is availability, one is focus; the marks never share a channel.

| State | Exact mark | Drawn by |
|---|---|---|
| unfiled | `layer`: the object one unit off the grid, 2 px soot keyline | this system |
| focused | `focus_layer` swapped in (3 px keyline, baked raised corner) plus the one-unit lift | this system |
| filed | `layer_filed` (same crop, keyline removed) plus the carbon ghost 2–3 px offset | this system (layer); Overlay (ghost) |
| void | `layer_filed` crop, no lift on focus; the slip shows the greyed bracket struck VOID | this system (layer); Paper UI (bracket) |
| hidden | nothing: no layer, no hit, out of the ring | this system |
| revealed | every unfiled hotspot in its focused pose with the 2 px keyline kept, so the focused one's 3 px still reads; doors one notch further ajar; filed and void unchanged | this system |

`kind: person` has no lift: people do not lift. Focus on a person is the 3 px keyline on the figure layer, which Character Presentation draws on this system's focus signal.

**3. The lift.** One unit is `LIFT_PX` = 12 px at 1080 (8 px at 720, whole pixels under the ⅔ stretch; the knob must stay a multiple of 3). The painted disturbance is one unit; focus adds a second. Mechanism: swap to `focus_layer` on the first frame, then translate the crop rigidly one unit in screen −y (paper rising toward the viewer) over `LIFT_MS`, ease-out quadratic, no rotation. `lift_anchor` is the corner that stays grounded: the export paints the anchor corner one unit lower in the focus crop so that after the translate it lands on its original pixel; the pivot lives in the paint, the motion in the translate, and E08's equal bounds hold. `kind: door` translates zero; its focus crop *is* the extra ajar notch. `kind: phone`: the receiver rises −y like paper. The drop is the same 120 ms reversed. The carbon ghost never moves.

**4. The paper wipe.** A sheet slide, never a page turn (a turn needs bend, which §7.4 forbids) and never a fade. A blank bone sheet at UI value, unlit, grain ≤ 6%, enters from the `wipe_from` edge and travels in one continuous direction: its leading edge covers the old plate in 180 ms, the swap happens under it, its trailing edge uncovers the new plate in a further 180 ms. `WIPE_MS` = 360, hard ceiling 400 ms; any load hold beyond that is a hold with the sheet fully covering, cursor hidden. No alpha changes anywhere in the wipe.

**5. Cursor.** Three silhouettes, soot fill with a 2 px bone edge so it survives soot plates (the one soft shape, Principle C), all in a `CURSOR_PX` frame (48 at 1080, 32 at 720), scaled by `cursor_scale`: the thin pointing hand, hit point at the fingertip; the typewriter caret, 3 × 27 px (whole pixels at ⅔), over selectable text; the stamp-hand during filing, stamp face 24 px. No colour change, ever.

**6. Plates and the export.** Painted 3840×2160, shipped 1920×1080 (scrolling ≤ 3840×1080, width only, one texture), sRGB 8-bit, ICC stripped, straight alpha. The figure band and walkable floor are vector paths in the paint file, never pixels, named `_figure_band` and `_walkable`. The export script writes the sidecar fields of Core Rule 1, including the third crop `layer_filed {png, x, y}` per hotspot; all crops ≤ 512², integer offsets in 1080 space, even dimensions; `focus_order` by anchor rows. Hard edges on whole pixels; no red-tolerance pixel in any crop (art bible T7 Gate A runs over layers too).

**7. Rulings.**
- *(a) The cursor bracket.* Confirmed: the bracket belongs to the typed slip; §6.4's "cursor bracket" is a wording error. §7.3 stands: the cursor never changes for a hotspot.
- *(b) Floor hotspots.* §6.6 wins and E06 splits: a non-threshold hotspot whose hit region intersects `figure_band` is an **error**; a `threshold: true` hotspot may intersect the wall portion of the band (doors and the telephone are in the wall at figure height by definition) as a **warning**, and may never intersect `walkable`. The "cord across a threshold" example in §6.4 is withdrawn: a cord is drawn on the jamb, not across the floor. Darkness and keylines stay behind people, never under them.
- *(c) Filed hotspots on focus.* Lift only, no keyline. The keyline means "a fact is here"; restoring it on focus would un-read a read object. The focus read for `filed` is the gap opening between the paper and its carbon ghost, which stays put: a 2–3 px offset becoming 12 px is a stronger grain-proof signal than a 3 px line. The focus pose for a filed hotspot is `layer_filed` translated, not the keylined focus crop. This read is a hypothesis in the same class as C1: in the Formulas §11 session each player is shown a 720 grain still with one filed hotspot focused and asked which object is focused; pass is at least 4 of 5 correct (n ≥ 5), recorded in the discoverability evidence file.
- *Door under reveal:* confirmed as a lift; the door's reveal pose is its focus pose (one more notch), so reveal and focus stay one vocabulary (C2). Filed hotspots under reveal are unchanged (the ghost gap opens on focus only).
- *Art-bible amendments requested, not made* (the user approves any edit to `design/art/art-bible.md`; Open Questions): §6.4 "cursor bracket" → "typed slip (§7.1)"; §6.4 withdraw "a cord across a threshold"; §6.4 add the filed-focus rule.

**8. Audio** (named for the audio director, not specified). Corner lift and drop: silent; focus fires on every hover and must never sound. Reveal press: one candidate rustle, the director's call. Activation by `kind`: paper lifted, drawer notch, door latch, receiver off cradle, nothing for `person` (Dialogue's). Wipe: the sheet slide. Examine slip: silent or a single type-tick. Void: silent. Visual mood to match: dry, close, paper on wood; nothing rings.

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:scene-interaction-framework` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## Game Feel

Feel is a design target here even though the category is Core, because the cursor and the lift are the player's whole contact with the room.

- **Focus answers within one frame.** Pointer enter, ring step or spatial step sets focus in the same frame; the lift starts the next frame and completes in `LIFT_MS` (120 ms, ease-out, no overshoot, no breathing). Input-to-focus latency is at most one frame on every device, with a worst case of 33 ms. This and every other timing budget are measured in `tests/performance/scene/`, reported per run and blocking only on the reference machine the technical director names; unit tests assert no wall time.
- **Nothing moves unprompted.** While the player is idle the room is still: no idle animation on hotspots, no hint pulse, no camera drift. The only continuous motion in the game is the interrogation timer's margin fill, which is Dialogue's, never the room's.
- **The lift is the only hover feel.** No cursor change, no glow, no sound on hover. A corner rises one unit and a keyline thickens by one pixel at 1080; the rest is the player's attention.
- **A press is a press.** Activation fires on release of a single discrete press; no hold, no double, no charge. A misclick on bare plate does nothing under standing layers and only walks under walking avatars, and a walk can always be cancelled.
- **The wipe is the only transition.** `WIPE_MS` of paper sliding in the exit's direction, input blocked, cursor hidden; never a fade, never a loading bar. A preloaded swap must feel like a page turn (≤ `SWAP_BUDGET_MS` behind the wipe).
- **Under walking avatars,** crossing a plate takes ≤ `PLATE_CROSS_S`; the avatar never blocks a hotspot the player is looking at (the dynamic figure-band warning), and arrival is where activation happens, not a second click.

## UI Requirements

This system owns no sheet and no HUD. It supplies three things the screen-space UI needs and consumes one.

- **To Paper UI (PROV):** the focus position and anchor for the typed slip; `hotspot_examined` to open it; `hotspot_counts` for the read count ("4 of 6 documents") on the dossier sheet at exit and whenever the dossier opens mid-scene; the forwarded `dossier` and `cancel` actions; the VOID state for the struck bracket.
- **To the HUD (PROV, Paper UI):** the cursor (three silhouettes, Rule 12) and the busy state during a wipe. The dossier tab and date stamp are Paper UI's; this system guarantees they are reachable by `focus_next` from the ring (keyboard reach for every interactive element).
- **From Settings Store (PROV):** `ui_scale` (100–150%; the hit rect is in plate space and does not scale with UI scale, Edge Cases), `cursor_scale`, `flicker: off`, `reveal_mode: hold | toggle | always`, `tooltip_mode: focus | examine | off`, and the seven action bindings.
- **Accessibility inputs this system carries** (implemented here; recorded project-wide in `design/accessibility-requirements.md`, which the accessibility specialist must write before this GDD's acceptance criteria are checked): AccessKit roles on the plate region, every hotspot, thresholds and the hero; the focus announcement and the scene announcement with the read count; the reveal live region; full keyboard reach; target size ≥ `HIT_MIN` with ≥ `HIT_GAP` between targets; no timed input.

> **📌 UX Flag — Scene & Interaction Framework**: this system contributes the slip, the cursor and the read count to Paper UI's screens and the HUD. In Pre-Production, run `/ux-design` for the plate interaction pattern (focus, reveal, slip) and the HUD **before** writing epics; stories that reference them cite `design/ux/[screen].md`, not this GDD. Run `/ux-design accessibility` first so `design/accessibility-requirements.md` exists.

## Cross-References

| This GDD references | In | Owner | Nature |
|---|---|---|---|
| Scene id form `a1_vera/s3`; `begin_boundary(scene_id)`; the headless rule and CI path check | GDD 1 Core Rules 4a, 11 | Dossier State Model | Followed (Rules 1, 14) |
| `scene.location` and `action.hotspot` as opaque refs; the lint's dangling-reference check; `acc.*` namespace; `StringLookup.text()` | GDD 2 Core Rules 4, 5, 10; V05 | Narrative Content Format | `scene_vocab.json` supplies the vocabulary; `name_key` is the one string call (Rule 9) |
| `exits[{to, when}]` as Scene Flow's conditional routes | GDD 2 Core Rule 5 (`scene` row) | Narrative Content Format / Scene Flow | Doors emit `hotspot_activated`; no exit signal (Rule 8) |
| Iso axis, thresholds drawn thick | Art bible §3.3 | Art | `threshold: true` on door/phone/window kinds |
| One hero per plate; 3–8 hotspots; prop density | Art bible §3.4, §6.3 | Art | E02, E03 |
| Hotspot = one-unit disturbance; 2 px keyline, 3 px on focus; clear margin; carbon ghost after filing; no glow | Art bible §6.4 | Art | Rules 2, 5, 6; E05 |
| Figure band free of keylines | Art bible §6.6 | Art | E06 (error for non-threshold hotspots, warning for thresholds in the wall band; Visual/Audio 7b) |
| Diegetic HUD (dossier tab, date stamp, cursor); typed slip tooltip | Art bible §7.1 | Art | UI Requirements; Rule 6 |
| Cursor never signals a hotspot; three silhouettes | Art bible §7.3 | Art | Rule 12; the §6.4 "cursor bracket" lives on the slip |
| 120 ms lift; no breathing | Art bible §7.4 | Art | `LIFT_MS`; Game Feel |
| C1 hold-key reveal and read count; C2 one focus state; C3 VOID bracket and disabled flag; AccessKit roles on every Control | Art bible §7.6 | Art / UX | Rules 4, 5, 6, 9 |
| Plates 1920×1080, painted 2×, 720 as ⅔ stretch, scrolling width only; layers cropped with integer offsets in a sidecar; figures 162–216 px on a baseline | Art bible §8.3, §8.5 | Art | Rule 1; E07, E08 |
| T1 ≤ 256 MB per scene, two resident; T3 ≤ 150 draws; T4 overlay stack; T6 integer positions; T8 sprite sheets; T9 60 fps | Art bible §8.7 | Technical art | Rules 7, 10; W13, W14 |
| MVP spike list | Art bible §8.9 | Technical art | Rule 15 extends it |
| Stretch defaults `canvas_items`/`expand` for new projects; `CanvasItem` lines without feather; `PackedScene.instantiate()`; `@abstract`; typed-return overrides; `Tween.tween_await()`; dual focus; device ids; recursive Control disable; AccessKit on Controls; dedicated 2D navigation server; `--headless --import` before gdUnit4 | docs/engine-reference/godot/ (breaking-changes.md 17, 31, 39, 55, 69, 75; input.md 8–10, 16–18, 23, 79, 80; rendering.md 11; navigation.md 8, 11–16, 44–58; animation.md 8; deprecated-apis.md 30; current-best-practices.md 138–141, 214–215; VERSION.md 6) | Engine reference | Rules 3, 4, 7, 8, 9, 10, 13, 14, 15 |
| Renderer and stretch ADRs required before visual work; character presentation decided by the pipeline proof | design/gdd/game-concept.md Technical Risks, MVP Definition | Concept | Rules 10, 11; Open Questions |
| Pillars 1 and 5; anti-pillar "not a sandbox" | design/gdd/game-concept.md | Creative direction | Player Fantasy; Rule 10 ("walking is never a puzzle") |
| Systems index row 3 and dependency map; the MVP definition (one archivist scene) | design/gdd/systems-index.md | /map-systems | Scope |

## Acceptance Criteria

*Drafted with the QA lead; the seven testability gaps it found are fixed in the rules they name (Core Rules 2, 4, 6, 9; Formulas §11; Visual/Audio 7c; Game Feel and Performance). Timing budgets live in `tests/performance/scene/`, reported per run and blocking only on the reference machine the technical director names.*

*Everything is gdUnit4: compiler, validator, formula, host and focus criteria under `tests/unit/scene/` (`scene_validator_<rule>_test.gd`, fixtures under `tests/unit/scene/fixtures/`); engine-host and cross-system runs under `tests/integration/scene/`; retained screenshots and sign-offs under `production/qa/evidence/scene/`, one `Run result:` line each per `.claude/docs/run-and-observe.md`. The suite runs with `commands.test` after `godot --headless --path . --import`; the simulator and every unit test bind `NullSceneHost`. Constants are read from `assets/data/scene_framework.json`, never inlined, except where the boundary value is the point. Fixtures are the MVP office sidecar (`office`, 6 paper + 2 person hotspots, static 1920 plate) and a scrolling 2880 plate (`corridor`). Every validator THEN also asserts the message names `scene_id`, the offending id and a one-line fix, and that every error in the fixture is reported, not only the first.*

Citations: **CR§n** = Core Rules, **ST** = States and Transitions, **F§n** = Formulas, **EC n** = Edge Cases, **G** = Tuning Knobs, **VA** = Visual/Audio, **GF** = Game Feel, **UI** = UI Requirements.

**Sidecar compiler and validator** (Logic, BLOCKING)

- [ ] **Normalised output (CR§1)**: **GIVEN** the export script's raw `office/scene.json` with unsorted hotspots and a float offset, **WHEN** the compiler runs twice, **THEN** both outputs are byte-equal, `schema_version` is the first key, hotspots are sorted by id, every coordinate is an int, and a hand-edit to the committed file fails the CI recompile diff.
- [ ] **E01**: **GIVEN** a sidecar with no `schema_version` and one with `schema_version` one below current, **THEN** two E; a release load of either leaves the scene `failed` (EC 8).
- [ ] **E02 (EC 1)**: **GIVEN** `office` with a ninth hotspot and a plate with two, **THEN** two E; **WHEN** the nine-hotspot sidecar loads in release mode, **THEN** `hotspot_ids()` returns the first eight of `focus_order`, the ninth is `hidden`, `set_hotspot_state` on it returns an error, and one error is logged.
- [ ] **E03**: **GIVEN** no `hero` and two `hero` entries, **THEN** two E.
- [ ] **E04 (EC 4, EC 19)**: **GIVEN** id `Drawer-Desk`, two hotspots `ledger`, two scenes sharing `location: archive`, `scene_id` `vera_s3`, `focus_order` missing `ledger`, and a hero sharing a hotspot id whose `rect` excludes its `lift_anchor`, **THEN** six E; **WHEN** the missing-id sidecar loads in release, **THEN** `ledger` is appended in F§3 order and a non-hotspot id dropped, both logged.
- [ ] **E05**: **GIVEN** two hit rects whose half-width expansions intersect, **THEN** one E naming both ids; **GIVEN** the committed `office`, **THEN** none (see flag 4 for the figure-layer clause).
- [ ] **E06 (VA 7b)**: **GIVEN** a `paper` hotspot whose hit rect intersects `figure_band`, a `door` intersecting the wall portion of the band, and a `door` with a "cord" hit rect crossing `walkable`, **THEN** E, W, E in that order.
- [ ] **E07**: **GIVEN** `hit.x` of `12.5`, a rect extending to x 1925 on a 1920 plate, `plate.height` 1079, width 2880 with no `camera`, and `camera.max_x` 2000 on a 2880 plate, **THEN** five E.
- [ ] **E08**: **GIVEN** a missing `focus_layer` PNG, `layer.x` of `3.0`, a 520×100 crop, a `layer_filed` whose bounds differ from `layer` by 2 px, and a 2× PNG (600×400 pixels for a 300×200 crop), **THEN** five E; the 2× case's message names the expected and actual pixel size.
- [ ] **E09**: **GIVEN** `exits[0].hotspot` naming a missing id and one naming a `paper` hotspot with `threshold: false`, **THEN** two E.
- [ ] **E10**: **GIVEN** a `walkable` of two vertices, a self-intersecting bow-tie, a zero-area line, one not contained by `figure_band`, and an `approach` outside it, **THEN** five E; under `presentation.mode: standing` a sidecar with no `walkable` is clean.
- [ ] **E11**: **GIVEN** `kind: lamp` and `threshold: true` on a `paper`, **THEN** one E and one W.
- [ ] **E12 (F§2, EC 2, EC 3)**: **GIVEN** a 30 px key, two 96×40 papers 20 px apart, and a 96×40 paper with its bbox 10 px from the plate's bottom edge, **THEN** the key is E (`m_x` 18 > 15); the pair's paddings shrink equally to a gap of exactly `HIT_GAP`, E only if a side then falls under `HIT_MIN`; the edge paper is clipped and grows upward by the shortfall to ≥ `HIT_MIN`.
- [ ] **W13 (F§7)**: **GIVEN** `office`, **THEN** no finding at 197.8 MB; **GIVEN** its plate replaced by a 3840×2160 PNG (+33 MB), **THEN** one W at ≥ `SCENE_BUDGET_WARN`; **GIVEN** `OTHERS_RESERVE_MB` forced to 240, **THEN** one E over `SCENE_BUDGET_MAX`.
- [ ] **W14 (F§8)**: **GIVEN** the comparison function with `draws_est` 119 and injected measured counts 136 and 137, **THEN** no warning, then one W.
- [ ] **W15 (EC 16)**: **GIVEN** a figure box standing at `approach` whose top quarter intersects its own hotspot's hit rect, **THEN** one W; moved 60 px down, none.

**Formulas** (Logic, BLOCKING; `scene_formulas_<n>_test.gd`)

- [ ] **F§1 hit test**: **GIVEN** `drawer_desk` padded rect {1210, 599, 96, 66}, **WHEN** `hit_id((1218, 630))`, **THEN** `drawer_desk`; (1306, 630) and (1218, 665) return `none` (half-open); (500, 950) is inside polygon (400,900)(640,980)(640,996)(400,916); overlapping regions return the smaller area, ties by id; `hidden` never returns.
- [ ] **F§2 padding**: **GIVEN** bboxes 96×40 at (1210, 612), 40×28 and 30×30, **THEN** {1210, 599, 96, 66}, 66×66, and E12 respectively; a polygon `hit` is returned unpadded.
- [ ] **F§3 ring**: **GIVEN** anchors a(300,700) b(1210,612) c(900,640) d(1500,705) e(640,300) f(1300,290) and no `focus_order`, **THEN** the ring is `e, f, c, b, a, d`, `next(d) = e`, `prev(e) = d`; with `c` hidden it is `e, f, b, a, d`; a one-member ring returns itself; an empty ring returns `none`.
- [ ] **F§4 spatial**: **GIVEN** the same anchors, focus `c`, **WHEN** right, **THEN** `b` at cost 353.3 (±0.1), `d` 701, `f` 1056.5, `a` and `e` excluded; **WHEN** left from `e`, **THEN** no move; equal costs resolve by id.
- [ ] **F§5 latch**: **GIVEN** `p_latch` set by a KEY set at 720 window (100, 100), **THEN** a 3 px move (4.5 plate px) holds, 5 px (7.5) re-asserts; two opposed 3 px moves hold, two same-direction 3 px moves re-assert (EC 9).
- [ ] **F§6 camera**: **GIVEN** `corridor` (2880 wide, `camera.max_x` 960), `cam_x` 0, view 1920, **WHEN** Tab lands on anchor 2300, **THEN** `target_x` 960; anchor 1400 with rect 1400–1496 does not pan, nor does any POINTER set; a 1440 view on a static 1920 plate yields `max_x_eff` 480; a 2520 view centres at −300.
- [ ] **F§7 bytes**: **GIVEN** `office`, **THEN** `bytes_fw` 16.8 MB and `bytes_est` 197.8 MB (±0.1); **GIVEN** `report_resident_bytes("portraits", 128)` at runtime, **THEN** `bytes_scene` is 144.8.
- [ ] **F§8 draws**: **GIVEN** `office` with `n_vis` 6 all unfiled, **THEN** 119; with two filed and one of them focused, 115.
- [ ] **F§9 walk (walking outcome only)**: **GIVEN** `WALK_SPEED_PX_S` 360, diameter 1600, median hop 500 and `STRIDE_PX` 230, **THEN** 4.44 s ≤ `PLATE_CROSS_S`, 1.39 s ≤ `HOP_S`, `slide` 1.04 in 0.8–1.25; stride 180 fails at 1.33.
- [ ] **F§10 counts**: **GIVEN** `office` with four papers filed, one void, one person hidden, **THEN** `hotspot_counts` returns `paper {6, 4, 1}` and `person {1, 0, 0}`; `hidden` is absent from `total`.
- [ ] **F§11 pass rule**: **GIVEN** found `6, 5, 5, 6, 4, 5, 3, 6`, misses 52, `n_h` 6, **THEN** pass; **GIVEN** the same with misses 81, or found `6, 5, 5, 6, 3, 5, 3, 6`, or n = 4, **THEN** fail, and the n = 4 failure is reported as "smoke, not a verdict".

**SceneHost contract** (Integration, BLOCKING; `scene_host_contract_test.gd` parameterised over `NullSceneHost` and `EngineSceneHost`, the latter under `tests/integration/scene/`)

- [ ] **Lifecycle (ST)**: **GIVEN** a fresh host, **WHEN** `preload_scene("office")`, `activate_scene("office", false)`, `unload_scene("office")`, **THEN** `preload_scene` returns `{ok: true, errors: []}` and `scene_preloaded`, `scene_ready`, `scene_exited` arrive in that order, each once with the id.
- [ ] **Residency (EC 7)**: **GIVEN** `office` active and `corridor` ready, **WHEN** `preload_scene("cell")`, **THEN** `{ok: false, errors: ["residency"]}` synchronously and both resident scenes are unchanged.
- [ ] **State before activation (CR§5)**: **GIVEN** `office` ready but not active, **WHEN** `set_hotspot_state("ledger", filed)`, **THEN** `hotspot_states()["ledger"]` is `filed` after activation; a `hidden` hotspot is absent from `hotspot_ids()`; an unknown id returns an error.
- [ ] **Focus placement (CR§8)**: **WHEN** `set_focus("ledger")`, **THEN** `focus()` returns `ledger`; `set_focus` on a `hidden` id returns an error and `focus()` is unchanged.
- [ ] **Block multiset (CR§13, EC 20)**: **WHEN** `push_input_block("sheet:doc_7")` twice and `pop_input_block("sheet:doc_7")` once, **THEN** input is still blocked; a second pop unblocks; `pop_input_block("never")` is ignored with a logged error and the count unchanged.
- [ ] **Activation signals (CR§5, EC 12, EC 13)**: **GIVEN** `ledger` unfiled, `memo` filed, `phone` void, **WHEN** each is activated, **THEN** `hotspot_activated` fires for `ledger` and `memo`, `phone` fires `hotspot_examined` only, and no signal named `exit_requested` exists on the host.
- [ ] **Exit via threshold (CR§8)**: **WHEN** the `door` is activated, **THEN** only `hotspot_activated("door")` fires; **WHEN** Scene Flow then calls `activate_scene("corridor", true)`, **THEN** `scene_exited("office")` fires after `WIPE_MS` and `office` unloads.
- [ ] **Failed target (EC 8)**: **GIVEN** `cell` failed structural validation, **WHEN** `activate_scene("cell", true)`, **THEN** `{ok: false, errors}`, no wipe starts, `office` stays active with the block count at 0.

**FocusController** (Logic, BLOCKING; `focus_controller_test.gd`, driven through `NullSceneHost`)

- [ ] **Hover then Enter (CR§4)**: **WHEN** the pointer enters `ledger`'s hit rect and `activate` is pressed, **THEN** `focused_id` is `ledger`, source POINTER, `grab_focus()` was called once on its carrier, and `hotspot_activated("ledger")` fires on release.
- [ ] **Rest then Tab**: **GIVEN** no focus, **WHEN** `focus_next`, **THEN** focus is the first ring member, source KEY; pointer leaving does not clear it.
- [ ] **Latch (CR§4, F§5)**: **GIVEN** the pointer resting on `a` and Tab moving focus to `b`, **WHEN** the pointer jitters 3 px at 720, **THEN** `b` holds; at 5 px `a` takes POINTER focus and `b` drops.
- [ ] **Single lift invariant**: **GIVEN** every input sequence in the suite, **THEN** `lifted_count()` ≤ 1 after each event, and 0 while the block count > 0.
- [ ] **Hidden forces next (ST, EC 6)**: **GIVEN** KEY focus on `c`, **WHEN** `c` is set `hidden`, **THEN** focus moves to the next non-hidden id after `c`'s former position; with POINTER focus, `none`.
- [ ] **Sheet stack restore (CR§13)**: **GIVEN** KEY focus on `ledger`, **WHEN** a block is pushed then popped, **THEN** `ledger` is re-focused and re-lifted; if it became `filed`, restored anyway; if `void` or `hidden`, next in ring (KEY) or `none` (POINTER); nested pushes restore LIFO.
- [ ] **Spatial no-move (F§4)**: **GIVEN** focus on the rightmost anchor, **WHEN** `focus_dir` right, **THEN** focus and lift are unchanged and no signal fires.
- [ ] **KEY landing (CR§4)**: **WHEN** `scene_ready` with last source KEY, **THEN** focus is the first ring member; with POINTER, `none`.
- [ ] **Reveal and examine (CR§6, EC 10, EC 11)**: **WHEN** `reveal` is held, **THEN** `lifted_ids()` is every unfiled plus the door, focus unchanged; on release, empty; held across a sheet, lifts drop and return on pop only if still held. **WHEN** `examine` on KEY focus, **THEN** `hotspot_examined` fires immediately; under `tooltip_mode: focus` it fires after an injected clock advances `TOOLTIP_DWELL_MS`.
- [ ] **Locale change (EC 18)**: **WHEN** the locale changes with a slip open, **THEN** `hotspot_examined` re-fires for the focused id only; focus, availability and `cam_x` are unchanged.

**Headless and CI** (Logic, BLOCKING)

- [ ] **Path check (CR§8, CR§14)**: **GIVEN** a temporary `src/scene_flow/x.gd` that preloads `src/scene/engine/scene_root.gd`, **WHEN** the CI path check runs, **THEN** exit non-zero naming the file; the committed tree exits 0.
- [ ] **Null binding**: **GIVEN** `tools/sim/` and `tests/unit/`, **THEN** a grep finds no `EngineSceneHost` or `src/scene/engine/` reference.
- [ ] **Import first**: **GIVEN** the CI workflow, **THEN** `godot --headless --path . --import` precedes `commands.test`; a run without it reports 0 tests.

**Run-and-observe** (Visual/Feel and UI, BLOCKING; retained PNG per criterion at `production/qa/evidence/scene/<name>-<res>.png`, art-director sign-off in `production/qa/evidence/scene/signoff.md`)

- [ ] **State vocabulary (VA 2)**: **GIVEN** `office` with a hotspot in each of unfiled, focused, filed, void, and all under reveal, **THEN** five stills at 1920×1080 and five at 1280×720 are retained, each signed by the art director against the VA 2 table.
- [ ] **Keyline at 720 (VA 1, CR§14)**: **THEN** a 400% crop of the focused still at 720 shows the 3 px keyline distinguishable from a neighbour's 2 px, signed.
- [ ] **Filed ghost gap (VA 7c)**: **THEN** a 720 still of a focused filed hotspot shows the ghost unmoved and the paper 8 px above it, signed (hypothesis test).
- [ ] **Lift timing (VA 3, GF)**: **GIVEN** a 60 fps capture of one hover, **THEN** the lift starts on the frame after the pointer enters and ends 7±1 frames later, with no overshoot; a `door` translates 0 px.
- [ ] **Wipe (VA 4)**: **GIVEN** a 60 fps capture of a door exit, **THEN** the sheet covers the old plate in 11±1 frames, the new plate is uncovered 11±1 frames later, no frame shows partial alpha, the cursor is absent throughout, and a click during the wipe is ignored.
- [ ] **Cursors (CR§12, VA 5)**: **THEN** stills of the hand over a hotspot, a threshold and a `void`, the caret over sheet text and the stamp-hand during filing show three silhouettes only, no colour change, hand 48 px at 1080 and 32 px at 720 (OS-level capture if the hardware cursor is absent from the engine capture).
- [ ] **Stillness (GF)**: **GIVEN** `flicker: off` and an idle room, **THEN** two stills 10 s apart are pixel-identical.
- [ ] **Aspect (EC 17)**: **THEN** a 4:3 still shows the plate panned with no soot strip; a 21:9 still shows it centred with soot either side and one debug warning logged.
- [ ] **Pseudo-locale slip (CR§9, UI)**: **THEN** a still of the examine slip under GDD 2's pseudo-locale shows the bracketed, padded name with no clipping.

**Accessibility** (Integration, BLOCKING; checked only after `design/accessibility-requirements.md` exists, which it does not today)

- [ ] **Roles (CR§9)**: **GIVEN** `office` active, **WHEN** the accessibility tree is dumped, **THEN** the plate is `region`, each paper/object `button`, each door/phone `link`, the hero `image`, the void hotspot flagged disabled.
- [ ] **Announcements**: **THEN** `scene_ready` yields "Archive office. 6 documents, 2 read." and focusing the second paper yields "Personnel file, unread, 2 of 6"; a reveal press updates the live region with the count only.
- [ ] **Reach (CR§4, CR§9)**: **GIVEN** `corridor` with one off-screen and one `void` hotspot, **WHEN** Tab is pressed |ring| times, **THEN** every ring member including both is visited, the off-screen one pans into view, and every hotspot the suite activates by pointer is also activated by Tab+Enter.

**Discoverability playtest** (Integration, BLOCKING; evidence `production/qa/evidence/scene/discoverability-<date>.md`)

- [ ] **720p pass (F§11, CR§6)**: **GIVEN** n ≥ 5 players on `office` at 1280×720 with reveal disabled for `FIND_WINDOW_S`, **THEN** the per-player `found_i` and `miss_i` are recorded and the F§11 rule returns pass; a second run with reveal enabled reaches median `n_h` of `n_h`.

**Navigation outcome** (Integration, BLOCKING; the live paragraph only)

- [ ] **Standing (CR§10)**: **GIVEN** `presentation.mode: standing`, **WHEN** `activate` on a hotspot, **THEN** `hotspot_activated` fires in the same frame; a click on bare plate emits nothing; a `person` hotspot activates like a document.
- [ ] **Walking arrival**: **GIVEN** `walking`, **THEN** `hotspot_activated` fires only on arrival within `ARRIVAL_TOLERANCE_PX` of `approach`; bare-floor click walks and emits nothing; `cancel` and a second `activate` abort with nothing emitted; keyboard activation walks too.
- [ ] **Walking degradation (EC 14, EC 15)**: **GIVEN** no path, **THEN** activation is immediate and `nav.no_path` is logged; **GIVEN** the target hidden mid-walk, **THEN** the avatar stops, nothing is emitted, focus moves per EC 6.
- [ ] **Walking proof**: **THEN** the measured median hop ≤ `HOP_S`, the diameter crossing ≤ `PLATE_CROSS_S`, and `slide` in 0.8–1.25, recorded beside authoring time.

**Performance** (budgets PENDING the technical director; `tests/performance/scene/`, reported per run, BLOCKING on the named reference machine only)

- [ ] **Load and swap (CR§7, G)**: **GIVEN** a cold `preload_scene("office")`, **THEN** `scene_ready` within `LOAD_BUDGET_MS`; a preloaded swap stalls ≤ `SWAP_BUDGET_MS`; the `scene_ready` byte assert matches `bytes_fw` within 5%.
- [ ] **Input to focus (GF)**: **THEN** a 60 fps capture shows focus set on the frame of the input event and the lift starting the next.
- [ ] **Hot paths**: **THEN** 10,000 `hit_id` calls on an 8-hotspot plate average ≤ 0.1 ms, `next_focus` ≤ 0.05 ms, and the full validator over `office` ≤ 5 ms.

**CD-GDD-ALIGN additions** (Logic unless noted, BLOCKING)

- [ ] **Timers as sheets (CR§13)**: **GIVEN** an interrogation or search timer running (Dialogue's), **THEN** the scene is `suspended` and the block count is greater than zero for the whole run; **GIVEN** a scene `active`, **WHEN** any Scene Flow or Dialogue clock attempts to start, **THEN** a debug assert fires and no clock runs.
- [ ] **Player-caused availability only (CR§5, EC 14)**: **GIVEN** `scene_ready` and no block, **WHEN** `set_hotspot_state` arrives outside a `hotspot_activated`/`hotspot_examined` handler, **THEN** a debug assert fires; **GIVEN** a hotspot leaving `hidden` under a block, **THEN** the live region announces it and the unfiled pose shows on the next frame after the pop.
- [ ] **Press and release (CR§4)**: **GIVEN** focus on A at press, **WHEN** the pointer moves to B or bare plate before release, **THEN** release emits nothing and focus follows the pointer rule; **GIVEN** focus still A at release, **THEN** `hotspot_activated(A)` once.
- [ ] **Filable hotspots (X01)**: **GIVEN** a `paper` hotspot whose content action yields no fact with a dossier use, **WHEN** the `tools/` cross-check runs, **THEN** one E naming the hotspot and action; a `door` with no fact passes.
- [ ] **Read count guards (CR§6, F§10)** (UI, retained screenshot): **THEN** the dossier sheet prints "4 of 6 documents, 1 struck" for `paper {6, 4, 1}` and nothing for `person`, no chapter or game total appears on any sheet, and the screen-reader string carries the same three numbers.
- [ ] **No engine focus style (CR§4)** (Visual, retained screenshot): **GIVEN** keyboard focus on a hotspot at 1080 and 720, **THEN** the still shows the lift and 3 px keyline and no engine focus rectangle or hover style anywhere on the plate.
- [ ] **Walking guarantees (CR§10, conditional)**: **GIVEN** the avatar standing anywhere in `walkable`, **THEN** every `approach` has a path (E10 simple polygon); **GIVEN** a path consumed with the avatar 9 px from `approach`, **THEN** activation fires; **GIVEN** `HOP_S` exceeded in the proof, **THEN** the walking outcome is recorded as not adopted.

**MVP gate.** Before `/gate-check technical-setup` on the one archivist scene under `presentation.mode: standing`: compiler, E01–E12 and W13; F§1–F§8 and F§10; the SceneHost contract on both hosts; FocusController; Headless and CI; the state, keyline, lift, wipe, cursor and stillness stills at 1080 and 720; the Accessibility reach criterion by keyboard alone; the Standing criterion. **Vertical Slice:** the discoverability playtest and its reveal-enabled rerun, the filed-ghost still, AccessKit roles and announcements with a named screen reader, the aspect and pseudo-locale stills, W14/W15, F§9 and the walking group (only if the proof picks `walking`), and Performance once the technical director confirms the budgets.

## Open Questions

| Question | Owner | Needed by | Status |
|---|---|---|---|
| MVP spike list (Core Rule 15): `/setup-engine refresh` on the developer's machine; AccessKit role, name and disabled property names in GDScript; the recursive-disable property name; threaded `ResourceLoader` and the load/swap measurements; cursor API; `CanvasLayer`/`CanvasModulate`/`y_sort_enabled`/`z_index` for the T4 stack; pixel snap; `Camera2D` limits; `NavigationAgent2D` 2D arrival names and signal; `Geometry2D.is_point_in_polygon`; `Control.offset_transform_*` for the lift | technical-director, engine-programmer, technical-artist | Before the renderer, stretch and plate-authoring ADRs | Open; NOT SOURCEABLE from the pinned reference; VERSION.md says the installed editor is NOT DETERMINED |
| Renderer (Compatibility vs Forward+) and stretch/aspect ADRs; letterboxing versus wider plates at 21:9 and 4:3 | technical-director | Before any plate work | Open (concept, Technical Risks) |
| `presentation.mode: walking | standing`, set once from the art-pipeline proof's measured times and the hop/crossing/slide criteria (Formulas §9) | creative-director, with the proof's data | After the MVP pipeline proof | Open; `standing` until then |
| Art-bible amendments requested by the art director (Visual/Audio item 7): §6.4 "cursor bracket" → "typed slip (§7.1)"; withdraw "a cord across a threshold"; add the filed-focus rule (lift only, ghost stays) | user approves; art-director edits `design/art/art-bible.md` | Before `/asset-spec` for plates | Open; not edited by this GDD |
| `design/accessibility-requirements.md` does not exist; the accessibility specialist writes it (proposed tier: screen-reader-complete for all paper UI and plate hotspots) before this GDD's acceptance criteria are checked | accessibility-specialist via `/ux-design accessibility` | Before `/gate-check technical-setup` | Open |
| Does `name_key` resolution through `StringLookup` count as a text read for the headless rule? This GDD says no (one string, presentation only; the null host resolves nothing) | technical-director | ADR for the host seam | Open; assumed no |
| The host seam itself (`SceneHost`, `NullSceneHost`, `EngineSceneHost`, constructor injection, no autoload) deserves a short ADR | technical-director | `/create-architecture` | Open |
| Discoverability at 720p without glow (art bible C1) and the filed "ghost gap" focus read (7c) are hypotheses; the playtest rule in Formulas §11 decides, and failure escalates three options to the art director | ux-designer, art-director, analytics-engineer (events `hotspot_activated`, `plate_miss`, `reveal_pressed`) | MVP playtest | Open |
| Settings Store's scope must include `reveal_mode`, `tooltip_mode`, `cursor_scale`, `ui_scale`, `flicker` and the seven action bindings | `/map-systems` (producer), Settings Store GDD | Before the Settings Store GDD | Open |
| Whether the carbon ghost staying put under a lifted filed hotspot costs an extra draw under T4 (it is already its own draw per T3, so it should not) | technical-artist | Overlay GDD | Open |
| Performance budgets proposed in Acceptance Criteria (`LOAD_BUDGET_MS`, `SWAP_BUDGET_MS`, input-to-focus, hit-test, `next_focus`, validator) | technical-director | ADR | To be confirmed |
