*-----------------------------------------------------------
* Title      : 68K Disassember
* Written by : Team Rango
* Date       : 11/14/2013
* Description: Write an inverse assember that will
*           convert a memory image of instructions and
*           data back to 680000 assembly language and
*           output the disassembled code to the display.
*-----------------------------------------------------------
OPT     CRE             ;bring data memory into Symbol Table
ORG    $1000
START:                  ; first instruction of program

* Variable used in code
startAddr   EQU     $00002000           ;require user to input the memory location lower bound
endAddr     EQU     $000FFFFF           ;require user to input the memory location upper bound
badStart    EQU     $000FFFFE           ;Invalid starting Address if GTE 000FFFFE
dollar      EQU     $24                 ;ASCII $
LF          EQU     $0A                 ;ASCII value for Line feed
CR          EQU     $0D                 ;ASCII value for Carriage return

* Put variables and constants here
LEA WELCOM_MSG, A1      ;LOAD WELCOME MASSAGE
MOVE.B  #14,D0
TRAP    #15

WELCOME_MSG     DC.B    '------------------------------------------------------------',CR,CL
                DC.B    '---------------============================---------------',CR,CL
                DC.B    '---------------=                            =--------------',CR,CL
                DC.B    '---------------=      ==================     =-------------',CR,CL
                DC.B    '---------------=      =                 =     =------------',CR,CL
                DC.B    '---------------=      =                  =     =-----------',CR,CL
                DC.B    '---------------=      =                   =     =-----------',CR,CL
                DC.B    '---------------=      =                   =     =-----------',CR,CL
                DC.B    '---------------=      =                   =     =-----------',CR,CL
                DC.B    '---------------=      =                  =     =------------',CR,CL
                DC.B    '---------------=      ==================     =-------------',CR,CL
                DC.B    '---------------=                             =--------------',CR,CL
                DC.B    '---------------=      ================     =----------------',CR,CL
                DC.B    '---------------=      =               =     =---------------',CR,CL
                DC.B    '---------------=      =                =     =--------------',CR,CL
                DC.B    '---------------=      =                 =     =-------------',CR,CL
                DC.B    '---------------=      =                  =     =------------',CR,CL
                
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
