; retroinvaders

; contains all lookup tables for quick access
; bit_set_tbl contains lookup for bit setting
; bit_clr_tbl contains lookup for bit clearing
; bank_addr_tbl contains lookup for VIC-II bank address
; screen_lo_tbl - calculate screen offset (y * 40), low part
; screen_hi_tbl - calculate screen offset (y * 49), high part


        ; table for bit set
bit_set_tbl
        byte $01
        byte $02
        byte $04
        byte $08
        byte $10
        byte $20
        byte $40
        byte $80

        ; table for bit clear
bit_clr_tbl
        byte $fe
        byte $fd
        byte $fb
        byte $f7
        byte $ef
        byte $df
        byte $bf
        byte $7f

        ; table containing $dd00 memory bank
bank_addr_tbl
        byte $c0 ; 0
        byte $80 ; 1
        byte $40 ; 2
        byte $00 ; 3

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
