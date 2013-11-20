*-----------------------------------------------------------
* Title      : 68K TEST
* Written by : Team Rango
* Date       : 11/14/2013
* Description: Write an inverse assember that will
*           convert a memory image of instructions and
*           data back to 680000 assembly language and
*           output the disassembled code to the display.
*-----------------------------------------------------------
            ORG    $A000
START:                  ; first instruction of program

* Put variables and constants here
            MOVE.B  #14,D0
            MOVEA.W $1000, A0


                
    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
