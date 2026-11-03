;; PROTOTYPE - NOT FOR PRODUCTION
;; Question: Can polyscene enumerate the admissible story branches of Paper Walls?
;; Date: 2026-11-03
;;
;; What IS the case on Friday 6 October: the opening. No goal: a telling ends when it is
;; terminal, not when a goal is met.
(define (problem week-one) (:domain paper-walls)
  (:objects vera - archivist  jan - dissident  tomas - conscript  rybar - officer  kastan - informer
            marta - person
            border - place)
  (:init (report-received vera marta)
         (= (unrest border) 2) (= (stability border) 9)
         (= (attention vera) 0) (= (attention jan) 1) (= (attention tomas) 0)
         (= (attention rybar) 0) (= (attention kastan) 0) (= (attention marta) 1)
         (= (attention border) 0))
  (:goal (and)))
