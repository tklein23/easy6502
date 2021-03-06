; used memory:
;   $02     stores the direction to go: 1:up, 2:right, 3:down, 4:left
;   $10:$11 stores the position of the robot
;   $12:$13 stores the target position of the robot

jsr drawLabyrinth
jsr gameInit
jsr gameLoop
jmp gameOver

gameLoop:
  jsr copyPosition
  jsr readKeys
  jsr updatePosition

  ;TODO: resetting pressed keys and stored directions
  LDA #$00 ; neutral value
  STA $ff ; pressed keys
  STA $02 ; stored direction

  jsr checkWallCollisions

  jsr drawNewPosition
  jsr restorePosition

  jsr spinWheels
  jmp gameLoop

gameInit:
  LDA #$03
  STA $00

  ; robot start position: use $0200 for (0,0) and $05ff for (31,31)
  ; data is stored as little endian, so don't forget to swap the bytes
  LDA #$00
  STA $10
  LDA #$02
  STA $11

  ;TODO: resetting pressed keys and stored directions
  LDA #$00 ; neutral value
  STA $ff ; pressed keys
  STA $02 ; stored direction

  jsr copyPosition
  jsr drawNewPosition
  RTS

checkWallCollisions:
  LDY #$00
  LDA ($12),Y

  CMP #$01
  BEQ collision

  RTS

drawNewPosition:
  ; mark previous field black:$00 or yellow:$07
  LDA #$07 ; color of previous field
  LDY #$00
  STA ($10),Y

  ; draw new position
  LDA $00
  LDY #$00
  STA ($12),Y

  LDA #$03
  STA $00

  RTS

copyPosition:
  lda $10
  sta $12
  lda $11
  sta $13
  rts

restorePosition:
  lda $12
  sta $10
  lda $13
  sta $11
  rts

updatePosition:

  ;now determine where to move the robot.
  ;lsr: Logical Shift Right. Shift all bits in register A one bit to the right
  ;the bit that "falls off" is stored in the carry flag
  lda $02

  lsr
  bcs up    ;if a 1 "fell off", we started with bin 0001, so the robot needs to go up
  lsr
  bcs right ;if a 1 "fell off", we started with bin 0010, so the robot needs to go right
  lsr
  bcs down  ;if a 1 "fell off", we started with bin 0100, so the robot needs to go down
  lsr
  bcs left  ;if a 1 "fell off", we started with bin 1000, so the robot needs to go left
  rts

up:
  lda $12   ;load the least significant byte into register A
  sec       ;set carry flag
  sbc #$20  ;Subtract with Carry: If overflow occurs the carry bit is clear.
  sta $12
  bcc upup
  rts

upup:
  dec $13   ;decrement the most significant byte
  lda #$1   ;load hex value $1 into register A
  cmp $13   ;if in strip 1, we overflowed.
  beq collision
  rts

right:
  inc $12   ;increment least significant byte
  lda #$1f  ;load value hex $1f into register A
  bit $12   ;AND value with hex $1f (bin 11111)
  beq collision ;branch to collision if zero flag is set
  rts       ;return

down:
  lda $12   ;load the least significant byte in register A
  clc       ;clear carry flag
  adc #$20  ;add hex $20 to register A and set the carry flag on overflow
  sta $12
  bcs downdown ;if the carry flag is set, we ran out of current strip
  rts

downdown:
  inc $13   ;increment most significant byte
  lda #$6   ;load the value hex $6 into the A register
  cmp $13   ;if the most significant byte equals to 6, we're off
  beq collision ;collision with the bottom of the screen
  rts

left:
  dec $12   ;decrement least significant byte
  lda $12
  and #$1f  ;AND the value hex $1f (binary 11111) with the value in register A
  cmp #$1f  ;compare the ANDed value above with binary 11111.
  beq collision ;collision with left border of the screen
  rts

collision:
  LDA #$0e
  STA $00

  jsr copyPosition
  rts

;functions to read pressed keys and write them to $02
readKeys:
  ; address $ff in the zero page contains the key pressed
  lda $ff

  cmp #$77
  beq upKey
  cmp #$64
  beq rightKey
  cmp #$73
  beq downKey
  cmp #$61
  beq leftKey

  rts

upKey:
  lda #1
  sta $02
  rts

rightKey:
  lda #2
  sta $02
  rts

downKey:
  lda #4
  sta $02
  rts

leftKey:
  lda #8
  sta $02
  rts

illegalMove:
  rts

;slow the game down by wasting cycles
spinWheels:
  ldx #0
spinloop:
  nop
  nop
  dex
  bne spinloop
  rts

gameOver:
  brk

drawLabyrinth:
