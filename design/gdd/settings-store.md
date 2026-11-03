# Settings Store

> Authoring guidance: .claude/docs/templates/guidance/game-design-document-guide.md (load per-section as you author — do not read entirely).

> **Status**: Designed
> **Author**: Mustafa Faisal (user) + ux-designer, systems-designer, gameplay-programmer (agents)
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: 5 Pressure comes from attention, not reflexes (the timer and reveal options keep the room fair for every player)

## Summary

The Settings Store is the single, closed catalogue of player preferences in Paper Walls: seventeen declared keys (the interrogation timer mode, UI and cursor scale, flicker and motion limits, red-as-hatching, the reveal and tooltip modes, screen-reader verbosity, captions, window mode and vsync, the bindings of the ten input names, four audio levels, locale and a first-run flag), each with a default, a range, an owner and a string id for its label. It validates strictly when the settings sheet writes and leniently when the file loads, persists to an A/B file pair under the user profile with a debounce, migrates by tombstone, layers defaults under OS-derived first-run values, persisted values and QA overrides, and tells its readers of every change synchronously. It exists so that the accessibility promises of the art bible and the first three GDDs are declared facts with one owner, and so that no setting can ever change what the story asks or what an answer costs: story systems never read it, and two runs with opposite settings produce the same dossier.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `Narrative Content Format & Strings` (locale and string ids); read by Paper UI (the only writer), Dialogue & Interrogation, Overlay & Surveillance Rendering, Scene & Interaction Framework, Audio

## Overview

The Settings Store is the one place a player preference lives: a small, typed catalogue of plain-data settings (the interrogation timer mode, UI scale, cursor scale, flicker and motion limits, red-as-hatching, the hotspot reveal and tooltip modes, locale, audio levels, and the bindings of the seven input actions) with declared defaults, ranges and owners, read by the systems that act on them and written only by the settings sheets of Paper UI. It loads once at start-up, validates every value against its declaration, persists to the user's profile outside the save files, and tells its readers when a value changes. It exists because the technical director split it out of the HUD so that Dialogue, Overlay Rendering, the Scene framework, Paper UI and the string lookup read one source of truth instead of each keeping its own, and because the accessibility promises the art bible and the first three GDDs make (a timer that can be turned off or doubled, text that scales, red that can become hatching, nothing that needs a held key) are only promises if the values behind them are declared, persisted and reachable from one sheet. The index describes it as "plain-data settings (timer mode, UI scale, flicker, red-as-hatching) read by others, written by the HUD settings screens", and this GDD keeps that scope while adding the keys the later GDDs have since required (locale, reveal and tooltip modes, cursor scale, action bindings). It does not own how a setting is presented (Paper UI), what a setting does (each reader), or save-game state (Save/Load). Implementation questions raised here (which engine file API persists it, how bindings reach the input map) are recorded for the ADRs, not decided in this document.

## Player Fantasy

*Framing: indirect. The player never sees the store; they see a settings sheet that Paper UI draws from the store's declared keys. Shaped with the creative director (three candidate framings; "the form you fill in about yourself" chosen, with the head line and the phase-invariance rule from "the back of the page"; "the state's form, filled in by you" rejected because it makes accessibility feel like being registered).*

**The form you fill in about yourself.** The settings sheet is the one form in Paper Walls that the player fills in about themselves, and nobody files it. It is a sheet at UI value like every other sheet (art bible §7.1), typed, with field labels down the left and typed brackets for the answers. It has no surveillance stamp, no carbon and no "cc", because nothing on it is copied anywhere, and it looks the same in Confident week as in Collapsing week: no phase ink reaches it. The anchor is the timer line, `INTERROGATION TIMER: [ OFF ] [ 2× ] [ DEFAULT ]`, with one bracket double-struck. Choosing a bracket is the same press that chooses an answer in a transcript, so the sheet teaches the game's grammar, and it promises that this answer, unlike every other one, costs nothing. At its head, above every field, one typed line is the only sentence in the game addressed to the player instead of a protagonist: *nothing in this room needs a steady hand.* It states openly what GDD 3 guarantees. A player with a tremor, low vision or a slow reading pace should feel that the game made room for them before they had to ask. The feeling is the small relief of a form that asks only what it needs and keeps the answers to itself.

*Costs accepted:* the settings sheet is exempt from §7.5's surveillance stamp and from phase styling (the art director records the exemption); the head line is one piece of out-of-fiction copy the narrative director approves and localises.

**Pillar alignment.** Pillar 3, "no one is clean": with no "safer" setting, no option can soften a cost or buy absolution. Pillar 5, "pressure comes from attention, not reflexes": pressure comes from the state's attention, which no setting touches, so "timer off" removes the reflex test without removing the pressure.

**The one rule the store must obey: a setting changes how the game asks, never what it asks or what an answer costs.** Every key changes only presentation, input or pace. No key changes which choices exist, what they cost, when they are available, what they write to a dossier, how attention rises, or which ending is reached. *Required:* story systems (dossier, attention, rules, chapter structure, the simulator) never read a setting value; settings are never written into a save; if the timer running out produces an outcome (silence as an answer), turning the timer off keeps that outcome available as an explicit choice (Dialogue & Interrogation decides how). *Forbidden:* any "easy", "story" or "recommended" label, or any option framed as reducing difficulty; a consequence preview, undo or rewind presented as a setting; a setting that adds a timer anywhere outside interrogation or search; an achievement, ending or text line that depends on a setting; a warning or confirmation shown when an accessibility option is chosen. *Design test (headless, an acceptance criterion):* two simulated runs with the same choices and opposite values for every setting produce identical dossiers, attention and ending state; any difference is a defect.

## Detailed Design

### Core Rules

*Drafted with the UX designer (the catalogue), the systems designer (store semantics) and the gameplay programmer (the seam and bridges). Rulings where they differed are stated in place. Engine facts are quoted only from `docs/engine-reference/godot/`; everything else is **NOT SOURCEABLE** and listed as a spike. Items marked **(PROV)** rest on a system whose GDD is not yet written.*

**0. Vocabulary.** A *key* is one declared setting. The *catalogue* is the closed declaration of every key. A *reader* is a system that acts on a value; the *writer* is Paper UI's settings sheet. A *bridge* is an adapter that carries a value into an engine server (input map, display, audio); the store itself never touches one. A *layer* is one source of a value (default, OS-derived, persisted, session override).

**1. The catalogue is closed.** `assets/data/settings/schema.json` declares every key: `{type: bool|int|float|enum|binding, default, range: [lo, hi] + step (int/float) | values (enum), category: accessibility|display|input|audio|language|meta, owner, restart_required, persist, since_version, deprecated_to, os_default: null|locale|reduced_motion}`. Key grammar `^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)?$` (one dot at most: `audio.master`, `bindings.examine`); keys are flat, never nested dictionaries, so `changed(key, old, new)` and `reset(key)` are unambiguous. `get`, `set`, `reset`, `bindings` and `subscribe` on an undeclared key return `UNKNOWN_KEY` and assert in debug builds. A build-time lint checks: defaults in range and on step, `(hi − lo)` a multiple of `step`, enum defaults in `values`, default bindings conflict-free, `deprecated_to` targets declared and of the same type, every key's label, help and enum-value string ids present in GDD 2's `en` table. *Rationale:* GDD 1 Rule 3's discipline: one declaration, nothing hardcoded, so the sheet, the validator and the tests enumerate the same list. *Rejected:* readers registering their own keys at start-up (order-dependent; the sheet cannot be built before every reader exists; headless tests would see a different catalogue than the game).

**2. The MVP catalogue.** Keys the art bible mandates are marked *(bible)*. No MVP key sets `restart_required`; the field exists for later keys.

| Key | Type | Default | Values / range | Category | Owner (reader) | Why it exists |
|---|---|---|---|---|---|---|
| `timer_mode` *(bible)* | enum | `default` | `off`, `double`, `default` | accessibility | Dialogue & Interrogation **(PROV)** | Art bible §7.5 and C5: off / 2× / default. The only clock in the game starts when the player answers an interrogator (Pillar 5); idle anywhere loses nothing. A change mid-interrogation applies at the next beat, not mid-fill |
| `ui_scale` *(bible)* | int | 100 | 100–150 step 10 | accessibility | Paper UI **(PROV)**; GDD 3 (slip, counts) | §7.2 "100–150% required". Hit rects never scale (GDD 3 Rule 9); only paper Controls do. 150% under the 1080 stretch reaches 225% of the 720 body; whether WCAG 1.4.4's 200% is a formal target is the accessibility specialist's |
| `cursor_scale` | int | 100 | 100–200 step 50 | accessibility | GDD 3 Rule 12 | `CURSOR_PX` × scale; 64 px at 720 for low vision; the hit point stays at the fingertip |
| `flicker` *(bible)* | enum | `limited` | `off`, `limited` | accessibility | Overlay & Surveillance Rendering **(PROV)** | §7.4 and §2.2: the Panicking flicker runs under Overlay's cap of `FLASH_MAX_PER_S` (WCAG 2.3.1); no value permits more. `off` removes the effect; set `off` when the OS reports reduced motion at first run |
| `motion` | enum | `full` | `full`, `reduced` | accessibility | Paper UI; GDD 3 (lift, wipe); Overlay | §7.4 durations become 0 ms under `reduced`; the timer margin fill stays, because it is information, not decoration (readers decide; the store never knows). WCAG 2.3.3 |
| `red_as_hatching` *(bible)* | bool | `false` | | accessibility | Overlay (stamp, timer fill, surveillance) | §4.5's supplementary toggle for protan and deutan players who prefer no red at all; the shape backups already carry meaning for everyone |
| `reveal_mode` | enum | `hold` | `hold`, `toggle`, `always` | accessibility | GDD 3 Rule 6 | For players who cannot sustain a hold; no deadline in any mode |
| `tooltip_mode` | enum | `examine` | `examine`, `focus`, `off` | accessibility | GDD 3 Rule 6 | `focus` for players who cannot right-click; `off` for screen-reader users whose announcement carries the name |
| `sr_verbosity` | enum | `full` | `full`, `brief` | accessibility | GDD 3 Rule 9; Paper UI | `brief` drops the "n of m" count, the known fatigue point. There is no screen-reader on/off: AccessKit roles are always present (§7.6) |
| `captions` | bool | `true` | | accessibility | Paper UI; Audio **(PROV)** | §4.5's audio backups (the two attention cues, the timer cue) typed in brackets, `[ phone rings ]`; dialogue is already text. A hearing player loses nothing with it on |
| `window_mode` | enum | `windowed` | `windowed`, `fullscreen`, `borderless` | display | the display bridge | First run never takes the screen, so a screen-reader user keeps their reader window visible (technical and art directors may overrule; Open Questions) |
| `vsync` | bool | `true` | | display | the display bridge | Tearing on a static plate is the one motion the art bible forbids |
| `bindings.<name>` | binding | GDD 3 Rule 3's table | 1–`MAX_EVENTS_PER_ACTION` events; per class at most `KB_SLOTS`/`MOUSE_SLOTS`/`PAD_SLOTS`; no event shared between names | input | GDD 3 Rule 3 (`assets/data/input_actions.json`) via the input bridge | "The framework never hardcodes a binding." Ten names for GDD 3's seven rows: `activate`, `focus_next`, `focus_prev`, `focus_up`, `focus_down`, `focus_left`, `focus_right`, `reveal`, `examine`, `cancel`, `dossier` (GDD 3 keeps one `focus_dir` action with a direction parameter; the four direction keys are the remappable surface). Mouse events are fixed at MVP (a pointer game always has a click; button swap is the OS's); Esc stays on `cancel` as the capture-mode cancel key |
| `audio.master` / `.music` / `.sfx` / `.voice` | int | 100 / 80 / 100 / 100 | 0–100 step 5 | audio | Audio **(PROV)** via the audio bridge | Bus levels; `voice` reserved pending the audio director's cue spec |
| `locale` | enum | OS language if shipped, else `en` | the content manifest's `shipped_locales` | language | GDD 2 `StringLookup`; GDD 3 Rule 9 (names re-resolve) | GDD 2 Rule 10: locale comes from this store, fallback `en`. MVP ships `en` only, so the enum has one value; `pseudo` exists in dev builds only |
| `first_run_seen` | bool | `false` | | meta | Paper UI | Drives the one-time slip (Rule 12); declared because nothing undeclared can be written |

*Not settings, and why* (Player Fantasy's one rule): difficulty (Pillar 5 has no reflex axis to ease; `timer_mode` is named for what it does and sits under Accessibility); skip-timer-consequence (Pillar 3: silence under interrogation is a line, and every line costs; `timer_mode: off` removes the clock, never the cost); a hint toggle (the reveal hold and the read count are the discoverability aids for everyone; a hint switch creates two games and hides facts from the players who most need them); colour swaps or a high-contrast mode beyond hatching (§4.5's backups are shapes and §4.4's contrasts are measured post-composite; a palette mode would unmeasure the 7:1 floor); autosave (Save/Load's); content-warning suppression; mouse sensitivity (the OS's); resolution (the window is the resolution under `canvas_items` stretch, resizable and remembered by the OS); accessibility presets (bundles hide which key did what, and every key is one line). *Rejected:* `screen_reader: on|off` (a second UI); `locale: auto` re-read every launch (fights the player's choice); per-save settings.

**3. Declared keys are permanent.** Once a key has shipped (`since_version` ≤ any released `SCHEMA_VERSION`) it is never renamed or deleted: it is retired with `deprecated_to: <new_key>` (a tombstone with a forwarding address, GDD 2 Rule 3's `replaced_by`) or `deprecated_to: null` with `type` kept so old files still parse. The catalogue is append-only after first ship; enum `values` may be added, never removed (a removed value becomes a migration). The lint's input for this rule is the released-schema snapshot `tests/unit/settings/fixtures/schema_released.json`, copied at each release tag (empty until the first ship); a key present there and absent or changed in the current catalogue fails the build. *Rationale:* the persisted file on a player's machine is an external contract exactly as a save is; a rename is data loss. *Rejected:* a free-form migration script per version (untestable against a catalogue; `deprecated_to` makes every migration a table lookup the lint can check).

**4. API and write authority.** Two interfaces over one object. `SettingsReader`: `get(key) → typed value`, `bindings(name) → Array`, `subscribe(key, callable)`, `snapshot() → {schema_version, values}` (deep copy, file shape), signal `changed(key, old, new)`. `SettingsStore extends SettingsReader`: `set(key, value) → {ok, error}`, `set_many([{key, value}]) → {ok, errors}` (validates the resulting whole, so the sheet can swap two bindings), `reset(key | "all")`, `load()`, `flush()`, `close()` (the final `flush()`, after which the store is `closed` and `set` returns `NOT_READY`), `migrate(payload) → payload`. Error enum: `UNKNOWN_KEY`, `TYPE`, `RANGE`, `ENUM`, `BINDING_EMPTY`, `BINDING_TOO_MANY`, `BINDING_CLASS_FULL`, `BINDING_DUPLICATE(other)`, `BINDING_MALFORMED`, `OVERRIDDEN`, `NOT_READY`; user-level validation never raises an engine error. Readers are constructed with a `SettingsReader`; only Paper UI's settings sheets and the `migrate` path hold a `SettingsStore`. *Rationale:* a capability you were not handed cannot be misused; a string writer token can be forged by any caller. *Rejected:* per-key `writers` lists as in GDD 1 (every key here has one writer, so the list would be a constant); readers calling `set` to "fix" values (two writers, no owner).

**5. Validation: `set` rejects, `load` clamps.** `set` checks type (an `int` key rejects a float even if integral; `bool` rejects 0 and 1), then range with step snapping (Formulas §1): a value outside `[lo, hi]` is `RANGE`; a value inside the range but off step is snapped and accepted (a slider drag may send 123; the store keeps 120 and the sheet shows 120); then enum membership; then binding well-formedness (Rule 6). `load` never rejects a scalar: out of range → `snap`; wrong type or unknown enum value → default; each with one warning naming the key, the value found and the value used. *Rationale:* the sheet is a live caller that can show an error and must never persist garbage; the file is a dead artefact whose only alternatives to clamping are a wrong default or refusing to start. *Rejected:* `set` clamping silently (the slider and the stored value disagree, and the sheet cannot tell a typo from a drag); `load` rejecting the file whole as GDD 1 Edge Case 13 does for saves (a blank save loses a story; a blank settings file loses a preference the player restores in one sheet, so strictness buys nothing and costs a start-up failure).

**6. Bindings.** An event is plain data `{dev: kb|mouse|pad, code, mods: [shift|ctrl|alt|meta]}` in memory, stored and diffed in a portable string form through a headless `BindingCodec` (`"key:F"`, `"key:ctrl+F"`, `"mouse:1"`, `"pad:button0"`); `code` names a **physical** key so a binding survives a layout change (keycode naming and physical-versus-unicode behaviour are **NOT SOURCEABLE**, spike). `binding_ok` (Formulas §2): 1 to `MAX_EVENTS_PER_ACTION` events, at most `KB_SLOTS` keyboard, `MOUSE_SLOTS` mouse and `PAD_SLOTS` gamepad events, no event shared between two names, no modifiers on mouse or pad events, and every name keeps at least one keyboard event (GDD 3's reach-by-enumeration proof). `set` on one name is rejected with the reason; the sheet swaps two bindings through `set_many`. At `load`, binding validity is a property of the whole group: any failure resets **all** `bindings.*` to defaults with one warning, because conflict-free defaults are lint-guaranteed and a partial repair could leave a name empty. *Rejected:* an unbound action with a warning (breaks GDD 3's proof); shared events with priority (meaning would depend on context, which GDD 3 forbids); `InputEvent` dictionaries in the file (engine serialisation drift, not hand-editable).

**7. Persistence.** The file is plain data `{schema_version, generation, values}` with only `persist: true` keys, under the user profile directory, separate from saves, per machine, never per save slot, never inside a save, and never loaded as an engine Resource (GDD 1's ADR-4 principle). *Atomic write:* the sourced API set cannot express temp-and-rename (`FileAccess.store_*` returning `bool` is the one sourced fact, breaking-changes.md line 91; rename and directory APIs are **NOT SOURCEABLE**), so the MVP writes an A/B pair, `settings.a.json` and `settings.b.json`, alternating files and incrementing `generation`; `load` reads both and takes the highest generation that parses, so a crash mid-write loses at most one generation and never the file. When the spike confirms a rename API the engine twin switches to temp-and-rename; the store does not change. *When:* writes are debounced (Formulas §6, `WRITE_DEBOUNCE_MS`) and forced by `flush()` on sheet close and on quit (the main scene calls `flush()` from its close notification); never during a wipe. `load` runs once, synchronously, before any scene exists. *Rationale:* a slider drag emits dozens of sets a second; one write per burst keeps the disk quiet and a crash loses at most one window. *Rejected:* the engine's `ConfigFile` (**NOT SOURCEABLE** API, and INI sections cannot carry a binding list cleanly); write on every change (I/O on the drag path); write only on quit (a crash loses the whole session's settings).

**8. Versioning.** `load` reads `schema_version`. Equal: validate per Rule 5. Older: `migrate` walks every key with `deprecated_to`, moving the old value to the new key if absent there, then validates. Newer: keys that match the current catalogue load, the rest drop with a warning, and the file is rewritten at the current version on the next flush (a downgraded build keeps what it understands). Missing files: defaults, no warning, no write until the first change. Both files unparseable: defaults, one warning, the bad files renamed `.bad` so support can read them. *Rejected:* refusing a newer file (locks a player out of defaults on a rollback build).

**9. Precedence of layers.** For every key the effective value is the highest present layer: schema default < OS-derived first-run default < persisted value < session override. The OS layer is computed once, when no file exists, and only for keys with `os_default`: `locale` through `effective_locale` (Formulas §5), and `motion` → `reduced` plus `flicker` → `off` when the OS reports reduced motion (`OS.get_locale` and the reduced-motion query are **NOT SOURCEABLE**, spike; if unavailable the static defaults stand). The result is persisted at once, so a later OS change never silently moves a chosen value. Never read from the OS: screen-reader presence (AccessKit is always on; detection would create a second UI), display scale (`ui_scale` is the player's choice; DPI is the stretch's job), audio levels, window mode. Session overrides come from a launch flag `--setting key=value` for QA, are validated like `set`, are never persisted, and make `set` on that key return `OVERRIDDEN` while the sheet shows a lock. *Rejected:* re-deriving OS defaults every launch; overrides that `set` can clear.

**10. Change propagation.** A `set` that changes a value stores it, then emits `changed(key, old, new)` synchronously on the main thread before returning, so `get` inside a handler sees the new value; a `set` to the current value emits nothing; handlers run in connection order and must not do work (Paper UI defers its re-layout). `reset("all")` emits one `changed` per key that actually changes, then `reset_done`. `load` emits nothing: it completes before any scene exists and readers construct against the loaded state. A key with `restart_required: true` is read by its owner once at start-up and the sheet labels it "takes effect on restart"; no MVP key needs it (locale is live, since GDD 3 Rule 9 re-resolves names on change; `window_mode` and `vsync` live pending the display spike). No reader polls. *Rejected:* deferred emission (hides a frame where the sheet and the room disagree); readers re-reading every frame (cost, and no moment of change to announce to a screen reader).

**11. The store holds data; the applier holds side effects.** `SettingsStore extends RefCounted`, constructed as `new(schema, file: SettingsFile, clock: Clock, os: OsProbe, overrides)` where `overrides` carries the content manifest's `shipped_locales` (the catalogue cannot know it statically) and the session overrides from the launch flag. `OsProbe` is the injected seam for the OS layer (`locale() → String|null`, `reduced_motion() → bool|null`): `NullOsProbe` returns what a test sets, the engine twin wraps the OS and display-server queries (**NOT SOURCEABLE**, spike) and returns null when they are unavailable, so the static defaults stand. `SettingsFile` is the injected file adapter (`read_pair() → {a, b}`, `write(slot, text) → bool`, `rename_bad()`): `MemorySettingsFile` for tests (holds text, counts writes, can fail the next write) and `UserSettingsFile.new(path)` for the game, so the store never knows the profile path. `SettingsApplier extends RefCounted` subscribes to `changed` and owns the bridges, each with a null twin that records into a dictionary tests read: `InputBridge` (engine twin → the input map; API **NOT SOURCEABLE**, spike); `DisplayBridge` (window mode, vsync; **NOT SOURCEABLE**, spike); `AudioBridge` (engine twin → bus index, volume and mute; **SOURCED**, audio.md lines 55–59; the percent-to-decibel curve is Audio's config). Locale has no bridge of its own: the applier hands `locale` to GDD 2's engine `StringLookup`, which already owns the engine's translation calls. `ui_scale` has no bridge either: applying it as a root scale factor would scale hit rects, which GDD 3 forbids; Paper UI reads it and scales its sheets itself. `cursor_scale`, `reveal_mode`, `tooltip_mode`, `timer_mode`, `flicker`, `motion`, `red_as_hatching`, `sr_verbosity` and `captions` are reader values, not bridge calls. *Start-up order* (the main scene's ready, no autoload): schema → `UserSettingsFile` → `SettingsStore.new` → `load()` (read, migrate, validate, OS layer, overrides) → `applier.apply_all()` (locale before content so names resolve once) → `EngineSceneHost` → `SceneFlow.new(host, dossier, content_store, settings)` → content. The CI path check extends to `src/settings/`: only `src/settings/engine/*` may touch the tree or a server. *Rejected:* an autoload singleton (the pattern the coding standards forbid for testability); the store calling servers directly (one import and the simulator cannot load it).

**12. The sheet's guarantees and first run.** Per key the store guarantees: string ids `set.<key>.label`, `set.<key>.help` and `set.<key>.value.<v>` for every enum value (GDD 2: every string is an id, never blank); an accessible name equal to the label and a description equal to the help; a role by type (bool → checkbox, enum → radio group, int → slider with a typed numeral, binding → a button that enters capture); a per-key `[ RESET ]` struck VOID when already at default (art bible C3) and `[ RESET ALL ]` on the sheet; an error string id for every refusal so the sheet can type it. *Live preview:* `ui_scale`, `cursor_scale`, `motion`, `red_as_hatching` and `locale` apply on change with no confirmation and are reversible on the same sheet by keyboard alone, so no revert timer exists (a deadline would break GDD 3's rule). *Capture mode:* "press a key", Esc cancels capture, and every name keeps at least one keyboard event. *First run:* no wizard, because every default is safe (nothing lost idle, no flash above `FLASH_MAX_PER_S`, windowed, OS language); one typed slip on the first title sheet, keyed on `first_run_seen`, reads `[ SETTINGS: BACK PAGE ]` (the sheet is the back page of the folder, in the fiction, and Esc opens it anywhere) and stays until dismissed, never on a timeout. The sheet itself is exempt from §7.5's surveillance stamp and from phase styling (Player Fantasy).

**13. Meaning-blind.** The store validates shape and range only and never interprets a value. `FLASH_MAX_PER_S` is declared here so that Overlay and `design/accessibility-requirements.md` cite one number, but the store does not count flashes; `UI_MIN_PX` is declared here so Paper UI and the art bible agree on the floor. Story systems (dossier, attention, rules, chapter structure, the simulator) are never constructed with a `SettingsReader` and the CI path check forbids the import (Player Fantasy's design test).

### States and Transitions

**Store lifecycle:** `unloaded → loading → ready → closed`. `loading` (read the pair, pick the generation, migrate, validate, OS layer on first run, session overrides) is synchronous and runs before the first scene; `ready` is the only state in which `set` and `get` are legal (`get` before `ready` asserts in debug and returns the default with a warning in release; `set` returns `NOT_READY`); `closed` follows the final `flush()` on quit, after which `set` returns `NOT_READY`.

**Dirty flag within `ready`:** `clean ⇄ dirty`. The first changing `set` arms the debounce timer; each further `set` re-arms it; expiry or `flush()` writes the next slot of the A/B pair, increments `generation` and returns to `clean`. A failed write stays `dirty`, logs once, and retries at the next arm or `flush()`.

**Per-key layer label** (for the sheet, not a state machine): `default`, `yours` (persisted), `system` (OS-derived at first run, then persisted), `launch flag` (session override; locked).

### Interactions with Other Systems

| System | Reads from this store | Writes | Interface owner | Status |
|---|---|---|---|---|
| **Paper UI** | every key for the sheets; `ui_scale` through `ui_scale_px`; `sr_verbosity`, `captions`, `first_run_seen`, `motion` | the only `set`/`set_many`/`reset` caller (holds the `SettingsStore`) | this store (API, string-id guarantees); Paper UI (the form) | **(PROV)** |
| **Dialogue & Interrogation** | `timer_mode` (applied at the next beat), `captions` | — | Dialogue decides how `off` keeps the silence outcome available as an explicit choice | **(PROV)** |
| **Overlay & Surveillance Rendering** | `flicker`, `motion`, `red_as_hatching`; the constant `FLASH_MAX_PER_S` | — | Overlay owns the cap and the effects | **(PROV)** |
| **Scene & Interaction Framework** (GDD 3) | `reveal_mode`, `tooltip_mode`, `cursor_scale` (× `CURSOR_PX`), `motion`; `bindings.*` through the input bridge | — | GDD 3 Rule 3's action list is the binding vocabulary; the ten names and seven rows are reconciled there | written |
| **Narrative Content Format** (GDD 2) | `locale` handed to the engine `StringLookup` by the applier; `shipped_locales` from its manifest feeds the enum; every label, help and value string id lives in its `set.*` namespace | — | GDD 2 owns the lookup and the ids; this store owns the key | written |
| **Audio** | `audio.*` through the audio bridge (sourced bus API); `captions` | — | Audio owns the percent-to-decibel curve and the cue spec | **(PROV)** |
| **Save/Load** | nothing; separate file, separate version | the `migrate` pattern is shared in shape, not in code | — | **(PROV)** |
| **Dossier, Rules, Calendar, Chapter Structure, the simulator** | **nothing, ever** (Player Fantasy's rule; CI path check) | — | — | — |
| **Accessibility requirements** (`design/accessibility-requirements.md`, not yet written) | inputs: the accessibility-category keys with defaults, `FLASH_MAX_PER_S`, `UI_MIN_PX`, the WCAG 1.4.4 and 2.5.8 questions | — | accessibility-specialist | **(PROV)** |


## Formulas

*Proposed by the systems designer; reformatted to the house structure. All constants live in `assets/data/settings/schema.json` or `assets/data/settings/tuning.json` (D) unless marked art-bible (A).*

### 1. Step snapping

The step-snapping formula is defined as:

`snap(value, lo, hi, step) = clamp(lo + round((clamp(value, lo, hi) − lo) / step) × step, lo, hi)`

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `value` | int/float | unbounded | calculated (sheet or file) | Candidate value |
| `lo`, `hi` | same as key | `lo < hi` | data file (catalogue) | Declared range |
| `step` | same as key | > 0; `(hi − lo) mod step = 0` (lint) | data file (catalogue) | Declared increment |
| `snap` | same as key | `[lo, hi]` | calculated | Stored value |

**Output Range:** `lo` for any value at or below `lo`, `hi` at or above; `step ≤ 0` is a lint error and never reached at runtime.
**Example:** `ui_scale` 123 → clamp 123 → 23/10 = 2.3 → round 2 → 120. *Rejected:* truncation instead of rounding (a drag ending at 149 would store 140, one step short of where the slider sits).

### 2. Binding validity

The binding validity formula is defined as:

`binding_ok(name, events, others) = 1 ≤ n ≤ MAX_EVENTS_PER_ACTION ∧ n_kb ≥ 1 ∧ ∀c: n_c ≤ cap_c ∧ events ∩ ⋃others = ∅ ∧ ∀e: well_formed(e)`

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `n` | int | 0–∞ | calculated | Events bound to this name |
| `n_c` | int | 0–n | calculated | Events of class `c ∈ {kb, mouse, pad}` |
| `cap_c` | int | kb 2, mouse 1, pad 1 | constant (`KB_SLOTS`, `MOUSE_SLOTS`, `PAD_SLOTS`) | Per-class slots |
| `MAX_EVENTS_PER_ACTION` | int | 2–4 | constant (3) | Total slots |
| `others` | set of events | — | calculated | Every other name's events |
| `well_formed(e)` | bool | — | calculated (`BindingCodec`) | Parses; no modifiers on mouse or pad |
| `binding_ok` | bool | — | calculated | Accept, or reject with the first failing reason |

**Output Range:** boolean; the reason order is `EMPTY`, `TOO_MANY`, `CLASS_FULL`, `DUPLICATE`, `MALFORMED`, and keyboard-reach (`n_kb ≥ 1`) reports as `EMPTY`.
**Example:** `activate` = [mouse:1, key:Enter, key:Space]: n = 3, kb = 2, mouse = 1, nothing shared → ok. Adding `key:E` (already `examine`) → `BINDING_DUPLICATE(examine)`. *Rejected:* one event per class with three classes (`activate`'s Enter and Space could not coexist).

### 3. Flash-rate ceiling

The flash-rate formula is defined as:

`flash_rate_ok(flashes, window_s) = flashes / window_s ≤ FLASH_MAX_PER_S` over every sliding one-second window (WCAG 2.3.1 general flash threshold); owned by Overlay when `flicker = limited`, declared here.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `flashes` | int | ≥ 0 | calculated (Overlay) | Opposing luminance changes in the window |
| `window_s` | float | 1.0 | constant | The WCAG window |
| `FLASH_MAX_PER_S` | int | ≤ 3 only | constant (3) | Legal maximum; may only be lowered |
| `flash_rate_ok` | bool | — | calculated | The effect may play at this rate |

**Output Range:** boolean. **Example:** the Panicking portrait flicker at 2 per second → ok; a 4 per second burst is capped to 3 or dropped by Overlay; the red-flash area threshold is Overlay's to add. *Rejected:* a per-player Hz slider (players do not tune frequencies, and no value above the ceiling may exist).

### 4. UI scale in pixels

The UI scale formula is defined as:

`ui_scale_px(base_px, ui_scale) = max(UI_MIN_PX, round(base_px × ui_scale / 100))`

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `base_px` | int | 10–48 | data file (art bible §7.2 sizes at 720; body 18) | Authored size |
| `ui_scale` | int | 100–150 step 10 | data file (the key) | The player's scale |
| `UI_MIN_PX` | int | 15 | constant (art bible §7.2 "nothing below 15") | Floor |
| `ui_scale_px` | int | `[UI_MIN_PX, 72]` | calculated | Rendered size at 720, before the engine's ⅔/1.5 stretch |

**Output Range:** 15 to 72. **Example:** body 18 at 100 → 18; at 150 → 27; labels 15 at 100 → 15. Hit rects are not scaled (GDD 3). *Flag:* art bible §7.2's 15 px floor and §7.6's "body text ≥ 16 px" are consistent for body (18) but the accessibility specialist owns the floor for labels. *Rejected:* scaling the root (would scale hit rects).

### 5. Effective locale

The effective-locale formula is defined as:

`effective_locale(persisted, os_locale, shipped) = persisted if persisted ∈ shipped; else lang(os_locale) if persisted = null ∧ lang(os_locale) ∈ shipped; else DEFAULT_LOCALE`, where `lang` strips the region (`pt_BR → pt`).

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `persisted` | enum or null | `shipped ∪ {null}` | data file (the settings file) | The player's stored choice |
| `os_locale` | string | BCP-47-like | calculated (OS; **NOT SOURCEABLE**) | The OS report at first run |
| `shipped` | set | ⊇ {`en`} | data file (content manifest) | Shipped locales |
| `DEFAULT_LOCALE` | enum | must be shipped | constant (`en`) | GDD 2 Rule 10's fallback |
| `effective_locale` | enum | `shipped` | calculated | The locale handed to `StringLookup` |

**Output Range:** always a shipped locale. **Example:** persisted null, OS `de_DE`, shipped {en} → `en`; persisted `de` after `de` is dropped from a build → `en` with a warning. Per-object completeness fallback stays GDD 2's `object_complete`. *Rejected:* keeping an unshipped persisted value (a raw id would reach the screen).

### 6. Write debounce

The debounce formula is defined as:

`write_at = t_last_set + WRITE_DEBOUNCE_MS`; a write happens when `now ≥ write_at` or on `flush()`; writes per burst = 1 for any sequence of sets whose gaps are below `WRITE_DEBOUNCE_MS`; worst-case loss on a crash = the changes of the last `WRITE_DEBOUNCE_MS`.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| `t_last_set` | float ms | ≥ 0 | calculated (injected clock) | Time of the most recent changing `set` |
| `WRITE_DEBOUNCE_MS` | int | 100–2000 | constant (500) | The window |
| `write_at` | float ms | ≥ `t_last_set` | calculated | Scheduled write |

**Output Range:** one write per burst. **Example:** a 1.2 s slider drag at 60 sets per second with a 500 ms window → one write 500 ms after the drag ends, or earlier on sheet close. *Rejected:* a fixed interval timer (writes while idle).

## Edge Cases

*From the systems designer over the rule and formula space; six rulings it proposed as new are accepted and marked.*

1. **If both `settings.a.json` and `settings.b.json` parse with the same `generation`**: compare the two texts; identical → load either, no warning; different → load `.a`, one warning quoting both generations, and the next write goes to `.b` at `max + 1` *(new ruling)*. *Equal generations only arise from a crash between write and counter increment or from hand-copying; a deterministic slot choice beats guessing which is newer.*
2. **If both files are unparseable**: defaults, one warning, both renamed `.bad` (overwriting earlier `.bad` files), the OS layer is computed as on first run, and the next flush writes `generation` 1 to `.a`. *Nothing chosen survives, so there is nothing for the OS layer to override; `first_run_seen` is lost too, so the slip reappears, which is the honest signal.*
3. **If the higher-generation file carries a newer `schema_version` than the build**: it still wins (generation decides, not version), Core Rule 8's newer path applies, and the next flush rewrites at the current version. *Falling back to the older-generation file would discard the player's latest choices to keep a version number.*
4. **If a file from a newer build holds an unknown enum value for a known key** (`reveal_mode: "dwell"`): Core Rule 5, `load` uses the default with a warning; the next flush persists the default, so the value is lost on the downgrade. *Enum values are append-only (Core Rule 3), so this only occurs on a rollback build, which cannot represent the value anyway.*
5. **If `deprecated_to` forms a chain** (`a → b → c`): `migrate` follows the chain to the first non-deprecated key and moves the value there only if that key is absent in the file; intermediate tombstones are never populated. The lint rejects cycles and type changes at any hop.
6. **If the persisted `locale` is no longer in `shipped_locales`**: Formulas §5 gives `DEFAULT_LOCALE` with a warning; the layer label becomes `default`, and the next flush persists `en`. *Keeping the stale value would put a raw string id on screen (GDD 2 Rule 10).*
7. **If `--setting` names an undeclared key**: one warning at launch naming the key, the flag is dropped, the game starts. *`UNKNOWN_KEY` is a QA typo, not a reason to refuse a launch.*
8. **If `--setting` targets a binding** (`--setting bindings.examine=key:E,key:ctrl+E`): parsed through `BindingCodec`, validated with `binding_ok` against the loaded group; failure drops the flag with the reason; success locks that name for the session and is never persisted *(new ruling)*. *QA needs the override to test keyboard reach, and the group rule still applies.*
9. **If the sheet calls `set` or `reset` on an overridden key**: `OVERRIDDEN`, no store change, no `changed`; the sheet shows the lock and the `launch flag` label. *A launch flag outranks the sheet on every path (Core Rule 9).*
10. **If the OS reports reduced motion but a file exists**: ignored. The OS layer runs only when no file exists (Core Rule 9), even if the persisted `motion` and `flicker` equal the static defaults. *The file records that first run already decided; a later OS change never silently moves a value.*
11. **If `set_many` carries a swap that is valid as a whole but invalid per step** (A takes B's key, B takes A's): only the resulting whole is validated; all entries store together or none; `changed` emits per key, in list order, after every entry is stored. *Handlers never observe a half-swapped, duplicate-holding group.*
12. **If default bindings conflict** versus **a file where one name lost its keyboard event**: the former is a lint failure and the build does not ship. The latter is `BINDING_EMPTY` at `load`, which resets every `bindings.*` key to defaults with one warning naming the key and reason; the player's other remaps are lost. *A partial repair could orphan a second name (Core Rule 6); lint-clean defaults are the only group known to be whole.*
13. **If a `set` lands during a wipe, or `flush()` is called during one**: the store cannot see a wipe (Core Rule 13) and never defers; the "never during a wipe" guarantee is structural: the only writers (the sheet on close, the first-run slip on dismissal) call `flush()` before a wipe can begin, so the debounce has nothing to write; the slip's dismissal therefore flushes rather than debounces *(new ruling)*. A `flush()` from the quit path during a wipe writes synchronously; a quit outranks a wipe.
14. **If a write fails twice**: the store stays `dirty`, logs once at the first failure only, leaves `generation` unincremented and the other slot untouched, and retries on the next arm or `flush()`. No retry loop and no blocking; if the final quit flush fails, the session's changes are lost with one warning, and `load` still finds the last good file.
15. **If `get` is called before `load`**: debug builds assert; release returns the schema default (not OS, not persisted) with one warning per key. *Readers are constructed after `load` by Core Rule 11's start-up order, so this is a wiring bug, not a runtime state.*
16. **If `reset("all")` runs while a session override is active**: overridden keys are skipped and listed in the warning, `changed` emits only for keys that change, `reset_done` still emits, the lock remains *(new ruling)*. *Resetting a layer the player cannot see would surprise them when the flag is removed.*
17. **If a `changed` handler calls `set`**: the store holds an `emitting` flag; a nested `set` returns `NOT_READY` and asserts in debug *(new ruling)*. *Handlers must not do work (Core Rule 10); a nested emission would deliver `changed` to later handlers out of order.*
18. **If `ui_scale` is 150 at a 720 window and a sheet overflows**: Paper UI's problem (reflow, scroll, or turn the page, since the sheet is a back page); the store never clamps `ui_scale` to the window, and 150 stays in range. *Core Rule 11 gives Paper UI the scaling; WCAG 1.4.4 reflow is a layout obligation, flagged for the accessibility specialist.*
19. **If `timer_mode` changes mid-interrogation**: `changed` emits at once; Dialogue applies it at the next beat; the running fill completes at its old rate, and `off` means the next beat has no clock. *A bar that jumps mid-fill reads as a glitch, not a choice.*
20. **If `captions` is `false` while `audio.sfx` or `audio.master` is 0**: both store; no cross-key validation. The sheet types a non-blocking note under `captions` ("attention cues will be silent and untyped"); nothing changes automatically *(new ruling; the note is Paper UI's)*. *Cross-key constraints are policy, not shape; a player who asked twice for silence meant it.*
21. **If `flicker` is `limited` but Overlay cannot yet enforce `FLASH_MAX_PER_S`** (the spike is absent): Overlay must not play the flicker at all; `limited` behaves as `off` until the cap exists. The store is unchanged. *`limited` promises a ceiling (WCAG 2.3.1); without one the promise is false.*
22. **If a `step` does not divide `(hi − lo)`**: a build-time lint failure. Should a hand-edited dev schema bypass it, `snap` still clamps, so `hi` is unreachable by stepping and only by exact entry; stated so the symptom is recognisable.
23. **If a reader is constructed with a `SettingsStore`**: nothing corrupts (the last `set` wins, `changed` fires normally) but ownership is lost. The CI path check forbids the type name outside `src/settings/` and Paper UI's sheets, and every reader test constructs against a `SettingsReader` double that has no `set`, so the mistake fails in CI, not in play.

## Dependencies

*Hard* means the system cannot function without the other; *soft* means it works without it and is improved by it. Rows marked **(PROV)** name a system whose GDD is not yet written. Reciprocity today: GDD 2 lists this store as the source of `locale` and GDD 3 lists the keys it reads and the bindings it needs; both match the rows below.

| System | Direction | Hard/Soft | Interface |
|---|---|---|---|
| Narrative Content Format & Strings (GDD 2) | Mutual | Hard | This store supplies `locale` (through the applier to the engine `StringLookup`); GDD 2 supplies `shipped_locales` from its manifest for the `locale` enum and holds every `set.*` label, help, value and error string id this store guarantees |
| Scene & Interaction Framework (GDD 3) | Depends on this | Soft | Reads `reveal_mode`, `tooltip_mode`, `cursor_scale`, `motion`; its `assets/data/input_actions.json` is the binding vocabulary; the input bridge applies `bindings.*`. Absent, GDD 3's own defaults apply |
| Paper UI | Depends on this; the only writer **(PROV)** | Hard | The settings sheets (`set`, `set_many`, `reset`); reads `ui_scale` through `ui_scale_px`, `sr_verbosity`, `captions`, `first_run_seen`, `motion`; draws the first-run slip |
| Dialogue & Interrogation | Depends on this **(PROV)** | Soft | `timer_mode` at the next beat; `captions`; decides how `off` keeps the silence outcome available |
| Overlay & Surveillance Rendering | Depends on this **(PROV)** | Soft | `flicker`, `motion`, `red_as_hatching`; cites `FLASH_MAX_PER_S` for its cap |
| Audio | Depends on this **(PROV)** | Soft | `audio.*` through the audio bridge (sourced bus API); `captions` |
| Save/Load | None **(PROV)** | — | Separate file and version; settings never enter a save |
| Dossier State Model, Reactive Event Rules, Calendar, Chapter & Story Structure, the story simulator | None, by rule | — | Never constructed with a reader; the CI path check forbids the import (Player Fantasy's design test) |
| Accessibility requirements (`design/accessibility-requirements.md`) | This supplies inputs **(PROV)** | Soft | The accessibility-category keys and defaults, `FLASH_MAX_PER_S`, `UI_MIN_PX`, the WCAG 1.4.4 and 2.5.8 questions |
| Engine bridges (input map, display, audio buses) | This depends on them at runtime | Soft | Null twins make the store and applier fully testable headless; the audio bus API is sourced, the input and display APIs are spikes |

## Tuning Knobs

Column key: **D** = `assets/data/settings/schema.json` or `tuning.json`; **A** = art-bible value read by pointer; **S** = the player's value is the key itself and this system owns only the default.

| Knob | Default | Safe range | Too low | Too high | Interacts with |
|---|---|---|---|---|---|
| `SCHEMA_VERSION` (D) | 1 | monotonic | — | — | Migration trigger; not a tuning value |
| `WRITE_DEBOUNCE_MS` (D) | 500 | 100–2000 | I/O on the drag path | A crash loses a whole sheet of changes | Formulas §6; `flush()` on close and quit |
| `MAX_EVENTS_PER_ACTION` (D) | 3 | 2–4 | `activate` cannot keep click, Enter and Space | The sheet's binding column wraps | `KB_SLOTS`, `MOUSE_SLOTS`, `PAD_SLOTS` |
| `KB_SLOTS` / `MOUSE_SLOTS` / `PAD_SLOTS` (D) | 2 / 1 / 1 | 1–3 / 1 / 1–2 | Enter and Space cannot coexist | More events than a line can show | `MAX_EVENTS_PER_ACTION` |
| `FLASH_MAX_PER_S` (D, WCAG) | 3 | ≤ 3 only | The Panicking effect becomes a slow blink | Illegal; may not exceed 3 | Overlay's cap; `flicker` |
| `UI_MIN_PX` (A, §7.2) | 15 | 15–16 (accessibility specialist) | Labels unreadable under grain | Dossier field labels cannot fit 40 characters | `ui_scale_px`, Paper UI |
| `ui_scale` range/step (D) | 100–150 / 10 | hi ≤ 200 | Below the art bible's required range | Sheets overflow the window at 720 | Paper UI containers; GDD 3 hit rects (never scaled) |
| `cursor_scale` range/step (D) | 100–200 / 50 | — | — | A 96 px pointer covers the slip | `CURSOR_PX` (GDD 3) |
| `audio.*` step (D) | 5 | 1–10 | Twenty keyboard presses per slider | Coarse mix | Audio bridge |
| `DEFAULT_LOCALE` (D) | `en` | must be shipped | — | — | Formulas §5; GDD 2 Rule 10 |
| `timer_mode` default (S) | `default` | — | — | `off` as default removes an authored Pillar 5 beat for everyone | Dialogue |
| `flicker` default (S) | `limited` | — | `off` deletes an authored Pillar 2 phase effect for players who never needed it | no higher value exists | Overlay cap; OS reduced motion at first run |
| `window_mode` default (S) | `windowed` | — | — | `fullscreen` at first run hides a screen-reader window | Display bridge; Open Questions |
| `reveal_mode` / `tooltip_mode` defaults (S) | `hold` / `examine` | — | — | see GDD 3 Tuning Knobs | GDD 3 |

## Visual/Audio Requirements

Optional for a Meta system; one note suffices, because the sheet itself is Paper UI's. What this store requires of its presentation: the settings sheet is a typed form at UI value (art bible §7.1) with field labels down the left and typed brackets for values; it carries no surveillance stamp, no carbon, no "cc" and no phase ink, and looks identical in every regime phase (Player Fantasy; the art director records the §7.5 exemption, Open Questions); a chosen bracket is double-struck, a `[ RESET ]` at default is struck VOID (C3); the head line *nothing in this room needs a steady hand* is typed in the body face; live preview of `ui_scale` and `cursor_scale` re-lays the sheet in place with no animation beyond §7.4's rigid translates, and none at all under `motion: reduced`. Audio: this store owns no sound; the sheet's bracket press uses Paper UI's standard type-tick, and `captions` governs the bracketed captions `[ phone rings ]` for the §4.5 audio backups. No asset spec follows from this section.

## Game Feel

Not a feel system. Two properties the store must not break: a changed value is visible on the same frame it is set (synchronous `changed`, Core Rule 10) so a slider never lags the number beside it, and nothing in the sheet has a deadline (no revert timer, no capture timeout).

## UI Requirements

This store owns no screen. It guarantees to Paper UI, per key: `set.<key>.label`, `set.<key>.help` and `set.<key>.value.<v>` string ids; an accessible name and description; a role by type (checkbox, radio group, slider with a typed numeral, capture button); a per-key reset and a reset-all; an error string id for every refusal; a layer label (`default`, `yours`, `system`, `launch flag`); live preview for `ui_scale`, `cursor_scale`, `motion`, `red_as_hatching` and `locale` with no confirmation and keyboard-reversibility; capture mode with Esc to cancel and at least one keyboard event per name. The sheet is reachable from the title and from `cancel` in any room, and every setting is changeable by keyboard alone. First run shows one typed slip `[ SETTINGS: BACK PAGE ]` until dismissed. Accessibility inputs for `design/accessibility-requirements.md` are listed in Dependencies.

> **📌 UX Flag — Settings Store**: this system contributes the settings sheet and the first-run slip to Paper UI. In Pre-Production, run `/ux-design accessibility` first (it creates `design/accessibility-requirements.md`, which this GDD's acceptance criteria require), then `/ux-design` for the settings sheet **before** writing epics; stories cite `design/ux/[screen].md`, not this GDD.

## Cross-References

| This GDD references | In | Owner | Nature |
|---|---|---|---|
| Schema discipline (one declaration, nothing hardcoded); versioned plain data; saves never loaded as Resources; `SCHEMA_MISMATCH` strictness for saves | GDD 1 Core Rules 3, 10; Edge Case 13 | Dossier State Model | Mirrored for the catalogue (Rules 1, 7); strictness deliberately not mirrored (Rule 5) |
| Id permanence and tombstones (`replaced_by`); text and id freeze; `StringLookup` and the `locale` contract; `shipped_locales`; every string is an id | GDD 2 Core Rules 3, 10, 11, 12 | Narrative Content Format | Rule 3 (`deprecated_to`), Rule 11 (locale to `StringLookup`), Rule 12 (`set.*` ids) |
| Closed input action set and `assets/data/input_actions.json`; reveal and tooltip modes; `CURSOR_PX`; the settings GDD 3 requires; hit rects never scale; the `SceneHost` seam pattern | GDD 3 Core Rules 3, 6, 9, 12 | Scene & Interaction Framework | Rules 2, 6, 11; GDD 3 Rule 3 amended to ten names |
| Timer off / 2× / default; countdown string to the screen reader; surveillance stamp inside every open sheet | Art bible §7.5 | Art | `timer_mode`; the sheet's exemption from the stamp (Open Questions) |
| UI scale 100–150% required; nothing below 15 px; body 18 px at 720 | Art bible §7.2 | Art | `ui_scale`, `UI_MIN_PX`, Formulas §4 |
| Red-as-hatching as a UX item; shape backups; audio backups | Art bible §4.5 | Art | `red_as_hatching`, `captions` |
| Flicker limits; durations; the timer as the only continuous motion | Art bible §7.4, §2.2 | Art | `flicker`, `motion`, `FLASH_MAX_PER_S` |
| Eight UX requirements; C3 VOID bracket; C5 timer options | Art bible §7.6 | Art / UX | Rules 2, 12 |
| Diegetic UI; three screen-space exceptions | Art bible §7.1 | Art | Visual/Audio |
| `FileAccess.store_*` returns `bool`; AccessKit on Controls; audio bus API; stretch defaults | docs/engine-reference/godot/ (breaking-changes.md 75, 91; audio.md 55–59; ui.md 13–14) | Engine reference | Rules 7, 11; everything else NOT SOURCEABLE (Open Questions) |
| Pillars 3 and 5; anti-pillars | design/gdd/game-concept.md | Creative direction | Player Fantasy's one rule; Rule 2's "not settings" |
| TD-SYSTEM-BOUNDARY: Settings Store split from the HUD | design/gdd/systems-index.md header | Technical direction | Scope |

## Acceptance Criteria

*Drafted with the QA lead; the three rule gaps it found are fixed in Core Rules 3, 4 and 11 (the released-schema snapshot, `close()`, the OS probe seam). Criteria that need an undesigned system or an unsourced engine API are marked Vertical Slice or run-and-observe; `design/accessibility-requirements.md` must exist before the accessibility group is gated.*

*Drafted with the QA lead. Timing budgets live in `tests/performance/settings/`, reported per run and blocking only on the reference machine the technical director names; no unit test asserts wall time.*

*Everything is gdUnit4: catalogue, validation, persistence, layer, propagation and formula criteria under `tests/unit/settings/` (`settings_<group>_test.gd`, fixtures under `tests/unit/settings/fixtures/`, schema fixtures named `schema_<case>.json`); engine twins, bridges and the design test under `tests/integration/settings/`; retained screenshots and sign-offs under `production/qa/evidence/settings/`, one `Run result:` line each per `.claude/docs/run-and-observe.md`. The suite runs with `commands.test` after `godot --headless --path . --import`. Every unit test constructs `SettingsStore.new(schema, MemorySettingsFile, FakeClock, overrides)` with the null bridge twins; nothing under `tests/unit/` imports from `src/settings/engine/`. Constants are read from `assets/data/settings/schema.json` and `tuning.json`, never inlined, except where the boundary value is the point. Every warning THEN also asserts the message names the key, the value found and the value used, and that one warning is emitted, not one per retry.*

Citations: **PF** = Player Fantasy, **CR§n** = Core Rules, **ST** = States and Transitions, **F§n** = Formulas, **EC n** = Edge Cases, **G** = Tuning Knobs, **UI** = UI Requirements.

**Catalogue and lint** (Logic, BLOCKING; `settings_lint_test.gd`, runs in CI as the build-time lint)

- [ ] **Closed catalogue (CR§1)**: **GIVEN** the shipped `schema.json`, **WHEN** `get`, `set`, `reset`, `bindings` and `subscribe` are called with `ui_scal`, **THEN** each returns `UNKNOWN_KEY`, no value changes and no `changed` fires.
- [ ] **Grammar (CR§1)**: **GIVEN** fixture keys `Audio.master`, `audio.master.left`, `9lives`, `audio.`, **THEN** four lint E, each naming the key; the shipped schema produces none.
- [ ] **Defaults in range and on step (CR§1, EC 22)**: **GIVEN** `ui_scale` default 95, `ui_scale` default 125, `cursor_scale` range 100–190 step 50, **THEN** three E: below range, off step, step does not divide range.
- [ ] **Enum defaults (CR§1)**: **GIVEN** `flicker` default `strobe`, **THEN** one E naming the key and the declared `values`.
- [ ] **Default bindings conflict-free (CR§1, EC 12)**: **GIVEN** the shipped defaults, **THEN** `binding_ok` holds for every name; **GIVEN** `examine` and `reveal` both defaulting to `key:E`, **THEN** one E naming both names.
- [ ] **`deprecated_to` (CR§3, EC 5)**: **GIVEN** `deprecated_to: "ghost"`, an `int` key forwarding to an `enum` key, and the cycle `a → b → a`, **THEN** three E; `a → b → c` with `c` live is clean.
- [ ] **String ids (CR§12, UI)**: **GIVEN** the shipped schema and GDD 2's `en` table, **THEN** `set.<key>.label`, `set.<key>.help`, `set.<key>.value.<v>` for every enum value, and `set.error.<name>` for every error enum member resolve; **GIVEN** `en` with `set.flicker.value.limited` removed, **THEN** one E.
- [ ] **Keys permanent, append-only (CR§3)**: **GIVEN** `fixtures/schema_released.json` (the snapshot of the last shipped `SCHEMA_VERSION`) and a candidate schema that renames `motion`, deletes `captions`, or removes enum value `toggle`, **THEN** three E; one that adds `audio.ambience` and enum value `dwell` is clean.

**Validation** (Logic, BLOCKING; `settings_validate_test.gd`)

- [ ] **`set` rejects by type (CR§5)**: **WHEN** `set("ui_scale", 120.0)`, `set("captions", 1)`, `set("flicker", "strobe")`, `set("ui_scale", 160)`, **THEN** `TYPE`, `TYPE`, `ENUM`, `RANGE`, each with `ok: false`, the stored value unchanged and no `changed`.
- [ ] **Off-step snaps (CR§5, F§1)**: **WHEN** `set("ui_scale", 123)`, **THEN** `ok: true`, `get` returns 120 and `changed("ui_scale", 100, 120)` fires once; `set("ui_scale", 120)` again emits nothing.
- [ ] **`load` clamps and defaults (CR§5)**: **GIVEN** a file with `ui_scale: 170`, `captions: "yes"`, `reveal_mode: "dwell"`, **WHEN** `load()`, **THEN** 150, `true`, `hold`, with exactly three warnings, one per key.
- [ ] **Binding `set` (CR§6, F§2)**: **WHEN** `set("bindings.activate", [])`, four events, three keyboard events, `[mouse:1, key:Enter, key:E]` while `examine` holds `key:E`, `["mouse:ctrl+1"]`, and `[mouse:1]` alone, **THEN** `BINDING_EMPTY`, `BINDING_TOO_MANY`, `BINDING_CLASS_FULL`, `BINDING_DUPLICATE(examine)`, `BINDING_MALFORMED`, `BINDING_EMPTY` (keyboard reach); `[mouse:1, key:Enter, key:Space]` is `ok`.
- [ ] **Codec round-trip (CR§6)**: **GIVEN** `"key:F"`, `"key:ctrl+F"`, `"mouse:1"`, `"pad:button0"`, **THEN** `BindingCodec.parse` then `format` returns the same string, and `"key:"` and `"joystick:3"` are `BINDING_MALFORMED`.
- [ ] **Whole-group reset on load (CR§6, EC 12)**: **GIVEN** a file whose `bindings.examine` is `[mouse:2]` and `bindings.reveal` is a valid remap, **WHEN** `load()`, **THEN** every `bindings.*` equals its default, one warning names `examine` and `BINDING_EMPTY`, and no scalar key is touched.
- [ ] **`set_many` swap (CR§4, EC 11)**: **GIVEN** `examine` = `[key:E]`, `reveal` = `[key:R]`, **WHEN** `set_many` swaps them, **THEN** `ok: true`, both store, `changed` fires for `examine` then `reveal` after both are stored (a handler on `examine` reads `reveal` as `[key:E]`); **WHEN** `set_many` includes one `RANGE` entry, **THEN** nothing stores and `errors` names that entry only.

**Persistence** (Logic, BLOCKING; `settings_persist_test.gd`)

- [ ] **A/B alternation (CR§7)**: **GIVEN** an empty `MemorySettingsFile`, **WHEN** three changes each followed by `flush()`, **THEN** writes go `a`, `b`, `a` with `generation` 1, 2, 3, and each text is `{schema_version, generation, values}` holding only `persist: true` keys.
- [ ] **Highest generation wins (CR§7, EC 3)**: **GIVEN** `.a` at generation 4 and `.b` at 5, **THEN** `.b` loads; **GIVEN** `.b` unparseable, **THEN** `.a` loads with one warning; **GIVEN** `.b` at 5 with a newer `schema_version`, **THEN** `.b` still wins and the next flush rewrites it at the current version.
- [ ] **Equal generations (EC 1)**: **GIVEN** both at 4 with identical text, **THEN** either loads, no warning; **GIVEN** different texts, **THEN** `.a` loads, one warning quotes both generations, and the next write goes to `.b` at 5.
- [ ] **Missing and bad files (CR§8, EC 2)**: **GIVEN** no files, **THEN** defaults, no warning, and `write` count stays 0 until the first changing `set`; **GIVEN** both unparseable, **THEN** defaults, one warning, `rename_bad()` called once, the OS layer recomputed, and the next flush writes generation 1 to `.a`.
- [ ] **Enum from a newer build (EC 4)**: **GIVEN** `reveal_mode: "dwell"`, **THEN** `hold` with a warning and the next flush persists `hold`.
- [ ] **Debounce (CR§7, F§6, ST)**: **GIVEN** `WRITE_DEBOUNCE_MS` 500 and a `FakeClock`, **WHEN** 72 sets arrive at 16.7 ms gaps over 1.2 s, **THEN** 0 writes during the burst and 1 at 500 ms after the last set; `flush()` at 1.3 s writes at once and a second `flush()` writes nothing (clean).
- [ ] **Write failure (EC 14)**: **GIVEN** `MemorySettingsFile` failing the next two writes, **WHEN** `flush()` twice then once more, **THEN** one log line, `generation` unincremented, the other slot's text untouched, state `dirty`, and the third flush succeeds at generation +1.
- [ ] **Never a Resource (CR§7)**: **GIVEN** `src/settings/`, **THEN** a CI grep finds no `ResourceLoader`, `ResourceSaver`, `ConfigFile` or `.tres` reference, and the written text parses with `JSON.parse_string`.

**Versioning and migration** (Logic, BLOCKING; `settings_migrate_test.gd`)

- [ ] **Older with chain (CR§8, EC 5)**: **GIVEN** `fixtures/schema_v3.json` where `a → b → c`, and a version-1 file holding `a: 7` and no `c`, **WHEN** `migrate`, **THEN** `c` is 7, `b` absent; **GIVEN** `c: 2` already present, **THEN** `c` stays 2; then Rule 5 validation runs on the result.
- [ ] **Newer file (CR§8)**: **GIVEN** `schema_version` current +1 with `unknown_key: 3` and valid known keys, **THEN** known keys load, one warning per dropped key, and the next flush writes the current version without `unknown_key`.
- [ ] **Equal version (CR§8)**: **GIVEN** a current-version file, **THEN** `migrate` returns it byte-equal and no warning fires.

**Layers** (Logic, BLOCKING; `settings_layers_test.gd`, OS probe injected as a null twin)

- [ ] **Precedence (CR§9)**: **GIVEN** default `full`, OS reduced motion, persisted `motion: full`, override `motion=reduced`, **THEN** `get` returns `reduced` and the layer label is `launch flag`; remove the override → `full` / `yours`; remove the file → `reduced` / `system`; no OS report → `full` / `default`.
- [ ] **OS layer first run only (CR§9, EC 10, F§5)**: **GIVEN** no files and OS `de_DE` with reduced motion, shipped {en}, **THEN** `locale` `en`, `motion` `reduced`, `flicker` `off`, all persisted on the first flush; **GIVEN** a file holding static defaults, **THEN** the OS report is ignored.
- [ ] **Override never persisted (CR§9, EC 7–9)**: **GIVEN** `--setting ui_scale=140`, **WHEN** `flush()`, **THEN** the written `ui_scale` is the persisted value, `set("ui_scale", 120)` returns `OVERRIDDEN` with no `changed`; `--setting nope=1` warns once and starts; `--setting bindings.examine=key:E,key:ctrl+E` validates against the loaded group and locks the name.
- [ ] **Reset-all skips overrides (EC 16)**: **GIVEN** `ui_scale` overridden and three other keys changed, **WHEN** `reset("all")`, **THEN** three `changed`, then `reset_done`, the warning lists `ui_scale`, the lock remains.

**Change propagation** (Logic, BLOCKING; `settings_signals_test.gd`)

- [ ] **Synchronous after store (CR§10)**: **GIVEN** a handler that reads `get(key)`, **WHEN** `set("cursor_scale", 150)`, **THEN** the handler sees 150 before `set` returns, with `old` 100; a second identical `set` emits nothing.
- [ ] **Connection order (CR§10)**: **GIVEN** handlers A, B, C subscribed in that order, **THEN** they run A, B, C on every emission.
- [ ] **Nested `set` (EC 17)**: **GIVEN** a handler calling `set("captions", false)`, **THEN** the nested call returns `NOT_READY`, `captions` is unchanged and later handlers still receive the outer `changed`.
- [ ] **Lifecycle (ST, EC 15)**: **GIVEN** a store before `load()`, **THEN** `set` returns `NOT_READY` and release-mode `get` returns the schema default with one warning; **WHEN** `load()`, **THEN** no `changed` fires; after the final `flush()` and `close()`, `set` returns `NOT_READY`.

**Headless and seams** (Integration, BLOCKING; `tests/integration/settings/seams_test.gd` and `tools/ci/path-check`)

- [ ] **No tree imports (CR§11, CR§13)**: **GIVEN** `src/settings/`, **THEN** the CI path check passes, and fails on a fixture adding `extends Node` to `settings_store.gd`, on `src/dossier/` importing `SettingsReader`, and on `src/ui/room/` importing `SettingsStore` (EC 23).
- [ ] **Null twins record (CR§11)**: **WHEN** `applier.apply_all()` against null bridges, **THEN** each twin's dictionary holds one entry per bridged key with the loaded value, and a later `set("vsync", false)` adds exactly one entry.
- [ ] **Design test (PF)**: **GIVEN** the simulator with a fixed choice script, **WHEN** run with every key at default and again with every key at its opposite (enum: last value, bool: negated, int: `hi`), **THEN** the dossiers, attention traces and ending state are byte-equal.

**Bridges** (Integration, BLOCKING; engine twins under `tests/integration/settings/`)

- [ ] **Audio (CR§11, SOURCED)**: **GIVEN** `audio.music` 80 and Audio's injected curve, **WHEN** applied, **THEN** the `Music` bus volume equals `curve(80)` and 0 sets mute; the null twin records the same pair.
- [ ] **Input and display (CR§11, NOT SOURCEABLE)**: **GIVEN** `bindings.examine` remapped to `key:X` and `window_mode` `borderless`, **WHEN** the game runs, **THEN** X examines and the window is borderless; evidence is a `Run result:` line and screenshot `bridges-01.png`, blocking once the spike lands.

**Sheet and accessibility** (UI, BLOCKING; run-and-observe, `production/qa/evidence/settings/`)

- [ ] **Scale (CR§2, F§4)**: **GIVEN** a 720 window, **THEN** `sheet-100.png` and `sheet-150.png` show body text at 18 and 27 px with no clipped field; hit rects unchanged (GDD 3 Rule 9).
- [ ] **Timer line and reset (PF, CR§12)**: **THEN** `timer-line.png` shows `INTERROGATION TIMER: [ OFF ] [ 2× ] [ DEFAULT ]` with exactly one bracket double-struck, `[ RESET ]` struck VOID beside a key at default and plain beside a changed one.
- [ ] **Capture mode (CR§12)**: **WHEN** capture is entered and Esc pressed, **THEN** `capture-esc.png` shows the prior binding intact and the prompt gone.
- [ ] **First-run slip (CR§12)**: **GIVEN** no files, **THEN** `slip.png` shows `[ SETTINGS: BACK PAGE ]` on the title sheet; it persists across 60 s idle, and `first_run_seen` is flushed on dismissal (EC 13).
- [ ] **Exemptions (PF)**: **THEN** `sheet-confident.png` and `sheet-collapsing.png` are pixel-identical in the sheet region and show no surveillance stamp; art director sign-off line attached.
- [ ] **Keyboard and roles (CR§12, UI)**: **THEN** every key is changed by keyboard alone (`keyboard-pass.md` lists each key, keys pressed, before/after); a screen-reader transcript shows checkbox, radio group, slider with numeral and capture button roles; `design/accessibility-requirements.md` exists at that path.

**Formulas** (Logic, BLOCKING; `settings_formulas_<n>_test.gd`)

- [ ] **F§1**: **GIVEN** `ui_scale` 100–150 step 10, **THEN** 123 → 120, 149 → 150, 95 → 100, 999 → 150.
- [ ] **F§2**: **GIVEN** `activate` = `[mouse:1, key:Enter, key:Space]`, **THEN** ok; plus `key:E` held by `examine` → `BINDING_DUPLICATE(examine)`; reason order `EMPTY, TOO_MANY, CLASS_FULL, DUPLICATE, MALFORMED` holds for a fixture failing all five.
- [ ] **F§3**: **GIVEN** 2 flashes in 1.0 s, **THEN** ok; 4 → not ok; `FLASH_MAX_PER_S` 4 in a schema fixture → lint E.
- [ ] **F§4**: **GIVEN** base 18 at 100, 150; base 15 at 100; base 10 at 100, **THEN** 18, 27, 15, 15.
- [ ] **F§5**: **GIVEN** (null, `de_DE`, {en}) → `en`; (`de`, any, {en}) → `en` with warning; (null, `pt_BR`, {en, pt}) → `pt`; (`en`, `de_DE`, {en, de}) → `en`.
- [ ] **F§6**: **GIVEN** sets at 0, 100, 1200 ms, **THEN** `write_at` 1700 and one write; sets at 0 and 600 → two writes.

**Performance** (`tests/performance/settings/`, reported per run; blocking only on the reference machine, all budgets to be confirmed by the technical director)

- [ ] **Budgets**: **GIVEN** the shipped schema and 10 subscribers, **THEN** median `get` ≤ 1 µs, `set` ≤ 20 µs, `changed` dispatch ≤ 50 µs, `write` ≤ 5 ms, `load` of a full pair ≤ 20 ms, schema parse and lint ≤ 5 ms.

**MVP gate**: every Logic group above except Bridges' input/display row and the Design test; Sheet rows `sheet-100/150`, `timer-line`, `capture-esc`, `slip`, `keyboard-pass`; Audio bridge. **Vertical Slice remainder**: the Design test (needs the simulator, dossier, attention and Dialogue), `sheet-confident/collapsing` (needs Overlay's phase ink), the screen-reader transcript, input and display bridges (after the spike), and the performance budgets on the named machine.

## Open Questions

| Question | Owner | Needed by | Status |
|---|---|---|---|
| Engine spike (NOT SOURCEABLE): the user profile directory's per-platform location; a rename or directory API for temp-and-rename writes (until then the A/B pair); `JSON.parse_string` limits; the input map's runtime remap API and physical-versus-unicode keycode naming; the OS locale and reduced-motion queries; the display server's window mode and vsync calls | technical-director, engine-programmer | Before the store's ADR; shares the spike with GDDs 2 and 3 | Open |
| The settings sheet's exemption from art bible §7.5's surveillance stamp and from phase styling | art-director (edits `design/art/art-bible.md` with the user's approval) | Before `/ux-design` of the sheet | Open; requested, not made |
| The head line *nothing in this room needs a steady hand*: the one sentence addressed to the player | narrative-director (approve and localise) | Before the text freeze | Open |
| `window_mode` default `windowed` at first run (so a screen-reader window stays visible) | technical-director, art-director | Before the display spike | Open; this GDD's default stands until overruled |
| How `timer_mode: off` keeps the silence outcome available as an explicit choice | Dialogue & Interrogation GDD | Vertical Slice | Open; Player Fantasy requires it |
| Whether WCAG 1.4.4 (200% text) and 2.5.8 (target size for paper Controls) are formal targets; the floor for label text (15 vs 16 px) | accessibility-specialist via `/ux-design accessibility` (creates `design/accessibility-requirements.md`) | Before this GDD's acceptance criteria are checked | Open |
| `design/accessibility-requirements.md` does not exist; this GDD's inputs to it are listed in Dependencies | accessibility-specialist | Before `/gate-check technical-setup` | Open |
| `assets/data/input_actions.json` does not exist yet; GDD 3's ten action names are its content | gameplay-programmer, at Technical Setup | Before the input bridge | Open |
| The `voice` audio bus is reserved pending the audio director's cue spec | audio-director | Audio GDD | Open |
| Performance budgets proposed in Acceptance Criteria | technical-director | ADR | To be confirmed |
