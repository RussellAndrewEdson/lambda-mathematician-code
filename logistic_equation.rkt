;;;; Racket code to explore the chaotic behaviour of the logistic equation.
;;;; Date: 13/02/2016

#lang racket
(require plot)

;;; The logistic equation, x(n+1) = r*x(n)*(1-x(n))
(define (logistic-equation r x)
  (* r x (- 1 x)))

;;; Returns a list of iterations of the logistic equation for a given 
;;; parameter r and starting point x-init.
(define (iterate-logistic-equation steps r x-init)
  (let ((xs (list x-init)))
    (for ((i (in-range 0 steps)))
      (set! xs (cons (logistic-equation r (car xs)) xs)))
    (map vector (stream->list (in-range 0 (+ 1 steps))) (reverse xs))))

;;; Plots the graph of x(n) for the given number of steps, parameter r
;;; and starting point x-init.
(define (plot-logistic-equation steps r x-init)
  (parameterize ((plot-width 400)
                 (plot-height 200)
                 (plot-font-size 11)
                 (plot-x-label "n")
                 (plot-y-label "x(n)"))
    (plot
     (lines (iterate-logistic-equation steps r x-init) 
            #:y-min 0 #:y-max 1 #:color 'blue))))

;;; Plots the cobweb diagram for the given number of steps, parameter r
;;; and starting point x-init.
(define (plot-cobweb-diagram steps r x-init)
  (define (cobweb)
    (let ((endpoints (list (vector x-init 0)))
          (x x-init)
          (y '()))
      (for ((i (in-range 0 steps)))
        (set! y (logistic-equation r x))
        (set! endpoints 
              (cons (vector y y) 
                    (cons (vector x y) endpoints)))
        (set! x y))
      (reverse endpoints)))
  (parameterize ((plot-width 400)
                 (plot-height 400)
                 (plot-font-size 11)
                 (plot-x-label "x")
                 (plot-y-label "y")
                 (line-color 'black))
    (plot
     (list
      (function (lambda (x) (logistic-equation r x)) 0 1)
      (function identity 0 1)
      (lines (cobweb) 
             #:x-min 0 #:x-max 1 #:color 'blue)))))

;;; Plots the bifurcation diagram, using the given starting point
;;; x-init (using 100 iterations, and plots the values for the
;;; last 30.)
(define (plot-bifurcation-diagram x-init)
  (define (steady-state-points)
    (let ((points '())
          (step-size 0.001)
          (iterations 100)
          (keep-last-points 30))
      (for ((r (in-range 0 4 step-size)))
        (let ((xs (list x-init)))
          (for ((n (in-range 2 iterations)))
            (let ((x (car xs)))
              (set! xs (cons (logistic-equation r x) xs))))
          (set! points 
                (append points (map (lambda (x) (vector r x)) 
                                    (take xs keep-last-points))))))
      points))
  (parameterize ((plot-width 400)
                 (plot-height 400)
                 (plot-font-size 11)
                 (plot-x-label "r")
                 (plot-y-label "x"))
    (plot (points (steady-state-points) 
                  #:x-min 0 #:x-max 4 #:y-min 0 #:y-max 1
                  #:sym 'dot #:color 'blue))))
