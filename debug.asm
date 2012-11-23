

defm writev
        lda #\3
        ldx #\1
        ldy #\2
        jsr write_acc_value
        endm

defm writea
        ldx #\1
        ldy #\2
        jsr write_acc_value
        endm

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


        ; write acc as hex to screen
        ; a = value
        ; x = x position, 0 to 39
        ; y = y position, 0 to 24
write_acc_value
        sta _write_hex_1 + 1    ; store acc value for later use
        lda screen_lo_tbl,y     ; get low part of screen addr
        sta _write_hex_lo + 1   ; store it at low screen addr
        sta _write_hex_hi + 1   ; store it at high screen addr
        lda screen_hi_tbl,y     ; get high part of screen addr
        sta _write_hex_3 + 1    ; store for later use
        stx _write_hex_4 + 1    ; store x for later use
        jsr get_screen_bank     ; get screen position in memory
        clc                     ; clear carry
_write_hex_3
        adc #$00                ; add with high part of screen addr
        sta _write_hex_lo + 2   ; store it at low screen addr
        sta _write_hex_hi + 2   ; store it at high screen addr
_write_hex_4
        ldy #$00                ; get x position on screen
_write_hex_1
        lda #$00                ; get high part of hex value to translate
        lsr
        lsr
        lsr
        lsr
        tax
        lda hex_tbl,x          ; convert to hex
_write_hex_hi
        sta $0100,y             ; store it on the screen
        iny                     ; increase x position
        lda _write_hex_1 + 1    ; get low part of hex value to translate
        and #$0f
        tax
        lda hex_tbl,x           ; convert to hex
_write_hex_lo
        sta $0101,y             ; store it on the screen
        rts

     ; table for hex converter
hex_tbl
        byte 48, 49, 50, 51
        byte 52, 53, 54, 55
        byte 56, 57, 01, 02
        byte 03, 04, 05, 06

        ; low part table of screen translation
        ; lo_addr = <(row * 40)
screen_lo_tbl
        byte 0, 40, 80, 120, 160, 200, 240      ; 7
        byte 24, 64, 104, 144, 184, 224         ; 6
        byte 8, 48, 88, 128, 168, 208, 248      ; 7
        byte 32,72, 112, 162, 202               ; 5

        ; high part table of screen translation
        ; hi_addr = >(row * 40)
screen_hi_tbl
        byte 0, 0, 0, 0, 0, 0, 0
        byte 1, 1, 1, 1, 1, 1
        byte 2, 2, 2, 2, 2, 2, 2
        byte 3, 3, 3, 3, 3
