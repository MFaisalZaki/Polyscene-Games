%% PROTOTYPE - NOT FOR PRODUCTION
%% Question: Can polyscene enumerate the admissible story branches of Paper Walls?
%% Date: 2026-11-03
%%
%% paper-walls.lp -- the topic's rows: who the agents are and what they want, how each action
%% class reads, the world's own motion, what is unknown at the opening, the game's own laws,
%% and the axes the branch space is read on. Nothing here names a path: the engine returns end
%% states reached by admissible tellings, and the axes read those end states.
%% Written against polyscene's encodings at commit 0a0e8cb.

#program base.

% --- the cast ---------------------------------------------------------------------------
agent(A) :- has(A, type("agent")).

% --- the world's own moves: a crowd, and the regime's phases --------------------------------
happening(action(("crowd_gathers",L)))  :- action(action(("crowd_gathers",L))).
happening(action(("regime_wavers",L)))  :- action(action(("regime_wavers",L))).
happening(action(("regime_panics",L)))  :- action(action(("regime_panics",L))).
worldAction(A) :- happening(A).
window(action(("crowd_gathers",L)), 3, 12) :- action(action(("crowd_gathers",L))).
window(action(("regime_wavers",L)), 4, 12) :- action(action(("regime_wavers",L))).
window(action(("regime_panics",L)), 5, 12) :- action(action(("regime_panics",L))).
% a crowd needs the leaflets out or the informer named; the regime wavers for the same reasons;
% it panics only with a crowd in the street (a precondition) and the gate still shut
licence(A, leaflets, is(variable(("leaflets_distributed", constant("jan"))), true)) :- actClass(A, "crowd_gathers").
licence(A, exposed,  is(variable(("informer_exposed", constant("kastan"))), true))  :- actClass(A, "crowd_gathers").
licence(A, leaflets, is(variable(("leaflets_distributed", constant("jan"))), true)) :- actClass(A, "regime_wavers").
licence(A, exposed,  is(variable(("informer_exposed", constant("kastan"))), true))  :- actClass(A, "regime_wavers").
licence(A, shut,     is(variable(("border_open", constant("border"))), false))       :- actClass(A, "regime_panics").
% the world's own numeric motion: unrest climbs while the leaflets are out; stability drains
% while a crowd stands at the gate
driftWhile(variable(("unrest",    constant("border"))),  1, 2, variable(("leaflets_distributed", constant("jan")))).
driftWhile(variable(("stability", constant("border"))), -1, 2, variable(("crowd_at", constant("border")))).

% --- how each class reads: intensity (coercion) and sign (warm / cold) ------------------
actionIntensity("raid",                 3).  actionSign("raid",                 pos).
actionIntensity("order_fire",           3).  actionSign("order_fire",           pos).
actionIntensity("obey_order",           3).  actionSign("obey_order",           pos).
actionIntensity("turn_informer",        3).  actionSign("turn_informer",        pos).
actionIntensity("query_ledger",         2).  actionSign("query_ledger",         pos).
actionIntensity("inform",               2).  actionSign("inform",               pos).
actionIntensity("report_neighbour",     2).  actionSign("report_neighbour",     pos).
actionIntensity("inform_on_archivist",  2).  actionSign("inform_on_archivist",  pos).
actionIntensity("file_report",          2).  actionSign("file_report",          pos).
actionIntensity("recover_report",       2).  actionSign("recover_report",       pos).
actionIntensity("expose_informer",      2).  actionSign("expose_informer",      pos).
actionIntensity("distribute",           1).  actionSign("distribute",           pos).
actionIntensity("print_leaflets",       1).  actionSign("print_leaflets",       pos).
actionIntensity("burn_report",          1).  actionSign("burn_report",          neg).
actionIntensity("leak_file",            1).  actionSign("leak_file",            neg).
actionIntensity("recant",               1).  actionSign("recant",               neg).
actionIntensity("warn",                 0).  actionSign("warn",                 neg).
actionIntensity("stand_down",           0).  actionSign("stand_down",           neg).
actionIntensity("read_file",            0).
% dyads: the beats aimed at another agent (actor, target); the rest are not dyads
principals("leak_file", 0, 1).
dyadExempt("file_report"). dyadExempt("burn_report"). dyadExempt("recover_report"). dyadExempt("warn").
dyadExempt("read_file"). dyadExempt("print_leaflets"). dyadExempt("distribute").
dyadExempt("expose_informer"). dyadExempt("recant"). dyadExempt("stand_down").
dyadExempt("raid"). dyadExempt("query_ledger"). dyadExempt("report_neighbour").

numBound(variable(("unrest",    L)), 0, 12) :- has(L, type("place")).
numBound(variable(("stability", L)), 0, 10) :- has(L, type("place")).
numBound(variable(("attention", X)), 0, 6)  :- has(X, type("object")).

% --- what each agent wants (the objective of each actor) ---------------------------------
% Vera: the household file complete; Marta neither watched nor betrayed; the report gone;
% Jan armed with it; herself unwatched and unnoticed
preference(constant("vera"), variable(("household_complete", constant("vera"))),  true,  4).
preference(constant("vera"), variable(("under_observation",  constant("marta"))), false, 1).
preference(constant("vera"), variable(("burned",             constant("marta"))), true,  2).
preference(constant("vera"), variable(("warned",             constant("marta"))), true,  3).
preference(constant("vera"), variable(("knows_parcel",       constant("vera"))),  true,  1).
preference(constant("vera"), variable(("has_file",           constant("jan"))),   true,  2).
preference(constant("vera"), variable(("under_observation",  constant("vera"))),  false, 3).
preference(constant("vera"), variable(("attention",          constant("vera"))),  down,  1).
% Jan: leaflets out, the informer named, himself free, unwatched, and not a traitor
preference(constant("jan"), variable(("leaflets_printed",     constant("jan"))),    true,  2).
preference(constant("jan"), variable(("leaflets_distributed", constant("jan"))),    true,  3).
preference(constant("jan"), variable(("informer_exposed",     constant("kastan"))), true,  2).
preference(constant("jan"), variable(("arrested",             constant("jan"))),    false, 4).
preference(constant("jan"), variable(("under_observation",    constant("jan"))),    false, 2).
preference(constant("jan"), variable(("recanted",             constant("jan"))),    false, 1).
preference(constant("jan"), variable(("released",             constant("jan"))),    true,  3).
preference(constant("jan"), variable(("attention",            constant("jan"))),    down,  1).
% Kastan: the dissident and the archivist watched
preference(constant("kastan"), variable(("under_observation", constant("jan"))),  true, 2).
preference(constant("kastan"), variable(("under_observation", constant("vera"))), true, 2).
% Rybar: order; the dissident taken or turned; the ledger complete; the archivist in line
preference(constant("rybar"), variable(("unrest",            constant("border"))), down, 1).
preference(constant("rybar"), variable(("arrested",          constant("jan"))),    true, 3).
preference(constant("rybar"), variable(("turned",            constant("jan"))),    true, 4).
preference(constant("rybar"), variable(("filed",             constant("marta"))),  true, 1).
preference(constant("rybar"), variable(("under_observation", constant("vera"))),   true, 2).
preference(constant("rybar"), variable(("ordered_fire",      constant("tomas"))),  true, 2).
% Tomas: not to fire; the gate open; his unit safe; no desertion on his record
preference(constant("tomas"), variable(("fired_on_crowd", constant("border"))), false, 4).
preference(constant("tomas"), variable(("stood_down",     constant("border"))), true,  3).
preference(constant("tomas"), variable(("unit_safe",      constant("tomas"))),  true,  2).
preference(constant("tomas"), variable(("deserted",       constant("tomas"))),  false, 2).

% --- what may not co-hold -----------------------------------------------------------------
incompatible(variable(("fired_on_crowd", constant("border"))), true,
             variable(("stood_down",     constant("border"))), true).
incompatible(variable(("arrested", constant("jan"))), true, variable(("turned", constant("jan"))), true).

% --- what is unknown at the opening: three premises a telling may assume -------------------
premiseFluent(variable(("kastan_loyal",     constant("kastan")))).
premiseFluent(variable(("garrison_wavers",  constant("border")))).
premiseFluent(variable(("rybar_vindictive", constant("rybar")))).
variable(V) :- premiseFluent(V).
unknown(V)  :- premiseFluent(V).
% The engine's README describes assumptions over unknown fluents (assumed/2, assume_min), but the
% encodings at commit 0a0e8cb carry no such rules, so the topic states the mechanism itself: a
% telling may take an unknown fluent to hold at the opening (an initialState atom, so the
% engine's closed-world default and inertia treat it like any other), each assumption costs one,
% and the objective is switched off with -c assume_min=0 (needed for classes()).
#const assume_min = 1.
{ initialState(V, value(V, true)) } :- unknown(V).
assumed(V, true) :- unknown(V), initialState(V, value(V, true)).
#show assumed/2.
#minimize { 1@1,V : assumed(V, true), assume_min = 1 }.

% --- licences: the surprising classes need a warrant at their step ---------------------------
% the informer informs on Jan if he is still loyal (unknown) OR a filed report has just paid him:
% this is the archivist's filing reaching the dissident's life through the dossier
licence(A, loyal,     is(variable(("kastan_loyal",    constant("kastan"))), true)) :- actClass(A, "inform").
licence(A, rewarded,  is(variable(("kastan_rewarded", constant("kastan"))), true)) :- actClass(A, "inform").
licence(A, loyal,     is(variable(("kastan_loyal",    constant("kastan"))), true)) :- actClass(A, "report_neighbour").
licence(A, rewarded,  is(variable(("kastan_rewarded", constant("kastan"))), true)) :- actClass(A, "report_neighbour").
% the conscript stands down only when the regime wavers (a precondition) and either the
% garrison wavers with it (unknown) or the leaflets have reached the barracks
licence(A, wavers,    is(variable(("garrison_wavers", constant("border"))), true))      :- actClass(A, "stand_down").
licence(A, leaflets,  is(variable(("leaflets_distributed", constant("jan"))), true))     :- actClass(A, "stand_down").
% the officer orders fire only in panic, or if vindictive; he turns a prisoner on the same terms
licence(A, panic,     is(variable(("panicking", constant("border"))), true))             :- actClass(A, "order_fire").
licence(A, vindictive, is(variable(("rybar_vindictive", constant("rybar"))), true))      :- actClass(A, "order_fire").
licence(A, panic,     is(variable(("panicking", constant("border"))), true))             :- actClass(A, "turn_informer").
licence(A, vindictive, is(variable(("rybar_vindictive", constant("rybar"))), true))      :- actClass(A, "turn_informer").

% --- the game's own laws (Pillar 3: no one is clean) -------------------------------------------
% A courage beat must cost its actor something it cares about; a cowardice beat must protect
% something its actor cares about. Both read the engine's objective terms (gainTerm/4, laws.lp).
law(costless_courage).
law(unprotected_cowardice).
law(paid_silence).   % a paid informer who never files, while he is still unexposed, is not a telling
courageClass("warn").  courageClass("burn_report").  courageClass("leak_file").
courageClass("stand_down").  courageClass("expose_informer").  courageClass("print_leaflets").
courageClass("distribute").
cowardiceClass("file_report").  cowardiceClass("recover_report").  cowardiceClass("obey_order").
cowardiceClass("inform").  cowardiceClass("report_neighbour").  cowardiceClass("recant").
cowardiceClass("inform_on_archivist").  cowardiceClass("turn_informer").

#program step(t).
costs(A, t)    :- gainTerm(A, _, W, t), W < 0.
protects(A, t) :- gainTerm(A, _, W, t), W > 0.
broken(costless_courage, t)      :- agentActed(t), actor(A, t), eventName(C, t), courageClass(C),   not costs(A, t).
broken(unprotected_cowardice, t) :- agentActed(t), actor(A, t), eventName(C, t), cowardiceClass(C), not protects(A, t).
everInformed(t) :- eventName("inform", t).
everInformed(t) :- eventName("report_neighbour", t).
everInformed(t) :- everInformed(t-1).
paidAt(t) :- holds1("kastan_rewarded", constant("kastan"), t), not holds1("kastan_rewarded", constant("kastan"), t-1).
paidAt(t) :- paidAt(t-1).

#program check(t).
broken(paid_silence, t) :- query(t), paidAt(T), T + 2 <= t, not everInformed(t),
                           not holds1("informer_exposed", constant("kastan"), t).
#program base.

#program base.
% --- the branch space: axes read off the END STATE -------------------------------------------
featureAxis(fate).         axisDomain(fate, (fell_quiet; fell_bloody; held; held_bloody)).
featureAxis(vera_choice).  axisDomain(vera_choice, (filed; burned; warned; leaked; silent)).
featureAxis(vera_fate).    axisDomain(vera_fate, (unwatched; watched)).
featureAxis(jan_fate).     axisDomain(jan_fate, (free; arrested; turned; recanted)).
featureAxis(tomas_choice). axisDomain(tomas_choice, (none; fired; stood_down)).

#program check(t).
fired     :- query(t), holds1("fired_on_crowd", constant("border"), t).
gateOpen  :- query(t), holds1("border_open",    constant("border"), t).
wavering  :- query(t), holds1("wavering",       constant("border"), t).
panicking :- query(t), holds1("panicking",      constant("border"), t).
lowStab   :- query(t), numval(variable(("stability", constant("border"))), S, t), S <= 3.
feature(fate, fell_quiet)  :- gateOpen, wavering, lowStab.
feature(fate, fell_bloody) :- fired, panicking, lowStab.
feature(fate, held_bloody) :- fired, query(t), not feature(fate, fell_bloody).
feature(fate, held)        :- query(t), not fired, not feature(fate, fell_quiet).

feature(vera_choice, filed)  :- query(t), holds1("filed",    constant("marta"), t).
feature(vera_choice, burned) :- query(t), holds1("burned",   constant("marta"), t).
feature(vera_choice, warned) :- query(t), holds1("warned",   constant("marta"), t).
feature(vera_choice, leaked) :- query(t), holds1("has_file", constant("jan"),   t).
veraActed :- feature(vera_choice, V), V != silent.
feature(vera_choice, silent) :- query(t), not veraActed.
feature(vera_fate, watched)   :- query(t), holds1("under_observation", constant("vera"), t).
feature(vera_fate, unwatched) :- query(t), not holds1("under_observation", constant("vera"), t).

feature(jan_fate, arrested) :- query(t), holds1("arrested", constant("jan"), t).
feature(jan_fate, turned)   :- query(t), holds1("turned",   constant("jan"), t).
feature(jan_fate, recanted) :- query(t), holds1("recanted", constant("jan"), t), not holds1("arrested", constant("jan"), t), not holds1("turned", constant("jan"), t).
janDone :- feature(jan_fate, V), V != free.
feature(jan_fate, free)     :- query(t), not janDone.
feature(tomas_choice, fired)      :- fired.
feature(tomas_choice, stood_down) :- query(t), holds1("stood_down", constant("border"), t).
feature(tomas_choice, none)       :- query(t), not fired, not holds1("stood_down", constant("border"), t).
