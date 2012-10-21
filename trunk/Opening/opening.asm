; 10 SYS (16384)

*=$801

        BYTE        $0E, $08, $0A, $00, $9E, $20, $28,  $31, $36, $33, $38, $34, $29, $00, $00, $00

*=$4000
        jsr setup_screen
        jsr clear_screen
        jsr copy_charROM
        jsr copy_customChar
        jsr enable_charRAM


        sei                  ; turn off interrupts
        lda #$7f
        ldx #$01
        sta $dc0d            ; Turn off CIA 1 interrupts
        sta $dd0d            ; Turn off CIA 2 interrupts
        stx $d01a            ; Turn on raster interrupts
        lda #$1b
        ldx #$08
        sta $d011            ; Clear high bit of $d012, set text mode
        stx $d016            ; 40 Column mode

        lda #<pe_sync; low part of address of interrupt handler code
        ldx #>pe_sync; high part of address of interrupt handler code
        ldy #$00             ; line to trigger interrupt
        sta $0314            ; store in interrupt vector
        stx $0315
        sty $d012

        lda $dc0d            ; ACK CIA 1 interrupts
        lda $dd0d            ; ACK CIA 2 interrupts
        asl $d019            ; ACK VIC interrupts

        cli

        rts

pe_sync inc $d020
        jsr print_effect01
        dec $d020
        asl $d019
        jmp $ea31

; ------------------------------------------------------------------------------
; @DATA:        screenMemory
; @DESCRIPTION: Where to put the screen. Address is set by 4 upper bits of
;               $d018. 
screenMemory_lo 
        byte $00
screenMemory_hi
        byte $04
screenMemory_reg
        byte %00010000

; ------------------------------------------------------------------------------
; @DATA:        charMemory
; @DESCRIPTION: Where to put the character memory. Address is set by bit 3,2,1
;               of $d018. xxxx111x (15) -> $3800
charMemory
        byte $38, 15

; ------------------------------------------------------------------------------
; @FUNCTION:    enable_charRAM
; @DESCRIPTION: 
; @ARG:         N/A
enable_charRAM
        lda $d018
        and #$f0
        ora charMemory+1
        sta $d018
        rts

; ------------------------------------------------------------------------------
; @FUNCTION:    copy_charROM
; @DESCRIPTION: Copy character ROM ($1000 - $17ff) to <charMemory>
; @ARG:         N/A
copy_charROM
        lda charMemory
        sta cc_02+2
        lda #$00
        sta cc_02+1
        ; disable interrupts while copy from ROM
        lda #$7f
        sta $dc0d
        ; switch the char ROM in
        lda $01
        and #$fb
        sta $01

        ldy #$07
cc_00   ldx #$00
cc_01   lda $d000,x
cc_02   sta $eeee,x
        dex
        bne cc_01
        inc cc_01+2
        inc cc_02+2
        dey
        bmi cc_03
        jmp cc_00

cc_03   ; Switch back VIC control
        lda $01
        ora #$04
        sta $01
        ; enable interrupts
        lda #$81
        sta $dc0d

        rts

; ------------------------------------------------------------------------------
; @FUNCTION:    clear_screen
; @DESCRIPTION: Fill screen memory with blanks ($20) 
; @ARG:         N/A
clear_screen
        ldx #250
        lda #$20
clp_00  sta $eeee,x   ;  0-249
clp_01  sta $eeee,x   ;250-499
clp_02  sta $eeee,x   ;500-749
clp_03  sta $eeee,x   ;750-999
        dex
        bne clp_00
        rts

; ------------------------------------------------------------------------------
; @FUNCTION:    setup_screen
; @DESCRIPTION: Setup screen memory 
; @ARG:         N/A
setup_screen
        ; ----------------------------------------------
        ; Set pointers for <clear_screen> function
        ; ----------------------------------------------
        ; clp_00
        lda screenMemory_lo
        sec
        sbc #$01
        sta clp_00+1
        lda screenMemory_hi
        bcs ss_00
        sbc #$00
ss_00   sta clp_00+2
        ; clp_01
        lda clp_00+1
        clc
        adc #$fa
        sta clp_01+1
        lda clp_00+2
        bcc ss_01
        adc #00
ss_01   sta clp_01+2
        ; clp_02
        lda clp_01+1
        clc
        adc #$fa
        sta clp_02+1
        lda clp_01+2
        bcc ss_02
        adc #$00
ss_02   sta clp_02+2
        ; clp_03
        lda clp_02+1
        clc
        adc #$fa
        sta clp_03+1
        lda clp_02+2
        bcc ss_03
        adc #$00
ss_03   sta clp_03+2
        rts

; ------------------------------------------------------------------------------
; @DATA:        print_effect01StartPos
; @DESCRIPTION: Relative screen start position (upper left corner) for enemy 
;               bitmap. This value will be added to <screenMemory>
print_effect01StartPos
        BYTE $d2, $00

; ------------------------------------------------------------------------------
; @FUNCTION:    print_effect01
; @DESCRIPTION: Copy the chars from bitmap onto screen
; @ARG:         <screenMemory_lo>
;               <screenMemory_hi>
;               <print_effect01StartPos>
;               <bitmapData_BigEnemy>
print_effect01
        ; calculate upper left corner screen address (store destination address)
        clc
        lda print_effect01StartPos
        adc screenMemory_lo
        sta pe01_a1+1
        lda print_effect01StartPos+1
        adc screenMemory_hi
        sta pe01_a1+2

        ; subtract 1 from destination address to be in synch with x index
        sec
        lda pe01_a1+1
        sbc #$01
        sta pe01_a1+1
        bcs pe01_00
        lda pe01_a1+2
        sbc #$01
        sta pe01_a1+2

pe01_00 ; calculate first load source address
        lda #<bitmapData_BigEnemy
        sta pe01_x0+1
        sta pe01_a0+1
        lda #>bitmapData_BigEnemy
        sta pe01_x0+2
        sta pe01_a0+2

        ;load x- value
pe01_x0 lda $eeee
        beq print_effect01Exit          ; x- value 0 means all rows printed
        tax
        tay                             ; save x value in y
pe01_nc dex                             ; next char
pe01_a0 lda $eeee,x
        beq pe01_nr 
pe01_a1 sta $eeee,x
        jmp pe01_nc
pe01_nr tya                             ; add x (saved y) value to pe01_x0, pe01_a0
        clc
        adc pe01_x0+1
        sta pe01_x0+1
        sta pe01_a0+1
        bcc pe01_01
        inc pe01_x0+2
        inc pe01_a0+2
pe01_01 lda pe01_a1+1                   ; add 40 to pe01_a1
        clc
        adc #40
        sta pe01_a1+1
        bcc pe01_x0
        inc pe01_a1+2
        jmp pe01_x0

print_effect01Exit
        rts

print_effect01Dst
        BYTE $00, $00
print_effect01Src
        BYTE $00, $00

; ------------------------------------------------------------------------------
; @DATA:        bitmapData_BigEnemySize
; @DESCRIPTION: Size of BigEnemy bitmap (cols, rows)
bitmapData_BigEnemySize
        BYTE     20, 14

; ------------------------------------------------------------------------------
; @DATA:        bitmapData_BigEnemy
; @DESCRIPTION: Bitmap char data for big enemy 
bitmapData_BigEnemy
        ;         -01--02--03--04--05--06--07--08--09--10--11--12--13--14--15--16--17--18--19--20--21-
        BYTE  15,   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 92,  1
        BYTE  15,   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  3
        BYTE  16,   0,  0,  0,  0,  0,  0,  4,  5, 32,  6,  7,  8,  9, 10, 11
        BYTE  18,   0,  0,  0,  0,  0,  0, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22
        BYTE  21,   0,  0,  0,  0,  0,  0, 23, 24, 25, 19, 26, 27, 28, 19, 29, 19, 30, 31, 33, 34
        BYTE  21,   0,  0,  0,  0,  0, 35, 36, 37, 38, 19, 39, 40, 19, 19, 41, 42, 43, 15, 19, 44
        BYTE  22,   0,  0,  0,  0,  0, 45, 19, 46, 47, 19, 19, 19, 19, 19, 48, 32, 32, 49, 19, 50, 51
        BYTE  22,   0,  0,  0,  0, 52, 53, 19, 19, 19, 19, 19, 19, 19, 19, 54, 32, 32, 55, 19, 19, 56
        BYTE  22,   0,  0,  0, 57, 58, 59, 19, 19, 19, 19, 60, 19, 61, 62, 32, 32, 32, 63, 19, 64, 65
        BYTE  20,   0,  0, 66, 67, 32, 68, 69, 19, 70, 71, 72, 19, 73, 32, 32, 32, 32, 74, 75
        BYTE  14,   0, 76, 85, 77, 32, 78, 79, 19, 26, 32, 81, 82, 83
        BYTE  10,   0, 84, 19, 86, 32, 32, 87, 88, 89
        BYTE   4,   0, 90, 91
        BYTE   0

; ------------------------------------------------------------------------------
; @FUNCTION:    copy_customChar
; @DESCRIPTION: Copy custom characters to <charMemory>
; @ARG:         N/A
copy_customChar
        lda #<customCharData_BigEnemy           ; low part of source address
        sta ccc_01+1
        lda #>customCharData_BigEnemy           ; high part of source address
        sta ccc_01+2
        lda #$00                                ; low part destination address
        sta ccc_02+1
        lda CharMemory                          ; high part destination address
        sta ccc_02+2
        ldx #$00

ccc_00  ldy #$00
ccc_01  lda $eeee,y
ccc_02  sta $eeee,y
        iny
        cpy #$08
        bne ccc_01

        inx        
        cpx customCharData_NumberOfChars
        beq copy_customCharExit

        clc
        lda ccc_01+1
        adc #$08
        sta ccc_01+1
        lda ccc_01+2
        adc #$00
        sta ccc_01+2

        clc
        lda ccc_02+1
        adc #$08
        sta ccc_02+1
        lda ccc_02+2
        adc #$00
        sta ccc_02+2

        jmp ccc_00

copy_customCharExit
        rts

; ------------------------------------------------------------------------------
; @DATA:        customCharData_NumberOfChars
; @DESCRIPTION: Number of chars for <customCharData_BigEnemy>
customCharData_NumberOfChars
        BYTE         93
; ------------------------------------------------------------------------------
; @DATA:        customCharData_BigEnemy
; @DESCRIPTION: BigEnemy characters.
customCharData_BigEnemy
        BYTE          0,  0,  0,  0,  0,  0,  0,  0 ; CHARACTER 0
        BYTE          0, 14,127,255,255,255,255,255 ; CHARACTER 1
        BYTE         63, 63, 63, 63, 63, 28, 16,  0 ; CHARACTER 2
        BYTE        255,255,254,240,128,  0,  0,  0 ; CHARACTER 3
        BYTE          0,  0,  0,  0,  0,  0,  3, 31 ; CHARACTER 4
        BYTE          0,  0,  0,  0, 24,120,240,240 ; CHARACTER 5
        BYTE          0,  0,  0,  0,  0,  0,  3, 15 ; CHARACTER 6
        BYTE          0,  0,  0,  1, 15,127,255,255 ; CHARACTER 7
        BYTE          1, 15,127,255,255,255,255,255 ; CHARACTER 8
        BYTE        192,192,192,192,192,192,224,224 ; CHARACTER 9
        BYTE          0,  0,  0,  0,  0,  0,  7, 31 ; CHARACTER 10
        BYTE          0,  0,  0,  0,  0,192,192,192 ; CHARACTER 11
        BYTE         63, 63, 63, 63,127,127,126,112 ; CHARACTER 12
        BYTE        240,240,240,240,241,207, 15, 15 ; CHARACTER 13
        BYTE          0,  3, 15,127,255,255,255,255 ; CHARACTER 14
        BYTE        127,255,255,255,255,255,255,255 ; CHARACTER 15
        BYTE        255,255,255,255,255,255,248,240 ; CHARACTER 16
        BYTE        255,255,255,252,224,  0,  0,  0 ; CHARACTER 17
        BYTE        224,231,159, 31, 31, 31, 31, 31 ; CHARACTER 18
        BYTE        255,255,255,255,255,255,255,255 ; CHARACTER 19
        BYTE        192,192,224,224,224,224,224,224 ; CHARACTER 20
        BYTE          0,  0,  0,  0,  0,  1, 15,255 ; CHARACTER 21
        BYTE          0,  0,  0,  0,120,248,248,252 ; CHARACTER 22
        BYTE        128,  0,  0,  0,  0,  0,  0,  0 ; CHARACTER 23
        BYTE         15, 15, 31, 31, 31, 31, 28,  0 ; CHARACTER 24
        BYTE        255,255,255,255,241,129,  1,  1 ; CHARACTER 25
        BYTE        240,240,240,240,240,240,240,240 ; CHARACTER 26
        BYTE          0,  0,  0,  0,  0,  0,  0,  1 ; CHARACTER 27
        BYTE         15, 15, 15, 15, 15, 15, 63,255 ; CHARACTER 28
        BYTE        231,255,255,255,255,255,255,255 ; CHARACTER 29
        BYTE        252,252,252,252,254,254,254,254 ; CHARACTER 30
        BYTE          0,  0,  0,  0,  0,  0,  0, 15 ; CHARACTER 31
        BYTE          0,  0,  0,  0,  0,  0,  0,  0 ; CHARACTER 32
        BYTE          0,  0,  0,  0,  1, 31,255,255 ; CHARACTER 33
        BYTE          0,  0,  0, 32,224,224,240,240 ; CHARACTER 34
        BYTE          0,  0,  0,  0,  1,  3,  3,  3 ; CHARACTER 35
        BYTE          0,  3, 31,255,255,255,255,255 ; CHARACTER 36
        BYTE         64,192,192,192,192,192,192,128 ; CHARACTER 37
        BYTE          1,  1,  1,  1,  1,  1,  1,  3 ; CHARACTER 38
        BYTE        240,240,251,255,255,255,255,255 ; CHARACTER 39
        BYTE         15,127,255,255,255,255,255,255 ; CHARACTER 40
        BYTE        255,255,255,255,255,255,252,252 ; CHARACTER 41
        BYTE        255,255,255,255,240,128,  0,  0 ; CHARACTER 42
        BYTE        254,255,225,  0,  0,  0,  0,  0 ; CHARACTER 43
        BYTE        240,248,248,248,252,252,252,252 ; CHARACTER 44
        BYTE          3,  3,  3,  7,  7,  7,  7, 15 ; CHARACTER 45
        BYTE        128,128,135,191,255,255,255,255 ; CHARACTER 46
        BYTE         31,255,255,255,255,255,255,255 ; CHARACTER 47
        BYTE        252,252,252,252,252,252,252,254 ; CHARACTER 48
        BYTE        127,127,127,127,127, 63, 63, 63 ; CHARACTER 49
        BYTE        254,254,254,255,255,255,255,255 ; CHARACTER 50
        BYTE          0,  0,  0,  0,  0,  0,  0,128 ; CHARACTER 51
        BYTE          0,  1, 15,127,127,255,255,255 ; CHARACTER 52
        BYTE         63,255,255,255,255,255,255,255 ; CHARACTER 53
        BYTE        254,254,254,254,254,254,248,128 ; CHARACTER 54
        BYTE         63, 63, 31, 31, 31, 31, 31, 15 ; CHARACTER 55
        BYTE        128,128,192,192,192,192,224,224 ; CHARACTER 56
        BYTE          0,  1,  1,  1,  1,  1,  3,  2 ; CHARACTER 57
        BYTE        255,255,255,255,255,248,192,  0 ; CHARACTER 58
        BYTE        255,255,255,255,191, 63, 63, 63 ; CHARACTER 59
        BYTE        255,255,255,255,255,255,255,207 ; CHARACTER 60
        BYTE        255,255,248,248,248,248,252,252 ; CHARACTER 61
        BYTE        248,128,  0,  0,  0,  0,  0,  0 ; CHARACTER 62
        BYTE         15, 15, 15, 15,  7,  7,  7,  7 ; CHARACTER 63
        BYTE        255,255,255,255,255,255,255,224 ; CHARACTER 64
        BYTE        224,240,240,240,248,240,  0,  0 ; CHARACTER 65
        BYTE          0,  0,  7, 63, 63, 63, 63,127 ; CHARACTER 66
        BYTE         12,120,248,248,248,240,240,240 ; CHARACTER 67
        BYTE         63, 63,127,127,127,127,127,127 ; CHARACTER 68
        BYTE        255,255,255,255,255,255,255,195 ; CHARACTER 69
        BYTE        255,255,254,248,248,248,248,240 ; CHARACTER 70
        BYTE        252,224,  0,  0,  0,  0,  0,  0 ; CHARACTER 71
        BYTE         15, 15,  15,15, 15, 15, 15, 15 ; CHARACTER 72
        BYTE        252,252,252,252,252,252,252,252 ; CHARACTER 73
        BYTE          7,  3,  0,  0,  0,  0,  0,  0 ; CHARACTER 74
        BYTE        254,192,  0,  0,  0,  0,  0,  0 ; CHARACTER 75
        BYTE          0,  0,  0,  0,  0,  0,  1,  1 ; CHARACTER 76
        BYTE        240,240,224,224,224,224,224,192 ; CHARACTER 77
        BYTE        252,192,  0,  0,  0,  0,  0,  0 ; CHARACTER 78
        BYTE          3,  3,  3,  7,  7,  7,  7,  7 ; CHARACTER 79
        BYTE        240,240,240,240,240,240,240,240 ; CHARACTER 80
        BYTE         15, 15, 15, 15, 15, 15, 15,  8 ; CHARACTER 81
        BYTE        255,255,255,255,255,252,128,  0 ; CHARACTER 82
        BYTE        252,252,252,252,192,  0,  0,  0 ; CHARACTER 83
        BYTE          1,  1,  3,  3,  3,  3,  7,  7 ; CHARACTER 84
        BYTE        127,127,255,255,255,255,255,255 ; CHARACTER 85
        BYTE        192,192,192,128,128,128,128,128 ; CHARACTER 86
        BYTE          7, 15, 15, 15, 15, 15, 12,  0 ; CHARACTER 87
        BYTE        255,255,255,255,254,192,  0,  0 ; CHARACTER 88
        BYTE        240,240,240,224,  0,  0,  0,  0 ; CHARACTER 89
        BYTE          7,  7, 15, 15, 15, 15, 31, 16 ; CHARACTER 90
        BYTE        255,255,255,255,255,248,128,  0 ; CHARACTER 91
        BYTE          0,  0,  0,  1, 15, 63, 63, 63 ; CHARACTER 92
