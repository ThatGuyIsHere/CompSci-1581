(require "lab03.scm")
(require "test-utilities.scm")

;; ********************************************************************
;; The following definitions are taken from the text and are used for
;; testing Ex. 3.6

(define sum-of-divisors
  (lambda (n)
    (define sum-from-plus
      (lambda (low addend)
        (if (> low n)
            addend
            (sum-from-plus (+ low 1) (if (divides? low n)
                                         (+ addend low)
                                         addend)))))
    (sum-from-plus 1 0)))

(define perfect?
  (lambda (n)
    (= (sum-of-divisors n) (* 2 n))))

(define first-perfect-after
  (lambda (n)
    (let ((next (+ n 1)))
      (if (perfect? next)
          next
          (first-perfect-after next)))))


;; ********************************************************************
;; Tests for Ex. 3.6, page 60

(display-results "3.6: The textbook's implementation of sum-of-divisors")
 
(begin (time (assert (= (first-perfect-after 496) 8128)))
       (values))

;; The following definitions are for Exercise 3.6, p. 60.
;; You must supply sum-of-divisors-eff in lab03.scm

(define first-perfect-after-eff
  (lambda (n)
    (let ((next (+ n 1)))
      (if (perfect-eff? next)
          next
          (first-perfect-after-eff next)))))

(define perfect-eff?
  (lambda (n)
    (= (sum-of-divisors-eff n) (* 2 n))))

(display-results "3.6: First test your sum-of-divisors-eff")
 
(assert (= (sum-of-divisors-eff 25) 31))
(assert (= (sum-of-divisors-eff 36) 91))

(display-results "3.6: Your implementation of sum-of-divisors-eff should be significantly faster:")
 
(begin (time (assert (= (first-perfect-after-eff 496) 8128)))
       (values))

;; ********************************************************************
;; Tests for Exercise 3.10, p. 68

(display-results "3.10")
 
(assert (= (renumber 5 8) 2))
(assert (= (renumber 17 40) 14))
(assert (= (renumber 1 40) 38))
(assert (= (renumber 2 40) 39))


;; ********************************************************************
;; Tests for Exercise 3.11, p. 68

(display-results "3.11")
 
(assert (survives? 4 8))
(assert (survives? 7 8))
(assert (survives? 13 40))
(assert (survives? 28 40))


;; ********************************************************************
;; Tests for Exercise 3.12, p. 68

(display-results "3.12")
 

;; The following tests your solution to the Problem of Josephus,
;; 

;(assert (= (first-survivor-after 0 8) 4))
(assert (= (first-survivor-after 4 8) 7))
(assert (= (first-survivor-after 7 8) 0))

(assert (= (first-survivor-after 0 40) 13))
(assert (= (first-survivor-after 13 40) 28))
(assert (= (first-survivor-after 28 40) 0))

