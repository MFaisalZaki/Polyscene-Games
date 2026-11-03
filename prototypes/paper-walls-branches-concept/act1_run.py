# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does the act-one brief, as a polyscene world, yield the nine ending classes?
# Date: 2026-11-03
"""Measure act one against the brief's coverage targets (section 7)."""
import sys, time, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from act1_topic import engine, AXES
H = int(sys.argv[1]) if len(sys.argv) > 1 else 12
t0 = time.time(); e = engine(horizon=H); print(f'[grounded in {time.time()-t0:.1f}s, horizon {H}]')

def pin_class(k): return f':- query(T), not feature(ending_class, {k}).\n'
classes = ['e1_complete_file','e2_gap','e3_carbon','e4_seized_parcel','e5_open_gate','e6_mothers_trade',
           'e7_daughters_statement','e8_martas_breath','e9_route_burned']
print('\n=== ending classes E1-E9: reachable? (plain solve; if not, the laws that forbid it) ===')
witness = {}
for k in classes:
    ctl = e.fresh(extra_text=pin_class(k)); got = []
    res = ctl.solve(on_model=lambda m: got.append(e._scenario(m)))
    if res.satisfiable:
        witness[k] = got[-1]; print(f'  {k:24s} REACHABLE')
    else:
        print(f'  {k:24s} unreachable; forbidding laws: {e.diagnose(budget=120, extra_text=pin_class(k))}')
e0 = (':- query(T), holds1("filed", constant("marta"), T).\n:- query(T), holds1("burned", constant("marta"), T).\n'
      ':- query(T), holds1("doctored", constant("vera"), T).\n:- query(T), holds1("leaflets_printed", constant("jan"), T).\n'
      ':- query(T), holds1("courier_through", constant("border"), T).\n:- query(T), holds1("courier_detained", constant("border"), T).\n'
      ':- query(T), holds1("family_through", constant("border"), T).\n:- query(T), holds1("family_detained", constant("border"), T).\n'
      ':- query(T), holds1("warned", constant("marta"), T).\n:- query(T), holds1("has_file", constant("jan"), T).\n:- query(T), holds1("reported_jan", constant("vera"), T).\n'
      ':- query(T), holds1("arrested", constant("jan"), T).\n:- query(T), holds1("recanted", constant("jan"), T).\n:- query(T), holds1("exposed", constant("kastan"), T).\n')
print('\nE0 nothing moved -> forbidding laws:', e.diagnose(budget=120, extra_text=e0))
gap = ':- not occurs(action(("burn_report",constant("vera"),constant("marta"),constant("berta"))),1).\n:- acted(T), T > 1, T < 7.\n'
print('Vera burns and nobody notices for a week ->', e.diagnose(budget=120, extra_text=gap))
free = ':- not occurs(action(("let_pass_courier",constant("tomas"),constant("ondra"),constant("border"))),3).\n:- query(T), holds1("liable", constant("ondra"), T).\n:- query(T), holds1("on_report", constant("tomas"), T).\n:- query(T), holds1("route_burned", constant("border"), T).\n'
print('Tomas lets the courier through and nobody pays ->', e.diagnose(budget=120, extra_text=free))

print('\n=== witness tellings per class ===')
for k, s in witness.items():
    print(f'\n--- {k}'); print(s.telling())

print('\n=== the raw behaviour space on the 13 axes (limit 400) ===')
e2 = engine(horizon=H, assume_min=0)
t0 = time.time(); cls = e2.classes(AXES, budget=900, limit=600); print(f'[{len(cls)} behaviours in {time.time()-t0:.1f}s; exhausted: {cls.exhausted}]')
cov = e2.coverage_table(cls, AXES) if hasattr(e2, 'coverage_table') else {}
for ax, vals in cov.items(): print(' ', ax, {v: ('·' if s == 'covered' else 'UNTOLD') for v, s in vals.items()})
