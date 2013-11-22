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
START_INPUT 
            LEA         START_PROMPT,A1 *LOAD WELCOME_MSG TO A1
            MOVE.B      #14,D0         
            TRAP        #15              *OUTPUT THE WELCOME_MSG 
            
            	* Get the input from the user
            LEA	    INPUT, A1	* LOAD INPUT TO THE POINTER A1
	        MOVE.B	#02, D0	    * ALLOW TO READ INPUT
            TRAP	#15		    
            JSR	    ASCII_CONVERTER	*CONVERT THE INPUT TO HEX AND STORE IN D2  
*----------INPUT THE ENDING ADDRESSS-------------------------          
END_INPUT            
            LEA         END_PROMPT,A1 *LOAD WELCOME_MSG TO A1
            MOVE.B      #14,D0         
            TRAP        #15              *OUTPUT THE WELCOME_MSG 
            
            LEA	    INPUT, A1	* LOAD INPUT TO THE POINTER A1
	        MOVE.B	#02, D0	    * ALLOW TO READ INPUT
            TRAP	#15	
            MOVEA.W #$10,A6   *ID TO RECOGNIZE THIS IS THE ENDING ADDRESS INPUT	    
            JSR	    ASCII_CONVERTER	*CONVERT THE INPUT TO HEX AND STORE IN D2  
            
            STOP    #$2700 *STOP THE PROGRAM
*-----------ASCII CONVERT MACHINE----------------------------------
*CONVERT USER INPUT STORED IN ASCII CODE INTO HEX NUMBER AND STORE 
*   IT INTO D2
*A1 STORED THE POINTER OF USER INPUT
*D1 STORED THE LENGTH OF USER INPUT
ASCII_CONVERTER
	        MOVEM.L	D0/D2,-(SP)	    * LOAD DATA REGISTER INTO STACK
            CLR.L	D3		        * CLEAR ALL DATA STORED IN D2 BEFORE

        	CMP.B	#8, D1			* COMPARE TO MAKE SURE THE INPUT LENGTH LESS THAN 8
	        BGT		LEN_ERROR       * THE LENGTH IS GREATER THAN 8, BRANCH TO ERROR
	        CMP.B	#0, D1			* COMPARE TO MAKE SURE THE INPUT LENGTH GREATER THAN 0
	        BLE	    LEN_ERROR	    * THE LENGTH EQUAL 0, BRANCH TO ERROR
	        SUBQ.B	#1,D1		    * Subtract 1 from the counter (zero based)

*-----------USE THE LENGTH OF USER INPUT IN D1 AS A COUNTER FOR THIS LOOP---------
ASCII_CONVERTER_LOOP	*COMPARE EACH BYTE OF INPUT TO DEFINE IT AS 0-9 OR NOT         
	        *ROL.L	#4, D3			* shift the bits left by 4
	        MOVE.B	(A1)+, D0		* MOVE THE BYTE FROM INPUT TO D0
	        CMP.B	#$39, D0		* ASCII CODE (0-9) = (30-39), COMPARE IT TO 39
	        BGT	    LETTER	        * BIGGER THAN 39, IT MAYBE A LETTER, BRANCH TO  
	        CMP.B	#$30, D0		* ASCII CODE (0-9) = (30-39), COMPARE IT TO 30
	        BLT	    LETTER_ERROR	* IF LESS THAN 30, RETURN ERROR WARNING
	        SUBI.B	#$30, D0		* ELSE THE INPUT IS VALID, SUBTRACT TO GET THE DECIMAL NUM
	        BRA	    ASCII_DONE

LETTER
	        CMP.B	#$66, D0		* IF ASCII NUM > 66(LOWER CASE F IN HEX), INVALID
	        BGT	    LETTER_ERROR	* RETURN WARNING MESSAGE
	        CMP.B	#$61, D0		* IF 61>= VALUE, IT MAY BE A LOWER CASE ASCII CHARACTER 
	        BGE	    ASCII_LOWER_LET	* BRANCH LOWER CASE 
	        
	        *HANDLING THE LOWER CASE ISSUE FOR ASCII CHARACTER
	        CMP.B	#$46, D0		* IF THE VALUE>46, IT IS INVALID
	        BGT	    LETTER_ERROR	* RETURN ERROR WARNING MESSAGE
	        CMP.B	#$41, D0		* IF THE VALUE<41, IT IS INVALID
	        BLT	    LETTER_ERROR	* RETURN WARNING MESSAGE
	        SUBI.B	#$37, D0		* ELSE, IT IS VALID, SUBTRACT 37
	        BRA	    ASCII_DONE      
	
ASCII_LOWER_LET
	        SUBI.B	#$57, D0            *SUBTRACT 57 IF LOWER CASE CHARACTER
	        BRA	    ASCII_DONE          *BRANCH TO FINISH THE SUBROUTINE
	
ASCII_DONE
	        OR.B	D0, D3			        * OR the results into the return value
	        SUBI    #$1,D1                  * DECREMENT THE LOOP COUNTER
	        CMP.B   #$0,D1                  * COMPARE IF COUNTER IS 0
	        BNE     ASCII_CONVERTER_LOOP	* IF THE COUNTER IS NOT 0, BRANCH BACK THE LOOP
	        MOVEM.L	(SP)+,D0/D2	            * POP OUT THE STACK
	        RTS			                    * BACK TO THE PROGRAM
	
	
*--------------------------------------------------------------------------
*THE LENGTH IS OUT OF BOUND, BRANCH BACK THE INPUT MESSAGE
LEN_ERROR       LEA         LENGTH_ER,A1    *LOAD LENGTH ERROR WARNING TO A1
                MOVE.B      #14,D0         
                TRAP        #15             *OUTPUT THE WELCOME_MSG 
                CMP.W       #$10,A6 
                BNE         START_INPUT     *BRANCH BACK TO THE INPUT MESSAGE  
                BRA         END_INPUT       *BRANCH BACK TO THE INPUT MESSAGE
LETTER_ERROR    LEA         LETTER_ER,A1    *LOAD LENGTH ERROR WARNING TO A1
                MOVE.B      #14,D0         
                TRAP        #15             *OUTPUT THE WELCOME_MSG 
                CMP.W       #$10,A6 
                BNE         START_INPUT     *BRANCH BACK TO THE INPUT MESSAGE  
                BRA         END_INPUT       *BRANCH BACK TO THE INPUT MESSAGE    	
*====================================================================================================	
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
                DC.B    '',CR,LF,$0
START_PROMPT	DC.B    'PLEASE INPUT THE STARTING ADDRESS GREATER THAN $0000A000: ',$0  
END_PROMPT	    DC.B	'PLEASE INPUT THE ENDING ADDRESS LESS THAN $000FFFFF: ',$0
CONTINUE_PRO	DC.B	'TAP ENTER KEY TO CONTINUE... ',$0 
PRO_DONE    	DC.B	'DONE! THANKS FOR RUNING THIS PROGRAM',$0    
LENGTH_ER       DC.B    'THE SIZE OF MEMORY LOCATION IS OUT OF RANGE',CR,LF,$0
LETTER_ER       DC.B    'INPUT CONTAINS INVALID ELEMENTS',CR,LF,$0

INPUT           DS.L    2    *ALLOCATE TWO LONG SPACE FOR STARTING AND ENDING WORDS
    
    END         START




