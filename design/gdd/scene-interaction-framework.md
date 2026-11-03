# Scene & Interaction Framework

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: In Design
> **Author**: Mustafa Faisal (user) + game-designer, ux-designer, godot-specialist, gameplay-programmer, systems-designer (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 1 Every fact is a weapon · 5 Pressure comes from attention, not reflexes

## Summary

[To be designed]

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `[To be designed]`

## Overview

The Scene & Interaction Framework is the part of Paper Walls that puts a painted room on screen and lets the player touch it. It loads a scene's isometric plate and its layers, registers the room's hotspots (a lifted paper corner, a drawer out one notch, a receiver off its cradle) under the ids the content format names, routes mouse and keyboard input into a small set of actions (focus, activate, reveal, cancel, open dossier), owns the cursor and the single focus state that hover, keyboard and a later gamepad all share, and tells Scene Flow which hotspot the player activated. It exists because every other visible system, Investigation & Fact, Dialogue, Character Presentation, Overlay Rendering and Paper UI, needs one answer to "what is on screen, where is it, and what did the player just do", and because the art bible's legibility rules (one hero, three to eight keylined hotspots, a clean figure band, no glow) are only enforceable if hotspots are registered objects rather than painted-in guesses. Whether a protagonist walks across the plate or the camera cuts between standing layers is not decided here: navigation and walkable regions are a conditional section whose activation the MVP art-pipeline proof decides. The index describes the system as "isometric plate, layers, hotspot registration, scene loading, input actions, cursor and focus; navigation and walkable regions as a conditional section decided by the MVP pipeline proof", and this GDD keeps that scope. It does not decide what a hotspot yields (Investigation & Fact), when a scene ends (Scene Flow), how a figure looks (Character Presentation), or how stamps and red are drawn (Overlay & Surveillance Rendering). Implementation questions raised here (CanvasLayer ordering, the pixel-snap setting, the stretch aspect) are recorded for the renderer and plate-authoring ADRs, not decided in this document.

## Player Fantasy

*Framing: indirect. The player sees a room, a cursor and the few objects that sit one unit off the grid; they never see the framework. Shaped with the creative director (three candidate framings; "the room is a page" chosen, with one line from "someone was here before you" and the rule from "the room waits").*

**The room is a page.** The emotion this system serves is a reader's attention. Entering a room is like turning to a new page: the player takes it in whole and at rest before touching anything, and the plate tells them which lines to read. Six or so objects are each disturbed by one unit, keylined and waiting. Moving the cursor across the room is like running a finger down a column. A corner lifts under it, the keyline thickens, and a typed slip offers one word. Nothing else answers. The cursor touches; it never knocks anything over and never moves anything the player did not choose to open.

The anchor is the drawer of the desk Vera inherited, pulled out one notch. It is the only drawer in the room that is not flush. The player sees it before they decide to look for it, and moving to it feels like reading the next word, not searching. As in Disco Elysium, the room is something you read. As in Pentiment, a hand chose every mark. A room the player has read looks read: carbon ghosts where the keylines were.

*Cost accepted:* the fantasy depends entirely on art discipline (art bible §6.3–6.6). A stray disturbance or a ninth hotspot lies to the reader, so the plate rules are load-time asserts in this system, not review notes.

**Pillar alignment.** Pillar 1, "every fact is a weapon": every marked object is there to be read and filed, and a detail that implies an unfilable fact is cut (art bible §6.5). Pillar 5, "pressure comes from attention, not reflexes": the room is the one place where the state is not watching the clock.

**The one rule this framework must obey: the room waits, and the room is fair.** The framework owns no clock and no precision test. Every hotspot is found because it is drawn. Every hotspot can be reached by focus (keyboard, later gamepad) as fully as by the pointer. Every activation is one discrete press, and the result does not depend on when the press lands, how fast, or where inside the hotspot's footprint. Required: hotspot margins of at least half the object's width; focus cycling as a full equal to the mouse; the reveal key as a guarantee that nothing is found by luck; cancel always available; if walking avatars win the pipeline proof, a click-to-walk target snaps to the hotspot's arrival point and the world never interrupts the walk. Forbidden inside this system: any timer or timed input; hold-to-complete, drag, double-click; hotspots that move, appear late, or show only on hover; sub-object pixel targets; any outcome triggered by a misclick that cannot be cancelled; any change in room state while the player is idle. Timed choices under interrogation or search, Pillar 5's one exception, belong to Dialogue & Interrogation and Scene Flow and are never a property of the room. *Design test:* could a player with a tremor, or one who has stepped away for coffee, lose anything in this room? If yes, it is a defect.

## Detailed Design

### Core Rules

*Drafted with the game designer (primary), the UX designer, the Godot specialist and the gameplay programmer. Where they disagreed, the ruling is stated in the rule with the alternative it displaced. Engine facts are quoted only from `docs/engine-reference/godot/`; anything else is marked **NOT SOURCEABLE** and listed as a spike. Items marked **(PROV)** rest on a system whose GDD is not yet written.*

**0. Vocabulary.** A *scene* is one painted plate and its sidecar. A *hotspot* is an object on the plate disturbed from the grid by one unit (art bible §6.4), registered under an id the content format references. The *hero* is the plate's one full-value object (§3.4); it is not a hotspot unless its id is also a hotspot id. A *threshold* is a door, window or telephone, drawn thick because reactive events enter through them (§3.3). *Focus* is the one hotspot the next `activate` will hit. *Availability* is a hotspot's content state (`unfiled`, `filed`, `void`, `hidden`), set by Scene Flow. The *host* is the thin interface through which headless systems drive this one.

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
| E05 | Clear margin (§6.4): each hit region expanded by half its width intersects no other hit region and no figure layer (standing outcome); the *midtone* half of the margin rule is the asset-pipeline gate's | E |
| E06 | A non-threshold hotspot's hit region ∩ `figure_band` ≠ ∅ (§6.6): error. A `threshold: true` hotspot may intersect the wall portion of the band (warning) and may never intersect `walkable` (error). Art-director ruling, Visual/Audio item 7b. The dynamic case, a moving figure's head over a focused hotspot, is a debug runtime warning | E / W |
| E07 | Every coordinate integer and inside the plate; `plate.height == 1080`; width may exceed 1920 only with `camera`; `camera` bounds inside the plate | E |
| E08 | Layer files exist; offsets integer; crops ≤ 512²; `focus_layer` and `layer_filed` bounds equal `layer` bounds (otherwise the lift shifts); a PNG whose pixel size exceeds ship size (a 2× paint imported at 2×) | E |
| E09 | `exits[].hotspot` resolve and are `threshold: true` | E |
| E10 | Walking outcome: `walkable` is a simple polygon (≥ 3 vertices, no self-intersection, non-zero area) inside the plate; `figure_band ⊇ walkable`; every `approach` and `baseline_y` inside it | E |
| E11 | `kind` in the closed set; `threshold: true` on a kind other than `door`/`phone` | E / W |
| E12 | Target size (UX): the hit rect, padded into its clear margin, is at least `HIT_MIN` × `HIT_MIN` px in 1080 space; hit rects never overlap and keep ≥ `HIT_GAP` px between edges | E |
| W13 | Resident-byte sheet over `SCENE_BUDGET_WARN`; error over `SCENE_BUDGET_MAX` (Rule 7) | W / E |
| W14 | Estimated draws over the T3 target (plate 1, hotspot layers ≤ 8 + 8 focus, figures ≤ 6) | W |

The cross-check "every hotspot has at least one content action, and every content `hotspot` ref exists" lives in `tools/` only, where importing both the content store and this validator is allowed. *Rationale:* every rule here is one the art bible already calls *checkable*; making the build the checker means a plate that breaks a rule cannot ship by accident, and the load-time re-run catches a sidecar edited after the build. *Rejected:* validating only at load (too late for the artist; the pipeline proof needs the gate in the export loop).

**3. The input action set is closed.** Seven actions, declared once in `assets/data/input_actions.json` so Settings Store **(PROV)** can remap them; the framework never hardcodes a binding.

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

**4. One focus, and the controller is the only truth.** `FocusController` holds at most one `focused_id` and its `source` (`POINTER` or `KEY`). The engine keeps mouse focus and keyboard focus separate since 4.6 (SOURCED: input.md lines 16–18, 79; breaking-changes.md line 55), so neither engine state is presentation: the controller *drives* the engine, calling `grab_focus()` on the focused hotspot's Control from every source, and the corner lift (120 ms, §7.4) with the 2 → 3 px keyline is drawn by the controller for exactly one id. Each hotspot owns an invisible Control sized to its hit rect purely as the keyboard-focus and screen-reader carrier; hit-testing is a polygon test in script over the sidecar's `hit` regions (deterministic, headless-testable). **Setting rules:** pointer entering a hit region → `set_focus(id, POINTER)`; `focus_next`/`focus_prev`/`focus_dir` → `set_focus(id, KEY)`; the gamepad cursor follows the POINTER path. Last input wins, with a **pointer latch**: after a KEY set, a resting pointer's hover is ignored until the pointer moves at least `POINTER_LATCH_PX` (4 px in 720 space); then hover re-asserts. Pointer leaving a hit region clears focus only when the source is POINTER; KEY focus persists until another set, a sheet, `hidden`, or scene exit. On `scene_ready`, focus is none if the last source was POINTER and first-in-ring if KEY (a screen-reader user needs a landing point). **Order:** `focus_order` is authored by the export and defaults to screen reading order by `lift_anchor`: rows of `FOCUS_ROW_HEIGHT` px (72 at 1080), x ascending within a row, ties by id; the ring wraps. The hero has no privilege: it is in the ring only if its id is a hotspot id, otherwise it is a non-interactive image. Thresholds are in the same ring. `filed` hotspots stay in the ring; `void` stay with the disabled flag so a screen-reader user still learns a document was removed; `hidden` leave. `focus_dir` is spatial and deterministic: candidates are hotspots whose anchor lies in the 90° cone past the current anchor in screen space, cost = Euclidean distance + `OFF_AXIS_PENALTY` × perpendicular offset, lowest wins, ties by id, no wrap, no move if the cone is empty; computed from anchors at load, never from the engine's focus neighbours (which split across the dual focus). `FocusOrdering.next_focus(current, hotspots, direction)` is a pure function over `{id, lift_anchor, hit, availability}` and is unit-tested headless. *Rationale:* a player must always know what the next `activate` will hit, on any device, from one visual fact (art bible C2); AccessKit announces what has keyboard focus, so the controller must drive it or screen readers follow the wrong object. *Rejected:* letting the engine's two focuses each draw (two lifts on screen); hover without `grab_focus()` (Enter activates the wrong thing after hovering with one hand and confirming with the other); nearest-first ring order (changes with where you are; unpredictable for a screen reader); hero last (hides the most important object from the first Tab).

**5. Availability is one axis; focus is another.** `availability ∈ {unfiled, filed, void, hidden}` is set **only** by Scene Flow through `set_hotspot_state`; focus is set only by the controller. Presentation: `unfiled` — layer with permanent 2 px keyline; `filed` — `layer_filed` (keyline removed) and a carbon ghost *requested from Overlay* (§6.4, "a read room looks read"; this system toggles state and emits, Overlay draws); on focus a filed hotspot lifts without a keyline, and the gap opening against its unmoving ghost is the focus read (Visual/Audio item 7c); `void` — the greyed typed bracket struck VOID in the slip and the AccessKit disabled flag (art bible C3); `hidden` — no layer, no hit region, out of the ring. `filed` hotspots remain focusable and activatable (lift only, no keyline); what re-activation yields is Investigation & Fact's **(PROV)**. The framework never derives availability from the dossier: it cannot read it (GDD 1's headless rule) and must not (the same principle as Overlay's "never reads raw dossier fields"). Availability is re-derived by Scene Flow on load; this system persists nothing. *Rejected:* a five-value enum with `focused` in it (two orthogonal axes in one field; a `filed` hotspot could not be focused); `filed` as inert (a screen-reader player loses the only way to re-check a document from the room, and the read count would hide a reachable object).

**6. Reveal, examine and the slip.** *Reveal* (`reveal` held, or toggled under `reveal_mode: toggle | always`): every `unfiled` hotspot lifts its corner at once, 120 ms ease-out, no stagger (no breathing, §7.4); keylines stay 2 px so the focused hotspot's 3 px still reads; `filed` show their ghost unchanged; `void` show the struck bracket without a lift; thresholds lift (a door ajar one more notch; confirmed by the art director); focus does not move; on release everything drops in 120 ms. There is no minimum hold and no hold-duration setting. *Examine* (`examine`, or a `TOOLTIP_DWELL_MS` focus dwell under `tooltip_mode: focus`, immediately on KEY focus): emits `hotspot_examined(id)` and Paper UI draws the typed slip (`[ PERSONNEL FILE ]`, `[ EXIT — CORRIDOR ]`, `[ VOID ]`) lifting 120 ms from under the cursor (POINTER) or below the anchor (KEY); it stays until focus changes or `cancel`, never on a timeout. The slip's bracket is the "cursor bracket" art bible §6.4 names; the cursor itself never changes shape for a hotspot (§7.3; the contradiction between §6.4 and §7.3 is resolved this way and recorded in Open Questions for the art director). *Read count:* `hotspot_counts(scene_id) → {kind: {total, filed, void}}`; Paper UI prints "4 of 6 documents" on the dossier sheet at scene exit and whenever the dossier opens mid-scene (the exit-only count arrives too late to help). *Rationale:* discoverability without glow is a hypothesis to test at 720p (art bible C1; Acceptance Criteria carry the test); the reveal guarantees nothing is found by luck.

**7. Two scenes resident; the reveal step is the loading screen.** At most two scenes are resident: the `active` (or `suspended`) one and at most one `preloading`/`ready` one, each ≤ `SCENE_BUDGET_MAX` (256 MB, art bible §8.7 T1). Scene Flow calls `preload_scene` as soon as the next scene id is known, after the rules step and before the reveal, so the reveal sheet's reading time hides the load. The resident-byte sheet is computed at build time from the sidecar (`Σ layer width × height × 4`, worst-case RGBA8; plate 8.3 MB) until the import-options spike reports whether compression applies; a debug assert at `scene_ready` sums the loaded textures' dimensions and compares within 5%. Threaded versus blocking load is **NOT SOURCEABLE** (only `PackedScene.instantiate()` is sourced, deprecated-apis.md line 30) and goes to the spike; the load budget (≤ `LOAD_BUDGET_MS` to `scene_ready`, ≤ `SWAP_BUDGET_MS` for a preloaded swap) is the technical director's to confirm. Transition: `activate_scene(wipe = true)` plays the paper wipe drawn by this system (direction from `exits[].wipe_from`, duration `WIPE_MS`, never a fade, §7.4; `Tween.tween_await()` is sourced, animation.md line 8), input blocked throughout, cursor hidden (the wipe is the busy signal; no spinner); the previous scene unloads after `scene_exited`. *Rejected:* preloading every exit candidate (breaks the two-scene ceiling the moment a scene has three conditional exits).

**8. The host interface is thin and has a null twin.** Headless systems drive this one through `SceneHost extends RefCounted` (`@abstract` is sourced for 4.5, breaking-changes.md line 69; its GDScript syntax is verified in the spike; an override of a typed-return method needs an explicit `return`, line 17). Two implementations: `EngineSceneHost`, a `RefCounted` adapter that holds the `SceneRoot` Node and forwards, and `NullSceneHost` for the story simulator and tests. Keeping the Node out of the hierarchy is what lets the CI path check enforce the direction: `src/scene_flow/`, `src/investigation/` and `tools/sim/` may import `scene_host.gd` and never `src/scene/engine/*`. Injection is by constructor (`SceneFlow.new(host, dossier, content_store)`); the main scene constructs the engine host, then Scene Flow; there is no autoload.

Calls: `preload_scene(scene_id) → {ok, errors[]}`; `activate_scene(scene_id, wipe: bool)`; `unload_scene(scene_id)`; `set_hotspot_state(hotspot_id, availability)`; `set_focus(hotspot_id)` and `focus() → StringName` (Scene Flow places entry focus deterministically for keyboard users); `push_input_block(reason)` / `pop_input_block(reason)` (a counted block, so nested sheets and a wipe cannot re-enable input under each other); queries `hotspot_counts(scene_id)`, `hotspot_ids(scene_id)`.
Signals: `scene_preloaded(scene_id)` (this system's assets resident; dependents load theirs), `scene_ready(scene_id)` (Rule 7's guarantees hold; input blocked until the block count is zero), `hotspot_activated(hotspot_id)`, `hotspot_examined(hotspot_id)`, `scene_exited(scene_id)` (wipe finished, resources released). **There is no exit signal:** a door is a `threshold` hotspot and emits `hotspot_activated` like everything else; Scene Flow owns what leaving means through GDD 2's `exits[{to, when}]`.
`NullSceneHost` validates ids against `scene_vocab.json`, emits both scene signals synchronously, records `set_hotspot_state` into a dictionary tests can read, and exposes driver methods `activate(hotspot_id)` and `hotspot_states()` so the simulator can script a player. The `SceneHost` contract suite runs against both hosts. *Rationale:* the one system that must run headless must not depend on the one system that cannot. *Rejected:* `exit_requested` as a separate signal (duplicates Scene Flow's conditional routes, which have no hotspot field); `enable_input(bool)` (fragile under nested sheets).

**9. Accessibility is a load-time property, not a pass.** Every hotspot's carrier Control has an AccessKit role (`button`; `link` for `door`/`phone`; the non-interactive hero is an `image`; the plate is a `region`), an accessible name and, when `void`, the disabled flag (AccessKit on Controls is SOURCED, ui.md line 29 and breaking-changes.md line 75; the role, name and disabled property names in GDScript are **NOT SOURCEABLE**, spike). The accessible name is the one string this system touches: `name_key` resolved through GDD 2's `StringLookup` at load and on locale change, used for the name, the examine slip and the focus announcement (`{acc.hotspot.<id>}, {acc.state.<state>}, {n} of {m}` → "Personnel file, unread, 2 of 6") and for nothing else; on `scene_ready` the region announces `{acc.location.<id>}` with the read count ("Archive office. 6 documents, 2 read."); a reveal press updates a live region with the count. Every ring member, including off-screen and `void`, is reachable by `focus_next`; nothing in a room is activatable only by pointer. Settings Store **(PROV)** must expose: `ui_scale` 100–150%, `cursor_scale`, `flicker: off`, `reveal_mode`, `tooltip_mode`, and full remap of the seven actions; the interrogation timer setting is Dialogue's. `design/accessibility-requirements.md` does not exist yet; the accessibility specialist writes it before this GDD's acceptance criteria are checked (the Pre-Production gate reads that exact path), with the tier "screen-reader-complete for all paper UI and plate hotspots" proposed (Open Questions). *Rejected:* Scene Flow pushing names per hotspot per scene (a call per hotspot per scene that ends in the same string); no names in this system (fails keyboard and screen-reader reach).

**10. Navigation (CONDITIONAL, decided by the MVP pipeline proof).** A project-level flag `presentation.mode: walking | standing` in `assets/data/scene_framework.json` is set once from the proof's measured times (the creative director owns the call). The flag selects which paragraph is live; the other stays in this document unimplemented.

*Walking avatars.* `walkable` is the walk surface. A path is the straight segment when it lies inside `walkable`; otherwise the dedicated 2D navigation server (SOURCED: navigation.md lines 11–13; `NavigationRegion2D` lost `avoidance_layers` in 4.3, line 16; no 4.7 changes, line 8) supplies it, with arrival polled by `is_navigation_finished()` (lines 44–58; the 2D arrival-distance property names and the `navigation_finished` signal are **NOT SOURCEABLE**, spike); avoidance is off (one figure). `activate` on a hotspot walks the avatar to its `approach` point and emits `hotspot_activated` on arrival (`ARRIVAL_TOLERANCE_PX`); `activate` on bare walkable floor walks there and emits nothing; `cancel` or a new `activate` aborts the walk; keyboard activation walks too (no device skips the walk). Facing is the dominant axis of the final segment, four directions, three authored (§8.7 T8), ≤ 12 fps. If no path exists the framework activates immediately and logs: walking is never a puzzle. The camera follows the avatar during a walk, then returns to following focus. *Proof criterion:* crossing a plate takes ≤ `PLATE_CROSS_S` at the walk-speed knob; travel time is friction, not Pillar 5 pressure, and the proof measures it beside authoring time.

*Standing layers.* No navigation, no `walkable`, no avatar; `activate` emits `hotspot_activated` immediately; any cut or pose change is Character Presentation's **(PROV)**, triggered by its own listener on the signal. `kind: person` hotspots are hit regions declared in the sidecar, so a conversation is reached exactly like a document.

**11. Camera.** Static per plate. Scrolling plates pan on x only (plates extend width, never height, §8.3), clamped to `camera.min_x..max_x`, and **follow focus, never the pointer**: a KEY-set focus outside a central dead zone (`CAMERA_DEAD_ZONE` of view width) eases the camera to centre it; a POINTER-set focus never pans (the pointer is already there); keyboard cycling onto an off-screen hotspot pans to it (keyboard reach). Edge-scroll is forbidden (a hover-only affordance, C2). For aspect ratios other than 16:9 the 4.7 `expand` default would show beyond the plate (concept, Technical Risks); the stretch ADR decides letterboxing **(PROV)**, and the framework clamps so the view never shows outside the plate regardless.

**12. Cursor.** Three silhouettes only (art bible §7.3), differing by shape, never colour: the thin pointing hand (default, over hotspots, over thresholds, over `void`), the caret over selectable text in sheets, and the stamp-hand during filing. No hotspot, exit or disabled cursor state exists: the hotspot lifts, the door shows its ajar notch and the slip's EXIT prefix, `void` shows in the slip. During a wipe the cursor is hidden and input is blocked. Size `CURSOR_PX` (32 at 720, 48 at 1080), hit point at the fingertip, scaled by `cursor_scale`. The cursor API is **NOT SOURCEABLE** (hardware cursor preferred; a software cursor must be drawn every frame with no lag; spike). *Rejected:* a five-state cursor (moves discoverability onto the pointer, which keyboard and gamepad players do not have).

**13. Modal layers.** When Paper UI opens a sheet it calls `push_input_block("sheet:<id>")`: the controller pushes `{focused_id, source}` onto a stack, drops the lift (one focus on screen, the sheet's), scene input is disabled recursively (the 4.5 single-property recursive disable is SOURCED as a feature, input.md line 23; the property name is **NOT SOURCEABLE**, spike; the block count gates this system's own input handling as belt and braces), and the sheet takes its first bracket. On `pop_input_block`: pop, `grab_focus()` on the saved id, re-lift; the pointer latch holds until the pointer moves. If the saved hotspot became `filed`, restore to it anyway; if `void` or `hidden`, move to the next in ring (KEY) or none (POINTER). Nested sheets and dialogue transcripts use the same stack. `cancel` on a bare plate does nothing in this system. *Rejected:* keeping the lift raised under the sheet (two focuses); resetting to none on close (a keyboard user loses their place).

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
| **Overlay & Surveillance Rendering (PROV)** | the scene root for the T4 stack, per-hotspot layer texture and offset for carbon ghosts, `hero.rect`, `scene_preloaded` | its resident bytes via `report_resident_bytes(owner, scene_id, bytes)` (an observation shown in the debug overlay, never a verdict) | Carbon, stamps and tint are never drawn here |
| **Character Presentation (PROV)** | `figure_band`, `baseline_y` per hotspot, the y-sort root, `walkable` and walk/arrival events (walking outcome), `scene_preloaded` | the avatar node (walking) or pose layers (standing) parented under the scene root | Figures are never keylined by this system |
| **Dialogue & Interrogation (PROV)** | `hotspot_activated` for `kind: person` | `push/pop_input_block` around its transcript sheet (via Paper UI) | Timers are its own; this system has none |
| **Dossier State Model** (GDD 1) | nothing | the scene id form `a1_vera/s3`; the headless rule | Never reads or writes fields |
| **Narrative Content Format** (GDD 2) | `scene_vocab.json` (location, hotspot, exit ids) for the lint | `StringLookup.text(name_key)`, the one string call | Content stays id-only |
| **Settings Store (PROV)** | the action list for remapping; the settings it must expose (Rule 9) | bindings, `reveal_mode`, `tooltip_mode`, `cursor_scale`, `ui_scale`, locale | No defaults hardcoded |
| **Paper UI (PROV)** | `hotspot_examined`, `hotspot_counts`, forwarded `dossier`/`cancel`, the focus position for the slip | `push/pop_input_block` around every sheet; draws the slip, the HUD and the read count | Documents stream on open; ≤ 4 resident is its rule |
| **Save/Load (PROV)** | nothing to persist | nothing | Availability is re-derived by Scene Flow from the dossier on load; camera and focus are not saved |
| **Audio (PROV)** | `hotspot_activated`, `hotspot_examined`, `scene_ready`, wipe start/end | nothing | Paper, stamp and wipe sounds are Audio's |

## Formulas

[To be designed]

## Edge Cases

[To be designed]

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

[To be designed]

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
- *(c) Filed hotspots on focus.* Lift only, no keyline. The keyline means "a fact is here"; restoring it on focus would un-read a read object. The focus read for `filed` is the gap opening between the paper and its carbon ghost, which stays put: a 2–3 px offset becoming 12 px is a stronger grain-proof signal than a 3 px line. The focus pose for a filed hotspot is `layer_filed` translated, not the keylined focus crop. This read is a hypothesis in the same class as C1, tested at 720p under grain alongside discoverability.
- *Door under reveal:* confirmed as a lift; the door's reveal pose is its focus pose (one more notch), so reveal and focus stay one vocabulary (C2). Filed hotspots under reveal are unchanged (the ghost gap opens on focus only).
- *Art-bible amendments requested, not made* (the user approves any edit to `design/art/art-bible.md`; Open Questions): §6.4 "cursor bracket" → "typed slip (§7.1)"; §6.4 withdraw "a cord across a threshold"; §6.4 add the filed-focus rule.

**8. Audio** (named for the audio director, not specified). Corner lift and drop: silent; focus fires on every hover and must never sound. Reveal press: one candidate rustle, the director's call. Activation by `kind`: paper lifted, drawer notch, door latch, receiver off cradle, nothing for `person` (Dialogue's). Wipe: the sheet slide. Examine slip: silent or a single type-tick. Void: silent. Visual mood to match: dry, close, paper on wood; nothing rings.

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:scene-interaction-framework` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## Game Feel

Feel is a design target here even though the category is Core, because the cursor and the lift are the player's whole contact with the room.

- **Focus answers within one frame.** Pointer enter, ring step or spatial step sets focus in the same frame; the lift starts the next frame and completes in `LIFT_MS` (120 ms, ease-out, no overshoot, no breathing). Input-to-focus latency is at most one frame on every device, with a worst case of 33 ms (technical director to confirm).
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
| Figure band free of keylines | Art bible §6.6 | Art | E06 (warning; conflict with §6.4 to the art director) |
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

[To be designed]

## Open Questions

[To be designed]
