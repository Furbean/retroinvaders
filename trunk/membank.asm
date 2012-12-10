; retroinvaders

; Available functions
; get_vic_bank = returns the VICII bank, high byte in a
; set_vic_bank, a = 0 - 3 - set the vic bank
; get_screen_bank = returns the screen bank, high byte in a
; set_screen_bank, a = 0 - 15 - set the video bank
; get_char_bank = returns the character bank, high byte in a
; set_char_bank, a = 0 - 7 - set the char bank
; get_bitmap_bank = returns the bitmap bank, high byte in a 
; set_bitmap_bank, a = 0 - 1 - set the bitmap bank $0000 or $2000


        ; returns the vic bank, only the high byte ($4000 bytes)
get_vic_bank
        lda $dd00
        and #$03
        tax
        lda bank_addr_tbl,x
        rts


        ; sets the vic bank, see bank_addr_tbl
        ; a = 0 - 3
set_vic_bank
        and #$03
        sta $dd00
        rts


        ; returns the screen bank, only the high byte ($400 bytes)
get_screen_bank
        lda $dd00
        and #$03
        tax
        lda $d018
        and #$78
        lsr
        lsr
        adc bank_addr_tbl,x
        rts


        ; sets the screen bank, vic_bank + video_bank * $400
        ; a = 0 - 15
set_screen_bank
        rol
        rol
        rol
        sta _set_screen_bank_1 + 1
        lda $d018
        and #$87
_set_screen_bank_1
        ora #$00
        sta $d018
        rts


        ; return the character bank, only the high byte ($800 bytes)
get_char_bank
        lda $dd00
        and #$03
        tax
        lda $d018
        and #$0e
        rol
        rol
        adc bank_addr_tbl,x
        rts


        ; sets the char bank, vic_bank + char_bank * $800
        ; a = 0 - 7
set_char_bank
        rol
        and #$0e
        sta _set_char_bank_1 + 1
        lda $d018
        and #$f8
_set_char_bank_1
        ora #$00
        sta $d018
        rts


        ; returns the bitmap bank, only the high byte ($0000 or $2000)
get_bitmap_bank
        lda $dd00
        and #$03
        tax
        lda $d018
        and #$07
        rol
        rol
        adc bank_addr_tbl,x
        rts


        ; sets the bitmap address, vic_bank + bitmap_bank * $2000
        ; a = 0 or 1
set_bitmap_bank
        and #$01
        bne _set_bitmap_bank_1
        lda #$f7
        and $d018
        sta $d018
        rts
_set_bitmap_bank_1
        lda #$08
        ora $d018
        sta $d018
        rts
