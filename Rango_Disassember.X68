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
startAddr   EQU     $0000A000           *require user to input the memory location lower bound
endAddr     EQU     $000FFFFF           *require user to input the memory location upper bound
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
            MOVE.B      #02, D0            * ALLOW TO READ INPUT
            TRAP        #15        
            MOVEA.W #$10,A6   *ID TO RECOGNIZE THIS IS THE ENDING ADDRESS INPUT            
            JSR            ASCII_CONVERTER        *CONVERT THE INPUT TO HEX AND STORE IN D2  
            MOVEA.L D3,A3           *STORE STARTING ADDRESS AT A1

*-----------DISASSEMBLY CODE ---------------------------------------
* CONVERT THE HEXADECIMAL ADDRESS MEMORY TO ASCII 
* THEN, WE CAN PRINT OUT IN THE WINDOW

	MOVE.B	#0, D6		* 
	LEA	GOOD_DATA,A5	* LOAD THE RESERVED SPACE OF PASSED DATA TO A5
	LEA	BAD_DATA,A6	    * LOAD THE RESERVED SPACE OF UNPASSED DATA TO A6
	MOVEA.L  #$FFF00,A7
LOOP_OPCODE	
* READ THE LOCATION MEMORY AND PRINT OUT
	    MOVE.L 	A0, D0		    * COPY MEMORY LOCATION TO D0
	    MOVE.L	#INPUT, A1	    * LOAD THE RESERVED SPACE OF INPUT TO A1
	    JSR	    HEXCONVERTER	* START CONVERTING HEX TO ASCII
        MOVE.W	#$2000,(A1)+    * ADD SPACE
        MOVE.B  #14,D0
        LEA     INPUT,A1
        TRAP    #15
    
        CLR.L	D0		        * CLEAR D0	
	    MOVE.W	(A0)+,D0	    * STORE THE DATA INTO D0 FOR DECODING OPCODE
	    JSR	    DECODE_PART     * JUMP TO DECODE_PART    
	    MOVE.B	#13,D0	        * DISPLAY NULL TERMINATE WITH CR, LF.	 
        LEA	    GOOD_DATA,A1	 
        TRAP	#15		    
	    CMP.L	A0,A3	
	    BLT	    DONE		    * FINISH PROGRAM
	    
	    	                    * check if we have filled a whole screen
	    ADDQ.B	#1, D6		    * increment counter
	    CMP.B	#20, D6	        * check if we have filled the screen
	    BGE	DECODE_SCN_FULL	    * we have filled the screen
	    BRA	    LOOP_OPCODE	    * CONTINUE TO DECODE

DECODE_SCN_FULL 		* A screen worth of output has been printed, prompt user for when ready
	    MOVE.B	#0, D6		* Reset counter
	    MOVE.B	#14, D0	* Load new task number
	    LEA	    CONTINUE_MSG,A1	* Load the string
	    TRAP	#15		* Print the message
	
	* Prompt user to <enter>
	    MOVE.B	#2, D0	        * Load new task number
	    LEA	    INPUT,A1	    * We dont want user to over-ride anything in memory
	    TRAP	#15		        * Prompt for user input
	    BRA	    LOOP_OPCODE 	* Go back to decoding
	
TABLE	JMP	ADDI	        * PREFIX 0000
	    JMP	MOVE_BYTE	    * PREFIX 0001
        JMP	MOVE_LONG	    * PREFIX 0010
	    JMP	MOVE_WORD	    * PREFIX 0011
		
DECODE_REST
	MOVE.L	A5,A2			
	JSR	    FIELD		
	MOVE.L	A2,A5			
	MOVE.B	D4,D1			
	AND.B	#$03,D1		    
	CMP.B	#$00,D1		    * %0000 BYTE?
	BEQ	    BYTE_SIZE
	CMP.B	#$01,D1		    * %0001 WORD?
	BEQ	    WORD_SIZE
	CMP.B	#$02,D1		    * %0010 LONG WORD?
	BEQ	    LONG_SIZE	    
REST_CONT   * KEEP DECODE THE REST OF OPCODE
	JSR 	ALIGN_SP		* ADD SPACE TO FORMAT THE OPCODE
	MOVE.B	D4,D1			* Make a copy of D4
	AND.B	#$78,D1		* isolate bit #2-5
	CMP.B	#$00,D1		* 000 = mode1 (EA,Rn)
	BEQ	OPCODE_MODE1	 
	CMP.B	#$08,D1		* 0001 = mode2 (Rn,EA)
	BEQ	OPCODE_MODE2	
	CMP.B	#$18,D1		* 0011 = mode4 (Rn,Rn)
	BEQ	OPCODE_MODE4	
	CMP.B	#$20,D1		* 0100 = mode5 (#shift,Rn)
	BEQ	OPCODE_MODE5	
	CMP.B	#$28,D1		* 0101 = mode6 (EA)
	BEQ	OPCODE_MODE6	
	CMP.B	#$30,D1		* 0101 = mode7 (EA,EA)
	BEQ	OPCODE_MODE7	
	CMP.B	#$38,D1		* 0101 = mode8 (Dn,An)
	BEQ	OPCODE_MODE8	
	CMP.B	#$40,D1		* 1000 = mode9 (Rn)
	BEQ	OPCODE_MODE9
OPCODE_MODE1
	JSR	EADECODE		* Try to decode the EA
	MOVE.B	#$2C,(A5)+		* Add a comma 
	JSR	OPCODE_PRINTREG		* print the reg
	RTS	
OPCODE_MODE2
	JSR	OPCODE_PRINTREG		* print the reg
	MOVE.B	#$2C,(A5)+		* Add a comma 
	JSR	EADECODE		* Try to decode the EA
	RTS	
OPCODE_MODE4
	JSR	OPCODE_PRINTREG		* print the reg
	MOVE.B	#$2C,(A5)+		* Add a comma 
	MOVE.W	D0,D3			* copy the OPCode to D3 (register)
	ANDI.W	#$0007,D3		* isolate the register data
	JSR	OPCODE_PRINTREG		* print the second reg
	RTS
OPCODE_MODE5
	MOVE.B	#$23,(A5)+		* Add a "#" 
	MOVE.B	#$24,(A5)+		* Add a "$" 
	MOVE.W	D0,D5			* copy the OPCode to D5 (register)
	ANDI.W	#$0007,D5		* isolate the register data
	MOVE.B	D3,D0			* Move D3 (the # of bits to shift) to D0
	MOVE.L	#1,D1			* setup the size (1 byte)
	MOVE.L	A5,A1			* setup the "good" string as the output
	JSR	HEXCONVERTER		* convert the value and add it to the string
	MOVE.L	A1,A5			* update the string pointer
	MOVE.B	#$2C,(A5)+		* Add a comma 
	MOVE.W	D5,D3			* copy the D5 (the register) to D3
	JSR	OPCODE_PRINTREG		* print the reg
	RTS
OPCODE_MODE6
	JSR	EADECODE		* Try to decode the EA
	RTS
OPCODE_MODE7
	* Need to decode 2 EA addresses (MOVE)
	JSR	EADECODE		* Try to decode the EA
	MOVE.B	#$2C,(A5)+		* Add a comma 
	MOVE.W	D0,D5			* copy D0 
	ANDI.W	#%0000111000000000,D5	* isolate bits
	ROR.W	#6,D5			* shift the bits
	ROR.W	#3,D5			* shift the bits
	MOVE.W	D0,D1			* copy D0 
	ANDI.W	#%0000000111000000,D1	* isolate bits
	ROR.W	#3,D1			* shift the bits
	OR.W	D1,D5			* combine the values (in the correct order)
	JSR	EADECODE		* Try to decode the EA
	RTS
OPCODE_MODE8
	* Src register # must be in D3 (Dn)
	*Dst register # must be in D5 (An)
	ORI.B	#%00000100,D4		* set Dn
	JSR	OPCODE_PRINTREG		* print the reg
	MOVE.B	#$2C,(A5)+		* Add a comma 
	MOVE.W	D5,D3			* copy the Dst register to D3
	ANDI.B	#%00000011,D4		* make sure we're set for An
	JSR	OPCODE_PRINTREG		* print the second reg
	RTS
OPCODE_MODE9
	JSR	OPCODE_PRINTREG		* print the reg
	RTS	

BYTE_SIZE
	MOVE.B	#$2E,(A5)+		* ADD A PERIOD 
	MOVE.B	#$42,(A5)+		*  ADD "B"
	JMP	    REST_CONT	
WORD_SIZE
	MOVE.B	#$2E,(A5)+		* ADD "."
	MOVE.B	#$57,(A5)+		* ADD "W"
	JMP	REST_CONT
LONG_SIZE
	MOVE.B	#$2E,(A5)+		* ADD "."
	MOVE.B	#$4C,(A5)+		* Add a "L"
	JMP	REST_CONT

* call this to print the Rn (as specified in D3 and the Rn bit in D4)
OPCODE_PRINTREG
	* D4 = the mode info (Dn/An)
	* D3 = the register number
	MOVE.B	D4,D1			* Make a copy of D4
	AND.B	#%00000100,D1		* isolate bit #3
	CMP.B	#%00000000,D1		* see if bit #3 = false (An)
	BEQ	OPCODE_PRINTREG_An	* if match then print an An
	MOVE.B	#$44,(A5)+		* Add a "D" 
	BRA 	OPCODE_PRINTREG_CONT
OPCODE_PRINTREG_An
	MOVE.B	#$41,(A5)+		* Add a "A" 
OPCODE_PRINTREG_CONT
	ADD.B	#$30,D3			* convert to ascii
	MOVE.B	D3,(A5)+		* Add the number to the string 
	RTS	
* This small function will ensure that the next column lines up correctly
ALIGN_SP
	    MOVE.L	#4,D2			* ADD 4 SPACE BETWEEN THE OPCODE AND DATA
        CMP.B   #01,D7
        BLT	    COUNTER
    	LEA     GOOD_DATA,A5

ALIGN_LOOP
	    MOVE.B	#$20,(A5)+		* ADD SPACE BETWEEN OPCODE AND DATA
	    SUBI    #1,D2
	    CMPI    #$00,D2
	    BNE     ALIGN_LOOP  	* IF COUNTER >0, BRANCH BACK THE ALGIN LOOP
	    RTS
COUNTER MOVE.B  #$01,D7
        BRA     ALIGN_LOOP
**********************************************************************************************
**********************************************************************************************
* OPCODE 
* This function takes a WORD (in D0) and attempts to decode the assembly language instruction.
* The decoded information is added to the string pointed to by A5.  If there is any EA information
* found the DECODEEA function is called.  If an error is encountered a non-zero value will be 
* returned in D7.
*
* A0 = Pointer to the next location in memory
* A5 = Pointer to the end of the "good" string
* D0 = The next opcode to process
* D7 = Error Code (if non-zero) that is returned
*
* Internally:
* D1 = scratch space
* D2 = scratch space
* D3 = Register bits
* D4 = Mode, Dn/An, Size
* D5 = EA bits
DECODE_PART
	MOVEM.L	A1-A4/D1-D6,-(A7)	* Push register data onto the stack so we can restore it at the end
	CLR.L	D7			        * Clear the error code 
	LEA	    TABLE,A1	        * Load up the jump table
	JSR	    OPCODE_DECODE_GET	* Break out the OPCode (only useful if the OPCode is standard)
	CLR.L	D1			        * Clear the temp register
	MOVE.L	D0,D1			    * Copy the opcode into the temp register
	MOVE.B	#12,D2			    * Copy 12 into D2
	LSR.W	D2,D1			    * Left shift D1 by the number of bits in D2
	MULU	#6,D1			    * Multiple D1 by 6
	JSR 	00(A1,D1)		    * Jumps to the decoder for each type of OPCode (first 4 bits)

OPCODE_DONE
	MOVEM.L	(A7)+,A1-A4/D1-D6	* Pop register data off the stack and restore it 
	MOVE.B	#$00,(A5)+		* Terminate the "good" string
	RTS
	
* Call this for instructions with the EA, OPMode, and Register data in standard locations
OPCODE_DECODE_GET
	* Parameters:
	* D0 = the OPCode
	*
	* Returns:
	* D3 = Register bits
	* D4 = OPMode bits
	* D5 = EA bits
	MOVEM.L	D0,-(SP)		* Push register data onto the stack so we can restore it at the end

	MOVE.W	D0,D1			* Copy the OPCode to D1
	ANDI.W	#%0000000000111111,D1	* Get the last 6 bits
	MOVE.B	D1,D5			* copy the EA bits into D5
	
	ROR.W	#6,D0			* Roll the bits right by 6
	MOVE.W	D0,D1			* Copy the OPCode to D1
	ANDI.W	#%0000000000000111,D1	* Get the last 3 bits
	MOVE.B	D1,D4			* copy the OPMode bits into D4
	
	ROR.W	#3,D0			* Roll the bits right by 3
	MOVE.W	D0,D1			* Copy the OPode to D1
	ANDI.W	#%0000000000000111,D1	* Get the last 3 bits
	MOVE.B	D1,D3			* copy the Register bits into D3

	MOVEM.L	(SP)+,D0		* Pop register data off the stack and restore it 
	RTS

FIELD
	MOVEM.L	D1/D2,-(A7)	        * PUSH DATA INTO STACK A7
	CLR.L	D1		
	MOVE.B	%11111111,D1
	LEA     GOOD_DATA,A2        * DONT CHANGE - IT FIXED THE ERROR

FIELD_CON
	MOVE.B	(A1)+,D2	* Copy the next byte into a register
	CMP.B	#$00,D2		* See if we hit a null/end of string
	BNE	    FIELD_CON1	* Go to the end if we're finished
	MOVEM.L	(A7)+,D1-D2	* Pop register data off the stack and restore it 
	RTS	
	
FIELD_CON1
	MOVE.B	D2,(A2)+	* Copy the byte to the dest string
	SUBI    #1,D1
	CMPI    #00, D1
	BNE     FIELD_CON	* If there is more to process, go to the next byte
    MOVEM.L	(A7)+,D1-D2	* Pop register data off the stack and restore it 
	RTS
	
EADECODE	MOVEM.L		D0-D6/A2-A4,-(SP)	; save registers that will be used for things are purely local
;************************************************************************************
		MOVE.L		A5,A1		; copy the good buffer pointer to A1
	;----------------------------------------------------------------
	; SEPARATE THE MODE AND REG
		MOVE.B		D5,D3
		ANDI.B		#%00000111,D3
		ANDI.B		#%00111000,D5
		LSR.B		#3,D5
	;----------------------------------------------------------------
	; A JUMP TABLE
		CMP.B		#0,D5
		BEQ		MODE_ZERO
		CMP.B		#1,D5
		BEQ		MODE_ONE
		CMP.B		#2,D5
		BEQ		MODE_TWO
		CMP.B		#3,D5
		BEQ		MODE_THREE
		CMP.B		#4,D5
		BEQ		MODE_FOUR
		CMP.B		#5,D5
		BEQ		MODE_FIVE
		CMP.B		#6,D5
		BEQ		MODE_SIX
		CMP.B		#7,D5
		BEQ		MODE_SEVEN
	;----------------------------------------------------------------
	; INVALID MODE
		ORI.B		#$02,D7	; FLAG SET
		BRA		END_OP

;*************************************************************************************
; DATA REGISTER DIRECT MODE
; Basic EA that displays a capital 'D' and a number
; ex: D4
MODE_ZERO	ADDI.B		#48,D3		; convert register into number
		MOVE.B		#$44,(A1)+	; add 'D' to the good buffer
		MOVE.B		D3,(A1)+	; add number to the good buffer
		BRA		END_OP		; we have now added D# to the good buffer
;-------------------------------------------------------------------------------------
; ADDRESS REGISTER DIRECT MODE
; Basic EA that displays a capital 'A' and a number
; ex: A2
MODE_ONE	CMP.B		#7,D3		; is reg 7?
		BEQ		SPREGONE
		ADDI.B		#48,D3		; convert register into number
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		MOVE.B		D3,(A1)+	; add number to the good buffer
MONE_X		BRA		END_OP		; we have now added A# to the good buffer
SPREGONE	MOVE.B		#$53,(A1)+	; add 'S'
		MOVE.B		#$50,(A1)+	; add 'P'
		BRA		MONE_X
;-------------------------------------------------------------------------------------
; ADDRESS REGISTER INDIRECT MODE
; Slightly more complicated than the previous EA. Displays 'A' and number in parentheses.
; ex: (A6)
MODE_TWO	MOVE.B		#$28,(A1)+	; add '(' to the good buffer
		CMP.B		#7,D3		; is reg 7?
		BEQ		SPREGTWO
		ADDI.B		#48,D3		; convert register into number
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		MOVE.B		D3,(A1)+	; add number to the good buffer
MTWO_X		MOVE.B		#$29,(A1)+	; add ')' to the good buffer
		BRA		END_OP		; we have now added (A#) to the good buffer
SPREGTWO	MOVE.B		#$53,(A1)+	; add 'S'
		MOVE.B		#$50,(A1)+	; add 'P'
		BRA		MTWO_X
;-------------------------------------------------------------------------------------
; ADDRESS REGISTER INDIRECT WITH POSTINCREMENT MODE
; Slightly more complicated that the previous EA. Displays parenthized 'A' and number with
; a '+' at the end.
; ex: (A1)+
MODE_THREE	MOVE.B		#$28,(A1)+	; add '(' to the good buffer
		CMP.B		#7,D3		; is reg 7?
		BEQ		SPREGTHR
		ADDI.B		#48,D3		; convert register into number
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		MOVE.B		D3,(A1)+	; add number to the good buffer
MTHR_X		MOVE.B		#$29,(A1)+	; add ')' to the good buffer
		MOVE.B		#$2B,(A1)+	; add '+' to the good buffer
		BRA		END_OP		; we have now added (A#) to the good buffer
SPREGTHR	MOVE.B		#$53,(A1)+	; add 'S'
		MOVE.B		#$50,(A1)+	; add 'P'
		BRA		MTHR_X
;-------------------------------------------------------------------------------------
; ADDRESS REGISTER INDIRECT WITH PREDECREMENT MODE
; Similar to the previous EA except with a '-' at the beginning instead of a '+' at the end.
; ex: -(A5)
MODE_FOUR	MOVE.B		#$2D,(A1)+	; add '-' to the good buffer
		MOVE.B		#$28,(A1)+	; add '(' to the good buffer
		CMP.B		#7,D3		; is reg 7?
		BEQ		SPREGFOR
		ADDI.B		#48,D3		; convert register into number
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		MOVE.B		D3,(A1)+	; add number to the good buffer
MFOR_X		MOVE.B		#$29,(A1)+	; add ')' to the good buffer
		BRA		END_OP		; we have now added (A#) to the good buffer
SPREGFOR	MOVE.B		#$53,(A1)+	; add 'S'
		MOVE.B		#$50,(A1)+	; add 'P'
		BRA		MFOR_X
;-------------------------------------------------------------------------------------
; ADDRESS REGISTER INDIRECT WITH DISPLACEMENT MODE
; This is like the ADDRESS REGISTER INDIRECT (parenthized A#) but with a 16bit displacement
; immediately preceding. Negative displacements are actually displayed as negatives.
; ex: $7C49(A3)
; NOTE there are other (not used) acceptable syntax
; -- ($7C49)(A3)
; -- ($7C49,A3)
; NOTE displacements are sign-extended to 32bits
MODE_FIVE	MOVE.W		(A0)+,D0	; read one word from memory into D0
		MOVE.B		#$02,D1		; size of D0 in bytes
	; if the displacement is greater that 7fff then it is negative
		MOVE.W		D0,D6
		ANDI.W		#$8000,D6	; MASK the sign bit
		BNE		ARID_ADJ	; if sign bit is 1 then goto adjuster
ARID_CB		MOVE.B		#$24,(A1)+	; add '$' to the good buffer
		JSR		HEXCONVERTER	; SEND D0 TO FUNCTION TOHEX
		MOVE.B		#$28,(A1)+	; add '(' to the good buffer
		CMP.B		#7,D3		; is reg 7?
		BEQ		SPREGFIV
		ADDI.B		#48,D3		; convert register into number
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		MOVE.B		D3,(A1)+	; add number to the good buffer
MFIV_X		MOVE.B		#$29,(A1)+	; add ')' to the good buffer
		BRA		END_OP		; we have now added [####(A#)]
ARID_ADJ	MOVE.B		#$2D,(A1)+	; add '-' to signify a negative displacement
	; twos complement means flip every bit, and add one
		NOT.W		D0
		ADDQ.W		#1,D0
		BRA		ARID_CB		; resume normal flow
SPREGFIV	MOVE.B		#$53,(A1)+	; add 'S'
		MOVE.B		#$50,(A1)+	; add 'P'
		BRA		MFIV_X
;-------------------------------------------------------------------------------------
; ADDRESS REGISTER INDIRECT WITH INDEX (8-BIT DISP) MODE
; This is similar to the above EA but w/ an addtional figure to add in (an Index). The
; displacement is only 8bits long this time. The index is displayed after a comma inside
; the parentheses. The index is a register dot size. Negative displacements are actually
; displayed as negatives.
; ex: $5B(A6,D4.L)
; NOTE there are other (not used) acceptable syntax
; -- ($5B)(A6,D4.L)
; -- ($5B,A6,D4.L)
; NOTE displacements are sign-extended to 32bits
MODE_SIX	MOVE.W		(A0)+,D0	; read one word into a scratch data register
		MOVE.W		D0,D6		; copy the word
		ANDI.W		#$00FF,D0	; the displacement
		ANDI.W		#$FF00,D6	; the index
		LSR.W		#8,D6		; is moved to lsbp
		MOVE.B		#1,D1		; for counter
	; if the displacement is greater that 7f then it is negative
		MOVE.W		D0,D2		; make copy for anding
		ANDI.L		#$00000080,D2	; MASK sign bit
		BNE		ARII_ADJ
ARII_CB		MOVE.B		#$24,(A1)+	; add '$' to the good buffer
		JSR		HEXCONVERTER	; add the displacement to the good buffer
		; D0 and D2 ARE FREE AGAIN
		MOVE.B		#$28,(A1)+	; add '(' to the good buffer
		CMP.B		#7,D3		; is reg 7?
		BEQ		SPREGSIX
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		ADDI.B		#48,D3		; convert register into number
		MOVE.B		D3,(A1)+	; add number to the good buffer
		; d3 is free
MSIX_X		MOVE.B		#$2C,(A1)+	; add ',' to the good buffer
		LSL.B		#1,D6		; PUSH into x
		BCC		DREG
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		BRA		NXT
DREG		MOVE.B		#$44,(A1)+	; add 'D' to the good buffer
NXT		MOVE.B		D6,D2
		ANDI.B		#$E0,D2
		LSR.B		#5,D2		; IND REG number
		ADDI.B		#48,D2		; convert number to ascii
		MOVE.B		D2,(A1)+	; add number to the good buffer
		MOVE.B		#$2E,(A1)+	; add '.' to the good buffer
		ANDI.B		#$10,D6
		BEQ		SIZB
		MOVE.B		#$4C,(A1)+	; add 'L' to the good buffer
		BRA		NXT2
SIZB		MOVE.B		#$57,(A1)+	; add 'W' to the good buffer
NXT2		MOVE.B		#$29,(A1)+	; add ')' to the good buffer
		BRA		END_OP		;
ARII_ADJ	MOVE.B		#$2D,(A1)+	; add a '-' because the displacement is negative
	; twos complement means flip every bit, and add one
		NOT.B		D0
		ADDQ.B		#1,D0
		BRA		ARII_CB
SPREGSIX	MOVE.B		#$53,(A1)+	; add 'S'
		MOVE.B		#$50,(A1)+	; add 'P'
		BRA		MSIX_X
;-------------------------------------------------------------------------------------
; The following five codes are for when the MODE IS 7 (111)
;-------------------------------------------------------------------------------------
; since mode seven is the only one that has several addressing modes, it is fortunate
; that it is that last one (according to its mode number)
	;----------------------------------------------------------------
	; A JUMP TABLE
MODE_SEVEN	CMP.B		#0,D3
		BEQ		REG_ZERO
		CMP.B		#1,D3
		BEQ		REG_ONE
		CMP.B		#2,D3
		BEQ		REG_TWO
		CMP.B		#3,D3
		BEQ		REG_THREE
		CMP.B		#4,D3
		BEQ		IM_REGISTER
	;----------------------------------------------------------------
	; INVALID REGISTER
		ORI.B		#$01,D7		; FLAG SET
		BRA		END_OP
;-------------------------------------------------------------------------------------
; REG 000 ABSOLUTE SHORT ADDRESSING MODE
REG_ZERO	MOVE.W		(A0)+,D0	; read one word from memory into D0
		MOVE.B		#$02,D1		; size of D0 in bytes
		MOVE.B		#$24,(A1)+	; add '$' to the good buffer
		JSR		HEXCONVERTER	; SEND D6 TO FUNCTION TOHEX
		BRA		END_OP
;-------------------------------------------------------------------------------------
; REG 001 ABSOLUTE LONG ADDRESSING MODE
REG_ONE		MOVE.L		(A0)+,D0	; read one word from memory into D0
		MOVE.B		#$04,D1		; size of D0 in bytes
		MOVE.B		#$24,(A1)+	; add '$' to the good buffer
		JSR		HEXCONVERTER	; SEND D6 TO FUNCTION TOHEX
		BRA		END_OP
;-------------------------------------------------------------------------------------
; REG 010 PROGRAM COUNTER INDIRECT WITH DISPLACEMENT MODE
; displacement is sign-extended
REG_TWO		MOVEA.W		A0,A2		; save a copy of the "PC" of the test program
		MOVE.W		(A0)+,D0	; D0 is current displacement
		ADDQ.L		#2,D0		; D0 is now actual displacement from the calling command
		MOVE.L		D0,D2		; save disp for analysis
		ANDI.L		#$00008000,D0	; mask the sign bit
		BNE		PCID_ADJ	; if disp is negative, then adjust
PCID_CB		ADD.L		A2,D0		; add complete disp to get address with that displacement
		MOVE.L		#$04,D1		; start size of address at long
		MOVE.L		D0,D2		; if first byte is zero, decrease size
		AND.L		#$FF000000,D2
		BNE		SIZEREADY1
		SUBQ.B		#1,D1
		MOVE.L		D0,D2		; if second byte is zero, decrease size
		AND.L		#$00FF0000,D2
		BNE		SIZEREADY1
		SUBQ.B		#1,D1
	; now size has been reduced to prevent unneccessary leading zeros
SIZEREADY1	MOVE.B		#$24,(A1)+	; print '$'
		JSR		HEXCONVERTER	; print address
		MOVE.B		#$28,(A1)+	; print '('
		MOVE.B		#$50,(A1)+	; pring 'P'
		MOVE.B		#$43,(A1)+	; print 'C'
		MOVE.B		#$29,(A1)+	; print ')'
		BRA		END_OP
PCID_ADJ	MOVE.L		#$FFFF0000,D0	; manually sign-extend
		ADD.W		D2,D0		; with adding
		BRA		PCID_CB
;-------------------------------------------------------------------------------------
; REG 011 PROGRAM COUNTER INDIRECT WITH INDEX (8-BIT DISP) MODE ?UNNECESSARY?
; displacement is sign-extended
REG_THREE	ADDI.B		#48,D3		; convert register into number
	; because it is PC
		MOVEA.W		A0,A2		; save a copy of the "PC" of the test program
		MOVE.W		(A0)+,D0	; read one word into a scratch data register
		MOVE.W		D0,D3		; copy the word
		ANDI.W		#$00FF,D0	; D0 is the current displacement
		ADDQ.L		#2,D0		; D0 is now actual displacement from the calling command
		; this is for the displacement
		MOVE.L		D0,D2		; copy disp for anding
		ANDI.L		#$00000080,D0	; mask the sign bit
		BNE		PCII_ADJ	; if negative, then adjust
PCII_CB		ADD.L		A2,D0		; add disp to PC to get address 
		; GOT THE ADDRESS AND D2 IS NOW FREE
		MOVE.L		#$04,D1		; start size of address at long
		MOVE.L		D0,D2		; if first byte is zero, decrease size
		AND.L		#$FF000000,D2
		BNE		SIZEREADY2
		SUBQ.B		#1,D1
		MOVE.L		D0,D2		; if second byte is zero, decrease size
		AND.L		#$00FF0000,D2
		BNE		SIZEREADY2
		SUBQ.B		#1,D1
		; GOT THE CORRECT SIZE OF THE ADDRESS
SIZEREADY2	ANDI.W		#$FF00,D3	; the index
		LSR.W		#8,D3		; is moved to lsbp
		MOVE.B		#$24,(A1)+	; add '$' to the good buffer
		JSR		HEXCONVERTER	; add the displacement to the good buffer
		; D0 IS FREE AGAIN
		MOVE.B		#$28,(A1)+	; add '(' to the good buffer
		MOVE.B		#$50,(A1)+	; add 'P' to the good buffer
		MOVE.B		#$43,(A1)+	; add 'C' to the good buffer
		MOVE.B		#$2C,(A1)+	; add ',' to the good buffer
		LSL.B		#1,D3		; PUSH into x
		BCC		DREG2
		MOVE.B		#$41,(A1)+	; add 'A' to the good buffer
		BRA		NXT11
DREG2		MOVE.B		#$44,(A1)+	; add 'D' to the good buffer
NXT11		MOVE.B		D3,D2		; copy the rest of the index
		ANDI.B		#$E0,D2		; mask number
		LSR.B		#5,D2		; shift
		ADDI.B		#48,D2		; convert
		MOVE.B		D2,(A1)+	; add number to the good buffer
		;NUMBER
		MOVE.B		#$2E,(A1)+	; add '.' to the good buffer
		ANDI.B		#$10,D6		; mask size bit
		BEQ		SIZB1
		MOVE.B		#$4C,(A1)+	; add 'L' to the good buffer
		BRA		NXT12
SIZB1		MOVE.B		#$57,(A1)+	; add 'W' to the good buffer
NXT12		MOVE.B		#$29,(A1)+	; add ')' to the good buffer
		BRA		END_OP		;
PCII_ADJ	MOVE.L		#$FFFFFF00,D0	; manually sign-extend
		ADD.B		D2,D0
		BRA		PCII_CB
*-------------------------------------------------------------------------------------
* SOURCE EFFECTIVE ADDRESS FIELD - MOVE REGISTER 100 IMMEDIATE DATA

IM_REGISTER	
            ANDI.B		#$03,D4	        * BIT SIZE 
		    CMP.B		#$02,D4		    * COMPARE TO SEE IF SIZE IS LONG WORD?
		    BEQ		    NEXT		    * IF SO, WORD SIZE SETTING
    	    MOVE.B		#$02,D1		    * LONG SIZE SETTING
		    MOVE.W		(A0)+,D0	    
		    BRA		    SPECIAL_CHAR	* BRANCH TO ADD SPECIAL CHAR 

NEXT		MOVE.L		(A0)+,D0	    * TAKE LONG WORD FROM MEMORY A0
            MOVE.B		#$04,D1		    * LONG WORD
		    
SPECIAL_CHAR
		    MOVE.B		#$23,(A1)+	    * '#' ADDING 
		    MOVE.B		#$24,(A1)+	    * '$' ADDING
		    JSR		    HEXCONVERTER	* SHIP TO HEX CONVERTER 	    
END_OP      MOVE.L		A1,A5
            MOVEM.L		(SP)+,D0-D6/A2-A4
		    RTS

*------------------------------------------------------------------------------
* A1 = STORED MEMORY LOCATION 
* D0 = STORED VALUE FROM A1
* D1 = STORED THE SIZE OF OPCODE
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

*=============SIZE DEFINE FOR OPCODE========================================

ADDI                        * ADDI (0000)
MOVE_BYTE                   * MOVE.B (0001)
	MOVE.B	#$30,D4		    * SIZE AND MODE DEFINE
	LEA	MOVE,A1		        * GET FIRST 7 BIT
	JMP	    DECODE_REST	    * JUMP BACK TO DECODE THE REST OF OPCODE	
MOVE_LONG	                * MOVE.L (0010) 
    MOVE.B	#$32,D4		    
	MOVE.W	D0,D1			* STORE DECODING DATA TO D1
	ANDI.W	#$F1C0,D1	    * GET FIRST 7 BIT
	LEA	    MOVE,A1		    * LOAD OPCODE MOVE INTO A1
	JMP	    DECODE_REST	    * JUMP BACK TO DECODE THE REST OF OPCODE
	
MOVE_WORD	* MOVE.W (0011)
    MOVE.B	#$31,D4		    
	MOVE.W	D0,D1
	ANDI.W	#$F1C0,D1	    * GET FIRST 7 BIT
	LEA	    MOVE,A1		    * LOAD OPCODE MOVE INTO A1
	JMP	    DECODE_REST	    * JUMP BACK TO DECODE THE REST OF OPCODE

DONE            

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
START_PROMPT    DC.B    'PLEASE INPUT THE STARTING ADDRESS GREATER THAN $0000A000: ',$0  
END_PROMPT      DC.B        'PLEASE INPUT THE ENDING ADDRESS LESS THAN $000FFFFF: ',$0
CONTINUE_PRO    DC.B        'TAP ENTER KEY TO CONTINUE... ',$0 
PRO_DONE        DC.B        'DONE! THANKS FOR RUNING THIS PROGRAM',$0    
LENGTH_ER       DC.B    'THE SIZE OF MEMORY LOCATION IS OUT OF RANGE',CR,LF,$0
LETTER_ER       DC.B    'INPUT CONTAINS INVALID ELEMENTS',CR,LF,$0
INPUT           DS.L    32                  *ALLOCATE TWO LONG SPACE FOR STARTING AND ENDING WORDS
BAD_DATA        DCB.B   200,00              *RESERVE 200 BLOCKS OF BYTE FOR UNDEFINED DATAS
GOOD_DATA       DCB.B   200,00              *RESERVE 200 BLOCKS OF BYTE FOR PASSED DATAS   
DATA	        DC.B	'DATA',$00
MOVE	        DC.B	'MOVE',$00
MOVEA	        DC.B	'MOVEA',$00
UNKNOWN	        DC.B	'DATA',$00
CONTINUE_MSG    DC.B    'PRESS ENTER TO DECODE THE REST OF OPCODE',CR,LF,$0
    END         START   










