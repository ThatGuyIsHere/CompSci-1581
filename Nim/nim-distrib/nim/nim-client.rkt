#lang racket/gui

(require "nim-common.rkt" 
	 "../framework/common.rkt"
	 "../framework/client.rkt"
         "../framework/client-ui.rkt")

(send frame set-label "Nim Client")

(send receive-field min-height 300)


(define connection-state welcome-state)

;; ************************************************************
;; Connection state test predicates

(define welcome-state?
  (lambda () (equal? connection-state welcome-state)))

(define name-state?
  (lambda () (equal? connection-state name-state)))

(define level-state?
  (lambda () (equal? connection-state level-state)))

(define mode-state?
  (lambda () (equal? connection-state mode-state)))

(define flip-state?
  (lambda () (equal? connection-state flip-state)))

(define move-state?
  (lambda () (equal? connection-state move-state)))

(define winner-state?
  (lambda () (equal? connection-state winner-state)))

(define automate-state?
  (lambda () (equal? connection-state automate-state)))

(define strategy-state?
  (lambda () (equal? connection-state strategy-state)))

(define bad-strategy-state?
  (lambda () (equal? connection-state bad-strategy-state)))

(define results-state?
  (lambda () (equal? connection-state results-state)))


;; **************************************************************************
;; Welcoming client and getting client-strategy

(define change-to-welcome
  (lambda ()
    (set! connection-state welcome-state)
    (change-send-component dummy-label)
    (send send-label set-label "")
    (send send-button set-label "Continue")))


;; **************************************************************************
;; Prompting for and getting player's name

(define name-field (new text-field%
			[parent dummy-frame]
			[label ""]))

(define change-to-name
  (lambda ()
    (set! connection-state name-state)
    (change-send-component name-field)
    (send send-label set-label "Your Name")
    (send send-button set-label "Send Name")))


;; **************************************************************************

(define level-choice (new choice%
			  [label ""]
			  [choices '("Mindless" "Beginner" "Advanced" "Expert")]
			  [parent dummy-frame]
			  ))

(define change-to-level
  (lambda ()
    (set! connection-state level-state)
    (change-send-component level-choice)
    (send send-label set-label "Choose Level")
    (send send-button set-label "Send Level")))

;; **************************************************************************

(define mode-choice (new choice%
			 [label ""]
			 [choices '("Human" "Automated")]
			 [parent dummy-frame]
			 ))
(define change-to-mode
  (lambda ()
    (set! connection-state mode-state)
    (change-send-component mode-choice)
    (send send-label set-label "Choose Mode")
    (send send-button set-label "Send Mode")))

;; **************************************************************************

(define flip-choice (new choice%
			 [label ""]
			 [choices '("Heads" "Tails")]
			 [parent dummy-frame]
			 ))
(define change-to-flip
  (lambda ()
    (set! connection-state flip-state)
    (change-send-component flip-choice)
    (send send-label set-label "Choose Heads or Tails")
    (send send-button set-label "Send Choice")))

;; **************************************************************************
;; Prompting for and getting a move

(define move-panel (new horizontal-panel% [parent dummy-frame]))

(define pile-field (new text-field%
                        [parent move-panel]
                        [label "Pile"]))

(define coins-field (new text-field%
			 [parent move-panel]
			 [label "Coins"]))

(define change-to-move
  (lambda ()
    (set! connection-state move-state)
    (change-send-component move-panel)
    (send send-label set-label "Your Move")
    (send send-button set-label "Send Move")))


;; **************************************************************************

(define continue-choice (new choice%
			     [label ""]
			     [choices '("Yes" "No")]
			     [parent dummy-frame]
			     ))
(define change-to-winner
  (lambda ()
    (set! connection-state winner-state)
    (change-send-component continue-choice)
    (send send-label set-label "Choose Yes or No")
    (send send-button set-label "Send Choice")))

;; **************************************************************************

(define automate-choice (new choice%
			     [label ""]
			     [choices '("Game" "Series")]
			     [parent dummy-frame]
			     ))
(define change-to-automate
  (lambda ()
    (set! connection-state automate-state)
    (change-send-component automate-choice)
    (send send-label set-label "Choose Type of Competition")
    (send send-button set-label "Send Type")))

;; **************************************************************************

(define dummy-label (new message%
			 [parent dummy-frame]
			 [label ""]))

(define change-to-strategy
  (lambda ()
    (set! connection-state strategy-state)
    (change-send-component dummy-label)
    (send send-label set-label "To Confirm, Click OK")
    (send send-button set-label "OK")))


(define change-to-bad-strategy
  (lambda ()
    (set! connection-state bad-strategy-state)
    (change-send-component dummy-label)
    (send send-label set-label "Upon clicking OK, you will be disconnected")
    (send send-button set-label "OK")))


;; **************************************************************************

(define change-to-results
  (lambda ()
    (set! connection-state results-state)
    (change-send-component continue-choice)
    (send send-label set-label "More Competition?")
    (send send-button set-label "Send Choice")))

;; **************************************************************************

(handle-message
 (lambda (message)   
   (send receive-field set-value (tagged-message-message message))
   (cond ((welcome-message? message) (change-to-welcome))
	 ((name-message? message) (change-to-name))
	 ((level-message? message) (change-to-level))
	 ((mode-message? message) (change-to-mode))
	 ((flip-message? message) (change-to-flip))
	 ((move-message? message) (change-to-move))
	 ((winner-message? message) (change-to-winner))
	 ((automate-message? message) (change-to-automate))
	 ((strategy-message? message) (change-to-strategy))
	 ((bad-strategy-message? message) (change-to-bad-strategy))
	 ((results-message? message) (change-to-results))
	 (else (error "Something's wrong in handle-message."))
	 )))

(handle-send-click
 (lambda (button event)
   (cond ((welcome-state?) client-strategy)
	 ((name-state?) (send name-field get-value))
	 ((level-state?) (send level-choice get-string-selection))
	 ((mode-state?) (send mode-choice get-string-selection))
	 ((flip-state?) (send flip-choice get-string-selection))
	 ((move-state?) (let ((pile (send pile-field get-value))
			      (coins (send coins-field get-value)))
			  (send pile-field set-value "")
			  (send coins-field set-value "")
			  (make-move-instruction coins pile)))
	 ((winner-state?) (let ((continue (send continue-choice get-string-selection)))
			    (cond ((equal? continue "No")
				   (set! connection-state handshake-state)
				   client-quit-message)
				  (else continue)))) ;; "Yes"
	 ((automate-state?) (send automate-choice get-string-selection))
	 ((strategy-state?) client-strategy)
	 ((bad-strategy-state?) (disconnect) "disconnected")
	 ((results-state?) (let ((continue (send continue-choice get-string-selection)))
			     (cond ((equal? continue "No")
				    (set! connection-state handshake-state)
				    client-quit-message)
				   (else continue)))) ;; "Yes"
	 (else (error "Something's wrong in handle-send-click.")))))
	  
;; *********************************************************************
;; Client's Nim strategy
;;
;; Your client's Nim strategy must be defined as "client-strategy" as
;; shown below.  Note:
;;
;; 1. The value of client-strategy must be a QUOTED lambda expression.
;;    This is necessary in order for the strategy to be sent over an
;;    internet connection to the Nim server.
;; 2. The client-strategy procedure must take a Nim game state as its
;;    single argument and return a valid move instruction as its value.
;; 3. The example client-strategy shown below implements the simple-minded
;;    strategy that simply takes one coin from the first non-empty pile.
;;    You can use this strategy to test your Nim client connection to the
;;    Nim server.
;; 4. When you implement your own Nim strategy, any helper procedures you
;;    define to support client-strategy must be defined internal to 
;;    client-strategy.

(define client-strategy
  '(lambda (game-state)
     (if (or (equal? (size-of-pile game-state 1) 0) (equal? (size-of-pile game-state 2) 0) (equal? (size-of-pile game-state 3) 0))
         (let ((px (if (= (size-of-pile game-state 1) 0)
                       2
                       1))
               (py (if (= (size-of-pile game-state 2) 0)
                       3
                       2)))
         (cond ((equal? (size-of-pile game-state px) (size-of-pile game-state py))
                (make-move-instruction 1 px))
               ((= (size-of-pile game-state py) 0)
                (make-move-instruction (size-of-pile game-state px) px))
               ((= (size-of-pile game-state px) 0)
                (make-move-instruction (size-of-pile game-state py) py))
               ((> (size-of-pile game-state px) (size-of-pile game-state py))
                (make-move-instruction
                 (- (size-of-pile game-state px) (size-of-pile game-state py)) px))
               ((> (size-of-pile game-state py) (size-of-pile game-state px))
                (make-move-instruction
                 (- (size-of-pile game-state py) (size-of-pile game-state px)) py))
               (else (make-move-instruction 1 py)))
          )
         (cond ((odd?  (+ (size-of-pile game-state 1) (size-of-pile game-state 2) (size-of-pile game-state 3)))
                (let ((pone (size-of-pile game-state 1))
                      (ptwo (size-of-pile game-state 2))
                      (pthree (size-of-pile game-state 3)))
                (if (and (> pthree pone) (> pthree ptwo))
                    (make-move-instruction 1 3)
                    (if (and (> ptwo pone) (> ptwo pthree))
                        (make-move-instruction 1 2)
                        (make-move-instruction 1 1))))
                        
               )(else (let ((pone (size-of-pile game-state 1))
                            (ptwo (size-of-pile game-state 2))
                            (pthree (size-of-pile game-state 3)))
                (if (and (> pthree pone) (> pthree ptwo))
                    (make-move-instruction 2 3)
                    (if (and (> ptwo pone) (> ptwo pthree))
                        (make-move-instruction 2 2)
                        (make-move-instruction 2 1))))
               )))
     ))
