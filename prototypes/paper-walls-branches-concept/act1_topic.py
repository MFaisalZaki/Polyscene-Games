# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does the act-one brief, as a polyscene world, yield the nine ending classes?
# Date: 2026-11-03
"""The act-one topic: the world of Plan Weeks 40 and 41 as polyscene sees it.
    /home/user/polyscene/venv/bin/python act1_run.py [horizon]
"""
import os
from polyscene import ScenarioEngine, Scenario, Topic
from unified_planning.io import PDDLReader

HERE = os.path.dirname(os.path.abspath(__file__))

PROSE = {
    'read-file':        'Vera reads 4471 to the end. The parcel was medicine. Marta Sokol, flat 3.',
    'file-report':      'Vera enters 4471 in the ledger. Marta is watched; the household file is complete; Kastan is paid.',
    'burn-report':      'Vera burns 4471. The intake log now has a gap, and Berta\'s initials sit beside it.',
    'recover-report':   'Vera gives in: 4471 is re-entered from the carbon. Berta is cleared; Marta is watched.',
    'doctor-ledger':    'Vera re-writes the intake line. There is no gap now, only a forged line under Berta\'s initials.',
    'warn':             'Vera knocks at flat 3 at 23:10 and says: not on Tuesdays. Kastan\'s building book records the hour.',
    'leak-file':        'Vera slips the carbon of 4471 to Jan. Berta\'s count is one short.',
    'take-blame':       'Vera signs for the gap herself. Berta is cleared. The household file is flagged.',
    'report-jan':       'Vera closes the household file on a different name: the cellar\'s.',
    'receive-courier':  'The courier reaches the cellar: paper and ink for Jan, the inhaler for Marta.',
    'print-leaflets':   'Jan runs the press all night.',
    'distribute':       'Jan puts the leaflets on every landing in Lom. The gate at Brenava is tightened.',
    'expose-informer':  'Jan prints the caretaker\'s name. The file is traced to the Records Office.',
    'ask-carbon':       'Jan asks Ilona for her mother\'s carbon.',
    'cut-ilona':        'Jan tells Ilona not to come back. She does not know why.',
    'recant':           'Jan signs the statement. The watch on him is lifted; the press goes quiet.',
    'give-courier':     'In a polite room, Jan gives the courier\'s name. The route is gone.',
    'give-ilona':       'In a polite room, Jan gives Ilona\'s name.',
    'give-vera':        'In a polite room, Jan says where the carbon came from: the archivist.',
    'let-pass-courier': 'Tomas waves the courier through. The gap is in Ondra\'s log.',
    'detain-courier':   'Tomas holds the courier. The parcel goes to the desk; the unit is commended.',
    'let-pass-family':  'Tomas lets the family through the tightened gate. Ondra\'s log again.',
    'detain-family':    'Tomas holds the family at the gate.',
    'confess-gap':      'Under inquiry, Tomas says the line was his. On report; Ondra clear.',
    'name-route':       'Under inquiry, Tomas names the Vienna route. Ondra clear; the route burned.',
    'cover-log':        'Ondra re-writes the line before the captain comes. Now it is false, not short.',
    'report-tomas':     'Ondra tells the captain whose gate it was.',
    'join-circle':      'Ilona sits in on the circle in the cellar.',
    'take-carbon':      'Ilona takes her mother\'s carbon from the desk drawer.',
    'renounce':         'Ilona signs the renunciation and gives the cellar\'s address. A second sitting is granted.',
    'send-word':        'Marta books the Vienna call and says: do not send. Her breath is her own now.',
    'plead-kastan':     'Marta, at one breath, tells Kastan where the Halm girl goes in the evenings.',
    'report-colleague': 'Berta files a memo about the gap. On paper, never aloud.',
    'cover-vera':       'Berta re-initials the line. The ledger balances; the liability is hers.',
    'inform':           'Kastan reports the cellar to the Records Office.',
    'report-neighbour': 'Kastan reports who was at flat 3\'s door after dark.',
    'query-ledger':     'Rybar telephones Vera: report 4471, where is it?',
    'raid':             'Rybar raids the cellar. Jan is taken.',
    'hold-review':      'Rybar holds Ilona\'s review. In writing: the state is waiting for her mother.',
    'list-route':       'Rybar puts the Vienna route on the list at Brenava.',
    'ledger-called':    'A slip on the desk: the District Register is to be reconciled before the inspection.',
    'press-runs-dry':   'The last ream is gone. The circle meets without a sheet to show.',
    'review-convened':  'A card arrives: the admissions review sits this week.',
    'courier-arrives':  'The courier is at the gate with a parcel.',
    'inquiry-at-post':  'A captain comes to the post about the log.',
    'regime-paranoid':  'More paper arrives at every desk. The regime is paranoid.',
    'family-arrives':   'A family tries the gate.',
    'tell-archivist':   'Kastan stops Vera on the stairs: I saw your girl go down to the cellar.',
    'go-to-hospital':   'Marta is taken to hospital. The hospital asks for papers.',
    'review-admits':    'The review sits: Ilona Halm, admitted.',
    'review-defers':    'The review sits: Ilona Halm, deferred.',
    'review-refuses':   'The review sits: Ilona Halm, refused.',
    'marta-collapses':  'Marta is taken to hospital. The hospital asks for papers.',
}

AXES = ['vera_ledger', 'vera_reach', 'vera_fate', 'ilona_review', 'jan_press', 'jan_fate',
        'tomas_gate', 'tomas_cost', 'marta_fate', 'marta_watched', 'berta_fate', 'regime', 'kastan']


class ActOneScenario(Scenario):
    multi_valued_axes = Scenario.multi_valued_axes | {'ending_class'}

    def opening(self):
        return ('Friday, Plan Week 40. Report 4471 on Vera\'s desk, a month old. The household file '
                'incomplete; Ilona\'s review pending. A press with no paper. Ondra has the log. '
                'Marta has two days of medicine.')

    def telling(self):
        lines = [f'  assuming {v.split(chr(34))[1].replace("_", " ")}' for v, b in self.assumed]
        for (t, _, is_world), ai in zip(self.beats, self.plan.actions):
            name = self._base(ai.action.name)
            lines.append(f'  {t:>2}. {PROSE.get(name, name)}{"  [world]" if is_world else ""}')
        end = {k: self.features.get(k) for k in AXES + ['ending_class']}
        lines.append('  — ' + ', '.join(f'{k}={v}' for k, v in end.items() if v is not None))
        return '\n'.join(lines)


class ActOneTopic(Topic):
    name = 'paper-walls-act1'
    domain = os.path.join(HERE, 'act1.pddl')
    instance = os.path.join(HERE, 'act1-init.pddl')
    encodings = (os.path.join(HERE, 'act1.lp'),)
    scenario_class = ActOneScenario
    class_predicates = ('actionIntensity', 'courageClass', 'cowardiceClass', 'turningCourage', 'worldClass')

    def ground(self):
        return PDDLReader().parse_problem(self.domain, self.instance)

    def facts(self, task):
        return ''


def engine(horizon=12, assume_min=None):
    args = ['-c', 'min_len=1'] + ([] if assume_min is None else ['-c', f'assume_min={assume_min}'])
    return ScenarioEngine(ActOneTopic(), horizon=horizon, solver_args=args)
