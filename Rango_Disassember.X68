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
SP          EQU     $00010000
*-----------WELCOME MESSAGE-----------
            LEA         WELCOME_MSG,A1 *LOAD WELCOME_MSG TO A1
            MOVE.B      #14,D0         
            TRAP        #15            *OUTPUT THE WELCOME_MSG             
           
*----------INPUT THE STARTING ADDRESSS-------------------------          
START_INPUT 
            LEA         START_PROMPT,A1 *LOAD WELCOME_MSG TO A1
            MOVE.B      #14,D0         
            TRAP        #15              *OUTPUT THE WELCOME_MSG 
            
            LEA            INPUT, A1        * LOAD INPUT TO THE POINTER A1
            MOVE.B        #02, D0            * ALLOW TO READ INPUT
            TRAP        #15                    
            JSR            ASCII_CONVERTER        *CONVERT THE INPUT TO HEX AND STORE IN D2  
            MOVEA.L D3,A0           *STORE STARTING ADDRESS AT A1
*----------INPUT THE ENDING ADDRESSS-------------------------          
END_INPUT            
            LEA         END_PROMPT,A1 *LOAD WELCOME_MSG TO A1
            MOVE.B      #14,D0         
            TRAP        #15              *OUTPUT THE WELCOME_MSG 
            
            LEA            INPUT, A1        * LOAD INPUT TO THE POINTER A1
            MOVE.B        #02, D0            * ALLOW TO READ INPUT
            TRAP        #15        
            MOVEA.W #$10,A6   *ID TO RECOGNIZE THIS IS THE ENDING ADDRESS INPUT            
            JSR            ASCII_CONVERTER        *CONVERT THE INPUT TO HEX AND STORE IN D2  
            MOVEA.L D3,A3           *STORE STARTING ADDRESS AT A1

*-----------DISASSEMBLY CODE ---------------------------------------
* CONVERT THE HEXADECIMAL ADDRESS MEMORY TO ASCII 
* THEN, WE CAN PRINT OUT IN THE WINDOW
	*MOVE.B	#0, D6		* 
	LEA	GOOD_DATA,A5	* LOAD THE RESERVED SPACE OF PASSED DATA TO A5
	LEA	BAD_DATA,A6	    * LOAD THE RESERVED SPACE OF UNPASSED DATA TO A6
	MOVEA.L  #$000FFF00,A7
	
* READ THE LOCATION MEMORY AND PRINT OUT
	MOVE.L 	A0, D0		    * COPY MEMORY LOCATION TO D0
	MOVE.L	#INPUT, A1	    * LOAD THE RESERVED SPACE OF INPUT TO A1
	JSR	    HEXCONVERTER	* START CONVERTING HEX TO ASCII
    MOVE.W  #$9,(A1)+       *ADD TAB
    MOVE.B  #14,D0
    LEA     INPUT,A1
    TRAP    #15
    
    BRA DONE *STOP THE PROGRAM    

*------------------------------------------------------------------------------
* A1 = The memory location where the output will be written
* D0 = The value to convert 
* D1 = The size of the operation (1-4: this is the number of bytes to process)
* D2 = Internal
* D3 = Internal
*-------------------------------------------------------------------------------
HEXCONVERTER
	MOVEM.L	D0,-(A7)	*PUSH THE DATA TO A7
	MOVE.L	#7,D1		*COUNTER FOR POP IN THE VALUE TO STACK (8 TIMES)
	MOVE.L	#7,D3		*COUNTER TO POP OUT THE VALUE AT THE END (8 TIMES)	
HEXCONVERTER_LOOP1
	MOVE.L 	D0,D2		*MAKE A COPY OF D0 AT D2
	ANDI.B	#$0F,D2	    *
	CMP.B	#9,D2		*NUMBER? (0-9)
	BGT	HEXCONVERTER_LETTER	*IF IT IS BIGGER, LETTER?
	ADDI	#$30,D2		*ASCII NUMBER 
	BRA	HEXCONVERTER_NEXT	
HEXCONVERTER_LETTER
	ADDI	#$37,D2		
HEXCONVERTER_NEXT	
	MOVE.B 	D2,-(A7) 		    *PUSH D2 INTO STACK
	ROR.L	#4,D0			    *SHIFT TO RIGHT 4 BITS
	SUBQ    #1,D1               *SUBTRACT COUNTER BY 1
	CMPI    #0,D1               *COMPARE THE COUNTER WITH 0
	BGE     HEXCONVERTER_LOOP1	*IF BIGGER OR EQUAL, BRANCH TO LOOP1 
HEXCONVERTER_LOOP2
	MOVE.B	(A7)+,(A1)+		*STORE ASCII CHARACTER INTO A1
	SUBQ    #1,D3
	CMP     #0,D3               *IF THE VALUE IS BIGGER OR EQUAL D3
	BGE	    HEXCONVERTER_LOOP2	*BRANCH BACK LOOP2
	MOVEM.L	(A7)+,D0	        *POP UP THE DATA BACK TO D0

HEXCONVERTER_QUIT RTS         
            
            
            
*-----------ASCII CONVERT MACHINE----------------------------------
*CONVERT USER INPUT STORED IN ASCII CODE INTO HEX NUMBER AND STORE 
*   IT INTO D2
*A1 STORED THE POINTER OF USER INPUT
*D1 STORED THE LENGTH OF USER INPUT
ASCII_CONVERTER
                MOVEM.L        D0/D2,-(SP)            * LOAD DATA REGISTER INTO STACK
                CLR.L        D3                        * CLEAR ALL DATA STORED IN D2 BEFORE

                CMP.B        #8, D1                        * COMPARE TO MAKE SURE THE INPUT LENGTH LESS THAN 8
                BGT                LEN_ERROR       * THE LENGTH IS GREATER THAN 8, BRANCH TO ERROR
                CMP.B        #0, D1                        * COMPARE TO MAKE SURE THE INPUT LENGTH GREATER THAN 0
                BLE            LEN_ERROR            * THE LENGTH EQUAL 0, BRANCH TO ERROR

*-----------USE THE LENGTH OF USER INPUT IN D1 AS A COUNTER FOR THIS LOOP---------
ASCII_CONVERTER_LOOP        *COMPARE EACH BYTE OF INPUT TO DEFINE IT AS 0-9 OR NOT         
                ROL         #$4, D3                        * shift one byte to the left to reserve next elements
                MOVE.B        (A1)+, D0                * MOVE THE BYTE FROM INPUT TO D0
                CMP.B        #$39, D0                * ASCII CODE (0-9) = (30-39), COMPARE IT TO 39
                BGT            LETTER                * BIGGER THAN 39, IT MAYBE A LETTER, BRANCH TO  
                CMP.B        #$30, D0                * ASCII CODE (0-9) = (30-39), COMPARE IT TO 30
                BLT            LETTER_ERROR        * IF LESS THAN 30, RETURN ERROR WARNING
                SUBI.B        #$30, D0                * ELSE THE INPUT IS VALID, SUBTRACT TO GET THE DECIMAL NUM
                BRA            ASCII_DONE

LETTER
                CMP.B        #$66, D0                * IF ASCII NUM > 66(LOWER CASE F IN HEX), INVALID
                BGT            LETTER_ERROR        * RETURN WARNING MESSAGE
                CMP.B        #$61, D0                * IF 61>= VALUE, IT MAY BE A LOWER CASE ASCII CHARACTER 
                BGE            ASCII_LOWER_LET        * BRANCH LOWER CASE 
                
                *HANDLING THE LOWER CASE ISSUE FOR ASCII CHARACTER
                CMP.B        #$46, D0                * IF THE VALUE>46, IT IS INVALID
                BGT            LETTER_ERROR        * RETURN ERROR WARNING MESSAGE
                CMP.B        #$41, D0                * IF THE VALUE<41, IT IS INVALID
                BLT            LETTER_ERROR        * RETURN WARNING MESSAGE
                SUBI.B        #$37, D0                * ELSE, IT IS VALID, SUBTRACT 37
                BRA            ASCII_DONE      
        
ASCII_LOWER_LET
                SUBI.B        #$57, D0            *SUBTRACT 57 IF LOWER CASE CHARACTER
                BRA            ASCII_DONE          *BRANCH TO FINISH THE SUBROUTINE
        
ASCII_DONE
                OR.B        D0, D3                                * OR the results into the return value
                SUBI    #$1,D1                  * DECREMENT THE LOOP COUNTER
                CMP.B   #$0,D1                  * COMPARE IF COUNTER IS 0
                BNE     ASCII_CONVERTER_LOOP        * IF THE COUNTER IS NOT 0, BRANCH BACK THE LOOP
                MOVEM.L        (SP)+,D0/D2                    * POP OUT THE STACK
                RTS                                            * BACK TO THE PROGRAM
        
        
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
START_PROMPT        DC.B    'PLEASE INPUT THE STARTING ADDRESS GREATER THAN $0000A000: ',$0  
END_PROMPT            DC.B        'PLEASE INPUT THE ENDING ADDRESS LESS THAN $000FFFFF: ',$0
CONTINUE_PRO        DC.B        'TAP ENTER KEY TO CONTINUE... ',$0 
PRO_DONE            DC.B        'DONE! THANKS FOR RUNING THIS PROGRAM',$0    
LENGTH_ER       DC.B    'THE SIZE OF MEMORY LOCATION IS OUT OF RANGE',CR,LF,$0
LETTER_ER       DC.B    'INPUT CONTAINS INVALID ELEMENTS',CR,LF,$0

INPUT           DS.L    32   *ALLOCATE TWO LONG SPACE FOR STARTING AND ENDING WORDS
BAD_DATA        DCB.B   256,00  *RESERVE 256 BLOCKS OF BYTE FOR UNDEFINED DATAS
GOOD_DATA       DCB.B   256,00  *RESERVE 256 BLOCKS OF BYTE FOR PASSED DATAS   

DONE
    END         START   


*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
