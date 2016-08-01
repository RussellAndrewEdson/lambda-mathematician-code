;;;; Racket code to generate fractals with Barnsley's Chaos Game.
;;;; Date: 01/08/2016

#lang racket
(require plot)

;;; Barnsley's Chaos Game. Draws the fractal for a given set of
;;; update rules starting from an (arbitrary) initial point with
;;; a specified number of iterations.
(define (chaos-game rules init-point iterations)
  ;; Returns the cumulative distribution for the rules list.
  (define (cumulative-probabilities rules-list)
    (let ((prob-sum 0.0)
          (cumulative-rules-list '()))
      (for ((rule rules-list))
        (set! prob-sum (+ (car rule) prob-sum))
        (set! cumulative-rules-list
              (cons (cons prob-sum (cdr rule))
                    cumulative-rules-list)))
      (reverse cumulative-rules-list)))
  
  ;; Chooses a random rule from the rules list.
  (define (choose-rule rules-list)
    (let ((p (random)))
      (for/first ((rule (cumulative-probabilities rules-list))
                  #:when (<= p (car rule)))
        (cdr rule))))
  
  (let ((plot-points (list (list init-point 'black)))
        (drop-points 50)
        (rules-list (sort rules < #:key car)))
    (for ((n (in-range iterations)))
      (set! plot-points
            (let ((rule-and-color (choose-rule rules-list)))
              (cons (list
                     ((car rule-and-color) (caar plot-points))
                     (cadr rule-and-color))
                    plot-points))))
    ;; Drop some of the first points to "remove the randomness".
    (set! plot-points (drop (reverse plot-points) drop-points))

    ;; Sort the list according to each of the different colors
    ;; to be drawn for the plot.
    (let ((colors (remove-duplicates (map cadr plot-points))))
      (set! plot-points
            (map (lambda (color)
                   (map car (filter (lambda (point)
                                      (eq? color (cadr point)))
                                    plot-points)))
                 colors))
      (parameterize ((plot-width 400)
                     (plot-height 400)
                     (plot-font-size 11)
                     (plot-x-label "x")
                     (plot-y-label "y")
                     (plot-decorations? #t))
        (plot-file (map (lambda (color colored-points)
                          (points colored-points #:sym 'dot #:color color))
                        colors
                        plot-points)
                   "output.png")))))

;; The Sierpinski triangle.
(define (make-triangle-rules)
  (list
   (list 1/3 (lambda (p)
               (list (* 1/2 (car p))
                     (* 1/2 (cadr p))))
         1)
   (list 1/3 (lambda (p)
               (list (+ (* 1/2 (car p)) 1/4)
                     (+ (* 1/2 (cadr p)) (/ (sqrt 3) 4))))
         2)
   (list 1/3 (lambda (p)
               (list (+ (* 1/2 (car p)) 1/2)
                     (* 1/2 (cadr p))))
         3)))

;; David's flower fractal.
(define (make-flower-rules)
  (list
   (list 1/6 (lambda (p)
               (list (+ (* 1/3 (car p)) 2/3)
                     (* 1/3 (cadr p))))
         1)
   (list 1/6 (lambda (p)
               (list (+ (* 1/3 (car p)) 4/3)
                     (* 1/3 (cadr p))))
         2)
   (list 1/6 (lambda (p)
               (list (+ (* 1/3 (car p)) 1/3)
                     (+ (* 1/3 (cadr p)) (/ (sqrt 3) 3))))
         3)
   (list 1/6 (lambda (p)
               (list (+ (* 1/3 (car p)) 5/3)
                     (+ (* 1/3 (cadr p)) (/ (sqrt 3) 3))))
         4)
   (list 1/6 (lambda (p)
               (list (+ (* 1/3 (car p)) 2/3)
                     (+ (* 1/3 (cadr p)) (* 2/3 (sqrt 3)))))
         5)
   (list 1/6 (lambda (p)
               (list (+ (* 1/3 (car p)) 4/3)
                     (+ (* 1/3 (cadr p)) (* 2/3 (sqrt 3)))))
         6)))

;; The Barnsley fern.
(define (make-fern-rules)
  (list
   (list 0.01 (lambda (p)
                (list 0
                      (* 0.16 (cadr p))))
         2)
   (list 0.85 (lambda (p)
                (list (+ (* 0.85 (car p)) (* 0.04 (cadr p)))
                      (+ (* -0.04 (car p)) (* 0.85 (cadr p)) 1.6)))
         2)
   (list 0.07 (lambda (p)
                (list (+ (* 0.20 (car p)) (* -0.26 (cadr p)))
                      (+ (* 0.23 (car p)) (* 0.22 (cadr p)) 1.6)))
         2)
   (list 0.07 (lambda (p)
                (list (+ (* -0.15 (car p)) (* 0.28 (cadr p)))
                      (+ (* 0.26 (car p)) (* 0.24 (cadr p)) 0.44)))
         2)))

;; The Dragon curve.
(define (make-dragon-rules)
  (list
   (list 1/2 (lambda (p)
               (list (+ (* 1/2 (car p)) (* -1/2 (cadr p)) 1)
                     (+ (* 1/2 (car p)) (* 1/2 (cadr p)))))
         1)
   (list 1/2 (lambda (p)
               (list (+ (* 1/2 (car p)) (* -1/2 (cadr p)) -1)
                     (+ (* 1/2 (car p)) (* 1/2 (cadr p)))))
         3)))

;; The Sierpinski carpet
(define (make-carpet-rules)
  (list
   (list 1/8 (lambda (p)
               (list (* 1/3 (car p))
                     (* 1/3 (cadr p))))
         1)
   (list 1/8 (lambda (p)
               (list (+ (* 1/3 (car p)) 1/3)
                     (* 1/3 (cadr p))))
         2)
   (list 1/8 (lambda (p)
               (list (+ (* 1/3 (car p)) 2/3)
                     (* 1/3 (cadr p))))
         3)
   (list 1/8 (lambda (p)
               (list (* 1/3 (car p))
                     (+ (* 1/3 (cadr p)) 1/3)))
         4)
   (list 1/8 (lambda (p)
               (list (+ (* 1/3 (car p)) 2/3)
                     (+ (* 1/3 (cadr p)) 1/3)))
         5)
   (list 1/8 (lambda (p)
               (list (* 1/3 (car p))
                     (+ (* 1/3 (cadr p)) 2/3)))
         6)
   (list 1/8 (lambda (p)
               (list (+ (* 1/3 (car p)) 1/3)
                     (+ (* 1/3 (cadr p)) 2/3)))
         7)
   (list 1/8 (lambda (p)
               (list (+ (* 1/3 (car p)) 2/3)
                     (+ (* 1/3 (cadr p)) 2/3)))
         8)))

;; Fancy 'MATH' fractal.
(define (make-math-rules)
  (list
   (list 1/12 (lambda (p)
                (list (+ (* (/ 1 4.6) (cos (/ pi 2)) (car p))
                         (* (/ -1 4.6) (sin (/ pi 2)) (cadr p))
                         (/ 1 4.6))
                      (+ (* (/ 1 4.6) (sin (/ pi 2)) (car p))
                         (* (/ 1 4.6) (cos (/ pi 2)) (cadr p)))))
         1)
   (list 1/12 (lambda (p)
                (list (+ (* (/ 1 9.2) (cos (/ pi -4)) (car p))
                         (* (/ -1 9.2) (sin (/ pi -4)) (cadr p))
                         0.18)
                      (+ (* (/ 1 9.2) (sin (/ pi -4)) (car p))
                         (* (/ 1 9.2) (cos (/ pi -4)) (cadr p))
                         0.87)))
         2)
   (list 1/12 (lambda (p)
                (list (+ (* (/ 1 9.2) (cos (/ pi 4)) (car p))
                         (* (/ -1 9.2) (sin (/ pi 4)) (cadr p))
                         0.5)
                      (+ (* (/ 1 9.2) (sin (/ pi 4)) (car p))
                         (* (/ 1 9.2) (cos (/ pi 4)) (cadr p))
                         0.53)))
         3)
   (list 1/12 (lambda (p)
                (list (+ (* (/ 1 4.6) (cos (/ pi 2)) (car p))
                         (* (/ -1 4.6) (sin (/ pi 2)) (cadr p))
                         1)
                      (+ (* (/ 1 4.6) (sin (/ pi 2)) (car p))
                         (* (/ 1 4.6) (cos (/ pi 2)) (cadr p)))))
         4)
   (list 1/12 (lambda (p)
                (list (+ (* (/ 1 4.6) (cos (/ pi 3)) (car p))
                         (* (/ -1 4.6) (sin (/ pi 3)) (cadr p))
                         1.3)
                      (+ (* (/ 1 4.6) (sin (/ pi 3)) (car p))
                         (* (/ 1 4.6) (cos (/ pi 3)) (cadr p)))))
         5)
   (list 1/12 (lambda (p)
                (list (+ (* (/ 1 9.2) (cos 0) (car p))
                         (* (/ -1 9.2) (sin 0) (cadr p))
                         1.57)
                      (+ (* (/ 1 9.2) (sin 0) (car p))
                         (* (/ 1 9.2) (cos 0) (cadr p))
                         0.37)))
         6)
   (list 1/12 (lambda (p)
                (list (+ (* (/ 1 4.6) (cos (/ pi -3)) (car p))
                         (* (/ -1 4.6) (sin (/ pi -3)) (cadr p))
                         1.8)
                      (+ (* (/ 1 4.6) (sin (/ pi -3)) (car p))
                         (* (/ 1 4.6) (cos (/ pi -3)) (cadr p))
                         0.83)))
         7)
   (list 1/12 (lambda (p)
                (list (+ (* (/ 1 4.6) (cos 0) (car p))
                         (* (/ -1 4.6) (sin 0) (cadr p))
                         2.43)
                      (+ (* (/ 1 4.6) (sin 0) (car p))
                         (* (/ 1 4.6) (cos 0) (cadr p))
                         0.75)))
         8)
   (list 1/12 (lambda (p)
                (list (+ (* (/ 1 4.6) (cos (/ pi 2)) (car p))
                         (* (/ -1 4.6) (sin (/ pi 2)) (cadr p))
                         3.1)
                      (+ (* (/ 1 4.6) (sin (/ pi 2)) (car p))
                         (* (/ 1 4.6) (cos (/ pi 2)) (cadr p)))))
         9)
   (list 1/12 (lambda (p)
                (list (+ (* (/ 1 4.6) (cos (/ pi 2)) (car p))
                         (* (/ -1 4.6) (sin (/ pi 2)) (cadr p))
                         3.8)
                      (+ (* (/ 1 4.6) (sin (/ pi 2)) (car p))
                         (* (/ 1 4.6) (cos (/ pi 2)) (cadr p)))))
         10)
   (list 1/12 (lambda (p)
                (list (+ (* (/ 1 9.2) (cos 0) (car p))
                         (* (/ -1 9.2) (sin 0) (cadr p))
                         3.77)
                      (+ (* (/ 1 9.2) (sin 0) (car p))
                         (* (/ 1 9.2) (cos 0) (cadr p))
                         0.45)))
         11)
   (list 1/12 (lambda (p)
                (list (+ (* (/ 1 4.6) (cos (/ pi 2)) (car p))
                         (* (/ -1 4.6) (sin (/ pi 2)) (cadr p))
                         4.4)
                      (+ (* (/ 1 4.6) (sin (/ pi 2)) (car p))
                         (* (/ 1 4.6) (cos (/ pi 2)) (cadr p)))))
         12)))