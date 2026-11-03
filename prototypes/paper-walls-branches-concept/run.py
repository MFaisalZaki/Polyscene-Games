# PROTOTYPE - NOT FOR PRODUCTION
# Question: Can polyscene enumerate the admissible story branches of Paper Walls?
# Date: 2026-11-03
"""Three questions to the engine, printed:
  1. the cheapest-assumption tellings (outcome, k=6)
  2. one witness telling per behaviour on (fate, vera_choice, jan_fate): the flowchart
  3. a diagnosis: which laws forbid "Vera files and the regime still falls quietly"
"""
import sys, time, warnings
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from topic import engine

H = int(sys.argv[1]) if len(sys.argv) > 1 else 9

with warnings.catch_warnings(record=True) as w:
    warnings.simplefilter('always')
    t0 = time.time(); e = engine(horizon=H); print(f'[compiled and grounded in {time.time()-t0:.1f}s, horizon {H}]')
    for x in w: print('WARNING:', x.message)

print('\n=== 1. cheapest tellings (k=6) ===')
t0 = time.time(); found = e.outcome(budget=60, k=6); print(f'[{len(found)} tellings in {time.time()-t0:.1f}s; pool dry: {found.exhausted}]')
print(found.narrate())

print('\n=== 2. the branch space on (fate, vera_choice, jan_fate) ===')
e2 = engine(horizon=H, assume_min=0)
t0 = time.time(); cls = e2.classes(['fate', 'vera_choice', 'jan_fate'], budget=120, limit=40)
print(f'[{len(cls)} behaviours in {time.time()-t0:.1f}s; exhausted: {cls.exhausted}]')
print(cls.feature_table())
print(e2.coverage_table(cls, ['fate', 'vera_choice', 'jan_fate']) if hasattr(e2, 'coverage_table') else '')
for i, s in enumerate(cls, 1):
    print(f'\n--- behaviour {i}: {s.behaviour}')
    print(s.telling())

print('\n=== 3. diagnosis: Vera files 4471, and the regime still falls quietly ===')
pin = (':- not occurs(action(("file_report",constant("vera"),constant("marta"))),1).\n'
       ':- query(t), not holds1("regime_fell_quietly", constant("border"), t).\n')
print('laws that forbid it:', e.diagnose(budget=60, extra_text=pin))
