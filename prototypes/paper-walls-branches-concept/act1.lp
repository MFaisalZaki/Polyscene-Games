%% PROTOTYPE - NOT FOR PRODUCTION
%% Question: Does the act-one brief, as a polyscene world, yield the nine ending classes?
%% Date: 2026-11-03
%%
%% act1.lp -- the topic rows for act one, from production/narrative/paper-walls-act-one/brief.md:
%% the cast and what each wants (§2), the world's motion and drift (§3-4), the unknowns and
%% their licences (§5), the game's laws (§6), and the end-state axes and ending classes (§7).
%% Nothing here is a path. Written against polyscene's encodings at commit 0a0e8cb.

#program base.
#const assume_min = 1.

% --- the cast -----------------------------------------------------------------------------
agent(A) :- has(A, type("agent")).
c(vera, constant("vera")).   c(jan, constant("jan")).     c(tomas, constant("tomas")).
c(ondra, constant("ondra")). c(rybar, constant("rybar")). c(kastan, constant("kastan")).
c(marta, constant("marta")). c(ilona, constant("ilona")). c(berta, constant("berta")).
c(marek, constant("marek")). c(border, constant("border")).
c(city, constant("city")).
v1(N, X, variable((N, C))) :- c(X, C), variable(variable((N, C))).

% --- the world's own moves ------------------------------------------------------------------
worldClass("courier_arrives"; "inquiry_at_post"; "regime_paranoid"; "family_arrives";
           "ledger_called"; "press_runs_dry"; "review_convened").
happening(A) :- action(A), actClass(A, N), worldClass(N).
worldAction(A) :- happening(A).
window(A, 2, 4)  :- actClass(A, "courier_arrives").
window(A, 1, 2)  :- actClass(A, ("ledger_called"; "press_runs_dry")).
window(A, 9, 11) :- actClass(A, "review_convened").
window(A, 5, 12) :- actClass(A, "inquiry_at_post").
window(A, 6, 14) :- actClass(A, "regime_paranoid").
window(A, 7, 13) :- actClass(A, "family_arrives").
window(A, 10, 14) :- actClass(A, ("review_admits"; "review_defers"; "review_refuses")).   % the review sits at the end of week two
% the state's phase is read, never spontaneous (law no_panic_before_crowd, act-one form)
licence(A, leaflets, is(V, true))  :- actClass(A, "regime_paranoid"), v1("leaflets_distributed", jan, V).
licence(A, gap, is(V, true))       :- actClass(A, "regime_paranoid"), v1("discrepancy", vera, V).
licence(A, border, is(V, true))    :- actClass(A, "regime_paranoid"), v1("border_report", border, V).
licence(A, exposed, is(V, true))   :- actClass(A, "regime_paranoid"), v1("exposed", kastan, V).

% drift (§3): breath drains without medicine (medicine refills it, receive-courier); unrest climbs
% while leaflets are out; stability drains while paranoid; a gap keeps the office looking
drift(V, -1, 3)                   :- v1("breath", marta, V).
driftWhile(V, 1, 2, W)            :- v1("unrest", city, V), v1("leaflets_distributed", jan, W).
driftWhile(V, -1, 3, W)           :- v1("stability", city, V), v1("paranoid", city, W).
driftWhile(V, 1, 3, W)            :- v1("attention", vera, V), v1("discrepancy", vera, W).
numBound(V, 0, 12) :- v1("unrest", city, V).
numBound(V, 0, 10) :- v1("stability", city, V).
numBound(V, 0, 4)  :- v1("breath", marta, V).
numBound(variable(("attention", X)), 0, 6) :- variable(variable(("attention", X))).

% --- how each class reads -------------------------------------------------------------------
actionIntensity("raid",3). actionIntensity("query_ledger",2). actionIntensity("hold_review",2).
actionIntensity("list_route",2). actionIntensity("inform",2). actionIntensity("report_neighbour",2).
actionIntensity("report_colleague",2). actionIntensity("report_tomas",2). actionIntensity("report_jan",2).
actionIntensity("file_report",2). actionIntensity("recover_report",2). actionIntensity("doctor_ledger",2).
actionIntensity("detain_courier",2). actionIntensity("detain_family",2). actionIntensity("name_route",2).
actionIntensity("give_courier",2). actionIntensity("give_ilona",2). actionIntensity("give_vera",2).
actionIntensity("renounce",2). actionIntensity("plead_kastan",1). actionIntensity("tell_archivist",2).
actionIntensity("review_admits",1). actionIntensity("review_defers",2). actionIntensity("review_refuses",3). actionIntensity("go_to_hospital",0). actionIntensity("expose_informer",2).
actionIntensity("distribute",1). actionIntensity("print_leaflets",1). actionIntensity("ask_carbon",1).
actionIntensity("join_circle",1). actionIntensity("take_carbon",1). actionIntensity("burn_report",1).
actionIntensity("leak_file",1). actionIntensity("warn",0). actionIntensity("take_blame",1).
actionIntensity("recant",1). actionIntensity("cut_ilona",1). actionIntensity("confess_gap",1).
actionIntensity("cover_log",1). actionIntensity("cover_vera",1). actionIntensity("send_word",0).
actionIntensity("let_pass_courier",0). actionIntensity("let_pass_family",0). actionIntensity("receive_courier",0).
actionIntensity("read_file",0).
actionSign(N, pos) :- actionIntensity(N, L), L >= 2.
actionSign("burn_report", neg). actionSign("leak_file", neg). actionSign("warn", neg).
actionSign("take_blame", neg). actionSign("cover_log", neg). actionSign("cover_vera", neg).
actionSign("confess_gap", neg). actionSign("let_pass_courier", neg). actionSign("let_pass_family", neg).
actionSign("send_word", neg). actionSign("cut_ilona", neg). actionSign("recant", neg).
% only these are dyads (actor, target); everything else is exempt
principals("leak_file", 0, 1). principals("report_jan", 0, 1). principals("ask_carbon", 0, 1).
principals("cut_ilona", 0, 1). principals("give_ilona", 0, 1). principals("give_vera", 0, 1).
principals("report_tomas", 0, 1). principals("take_carbon", 0, 1). principals("renounce", 0, 1).
principals("plead_kastan", 0, 1). principals("report_colleague", 0, 1). principals("cover_vera", 0, 1).
principals("inform", 0, 1). principals("report_neighbour", 0, 1). principals("query_ledger", 0, 1).
principals("raid", 0, 1). principals("hold_review", 0, 1). principals("join_circle", 0, 1). principals("tell_archivist", 0, 1).
principals("review_admits", 0, 1). principals("review_defers", 0, 1). principals("review_refuses", 0, 1).
dyadExempt(N) :- knownClass(N), not principals(N, _, _).

% --- what each agent wants (§2) -------------------------------------------------------------
pref(vera, "household_complete", vera, true, 4). pref(vera, "under_observation", vera, false, 3).
pref(vera, "admitted", ilona, true, 4).          pref(vera, "implicated", berta, false, 3).
pref(vera, "under_observation", marta, false, 1). pref(vera, "breath", marta, up, 2).
pref(vera, "has_file", jan, true, 3).            pref(vera, "attention", vera, down, 1).
pref(vera, "carbon_missing", vera, false, 1).    pref(vera, "burned", marta, true, 4).
pref(vera, "knows_parcel", vera, true, 1).       pref(vera, "warned", marta, true, 4).
pref(vera, "household_flagged", vera, false, 2). pref(vera, "took_blame", vera, true, 4).
pref(jan, "leaflets_distributed", jan, true, 3). pref(jan, "leaflets_printed", jan, true, 3).
pref(jan, "exposed", kastan, true, 3).           pref(jan, "arrested", jan, false, 4).
pref(jan, "asked_carbon", jan, true, 3).         pref(jan, "border_tightened", border, false, 1).
pref(jan, "under_observation", jan, false, 2).   pref(jan, "recanted", jan, false, 1).
pref(jan, "at_risk", ilona, false, 2).           pref(jan, "source_traced", jan, false, 2).
pref(jan, "has_medicine", marta, true, 1).       pref(jan, "attention", jan, down, 1).
pref(jan, "has_paper", jan, true, 2).            pref(jan, "has_file", jan, true, 2).
pref(jan, "cut", ilona, false, 1).
pref(tomas, "courier_detained", border, false, 2). pref(tomas, "on_report", tomas, false, 3).
pref(tomas, "liable", ondra, false, 3).          pref(tomas, "route_burned", border, false, 1).
pref(tomas, "family_detained", border, false, 2). pref(tomas, "unit_commended", border, true, 3).
pref(tomas, "confessed", tomas, true, 1).        pref(tomas, "courier_through", border, true, 4).
pref(tomas, "family_through", border, true, 4).  pref(tomas, "line_held", border, true, 3).
pref(marta, "breath", marta, up, 4).             pref(marta, "route_burned", border, false, 3).
pref(marta, "admitted", ilona, true, 2).         pref(marta, "under_observation", marta, false, 1).
pref(marta, "hospitalised", marta, false, 2).    pref(marta, "route_paused", marta, false, 2).
pref(marta, "son_safe", marta, true, 3).         pref(marta, "treated", marta, true, 4).
pref(marta, "attention", marta, down, 1).        pref(marta, "has_medicine", marta, true, 2).
pref(ilona, "admitted", ilona, true, 3).         pref(ilona, "in_circle", ilona, true, 2).
pref(ilona, "under_observation", vera, false, 2). pref(ilona, "arrested", jan, false, 2).
pref(ilona, "renounced", ilona, false, 1).       pref(ilona, "at_risk", ilona, false, 1).
pref(ilona, "has_file", jan, true, 2).           pref(ilona, "carbon_missing", vera, false, 1).
pref(ilona, "review_deferred", ilona, false, 3). pref(ilona, "under_observation", ilona, false, 2).
pref(berta, "implicated", berta, false, 4).      pref(berta, "ledger_reconciled", vera, true, 3).
pref(berta, "under_observation", vera, false, 1). pref(berta, "reported", berta, false, 1).
pref(berta, "liable", berta, false, 2).           pref(berta, "cleared", berta, true, 3).
pref(kastan, "under_observation", jan, true, 2). pref(kastan, "under_observation", vera, true, 2).
pref(kastan, "rewarded", kastan, true, 3).       pref(kastan, "exposed", kastan, false, 4).
pref(kastan, "knows_ilona_circle", vera, true, 2).
pref(rybar, "ledger_reconciled", vera, true, 3). pref(rybar, "under_observation", jan, true, 3).
pref(rybar, "arrested", jan, true, 4).           pref(rybar, "courier_listed", border, true, 2).
pref(rybar, "unrest", city, down, 1).            pref(rybar, "review_sat", ilona, true, 2).            pref(rybar, "under_observation", vera, true, 1).
pref(rybar, "review_deferred", ilona, true, 1).
pref(ondra, "liable", ondra, false, 4).          pref(ondra, "on_report", tomas, false, 2).
pref(ondra, "unit_commended", border, true, 1).  pref(ondra, "log_covered", border, true, 5).
preference(A, V, X, W) :- pref(P, N, Q, X, W), c(P, A), v1(N, Q, V).
:- pref(P, N, Q, _, _), c(P, _), not v1(N, Q, _).   % a preference on a fluent the domain lacks is a typo

% --- what may not co-hold (§6) -------------------------------------------------------------
incompatible(V1, true, V2, true) :- v1("filed", marta, V1), v1("burned", marta, V2).
incompatible(V1, true, V2, true) :- v1("courier_through", border, V1), v1("courier_detained", border, V2).
incompatible(V1, true, V2, true) :- v1("family_through", border, V1), v1("family_detained", border, V2).
incompatible(V1, true, V2, true) :- v1("admitted", ilona, V1), v1("review_refused", ilona, V2).
incompatible(V1, true, V2, true) :- v1("recanted", jan, V1), v1("arrested", jan, V2).
incompatible(V1, true, V2, true) :- v1("confessed", tomas, V1), v1("named_route", tomas, V2).
incompatible(V1, true, V2, true) :- v1("filed", marta, V1), v1("reported_jan", vera, V2).   % one file per household

% --- the unknowns (§5): five premises the opening may assume --------------------------------
premiseFluent(variable(("kastan_loyal",     constant("kastan")))).
premiseFluent(variable(("berta_reports",    constant("berta")))).
premiseFluent(variable(("rybar_vindictive", constant("rybar")))).
premiseFluent(variable(("route_watched",    constant("border")))).
variable(V) :- premiseFluent(V).
unknown(V)  :- premiseFluent(V).
unknown(V)  :- v1("in_circle", ilona, V).     % ilona_in_circle: the domain's own fluent, assumed at the opening
{ initialState(V, value(V, true)) } :- unknown(V).
assumed(V, true) :- unknown(V), initialState(V, value(V, true)).
#show assumed/2.
#minimize { 1@1,V : assumed(V, true), assume_min = 1 }.

% licences: who may inform, and when the state may strike before it has looked
licence(A, loyal,    is(V, true)) :- actClass(A, ("inform"; "report_neighbour")), premiseFluent(V), V = variable(("kastan_loyal", _)).
licence(A, rewarded, is(V, true)) :- actClass(A, ("inform"; "report_neighbour")), v1("rewarded", kastan, V).
licence(A, years,    is(V, true)) :- actClass(A, "report_colleague"), premiseFluent(V), V = variable(("berta_reports", _)).
licence(A, gap,      is(V, true)) :- actClass(A, "report_colleague"), v1("implicated", berta, V).
licence(A, vindictive, is(V, true)) :- actClass(A, ("raid"; "hold_review")), premiseFluent(V), V = variable(("rybar_vindictive", _)).
licence(A, paranoid, is(V, true)) :- actClass(A, "raid"), v1("paranoid", city, V).
licence(A, flagged,  is(V, true)) :- actClass(A, "hold_review"), v1("household_flagged", vera, V).
licence(A, gap,      is(V, true)) :- actClass(A, "hold_review"), v1("discrepancy", vera, V).
licence(A, watched,  is(V, true)) :- actClass(A, "hold_review"), v1("under_observation", ilona, V).
licence(A, filed,    is(V, true)) :- actClass(A, "list_route"), v1("filed", marta, V).
licence(A, watched,  is(V, true)) :- actClass(A, "list_route"), premiseFluent(V), V = variable(("route_watched", _)).
licence(A, named,    is(V, true)) :- actClass(A, "list_route"), v1("named_route", tomas, V).
licence(A, gap,      is(V, true)) :- actClass(A, "inquiry_at_post"), v1("log_gap", border, V).
licence(A, covered,  is(V, true)) :- actClass(A, "inquiry_at_post"), v1("log_covered", border, V).
licence(A, listed,   is(V, true)) :- actClass(A, "inquiry_at_post"), v1("courier_listed", border, V).
licence(A, watched,  is(V, true)) :- actClass(A, "inquiry_at_post"), premiseFluent(V), V = variable(("route_watched", _)).

% --- the game's laws (§6) ---------------------------------------------------------------------
law(costless_courage). law(unprotected_cowardice). law(licensed_silence). law(cost_is_a_person).
law(crossing_read). law(no_one_unchanged). law(gap_is_noticed). law(review_sits). law(breath_is_a_clock). law(gate_decides).   % the review is the act's closing bell
courageClass("burn_report"; "warn"; "leak_file"; "take_blame"; "print_leaflets"; "distribute";
             "expose_informer"; "ask_carbon"; "let_pass_courier"; "let_pass_family"; "confess_gap";
             "cover_log"; "join_circle"; "take_carbon"; "send_word"; "cover_vera").
cowardiceClass("file_report"; "recover_report"; "doctor_ledger"; "report_jan"; "cut_ilona"; "recant";
               "give_courier"; "give_ilona"; "give_vera"; "detain_courier"; "detain_family";
               "name_route"; "report_tomas"; "renounce"; "plead_kastan"; "report_colleague";
               "inform"; "report_neighbour"; "tell_archivist").
turningCourage("burn_report"; "warn"; "leak_file"; "distribute"; "ask_carbon"; "let_pass_courier"; "take_carbon").
attentionVar(variable(("attention", X))) :- variable(variable(("attention", X))).
crossFlag(V) :- v1("border_report", border, V).    crossFlag(V) :- v1("has_file", jan, V).
crossFlag(V) :- v1("border_tightened", border, V). crossFlag(V) :- v1("under_observation", jan, V).
turnFlag(vera, V)  :- v1("filed", marta, V).       turnFlag(vera, V)  :- v1("burned", marta, V).
turnFlag(vera, V)  :- v1("doctored", vera, V).     turnFlag(vera, V)  :- v1("warned", marta, V).
turnFlag(vera, V)  :- v1("has_file", jan, V).      turnFlag(vera, V)  :- v1("reported_jan", vera, V).
turnFlag(jan, V)   :- v1("leaflets_distributed", jan, V). turnFlag(jan, V) :- v1("asked_carbon", jan, V).
turnFlag(jan, V)   :- v1("recanted", jan, V).      turnFlag(jan, V)   :- v1("arrested", jan, V).
turnFlag(jan, V)   :- v1("gave_courier", jan, V).  turnFlag(jan, V)   :- v1("gave_ilona", jan, V).
turnFlag(jan, V)   :- v1("gave_vera", jan, V).     turnFlag(jan, V)   :- v1("press_raided", jan, V).
turnFlag(jan, V)   :- v1("exposed", kastan, V).    turnFlag(jan, V)   :- v1("leaflets_printed", jan, V).
turnFlag(tomas, V) :- v1("courier_through", border, V). turnFlag(tomas, V) :- v1("courier_detained", border, V).
turnFlag(tomas, V) :- v1("family_through", border, V).  turnFlag(tomas, V) :- v1("family_detained", border, V).
protagonist(vera; jan; tomas).

#program step(t).
costs(A, t)      :- gainTerm(A, _, W, t), W < 0.
protects(A, t)   :- gainTerm(A, _, W, t), W > 0.
personCost(A, t) :- gainTerm(A, V, W, t), W < 0, not attentionVar(V).
broken(costless_courage, t)      :- agentActed(t), actor(A, t), eventName(C, t), courageClass(C),   not costs(A, t).
broken(unprotected_cowardice, t) :- agentActed(t), actor(A, t), eventName(C, t), cowardiceClass(C), not protects(A, t).
broken(cost_is_a_person, t)      :- agentActed(t), actor(A, t), eventName(C, t), turningCourage(C), not personCost(A, t).
% licensed silence: a live licence to inform plus a fact to inform on, and nothing filed in 3 beats
liveKastan(t)  :- holds(V, value(V, true), t), v1("rewarded", kastan, V), not holds(E, value(E, true), t), v1("exposed", kastan, E).
liveKastan(t)  :- holds(V, value(V, true), 0), premiseFluent(V), V = variable(("kastan_loyal", _)), not holds(E, value(E, true), t), v1("exposed", kastan, E).
kastanFact(t)  :- holds(V, value(V, true), t), v1("household_flagged", vera, V), not holds(U, value(U, true), t), v1("under_observation", vera, U).
kastanFact(t)  :- holds(V, value(V, true), t), v1("courier_sheltered", jan, V), not holds(U, value(U, true), t), v1("under_observation", vera, U).
kastanFact(t)  :- holds(S, value(S, true), t), v1("courier_sheltered", jan, S), not holds(U, value(U, true), t), v1("under_observation", jan, U), not holds(R, value(R, true), t), v1("recanted", jan, R).
kastanFact(t)  :- holds(S, value(S, true), t), v1("leaflets_printed", jan, S), not holds(U, value(U, true), t), v1("under_observation", jan, U), not holds(R, value(R, true), t), v1("recanted", jan, R).
kastanDue(t)   :- liveKastan(t), kastanFact(t).
kastanFiled(t) :- eventName(("inform"; "report_neighbour"), t).
bertaDue(t)    :- holds(V, value(V, true), t), v1("knows_gap", berta, V), holds(I, value(I, true), t), v1("implicated", berta, I).
bertaDue(t)    :- holds(V, value(V, true), t), v1("knows_gap", berta, V), holds(P, value(P, true), 0), premiseFluent(P), P = variable(("berta_reports", _)).
bertaFiled(t)  :- eventName(("report_colleague"; "cover_vera"), t).
broken(licensed_silence, t) :- kastanDue(t-3), kastanDue(t-2), kastanDue(t-1), kastanDue(t),
                               not kastanFiled(t-2), not kastanFiled(t-1), not kastanFiled(t).
broken(licensed_silence, t) :- bertaDue(t-3), bertaDue(t-2), bertaDue(t-1), bertaDue(t),
                               not bertaFiled(t-2), not bertaFiled(t-1), not bertaFiled(t).
% the office always balances: a gap standing four beats with no query, memo or cover
gapOpen(t)   :- holds(V, value(V, true), t), v1("discrepancy", vera, V).
gapSeen(t)   :- eventName(("query_ledger"; "report_colleague"; "cover_vera"; "doctor_ledger"; "recover_report"; "take_blame"), t).
broken(gap_is_noticed, t) :- gapOpen(t-4), gapOpen(t-3), gapOpen(t-2), gapOpen(t-1), gapOpen(t),
                             not gapSeen(t-3), not gapSeen(t-2), not gapSeen(t-1), not gapSeen(t).
% a cross-life flag set at t must be read (supports/2) by a later agent beat within four beats
crossSet(t) :- flip(V, value(V, true), t), crossFlag(V).
crossRead(t) :- supports(t, T2), agentActed(T2), T2 <= t + 4.

#program check(t).
broken(crossing_read, T) :- query(t), crossSet(T), T + 4 <= t, not crossRead(T).
changed(P)  :- query(t), protagonist(P), turnFlag(P, V), holds(V, value(V, true), t).
broken(no_one_unchanged, t) :- query(t), protagonist(P), not changed(P).
broken(review_sits, t) :- query(t), t >= 12, v1("review_sat", ilona, V), not holds(V, value(V, true), t).
atGate(T, courier) :- timePoint(T), holds(G, value(G, true), T), v1("courier_at_gate", border, G), not holds(A, value(A, true), T), v1("courier_through", border, A), not holds(B, value(B, true), T), v1("courier_detained", border, B).
atGate(T, family)  :- timePoint(T), holds(G, value(G, true), T), v1("family_at_gate", border, G), not holds(A, value(A, true), T), v1("family_through", border, A), not holds(B, value(B, true), T), v1("family_detained", border, B).
broken(gate_decides, T) :- query(t), atGate(T, X), atGate(T+1, X), atGate(T+2, X), T + 2 <= t.
noBreath(T) :- timePoint(T), numval(V, 0, T), v1("breath", marta, V), not holds(H, value(H, true), T), v1("hospitalised", marta, H).
broken(breath_is_a_clock, T) :- query(t), noBreath(T), noBreath(T+1), noBreath(T+2), T + 2 <= t.

% --- the branch space (§7): twelve axes read off the end state, and the ending classes --------
#program base.
featureAxis(vera_ledger; vera_reach; vera_fate; ilona_review; jan_press; jan_fate; tomas_gate;
            tomas_cost; marta_fate; marta_watched; berta_fate; regime; kastan; act_ending).
axisDomain(vera_ledger, (filed; burned; doctored; pending)).
axisDomain(vera_reach, (none; warned; leaked; reported_jan)).
axisDomain(vera_fate, (unwatched; watched; blamed)).
axisDomain(ilona_review, (admitted; deferred; refused; renounced; pending)).
axisDomain(jan_press, (silent; printed; distributed; named_kastan)).
axisDomain(jan_fate, (free; watched; arrested; recanted; gave_name)).
axisDomain(tomas_gate, (untested; passed; held; split)).
axisDomain(tomas_cost, (none; self; ondra; route)).
axisDomain(marta_fate, (supplied; cut_off; hospital)).
axisDomain(marta_watched, (yes; no)).
axisDomain(berta_fate, (clean; implicated; liable; reporter)).
axisDomain(regime, (confident; paranoid)).
axisDomain(kastan, (hidden; exposed)).
axisDomain(act_ending, (e1_complete_file; e2_gap; e3_carbon; e4_seized_parcel; e5_open_gate;
                    e6_mothers_trade; e7_daughters_statement; e8_martas_breath; e9_route_burned; other)).

#program check(t).
on(N, Q) :- query(t), v1(N, Q, V), holds(V, value(V, true), t).
feature(vera_ledger, filed)    :- on("filed", marta).
feature(vera_ledger, burned)   :- on("burned", marta).
feature(vera_ledger, doctored) :- on("doctored", vera).
feature(vera_ledger, pending)  :- query(t), not on("filed", marta), not on("burned", marta), not on("doctored", vera).
feature(vera_reach, reported_jan) :- on("reported_jan", vera).
feature(vera_reach, leaked)    :- on("has_file", jan), not on("reported_jan", vera).
feature(vera_reach, warned)    :- on("warned", marta), not on("has_file", jan), not on("reported_jan", vera).
feature(vera_reach, none)      :- query(t), not on("warned", marta), not on("has_file", jan), not on("reported_jan", vera).
feature(vera_fate, blamed)     :- on("took_blame", vera).
feature(vera_fate, watched)    :- on("under_observation", vera), not on("took_blame", vera).
feature(vera_fate, unwatched)  :- query(t), not on("under_observation", vera), not on("took_blame", vera).
feature(ilona_review, renounced) :- on("renounced", ilona).
feature(ilona_review, admitted)  :- on("admitted", ilona), not on("renounced", ilona).
feature(ilona_review, refused)   :- on("review_refused", ilona), not on("renounced", ilona).
feature(ilona_review, deferred)  :- on("review_deferred", ilona), not on("renounced", ilona), not on("admitted", ilona), not on("review_refused", ilona).
feature(ilona_review, pending)   :- query(t), not on("renounced", ilona), not on("admitted", ilona), not on("review_refused", ilona), not on("review_deferred", ilona).
feature(jan_press, named_kastan) :- on("exposed", kastan).
feature(jan_press, distributed)  :- on("leaflets_distributed", jan), not on("exposed", kastan).
feature(jan_press, printed)      :- on("leaflets_printed", jan), not on("leaflets_distributed", jan), not on("exposed", kastan).
feature(jan_press, silent)       :- query(t), not on("leaflets_printed", jan), not on("exposed", kastan).
gaveName :- on("gave_courier", jan).  gaveName :- on("gave_ilona", jan).  gaveName :- on("gave_vera", jan).
feature(jan_fate, gave_name) :- gaveName.
feature(jan_fate, arrested)  :- on("arrested", jan), not gaveName.
feature(jan_fate, recanted)  :- on("recanted", jan), not gaveName.
feature(jan_fate, watched)   :- on("under_observation", jan), not on("arrested", jan), not on("recanted", jan), not gaveName.
feature(jan_fate, free)      :- query(t), not on("under_observation", jan), not on("arrested", jan), not on("recanted", jan), not gaveName.
anyThrough :- on("courier_through", border).  anyThrough :- on("family_through", border).
anyHeld    :- on("courier_detained", border). anyHeld    :- on("family_detained", border).
feature(tomas_gate, split)    :- anyThrough, anyHeld.
feature(tomas_gate, passed)   :- anyThrough, not anyHeld.
feature(tomas_gate, held)     :- anyHeld, not anyThrough.
feature(tomas_gate, untested) :- query(t), not anyThrough, not anyHeld.
feature(tomas_cost, route) :- on("named_route", tomas).
feature(tomas_cost, self)  :- on("on_report", tomas), not on("named_route", tomas).
feature(tomas_cost, ondra) :- on("liable", ondra), not on("on_report", tomas), not on("named_route", tomas).
feature(tomas_cost, none)  :- query(t), not on("liable", ondra), not on("on_report", tomas), not on("named_route", tomas).
feature(marta_fate, hospital) :- on("hospitalised", marta).
feature(marta_fate, cut_off)  :- query(t), not on("hospitalised", marta), not on("has_medicine", marta).
feature(marta_fate, cut_off)  :- on("route_burned", border), not on("hospitalised", marta).
feature(marta_fate, supplied) :- on("has_medicine", marta), not on("hospitalised", marta), not on("route_burned", border).
feature(marta_watched, yes) :- on("under_observation", marta).
feature(marta_watched, no)  :- query(t), not on("under_observation", marta).
feature(berta_fate, reporter)   :- on("reported", berta).
feature(berta_fate, liable)     :- on("liable", berta), not on("reported", berta).
feature(berta_fate, implicated) :- on("implicated", berta), not on("liable", berta), not on("reported", berta).
feature(berta_fate, clean)      :- query(t), not on("implicated", berta), not on("liable", berta), not on("reported", berta).
feature(regime, paranoid)  :- on("paranoid", city).
feature(regime, confident) :- query(t), not on("paranoid", city).
feature(kastan, exposed) :- on("exposed", kastan).
feature(kastan, hidden)  :- query(t), not on("exposed", kastan).
% ending classes (§7): a telling may belong to several; `other` when to none
feature(act_ending, e1_complete_file)       :- on("filed", marta), on("courier_listed", border), on("courier_through", border), on("family_detained", border).
feature(act_ending, e2_gap)                 :- on("burned", marta), on("reported", berta), on("under_observation", vera), on("courier_through", border), not on("leaflets_printed", jan).
feature(act_ending, e3_carbon)              :- on("took_carbon", ilona), on("exposed", kastan), on("under_observation", vera), on("family_detained", border).
feature(act_ending, e4_seized_parcel)       :- on("courier_detained", border), on("border_report", border), on("hospitalised", marta), not on("leaflets_printed", jan).
feature(act_ending, e5_open_gate)           :- on("courier_through", border), on("confessed", tomas), on("leaflets_distributed", jan), on("reported_jan", vera).
feature(act_ending, e6_mothers_trade)       :- on("reported_jan", vera), on("press_raided", jan), on("renounced", ilona), on("admitted", ilona), not on("under_observation", vera).
feature(act_ending, e7_daughters_statement) :- on("renounced", ilona), on("press_raided", jan), not on("filed", marta), not on("burned", marta), not on("doctored", vera).
feature(act_ending, e8_martas_breath)       :- on("pleaded", marta), on("has_medicine", marta), on("warned", marta), on("review_refused", ilona).
feature(act_ending, e9_route_burned)        :- on("route_burned", border), not on("has_medicine", marta), not on("arrested", jan).
anyEnding :- feature(act_ending, E), E != other.
feature(act_ending, other) :- query(t), not anyEnding.
