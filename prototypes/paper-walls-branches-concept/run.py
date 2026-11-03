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

H = int(sys.argv[1]) if len(sys.argv) > 1 else 10

with warnings.catch_warnings(record=True) as w:
    warnings.simplefilter('always')
    t0 = time.time(); e = engine(horizon=H); print(f'[compiled and grounded in {time.time()-t0:.1f}s, horizon {H}]')
    for x in w: print('WARNING:', x.message)

print('\n=== 1. cheapest tellings (k=6) ===')
t0 = time.time(); found = e.outcome(budget=60, k=6); print(f'[{len(found)} tellings in {time.time()-t0:.1f}s; pool dry: {found.exhausted}]')
print(found.narrate())

AXES = ['fate', 'vera_choice', 'vera_fate', 'jan_fate', 'tomas_choice']
print('\n=== 2. the branch space on', AXES, '===')
e2 = engine(horizon=H, assume_min=0)
t0 = time.time(); cls = e2.classes(AXES, budget=300, limit=80)
print(f'[{len(cls)} behaviours in {time.time()-t0:.1f}s; exhausted: {cls.exhausted}]')
print(cls.feature_table())
print(e2.coverage_table(cls, AXES) if hasattr(e2, 'coverage_table') else '')
for i, s in enumerate(cls, 1):
    print(f'\n--- behaviour {i}: {s.behaviour}')
    print(s.telling())

print('\n=== 3. diagnoses ===')
pin = (':- not occurs(action(("file_report",constant("vera"),constant("marta"),constant("kastan"))),1).\n'
       ':- query(T), holds1("arrested", constant("jan"), T).\n:- query(T), holds1("under_observation", constant("jan"), T).\n'
       ':- query(T), holds1("recanted", constant("jan"), T).\n')
print('Vera files, and nothing ever happens to Jan ->', e.diagnose(budget=60, extra_text=pin))
pin4 = ':- query(T), not holds1("turned", constant("jan"), T).\n'
print('Jan is turned ->', e.diagnose(budget=60, extra_text=pin4))
pin5 = ':- query(T), not holds1("fired_on_crowd", constant("border"), T).\n:- query(T), not holds1("panicking", constant("border"), T).\n'
print('The regime panics and the unit fires ->', e.diagnose(budget=60, extra_text=pin5))
pin2 = ':- not occurs(action(("warn",constant("vera"),constant("marta"))),2).\n:- query(T), numval(variable(("attention", constant("vera"))), X, T), X > 0.\n'
print('Vera warns Marta and pays nothing ->', e.diagnose(budget=60, extra_text=pin2))
pin3 = ':- not occurs(action(("stand_down",constant("tomas"),constant("border"))),4).\n'
print('Tomas stands down at step 4 ->', e.diagnose(budget=60, extra_text=pin3))
