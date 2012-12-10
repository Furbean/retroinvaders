; retroinvaders

; This file contains all macro definitions
; Start address needs to be at 0 to be loaded first

        *=$08ff

; writev(x,y,value) write a value at x,y
defm writev
        lda #\3
        ldx #\1
        ldy #\2
        jsr write_acc_value
endm

; writea(x,y) write accumulator at x,y
defm writea
        ldx #\1
        ldy #\2
        jsr write_acc_value
endm

; writem(x,y,mem) write memory value at x,y
defm writem
        lda \3
        ldx #\1
        ldy #\2
        jsr write_acc_value
        lda \3 + 1
        ldx #\1 + 2
        ldy #\2
        jsr write_acc_value
endm
