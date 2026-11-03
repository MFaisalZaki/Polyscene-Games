;; PROTOTYPE - NOT FOR PRODUCTION
;; Question: Does the act-one brief, as a polyscene world, yield the nine ending classes?
;; Date: 2026-11-03
;; Friday of Plan Week 40: 4471 one month old on Vera's desk; the household file incomplete;
;; Ilona's review pending; a press with no paper; Ondra's log; two days of medicine.
(define (problem act-one) (:domain paper-walls-act1)
  (:objects vera - archivist  jan - dissident  tomas - conscript  ondra - bunkmate  rybar - officer
            kastan - informer  marta - widow  ilona - daughter  berta - colleague
            marek - person
            vrba border city - place)
  (:init (report-received vera) (review-pending ilona)
         (= (unrest city) 1) (= (stability city) 9) (= (breath marta) 2)
         (= (attention vera) 0) (= (attention jan) 1) (= (attention tomas) 0) (= (attention ondra) 0)
         (= (attention rybar) 0) (= (attention kastan) 0) (= (attention marta) 1) (= (attention ilona) 0)
         (= (attention berta) 0) (= (attention marek) 0)
         (= (unrest vrba) 0) (= (unrest border) 0) (= (stability vrba) 0) (= (stability border) 0))
  (:goal (and)))
