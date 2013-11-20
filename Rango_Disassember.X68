*-----------------------------------------------------------
* Title      : 68K Disassember
* Written by : Team Rango
* Date       : 11/14/2013
* Description: Write an inverse assember that will
*           convert a memory image of instructions and
*           data back to 680000 assembly language and
*           output the disassembled code to the display.
*-----------------------------------------------------------
  
            ORG    $1000
START:                  ; first instruction of program

* Variable used in code
startAddr   EQU     $0000A000           ;require user to input the memory location lower bound
endAddr     EQU     $000FFFFF           ;require user to input the memory location upper bound
dollar      EQU     $24                 ;ASCII $
LF          EQU     $0A                 ;ASCII value for Line feed
CR          EQU     $0D                 ;ASCII value for Carriage return

*-----------Code for output-----------
LOOP        LEA         MESSAGE,A1
            MOVE.B      #14,D0
            TRAP        #15              ;Display Message
           
*-----------Code for input------------
START       MOVE.L  #2, D0               ;
            TRAP    #15                  ;Read string from keyboard
               

            *MOVE.B      #2,D0           Read String
            *TRAP        #15             Read a number from keyboard into D1.l
            *CMP.L       #0,D1           Compares D1 to number 0
            *BEQ         DONE            Branch to DONE if they are equal
           
            CMP.L       #$10,D1          Compares D1 to 0
            BLT         INVALID         BTL branches if D1 is less than 0
            CMP.L       #$20,D1          Compares D1 to 1
            BGT         INVALID         BGT branches if D1 is greater than 9
 
*--figure out what the number actually is--            
            
            LEA     DISPLAY, A1
            MOVE.B  #14, D0
            TRAP    #15            
            
DISPLAY     DC.B    'You enter....', 0
           
INVALID     LEA         INV,A1
            MOVE.B      #14,D0
            TRAP        #15
            BRA         LOOP
           
DONE        MOVE.B      #9,D0
            TRAP        #15             Halt simulator
                       
MESSAGE     DC.B        'Enter a number between 0000A000 and 000FFFFF, Enter 0 to finsih: ',0
INV         DC.B        'That is not between 0000A000 and 000FFFFF.',CR,LF,0
 
             END         START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
