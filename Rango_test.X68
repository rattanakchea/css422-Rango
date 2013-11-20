*-----------------------------------------------------------
* Title      : 68K test
* Written by : Team Rango
* Date       : 11/14/2013
* Description: intend to input data into memory location.
*-----------------------------------------------------------

    ORG         $0000A000
START

*-MOVE opcode-----------------------------------
    
    *---MOVE.B
    MOVE.B  #101,D1
    MOVE.B  $48,D2
    MOVE.B  #$AA,D1
    MOVE.B  D1,(A6)+
    MOVE.B  D0,(A2)
    MOVE.B  D0,-(A0)
    MOVE.B  (A1), D1
    MOVE.B  (A1)+,D1
    MOVE.B  -(A1),D1
    MOVE.B  #$40,D2
    MOVE.B  D0,D1
    MOVE.B  D0, $E111
    MOVE.B  D0, $E1234560
 
    *---MOVE.W
    MOVE.W  #1201,D1
    MOVE.W  $418,D2
    MOVE.W  #$ABA,D1
    MOVE.W  D1,(A6)+
    MOVE.W  D0,(A2)
    MOVE.W  D0,-(A0)
    MOVE.W  (A1), D1
    MOVE.W  (A1)+,D1
    MOVE.W  -(A1),D1
    MOVE.W  #$4120,D2
    MOVE.W  D0,D1
    MOVE.W  D0, $AE111
    MOVE.W  D0, $E1234
    
    *---MOVE.L
    MOVE.L  #1201,D1
    MOVE.L  $418,D2
    MOVE.L  #$ABA,D1
    MOVE.L  D1,(A6)+
    MOVE.L  D0,(A2)
    MOVE.L  D0,-(A0)
    MOVE.L  (A1), D1
    MOVE.L  (A1)+,D1
    MOVE.L  -(A1),D1
    MOVE.L  #$4120,D2
    MOVE.L  D0,D1
    MOVE.L  D0, $AE111
    MOVE.L  D0, $E1234
    
*-MOVEA opcode-----------------------------------
    *---MOVEA.W
    MOVEA.W  #%11001,A1
    MOVEA.W  $4180AABB,A2
    MOVEA.W  #$ACAA,A1
    MOVEA.W  21031,A4
    MOVEA.W  D1,A6
    MOVEA.W  A2,A2
    MOVEA.W  D0,A0
    MOVEA.W  (A1), A2
    MOVEA.W  (A1)+,A2
    MOVEA.W  -(A1),A2

    *---MOVEA.L
    MOVEA.L  #%11001,A1
    MOVEA.L  $4180AABB,A2
    MOVEA.L  #$ACAA,A1
    MOVEA.L  21031,A4
    MOVEA.L  D1,A6
    MOVEA.L  A2,A2
    MOVEA.L  D0,A0
    MOVEA.L  (A1), A2
    MOVEA.L  (A1)+,A2
    MOVEA.L  -(A1),A2

*--MOVEM OPCODE--------------------------------------
    MOVEM.L D0-D7/A0-A6,$1234
    MOVEM.L (A5),D0-D2/D5-D7/A0-A3/A6
    MOVEM.W (A7)+,D0-D5/D7/A0-A6
    MOVEM.W D0-D5/D7/A0-A6,-(A7)    
    
         


     END           START





