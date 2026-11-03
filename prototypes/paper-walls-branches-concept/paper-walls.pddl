;; PROTOTYPE - NOT FOR PRODUCTION
;; Question: Can polyscene enumerate the admissible story branches of Paper Walls from a
;;           small world of dossier flags, five agents and the state's own motion?
;; Date: 2026-11-03
;;
;; What CAN happen in the six weeks: the action space. Every fluent is at least unary so the
;; engine's holds1/holds2 read-backs reach it; `border` is the one place. Agents are typed by
;; role so each action grounds only for the role that can take it.
(define (domain paper-walls)
  (:requirements :strips :typing :numeric-fluents)
  (:types agent person place - object
          archivist dissident conscript officer informer - agent)
  (:predicates
    (report-received ?v - archivist ?p - person)   ; the archivist holds informer report 4471 on p
    (knows-parcel ?v - archivist)                  ; she has read enough to know the parcel was medicine
    (filed ?p - person)
    (burned ?p - person)
    (under-observation ?x - object)                ; the state is watching x
    (warned ?p - person)
    (household-complete ?v - archivist)            ; her file is "complete": the daughter's review closes
    (discrepancy ?v - archivist)                   ; a report logged by its source but never entered
    (has-file ?j - dissident)                      ; the dissident holds the leaked report
    (leaflets-printed ?j - dissident)
    (leaflets-distributed ?j - dissident)
    (press-raided ?j - dissident)
    (arrested ?j - dissident)
    (informer-exposed ?k - informer)
    (crowd-at ?l - place)
    (ordered-fire ?t - conscript)
    (fired-on-crowd ?l - place)
    (stood-down ?l - place)
    (border-open ?l - place))
  (:functions
    (unrest ?l - place)
    (attention ?x - object))

  ;; --- the archivist -----------------------------------------------------------------------
  (:action read-file
    :parameters (?v - archivist ?p - person)
    :precondition (and (report-received ?v ?p) (not (knows-parcel ?v)))
    :effect (knows-parcel ?v))
  (:action file-report
    :parameters (?v - archivist ?p - person)
    :precondition (and (report-received ?v ?p) (not (filed ?p)) (not (burned ?p)))
    :effect (and (filed ?p) (under-observation ?p) (household-complete ?v)
                 (increase (attention ?p) 2)))
  (:action burn-report
    :parameters (?v - archivist ?p - person)
    :precondition (and (report-received ?v ?p) (not (filed ?p)) (not (burned ?p)))
    :effect (and (burned ?p) (discrepancy ?v) (increase (attention ?v) 1)))
  (:action warn
    :parameters (?v - archivist ?p - person)
    :precondition (and (knows-parcel ?v) (not (warned ?p)))
    :effect (and (warned ?p) (increase (attention ?v) 2)))
  (:action leak-file
    :parameters (?v - archivist ?j - dissident ?p - person)
    :precondition (and (report-received ?v ?p) (not (has-file ?j)) (not (arrested ?j)))
    :effect (and (has-file ?j) (increase (attention ?v) 1)))

  ;; --- the dissident ----------------------------------------------------------------------
  (:action print-leaflets
    :parameters (?j - dissident ?l - place)
    :precondition (and (not (press-raided ?j)) (not (leaflets-printed ?j)) (not (arrested ?j)))
    :effect (and (leaflets-printed ?j) (increase (unrest ?l) 1)))
  (:action distribute
    :parameters (?j - dissident ?l - place)
    :precondition (and (leaflets-printed ?j) (not (leaflets-distributed ?j)) (not (arrested ?j)))
    :effect (and (leaflets-distributed ?j) (increase (unrest ?l) 2) (increase (attention ?j) 2)))
  (:action expose-informer
    :parameters (?j - dissident ?k - informer ?l - place)
    :precondition (and (has-file ?j) (not (informer-exposed ?k)) (not (arrested ?j)))
    :effect (and (informer-exposed ?k) (increase (unrest ?l) 1) (increase (attention ?j) 1)))

  ;; --- the informer -----------------------------------------------------------------------
  (:action inform
    :parameters (?k - informer ?j - dissident)
    :precondition (and (not (informer-exposed ?k)) (not (under-observation ?j)))
    :effect (and (under-observation ?j) (increase (attention ?j) 1)))

  ;; --- the state officer ------------------------------------------------------------------
  (:action raid
    :parameters (?r - officer ?j - dissident ?l - place)
    :precondition (and (under-observation ?j) (not (press-raided ?j)))
    :effect (and (press-raided ?j) (arrested ?j) (increase (unrest ?l) 2)))
  (:action query-ledger
    :parameters (?r - officer ?v - archivist)
    :precondition (and (discrepancy ?v) (not (under-observation ?v)))
    :effect (and (under-observation ?v) (increase (attention ?v) 2)))
  (:action order-fire
    :parameters (?r - officer ?t - conscript ?l - place)
    :precondition (and (crowd-at ?l) (not (ordered-fire ?t)) (not (stood-down ?l)))
    :effect (ordered-fire ?t))

  ;; --- the conscript ----------------------------------------------------------------------
  (:action obey-order
    :parameters (?t - conscript ?r - officer ?l - place)
    :precondition (and (ordered-fire ?t) (crowd-at ?l) (not (fired-on-crowd ?l)) (not (stood-down ?l)))
    :effect (and (fired-on-crowd ?l) (increase (unrest ?l) 3)))
  (:action stand-down
    :parameters (?t - conscript ?l - place)
    :precondition (and (crowd-at ?l) (not (stood-down ?l)) (not (fired-on-crowd ?l)))
    :effect (and (stood-down ?l) (border-open ?l)))

  ;; --- the world's own move (declared happening/1 in the topic file) -----------------------
  (:action crowd-gathers
    :parameters (?l - place)
    :precondition (not (crowd-at ?l))
    :effect (and (crowd-at ?l) (increase (unrest ?l) 1))))
