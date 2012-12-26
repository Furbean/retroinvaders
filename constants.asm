; retroinvaders

; global contantants

        *=$08fe


; zero page constants
io_port        = $00
io_bank        = $01

src_ptr        = $02;-03
dst_ptr        = $04;-05


; contains high byte of the bank address
vic_bank       = $f0
screen_bank    = $f1
char_bank      = $f2
bitmap_bank    = $f3


; IRQ handling
irq_jump_tbl   = $f4;-f5       ; irq jump table
irq_scan_tbl   = $f6;-f7       ; irq scan line table
irq_index      = $f8           ; current irq index


; IO addresses
vic_io         = $d000         ; VIC-II io address
sid_io         = $d400         ; SID address
irq_io         = $dc00         ; CIA #1 IRQ io address
nmi_io         = $dd00         ; CIA #2 NMI io address


color_ram      = $d800         ; color ram address
screen_chars   = 1000          ; number of characters per screen


rst_addr       = $fffc         ; reset address
nmi_addr       = $fffa         ; nmi address
irq_addr       = $fffe         ; irq address
