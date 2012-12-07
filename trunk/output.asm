        ; screen output
        ; available functions:
        ; get_screen_addr
        ; write_string
        ; write_acc_value

        ; calculate screen position
        ; stored at $04-$05
get_screen_addr
        stx _get_screen_addr_1 + 1      ; store x position for later use
        lda screen_lo_tbl,y             ; get low part of screen addr
        clc
_get_screen_addr_1
        adc #0                          ; add x position
        sta $04                         ; store it at low screen addr
        lda #0
        adc screen_hi_tbl,y             ; get high part of screen addr with carry
        sta _get_screen_addr_2 + 1      ; store for later use
        jsr get_screen_bank             ; get screen position in memory
        clc
_get_screen_addr_2
        adc #$0                         ; add with high part of screen addr
        sta $05
        rts

        ; write string to screen
        ; start with length, e.g. '\3' 'A' 'B' 'C'
        ; 
        ; x = x position, 0 to 39
        ; y = y position, 0 to 24
        ; $02-$03 = string address
write_string
        stx _write_str_4 + 1    ; store x position
        lda screen_lo_tbl,y     ; get low part of screen addr
        clc
_write_str_4
        adc #0                  ; add with x position
        sta _write_str_1 + 1    ; store it at screen addr
        lda #0                  ; calculate y hi addr
        adc screen_hi_tbl,y     ; add with high part and carry to screen addr
        sta _write_hex_2 + 1    ; store for later use
        jsr get_screen_bank     ; get screen position in memory
        clc                     ; clear carry
_write_hex_2
        adc #$00                ; add with high part of screen addr
        sta _write_str_1 + 2    ; store it at low screen addr
        ldy #0
        lda ($02),y
        tay
        jmp _write_str_3
_write_str_5
        lda ($02),y
        dey
_write_str_1
        sta $0100,y
_write_str_3
        bne _write_str_5
        rts


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
