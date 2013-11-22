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
CR          EQU     $0D
LF          EQU     $0A 

*-----------WELCOME MESSAGE-----------
            LEA         WELCOME_MSG,A1 *LOAD WELCOME_MSG TO A1
            MOVE.B      #14,D0         
            TRAP        #15            *OUTPUT THE WELCOME_MSG             
           
*----------INPUT THE STARTING ADDRESSS-------------------------          
            LEA         START_PROMPT1,A1 *LOAD WELCOME_MSG TO A1
            MOVE.B      #14,D0         
            TRAP        #15              *OUTPUT THE WELCOME_MSG 
            
            	* Get the input from the user
            LEA	    INPUT, A1	* LOAD INPUT TO THE POINTER A1
	        MOVE.B	#02, D0	    * ALLOW TO READ INPUT
            TRAP	#15		    
        			* A1 stores a pointer to the beginning of the info.
        			* D1 stores length

            JSR	    ASCII_CONVERTER	*CONVERT THE INPUT TO HEX AND STORE IN D3  
*----------INPUT THE ENDING ADDRESSS-------------------------          
            LEA         START_PROMPT1,A1 *LOAD WELCOME_MSG TO A1
            MOVE.B      #14,D0         
            TRAP        #15              *OUTPUT THE WELCOME_MSG 
            
            	* Get the input from the user
            LEA	    INPUT, A1	* LOAD INPUT TO THE POINTER A1
	        MOVE.B	#02, D0	    * ALLOW TO READ INPUT
            TRAP	#15		    
        			* A1 stores a pointer to the beginning of the info.
        			* D1 stores length

            JSR	    ASCII_CONVERTER	*CONVERT THE INPUT TO HEX AND STORE IN D3  
            
*-----------ASCII CONVERT MACHINE----------------------------------

ASCII_CONVERTER

WELCOME_MSG     DC.B    '------------------------------------------------------------',CR,LF
                DC.B    '---------------============================---------------',CR,LF
                DC.B    '---------------=                            =--------------',CR,LF
                DC.B    '---------------=      ==================     =-------------',CR,LF
                DC.B    '---------------=      =                 =     =------------',CR,LF
                DC.B    '---------------=      =                  =     =-----------',CR,LF
                DC.B    '---------------=      =                   =     =-----------',CR,LF
                DC.B    '---------------=      =                   =     =-----------',CR,LF
                DC.B    '---------------=      =                   =     =-----------',CR,LF
                DC.B    '---------------=      =                  =     =------------',CR,LF
                DC.B    '---------------=      ==================     =-------------',CR,LF
                DC.B    '---------------=                             =--------------',CR,LF
                DC.B    '---------------=      ================     =----------------',CR,LF
                DC.B    '---------------=      =               =     =---------------',CR,LF
                DC.B    '---------------=      =                =     =--------------',CR,LF
                DC.B    '---------------=      =                 =     =-------------',CR,LF
                DC.B    '---------------=      =                  =     =------------',CR,LF 
                DC.B    '-------------WELCOME TO 68K FINAL PROJECT-------------------',CR,LF,$0
                DC.B    '',$0
START_PROMPT1	DC.B    'PLEASE INPUT THE STARTING ADDRESS GREATER THAN $0000A000: ',$0  
END_PROMPT2	    DC.B	'PLEASE INPUT THE ENDING ADDRESS LESS THAN $000FFFFF: ',$0
CONTINUE_PRO	DC.B	'TAP ENTER KEY TO CONTINUE... ',$0 
PRO_DONE    	DC.B	'DONE! THANKS FOR RUNING THIS PROGRAM',$0    

INPUT           DS.L    2    *ALLOCATE TWO LONG SPACE FOR STARTING AND ENDING WORDS
    
    END         START


