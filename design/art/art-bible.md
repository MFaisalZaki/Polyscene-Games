# Art Bible: Paper Walls

> **Status**: Draft
> **Owned By**: art-director
> **Last Updated**: 2026-11-02
> **Art Director Sign-Off (AD-ART-BIBLE)**: [Not yet reviewed]

`/art-bible` writes these nine sections in this order and replaces each
section's `[To be designed]` line as that section is approved. A section still
holding its placeholder is incomplete; a later run fills only those.

## 1. Visual Identity Statement

**Anchor:** Carbon Copy (hybrid) — *everything is paperwork.* Confirmed at AD-CONCEPT-VISUAL (STRONG) and again at this session; this section builds on it and does not reopen it.

### 1.1 The one-line rule

> **If the state could not file it, do not draw it.**

Every frame of *Paper Walls* — plate, prop, figure, UI, transition — must look like something that could be stapled into a dossier: typed, stamped, carbon-pressed, folded, redacted. The dossier is the game's central object (Unique Hook §1: "the state's knowledge is a visible, changing object"), so the world is rendered the way the dossier is rendered and the player never leaves the document. The rule resolves ambiguity by subtraction: when two treatments compete, keep the one that survives being photocopied onto onionskin. It is also the strictest filter the AI paint-over pipeline can be given — a generated asset that looks like a painting, a photograph or a render is a defect, not a style choice, and the reviewer need not argue taste to reject it.

### 1.2 Supporting principles

**Principle A — Attention has a colour.** *Serves Pillar 5 (pressure comes from attention, not reflexes) and Pillar 2 (the state is a character).*
Stamp red is the only saturated red in the game and it belongs to the state alone. It appears when the regime is looking and spreads as surveillance rises — UI margin, then prop, then key light. Outdoors the same principle takes the Sodium Light form: sodium orange is state light, incandescent amber is private light, and darkness is the only privacy; interiors stay paper-neutral, warm light is a desk lamp and never the sun. Merging the red rule and the lighting rule makes them one grammar, so the player learns a single lesson — *coloured light and red ink both mean someone is watching* — and tension can be read off the frame without a meter.
*Design test:* when it is ambiguous whether something should be red (or sodium-lit), ask whether the state is looking at it right now; if not, it is not.

**Principle B — Two paper languages, one wall.** *Serves Pillar 4 (consequences cross lives) and Pillar 1 (every fact is a weapon).*
State paper is typed, gridded, stamped, carbon-blue; people's paper is hand-set, misregistered, smudged, drawing on the Polish/Czech poster school for the dissident's samizdat sub-vocabulary only. The archivist's chapters lean state paper, the dissident's lean people's paper, the conscript's pin both to the same wall. Each protagonist owns one secondary ink (archivist grey-green, dissident soot black, conscript khaki), so a consequence arriving from another chapter is drawn as a literal overprint — one person's ink on another person's page. Because every fact must have a dossier use, every document on screen carries a readable name, date or stamp; there is no flavour paper.
*Design test:* when it is ambiguous which language a surface belongs to, ask who made it — the state types, people hand-set — and if it carries another chapter's consequence, it is both, overprinted.

**Principle C — People are the only soft things.** *Serves Pillar 3 (no one is clean).*
Architecture, furniture, vehicles and UI are rectilinear and stacked, like filing. Figures are thin, stooped and rounded — the softest shape in a hard room, and the only thing in it that can be bent. No protagonist is drawn heroic; the silhouette says *complicit and vulnerable*, never *chosen*. This is the character read of *The Lives of Others*: people as the one organic thing in a system of boxes.
*Design test:* when it is ambiguous whether a shape should be hard or soft, ask whether it is a person or weather; if not, it is rectilinear.

### 1.3 Alternatives considered

- **Pure Sodium Light (cinematic realism).** Rejected: it makes the dossier a UI overlay on a filmed world, breaking Hook §1; it also invites golden-hour sun and photographic drift from AI generation.
- **Pure poster school.** Rejected: hero-saturated primaries and graphic heroism give the dissident's voice to the whole game, contradicting Pillar 3's even-handedness; it survives only as the samizdat sub-vocabulary.
- **Moral colour coding (warm = good, cold = bad).** Rejected outright by the *not a morality meter* anti-pillar; colour here encodes who is watching, never who is right.
- **Per-protagonist palettes.** Rejected in favour of per-protagonist inks on a shared paper palette, so cross-chapter payoffs can be seen on one page instead of implied across three.

## 2. Mood & Atmosphere

Two rules make every state distinct and keep AI-generated plates on-model. **One state, one light source** — each state owns a lighting recipe and no plate mixes two. **Red reaches further as the state's attention rises** (Principle A) — so the same room is a different room in week one and week five. Every plate is tagged with its state and regime phase and reviewed against the tables below; a "dark and foreboding" plate with the wrong light source is a defect.

### 2.1 Game states

| State | Emotional target | Lighting character | Descriptors | Energy | Mood carrier |
|---|---|---|---|---|---|
| **Investigation** | Patient scrutiny: a room that will remember you were here. | One desk/table lamp, incandescent amber, low side angle, a pool over the working surface; rest of plate paper-neutral and flat; medium contrast; window blank bone (overcast) or soot (night), never sun. | still, dusty, close, legible, unhurried | Lowest | The lamp pool. Hotspots are a lifted paper corner or a hard-edged object — never a glow (Pillar 5: think as long as you like). |
| **Conversation / interrogation** | Conversation: two people measuring what the other knows. Interrogation: being read faster than you can read. | Conversation keeps the lamp. Interrogation switches to a single overhead source: frontal, hard shadow under the brow, high contrast, portrait crop tightening as the timer runs. | airless, frontal, pinned, ticking | Medium-high — the only state with a pulse. | The timer: a stamp-red margin filling the page edge. Never a clock face. |
| **Filing / decision** | Cold ceremony: the weight of a signature. | Scanner-flat, shadowless — the most even frame in the game; the plate fades to onionskin behind the document. | flat, formal, silent, irreversible | Low and heavy. | The act itself at full frame: stamp impression, fold, match, carbon sheet. |
| **Dossier review** | Archivist: possession. Dissident: dread by inference. Conscript: instruction without context. | No light at all — pure paper surface, bone at full value. | archival / fragmentary / imperative | Low | Archivist: the typed file, carbon-blue grid. Dissident: no typed paper, only signs — torn corner, chalk mark, misregistered notice, a gap where a name should be. Conscript: one order sheet, khaki stencil, a list of names. Cross-chapter consequences are overprinted ink (Pillar 4). |
| **Reactive event** | The floor goes: the state has arrived. | The room's light source is replaced abruptly — torch beam through the door, sodium through the window, a 3 a.m. phone under one bare bulb; hard shadow cast from the threshold; highest contrast. | sudden, intrusive, hard, loud-silent | High — in the frame, never in the controls (Pillar 5). | The threshold line (door frame, window frame, phone cord) with red crossing it at the phase's reach: a stamp on the door, a red phone, red key light. |
| **Exterior / street** | Exposure: seen from windows you cannot see into. | Night or overcast dusk; wet-concrete darkness; sodium cones from poles, amber rectangles from windows; no sun; rain, breath and smoke are the only weather. | wet, pooled, sparse, watched, cold | Low-medium | Light pools are the only colour in the frame (Sodium Light rule). |
| **Calendar transition** | Time passes without you. | Flat paper: tear-off wall calendar, date stamp, dossier change notices. | brisk, dated, torn, clerical | A short medium beat. | The date stamp; its ink reach follows the phase. |
| **Menus / epilogue** | Menus: before the file is opened. Epilogue: quiet verdict. | Flat. Menu is a closed dossier cover, typed title. Epilogue is the file's last page and its closing stamp (ARCHIVED / DESTROYED / RELEASED by outcome — narrative-director to confirm the outcome classes), then the lamp pool going out. | closed, still, final | Lowest | The cover and the closing stamp. No triumphant colour on any ending (Pillar 3). |

### 2.2 The four regime phases

The progression is read on three axes: **red reach**, **paper order**, **light evenness**. The grid never tilts; the state's shapes outlast it.

| Phase | Red reach | Paper order | Light | Mood in one word |
|---|---|---|---|---|
| **Confident** (wk 1–2) | UI margin and official stamps only. | State paper perfectly gridded and sparse. | Even; overhead in state spaces; lamps in private ones. | Tidy. |
| **Paranoid** (wk 2–3) | Props: a red phone, folder, pen. | Density doubles; carbon copies multiply (more blue). | Lamps lowered — more pools, fewer evenly lit rooms. | Counting. |
| **Panicking** (wk 4–5) | Key light in state spaces and in every reactive event. | The state's own typing misregisters; stacks lean; shredder strips appear. | Hard; overhead flicker in portraits. | Noise. |
| **Collapsing** (wk 6) | Withdraws: stamps unanswered, sodium poles dark one by one. | Paper loose in the street; oil drums burn (amber — private light, now public). | Darkness spreads — the only privacy, now everywhere, and it is not comfort. | Ash. |

### 2.3 Alternatives considered

- **Time-of-day progression** (dawn to night across six weeks). Rejected: sun is forbidden, and it makes the clock the character instead of the state (Pillar 2).
- **Desaturation toward collapse.** Rejected: the palette is already low-saturation; instead red withdraws and soot grows, so collapse looks like absence, not fade.
- **Per-protagonist moods.** Rejected: mood belongs to state and phase; protagonists differ by ink and paper language (§4), so a consequence crossing chapters lands in a recognisably shared world (Pillar 4).

## 3. Shape Language

### 3.1 Three shape classes

Everything on screen belongs to one of three classes. **Paper**: rectangles with tabs, folds, tears — hard edges, flat. **Furniture**: stacked rectilinear boxes — shelving, drawers, radiators, window bars, vehicles, facades. **People and weather**: the only curves (Principle C). Round shapes are permitted elsewhere only where paperwork already has them — a seal, a telephone dial, a clock face — and must look printed, never volumetric. *Reviewer test:* fill the plate black; any curve that is not a person, smoke, rain, breath or a printed circle is a defect.

### 3.2 Character silhouettes

Base figure: about six heads tall, narrow shoulders, no muscle mass, a forward stoop at the neck, rounded shoulders and coat hems, hands always visible (hands file, burn, sign). *Thumbnail test:* a 64 px black fill must identify the archetype by one trait and nothing else. Portraits use ID-photo framing — frontal, flat, cropped at the collar — so even the player's own face looks filed (the one-line rule).

- **Archivist** — a rectangle held against the chest: files carried. The only soft figure with a hard shape attached. *Says:* she holds the state's shapes close; knowledge as burden (Pillar 1).
- **Dissident** — no neck: collar up, scarf, shoulders lifted, hands in pockets; the narrowest, most closed outline. *Says:* hiding in plain sight, and cold.
- **Conscript** — one straight edge in the silhouette: cap peak and greatcoat hem are rectilinear, the body stoops inside them. *Says:* a uniform trying to turn a person into furniture, and failing (Pillar 3).
- **State officials** — the most upright, with a horizontal line (hat brim) and a briefcase; still thin, never bulky. Power is shown by stillness and position — centred, seated, behind a desk — never by mass. *Says:* people halfway to becoming furniture (Pillar 2).
- **Informers** — identical to citizens in silhouette. The only tell is ink: a carbon-blue overprint on their portrait once the player holds the fact. *Says:* no one is clean and you cannot see it (Pillars 1 and 3).
- **Ordinary citizens** — the most stooped; a load carried low in the hand (bag, bucket, bundle); queue posture. *Says:* endurance.

Forbidden: heroic stance, wide shoulders, dynamic poses, any silhouette that reads as "chosen". Animation vocabulary is walking, sitting, handing over, turning a page.

### 3.3 Environment geometry

Isometric plates on the iso axis only; no diagonal that is not the iso axis; stacked horizontals everywhere. **State spaces** are repeated identical units — shelving rows, numbered doors, benches: the grid. **Private spaces** are the same rectangles piled and leaning — books, plates, crates: accumulation. The dissident's print shop is misregistered rectangles. The street is facades as filing cabinets, windows as drawers. Doorways, windows and the telephone are drawn as thick hard **thresholds**, because reactive events enter through them (§2.1). *Says:* the city is a cabinet and you live in a drawer (Pillar 2). *Emotional read:* order is the state's, clutter is yours, and neither is safe.

### 3.4 Hero vs supporting shapes

Each plate has one hero class at a time: the object with a fact in it (Pillar 1). Hero = hardest edge, highest local contrast, bone paper at full value, a lifted corner. Supporting = inside the plate's midtone band, lower contrast (never softer *shape*), repeated. People sit at the second-highest contrast — always hero-adjacent, never background. The dossier folder with its tab is the hero shape of the whole game, and the tab is the UI's signature.

### 3.5 UI shape grammar

The UI echoes the world because the player never leaves the document (Hook §1). Panels are sheets with tabs and staples; buttons are typed brackets or stamp impressions; hover is a corner lift; selected is stamped; disabled is a redaction bar; the timer is a margin filling. No rounded corners, glass, glow, or drop shadow into the plate. Where the UI stands apart is not shape but treatment: it is the only perfectly aligned, unlit layer, and it never takes the plate's lamp or sodium. The three dossier views differ in grammar — archivist: gridded form; dissident: pinboard of torn fragments; conscript: a single list sheet.

### 3.6 Alternatives considered

- **Stylised big-head proportions.** Rejected: reads comic and undercuts complicity; the figure must be able to look ashamed.
- **Tilted or Dutch angles for tension.** Rejected: tension is carried by red and light (§2, §4), not geometry; the grid never tilts even in collapse.
- **A distinct modern UI layer.** Rejected: breaks the one-line rule and Hook §1; the dossier is the interface.

## 4. Color System

[To be designed] — a primary palette of 5–7 colours with their meaning in this
world, semantic colour usage, per-area colour temperature rules, the UI palette
and where it diverges, and colourblind safety: which semantic colours need a
shape, icon or sound backup.

## 5. Character Design Direction

[To be designed] — the player character's visual archetype, how players tell
enemies, NPCs and allies apart at a glance, expression and pose style, and how
much detail survives at game camera distance (LOD philosophy).

## 6. Environment Design Language

[To be designed] — architectural style and its tie to the world's culture,
texture philosophy (painted, PBR or stylised, and why), prop density rules per
area type, and environmental storytelling guidelines.

## 7. UI/HUD Visual Direction

[To be designed] — diegetic versus screen-space HUD, typography (personality,
weight, size hierarchy, minimum readable size), iconography style, UI animation
feel, and any art-direction versus readability conflict and how it was decided.

## 8. Asset Standards

[To be designed] — file formats, naming convention, texture resolution tiers,
LOD levels, export settings, and the engine's hard limits (poly budgets per
asset category, texture memory, material slots). Where an art preference and a
technical limit disagree, record both and the trade-off chosen.

## 9. Reference Direction

[To be designed] — 3–5 references (games, films, art styles or artists). For
each: the specific element to take from it, and what to avoid so the result
does not read as a copy.
