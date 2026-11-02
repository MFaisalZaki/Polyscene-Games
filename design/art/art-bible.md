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

[To be designed] — for each major game state (exploration, combat, victory,
defeat, menus — whichever this game has): the emotional target, lighting
character (time of day, colour temperature, contrast), 3–5 atmospheric
descriptors, and energy level. Each state must look distinct from the others.

## 3. Shape Language

[To be designed] — character silhouette philosophy (readable at thumbnail
size, one distinguishing trait per archetype), environment geometry, UI shape
grammar, and hero versus supporting shapes.

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
