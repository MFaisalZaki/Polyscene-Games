# Game Concept: Paper Walls

*Created: 2026-11-02*
*Status: Draft*

> **Creative Director Review (CD-PILLARS)**: CONCERNS (resolved) 2026-11-02 — six sharpenings applied; see Game Pillars.
> **Art Director Review (AD-CONCEPT-VISUAL)**: STRONG 2026-11-02 — Carbon Copy hybrid chosen as Visual Identity Anchor.
> **Technical Director Review (TD-FEASIBILITY)**: CONCERNS (noted) 2026-11-02 — nothing blocks MVP or slice; full vision re-judged at the slice gate from measured rates; six ADRs required before MVP code.
> **Producer Review (PR-SCOPE)**: OPTIMISTIC (adjustments applied) 2026-11-02 — re-scoped to a shippable 3-act core; timelines restated; ending-first skeleton, self-contained slice and post-slice go/no-go adopted.

---

## Elevator Pitch

> It's an interactive drama where you play the three people a dying police
> state runs on — the archivist who files the surveillance reports, the
> dissident who prints the leaflets, the conscript ordered to hold the border —
> in the six weeks of autumn 1989 that decide whether the regime falls at all,
> and what the files say about you afterwards.

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | Interactive drama / branching narrative adventure (isometric 2D point-and-click, investigation) |
| **Platform** | PC (Windows, Linux, macOS), mouse and keyboard |
| **Target Audience** | See Player Profile |
| **Player Count** | Single-player |
| **Session Length** | 30–120 min (one act: one chapter per protagonist) |
| **Monetization** | Premium (none decided; experiment first) |
| **Estimated Scope** | Large (3-act core 14–18 months, full 5-act vision 24–30 months; one human at 10–20 h/week plus the AI studio — producer estimate, re-run `/estimate` after the MVP) |
| **Comparable Titles** | Detroit: Become Human (structure), Papers, Please, Orwell, Disco Elysium, Pentiment |

---

## Core Fantasy

Being the small cog whose acts of disobedience — or obedience — decide whether
something enormous falls. The regime does not fall on its own: the player's
choices across three lives determine whether it collapses, how much blood it
costs, which files survive, and who is named when it is over. The act can
succeed; the actor is never absolved.

---

## Unique Hook

"Like Detroit: Become Human, and also the awakening is political, not
artificial." Against the games players will actually compare it to — Papers,
Please, Orwell, Beholder — Paper Walls does three things none of them do:

1. **The state's knowledge is a visible, changing object.** Every character has
   a living state-security dossier that grows and changes in real time as the
   player acts.
2. **Three intersecting protagonists**, and the most important consequence of a
   choice lands in *another* protagonist's chapter.
3. **The regime can fall, and the player decides whether it does.**

Investigation scenes are reading surveillance files, reconstructing who
betrayed whom, and choosing whether to burn, leak or deliver them.

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Narrative** (drama, story arc) | 1 | Three intersecting lives, permanent consequences, player-determined fall |
| **Discovery** (exploration, secrets) | 2 | Facts pieced from documents, objects and conversations; the dossier reveals what the state knows |
| **Fantasy** (make-believe, role-playing) | 3 | Three distinct lives inside a police state; courage or cowardice, never purity |
| **Sensation** (sensory pleasure) | 4 | Carbon Copy visual identity: paper, ink, stamp red bleeding in as surveillance rises |
| **Challenge** (obstacle course, mastery) | 5 | Investigation quality decides what options exist; rare timed choices under interrogation |
| **Submission** (relaxation, comfort zone) | N/A | — |
| **Expression** (self-expression, creativity) | N/A | — |
| **Fellowship** (social connection) | N/A | — |

### Key Dynamics (Emergent player behaviors)

- Players hoard facts and hesitate before filing, because every fact can protect or destroy someone.
- Players learn to fear a colour: stamp red creeping into a scene means the state is looking.
- Players replay chapters to see how a different filing lands in another protagonist's life.
- Players argue about whether the archivist's compliance was cowardice or protection.

### Core Mechanics (Systems we build)

1. **Investigation**: examine objects, read documents, question characters; each yields a fact; connected facts unlock new questions and actions.
2. **Living dossier**: per-character state-security files that change in real time; the sole channel through which consequences cross storylines; viewed differently per protagonist (files / signs / orders).
3. **Filing and decision**: each scene ends in a decision (file, burn, leak, deliver, obey, refuse) that writes to dossiers.
4. **Reactive state**: authored events (raids, calls, visits) whose firing and target are read from dossier state; the state's behaviour shifts across the six weeks (confident → paranoid → panicking → collapsing).
5. **Calendar**: the macro clock advancing toward the final night; the fall is an outcome of accumulated dossier state, not a fixed event.

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy** | Choices whose consequences are visible in the dossier and felt in other lives | Core |
| **Competence** | Piecing facts together; thorough investigation opens options others never see | Supporting |
| **Relatedness** | Named people whose fates the player holds; three lives crossing | Core |

### Player Type Appeal (Bartle Taxonomy)

- [ ] **Achievers** — Secondary: every ending, a complete dossier
- [x] **Explorers** — Primary: every document read, every connection found
- [ ] **Socializers** — Not served (single-player); relatedness comes from fiction
- [ ] **Killers/Competitors** — Not served

Quantic Foundry: primary Storytellers and Explorers.

### Flow State Design

- **Onboarding curve**: the first archivist scene teaches read → connect → file with six documents and one visible dossier change; no tutorial text.
- **Difficulty scaling**: more facts per scene, more conflicting pressures, more of the scene in stamp red; interrogation timers appear only from act 2.
- **Feedback clarity**: the dossier change at scene end, the red bleed, overprinted ink from another protagonist when a payoff lands.
- **Recovery from failure**: no fail state on investigation; a poor investigation narrows options rather than ending the game. A protagonist can die; the story continues with the others.

---

## Core Loop

### Moment-to-Moment (30 seconds)
Read a document, examine an object, or pick a line in a conversation. Each
yields a fact (a name, a date, an address) that drops into a dossier. Two
facts that connect unlock a new question or action. The dossier visibly grows;
facts "click" when they link; every fact learned is one the state could learn.

### Short-Term (5-15 minutes)
One scene, one location, one objective (find out who informed on the printer;
get the leaflets past the checkpoint; decide what to file about a neighbour).
Investigate, talk, then make the filing or decision. The scene ends by showing
which dossiers changed; a change set up here pays off in another protagonist's
chapter.

### Session-Level (30-120 minutes)
One act: one chapter per protagonist. The calendar advances toward the final
night. The act ends with all three dossiers changed and the next calendar event
teased.

### Long-Term Progression
No stats. Progress is knowledge and standing: what the state knows about you,
who still trusts you, and how far each protagonist has moved from compliance.
The long-term goal is to bring all three to the final night alive, free and
with their conscience intact — rarely all three — and to decide whether the
regime falls. An epilogue per character ends the game.

### Retention Hooks
- **Curiosity**: what the other protagonist's dossier now says; what the next calendar event is
- **Investment**: named characters whose files the player has shaped
- **Social**: none (single-player)
- **Mastery**: the complete dossier; every ending; a clean-conscience run

---

## Game Pillars

### Pillar 1: Every fact is a weapon
Information is the only currency: anything learned can be written into, leaked
from, or used against someone's dossier, and the game never hands over a fact
with no possible dossier use.

*Design test*: A flavour-only document or one with a name in it? The name.

### Pillar 2: The state is a character
The regime is not a backdrop. Authored events, systemic triggers: every scene
is hand-made, but whether it fires and at whom is read from the dossier. Across
the six weeks the state goes confident → paranoid → panicking → collapsing.

*Design test*: A scripted raid or one triggered by dossier state? Triggered.

### Pillar 3: No one is clean
Every protagonist is complicit in something. Every heroic line costs something;
every cowardly line protects something real. The act can succeed; the actor is
never absolved.

*Design test*: A heroic line with no cost, or a cowardly line that protects nothing? Fix whichever is missing.

### Pillar 4: Consequences cross lives
The most important result of a choice lands in another protagonist's chapter —
through dossier states, never bespoke branch trees. One cross-chapter payoff
is a vertical-slice success criterion.

*Design test*: Where should a consequence land? The other protagonist's story.

### Pillar 5: Pressure comes from attention, not reflexes
Tension rises as the state's attention on a character grows. Timed choices
exist only under interrogation or search; everywhere else the player may think
as long as they like.

*Design test*: A chase or an interrogation? The interrogation.

### Anti-Pillars (What This Game Is NOT)

- **NOT an action game**: no combat, no quick-time events; it would compromise Pillar 5.
- **NOT a history lesson**: real texture, fictional facts. Authentic bureaucracy and material culture; invented city, names, events and regime. Real-world specifics would compromise drama with factual nitpicking.
- **NOT a morality meter**: no good/evil score; it would compromise Pillar 3.
- **NOT a sandbox**: scenes are authored; emergent freedom would compromise the authored payoffs Pillar 4 depends on.

---

## Visual Identity Anchor

**Carbon Copy (hybrid)** — *Everything is paperwork.*

Every surface reads as something the state could file: typed, stamped,
carbon-pressed, folded, redacted. The world is rendered the way the dossier is
rendered, so the player never leaves the document.

Supporting principles:
- **Stamp red is the state's attention.** The only saturated red in the game; it appears only when the regime is looking, and bleeds further into the scene (UI margin → prop → key light) as surveillance rises. *Test*: is there red in this frame that is not the state? Remove it.
- **Two paper languages.** State paper (typed, gridded, stamped, carbon-blue) versus people's paper (hand-set, misregistered, smudged). The archivist's chapters lean state paper; the dissident's lean people's paper and use the Samizdat print sub-vocabulary; the conscript's pin both to the same wall. *Test*: could this frame be stapled into a file?
- **Figures are the only soft shapes.** Architecture is rectilinear and stacked; people are thin, stooped, rounded — the softest shape in a hard room. *Test*: is anything organic on screen that is not a person or weather?
- **Exterior lighting rule (from Sodium Light).** Outdoors, every light is someone watching: sodium orange for state light, incandescent amber for private light, darkness as the only privacy. Interiors stay paper-neutral.

Colour philosophy: paper neutrals (bone, grey-green, nicotine ochre,
wet-concrete grey) in the 20–60% value band; carbon blue/violet for anything
the state has a copy of; stamp red for attention; one secondary ink per
protagonist (archivist grey-green, dissident soot black, conscript khaki), so a
cross-chapter payoff appears as a literal overprint. Forbidden: hero-saturated
primaries, golden-hour sunlight. Warm light is a desk lamp, never the sun.

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| Detroit: Become Human | Multiple protagonists, permanent consequences, investigation/reconstruction scenes | No sci-fi, no QTEs, isometric 2D; consequences cross protagonists through the dossier | Validates the branching-drama appetite |
| Papers, Please | A fictional Eastern Bloc state made tactile through paperwork | The regime can fall; three lives, not one booth | Validates the bureaucracy-as-gameplay fantasy |
| Orwell | Surveillance files as the play surface | The files are a shared, changing object across three lives, and the player can be their subject | Validates reading-as-investigation |
| Disco Elysium / Pentiment | Dense reading, no combat, period texture | Shorter scenes, reactive state rather than skill checks | Validates reading-heavy commercial viability |

**Non-game inspirations**: *The Lives of Others* (2006); the Polish/Czech poster school; the material culture of late-socialist bureaucracy (carbon paper, rubber stamps, onionskin).

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 25–45 |
| **Gaming experience** | Mid-core; reads everything |
| **Time availability** | 1–2 hour sessions, a few per week |
| **Platform preference** | PC |
| **Current games they play** | Disco Elysium, Pentiment, Return of the Obra Dinn, Papers, Please |
| **What they're looking for** | A story where choices leave visible marks and nobody is clean |
| **What would turn them away** | Combat, QTEs, a morality meter, a preachy history lesson |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | Godot 4.7, GDScript — pinned by /setup-engine; 2D, Forward+, Godot Physics 2D |
| **Key Technical Challenges** | Dossier state model (sole cross-storyline channel), the polyscene story topic that generates the branch space (writer-authorable rules as preferences, licences and laws), branching dialogue/document tooling at ~60k words, three dossier views, isometric point-and-click navigation |
| **Art Style** | 2.5D isometric, painted plates, Carbon Copy identity |
| **Art Pipeline Complexity** | Medium (custom 2D; one shared paper/ink asset family) |
| **Audio Needs** | Moderate; adaptive layer tied to surveillance state (typewriters, phone taps, shredder) |
| **Networking** | None |
| **Content Volume** | Core: 3 acts × 3 chapters + finale; ~18–20 locations; ~12 named characters; ~35–40k words; 5–6 hours; all endings present. Stretch: acts 4–5 (to ~30 locations, ~18 characters, ~60k words, 8–10 hours) |
| **Procedural Systems** | None; reactive triggers over authored content only |

---

## Risks and Open Questions

### Design Risks
- Player-determined fall multiplies final-act branches; must be carried by dossier state, not bespoke endings per path.
- Three different dossier views (files / signs / orders) must each stay readable.
- Bleakness: six weeks in a police state needs relief (the exterior lighting rule, humour in the dissident's chapters).
- "Consequences land elsewhere" can make the current scene feel inert; the dossier change at scene end is the mitigation.

### Technical Risks
- **Dossier schema and flag budget.** The dossier needs a fixed schema (a small named set of flags and scalars per character plus a global regime state), a per-chapter budget of flags read and written, and endings computed from a few aggregate values, never from choice paths. Mitigation: a headless story simulator that walks the rule data and asserts every reactive event and ending is reachable and no dead ends exist.
- **Dialogue and document tooling.** No addon's compatibility with Godot 4.7 is sourceable from the pinned reference (4.7 changed typed-return overrides and RichTextLabel image APIs). Mitigation: one-day spike per candidate, ADR; fallback is a plain-text dialogue format with a small GDScript interpreter.
- **Stamp-red overlay pass.** CanvasModulate and full-screen 2D overlay shaders are NOT SOURCEABLE from the pinned reference. Mitigation: MVP spike owned by technical-artist and shader specialist, verified on the installed 4.7.x.
- **Renderer.** Forward+ is desktop-focused; a painted-plate 2D game uses little of it and the audience skews to older laptops. Mitigation: ADR weighing Compatibility vs Forward+ before visual work.
- **Save format.** Save only at scene boundaries for MVP and slice; versioned plain-data schema (dossier state, calendar, scene ID) with a migration hook; lead-programmer verifies the safety of the chosen format.
- **Display stretch.** 4.7 defaults new projects to `canvas_items` / `expand`, which shows painted plates beyond their edges at other aspect ratios. Decide aspect ratio and letterboxing in the first project setup.
- **Installed editor unknown.** `Installed at pin time: NOT DETERMINED`; run `/setup-engine refresh` on the dev machine before the first line of code.
- **Determinism.** Reactive events are decided by rules or a saved seeded RNG, so tests and bug reports reproduce.

### Market Risks
- Niche genre; comparables (Papers, Please; Orwell; Disco Elysium) show the niche pays, but discovery depends on a distinctive look (Carbon Copy) and a clear pitch.

### Scope Risks
- **Approval time is the capacity limit**, not generation time: one human at 10–20 h/week reads, edits and approves every word and asset. Re-run `/estimate` on the slice once the MVP yields velocity data.
- **No shippable tier between the slice and the core** unless the ending-first skeleton is built: after the slice, every act and ending is outlined and wired at low fidelity before any act is written in full, so a cut under pressure shortens acts instead of dropping the finale.
- **Character art is the largest unbudgeted cost** (walking sprites in several directions, consistent with painted plates, no human artist). Settled by the MVP pipeline proof (see MVP).
- **Unbudgeted items**: audio (music and sound), save/load across three protagonists (needed at the slice), readability and accessibility of text-heavy documents, localisation (assume English only; every line gets a string ID from day one).
- **Go/no-go gate after the slice**: the full-game commitment depends on the slice's playtest against the experiment question. If the drama does not hold up, the project still ends with a finished, publishable prologue.

### Open Questions
- Dialogue/document tooling: addon or in-house? → `/architecture-decision` after `/create-architecture`.
- Does the red bleed read as "the state is looking" without explanation? → MVP playtest.
- Can one archivist scene be tense with no timer? → MVP playtest.
- How do characters appear on screen (walking avatars in 2–4 directions, or hotspot plates with cuts and portraits)? → decided from the MVP pipeline proof's measured times; creative-director owns the call.

---

## MVP Definition

**Core hypothesis**: Players find piecing facts together and choosing what to
file tense, and understand the dossier change without explanation.

**Required for MVP**:
1. One archivist scene: an office with six documents and two conversations.
2. Fact extraction and connection (two facts link to unlock a question).
3. One filing decision that changes a dossier on screen.
4. The state reacting within the same session (a phone call or a visit), triggered by dossier state.
5. **Art pipeline proof**: one final-quality painted plate, the document and UI asset set, one character and one walk cycle, produced through the real AI-generate-and-paint-over workflow and timed end to end. The times decide the character-presentation question and feed the full-scope estimate.
6. Story-simulator tests covering the filing decision and the reactive event.

**Explicitly NOT in MVP** (defer to later):
- The dissident and conscript protagonists, and their dossier views (signs, orders)
- The calendar and the fall
- Mid-scene saves

### Scope Tiers (if budget/time shrinks)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | One archivist scene + art pipeline proof | Investigation, dossier write, one reactive event, simulator tests | 4–6 weeks |
| **Vertical Slice** | One chapter per protagonist, ~6 locations, 20–40 min, closes on an ending beat (agreed fallback, decided in advance: archivist + dissident with the conscript present as an order or dossier entry; see systems-index Creative Director Note) | Full dossier system, three views, one cross-chapter payoff, Carbon Copy art, scene-boundary saves. Ships standalone as a prologue/demo. **Go/no-go gate here.** | 4–6 months from start |
| **Skeleton** | Every act and ending of the core outlined and wired at low fidelity | All endings reachable via dossier state; simulator proves it | Immediately after the slice |
| **Core (shippable)** | 3 acts × 3 chapters + finale, ~18–20 locations, ~12 characters, ~35–40k words, 5–6 h | Everything, final art and audio, all endings | 14–18 months (producer estimate) |
| **Full Vision (stretch)** | + acts 4–5: ~30 locations, ~18 characters, ~60k words, 8–10 h | Depth only; the core is already complete | 24–30 months |

---

## Next Steps

- [x] Engine configured (`/setup-engine`: Godot 4.7, GDScript)
- [ ] `/art-bible` from the Visual Identity Anchor
- [ ] `/design-review design/gdd/game-concept.md`
- [ ] `/prototype` the MVP archivist scene (is reading-and-filing tense?)
- [ ] `/map-systems` → `/design-system` per system
- [ ] `/create-architecture` → `/architecture-decision` for the six ADRs the technical director requires before MVP code: (1) dossier data model, flag budget and ownership; (2) rule/trigger format and story-simulator contract; (3) dialogue and document authoring format or addon, after a 4.7 compatibility spike; (4) save format and save points; (5) renderer choice and stamp-red overlay method, after the spike; (6) stretch, resolution and plate-authoring standard
- [ ] `/test-setup` (gdUnit4 on the installed 4.7.x) before the first Logic story
- [ ] `/vertical-slice` before committing to sprints
- [ ] `/sprint-plan new`
