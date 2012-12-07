

;Memory setup
;--------------------


; VICII bank - 4 banks selectable, each 16KB = address $8000
; SCREEN bank - 16 banks selectable, contains text, address at VICII bank + SCREEN bank * $400
; SPRITE index = 8 indexes starting at SCREEN bank + 1016 bytes 
; CHAR bank - 8 banks selectable, contains character data, address at VICII bank + CHAR bank * $800
; BITMAP bank - 2 banks selectable, contains bitmap data, address at VICII bank + BITMAP bank * $2000


;$0801 - prg start
;$08ff - macro and contants start
;$0900 - program start
;$8000 - screen bank
;$8800 - char bank 1 - the whole bank for usage, contains game font
;$9000 - char bank 2 - extra bank for sprite animation (partially used)
;$9200 - $C000 sprites, 184 sprites


; UFO-->
;+--------------------------------------+ <-1
;|  >> << >> << >> << >> << >>
;|  >> << >> << >> << >> << >>
;|  >> << >> << >> << >> << >>
;|  >> << >> << >> << >> << >>
;|  >> << >> << >> << >> << >>
;|  >> << >> << >> << >> << >>
;|  >> << >> << >> << >> << >>
;|  >> << >> << >> << >> << >>
;|
;|          "           "
;|                        '              <- 2
;| SSS            SSS           SSS
;| SSS    |       SSS           SSS
;|
;|       +^+                             <- 3
;+-------------------------------------+
; +^+ +^+ +^+                 000000300

;Screen information:
;Remove bottom and top border

;top border contains UFO
;bottom border contains SHIPS (3) and SCORE (3 sprites)

;middle contains ship (1), shot from ship and up to 6 enemy shots
;shot must be able to pass up to the UFO!!!

;raster interrupt positions on screen

;position 1
;set correct character bank
;shift x character position
;setup sprite banks

;position 2 - when needed, depending on if the shield should be drawn
;setup correct character bank
;shift back x character position to 0

;position 3
;disable border
;set sprites for available ships and score
