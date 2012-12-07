
; constants used for sprites
shield_start_y = 200
shield_start_1_x = 30
shield_start_2_x = 80
shield_start_3_x = 130

shot_middle_x = 5
shot_start_y = 8
shot_height = 10

ship_start_x = 90
ship_start_y = 230



interrupt
        sty _restore_y + 1
        stx _restore_x + 1
        pha
        inc $d020


        lda #$3e        ; bitmap mask of sprite 1, 2, 3, 4, and 5
        jsr detect_sprite_collision
        lsr
        lsr ; is our shot involved?
        bcc _skip_hit_test
        ; the shield has been hit, carve some
        ; we can only hit one item at a time...
        lsr ; first shield?
        bcc _shield_test_2

        ; carve some from first shield
        ; carry set!!!
        lda shot_ypos
        sbc #shield_start_y - shot_start_y
        tay

        clc
        lda shot_xpos
        sbc #shield_start_1_x - shot_middle_x
        tax

        lda #$fd

        jsr carve_sprite
        
        jmp _end_shot_test
_shield_test_2
        lsr ; second shield?
        bcc _shield_test_3

        ; carve some from second shield
        ;carry set!!!
        lda shot_ypos
        sbc #shield_start_y - shot_start_y
        tay

        clc
        lda shot_xpos
        sbc #shield_start_2_x - shot_middle_x
        tax

        lda #$fc

        jsr carve_sprite

        jmp _end_shot_test

_shield_test_3
        ror ; third shield?
        bcc _enemy_test

        ; carve some from third shield
        ;carry set!!!
        lda shot_ypos
        sbc #shield_start_y - shot_start_y
        tay

        clc
        lda shot_xpos
        sbc #shield_start_3_x - shot_middle_x
        tax

        lda #$fb

        jsr carve_sprite

        jmp _end_shot_test

_enemy_test
        ror ; enemy ufo?
        bcc _skip_hit_test

        ; TODO: kill ufo

_end_shot_test
        jsr end_shot

_skip_hit_test
        jsr read_joy
        jsr move_ship
        jsr move_shot

        dec $d020
        asl $d019
_restore_y
        ldy #$00
_restore_x
        ldx #$00
        pla
        rti


        ; initialize the sprites
init_sprites
        ; first, disable and reset all the sprites
        jsr reset_all_sprites
        ; set the correct colors on all sprites
        lda #15
        jsr set_all_sprite_colors

        ; copy the ship sprite
        lda #<ship_spr
        sta $02
        lda #>ship_spr
        sta $03
        lda #$ff
        jsr copy_sprite_bank

        ; set the ship as sprite 0
        lda #0
        ldx #$ff
        jsr set_sprite_bank
        ; and show the ship sprite
        ldx #0
        jsr enable_sprite
        lda #ship_start_x
        sta ship_xpos
        jsr move_ship

        ; copy the shot sprite
        lda #<shot_spr
        sta $02
        lda #>shot_spr
        sta $03
        lda #$fe
        jsr copy_sprite_bank
        ; set the shot sprite as sprite 1
        lda #1
        ldx #$fe
        jsr set_sprite_bank

        ; initialize all three shields
        lda #<shield_spr
        sta $02
        lda #>shield_spr
        sta $03

        ; make three individual copies as we are going to modify them
        lda #$fd
        jsr copy_sprite_bank
        lda #$fc
        jsr copy_sprite_bank
        lda #$fb
        jsr copy_sprite_bank

        ; set the first shield as sprite 2
        lda #2
        ldx #$fd
        jsr set_sprite_bank
        ; move it to the correct position
        lda #2
        ldx #shield_start_1_x
        ldy #shield_start_y
        jsr move_sprite
        lda #2
        ldx #1
        ldy #0
        jsr move_sprite_rel
        ; and show the shield sprite
        ldx #2
        jsr enable_sprite
        ldx #2
        jsr set_double_width
        
        ; set the second shield as sprite 3
        lda #3
        ldx #$fc
        jsr set_sprite_bank
        ; move it to the correct position
        lda #3
        ldx #shield_start_2_x
        ldy #shield_start_y
        jsr move_sprite
        lda #3
        ldx #1
        ldy #0
        jsr move_sprite_rel
        ; and show the shield sprite
        ldx #3
        jsr enable_sprite
        ldx #3
        jsr set_double_width
        
        ; set the second shield as sprite 4
        lda #4
        ldx #$fb
        jsr set_sprite_bank
        ; move it to the correct position
        lda #4
        ldx #shield_start_3_x
        ldy #shield_start_y
        jsr move_sprite
        lda #4
        ldx #1
        ldy #0
        jsr move_sprite_rel
        ; and show the shield sprite
        ldx #4
        jsr enable_sprite
        ; make double width
        ldx #4
        jsr set_double_width

        ; todo: other sprites as well...

        rts

read_joy
        lda $dc00
        bit bit_set_tbl + 2
        bne _not_left
        dec ship_xpos
_not_left
        bit bit_set_tbl + 3
        bne _not_right
        inc ship_xpos
_not_right
        bit bit_set_tbl + 4
        bne _not_shot
        jsr send_shot
_not_shot
        rts

        ; set the ship position
move_ship
        lda #0
        ldx ship_xpos
        ldy #ship_start_y
        jsr move_sprite
        rts

        ; move any shots...
move_shot
        ldy shot_ypos
        beq _no_shot
        dey
        sty shot_ypos
        beq _end_shot
        ldx shot_xpos
        lda #1
        jsr move_sprite
        rts
end_shot
        lda #0
        sta shot_ypos
_end_shot
        ldx #1
        jsr disable_sprite
_no_shot
        rts

send_shot
        lda shot_ypos
        bne _already_shot
        ldx ship_xpos
        stx shot_xpos
        ldy #ship_start_y - shot_height
        sty shot_ypos
        lda #1
        jsr move_sprite
        ldx #1
        jsr enable_sprite
_already_shot
        rts


        ; carve from sprite
        ; a = sprite index, 0 - 255
        ; x = x pos
        ; y = y pos
carve_sprite
        jsr write_all

        pha                     ; store acc
        lda mul3_tbl,x
        sta _carve_sprite_x + 1 ; store x * 3
        cpy #21                 ; check if we are below line 0 or above 21 
        bcs _carve_sprite_2
        lda mul3_tbl,y
        byte $2c                ; skip next instruction
_carve_sprite_2
        lda #$00                ; load zero point
_carve_sprite_3
        sta _carve_sprite_y + 1 ; store y * 3
_carve_sprite_a
        pla                     ; reload acc
        jsr get_sprite_bank     ; get sprite bank
_carve_sprite_y
        ldy #$00                ; reload y
_carve_sprite_x
        ldx #$00                ; reload x
_carve_sprite_1
        lda ($04),y
        and shot_tbl,x
        sta ($04),y
        iny
        lda ($04),y
        and shot_tbl + 1,x
        sta ($04),y
        iny
        lda ($04),y
        and shot_tbl + 2,x
        sta ($04),y
        iny
        cpy #63
        bmi _carve_sprite_1
        rts


write_all
        sta _dbg_a + 1
        stx _dbg_x + 1
        sty _dbg_y + 1
        ldy #$00
        ldx #$00
        jsr write_acc_value
        lda _dbg_x + 1
        ldy #$01
        ldx #$00
        jsr write_acc_value
        lda _dbg_y + 1
        ldy #$02
        ldx #$00
        jsr write_acc_value
_dbg_a
        lda #$00
_dbg_x
        ldx #$00
_dbg_y        
        ldy #$00
        rts





ship_xpos
        byte 0
shot_xpos
        byte 0
shot_ypos
        byte 0


mul3_tbl
        byte  0,  3,  6,  9, 12, 15, 18, 21
        byte 24, 27, 30, 33, 36, 39, 42, 45
        byte 48, 51, 54, 57, 60, 63, 66, 69
        byte 72, 75, 78, 81, 84, 87, 90, 93

shot_tbl
        bits .@@@@@@@@@@@@@@@@@@@@@@@ ; 0
        bits ..@@@@@@@@@@@@@@@@@@@@@@ ; 0
        bits ...@@@@@@@@@@@@@@@@@@@@@ ; 1
        bits @...@@@@@@@@@@@@@@@@@@@@ ; 2
        bits @@...@@@@@@@@@@@@@@@@@@@ ; 3
        bits @@@...@@@@@@@@@@@@@@@@@@ ; 4
        bits @@@@...@@@@@@@@@@@@@@@@@ ; 5
        bits @@@@@...@@@@@@@@@@@@@@@@ ; 6
        bits @@@@@@...@@@@@@@@@@@@@@@ ; 7
        bits @@@@@@@...@@@@@@@@@@@@@@ ; 8
        bits @@@@@@@@...@@@@@@@@@@@@@ ; 9
        bits @@@@@@@@@...@@@@@@@@@@@@ ; 0
        bits @@@@@@@@@@...@@@@@@@@@@@ ; 1
        bits @@@@@@@@@@@...@@@@@@@@@@ ; 2
        bits @@@@@@@@@@@@...@@@@@@@@@ ; 3
        bits @@@@@@@@@@@@@...@@@@@@@@ ; 4
        bits @@@@@@@@@@@@@@...@@@@@@@ ; 5
        bits @@@@@@@@@@@@@@@...@@@@@@ ; 6
        bits @@@@@@@@@@@@@@@@...@@@@@ ; 7
        bits @@@@@@@@@@@@@@@@@...@@@@ ; 8
        bits @@@@@@@@@@@@@@@@@@...@@@ ; 9
        bits @@@@@@@@@@@@@@@@@@@...@@ ; 0
        bits @@@@@@@@@@@@@@@@@@@@...@ ; 1
        bits @@@@@@@@@@@@@@@@@@@@@... ; 2
        bits @@@@@@@@@@@@@@@@@@@@@@.. ; 3
        bits $@@@@@@@@@@@@@@@@@@@@@@. ; 3
