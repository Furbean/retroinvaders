; 10 SYS (16384)

;*=$801

 ;       BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $31, $36, $33, $38, $34, $29, $00, $00, $00


*=$4000         ; Level Presentation - Start
                jsr init_screenAndCharset
                jsr init_enemyData

                ; Init with some test data and print enemy playfield
                jsr test_initEnemyDataField ; TEST CODE - REMOVE LATER 
                jsr print_enemyDataField

                rts

; ------------------------------------------------------------------------------
; @FUNCTION:    print_enemyDataField
; @DESCRIPTION: This routine prints the data in <g_enemyDataField>- lists onto
;               the screen. 
; @ARG:         R: <g_enemyBitMask>
; ------------------------------------------------------------------------------
print_enemyDataField
                ldx #$00
                ldy #$01

                ; Pointer to screen low address list
                lda g_enemyDataField_screen_lo
                sta l_pedf_01+1
                lda g_enemyDataField_screen_lo+1
                sta l_pedf_01+2
                ; Pointer to screen high address list
                lda g_enemyDataField_screen_hi
                sta l_pedf_02+1
                lda g_enemyDataField_screen_hi+1
                sta l_pedf_02+2
                ; Pointer to left char list
                lda g_enemyDataField_left_char
                sta l_pedf_03+1
                lda g_enemyDataField_left_char+1
                sta l_pedf_03+2
                ; Pointer to right char list
                lda g_enemyDataField_right_char
                sta l_pedf_05+1
                lda g_enemyDataField_right_char+1
                sta l_pedf_05+2
                ; Pointer to health list
                lda g_enemyDataField_health
                sta l_pedf_10+1
                lda g_enemyDataField_health+1
                sta l_pedf_10+2
                ; Pointer to visibility list
                lda g_enemyDataField_visibility
                sta l_pedf_11+1
                lda g_enemyDataField_visibility+1
                sta l_pedf_11+2

                ; We must check both health and visibility
l_pedf_10       lda $eeee,x     ; Check health....
                beq l_pedf_07
l_pedf_11       lda $eeee,x     ; ... and visibility
                beq l_pedf_07

                ; Set up screen store address for each round
l_pedf_01       lda $eeee,x
                sta l_pedf_04+1 ; low address, left char
                sta l_pedf_06+1 ; low address, right char

l_pedf_02       lda $eeee,x
                sta l_pedf_04+2 ; high address, left char
                sta l_pedf_06+2 ; high address, right char

l_pedf_03       lda $eeee,x     ; load left character value
l_pedf_04       sta $eeee       ; store on screen, left char
l_pedf_05       lda $eeee,x     ; load right character value
l_pedf_06       sta $eeee,y     ; store on screen + 1, right char

l_pedf_07       inx
                cpx #$40
                bne l_pedf_10

                rts

; ------------------------------------------------------------------------------
; TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TES
; ------------------------------------------------------------------------------
;g_enemyDataField_health
;        BYTE    $00, $50
;g_enemyDataField_visibility
;        BYTE    $40, $50
;g_enemyDataField_screen_lo
;        BYTE    $80, $50
;g_enemyDataField_screen_hi
;        BYTE    $c0, $50
;g_enemyDataField_left_char
;        BYTE    $00, $51
;g_enemyDataField_right_char
;        BYTE    $40, $51

test_initEnemyDataField
                ; calculate screen address of upper left corner
                lda g_screenMemory_lo
                sta l_start_address
                lda g_screenMemory_hi
                sta l_start_address+1
                clc
                lda l_start_address
                adc l_start_value
                sta l_start_address
                bcc test_00
                inc l_start_address+1
test_00         ; ($02) pointer to screen low address list 
                lda g_enemyDataField_screen_lo
                sta $02
                lda g_enemyDataField_screen_lo+1
                sta $03
                ; ($04) pointer to screen high address list
                lda g_enemyDataField_screen_hi
                sta $04
                lda g_enemyDataField_screen_hi+1
                sta $05
                ldx #$08
                ldy #$00
test_03         lda l_start_address
                sta ($02),y
                lda l_start_address+1
                sta ($04),y
                dex
                bne test_01
                ldx #$08
                lda l_start_address
                clc
                adc #50
                sta l_start_address
                bcc test_02
                inc l_start_address+1
test_01         lda l_start_address
                clc
                adc #04
                sta l_start_address
                bcc test_02
                inc l_start_address+1
test_02         iny
                cpy #64
                bne test_03

                ; Set visibility to 1 for all enemies
                ldy #$00
                lda g_enemyDataField_visibility
                sta $02
                lda g_enemyDataField_visibility+1
                sta $03
                lda #$01
test_04         sta ($02),y
                iny
                cpy #$40
                bne test_04

                rts
l_start_value
                BYTE $a5
l_start_address
                BYTE $00, $00


; ------------------------------------------------------------------------------
; @DATA:        g_enemyBitMaskIndex
; @DESCRIPTION: Determines which playfield is copied to <g_enemyBitMask> by
;               <g_enemyBitMaskData>+<g_enemyBitMaskIndex>*8
; ------------------------------------------------------------------------------
g_enemyBitMaskIndex
        BYTE $00

; ------------------------------------------------------------------------------
; @DATA:        g_enemyBitMask
; @DESCRIPTION: Enemy bitmask. 8 bytes representing the enemy playfield; first
;               bit in first byte represents upper left corner, second bit is
;               first column second row from top etc.
;               Initially, this data is filled with values from 
;               <g_enemyBitMaskData>
;               This bitmask yeilds the data struct that is used by the enemy 
;               move- and print routine during game.
; ------------------------------------------------------------------------------
g_enemyBitMask
        BYTE    $00, $00, $00, $00, $00, $00, $00, $00

; ------------------------------------------------------------------------------
; @DATA:        g_enemyBitMaskData
; @DESCRIPTION: An array of playfield data to be copied into <g_enemyBitMask>. 
;               Each playfield is 8 bytes. 
;                   'Playfield'                            g_enemyBitMask
;                   |                                      |
;                   +---------------+                      +------------+
;                   |1 2 3 4 5 6 7 8|                      | Col, Value |
;                 1 | | |*|*|*|*| | |                      |   1,   16  |
;                 2 | | |*|*|*|*| | |                      |   2,   48  |
;                 4 | | |*|*|*|*| | |                      |   3,  127  |
;                 8 | | |*|*|*|*| | |- - - - - - - - - - ->|   4,  255  |
;                16 |*|*|*|*|*|*|*|*|                      |   5,  255  |
;                32 | |*|*|*|*|*|*| |                      |   6,  127  |
;                64 | | |*|*|*|*| | |                      |   7,   48  |
;               128 | | | |*|*| | | |                      |   8,   16  |
;                   +---------------+                      +------------+
; ------------------------------------------------------------------------------
g_enemyBitMaskData
        BYTE     16,  48, 127, 255, 255, 127,  48,  16  ; Playfield index 0
        BYTE    255, 255, 255, 255, 255, 255, 255, 255  ; Playfield index 1
        BYTE    170,  85, 170,  85, 170,  85, 170,  85  ; Playfield index 2
        BYTE      0,   0,   0,   0,   0,   0,   0, 128  ; Playfield index 3

; ------------------------------------------------------------------------------
; @DATA:        g_enemyDataField
; @DESCRIPTION: <g_enemyDataField> pointers
;               g_enemyDataField_health         The "health" of an enemy. A zero
;                                               value indicates that the enemy 
;                                               is dead, wont be printed onto
;                                               screen.
;               g_enemyDataField_visibility     The enemy visibility of an enemy
;                                               Zero visibility indicates that 
;                                               an enemy is cloaking or is out 
;                                               of screen.
;               g_enemyDataField_screen_lo      Screen location address, low
;               g_enemyDataField_screen_hi      Screen location address, high
;               g_enemyDataField_left_char      Enemy graphics, left character
;               g_enemyDataField_right_char     Enemy graphics, right character
; ------------------------------------------------------------------------------
g_enemyDataField_health
        BYTE    $00, $50
g_enemyDataField_visibility
        BYTE    $40, $50
g_enemyDataField_screen_lo
        BYTE    $80, $50
g_enemyDataField_screen_hi
        BYTE    $c0, $50
g_enemyDataField_left_char
        BYTE    $00, $51
g_enemyDataField_right_char
        BYTE    $40, $51

; ------------------------------------------------------------------------------
; @DATA:        g_enemyAnim
; @DESCRIPTION: Enemy animation speedcode pointers.
; ------------------------------------------------------------------------------
g_enemyAnimINC
        BYTE    $00, $00
g_enemyAnimDEC
        BYTE    $00, $00

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------
init_enemyData
                ; Playfield index #
                lda #$00
                sta g_enemyBitMaskIndex

                ; Generate animation INC speedcode at $5200
                lda #$00
                sta g_enemyAnimINC
                lda #$52
                sta g_enemyAnimINC+1

                ; Generate animation DEC speedcode at $5400
                lda #$00
                sta g_enemyAnimDEC
                lda #$54
                sta g_enemyAnimDEC+1

                jsr copy_enemyBitMask
                jsr init_enemyDataFieldPointers ; need to be run only once
                jsr generate_enemyDataField

                jsr generate_enemyAnimSpeedCode
                rts

; ------------------------------------------------------------------------------
; @FUNCTION:    generate_enemyAnimSpeedCode
; @DESCRIPTION:  Generate the character animation speedcode. The animation is 
;               done by a INC/DEC, INC/DEC.... sequence switching between two
;               characters. Since an enemy consists of two characters 
;               consecutive in memory, both these characters need to be switched
;               to generate an animation.
; 
;                The two characters that make up the enemy are located in the 
;               <g_enemyDataField_left_char> and <g_enemyDataField_right_char>
;               lists so the INC/DEC operation needs to be performed on those 
;               lists.
;                      INC Speedcode                   DEC Speedcode
;                   Before          After           Before          After
;                   96, 98          97, 99          97, 99          96, 98
;
;                The maximum number of enemies on- screen is 64, each consisting
;               of two displayed characters that need to be switched. This 
;               yields two operations per animated enemy, i.e. INC left_char, 
;               INC right_char, making up a total of 128 operations per 
;               animation "frame". Each operation taking 6 cycles we have 
;               128 * 6 / 63 = 12 rasterlines. Add 6 cycles for ending RTS 
;               operation.
;
;                It is only necessary to generate the speedcode once at 
;               playfield setup (level start); as enemies dies away it will 
;               still be more efficient to run the same speedcode.
;
;                Two speedcode routines will be generated here; <g_enemyAnimINC>
;               and <g_enemyAnimDEC>, each a maximum 64 * (3 + 3 ) = 384 bytes 
;               in length, plus one byte for ending RTS operation.
; @ARG:         R: <*g_enemyDataField_left_char>
;               R: <*g_enemyDataField_right_char>
;               R: <g_enemyAnimINC>
;               R: <g_enemyAnimDEC>
;               W: <*g_enemyAnimINC>
;               W: <*g_enemyAnimDEC>
; ------------------------------------------------------------------------------
generate_enemyAnimSpeedCode
                lda g_enemyAnimINC
                sta $02
                lda g_enemyAnimINC+1
                sta $03
                lda g_enemyAnimDEC
                sta $04
                lda g_enemyAnimDEC+1
                sta $05
                ldx #$00
l_leftchar_p03  lda $eeee,x
                beq l_geasc_01
                ldy #$00
                lda l_inc_opcode
                sta ($02),y      ; store INC opcode
                lda l_dec_opcode 
                sta ($04),y      ; store DEC opcode
                iny
                ; Store low- value for address; base_lo + index (x)
                clc
                txa
                adc g_enemyDataField_left_char
                sta ($02),y
                sta ($04),y
                iny
                ; Store high- value for address
                lda g_enemyDataField_left_char+1
                sta ($02),y
                sta ($04),y
                iny
                lda l_inc_opcode
                sta ($02),y
                lda l_dec_opcode 
                sta ($04),y
                iny
                clc
                txa
                adc g_enemyDataField_right_char
                sta ($02),y
                sta ($04),y
                iny
                lda g_enemyDataField_right_char+1
                sta ($02),y
                sta ($04),y
                ; Recalculate pointers
                clc
                lda $02
                adc #$06
                sta $02
                bcc l_geasc_00
                inc $03
l_geasc_00      clc
                lda $04
                adc #$06
                sta $04
                bcc l_geasc_01
                inc $05
l_geasc_01      inx
                cpx #$40
                bne l_leftchar_p03
                ;Finish off with an RTS
                ldy #$00
_aabc           lda l_rts_opcode
                sta ($02),y
                lda l_rts_opcode
                sta ($04),y
                rts

l_inc_opcode    BYTE $ee
l_dec_opcode    BYTE $ce
l_rts_opcode    BYTE $60

; ------------------------------------------------------------------------------
; @FUNCTION:    generate_enemyDataField
; @DESCRIPTION: Generate <g_enemyDataField> lists. This routine initializes the 
;               health-, left and right char data. Other fields are set to zero. 
; @ARG:         R: <g_enemyBitMask>
; ------------------------------------------------------------------------------
generate_enemyDataField
                lda #96
                sta l_leftchar
                lda #98
                sta l_rightchar
                lda #$01
                sta l_row
l_gedf_00       ldx #$00
l_gedf_01       lda #$00
l_visibility_p01
                sta $eeee,x
l_screenlo_p01  sta $eeee,x
l_screenhi_p01  sta $eeee,x
                lda g_enemyBitMask,x ; column
                bit l_row
                beq l_gedf_02
                lda #$01
l_health_p01    sta $eeee,x
                lda l_leftchar
l_leftchar_p01  sta $eeee,x
                lda l_rightchar
l_rightchar_p01 sta $eeee,x
                jmp l_gedf_03
l_gedf_02       lda #$00
l_health_p02    sta $eeee,x
l_leftchar_p02  sta $eeee,x
l_rightchar_p02 sta $eeee,x
l_gedf_03       inx
                cpx #$08
                bne l_gedf_01        ; next column
                clc
                lda l_health_p01+1
                adc #$08
                sta l_health_p01+1
                sta l_health_p02+1
                clc
                lda l_visibility_p01+1
                adc #$08
                sta l_visibility_p01+1
                clc
                lda l_screenlo_p01+1
                adc #$08
                sta l_screenlo_p01+1
                clc
                lda l_screenhi_p01+1
                adc #$08
                sta l_screenhi_p01+1
                clc
                lda l_leftchar_p01+1
                adc #$08
                sta l_leftchar_p01+1
                sta l_leftchar_p02+1
                clc
                lda l_rightchar_p01+1
                adc #$08
                sta l_rightchar_p01+1
                sta l_rightchar_p02+1
                clc
                lda l_leftchar
                adc #$04
                sta l_leftchar
                clc
                lda l_rightchar
                adc #$04
                sta l_rightchar
                clc
                asl l_row
                bcc l_gedf_04
                rts
l_gedf_04       jmp l_gedf_00

l_row
        BYTE $00
l_leftchar
        BYTE 96
l_rightchar
        BYTE 98
; ------------------------------------------------------------------------------
; @FUNCTION:    init_enemyDataFieldPointers
; @DESCRIPTION: Initilalize <g_enemyDataField> pointers
; @ARG:         
; ------------------------------------------------------------------------------
init_enemyDataFieldPointers
                lda g_enemyDataField_health
                sta l_health_p01+1
                sta l_health_p02+1
                lda g_enemyDataField_health+1
                sta l_health_p01+2
                sta l_health_p02+2
                lda g_enemyDataField_visibility
                sta l_visibility_p01+1
                lda g_enemyDataField_visibility+1
                sta l_visibility_p01+2
                lda g_enemyDataField_screen_lo
                sta l_screenlo_p01+1
                lda g_enemyDataField_screen_lo+1
                sta l_screenlo_p01+2
                lda g_enemyDataField_screen_hi
                sta l_screenhi_p01+1
                lda g_enemyDataField_screen_hi+1
                sta l_screenhi_p01+2
                lda g_enemyDataField_left_char
                sta l_leftchar_p01+1
                sta l_leftchar_p02+1
                sta l_leftchar_p03+1
                lda g_enemyDataField_left_char+1
                sta l_leftchar_p01+2
                sta l_leftchar_p02+2
                sta l_leftchar_p03+2
                lda g_enemyDataField_right_char
                sta l_rightchar_p01+1
                sta l_rightchar_p02+1
                lda g_enemyDataField_right_char+1
                sta l_rightchar_p01+2
                sta l_rightchar_p02+2
                rts

; ------------------------------------------------------------------------------
; @FUNCTION:    copy_enemyBitMask
; @DESCRIPTION: Copy playfield data from <g_enemyBitMaskData> to 
;               <g_enemyBitMask>
; @ARG:         R: <g_enemyBitMaskIndex>
;               R: <g_enemyBitMaskData>
;               W: <g_enemyBitMask>
; ------------------------------------------------------------------------------
copy_enemyBitMask
                lda #>g_enemyBitMaskData
                sta l_cebm_01+2
                lda g_enemyBitMaskIndex
                asl
                asl
                asl
                clc
                adc #<g_enemyBitMaskData
                sta l_cebm_01+1
                bcc l_cebm_00
                inc l_cebm_01+2
l_cebm_00       lda #>g_enemyBitMask
                sta l_cebm_02+2
                lda #<g_enemyBitMask
                sta l_cebm_02+1
                ldx #$00
l_cebm_01       lda $eeee,x
l_cebm_02       sta $eeee,x
                inx
                cpx #$08
                bne l_cebm_01
                rts

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------
init_screenAndCharset
                lda #$03                        ; VIC Bank 0
                sta g_VICBank
                lda #$00
                sta g_screenMemory_lo   
                lda #$04
                sta g_screenMemory_hi
                lda #$10                        ; screen at $0400
                sta g_screenLocation_reg
                lda #$38                        ; custom charset at $3800
                sta g_customCharMemory
                lda #$0e
                sta g_customCharMemory_reg


                ; Clear screen
                jsr setup_clearScreenRoutine
                jsr clear_screen

                ; Set VIC Bank
                jsr select_VICBank

                ; Select screen
                jsr select_screenLocation

                ; Copy default charset to custom charset memory
                jsr copy_defaultCharROM

                ; Copy custom charset to custom charset memory
                jsr copy_customChars

                ; Enable custom charset
                jsr enable_customCharset

                rts


; ------------------------------------------------------------------------------
; @DATA:        g_VICBank
; @DESCRIPTION: VIC Bank Select value of $dd00
;               VIC Memory Range     Bank       Bits    Value
;               $0000 - $3fff           0       %11     3 DEFAULT
;               $4000 - $7fff           1       %10     2
;               $8000 - $bfff           2       %01     1
;               $c000 - $ffff           3       %00     0 
; ------------------------------------------------------------------------------
g_VICBank
        BYTE    $00

; ------------------------------------------------------------------------------
; @DATA:        g_screenLocation
; @DESCRIPTION: Select screen memory location value of $d018. This memory must 
;               be in the selected VIC Bank. Below is example for Bank 0, for 
;               other banks, add bank base address to location.
;               Location            Bits    Value
;               $0000           0000XXXX        0
;               $0400           0001XXXX       16
;               $0800           0010XXXX       32
;               $0c00           0011XXXX       48
;               .....           ........      ...
;               $3c00           1111XXXX      240
g_screenLocation_reg
        BYTE    $00

; ------------------------------------------------------------------------------
; @DATA:        g_screenMemory_lo
; @DESCRIPTION: Screen memory, low byte. 
; ------------------------------------------------------------------------------
g_screenMemory_lo
        BYTE    $00

; ------------------------------------------------------------------------------
; @DATA:        g_screenMemory_hi
; @DESCRIPTION: Screen memory, high byte. 
; ------------------------------------------------------------------------------
g_screenMemory_hi
        BYTE    $00

; ------------------------------------------------------------------------------
; @DATA:        g_screenMemory_reg
; @DESCRIPTION: Where to put the screen. Address is set by 4 upper bits of
;               $d018.
; ------------------------------------------------------------------------------
g_screenMemory_reg
        BYTE    $00

; ------------------------------------------------------------------------------
; @DATA:        g_customCharMemory
; @DESCRIPTION: Where to put the custom charset (high byte)
g_customCharMemory
        BYTE    $00

; ------------------------------------------------------------------------------
; @DATA:        g_customCharMemory_reg
; @DESCRIPTION: Where to put the character memory. Address is set by bit 3,2,1
;               of $d018.
;               Location           Bits  Value
;               $0000 - $07ff  ----000-      0
;               $0800 - $0fff  ----001-      2
;               $1000 - $17ff  ----010-      4        ROM Image in Bank 0 & 2
;               $1800 - $1fff  ----011-      6        ROM Image in Bank 0 & 2
;               $2000 - $27ff  ----100-      8
;               $2800 - $2fff  ----101-     10
;               $3000 - $37ff  ----110-     12
;               $3800 - $3fff  ----111-     14
g_customCharMemory_reg
        BYTE    $00

; ------------------------------------------------------------------------------
; @FUNCTION:    select_VICBank
; @DESCRIPTION: Select VIC Bank
; @ARG:         R: <g_VICBank>
; ------------------------------------------------------------------------------
select_VICBank
                lda $dd02
                ora #$03
                sta $dd02
                lda $dd00
                ora g_VICBank
                sta $dd00
                rts

; ------------------------------------------------------------------------------
; @FUNCTION:    select_screenLocation
; @DESCRIPTION: Select screen memory location
; @ARG:         R: <g_screenMemory_reg>
; ------------------------------------------------------------------------------
select_screenLocation
                lda $d018
                and #$15
                ora g_screenMemory_reg
                sta $d018
                rts

; ------------------------------------------------------------------------------
; @FUNCTION:    select_screenLocation
; @DESCRIPTION: Select screen memory location
; @ARG:         R: <g_screenMemory_reg>
; ------------------------------------------------------------------------------
enable_customCharset
                lda $d018
                and #$f1
                ora g_customCharMemory_reg
                sta $d018
                rts

; ------------------------------------------------------------------------------
; @FUNCTION:    copy_defaultCharROM
; @DESCRIPTION: Copy character ROM ($1000 - $17ff) to <g_customCharMemory>
; @ARG:         RW: <g_customCharMemory>
; ------------------------------------------------------------------------------
copy_defaultCharROM
                lda g_customCharMemory
                sta l_cc_02+2
                lda #$00
                sta l_cc_02+1
                ; disable interrupts while copy from ROM
                lda #$7f
                sta $dc0d
                ; switch the char ROM in
                lda $01
                and #$fb
                sta $01
                ldy #$07
l_cc_00         ldx #$00
l_cc_01         lda $d000,x
l_cc_02         sta $eeee,x
                dex
                bne l_cc_01
                inc l_cc_01+2
                inc l_cc_02+2
                dey
                bmi l_cc_03
                jmp l_cc_00
l_cc_03         ; Switch back VIC control
                lda $01
                ora #$04
                sta $01
                ; enable interrupts
                lda #$81
                sta $dc0d
                rts

; ------------------------------------------------------------------------------
; @FUNCTION:    copy_customChars
; @DESCRIPTION: Copies custom defined character graphics into 
;               <g_customCharMemory>
; @ARG:         RW: <g_customCharMemory>
;                R: <g_customCharRAMData>
; ------------------------------------------------------------------------------
copy_customChars
                ldy #$00
                lda g_customCharMemory
                sta l_cch_04+2
l_cch_00        lda g_customCharRAMData,y
                cmp #$ff
                beq l_cch_05
                clc
                adc l_cch_04+2
                sta l_cch_04+2
                iny
l_cch_01        lda g_customCharRAMData,y
                sta l_cch_04+1
                ldx #$00
l_cch_02        iny
l_cch_03        lda g_customCharRAMData,y
l_cch_04        sta $eeee,x
                inx
                cpx #$08
                bne l_cch_02
                iny
                tya
                clc
                adc l_cch_00+1
                sta l_cch_00+1
                sta l_cch_01+1
                sta l_cch_03+1
                lda #$00
                adc l_cch_00+2
                sta l_cch_00+2
                sta l_cch_01+2
                sta l_cch_03+2
                jmp copy_customChars
l_cch_05        rts

; ------------------------------------------------------------------------------
; @FUNCTION:    setup_clearScreenRoutine
; @DESCRIPTION: Set pointers for <clear_screen> function
; @ARG:         R: <g_screenMemory_lo>
;               R: <g_screenMemory_hi>
;               W: <l_clp_00>
;               W: <l_clp_01>
;               W: <l_clp_02>
;               W: <l_clp_03>
; ------------------------------------------------------------------------------
setup_clearScreenRoutine
                lda g_screenMemory_lo
                sec
                sbc #$01
                sta l_clp_00+1
                lda g_screenMemory_hi
                bcs l_ss_00
                sbc #$00
l_ss_00         sta l_clp_00+2
                lda l_clp_00+1
                clc
                adc #$fa
                sta l_clp_01+1
                lda l_clp_00+2
                bcc l_ss_01
                adc #00
l_ss_01         sta l_clp_01+2
                lda l_clp_01+1
                clc
                adc #$fa
                sta l_clp_02+1
                lda l_clp_01+2
                bcc l_ss_02
                adc #$00
l_ss_02         sta l_clp_02+2
                lda l_clp_02+1
                clc
                adc #$fa
                sta l_clp_03+1
                lda l_clp_02+2
                bcc l_ss_03
                adc #$00
l_ss_03         sta l_clp_03+2
                rts

; ------------------------------------------------------------------------------
; @FUNCTION:    clear_screen
; @DESCRIPTION: Fill screen memory with blanks ($20) 
; @ARG:         N/A
; ------------------------------------------------------------------------------
clear_screen
                ldx #250
                lda #$20
l_clp_00        sta $eeee,x   ;  0-249
l_clp_01        sta $eeee,x   ;250-499
l_clp_02        sta $eeee,x   ;500-749
l_clp_03        sta $eeee,x   ;750-999
                dex
                bne l_clp_00
                rts

; ------------------------------------------------------------------------------
; @DATA:        g_customCharRAMData
; @DESCRIPTION: RAM characters
;               1 - 2 : Character index (3x256 + 64...) added to 
;                       <g_customCharMemory>
;               3 - 10: Character graphics
; ------------------------------------------------------------------------------
g_customCharRAMData
        BYTE    0,   0, 170,  85, 170,  85, 170,  85, 170,  85   ;   0
        BYTE    3,   0,   8,  37,  35,  39,  29,   7,   2,   2   ;  96
        BYTE    3,   8,   4,   5,   3,   7,  29,  39,  34,  36   ;  97
        BYTE    3,  16,  16, 164, 196, 228, 184, 224,  64,  64   ;  98
        BYTE    3,  24,  32, 160, 192, 224, 184, 228,  68,  36   ;  99
        BYTE    3,  32,   9,  23,  47,  59,  47,  23,   9,   0   ; 100
        BYTE    3,  40,  33,  39,  47,  59,  47,  39,  33,   0   ; 101
        BYTE    3,  48, 144, 232, 244, 220, 244, 232, 144,   0   ; 102 
        BYTE    3,  56, 132, 228, 244, 220, 244, 228, 132,   0   ; 103
        BYTE    3,  64,   3,  15,  27,  63,  63,   4,   8,   9   ; 104
        BYTE    3,  72,   3,   7,  11,  31,  63,   4,   2,   1   ; 105
        BYTE    3,  80, 192, 224, 208, 248, 252,  32,  64, 128   ; 106
        BYTE    3,  88, 192, 240, 216, 252, 252,  16,   8,   8   ; 107
        BYTE    3,  96,   3,  15,  31,  63,  63,   5,   4,   7   ; 108
        BYTE    3, 104,   1,   7,  15,  19,  63,  63,   2,  62   ; 109
        BYTE    3, 112, 128, 224, 240, 200, 252, 252,  64, 124   ; 110
        BYTE    3, 120, 192, 240, 248, 252, 252, 160,  32, 224   ; 111
        BYTE    3, 128,  24,   5,  15,  27,  63,  31,   8,  28   ; 112
        BYTE    3, 136,   8,  21,  23,  11,  63,  31,   4,  14   ; 113
        BYTE    3, 144,  16, 168, 232, 208, 252, 248,  32, 112   ; 114
        BYTE    3, 152,  24, 160, 240, 216, 252, 248,  16,  56   ; 115
        BYTE    3, 160,   3,  15,  31,  59,  63,   5,  10,  20   ; 116
        BYTE    3, 168,   3,  15,  31,  59,  63,   5,  10,   5   ; 117
        BYTE    3, 176, 192, 240, 248, 220, 252, 160,  80,  40   ; 118
        BYTE    3, 184, 192, 240, 248, 220, 252, 160,  80, 160   ; 119
        BYTE    3, 192,   3,  15,  31,  57,  63,   6,  13,   3   ; 120
        BYTE    3, 200,   3,  15,  31,  57,  63,   6,  13,  48   ; 121
        BYTE    3, 208, 192, 240, 248, 156, 252,  96, 176, 192   ; 122
        BYTE    3, 216, 192, 240, 248, 156, 252,  96, 176,  12   ; 123
        BYTE    3, 224,   4,  34,  39,  59,  31,  15,   8,  48   ; 124
        BYTE    3, 232,   4,   2,  15,  27,  63,  47,  40,   6   ; 125
        BYTE    3, 240,  32,  68, 228, 220, 248, 240,  16,  12   ; 126
        BYTE    3, 248,  32,  64, 240, 216, 252, 244,  20,  96   ; 127
        BYTE    $ff