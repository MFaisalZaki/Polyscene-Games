# PROTOTYPE - NOT FOR PRODUCTION
# Question: Can polyscene's end-state behaviours be shown as a Detroit-style flowchart?
# Date: 2026-11-03
"""Enumerate one witness telling per end-state behaviour and render them as a
single HTML flowchart in the art bible's paper language, plus a JSON export the
game could read. Usage:  python flowchart.py [horizon] [axes...]"""
import json, os, sys, html, time
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import importlib
TOPIC = importlib.import_module(os.environ.get('TOPIC', 'topic'))
engine, PROSE = TOPIC.engine, TOPIC.PROSE
BEATS = getattr(TOPIC, 'BEATS', {})

H = int(sys.argv[1]) if len(sys.argv) > 1 else 10
AXES = sys.argv[2:] or getattr(TOPIC, 'FLOW_AXES', ['fate', 'vera_choice', 'vera_fate', 'jan_fate', 'tomas_choice'])
GROUP = getattr(TOPIC, 'FLOW_GROUP', 'fate')
LABELS = getattr(TOPIC, 'FLOW_LABELS', {})
OUT = os.environ.get('FLOW_OUT', 'flowchart')

e = engine(horizon=H, assume_min=0)
t0 = time.time(); found = e.classes(AXES, budget=900, limit=int(os.environ.get('FLOW_LIMIT', '200'))); dt = time.time() - t0
domains = e.axis_domains(AXES)

def beats(s):
    out = []
    for (t, atom, is_world), ai in zip(s.beats, s.plan.actions):
        name = s._base(ai.action.name)
        args = [str(p).replace('-', ' ').capitalize() for p in ai.actual_parameters]
        beat = BEATS.get(name.replace('-', '_'))
        text = beat[0] if beat else PROSE.get(name, name)
        paper = beat[1] if beat else ''
        try: text = text.format(*args)
        except (IndexError, KeyError): pass
        out.append({'step': t, 'actor': args[0] if args else '', 'action': name, 'text': text, 'paper': paper, 'world': is_world})
    return out

records = []
for s in found:
    records.append({'behaviour': s.behaviour, 'assumes': [v for v, b in s.assumed], 'beats': beats(s)})
json.dump({'horizon': H, 'axes': AXES, 'domains': domains, 'exhausted': found.exhausted, 'behaviours': records},
          open(os.path.join(HERE, OUT + '.json'), 'w'), indent=1)

# --- the flowchart ---
FATE_ORDER = ['fell_quiet', 'fell_bloody', 'held_bloody', 'held']
FATE_LABEL = {'fell_quiet': 'THE REGIME FALLS — NOBODY FIRES', 'fell_bloody': 'THE REGIME FALLS — AFTER THE SHOOTING',
              'held_bloody': 'THE REGIME HOLDS — AFTER THE SHOOTING', 'held': 'THE REGIME HOLDS', **LABELS}
def cell(v): return ', '.join(v) if isinstance(v, list) else str(v)
groups = {}
for r in records:
    g = r['behaviour'].get(GROUP, 'other'); g = g[0] if isinstance(g, list) and g else g
    groups.setdefault(str(g), []).append(r)
coverage = []
for ax in AXES:
    seen = {cell(r['behaviour'].get(ax)) for r in records}
    coverage.append((ax, [(str(v), str(v) in seen) for v in domains.get(ax, [])]))

css = """
:root{--bone:#D8CDB2;--ui:#EDE4CC;--concrete:#585A57;--green:#6B7664;--carbon:#434C7C;--ctext:#2E3559;--red:#B5241C;--soot:#1B1917;--ochre:#8F7748}
body{margin:0;background:var(--concrete);font-family:"Courier New",Courier,monospace;color:var(--soot)}
header{background:var(--ui);border-bottom:3px solid var(--soot);padding:18px 28px}
h1{margin:0;font-size:20px;letter-spacing:4px}h1 small{letter-spacing:0;font-size:12px;color:var(--concrete);display:block;margin-top:6px}
.cov{display:flex;gap:18px;flex-wrap:wrap;margin-top:12px;font-size:12px}.cov div{border:2px solid var(--soot);padding:6px 10px;background:var(--ui)}
.cov b{letter-spacing:2px;display:block;margin-bottom:4px}.ok{color:var(--ctext);text-decoration:underline dotted}.no{color:#9a9480;text-decoration:line-through}
main{padding:20px 28px}.fate{margin:26px 0 10px;font-size:13px;letter-spacing:3px;background:var(--ui);border:2px solid var(--soot);padding:6px 12px;display:inline-block}
.fate.red{border-color:var(--red);color:var(--red)}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(360px,1fr));gap:16px}
.card{background:var(--ui);border:2px solid var(--soot);padding:12px 14px;position:relative;font-size:12px}
.card:before{content:"";position:absolute;left:14px;top:-5px;width:16px;height:6px;background:var(--concrete)}
.tab{position:absolute;right:-2px;top:-14px;background:var(--ui);border:2px solid var(--soot);border-bottom:none;padding:1px 8px;font-size:10px;letter-spacing:2px}
.state{display:grid;grid-template-columns:1fr 1fr;gap:2px 10px;margin-bottom:8px;border-bottom:2px dashed var(--concrete);padding-bottom:8px}
.state span b{letter-spacing:1px;color:var(--concrete);font-weight:normal;font-size:10px}
.assume{color:var(--ctext);text-shadow:1px 1px 0 var(--carbon);margin-bottom:6px}
ol{margin:0;padding-left:22px}li{margin:3px 0}li.world{color:var(--concrete)}li.world:before{content:"[world] ";color:var(--red);font-size:10px}
.paper{margin:2px 0 4px;padding:2px 6px;border-left:3px solid var(--carbon);color:var(--ctext);font-size:11px;text-shadow:1px 1px 0 rgba(67,76,124,.35)}
.stamp{position:absolute;right:12px;bottom:10px;width:30px;height:30px;border:3px solid var(--red);opacity:.6;background:repeating-linear-gradient(45deg,transparent 0 3px,var(--red) 3px 4px)}
"""
parts = [f"<!doctype html><html lang='en'><head><meta charset='utf-8'><title>Paper Walls — act one branches</title><style>{css}</style></head><body>",
         f"<header><h1>PAPER WALLS — ACT ONE, EVERY ADMISSIBLE END STATE<small>{len(records)} behaviours on {len(AXES)} axes, horizon {H}, "
         f"{'exhaustive' if found.exhausted else 'NOT exhaustive'}, enumerated in {dt:.1f}s by polyscene. Each card is one witness telling; the assumption line is what that future rests on.</small></h1><div class='cov'>"]
for ax, vals in coverage:
    parts.append(f"<div><b>{html.escape(ax)}</b>" + ' · '.join(f"<span class='{'ok' if ok else 'no'}'>{html.escape(v)}</span>" for v, ok in vals) + "</div>")
parts.append("</div></header><main>")
for fate in FATE_ORDER + [f for f in groups if f not in FATE_ORDER]:
    if fate not in groups: continue
    parts.append(f"<div class='fate {'red' if 'bloody' in fate else ''}'>{html.escape(FATE_LABEL.get(fate, fate))} · {len(groups[fate])}</div><div class='grid'>")
    for i, r in enumerate(groups[fate], 1):
        b = r['behaviour']
        parts.append(f"<div class='card'><div class='tab'>{html.escape(fate.upper())} {i}</div><div class='state'>")
        for ax in AXES:
            if ax == GROUP: continue
            parts.append(f"<span><b>{html.escape(ax)}</b><br>{html.escape(cell(b.get(ax, '')))}</span>")
        parts.append("</div>")
        if r['assumes']:
            parts.append("<div class='assume'>assuming " + ' · '.join(html.escape(a.split('"')[1].replace('_', ' ')) for a in r['assumes']) + "</div>")
        parts.append("<ol>" + ''.join(f"<li class='{'world' if x['world'] else ''}'>{html.escape(x['text'])}" + (f"<div class='paper'>{html.escape(x['paper'])}</div>" if x.get('paper') else '') + "</li>" for x in r['beats']) + "</ol>")
        parts.append("<div class='stamp'></div></div>")
    parts.append("</div>")
parts.append("</main></body></html>")
open(os.path.join(HERE, OUT + '.html'), 'w').write('\n'.join(parts))
print(f'{len(records)} behaviours, exhausted={found.exhausted}, {dt:.1f}s -> {OUT}.html, {OUT}.json')
