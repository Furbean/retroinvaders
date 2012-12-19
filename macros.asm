; retroinvaders

; This file contains all macro definitions
; Start address needs to be at 0 to be loaded first

        *=$08ff

; write_val(x,y,value)
; write a value at x,y
defm write_val
        lda #\3
        ldx #\1
        ldy #\2
        jsr write_acc_value
        endm

; write_acc(x,y)
; write accumulator at x,y
defm write_acc
        ldx #\1
        ldy #\2
        jsr write_acc_value
endm

; write_byte(x,y,mem)
; write memory byte value at x,y
defm write_byte
        lda \3
        ldx #\1
        ldy #\2
        jsr write_acc_value
        lda \3 + 1
        ldx #\1 + 2
        ldy #\2
        jsr write_acc_value
endm

; write_word(x,y,mem)
; write memory word value at x,y
defm write_word
        lda \3 + 1
        ldx #\1
        ldy #\2
        jsr write_acc_value
        lda \3
        ldx #\1 + 2
        ldy #\2
        jsr write_acc_value
endm

; init_irq(jump_tbl,scan_tbl,start)
; initialize irq table for scan line interrupts
; last entry in the jump table must be zero!
defm    init_irq
        ; store jump table
        lda #</1
        sta irq_jump_tbl
        lda #>/1
        sta irq_jump_tbl + 1

        ; store scan table
        lda #</2
        sta irq_scan_tbl
        lda #>/2
        sta irq_scan_tbl + 1

        ; set scan interrupt
        ldy #/3
        sty irq_index
        lda (irq_scan_tbl),y
        sta $d012

        ; set irq scan line interrupt address
        ldy #/3+/3
        lda (irq_jump_tbl),y
        sta scan_line_irq$ + 1
        iny
        lda (irq_jump_tbl),y
        sta scan_line_irq$ + 2
endm
