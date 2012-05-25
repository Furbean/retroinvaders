*=$4000
        LDA #$FF ; maximum frequency value 
        STA $D40E ; voice 3 frequency low byte 
        STA $D40F ; voice 3 frequency high byte 
        LDA #$80 ; noise waveform, gate bit off 
        STA $D412 ; voice 3 control register 

aa      LDA $D41B
bb      STA $0400
cc      sta $d800
        inc bb+1
        inc cc+1
        JMP aa
         