;; PROTOTYPE - NOT FOR PRODUCTION
;; Question: Does the act-one narrative brief, written as a polyscene world, yield the nine
;;           ending classes the writers need, with E0 "nothing moved" unreachable?
;; Date: 2026-11-03
;;
;; What CAN happen in weeks one and two. Written from production/narrative/paper-walls-act-one/
;; brief.md section 4 (36 actions) and the world moves of section 4. No path is scripted here.
(define (domain paper-walls-act1)
  (:requirements :strips :typing :numeric-fluents :conditional-effects :disjunctive-preconditions)
  (:types agent person place - object
          archivist dissident conscript bunkmate officer informer widow daughter colleague - agent)
  (:predicates
    ;; Vera
    (report-received ?v - archivist) (knows-parcel ?v - archivist) (border-report ?l - place)
    (filed ?p - widow) (burned ?p - widow) (doctored ?v - archivist) (discrepancy ?v - archivist)
    (carbon-missing ?v - archivist) (household-complete ?v - archivist) (household-flagged ?v - archivist)
    (took-blame ?v - archivist) (knows-ilona-circle ?v - archivist) (reported-jan ?v - archivist)
    (ledger-due ?v - archivist) (needs-paper ?j - dissident) (review-called ?i - daughter) (cleared ?b - colleague)
    ;; Jan
    (has-paper ?j - dissident) (has-file ?j - dissident) (leaflets-printed ?j - dissident)
    (leaflets-distributed ?j - dissident) (asked-carbon ?j - dissident) (courier-sheltered ?j - dissident)
    (source-traced ?j - dissident) (press-raided ?j - dissident) (arrested ?j - dissident)
    (recanted ?j - dissident) (gave-courier ?j - dissident) (gave-ilona ?j - dissident) (gave-vera ?j - dissident)
    ;; Tomas and Ondra
    (on-report ?t - conscript) (named-route ?t - conscript) (confessed ?t - conscript)
    (liable ?o - agent) (reported-tomas ?o - bunkmate)
    ;; Marta
    (has-medicine ?m - widow) (warned ?m - widow) (route-paused ?m - widow) (pleaded ?m - widow)
    (hospitalised ?m - widow) (treated ?m - widow) (son-safe ?m - widow)
    ;; Ilona
    (in-circle ?i - daughter) (at-risk ?i - daughter) (took-carbon ?i - daughter) (renounced ?i - daughter)
    (cut ?i - daughter) (review-pending ?i - daughter) (admitted ?i - daughter)
    (review-deferred ?i - daughter) (review-refused ?i - daughter) (review-sat ?i - daughter)
    ;; Berta
    (implicated ?b - colleague) (reported ?b - colleague) (knows-gap ?b - colleague)
    ;; Kastan
    (rewarded ?k - informer) (exposed ?k - informer) (knows-ilona ?k - informer) (line-held ?l - place)
    ;; everyone
    (under-observation ?x - object)
    ;; the office and the city
    (ledger-reconciled ?v - archivist) (paranoid ?l - place)
    ;; the border
    (courier-at-gate ?l - place) (courier-through ?l - place) (courier-detained ?l - place)
    (courier-listed ?l - place) (log-gap ?l - place) (log-covered ?l - place) (inquiry ?l - place)
    (border-tightened ?l - place) (family-at-gate ?l - place) (family-through ?l - place)
    (family-detained ?l - place) (route-burned ?l - place) (unit-commended ?l - place))
  (:functions (unrest ?l - place) (stability ?l - place) (attention ?x - object) (breath ?m - widow))

  ;; ===== Vera (9) =====================================================================
  (:action read-file
    :parameters (?v - archivist)
    :precondition (and (report-received ?v) (ledger-due ?v) (not (knows-parcel ?v)))
    :effect (knows-parcel ?v))
  (:action file-report
    :parameters (?v - archivist ?p - widow ?k - informer)
    :precondition (and (report-received ?v) (ledger-due ?v) (not (filed ?p)) (not (burned ?p)) (not (doctored ?v)))
    :effect (and (filed ?p) (under-observation ?p) (household-complete ?v) (rewarded ?k)
                 (ledger-reconciled ?v) (increase (attention ?p) 2)))
  (:action burn-report
    :parameters (?v - archivist ?p - widow ?b - colleague)
    :precondition (and (report-received ?v) (ledger-due ?v) (not (filed ?p)) (not (burned ?p)) (not (doctored ?v)))
    :effect (and (burned ?p) (discrepancy ?v) (implicated ?b) (knows-gap ?b)))
  (:action recover-report
    :parameters (?v - archivist ?p - widow ?k - informer ?b - colleague)
    :precondition (and (burned ?p) (discrepancy ?v) (or (under-observation ?v) (reported ?b)))
    :effect (and (filed ?p) (not (burned ?p)) (not (discrepancy ?v)) (not (implicated ?b))
                 (under-observation ?p) (household-complete ?v) (rewarded ?k) (ledger-reconciled ?v)
                 (increase (attention ?p) 2)))
  (:action doctor-ledger
    :parameters (?v - archivist ?b - colleague)
    :precondition (and (discrepancy ?v) (not (under-observation ?v)) (not (doctored ?v)))
    :effect (and (doctored ?v) (not (discrepancy ?v)) (ledger-reconciled ?v) (implicated ?b)
                 (household-complete ?v)))
  (:action warn
    :parameters (?v - archivist ?p - widow)
    :precondition (and (knows-parcel ?v) (not (warned ?p)))
    :effect (and (warned ?p) (household-flagged ?v) (increase (attention ?v) 1)))
  (:action leak-file
    :parameters (?v - archivist ?j - dissident ?b - colleague)
    :precondition (and (report-received ?v) (ledger-due ?v) (not (has-file ?j)) (not (arrested ?j)))
    :effect (and (has-file ?j) (carbon-missing ?v) (knows-gap ?b) (increase (attention ?v) 1)))
  (:action take-blame
    :parameters (?v - archivist ?b - colleague)
    :precondition (and (implicated ?b) (not (took-blame ?v)) (or (under-observation ?v) (reported ?b)))
    :effect (and (took-blame ?v) (not (implicated ?b)) (under-observation ?v) (household-flagged ?v)
                 (increase (attention ?v) 1)))
  (:action report-jan
    :parameters (?v - archivist ?j - dissident)
    :precondition (and (knows-ilona-circle ?v) (not (under-observation ?j)) (not (reported-jan ?v)))
    :effect (and (under-observation ?j) (reported-jan ?v) (household-complete ?v) (increase (attention ?j) 2)))

  ;; ===== Jan (8, give-name split in three) ============================================
  (:action receive-courier
    :parameters (?j - dissident ?m - widow ?l - place)
    :precondition (and (courier-through ?l) (not (courier-sheltered ?j)) (not (arrested ?j)))
    :effect (and (courier-sheltered ?j) (has-paper ?j) (has-medicine ?m) (increase (breath ?m) 3)
                 (increase (attention ?j) 1)))
  (:action print-leaflets
    :parameters (?j - dissident ?i - daughter ?c - place)
    :precondition (and (has-paper ?j) (not (press-raided ?j)) (not (leaflets-printed ?j)) (not (arrested ?j)) (not (recanted ?j)))
    :effect (and (leaflets-printed ?j) (increase (unrest ?c) 1)
                 (when (in-circle ?i) (at-risk ?i))))
  (:action distribute
    :parameters (?j - dissident ?i - daughter ?c - place ?l - place)
    :precondition (and (leaflets-printed ?j) (not (leaflets-distributed ?j)) (not (arrested ?j)) (not (recanted ?j)))
    :effect (and (leaflets-distributed ?j) (increase (unrest ?c) 2) (decrease (stability ?c) 1)
                 (border-tightened ?l) (increase (attention ?j) 1) (when (in-circle ?i) (at-risk ?i))))
  (:action expose-informer
    :parameters (?j - dissident ?k - informer ?v - archivist ?c - place)
    :precondition (and (has-file ?j) (not (exposed ?k)) (not (arrested ?j)) (not (recanted ?j)))
    :effect (and (exposed ?k) (source-traced ?j) (increase (attention ?v) 2) (increase (unrest ?c) 1)
                 (decrease (stability ?c) 1)))
  (:action ask-carbon
    :parameters (?j - dissident ?i - daughter)
    :precondition (and (in-circle ?i) (needs-paper ?j) (not (has-file ?j)) (not (asked-carbon ?j)) (not (arrested ?j)))
    :effect (and (asked-carbon ?j) (at-risk ?i)))
  (:action cut-ilona
    :parameters (?j - dissident ?i - daughter)
    :precondition (and (in-circle ?i) (at-risk ?i) (not (arrested ?j)) (not (cut ?i)))
    :effect (and (not (in-circle ?i)) (not (at-risk ?i)) (cut ?i)))
  (:action recant
    :parameters (?j - dissident ?i - daughter)
    :precondition (and (under-observation ?j) (not (arrested ?j)) (not (recanted ?j)))
    :effect (and (recanted ?j) (not (under-observation ?j)) (decrease (attention ?j) 2) (not (at-risk ?i))))
  (:action give-courier
    :parameters (?j - dissident ?l - place ?c - place)
    :precondition (and (or (arrested ?j) (and (under-observation ?j) (paranoid ?c))) (not (gave-courier ?j)) (not (route-burned ?l)))
    :effect (and (gave-courier ?j) (not (arrested ?j)) (route-burned ?l)))
  (:action give-ilona
    :parameters (?j - dissident ?i - daughter ?c - place)
    :precondition (and (or (arrested ?j) (and (under-observation ?j) (paranoid ?c))) (not (gave-ilona ?j)) (not (under-observation ?i)))
    :effect (and (gave-ilona ?j) (not (arrested ?j)) (under-observation ?i)))
  (:action give-vera
    :parameters (?j - dissident ?v - archivist ?c - place)
    :precondition (and (or (arrested ?j) (and (under-observation ?j) (paranoid ?c))) (not (gave-vera ?j)) (has-file ?j) (not (under-observation ?v)))
    :effect (and (gave-vera ?j) (not (arrested ?j)) (under-observation ?v)))

  ;; ===== Tomas (4, crosser split) =====================================================
  (:action let-pass-courier
    :parameters (?t - conscript ?o - bunkmate ?l - place)
    :precondition (and (courier-at-gate ?l) (not (courier-through ?l)) (not (courier-detained ?l)))
    :effect (and (courier-through ?l) (log-gap ?l) (liable ?o)
                 (when (courier-listed ?l) (increase (attention ?t) 2))))
  (:action detain-courier
    :parameters (?t - conscript ?m - widow ?l - place)
    :precondition (and (courier-at-gate ?l) (not (courier-through ?l)) (not (courier-detained ?l)))
    :effect (and (courier-detained ?l) (border-report ?l) (unit-commended ?l)
                 (increase (attention ?m) 2)))
  (:action let-pass-family
    :parameters (?t - conscript ?o - bunkmate ?l - place)
    :precondition (and (family-at-gate ?l) (border-tightened ?l) (not (family-through ?l)) (not (family-detained ?l)))
    :effect (and (family-through ?l) (log-gap ?l) (liable ?o) (increase (attention ?t) 2)))
  (:action detain-family
    :parameters (?t - conscript ?l - place ?c - place)
    :precondition (and (family-at-gate ?l) (not (family-through ?l)) (not (family-detained ?l)))
    :effect (and (family-detained ?l) (unit-commended ?l) (line-held ?l) (increase (unrest ?c) 1)))
  (:action confess-gap
    :parameters (?t - conscript ?o - bunkmate ?l - place)
    :precondition (and (log-gap ?l) (inquiry ?l) (liable ?o) (not (confessed ?t)))
    :effect (and (confessed ?t) (on-report ?t) (not (liable ?o)) (not (log-gap ?l))))
  (:action name-route
    :parameters (?t - conscript ?o - bunkmate ?m - widow ?l - place)
    :precondition (and (inquiry ?l) (or (log-gap ?l) (on-report ?t)) (not (named-route ?t)) (not (route-burned ?l)))
    :effect (and (named-route ?t) (route-burned ?l) (not (liable ?o)) (not (on-report ?t)) (increase (attention ?m) 2)))

  ;; ===== Ondra (2) ====================================================================
  (:action cover-log
    :parameters (?o - bunkmate ?l - place)
    :precondition (and (log-gap ?l) (not (inquiry ?l)) (not (log-covered ?l)))
    :effect (and (log-covered ?l) (not (log-gap ?l)) (liable ?o)))
  (:action report-tomas
    :parameters (?o - bunkmate ?t - conscript ?l - place)
    :precondition (and (or (log-gap ?l) (log-covered ?l)) (inquiry ?l) (not (reported-tomas ?o)))
    :effect (and (reported-tomas ?o) (on-report ?t) (not (liable ?o))))

  ;; ===== Ilona (3) ====================================================================
  (:action join-circle
    :parameters (?i - daughter ?j - dissident)
    :precondition (and (needs-paper ?j) (not (in-circle ?i)) (not (renounced ?i)) (not (cut ?i)) (not (arrested ?j)))
    :effect (and (in-circle ?i) (at-risk ?i)))
  (:action take-carbon
    :parameters (?i - daughter ?j - dissident ?v - archivist ?b - colleague)
    :precondition (and (in-circle ?i) (asked-carbon ?j) (not (has-file ?j)) (not (carbon-missing ?v)))
    :effect (and (took-carbon ?i) (has-file ?j) (carbon-missing ?v) (knows-gap ?b)))
  (:action renounce
    :parameters (?i - daughter ?j - dissident)
    :precondition (and (in-circle ?i) (or (review-deferred ?i) (under-observation ?i)) (not (renounced ?i)))
    :effect (and (renounced ?i) (not (in-circle ?i)) (under-observation ?j) (review-pending ?i)
                 (not (review-deferred ?i)) (not (at-risk ?i)) (not (under-observation ?i))))

  ;; ===== Marta (2) ====================================================================
  (:action send-word
    :parameters (?m - widow)
    :precondition (and (warned ?m) (not (route-paused ?m)) (not (has-medicine ?m)))
    :effect (and (route-paused ?m) (son-safe ?m)))
  (:action plead-kastan
    :parameters (?m - widow ?k - informer ?i - daughter)
    :precondition (and (in-circle ?i) (<= (breath ?m) 1) (not (pleaded ?m)) (not (exposed ?k)))
    :effect (and (pleaded ?m) (knows-ilona ?k) (increase (attention ?i) 2) (not (route-paused ?m))
                 (decrease (attention ?m) 1)))

  ;; ===== Berta (2) ====================================================================
  (:action report-colleague
    :parameters (?b - colleague ?v - archivist)
    :precondition (and (knows-gap ?b) (not (reported ?b)) (not (under-observation ?v)))
    :effect (and (reported ?b) (cleared ?b) (discrepancy ?v) (under-observation ?v) (increase (attention ?v) 2) (not (implicated ?b))))
  (:action cover-vera
    :parameters (?b - colleague ?v - archivist)
    :precondition (and (knows-gap ?b) (implicated ?b) (not (under-observation ?v)) (not (liable ?b)))
    :effect (and (liable ?b) (ledger-reconciled ?v) (not (discrepancy ?v)) (not (carbon-missing ?v))))

  ;; ===== Kastan (2) ===================================================================
  (:action inform
    :parameters (?k - informer ?j - dissident ?i - daughter ?v - archivist)
    :precondition (and (or (courier-sheltered ?j) (leaflets-printed ?j)) (not (exposed ?k)) (not (under-observation ?j)) (not (recanted ?j)))
    :effect (and (under-observation ?j) (increase (attention ?j) 1)
                 (when (knows-ilona ?k) (and (increase (attention ?i) 1) (knows-ilona-circle ?v)))))
  (:action report-neighbour
    :parameters (?k - informer ?v - archivist ?j - dissident)
    :precondition (and (or (household-flagged ?v) (courier-sheltered ?j)) (not (exposed ?k)) (not (under-observation ?v)))
    :effect (and (under-observation ?v) (increase (attention ?v) 2)))

  (:action tell-archivist
    :parameters (?k - informer ?v - archivist ?i - daughter)
    :precondition (and (knows-ilona ?k) (not (knows-ilona-circle ?v)) (not (exposed ?k)))
    :effect (and (knows-ilona-circle ?v) (increase (attention ?i) 1)))

  ;; ===== Marta: the hospital is her choice, and the hospital asks for papers =================
  (:action go-to-hospital
    :parameters (?m - widow ?v - archivist)
    :precondition (and (<= (breath ?m) 0) (not (hospitalised ?m)))
    :effect (and (hospitalised ?m) (treated ?m) (under-observation ?m) (increase (attention ?v) 1)))

  ;; ===== Rybar (4 + the review, which the Section sits) ==================================
  (:action query-ledger
    :parameters (?r - officer ?v - archivist ?p - widow ?l - place)
    :precondition (and (not (under-observation ?v))
                       (or (discrepancy ?v) (and (border-report ?l) (not (filed ?p))) (>= (attention ?v) 3)))
    :effect (and (under-observation ?v) (increase (attention ?v) 2)))
  (:action raid
    :parameters (?r - officer ?j - dissident ?i - daughter ?c - place)
    :precondition (and (under-observation ?j) (not (press-raided ?j)) (not (recanted ?j)))
    :effect (and (press-raided ?j) (arrested ?j) (increase (unrest ?c) 2) (when (in-circle ?i) (under-observation ?i))))
  (:action hold-review
    :parameters (?r - officer ?i - daughter ?v - archivist)
    :precondition (and (review-pending ?i) (not (review-deferred ?i)) (not (review-sat ?i)))
    :effect (review-deferred ?i))
  (:action list-route
    :parameters (?r - officer ?l - place)
    :precondition (not (courier-listed ?l))
    :effect (courier-listed ?l))

  ;; ===== world moves (declared happening/1 in the topic file) ==========================
  (:action ledger-called
    :parameters (?v - archivist)
    :precondition (not (ledger-due ?v))
    :effect (ledger-due ?v))
  (:action press-runs-dry
    :parameters (?j - dissident)
    :precondition (not (needs-paper ?j))
    :effect (needs-paper ?j))
  (:action review-convened
    :parameters (?i - daughter)
    :precondition (and (review-pending ?i) (not (review-called ?i)))
    :effect (review-called ?i))
  (:action courier-arrives
    :parameters (?l - place ?m - widow)
    :precondition (and (not (courier-at-gate ?l)) (not (route-paused ?m)) (not (route-burned ?l)))
    :effect (courier-at-gate ?l))
  (:action inquiry-at-post
    :parameters (?l - place)
    :precondition (and (not (inquiry ?l)) (or (log-gap ?l) (log-covered ?l) (courier-listed ?l)))
    :effect (inquiry ?l))
  (:action regime-paranoid
    :parameters (?c - place ?v - archivist ?j - dissident)
    :precondition (not (paranoid ?c))
    :effect (and (paranoid ?c) (decrease (stability ?c) 1)
                 (when (>= (attention ?v) 1) (increase (attention ?v) 1))
                 (when (>= (attention ?j) 1) (increase (attention ?j) 1))))
  (:action family-arrives
    :parameters (?l - place ?m - widow)
    :precondition (and (not (family-at-gate ?l)) (or (border-tightened ?l) (route-paused ?m)))
    :effect (family-at-gate ?l))
  (:action review-admits
    :parameters (?r - officer ?i - daughter ?v - archivist)
    :precondition (and (review-called ?i) (review-pending ?i) (not (review-sat ?i)) (household-complete ?v) (not (household-flagged ?v))
                       (not (under-observation ?i)) (not (review-deferred ?i)))
    :effect (and (admitted ?i) (review-sat ?i) (not (review-pending ?i))))
  (:action review-defers
    :parameters (?r - officer ?i - daughter ?v - archivist ?j - dissident)
    :precondition (and (review-called ?i) (review-pending ?i) (not (review-sat ?i)) (not (under-observation ?i)) (not (gave-ilona ?j))
                       (or (not (household-complete ?v)) (household-flagged ?v) (review-deferred ?i)))
    :effect (and (review-deferred ?i) (review-sat ?i) (not (review-pending ?i))))
  (:action review-refuses
    :parameters (?r - officer ?i - daughter ?j - dissident)
    :precondition (and (review-called ?i) (review-pending ?i) (not (review-sat ?i)) (or (under-observation ?i) (gave-ilona ?j)))
    :effect (and (review-refused ?i) (review-sat ?i) (not (review-pending ?i)))))
