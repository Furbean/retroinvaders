; retroinvaders

        *=$0900

        jsr sound_it

        lda #<message
        sta $02
        lda #>message
        sta $03
        ldx #14
        ldy #15
        jsr write_string

        ; initialize the interrupt
        sei

        ; disable all rom except for IO
        lda #$35
        sta io_bank$

        ; initialize all sprites
        jsr init_sprites
                
        ; init interrupt handler
        lda #<interrupt
        sta irq_addr$
        lda #>interrupt
        sta irq_addr$ + 1
        
        ; disable timer interrupts which can be generated by the two CIA chips.
        ; the kernal uses such an interrupt to flash the cursor and scan the keyboard, so we better stop it.
        lda #$7f
        sta $dc0d
        sta $dd0d

        ; by reading this two registers we negate any pending CIA irqs.
        ; if we don't do this, a pending CIA irq might occur after we finish setting up our irq.
        ; we don't want that to happen.
        lda $dc0d
        lda $dd0d

        ; tell the VIC-II to generate a raster interrupt
        lda #$01
        sta $d01a

        ; tell at which rasterline we want the irq to be triggered
        lda #$50
        sta $d012

        ; as there are more than 256 rasterlines, the topmost bit of $d011 serves as
        ; the 8th bit for the rasterline we want our irq to be triggered.
        ; here we simply set up a character screen, leaving the topmost bit 0.
        lda #$1b
        sta $d011

        cli

        ; todo: sound sequencer
        ; jsr reset_sequencer
_reset_sequencer
        ; jsr init_sequencer
_play_sequencer
        ; jsr play_sequencer
        ; lda done_sequencer
        bne _play_sequencer
        jmp _reset_sequencer

message
        byte 12
        text 'hello world!'