# Art Bible: Paper Walls

> **Status**: Draft
> **Owned By**: art-director
> **Last Updated**: 2026-11-03
> **Art Director Sign-Off (AD-ART-BIBLE)**: REVISED 2026-11-03 — CONCERNS C1–C8 and minor items applied (autonomous mode; see production/session-logs/decision-log.md); focused re-check of §5, §6.4, §7.6 pending

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

The UI echoes the world because the player never leaves the document (Hook §1). Panels are sheets with tabs and staples; buttons are typed brackets or stamp impressions; focus (hover, keyboard or gamepad cursor) is a corner lift; selected is stamped; disabled is a greyed typed bracket struck through VOID (redaction bars are content only — amended per §7.6 C3); the timer is a margin filling. No rounded corners, glass, glow, or drop shadow into the plate. Where the UI stands apart is not shape but treatment: it is the only perfectly aligned, unlit layer, and it never takes the plate's lamp or sodium. The three dossier views differ in grammar — archivist: gridded form; dissident: pinboard of torn fragments; conscript: a single list sheet.

### 3.6 Alternatives considered

- **Stylised big-head proportions.** Rejected: reads comic and undercuts complicity; the figure must be able to look ashamed.
- **Tilted or Dutch angles for tension.** Rejected: tension is carried by red and light (§2, §4), not geometry; the grid never tilts even in collapse.
- **A distinct modern UI layer.** Rejected: breaks the one-line rule and Hook §1; the dossier is the interface.

## 4. Color System

### 4.1 Primary palette

Seven colours; everything else is a tint of one of them. Plate midtones sit in the 20–60% value band (the concept's rule, read as a rule for plate midtones); bone reaches its full value only under a lamp and in the UI; soot only in true darkness.

| Colour | Hex | Role and meaning |
|---|---|---|
| **Bone** | `#D8CDB2` | Paper; lamp-lit interior surfaces; UI base. The page everything is written on. |
| **Wet-concrete grey** | `#585A57` | Street, facade, the state's exterior, night base. The city as cabinet. |
| **Nicotine ochre** | `#8F7748` | Private interiors: varnish, smoke-stained wallpaper, the bar. Lived-in space. |
| **Grey-green** | `#6B7664` | State interiors (archive, ministry, corridor paint) and the archivist's ink. Institutional — she writes in the state's colour. |
| **Carbon blue/violet** | `#434C7C` | The copy: anything the state has a duplicate of. Traceable. |
| **Stamp red** | `#B5241C` | The state's attention. The only saturated red (Principle A). |
| **Soot black** | `#1B1917` | Ink, darkness, the dissident's ink. The unfiled; the only privacy. |

Secondary (light and ink): **incandescent amber** `#DDB065` (private light), **sodium orange** `#D4862A` (state light), **conscript khaki** `#8A7C4A` (orders ink). Forbidden: any other saturated hue, blue sky, golden-hour, any gradient that is not lamp falloff.

### 4.2 Semantic usage

- **Stamp red = the state is looking now.** Never on skin or clothing, never in people's paper, never decorative. Its reach follows the phase (§2.2); red on a document means the state is reading it at this moment.
- **Carbon blue = filed.** A fact turns blue when filed; a copied document carries a blue double-strike ghost. The archivist's dossier view is blue-dominant.
- **Three inks, three letterforms.** Archivist grey-green *cursive annotation*; dissident soot *hand-set block*; conscript khaki *stencil capitals*. A cross-chapter consequence is that chapter's ink, in its letterform, overprinted on this chapter's page (Principle B, Pillar 4).
- **Neutrals locate space.** Bone = paper and lamp-lit rooms; ochre = private; grey-green = state interior; concrete = outside.
- **Light.** Amber = private; sodium = state; soot = privacy.

### 4.3 Temperature by area

- **Interiors** are neutral; warmth comes only from lamp pools; windows are bone (day) or soot (night), never blue.
- **State spaces** are cool: grey-green walls, bone paper, carbon blue, even overhead light. **Private spaces** are warm: ochre, amber, pooled.
- **Exteriors** default to night or dusk: concrete base, sodium cones, amber window rectangles. Overcast day is allowed sparingly — flat bone-grey, no pools, no shadows: everyone visible, no one lit.
- **Phase budgets** (red as share of frame, checkable on any plate; technical-artist to confirm they can be measured on export): Confident ≤2%, margin and stamps only; Paranoid ≤5%, on props, blue rising; Panicking ≤15%, tinting state key light, hard light; Collapsing ≤1%, sodium off, amber loose in the street, soot above 40% of frame.

### 4.4 UI palette and where it diverges

UI base is full-value bone `#EDE4CC` with soot text; carbon blue for interactive and linkable facts — **as text, the darker UI tint `#2E3559` of carbon** (measured 9.4:1 on UI bone; the world carbon `#434C7C` measures 6.5:1 and fails the §7.2 text rule, AD-ART-BIBLE C4) (clicking a fact files it, so world meaning and UI meaning converge); stamp red only for state attention — timer margin, surveillance indicator — never as a generic error or danger colour; protagonist inks for annotation. The divergence is **value, not hue**: UI runs at full bone and pure soot (about 13:1 contrast), higher than any plate; it never takes lamp or sodium tint; it contains no ochre or concrete. Per view: archivist bone + blue; dissident bone + soot with torn edges; conscript bone + khaki.

### 4.5 Colourblind safety

No semantic colour carries meaning alone; each has a shape backup, and the two attention states have an audio backup (audio-director to specify).

| Pair | Who it fails | Backup |
|---|---|---|
| Stamp red vs grey-green (ink or wall) | Protan, deutan: red reads brown, green reads grey, they merge. | Red is always a geometric stamp or bar with a bordered edge and hatching; grey-green ink is always cursive. Never red text on a grey-green field. |
| Stamp red vs ochre / khaki | Protan: red darkens to brown. | Red stamps sit on a bone field; khaki is stencil. Timer = margin fill + portrait crop tightening + audio cue. |
| Sodium vs amber | Everyone (near hues), worst for deutan. | Shape of pool: state = cone from a pole onto the ground; private = rectangle on a wall from a window. No exceptions. |
| Carbon blue vs soot | Tritan, low vision. | Filed = double-struck ghost plus a "cc" mark; unfiled = single strike. |
| Grey-green vs khaki inks | Deutan. | Letterform (cursive vs stencil) plus the chapter tab on the page. |

Text contrast (WCAG relative luminance, measured): soot on UI bone 13.8:1, soot on plate bone 11:1, carbon text tint `#2E3559` on UI bone 9.4:1 (world carbon `#434C7C` is 6.5:1 and is not used for text). An accessibility toggle that renders stamp red as hatching only is a ux-designer item, supplementary to these defaults.

### 4.6 Alternatives considered

- **A hue per protagonist.** Rejected in §1.3; inks on shared paper keep cross-chapter overprints legible on one page.
- **Colourblind palette swap as the primary fix.** Rejected: shape backups make the default mode safe; a swap is a supplement, not the answer.
- **Semantic green for "safe".** Rejected: nowhere is safe (Pillar 3), and it would collide with grey-green ink.

## 5. Character Design Direction

### 5.1 The three protagonists

Each protagonist keeps the one silhouette trait of §3.2 and adds exactly one costume accent in their own ink (§4.2); the rest of the costume is a tint of bone or concrete so the figure never merges with a wall of its own ink colour (the archivist works in grey-green rooms). *Checkable:* ink accent ≤ 15% of costume area; costume dominant differs from the plate's dominant neutral by ≥ 20% value. Names and ages below are proposals for narrative-director to confirm.

- **Archivist** (woman, ~40). Buttoned paper-grey cardigan, skirt below the knee, flat shoes, hair pinned flat; accent: grey-green sleeve protectors. Props: the file held to the chest with both hands, pencil behind the ear. Face: tired, precise, mouth closed; she looks at the lens.
- **Dissident** (man, ~28). Soot overcoat, collar up, scarf; accent: soot-stained fingers (ink is his trade, visible in portrait only). No props carried openly; hands in pockets except when handing over. Face: unshaven; his Neutral portrait meets the lens like everyone else's (AD-ART-BIBLE C1: looking away is a *state*, never a permanent trait), so his tell is the ink-stained fingers alone.
- **Conscript** (boy, ~19). Greatcoat one size too big, cap peak level; accent: khaki stencilled number on the collar tab. Prop: a folded order sheet, one corner showing from the breast pocket. Face: unlined, too open.

All three traits are bilaterally symmetric (file centred, scarf even, cap frontal) so the West facing can be mirrored from East (three directions authored, N/S/E, per §8.7 T8) without a prop changing hands.

### 5.2 Telling types apart at a glance

One straight-edge count per type, checkable on the 64 px fill, **counting costume and body only — carried props (the archivist's file, an official's briefcase) never count** (AD-ART-BIBLE C2): officials ≥ 2 straight edges (hat brim and a straight column of visible coat buttons; the briefcase is an extra prop, not a tally item; no load carried low); conscript exactly 1 (cap peak or greatcoat hem, §3.2); protagonists, citizens and informers 0. Citizens always carry something below the hip (bag, bucket, bundle) and wear a headscarf or flat cap; protagonists never carry below the hip. **Informers are drawn as citizens with no variation at all** (§3.2); the tell is applied in-engine, never painted: once the player holds the fact, the portrait receives a carbon-blue duplicate of its own outline offset 2–3 px down-right plus a "cc" mark in the lower-right corner — the same filed mark as §4.5 — so "informer" and "filed" are literally one mark. The plate-scale figure is never marked: the walking city cannot be read, only the file can.

Background figures painted into a plate (queues) are permitted only as non-interactive, still, and inside the plate's midtone band; an interactive figure sits at second-highest contrast (§3.4) and is always a separate layer.

### 5.3 Expression and pose

Target: **stiff bodies, restrained faces** — not stylised-exaggerated (rejected in §3.6: a comic figure cannot look ashamed), not photoreal (invites photographic drift). Bodies use only the §3.2 vocabulary plus standing idle; no gesture above the shoulder except handing over; weight always on both feet. Faces change through gaze, chin angle and mouth only; brows move one notch; no drawn tears, no open-mouth shouting. Pillar 3 is carried by the eyes looking away, not by acting.

### 5.4 Portraits

ID-photo framing (§3.2): frontal, cropped at the collar, head 60–70% of frame height, eyes on the upper-third line, bone background, stapled corner, drawn scanner-flat. State lighting (interrogation overhead, reactive torch) and the §2.1 crop tightening are layers applied by technical-artist, never repainted, so every portrait is painted with 20% bleed beyond its crop. **Four states per named character, protagonists included**, each defined by a checkable pose, not an adjective:

| State | Gaze | Chin | Mouth |
|---|---|---|---|
| Neutral | to lens | level | closed |
| Guarded | to lens | down 5° | tightened |
| Evasive | off-lens, side | level | closed |
| Exposed | down | down | parted |

Budget: 12 × 4 = 48 portraits core, 72 at stretch (from the concept's ~12 named characters in the 3-act core, ~18 with stretch acts); the informer overprint is a layer, not a fifth state.

### 5.5 LOD philosophy and the presentation decision

On a plate a standing figure is 15–20% of plate height. At that size only the silhouette trait, costume dominant, ink accent, head direction and hands survive; eyes are two marks, mouths are absent, buttons are one line. No fact lives on a figure at plate scale — facts are read in portraits and documents (Pillar 1). Figures and hero objects carry a 2 px soot keyline at 1080 (≈1.33 px at 720; amended from 1 px per §8.8 — people are drawn, so printed); supporting props carry none.

Rules that hold under **both** MVP outcomes: §5.1–5.4, keyline, contrast position, symmetry. Rules that change:

- **Walking avatars (2–4 directions):** protagonists get walk × directions (mirroring allowed), idle, sit, hand-over, page-turn; named NPCs get idle (one facing) and sit only — nobody but the player walks. Symmetry (§5.1) becomes a hard rule.
- **Hotspot plates with cuts and portraits:** no walk cycles; each named character is a per-scene plate layer (standing or seated, one pose per scene state) that can be removed when dossier state says they are absent; the player's own figure is never shown; portraits carry all expression. Symmetry becomes advisory. Plate-scale detail stays identical in both so a later switch costs nothing.

### 5.6 Alternatives considered

- **A full expression sheet (8–12 states).** Rejected: doubles the largest unbudgeted cost (Risks) for differences the four-state table already reads.
- **Marking informers on the plate figure.** Rejected: "you cannot see it" (§3.2) is the point.
- **Per-character colour accents beyond the inks.** Rejected: any new hue breaks §4.1.

## 6. Environment Design Language

### 6.1 Architecture and the city's history

An invented city of a late-socialist state in its last six weeks: real texture, fictional facts (anti-pillar). Three strata, read as three kinds of filing: an imperial-era core of stucco tenements and courtyards, now grey, with former ballrooms and banks holding archives — shelving rows inside moulded ceilings; an inter-war modernist ministry block, the state's own shape — ribbon windows, numbered doors; and prefab panel estates at the edge, drawers stacked ten high. History shows as overpainting, never as plaques: old shop lettering under state paint, a filled bullet pock, a church with its tower demolished and the stump roofed. Technology allow-list: rotary phones, typewriters, carbon paper, microfiche, reel-to-reel, tube radio, trams, boxy cars; forbidden: any screen, barcode, real brand, real flag, star, eagle, hammer or sickle, real script in any language. The state's device is a rectangular seal containing a filed rectangle with a tab (narrative-director to name it). **All text is a string**: no lettering is ever painted into a plate; text areas are left blank for the engine's typeset layer, so AI-generated pseudo-text is a defect, not texture.

### 6.2 Texture philosophy

Plates are flat printed surfaces, not paintings. Shading is **three steps and a pool**: at most three flat values per surface (§4.1 midtone band), and the only gradient is lamp or sodium falloff. The paper language is applied as three layers above the base plate: (1) one tileable bone grain at 8–12% opacity, uniform across the whole frame, so everything sits on one sheet; (2) carbon — the §4.5 double-strike ghost, offset 2–3 px, on objects the state has a copy of, driven by dossier state; (3) stamp — bordered, hatched red impressions placed by phase reach (§2.2). Layers 2 and 3 are engine layers owned by technical-artist, so **the base plate export contains no pixel within stamp-red tolerance and no carbon blue except painted carbon paper itself** — this makes the §4.3 red budgets measurable. The paint-over must reject: photographic drift (depth of field, bokeh, specular highlights, bloom, perspective lines, cast shadows from any light but the state's one source); painterly brushwork (visible strokes, impasto, soft blended edges); renders (corner occlusion gradients, metal, reflections, glass refraction). Reviewer test: every edge is hard, every surface is ≤ 3 values, and the only curves pass the §3.1 fill test.

### 6.3 Prop density by area

Density is counted in distinct objects per plate and a repeat ratio (share of furniture that is a repeated identical unit), per §3.3 and the §2.2 phase axis.

| Area | Distinct props | Repeat ratio | Note |
|---|---|---|---|
| State space | ≤ 12 at Confident, doubling per phase to ≤ 48 | ≥ 70% | Grid first; leaning stacks and shredder strips only from Panicking. |
| Private space | 20–35, constant across phases | ≤ 30% | Accumulation does not change; only red and carbon reach do. |
| Street | ≤ 10 | ≥ 60% (poles, windows, doors) | Sparse; loose paper only at Collapsing. |
| Print shop | 35–50, the densest plate | ≤ 20%, all misregistered | The one place the people's paper language dominates. |

Every plate has exactly one hero (§3.4) and 3–8 hotspots regardless of density.

### 6.4 Hotspot legibility without glow

A hotspot is an object **disturbed from the grid by one unit**: a lifted paper corner, a drawer out one notch, a door ajar, a receiver off its cradle, a cord across a threshold. Hotspots, figures and the hero are the only keylined objects on a plate, and an unfiled hotspot's 2 px keyline is **permanent**, not focus-only (AD-ART-BIBLE C3); on focus the corner lifts and the keyline thickens to 3 px. Every hotspot sits with a clear margin of plate midtone at least half its width on all sides, and no hotspot stands directly behind a figure's head. After its fact is filed the object loses its keyline and gains the carbon ghost, so a read room looks read. Hover feedback is the §3.5 corner lift and cursor bracket (ux-designer, §7). *Checkable:* keylined objects = hotspots + figures + hero.

### 6.5 Environmental storytelling

Documents never tell flavour story (Principle B, Pillar 1), so plates tell it through absence, duplication and wear: a lighter rectangle on wallpaper where a photograph was removed; two identical state pens on a private desk; a worn path to the telephone; a chair under the door handle; curtains closed at noon; a queue and what it queues for; a poster overpainted twice. The rule that keeps this on Pillar 1: **if a detail makes the player say "so X happened", X must be filable** — a hotspot or document must let them hold it. A detail that implies an unfilable fact is cut.

### 6.6 Legibility of figures against plates

Figures sit at second-highest contrast (§3.4). This forbids, in the band where figures stand (walkable floor plus one figure-height of wall): any hero object, any keyline, any value outside the midtone band (darkness is behind people, never under them), and any texture repeat finer than a figure's head width. *Checkable:* block the figure's bounding box; the plate inside it must contain no keyline and no value outside 20–60%.

### 6.7 Alternatives considered

- **Hand-painted textured plates (Disco Elysium register).** Rejected: brushwork is the first thing AI drift produces and the hardest to review; flat steps are checkable.
- **Painted-in text for atmosphere.** Rejected: no flavour paper, and generated lettering is always wrong.
- **Real-city architecture quoted directly.** Rejected by the anti-pillar; strata are invented from real building types, not real buildings.

## 7. UI/HUD Visual Direction

Builds on §3.5 (UI shape grammar) and §4.4 (UI palette) without restating them. Drafted by art-director, checked by ux-designer; the three conflicts between them were decided by the user and are recorded in §7.6.

### 7.1 Diegetic by default; three screen-space exceptions

Nothing floats. Every panel is a sheet at UI value (§4.4), unlit, axis-aligned to the window edge. The persistent HUD is exactly three elements: the **dossier tab** (bottom-right, a folder tab protruding 24 px into the frame), the **date stamp** (top-left, typed date with the phase's ink reach), and the **cursor**. Anything else on screen must be a sheet the player opened. Objective text is the top line of the open dossier, never a floating box. Dialogue is an **interrogation transcript**: a sheet with the speaker's ID-photo portrait pinned top-left, lines typed below, choices as typed brackets at the foot. Tooltips are a typed slip that lifts from under the cursor. *Reviewer test:* every UI pixel belongs to paper, cursor or a stamp; a border, panel, bar or badge that is not paper is a defect.

### 7.2 Typography

- **Body face:** one monospaced typewriter face with ribbon-ink texture, fixed pitch, no kerning, regular weight (never light). Used for documents, transcripts, menus, dossier fields, choices. Glyph coverage: Latin Extended-A and Cyrillic (localisation; every string is an ID).
- **One weight.** Emphasis is double-strike (bold), underline, or CAPS with letter-spacing. Italics are forbidden anywhere: a typewriter has none.
- **Protagonist letterforms** (§4.2) are annotation only: ≤ 2 lines, ≤ 80 characters, ≥ 1.2× body size, in that protagonist's ink. Never body copy, never choices, never menu labels. The dissident's pinboard fragments carry a typed caption beneath each. Fallback for uncovered glyphs: the typewriter face in the same ink.
- **Size hierarchy at 1280×720** (scale ×1.5 at 1920×1080, `canvas_items` stretch): body **18 px** (x-height ≥ 9 px) / 27 px; dossier field labels 15 / 22; sheet title 24 CAPS / 36; stamps 32 / 48. Nothing below 15 / 22 px. A UI scale option of 100–150% is required.
- **Line length:** documents 55–72 characters per line, never more (a typewriter margin); dossier fields ≤ 40; choices ≤ 60.
- **Interactive facts** (RichTextLabel): carbon blue plus a typed rule underline and a margin tick — a shape cue that is independent of filed state, so tritan and low-vision players can see what is clickable before clicking. Filed facts additionally gain the double-strike ghost and "cc" mark per §4.5.
- **Grain on the UI layer** (§6.2 layer 1) is capped at 6% opacity and omitted entirely behind body text; the §4.4 contrast figures are measured after compositing, and body contrast must stay ≥ 7:1.
- UI type never misregisters, even in Panicking (§2.2); misregistration is a plate phenomenon.

### 7.3 Iconography: almost none

Verbs are typed words in brackets — `[ FILE ]`, `[ BURN ]`, `[ LEAK ]`, `[ DELIVER ]`, `[ OBEY ]`, `[ REFUSE ]` — or stamp impressions once chosen. No pictograms for actions. The only icons permitted are printed marks that exist in paperwork: paperclip, staple, tab, seal, "cc", the date stamp, the surveillance stamp. Each is single-colour, hard-edged, pixel-aligned at 720 and 1080, no outline-plus-fill, no gradient. **Cursor:** three states only — a thin pointing hand (the one soft shape in the UI, per Principle C), a typewriter caret over text, and the hand holding a stamp during filing. The cursor never changes to signal a hotspot; the hotspot's corner lifts instead (§6.4), and discoverability is carried by the two aids in §7.6 C1.

### 7.4 Animation

Paper moves like paper: rigid translate, no rotation beyond 2°, no bend or curl beyond the baked two-frame corner lift. Durations: corner lift **120 ms**, sheet slide/page turn **180 ms**, stamp impression **90 ms** down + **60 ms** settle (one 2 px overshoot, the only overshoot in the game), onionskin fade to filing view **250 ms**, calendar tear **300 ms**. Easing: ease-out quadratic everywhere; no bounce, no elastic, no ease-in. **Never moves:** text (scrolling pages by line steps, no inertia), the dossier grid, tabs, the date stamp, the frame edge. No parallax, no pulsing, no breathing idle. Any flicker (the §2.2 Panicking portrait flicker included) stays at or below 3 Hz and can be disabled in settings.

### 7.5 Surveillance indicator and interrogation timer

Two elements, two shapes, two edges — never the same one. **Surveillance** is a square stamp inside the top-right corner of every open sheet, set 16 px in from both edges; the chapter tab and the "changed" marker (§7.6 C6) protrude *beyond* the sheet's top-right edge, so the two never overlap (AD-ART-BIBLE C8): hatching-only outline at Confident, red fill tracking the §4.3 tier — rising through Paranoid and Panicking and **falling back to a hatched outline at Collapsing**, when red withdraws (reviewer: fill percentage matches the §4.3 budget tier) — static, no motion. **Timer** is the margin fill (§2.1): the right margin of the transcript sheet fills top-to-bottom in stamp red with a bordered hatched edge, ruled across by hatching ticks at every 20% so the rate can be read without numerals; one fill = one decision; numerals are forbidden on screen, while the portrait crop tightens. A countdown string is exposed to the screen reader only. Settings offer **timer off / 2× / default**, defaulting to the normal timer; the audio cue is specified by audio-director. The timer is the only UI element allowed continuous motion.

### 7.6 UX alignment: conflicts and resolutions

The ux-designer review set eight requirements (keyboard and later gamepad reach for every interactive element; body text ≥ 16 px with contrast measured post-overlay; every state distinguishable by shape; timer accessibility; AccessKit roles on every Control; hotspot discoverability without pixel-hunting; dossier changes legible unaided; flicker limits) and found seven conflicts with the art rules. Decisions:

- **C1 Hotspot discovery** (art: keyline and displacement only, cursor fixed; UX: too subtle at 720p under grain). *Decided:* keep the fixed cursor and no glow; add a **hold-key / gamepad-button reveal** that raises every hotspot's corner lift at once, and a **read count** ("4 of 6 documents") on the dossier sheet at scene exit. The brief treats discoverability as a hypothesis: test with players at 720p in the MVP before locking.
- **C2 Hover vs focus.** *Merged:* the corner lift is the **focus** state, triggered by mouse hover, keyboard focus and a gamepad cursor alike; the hotspot's permanent 2 px keyline (§6.4) thickens to 3 px on focus so the state survives grain. No hover-only affordance exists.
- **C3 Disabled state** (art, §3.5: redaction bar; UX: indistinguishable from censored content, unreadable by screen readers). *Decided:* disabled = greyed typed bracket struck through **VOID**, exposed via the AccessKit disabled flag; redaction bars are content only. §3.5 amended to match.
- **C4 Interactive facts.** *Merged:* the typed-rule underline and margin tick in §7.2.
- **C5 Timer** (art: margin fill, no numerals; UX: no rate read, no off switch). *Decided:* the ticks, the off / 2× / default option and the screen-reader countdown in §7.5.
- **C6 Three dossier grammars** vs learning cost. *Merged:* one invariant across all three — overprinted consequences and the "changed" marker use the same shape in the same position (the top-right chapter tab), and each protagonist's first dossier view opens on an empty-state sheet so the grammar is met before it changes.
- **C7 Grain vs legibility.** *Merged:* the UI grain cap and post-composite contrast rule in §7.2.

Diegetic paper is built as a Control tree with semantic roles (button, list, heading) and accessible names, never as a drawn texture; the accessibility tier is confirmed by accessibility-specialist in `design/accessibility-requirements.md`.

### 7.7 Alternatives considered

- **A clean modern HUD layer for readability.** Rejected (§3.6); readability is carried by value contrast and size, not by leaving the paper.
- **Hand letterforms for dialogue body.** Rejected: handwriting fails the 9 px x-height test and the Cyrillic set; annotation-only is the compromise.
- **Cursor change over hotspots.** Rejected in C1 in favour of the hold-key reveal; the cursor stays one of three states.
- **Smooth inertial scrolling.** Rejected: line-step scrolling is an art rule (paper does not glide); if playtesting shows it hurts long documents, escalate to creative-director.
- **Pictogram verbs.** Rejected: a paperwork state writes words; pictograms would be the only non-period marks on screen.
- **Numeric timer.** Rejected by §2.1 (never a clock face) and Pillar 5; the 20% ticks give the rate read instead.

## 8. Asset Standards

### 8.1 File formats

Every raster asset is **PNG, 8-bit sRGB, lossless**. §6.2 demands hard edges and ≤ 3 flat values per surface; lossy formats add ringing and chroma shift that break both the §3.1 fill test and the §4.3 red measurement. JPEG is forbidden anywhere.

| Class | Format | Why |
|---|---|---|
| Plates (base) | PNG-24, no alpha | Opaque by definition; alpha invites soft edges. |
| Hotspot layers, figure sprites, standing layers | PNG-32, straight alpha | Cut-outs must register over the plate. |
| Portraits | PNG-32 with the §5.4 20% bleed baked in | Engine crops and lights; nothing repainted. |
| Document textures | PNG-24, blank text areas (§6.1) | Text is a string; texture is paper only. |
| UI sheets, nine-slices | PNG-32 | Flat, unlit, pixel-aligned (§3.5). |
| Stamps, carbon ghosts | PNG-8 greyscale mask | Engine tints with `#B5241C` / `#434C7C` (§4.1), so red lives in one place. |
| Fonts | TTF/OTF, embedded licence file | Four letterforms: typewriter, cursive, hand-set block, stencil (§4.2). |

### 8.2 Naming

`[class]_[slug]_[state]_[phase]_[dir]_[frame].png`, snake_case ASCII, tokens omitted when inapplicable but never reordered, no version suffixes (git holds versions). This deliberately drops the studio default's `[size]` token: size is fixed per class in 8.3.

Classes: `plate`, `hot`, `fig`, `stand`, `por`, `doc`, `ui`, `stamp`, `font`. Phase: `ph1`–`ph4` (§2.2 order). Direction: `n s e w` (or `l r` for 2-direction). Frame: `f00`.

Examples: `plate_archive_reading_room.png` · `hot_archive_reading_room_drawer_open.png` · `fig_archivist_walk_s_f03.png` · `stand_dissident_print_shop_seated.png` · `por_conscript_exposed.png` · `doc_transfer_order_blank.png` · `ui_panel_dossier_tab_nine.png` · `stamp_seal_state_mask.png`.

### 8.3 Resolution tiers

- **Plates: 1920×1080 ship, painted at 3840×2160 and downsampled 2:1 on export.** Source-only, not runtime; 2× painting keeps the §5.5 2 px keyline and §3.1 edges clean after reduction. Scrolling plates may extend width, never height. 720 is a ⅔ `canvas_items` stretch of the same file; a second 720 set is refused (8.7).
- **Figures / standing layers:** 15–20% of plate height (§5.5) → 162–216 px tall at 1080, exported in a 256×256 frame, feet on a fixed baseline row.
- **Portraits:** crop 640×800 (4:5, head 60–70% → 480–560 px), **export 896×1120** with bleed (~4 MB each). Only present characters' four states load per scene (≤ 24 portraits ≈ 128 MB with mipmaps), never the full set.
- **Documents:** 1:1 at 1080 (max 1200×1080 full-frame). Legibility belongs to the font: the paper field under any text area must be ≥ bone `#D8CDB2` so 18 px soot type holds the §4.5 7:1 contrast.
- **UI nine-slices:** 1× at 1080, all margins multiples of 3 px so the ⅔ stretch lands on whole pixels. Stamps ≤ 256².

### 8.4 LOD and filtering

No LOD levels. A painted 2D game has one level per asset; the portrait is a different asset, not an LOD of the figure (§5.5); only the ⅔ `canvas_items` stretch is accepted, never a second 720 set. Filtering follows the technical constraint, not the art preference (resolved in 8.8): **mipmaps on for plates and portraits** (they are downscaled 0.667× at 720), **off for UI**, linear filtering throughout (nearest aliases at 1.5×), no VRAM compression anywhere. Import option names are not sourceable for 4.7 and are verified in the MVP spike.

### 8.5 Export settings

sRGB, 8-bit, **ICC profile stripped**, no colour transform on export (keeps §4.1 hexes measurable). Straight alpha, ≤ 1 px anti-alias fringe. **Layers are cropped to their bounding box and carry their x,y offset in 1080 plate space** (in a sidecar `.json` beside the PNG, written by the export script), never exported full-frame (8.7 T1); registration is by offset, and the offset is an integer. **Base plate: no pixel within the red tolerance of 8.7 T7 and no carbon-blue pixel except painted carbon paper (§6.2)** — grain, carbon, stamp are engine layers. Keylines are **2 px at 1080** (≈1.33 px at 720; §5.5 amended). Hard edges on whole pixels at 1080; even dimensions everywhere.

### 8.6 Review checklist (AI-generated assets; any fail = reject)

1. Fill black — only people/weather/printed circles curve (§3.1).
2. 64 px thumbnail — one trait; straight-edge count per type (§3.2, §5.2).
3. ≤ 3 values per surface; only gradient is lamp/sodium falloff; no drift list items (§6.2).
4. Midtones 20–60%; one hero at full bone; one light source per state (§2.1, §3.4, §4.1).
5. No red, no carbon in base plate; red share within phase budget (§4.3, §6.2).
6. Keylines = hotspots + figures + hero; hotspot margin ≥ half-width (§6.4).
7. Figure band clean (§6.6); accent ≤ 15%; dominant ≥ 20% off plate neutral (§5.1).
8. No painted text, no forbidden devices (§6.1); density in table (§6.3).
9. Portraits: pose table pass; bleed present (§5.4).
10. Screenshot at 1080 and 720; keyline still reads at 720.

### 8.7 Technical constraints (technical-artist)

Engine Godot 4.7, Forward+, GDScript. Each item is **SOURCED** (reference file cited) or **NOT SOURCEABLE / SPIKE** (not covered by `docs/engine-reference/godot/`; verified in the MVP pipeline proof, never asserted from memory of post-4.3 behaviour).

- **T1 Texture memory per scene.** Ceiling 2 GB RAM (technical-preferences, SOURCED). Stated assumption, not sourced: minimum GPU is integrated / shared-memory class with 2 GB usable, so textures count against the same 2 GB. Allocation: engine, scripts and audio reserve 512 MB; resident textures ≤ 1 GB; **≤ 256 MB per loaded scene**, two scenes resident (current and preloading next). One 1920×1080 RGBA8 plate costs 8.3 MB (11 MB with mipmaps). Consequence: hotspot, figure and carbon layers are cropped to their bounding box, never full-frame (nine full-frame layers would be 75 MB on one plate). **Worst-case scene worksheet** (AD-ART-BIBLE C6; mipmapped textures cost 1.33×): plate 11 MB + one protagonist sprite sheet 16 MB + 24 portraits at 5.35 MB = 128 MB + UI atlas 16 MB + overlays and layers ≈ 10 MB + **documents: at most 4 full-resolution documents resident (≈ 21 MB); the rest stream in on open** → ≈ 202 MB, under the 256 MB ceiling. Twenty resident documents would push it to ≈ 260 MB, so the resident-document cap is a hard rule, verified in the MVP spike.
- **T2 Maximum dimensions per asset class** (project policy; the engine maximum is NOT SOURCEABLE). Plate: a single 1920×1080 PNG at runtime (painted at 2× and downsampled on export, 8.3); a scrolling plate ≤ 3840×1080, still one texture. Hotspot and standing-figure layer: ≤ 512×512 crop. Portrait: 896×1120 export (8.3; ≈ 5.35 MB each with mipmaps). Document: ≤ 2048×2048. UI: 2048×2048 atlas sheets. Hard cap for any asset **4096×4096**. One plate per scene is one draw either way; atlasing plates would only add memory.
- **T3 Draw calls** against the 500/frame default (SOURCED budget; batching rules NOT SOURCEABLE). Target ≤ 150 steady state: plate 1; hotspot layers ≤ 8 (+8 focus states); figures ≤ 6; carbon ghosts ≤ 16 (one extra draw per filed object); stamps ≤ 12; grain 1; phase tint 1; documents ≤ 20; UI ≤ 60; reserve 17. Counted with the engine's draw-call monitor (API name: SPIKE).
- **T4 Overlay stack.** Four engine layers above the base plate, in order: grain (one tileable texture, uniform, 8–12% opacity on plates, ≤ 6% on UI per §7.2) → carbon (duplicate of the object sprite, offset 2–3 px, carbon-blue tint, dossier-driven) → stamp (instances from one stamp atlas, placed by phase reach) → phase red tint (full-frame). SOURCED: `DrawableTexture2D` exists in 4.7 (`modules/rendering.md`) as a candidate for runtime stamp placement. NOT SOURCEABLE — SPIKE: `CanvasLayer` ordering, `CanvasModulate` versus a full-frame tint shader, blend modes, screen-texture access in 2D under Forward+.
- **T5 Import settings** (option names NOT SOURCEABLE — SPIKE; the reasons stand). Source PNG, lossless. No VRAM compression: block compression fringes hard edges, bands three-value flat fields (§6.2) and contaminates the red measurement. Mipmaps and filtering per 8.4. sRGB for all colour textures.
- **T6 Pixel alignment.** The 4.7 new-project default is `stretch/mode canvas_items`, `aspect expand` (`breaking-changes.md`, SOURCED); 720→1080 is 1.5×, so keylines are authored at 2 px (8.5). Figures and hotspot layers sit at integer positions in 1080 space. SOURCED: 4.7 `CanvasItem` lines draw without an anti-aliasing feather and look thinner, so any keyline drawn by code must be widened. The aspect setting is decided in the stretch ADR (concept, Technical Risks).
- **T7 Red-budget measurement** (§4.3). Two gates, scripted in `tools/asset-pipeline/`. Per pixel → HSV. Stamp red `#B5241C` is hue 3°, S 0.85, V 0.71; **red tolerance: hue 348°–18°, S ≥ 0.55, V ≥ 0.35** (excludes ochre 40°, sodium 33°, amber 38°). Soot: V ≤ 0.15, S ≤ 0.2. Carbon `#434C7C`: hue 215°–245°, S ≥ 0.3. **Gate A**, every plate export: red count = 0; carbon count ≤ the declared carbon-paper mask. **Gate B**, per phase: an in-engine composited capture with the T4 stack → red share ≤ 2 / 5 / 15 / 1%; Collapsing soot ≥ 40%. Capture API: SPIKE. The §4.3 question is answered: the budgets are measurable, but only on the composite, since the plate itself carries no red.
- **T8 Sprite sheets** (walking-avatar outcome). Figure 162–216 px tall at 1080 (§5.5); cell 256×256. Four directions, three authored (N, S, E; W mirrored). Frames: walk 8, idle 4, sit 2, hand-over 6, page-turn 6 → ≤ 50 cells per protagonist, one 2048×2048 sheet (64 cells, 16 MB). Named NPC: idle 4 + sit 2 on a 1024×512 sheet. Playback ≤ 12 fps. Standing-layer outcome: one ≤ 512×512 crop per pose per scene state. Animation node choice: SPIKE.
- **T9 Hard limits no art preference overrides.** 4096×4096 for any asset; 256 MB per scene; 500 draws absolute, 150 target; the base plate contains zero red-tolerance pixels; no VRAM compression on plates; no full-frame layers except plate, grain and tint; portraits carry 20% bleed; 60 fps / 16.6 ms.

### 8.8 Conflicts between art preference and technical constraint, and how each was decided

| Topic | Art preference | Technical constraint | Decided |
|---|---|---|---|
| Keyline width | 1 px (§5.5 as first written) | Not crisp at both 720 and 1080 under a 1.5× stretch | **2 px at 1080**; §5.5 amended |
| Filtering | Mipmaps off, no trilinear | Mipmaps on for plates and portraits to avoid shimmer at 720 | **Tech**: on for plates and portraits, off for UI, linear |
| Portrait size | 896×1120 export (~4 MB) | 640×800 (~2 MB), per-scene loading | **Art size with per-scene loading**: ≤ 24 portraits ≈ 128 MB per scene with mipmaps |
| Layer registration | Full plate canvas per layer | Full-frame layers forbidden (memory) | **Crop to bounding box with recorded integer offset** |

Everything else was compatible: lossless PNG, naming, 2× painting source with 1080 runtime plates, document sizes, the review checklist. Where the two halves gave different red thresholds, the HSV tolerance in T7 is the one scripts use.

### 8.9 MVP spike list (all NOT SOURCEABLE)

Texture import option names and the engine's maximum texture size; compression and sRGB handling for 2D; CanvasLayer / CanvasModulate / blend-mode compositing for the T4 stack; the draw-call monitor and frame-capture APIs; the sprite animation node; the pixel-snap setting. Each is proven on the installed 4.7.x during the MVP pipeline proof and recorded in the renderer and plate-authoring ADRs.

### 8.10 Alternatives considered

- **Lossy WebP/JPEG.** Rejected: edge ringing fails checklist items 1 and 5.
- **Separate 720 asset set.** Rejected: doubles the largest cost; stretch plus checklist item 10 instead.
- **SVG UI.** Rejected: vector smoothing fights pixel-aligned paper; nine-slices suffice.
- **Painting at 1× directly.** Rejected: 1 px keylines from generators arrive aliased; 2× source is cheap.
- **Atlasing plates.** Rejected: one plate per scene is already one draw; an atlas only adds memory.

## 9. Reference Direction

Five references, each pointing one direction only: material, figure, people's paper, filing composition, letterform. A plate that leans on one for a second purpose is a defect. The AI pipeline rule is uniform: **prompt the technique, never the title, artist, country or decade** — a name locks the generator to a style and drags real insignia, real script and photographic rendering in with it, all forbidden by §6.1 and §6.2.

### 9.1 Late-socialist bureaucratic material culture — *the surface*

Serves §4.1 (carbon, bone), §6.2 (three layers), §7.3 (permitted icons). Draw from the physical artefacts themselves: carbon paper's double strike, offset and bluer than the original; a rubber stamp's uneven ink load with a bordered, hatched edge; onionskin's translucency as the filing fade (§2.1); staples, paperclips, tear-off calendars. Avoid: nostalgia kitsch, any real seal, flag, eagle or script (§6.1), and product-photography lighting on the objects. *Prompt:* "carbon-copy double strike, 2 px offset", "rubber stamp impression, uneven ink, hatched border", "onionskin sheet over a form" — never a country, agency or era word.

### 9.2 *The Lives of Others* (2006) — *the figure*

Serves §1.2 Principle C, §3.2, §5.3. Draw the character read alone: stillness, narrow stooped bodies as the one organic thing in a room of boxes, faces that act with gaze and chin, complicity shown as listening posture. Avoid everything photographic — shallow focus, lens grain, naturalistic multi-source lighting (§2 one light; §6.2 photographic drift) — and its real set dressing. *Prompt:* describe the pose ("stooped, narrow shoulders, hands visible, gaze off-lens, flat printed figure"); never the title, actors or "film still", which returns photoreal frames that fail §1.1.

### 9.3 Polish/Czech poster school — *the people's paper only*

Serves Principle B, §3.3 print shop, §4.2 dissident letterform, the dissident dossier grammar (§3.5). Draw: misregistration of two flat inks, hand-cut block capitals, torn-edge collage, overprint as meaning. Avoid: hero-saturated primaries, surreal metaphor imagery, graphic heroism (rejected §1.3), and any spread onto state paper, plates or UI — it lives in samizdat and the print shop. *Prompt:* "two-colour misregistered linocut, torn edge, flat ink" — never "poster", never a school or artist name, and never request lettering at all: text areas stay blank (§6.1).

### 9.4 *Papers, Please* — *the filing frame*

Serves §2.1 Filing state, §3.4 hero, §7.3 stamp verbs, §7.4 stamp timing. Draw: the document filling the frame, scanner-flat and shadowless; the stamp as the decision, with weight in the impression not the hand. Avoid: pixel art (fails §8.3/§8.5 hard edges at 1080), the booth/checkpoint framing, the uniform drab grey, the comic register. *Prompt:* "document at full frame, scanner-flat, no shadow" — never the title; the title is a hard style lock to low-resolution pixel art.

### 9.5 *Pentiment* — *letterform as identity*

Serves §4.2 three inks/three letterforms, §7.2. Draw: the typeface identifies the writer before the words are read; the flat, unlit printed-surface register. Avoid: manuscript illumination, decorative borders, marginalia curves (§3.1), painted-in text (§6.1), parchment warmth drifting bone toward sepia. *Prompt:* "flat printed surface, hard edges, no shading" — never the title, which pulls illuminated lettering, the exact §6.1 defect.

### 9.6 Anti-references

Generated assets must never resemble:

- **Photoreal Cold War film stills** — §1.1 one-line rule; §6.2 photographic drift.
- **Generic dystopia** (searchlights, monumental statues, banners, hammer/sickle, fog) — §6.1 forbidden devices; §2.3 no desaturation; §3.6 no tilted grid.
- **Pixel art** — §8.3 2× source, §8.5 2 px keylines, §5.3.
- **Painterly brushwork / Disco Elysium register** — §6.7, §6.2.
- **Beholder** caricature and grotesque proportion — §3.6, §5.3 (a comic figure cannot look ashamed).
- **Orwell**'s screen-and-desktop UI — §3.6, §6.1 no screens, §7.1 nothing floats.
- **Noir chiaroscuro** with several light sources or Dutch angles — §2 one state, one light; §3.6.
- **Sunlight, golden hour, blue sky** — §4.1 forbidden.
- **Ostalgie kitsch and real insignia** — §6.1 anti-pillar.

Orwell and Beholder remain *comparables* in the concept's market positioning; they are anti-references here because the bible already rejects their defining visual traits.

### 9.7 Alternatives considered

- **A still-image mood board from the films and games above.** Rejected: pinned stills become prompt inputs and reintroduce photoreal and pixel drift; the board is built from §9.1 artefacts only.
- **Named-artist prompting for consistency.** Rejected: style lock plus copyright drift; consistency comes from the §8.6 checklist, not a name.