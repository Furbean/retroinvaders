; global contantants

        *=$08ff

; zero page constants
$io_port        = $00
$io_bank        = $01


$src_ptr        = $02
$src_ptr_lo     = $02
$src_ptr_hi     = $03
$dst_ptr        = $04
$src_ptr_lo     = $04
$src_ptr_hi     = $05


; contains high byte of the bank address
$vic_bank       = $f0
$screen_bank    = $f1
$char_bank      = $f2
$bitmap_bank    = $f3


; IO addresses
$vic_io         = $d000
$sid_io         = $d400
$irq_io         = $dc00
$nmi_io         = $dd00


$color_ram      = $d800        ; color ram address


$rst_addr       = $fffc         ; reset address
$nmi_addr       = $fffa         ; nmi address
$irq_addr       = $fffe         ; irq address
