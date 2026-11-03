;; PROTOTYPE - NOT FOR PRODUCTION
;; Question: Can polyscene enumerate the admissible story branches of Paper Walls?
;; Date: 2026-11-03
;;
;; What CAN happen in the six weeks: the action space. Every fluent is at least unary so the
;; engine's holds1/holds2 read-backs reach it; `border` is the one place. Agents are typed by
;; role so each action grounds only for the role that can take it. No action encodes a path:
;; each states what it needs and what it leaves; the laws and motives in paper-walls.lp decide
;; which sequences are admissible.
(define (domain paper-walls)
  (:requirements :strips :typing :numeric-fluents)
  (:types agent person place - object
          archivist dissident conscript officer informer - agent)
  (:predicates
    ;; the archivist's desk
    (report-received ?v - archivist ?p - person)
    (knows-parcel ?v - archivist)
    (filed ?p - person)
    (burned ?p - person)
    (warned ?p - person)
    (household-complete ?v - archivist)        ; the daughter's review closes
    (discrepancy ?v - archivist)               ; a report logged by its source, never entered
    ;; the dossier: who the state watches, and what it has bought
    (under-observation ?x - object)
    (kastan-rewarded ?k - informer)            ; a filed report pays the informer; he is emboldened
    ;; the dissident
    (has-file ?j - dissident)
    (leaflets-printed ?j - dissident)
    (leaflets-distributed ?j - dissident)
    (press-raided ?j - dissident)
    (arrested ?j - dissident)
    (recanted ?j - dissident)
    (turned ?j - dissident)                    ; released as an informer
    (released ?j - dissident)
    (informer-exposed ?k - informer)
    ;; the border and the regime
    (crowd-at ?l - place)
    (ordered-fire ?t - conscript)
    (unit-safe ?t - conscript)                 ; obeying keeps his unit out of the stockade
    (deserted ?t - conscript)                  ; standing down is desertion on his record
    (fired-on-crowd ?l - place)
    (stood-down ?l - place)
    (border-open ?l - place)
    (wavering ?l - place)                      ; regime phase: confident -> wavering -> panicking
    (panicking ?l - place))
  (:functions
    (unrest ?l - place)
    (stability ?l - place)
    (attention ?x - object))

  ;; --- the archivist -----------------------------------------------------------------------
  (:action read-file
    :parameters (?v - archivist ?p - person)
    :precondition (and (report-received ?v ?p) (not (knows-parcel ?v)))
    :effect (knows-parcel ?v))
  (:action file-report
    :parameters (?v - archivist ?p - person ?k - informer)
    :precondition (and (report-received ?v ?p) (not (filed ?p)) (not (burned ?p)))
    :effect (and (filed ?p) (under-observation ?p) (household-complete ?v) (kastan-rewarded ?k)
                 (increase (attention ?p) 2)))
  (:action burn-report
    :parameters (?v - archivist ?p - person)
    :precondition (and (report-received ?v ?p) (not (filed ?p)) (not (burned ?p)))
    :effect (and (burned ?p) (discrepancy ?v) (increase (attention ?v) 1)))
  (:action recover-report
    :parameters (?v - archivist ?p - person ?k - informer)
    :precondition (and (burned ?p) (discrepancy ?v) (not (filed ?p)))
    :effect (and (filed ?p) (not (burned ?p)) (not (discrepancy ?v)) (under-observation ?p)
                 (household-complete ?v) (kastan-rewarded ?k)))
  (:action warn
    :parameters (?v - archivist ?p - person)
    :precondition (and (knows-parcel ?v) (not (warned ?p)))
    :effect (and (warned ?p) (increase (attention ?v) 2)))
  (:action leak-file
    :parameters (?v - archivist ?j - dissident ?p - person)
    :precondition (and (report-received ?v ?p) (not (has-file ?j)) (not (arrested ?j)) (not (turned ?j)))
    :effect (and (has-file ?j) (increase (attention ?v) 1)))

  ;; --- the dissident ----------------------------------------------------------------------
  (:action print-leaflets
    :parameters (?j - dissident ?l - place)
    :precondition (and (not (press-raided ?j)) (not (leaflets-printed ?j)) (not (arrested ?j)) (not (recanted ?j)))
    :effect (and (leaflets-printed ?j) (increase (unrest ?l) 1) (increase (attention ?j) 1)))
  (:action distribute
    :parameters (?j - dissident ?l - place)
    :precondition (and (leaflets-printed ?j) (not (leaflets-distributed ?j)) (not (arrested ?j)) (not (recanted ?j)))
    :effect (and (leaflets-distributed ?j) (increase (unrest ?l) 2) (increase (attention ?j) 2)
                 (decrease (stability ?l) 1)))
  (:action expose-informer
    :parameters (?j - dissident ?k - informer ?l - place)
    :precondition (and (has-file ?j) (not (informer-exposed ?k)) (not (arrested ?j)) (not (recanted ?j)))
    :effect (and (informer-exposed ?k) (increase (unrest ?l) 1) (increase (attention ?j) 1)
                 (decrease (stability ?l) 2)))
  (:action recant
    :parameters (?j - dissident)
    :precondition (and (under-observation ?j) (not (arrested ?j)) (not (recanted ?j)))
    :effect (and (recanted ?j) (not (under-observation ?j)) (decrease (attention ?j) 2)))
  (:action inform-on-archivist
    :parameters (?j - dissident ?v - archivist)
    :precondition (and (turned ?j) (has-file ?j) (not (under-observation ?v)))
    :effect (and (under-observation ?v) (released ?j) (increase (attention ?v) 3)))

  ;; --- the informer -----------------------------------------------------------------------
  (:action inform
    :parameters (?k - informer ?j - dissident)
    :precondition (and (not (informer-exposed ?k)) (not (under-observation ?j)) (not (recanted ?j)))
    :effect (and (under-observation ?j) (increase (attention ?j) 1)))
  (:action report-neighbour
    :parameters (?k - informer ?v - archivist ?p - person)
    :precondition (and (warned ?p) (not (informer-exposed ?k)) (not (under-observation ?v)))
    :effect (and (under-observation ?v) (increase (attention ?v) 2)))

  ;; --- the state officer ------------------------------------------------------------------
  (:action raid
    :parameters (?r - officer ?j - dissident ?l - place)
    :precondition (and (under-observation ?j) (not (press-raided ?j)) (not (recanted ?j)))
    :effect (and (press-raided ?j) (arrested ?j) (increase (unrest ?l) 2)))
  (:action query-ledger
    :parameters (?r - officer ?v - archivist)
    :precondition (and (discrepancy ?v) (not (under-observation ?v)))
    :effect (and (under-observation ?v) (increase (attention ?v) 2)))
  (:action turn-informer
    :parameters (?r - officer ?j - dissident)
    :precondition (and (arrested ?j) (not (turned ?j)))
    :effect (and (turned ?j) (not (arrested ?j))))
  (:action order-fire
    :parameters (?r - officer ?t - conscript ?l - place)
    :precondition (and (crowd-at ?l) (wavering ?l) (not (ordered-fire ?t)) (not (stood-down ?l)))
    :effect (ordered-fire ?t))

  ;; --- the conscript ----------------------------------------------------------------------
  (:action obey-order
    :parameters (?t - conscript ?r - officer ?l - place)
    :precondition (and (ordered-fire ?t) (crowd-at ?l) (not (fired-on-crowd ?l)) (not (stood-down ?l)))
    :effect (and (fired-on-crowd ?l) (unit-safe ?t) (increase (unrest ?l) 3) (decrease (stability ?l) 2)))
  (:action stand-down
    :parameters (?t - conscript ?l - place)
    :precondition (and (crowd-at ?l) (wavering ?l) (not (stood-down ?l)) (not (fired-on-crowd ?l)))
    :effect (and (stood-down ?l) (border-open ?l) (deserted ?t) (decrease (stability ?l) 3)))

  ;; --- the world's own moves (declared happening/1 in the topic file) ----------------------
  (:action crowd-gathers
    :parameters (?l - place)
    :precondition (not (crowd-at ?l))
    :effect (and (crowd-at ?l) (increase (unrest ?l) 1)))
  (:action regime-wavers
    :parameters (?l - place)
    :precondition (not (wavering ?l))
    :effect (and (wavering ?l) (decrease (stability ?l) 2)))
  (:action regime-panics
    :parameters (?l - place)
    :precondition (and (wavering ?l) (crowd-at ?l) (not (panicking ?l)))
    :effect (and (panicking ?l) (decrease (stability ?l) 2))))
