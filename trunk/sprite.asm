; Methods
; disable_all_sprites
; reset_all_sprites
; enable_sprite x = sprite 0-7
; disable_sprite y = sprite 0-7
; move_sprite a = sprite 0-7, x = x pos, y = y pos
; set_sprite_bank a = sprite 0-7, x = sprite bank (0 - 255)
; get_sprite_bank a = sprite bank (0 - 255), $04 -$05 = destination
; copy_sprite_bank a = sprite bank (0-255), $02 - $03 = source
; copy_sprite = $02 - $03 = source, $04 - $05 = destination
; set_sprite_color, x = sprite 0-7, a = color
; set_double_width, x = sprite 0-7
; set_single_width, x = sprite 0-7
; set_double_height, x = sprite 0-7
; set_single_height, x = sprite 0-7
; detect_sprite_collision, a = bitmap mask of sprites to detect
; detect_bitmap_collision, a = bitmap mask of sprites to detect


        ; disables all sprites
disable_all_sprites
        lda #0
        sta $d015
        rts


        ; reset all sprite settings
reset_all_sprites
        lda #0
        ; disable all sprites
        sta $d015
        ; set single width
        sta $d01d
        ; set single height
        sta $d017
        ; reset sprite-sprite detection
        lda $d01e
        ; reset sprite-bitmap detection
        lda $d01f
        rts


        ; enable a sprite
        ; x = sprite, 0 to 7
enable_sprite
        lda bit_set_tbl,x
        ora $d015
        sta $d015
        rts


        ; disable a sprite
        ; x = sprite, 0 to 7
disable_sprite
        lda bit_clr_tbl,x
        and $d015
        sta $d015
        rts


        ; move sprite
        ; a = sprite, 0 to 7
        ; x = x position / 2
        ; y = y position
move_sprite
        stx _move_sprite_x + 1  ; save x
        sty _move_sprite_y + 1  ; save y
        tax                     ; x = a
        asl                     ; a = a << 1
        tay                     ; y = a
_move_sprite_y
        lda #$00
        sta $d001,y             ; set y position
_move_sprite_x
        lda #$00                ; get x position
        asl                     ; a = a * 2
        sta $d000,y             ; store x position
        bcs _move_sprite_hi     ; jump on high bit set
        lda bit_clr_tbl,x       ; clear bit
        and $d010
        sta $d010
        rts
_move_sprite_hi
        lda bit_set_tbl,x       ; set bit
        ora $d010
        sta $d010
        rts


        ; move a sprite relative
        ; use this for half moments, e.g. 1 pixel 
        ; a = sprite, 0 to 7
        ; x = relative x position, -128 to 127
        ; y = relative y position, -128 to 127
move_sprite_rel
        stx _move_sprite_rel_x + 1 ; save x
        sty _move_sprite_rel_y + 1  ; save y
        tax                     ; x = a
        asl                     ; a = a << 1
        tay                     ; y = a
        ; clc done by asl
_move_sprite_rel_y
        lda #$00                ; get y
        adc $d001,y             ; add y position
        sta $d001,y             ; and store it
        clc
_move_sprite_rel_x
        lda #$00
        adc $d000,y             ; add x position
        sta $d000,y             ; and store it
        bvc _move_sprite_rel_1  ; do we need to toggle bit?
        lda bit_set_tbl,x       ; toggle bit
        eor $d010
        sta $d010
_move_sprite_rel_1
        rts


        ; set sprite to bank
        ; a = sprite, 0 to 7
        ; x = sprite index, 0 - 255
        ; uses $04-$05 for sprite address map
set_sprite_bank
        sta $05
        stx $04
        jsr get_screen_bank
        ldy $05
        clc
        adc #>1016 ; adjust pointer to end of char bank
        sta $05
        lda $04
        ldx #<1016 ; and lower address
        stx $04
        sta ($04),y
        rts


        ; get a sprite bank address
        ; initialize with
        ; a = sprite bank (= membank + a * 64)
        ; $04-05 = sprite bank
get_sprite_bank
        sta $05 ; calculate a * 64
        lda #0
        sta $04
        jsr get_vic_bank ; add screen bank
        lsr $05 ; shift hi
        ror $04 ; into lo
        lsr $05 ; shift hi
        ror $04 ; into lo
        adc $05 ; add
        sta $05 ; store ($04-05 = char bank + sprite * 64)
        rts
        

        ; copy a sprite to bank
        ; initialize with
        ; a = sprite bank (= membank + a * 64)
        ; $02-$03 = source
        ;
        ; the following is used for copying
        ; $04-$05 = destination
copy_sprite_bank
        sta $05 ; calculate a * 64
        lda #0
        sta $04
        jsr get_vic_bank ; add screen bank
        lsr $05 ; shift hi
        ror $04 ; into lo
        lsr $05 ; shift hi
        ror $04 ; into lo
        adc $05 ; add
        sta $05 ; store ($04-05 = char bank + sprite * 64)
        ; and continue into the next method...

        
        ; copy a sprite bank of 63 bytes
        ; initialize with
        ; $02-$03 = source
        ; $04-$05 = destination
copy_sprite
        ldy #62
_copy_sprite_1
        lda ($02),y
        sta ($04),y
        dey
        bne _copy_sprite_1
        lda ($02),y
        sta ($04),y
        rts


        ; set sprite color
        ; a = color, 0 to 15
        ; x = sprite, 0 to 7
set_sprite_color
        sta $d027,x
        rts

        ; set all sprites to a color
        ; a = color, 0 to 15
set_all_sprite_colors
        ldx #7
_next_sprite_clr
        sta $d027,x
        dex
        bne _next_sprite_clr
        sta $d027
        rts


        ; set double sprite width
        ; x = sprite, 0 to 7
set_double_width
        lda bit_set_tbl,x
        ora $d01d
        sta $d01d
        rts


        ; set double sprite width
        ; x = sprite, 0 to 7
set_single_width
        lda bit_clr_tbl,x
        and $d01d
        sta $d01d
        rts


        ; set double sprite width
        ; x = sprite, 0 to 7
set_double_height
        lda bit_set_tbl,x
        ora $d017
        sta $d017
        rts


        ; set double sprite width
        ; x = sprite, 0 to 7
set_single_height
        lda bit_clr_tbl,x
        and $d017
        sta $d017
        rts


        ; detect sprite to sprite collision
        ; a = sprite mask, 0 - 7 bits, set all bits to detect
detect_sprite_collision
        and $d01e
        rts


        ; detect sprite to bitmap collision
        ; a = sprite mask, 0 - 7 bits, set all bits to detect
detect_bitmap_collision
        and $d01f
        rts
