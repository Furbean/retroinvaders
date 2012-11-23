; contains all lookup tables for quick access
; bit_set_tbl contains lookup for bit setting
; bit_clr_tbl contains lookup for bit clearing
; bank_addr_tbl contains lookup for VICII bank address



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

