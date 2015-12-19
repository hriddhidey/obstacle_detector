ORG 00H                                         ; origin
MOV P0,#00000000B                               ; sets P0 as output port
CLR P3.0                                        ; sets P3.0 as output for sending trigger
SETB P3.1                                       ; sets P3.1 as input for receiving echo
MOV TMOD,#00100010B                             ; sets timer1 as mode 2 auto reload timer
MAIN:
MOV A,#38H
ACALL CMND
MOV A,#0CH
ACALL CMND
MOV A,#01H
ACALL CMND
MOV A,#06H
ACALL CMND
MOV A,#80H
ACALL CMND
MOV DPTR,#MYDATA
STRING:
CLR A
MOVC A,@A+DPTR
CJNE A,#'$',STRING1
SJMP WORK
STRING1:
ACALL DISP
INC DPTR
SJMP STRING
WORK: SETB P1.0
MOV TL1,#207                 			; loads the initial value to start counting from
MOV TH1,#207                 			; loads the reload value
MOV A,#00000000B             			; clears accumulator
SETB P3.0                    			;starts the trigger pulse
ACALL DELAY1                 			; give 10uS width for the trigger pulse
CLR P3.0                     			; ends the trigger pulse
HERE: JNB P3.1,HERE          			; loops here until echo is received
BACK: SETB TR1               			; starts the timer1
HERE1: JNB TF1,HERE1    			; loops here until timer overflows (ie;48 count)
CLR TR1                 			; stops the timer
CLR TF1                      			; clears timer flag 1
INC A                        			; increments A for every timer1 overflow 
JB P3.1,BACK                 			; jumps to BACK if echo is still available
MOV R4,A                     			; saves the value of A to R4
ACALL back1                  			; calls the buzzer audio function
ACALL BACK2                  			; Calls the function to display on LCD.
SJMP WORK                    			; jumps to Work

DELAY1:   
MOV R6,#2                    			; 10uS delay
DJNZ R6,$
RET

BACK2:
MOV A,#89H
ACALL CMND
MOV A,R4
ADD A,#0H
DA A
SWAP A
ANL A,#0FH
ORL A,#30H
ACALL DISP
MOV A,R4
ADD A,#0H
DA A
ANL A,#0FH
ORL A,#30H
ACALL DISP
RET

BACK1:   
SUBB A,#10
JNC DOWN
LABEL:
CLR P1.0
ACALL DELAY
SETB P1.0
SJMP OUT

DOWN:
MOV A,R4
SUBB A,#20
JNC DOWN1
LABEL1:
CLR P1.0
ACALL DELAY
ACALL DELAY
SETB P1.0
SJMP OUT

DOWN1:
MOV A,R4
SUBB A,#30
JNC DOWN2
LABEL2:
CLR P1.0
ACALL DELAY
ACALL DELAY
ACALL DELAY
SETB P1.0
SJMP OUT

DOWN2:
MOV A,R4
SUBB A,#40
JNC OUT
LABEL3:
CLR P1.0
ACALL DELAY
ACALL DELAY
ACALL DELAY
ACALL DELAY
SETB P1.0
SJMP OUT
OUT:
RET

DELAY:
MOV R7,#250                                                   ; 1mS delay
DJNZ R7,$
RET

CMND: 
MOV P2,A
CLR P0.6                                                      ;This is the RS bit
CLR P0.5                                                      ;R/W bit
SETB P0.7
CLR P0.7
ACALL DELY
RET

DISP:
MOV P2,A
SETB P0.6
CLR P0.5
SETB P0.7
CLR P0.7
ACALL DELY
RET

DELY:
CLR P0.7
CLR P0.6
SETB P0.5
MOV P2,#0FFH
SETB P0.7
MOV A,P2
JB ACC.7,DELY
CLR P0.7
CLR P0.5
RET

DELAYTRY:
WAIT:
MOV R6,#1
MOV TH0,#0
MOV TL0,#0
SETB TR0
JNB TF0,$
CLR TF0
DJNZ R6,WAIT
RET

MYDATA:
DB 'DISTANCE:$'

END
