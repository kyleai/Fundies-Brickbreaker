;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname |Assignment 6 Part 2|) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
#|--- CONSTANTS ---|#
(define WIDTH 200)
(define HEIGHT 200)
(define BG (empty-scene WIDTH HEIGHT))

(define BALL-COLOR "blue")
(define BALL-RADIUS 6)
(define BALL-SPEED 4)
(define THE-BALL (circle BALL-RADIUS "solid" BALL-COLOR))

(define BRICK-COLOR 'red)
(define BRICK-WIDTH 30)
(define BRICK-HEIGHT 10)
(define BRICK-PADDING 10)
(define ROWS 3)
(define COLUMNS 5)
(define THE-BRICK (rectangle BRICK-WIDTH BRICK-HEIGHT "solid" BRICK-COLOR))

(define PADDLE-COLOR "purple")
(define PADDLE-WIDTH 40)
(define PADDLE-HEIGHT BRICK-HEIGHT)
(define PADDLE-Y (- HEIGHT (/ PADDLE-HEIGHT 2)))
(define PADDLE-SPEED 5)
(define THE-PADDLE (rectangle PADDLE-WIDTH PADDLE-HEIGHT "solid" PADDLE-COLOR))



#|--- DATA DEFINITIONS ---|#
;;A Ball is a (make-ball Number Number Number Number)
(define-struct ball (x y vx vy))

; - where the first Number is the ball's x-coordinate
; - the second Number is the ball's y-coordinate
; - the third Number is the ball's x-velocity
; - the fourth Number is the ball's y-velocity
(define INITIAL-BALL (make-ball (/ WIDTH 2)
                                (- HEIGHT (* 2 PADDLE-HEIGHT) (/ BALL-RADIUS 2))
                                BALL-SPEED 0))

;; A Paddle is a (make-paddle Number)

(define-struct paddle (x))
(define PADDLE1 (make-paddle 100))

;; A Brick is a (make-brick Number Number Number)

(define-struct brick (num x y))

; - where the first Number is the brick's health
; - the second number is the brick's x coordinate
; - the third number is the brick's y coordinate


;; A List-of-Bricks is one of:
; - '()
; - (cons Brick List-of-Bricks)

(define INITIAL-BRICKS (list (make-brick 2 20 10)
                             (make-brick 2 60 10)
                             (make-brick 2 100 10)
                             (make-brick 2 140 10)
                             (make-brick 2 180 10)
                             (make-brick 2 20 30)
                             (make-brick 2 60 30)
                             (make-brick 2 100 30)
                             (make-brick 2 140 30)
                             (make-brick 2 180 30)
                             (make-brick 2 20 50)
                             (make-brick 2 60 50)
                             (make-brick 2 100 50)
                             (make-brick 2 140 50)
                             (make-brick 2 180 50)))

;; A World is a (make-world Ball Paddle List-of-Bricks Boolean)
;; Interp: __DO THIS LATER PLEASE_________________________________________________________________________
(define-struct world (ball paddle lob launched))

(define WORLD0 (make-world INITIAL-BALL PADDLE1 INITIAL-BRICKS #false))
(define WORLD1 (make-world INITIAL-BALL PADDLE1 INITIAL-BRICKS #true))

(define (main _)
  (big-bang WORLD0
    [to-draw draw-world]
    [on-key move-paddle]
    [on-tick tick-world]
    ;[stop-when dead? show-end]
    ))
#|--- FUNCTIONS ---|#

;; speed: Ball -> Number
;; compute the speed of the ball
(check-expect (speed INITIAL-BALL) 4)
;; speed: Ball -> Number
;; compute the speed of the ball
(check-expect (speed INITIAL-BALL) 4)
(define (speed ball)
  (sqrt (+ (sqr (ball-vx ball))
           (sqr (ball-vy ball)))))

;;new-x-velocity : Ball Number -> Number
;;Produces the new x velocity of a ball that launched off a paddle with this x-coordinate
(define (new-x-velocity ball x)
  (inexact->exact
   (* .95
      (/ (- (ball-x ball) x) (+ (/ PADDLE-WIDTH 2) BALL-RADIUS))
      (speed ball))))
(check-expect (new-x-velocity INITIAL-BALL 100) 0)
(check-expect (new-x-velocity (make-ball 60 190 3 4) 100)
              (inexact->exact (* 4.75 -40/26)))

;;new-y-velocity : Ball Number -> Number
;;Produces the new y velocity of a ball that launched off a paddle with this x-coordinate
(define (new-y-velocity ball x)
  (inexact->exact
   (* (- (sqrt (- 1 (sqr (* .95
                            (/ (- (ball-x ball) x) (+ (/ PADDLE-WIDTH 2) BALL-RADIUS)))))))
      (speed ball))))
(check-expect (new-y-velocity INITIAL-BALL 100) -4)
(check-expect (new-y-velocity (make-ball 60 190 3 4) 100)
              (inexact->exact (* -5 (sqrt (- 1 (sqr (* .95 -40/26)))))))

;;launch-ball : Ball Number -> Ball
;;Launch ball off paddle with this x-coordinate
(define (launch-ball ball x)
  (make-ball (+ (ball-x ball) (new-x-velocity ball x))
               (+ (ball-y ball) (new-y-velocity ball x))
               (new-x-velocity ball x) (new-y-velocity ball x)))
(check-expect (launch-ball INITIAL-BALL 100)
              (make-ball 100 173 0 -4))
(check-expect (launch-ball (make-ball 60 190 3 4) 100)
              (make-ball (+ 60 (inexact->exact (* 4.75 -40/26)))
                         (+ 190 (inexact->exact (* -5 (sqrt (- 1 (sqr (* .95 -40/26)))))))
                         (inexact->exact (* 4.75 -40/26))
                         (inexact->exact (* -5 (sqrt (- 1 (sqr (* .95 -40/26))))))))

;; Draw-world : World -> Image
;; Renders the world onto an image
(check-expect (draw-world WORLD0)
                (draw-ball INITIAL-BALL (draw-bricks INITIAL-BRICKS (draw-paddle PADDLE1))))

(define (draw-world w)
  (draw-ball (world-ball w) (draw-bricks INITIAL-BRICKS (draw-paddle (world-paddle w)))))

;; Draw-ball : Ball, Image -> Image
;; draws ball over current image
(check-expect (draw-ball INITIAL-BALL BG) (place-image THE-BALL (ball-x INITIAL-BALL) (ball-y INITIAL-BALL) BG))

(define (draw-ball ball img)
  (place-image THE-BALL (ball-x ball) (ball-y ball) img))

;; Draw-bricks : LoB, Image -> Image
;; draws bricks over current image
(check-expect (draw-bricks '() BG) BG)
(check-expect (draw-bricks (list (make-brick 2 0 0)) BG) (place-image THE-BRICK 0 0 BG))

(define (draw-bricks bricks img)
  (cond
    [(empty? bricks) (place-image empty-image 0 0 img)]
    [(cons? bricks) (place-image THE-BRICK
                                 (brick-x (first bricks))
                                 (brick-y (first bricks))
                                 (draw-bricks (rest bricks) img))]))
;; draw-paddle : Paddle -> Image
;; draws the paddle on an image
(check-expect (draw-paddle PADDLE1) (place-image THE-PADDLE (paddle-x PADDLE1) 190 BG))

(define (draw-paddle paddle)
  (place-image THE-PADDLE (paddle-x paddle) 190 BG))

;; move-paddle : World, KeyEvent -> World
;; Moves the paddle on user keypress
(check-expect (move-paddle WORLD0 "right") (move-right WORLD0))
(check-expect (move-paddle WORLD0 "left") (move-left WORLD0))
(check-expect (move-paddle WORLD0 "up") WORLD0)

(define (move-paddle w key)
  (cond
    [(key=? key "left") (move-left w)]
    [(key=? key "right") (move-right w)]
    [else w]))

;; move-right : World -> World
;; Moves paddle to the right
(check-expect (move-right WORLD0)
              (make-world (world-ball WORLD0)
                          (make-paddle (+ (paddle-x (world-paddle WORLD0)) PADDLE-SPEED))
                          (world-lob WORLD0)
                          (world-launched WORLD0)))

(define (move-right w)
  (if (< (paddle-x (world-paddle w)) (- WIDTH (/ PADDLE-WIDTH 2)))
      (make-world (world-ball w)
                  (make-paddle (+ (paddle-x (world-paddle w)) PADDLE-SPEED))
                  (world-lob w)
                  (world-launched w))
      w))

;; move-left : World -> World
;; Moves paddle to the right
(check-expect (move-left WORLD0)
              (make-world (world-ball WORLD0)
                          (make-paddle (- (paddle-x (world-paddle WORLD0)) PADDLE-SPEED))
                          (world-lob WORLD0)
                          (world-launched WORLD0)))

(define (move-left w)
  (if (< (/ PADDLE-WIDTH 2) (paddle-x (world-paddle w)))
      (make-world (world-ball w)
                  (make-paddle (- (paddle-x (world-paddle w)) PADDLE-SPEED))
                  (world-lob w)
                  (world-launched w))
      w))

;; tick-world : World -> World
;; Checks if the ball has been launched yet
(check-expect (tick-world WORLD0) (make-world (launch-ball INITIAL-BALL (/ WIDTH 2)) PADDLE1 INITIAL-BRICKS #true))
(check-expect (tick-world WORLD1) (move-ball-helper WORLD1))

(define (tick-world w)
  (cond
    [(world-launched w) (move-ball-helper w)]
    [(not (world-launched w))
     (make-world (launch-ball INITIAL-BALL (/ WIDTH 2)) (world-paddle w) (world-lob w) #true)]))

;; move-ball
(define (move-ball-helper w)
  (cond
    [(collision? w)
      (cond
        []
        []
        []
        [](change-direction w)]
    [else (move-ball w)]))

;;
;;
(define (collision? w)
  (or (touching-brick (world-lob w) (world-ball w)) (touching-wall w) (touching-paddle w)))

;; move
;;
(define (move-ball w)
  (make-world (make-ball (+ (ball-x (world-ball w)) (ball-vx (world-ball w)))
                         (+ (ball-y (world-ball w)) (ball-vy (world-ball w)))
                         (ball-vx (world-ball w))
                         (ball-vy (world-ball w)))
              (world-paddle w)
              (world-lob w)
              (world-launched w)))


;; ----------------- TOUCHING WALL??? ------------------------------------

(define (touching-wall w)
  (or (touching-wall-r? w) (touching-wall-l? w) (touching-wall-t? w)))

(define (touching-wall-r? w)
  (>= (+ (ball-x (world-ball w)) BALL-RADIUS) WIDTH))

(define (touching-wall-l? w)
  (<= (- (ball-x (world-ball w) BALL-RADIUS) WIDTH)))

(define (touching-wall-t? w)
  (<= (+ (ball-y (world-ball w) BALL-RADIUS) HEIGHT)))

(define (touching-wall-b? w)
  (<= (- (ball-y (world-ball w) BALL-RADIUS) HEIGHT)))

;; ------------------ TOUCHING BRICK???????? -------------------------------

(define (touching-brick lob ball)
  (cond
    [(empty? lob) #false]
    [else (or (touching-single-brick (first lob) ball) (touching-brick (rest lob) ball))]))

(define (touching-single-brick brick ball)
  (or (touching-brick-r? brick ball) (touching-brick-l? brick ball) (touching-brick-t? brick ball) (touching-brick-b? brick ball)))

(define (touching-brick-r? brick ball)
  )
(define (touching-brick-l? brick ball)
  )
(define (touching-brick-t? brick ball)
  )
(define (touching-brick-b? brick ball)
  )

(define (touching-paddle w)
  )


(main 0)