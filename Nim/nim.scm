;; This file contains excerpts from the textbook Concrete
;; Abstractions: An Introduction to Computer Science Using Scheme, by
;; Max Hailperin, Barbara Kaiser, and Karl Knight, Copyright (c) 1998
;; by the authors. Full text is available for free at
;; http://www.gustavus.edu/+max/concrete-abstractions.html

;; Chapter 6: Compound Data and Data Abstraction

;; 6.2  Nim

(define nim
  (lambda ()
    (display '"Welcome to the game of Nim.")
    (newline)
    (define i (lambda ()(+ (random 6) 6)))
    (define j (lambda ()(+ (random 6) 6)))
    (define create-rand-state
      (lambda (l k)
        (if (= l k)
            (create-rand-state l (j))
            (make-game-state l k))
        ))
    (let ((randnum (random 2)))
      (if (= randnum (prompt '"I have a number between 0 and 1.  Which is it?" valid-coin-flip? '"number is not between 0 and 1."))
          (begin (display "The number is ")(display randnum)(display ". It is your turn.")
                 (play-with-turns (create-rand-state (i) (j)) 'human)
                 )
          (begin     (display "The number is ")(display randnum)(display ". I will go first.")
                     (play-with-turns (create-rand-state (i) (j)) 'computer))))))
(define valid-coin-flip?
  (lambda (number)
    (cond ((equal? number 0) #t)
          ((equal? number 1) #t)
          (else #f)
          )))
(define valid-pile-number?
  (lambda (game-state pile-number)
    (cond ((not (number? pile-number)) #f)
          ((equal? (size-of-pile game-state pile-number) 0) #f)
          ((equal? pile-number 1) #t)
          ((equal? pile-number 2) #t)
          (else #f))
    ))
(define valid-pile-move?
  (lambda (game-state pile-number removal)
    (cond ((not (number? removal)) #f)
          ((< removal 0) #f)
          ((> removal (size-of-pile game-state pile-number)) #f)
          (else #t))
    ))
(define play-with-turns
  (lambda (game-state player)
    (display-game-state game-state)
    (cond ((over? game-state) 
           (announce-winner player))
          ((equal? player 'human)  
           (play-with-turns (human-move game-state) 'computer))
          ((equal? player 'computer)  
           (play-with-turns (computer-move game-state) 'human))
          (else  
           (error "player wasn't human or computer:" player)))))

(define computer-move
  (lambda (game-state)
    (let ((pile (pile (intelligent-strategy-2-pile game-state)))
          (coin (coins (intelligent-strategy-2-pile game-state))))
      (display "I take ")
      (display coin)
      (display " from pile ")
      (display pile)
      (newline)
      (next-game-state game-state (intelligent-strategy-2-pile game-state)))))

;(define prompt
;  (lambda (prompt-string)
;    (newline)
;    (display prompt-string)
;    (newline)
;    (read)))
(define prompt
  (lambda (prompt-string valid? error-string)
    (newline)
    (display prompt-string)
    (newline)
    (let ((prompt-response (read)))
      (if (valid? prompt-response)
          prompt-response
          (begin (display error-string)
                 (prompt prompt-string valid? error-string))))))

(define human-move
  (lambda (game-state)
    (let ((p (prompt "Which pile will you remove from?" (lambda (new-prompt-string) (valid-pile-number? game-state new-prompt-string)) '"Bad pile number. Try again.")))
      (let ((n (prompt "How many coins do you want to remove?" (lambda (removal) (valid-pile-move? game-state p removal)) '"Bad number of coins. Try again.")))
        (next-game-state game-state (make-move-instruction n p))))))

(define over?
  (lambda (game-state)
    (= (total-size game-state) 0)))

(define announce-winner
  (lambda (player)
    (if (equal? player 'human) 
        (display "You lose. Better luck next time.")
        (display "You win. Congratulations."))))

;; 6.3  Representations and Implementations

;; Sidebar: Game State ADT Implementation

(define make-game-state
  (lambda (n m) (cons n m)))

(define size-of-pile
  (lambda (game-state pile-number)
    (if (= pile-number 1)
        (car game-state)
        (cdr game-state))))

;(define remove-coins-from-pile
;  (lambda (game-state num-coins pile-number)
;    (if (= pile-number 1)
;        (make-game-state (- (size-of-pile game-state 1)
;                            num-coins) 
;                         (size-of-pile game-state 2))
;        (make-game-state (size-of-pile game-state 1)
;                         (- (size-of-pile game-state 2)
;                            num-coins)))))

(define display-game-state
  (lambda (game-state)
    (newline)
    (newline)
    (display "    Pile 1: ")
    (display (size-of-pile game-state 1))
    (newline)
    (display "    Pile 2: ")
    (display (size-of-pile game-state 2))
    (newline)
    (newline)))

(define total-size
  (lambda (game-state)
    (+ (size-of-pile game-state 1)
       (size-of-pile game-state 2))))

(define intelligent-strategy-2-pile
  (lambda (game-state)
    (cond ((equal? (size-of-pile game-state 1) (size-of-pile game-state 2))
           (make-move-instruction 1 1))
          ((= (size-of-pile game-state 2) 0)
           (make-move-instruction (size-of-pile game-state 1) 1))
          ((= (size-of-pile game-state 1) 0)
           (make-move-instruction (size-of-pile game-state 2) 2))
          ((> (size-of-pile game-state 1) (size-of-pile game-state 2))
          (make-move-instruction
             (- (size-of-pile game-state 1) (size-of-pile game-state 2)) 1))
          ((> (size-of-pile game-state 2) (size-of-pile game-state 1))
           (make-move-instruction
              (- (size-of-pile game-state 2) (size-of-pile game-state 1)) 2))
          (else (next-game-state game-state (make-move-instruction 1 2)))
          )))
;; *******************************************************************
;; A Move Instruction ADT (Exercise 6.13, pp. 156-7)

(define make-move-instruction cons)

(define coins car)

(define pile cdr)


(define next-game-state
  (lambda (game-state move-instruction)
    (if (equal? (pile move-instruction) 1)
        (make-game-state (- (car game-state) (coins move-instruction)) (cdr game-state))
        (make-game-state (car game-state) (- (cdr game-state) (coins move-instruction))))))
;; *******************************************************************
;; 3-pile Nim game state representation
;;
;; When you are ready to move to 3-pile nim, uncomment the constructor
;; and selector below

;; (define make-game-state
;;   (lambda (n m k) (cons k (cons n m))))

;; (define size-of-pile
;;   (lambda (game-state pile-number)
;;     (cond ((= pile-number 3)
;; 	   (car game-state))
;; 	  ((= pile-number 1)
;; 	   (car (cdr game-state)))
;; 	  (else ; pile-number must be 2
;; 	   (cdr (cdr game-state))))))