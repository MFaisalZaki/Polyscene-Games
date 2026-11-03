%% PROTOTYPE - NOT FOR PRODUCTION
%% Question: Can polyscene enumerate the admissible story branches of Paper Walls?
%% Date: 2026-11-03
%%
%% paper-walls.lp -- the topic's rows: who the agents are and what they want, how each
%% action class reads, what the world does on its own, what is unknown at the opening,
%% and the two axes the branch space is spread on. Written against polyscene's encodings
%% at commit 0a0e8cb (preference/4, the no-gap pulse, licences as warrants).

#program base.

% --- the cast ---------------------------------------------------------------------------
agent(A) :- has(A, type("agent")).

% --- the world's own moves: a crowd, and the two ways the regime falls -------------------
happening(action(("crowd_gathers",L)))        :- action(action(("crowd_gathers",L))).
worldAction(A) :- happening(A).
window(A, 3, 12) :- happening(A).

% --- how each class reads: intensity (coercion) and sign (warm / cold) ------------------
actionIntensity("raid",            3).  actionSign("raid",            pos).
actionIntensity("order_fire",      3).  actionSign("order_fire",      pos).
actionIntensity("obey_order",      3).  actionSign("obey_order",      pos).
actionIntensity("query_ledger",    2).  actionSign("query_ledger",    pos).
actionIntensity("inform",          2).  actionSign("inform",          pos).
actionIntensity("file_report",     2).  actionSign("file_report",     pos).
actionIntensity("expose_informer", 2).  actionSign("expose_informer", pos).
actionIntensity("distribute",      1).  actionSign("distribute",      pos).
actionIntensity("print_leaflets",  1).  actionSign("print_leaflets",  pos).
actionIntensity("burn_report",     1).  actionSign("burn_report",     neg).
actionIntensity("leak_file",       1).  actionSign("leak_file",       neg).
actionIntensity("warn",            0).  actionSign("warn",            neg).
actionIntensity("stand_down",      0).  actionSign("stand_down",      neg).
actionIntensity("read_file",       0).
% the officer's orders and the informer's reports are directed at their target (0,1);
% leak_file is directed at the dissident; the rest are (0,1) by default or not dyads
principals("leak_file", 0, 1).
dyadExempt("file_report"). dyadExempt("burn_report"). dyadExempt("warn"). dyadExempt("read_file").
dyadExempt("print_leaflets"). dyadExempt("distribute"). dyadExempt("expose_informer").
dyadExempt("stand_down"). dyadExempt("query_ledger"). dyadExempt("raid").

numBound(variable(("unrest",L)),    0, 10) :- has(L, type("place")).
numBound(variable(("attention",X)), 0, 5)  :- has(X, type("object")).

% --- what each agent wants (PDDL3-style preferences; the objective of each actor) --------
% Vera: a complete household file (the daughter's review), but not Marta watched; the report
% gone, Marta warned; herself unwatched
preference(constant("vera"), variable(("household_complete", constant("vera"))),  true,  3).
preference(constant("vera"), variable(("under_observation",  constant("marta"))), false, 2).
preference(constant("vera"), variable(("burned",             constant("marta"))), true,  2).
preference(constant("vera"), variable(("warned",             constant("marta"))), true,  3).
preference(constant("vera"), variable(("knows_parcel",       constant("vera"))),  true,  1).
preference(constant("vera"), variable(("has_file",           constant("jan"))),   true,  2).
preference(constant("vera"), variable(("under_observation",  constant("vera"))),  false, 3).
preference(constant("vera"), variable(("attention",          constant("vera"))),  down,  1).
% Jan: leaflets out, the informer named, himself free
preference(constant("jan"), variable(("leaflets_printed",     constant("jan"))),    true,  1).
preference(constant("jan"), variable(("leaflets_distributed", constant("jan"))),    true,  3).
preference(constant("jan"), variable(("informer_exposed",     constant("kastan"))), true,  2).
preference(constant("jan"), variable(("arrested",             constant("jan"))),    false, 4).
preference(constant("jan"), variable(("attention",            constant("jan"))),    down,  1).
% Kastan: the dissident watched
preference(constant("kastan"), variable(("under_observation", constant("jan"))), true, 2).
% Rybar: order, the dissident taken, the ledger complete, the archivist in line, the line held
preference(constant("rybar"), variable(("unrest",            constant("border"))), down, 1).
preference(constant("rybar"), variable(("arrested",          constant("jan"))),    true, 3).
preference(constant("rybar"), variable(("filed",             constant("marta"))),  true, 1).
preference(constant("rybar"), variable(("under_observation", constant("vera"))),   true, 2).
preference(constant("rybar"), variable(("ordered_fire",      constant("tomas"))),  true, 2).
% Tomas: not to fire; the gate open
preference(constant("tomas"), variable(("fired_on_crowd", constant("border"))), false, 4).
preference(constant("tomas"), variable(("stood_down",     constant("border"))), true,  2).

% --- what may not co-hold -----------------------------------------------------------------
incompatible(variable(("fired_on_crowd", constant("border"))), true,
             variable(("stood_down",     constant("border"))), true).

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
% the informer informs only if he is still loyal (unknown)
licence(A, loyal,      is(variable(("kastan_loyal",     constant("kastan"))), true)) :- actClass(A, "inform").
% the officer queries the ledger only if vindictive (unknown)
licence(A, vindictive, is(variable(("rybar_vindictive", constant("rybar"))),  true)) :- actClass(A, "query_ledger").
% the conscript stands down only if the garrison wavers (unknown) or the leaflets are out
licence(A, wavers,     is(variable(("garrison_wavers",  constant("border"))), true)) :- actClass(A, "stand_down").
licence(A, leaflets,   is(variable(("leaflets_distributed", constant("jan"))), true)) :- actClass(A, "stand_down").
% a crowd gathers only once the leaflets are out or the informer is named
licence(A, leaflets,   is(variable(("leaflets_distributed", constant("jan"))), true)) :- actClass(A, "crowd_gathers").
licence(A, exposed,    is(variable(("informer_exposed", constant("kastan"))), true))  :- actClass(A, "crowd_gathers").

% --- the branch space: two axes of the flowchart -------------------------------------------
featureAxis(fate).        axisDomain(fate, (fell_quiet; fell_bloody; held)).
featureAxis(vera_choice). axisDomain(vera_choice, (filed; burned; warned; leaked; silent)).
featureAxis(jan_fate).    axisDomain(jan_fate, (free; arrested)).

#program check(t).

% the fate is read off the state at the close: the gate open means the regime fell without a
% shot; shots fired with the unrest at 8 or more means it fell in blood; anything else, it held
fell :- query(t), holds1("border_open", constant("border"), t).
fell :- query(t), holds1("fired_on_crowd", constant("border"), t), numval(variable(("unrest", constant("border"))), U, t), U >= 8.
feature(fate, fell_quiet)  :- query(t), holds1("border_open", constant("border"), t).
feature(fate, fell_bloody) :- fell, query(t), not holds1("border_open", constant("border"), t).
feature(fate, held)        :- query(t), not fell.

veraActed :- query(t), holds1("filed",  constant("marta"), t).
veraActed :- query(t), holds1("burned", constant("marta"), t).
veraActed :- query(t), holds1("warned", constant("marta"), t).
veraActed :- query(t), holds1("has_file", constant("jan"), t).
feature(vera_choice, filed)  :- query(t), holds1("filed",  constant("marta"), t).
feature(vera_choice, burned) :- query(t), holds1("burned", constant("marta"), t).
feature(vera_choice, warned) :- query(t), holds1("warned", constant("marta"), t).
feature(vera_choice, leaked) :- query(t), holds1("has_file", constant("jan"), t).
feature(vera_choice, silent) :- query(t), not veraActed.

feature(jan_fate, arrested) :- query(t), holds1("arrested", constant("jan"), t).
feature(jan_fate, free)     :- query(t), not holds1("arrested", constant("jan"), t).
