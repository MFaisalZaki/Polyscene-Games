# PROTOTYPE - NOT FOR PRODUCTION
# Question: Can polyscene enumerate the admissible story branches of Paper Walls?
# Date: 2026-11-03
"""The Paper Walls topic: the world of the first act as polyscene sees it.

Run with polyscene's own venv:
    /home/user/polyscene/venv/bin/python run.py
"""
import os

from polyscene import ScenarioEngine, Scenario, Topic
from unified_planning.io import PDDLReader

HERE = os.path.dirname(os.path.abspath(__file__))

# how each action class reads as a beat; {0} {1} {2} are the action's arguments
PROSE = {
    'read-file':            '{0} reads report 4471 to the end: the parcel was medicine.',
    'file-report':          '{0} enters 4471 in the ledger. {1} is now under observation; the household file is complete.',
    'burn-report':          '{0} burns 4471. The ledger now has a gap with her name beside it.',
    'warn':                 '{0} knocks on {1}\'s door after dark and says: not on Tuesdays. Not any Tuesday.',
    'leak-file':            '{0} slips the report to {1}.',
    'print-leaflets':       '{0} runs the press all night.',
    'distribute':           '{0} puts the leaflets on every landing in the district.',
    'expose-informer':      '{0} prints the name of the informer: {1}.',
    'inform':               '{0} reports {1} to the Records Office.',
    'raid':                 '{0} raids the print shop; {1} is taken.',
    'query-ledger':         '{0} telephones {1}: report 4471, where is it?',
    'order-fire':           '{0} orders {1}\'s unit to hold the line with live rounds.',
    'obey-order':           '{0} obeys {1}. The unit fires on the crowd.',
    'stand-down':           '{0} lowers the rifle. The gate stays open.',
    'crowd-gathers':        'A crowd gathers at the {0}.',
    'regime-falls-quietly': 'The regime falls. Nobody fires.',
    'regime-falls-bloody':  'The regime falls, after the shooting.',
}


class PaperWallsScenario(Scenario):
    """Reads a telling back as prose, one line per beat."""

    def pretty(self, name):
        return str(name).replace('-', ' ')

    def opening(self):
        return ('Friday 6 October 1989. Vera Halm has report 4471 on her desk. '
                'Jan has a press and no leaflets. Tomas is at the border. '
                'Rybar is waiting for the ledger.')

    def telling(self):
        lines = []
        for v, b in self.assumed:
            read = (' (read at ' + ', '.join(map(str, self.rests_on[v])) + ')'
                    if v in self.rests_on else '')
            lines.append(f'  assuming {v} = {b}{read}')
        for (t, _, is_world), ai in zip(self.beats, self.plan.actions):
            name = self._base(ai.action.name)
            args = [self.pretty(p).capitalize() for p in ai.actual_parameters]
            text = PROSE.get(name, name + ' ' + ' '.join(args))
            try:
                text = text.format(*args)
            except IndexError:
                pass
            mark = '  [world]' if is_world else ''
            lines.append(f'  {t:>2}. {text}{mark}')
        if self.features.get('fate'):
            lines.append(f'  — fate: {self.features["fate"]}')
        return '\n'.join(lines)


class PaperWallsTopic(Topic):
    name = 'paper-walls'
    domain = os.path.join(HERE, 'paper-walls.pddl')
    instance = os.path.join(HERE, 'paper-walls-init.pddl')
    encodings = (os.path.join(HERE, 'paper-walls.lp'),)
    scenario_class = PaperWallsScenario
    class_predicates = ('actionIntensity', 'actionSign', 'sustainedClass')

    def ground(self):
        return PDDLReader().parse_problem(self.domain, self.instance)

    def facts(self, task):
        return ''


def engine(horizon=9, assume_min=None):
    args = ['-c', 'min_len=1'] + ([] if assume_min is None else ['-c', f'assume_min={assume_min}'])
    return ScenarioEngine(PaperWallsTopic(), horizon=horizon, solver_args=args)
