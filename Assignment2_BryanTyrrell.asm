; Single Cycle Computer (SCC) Assignment 2a
; Created by <Bryan Tyrrell>
; Creation date: <20/02/2019>
; viciLogic Single Cycle Computer: https://www.vicilogic.com/static/ext/SCC/
;
; Description
; This program counts up in near 1 second intervals and shows the count 
; value on the 7 segment display if the user asserts right or left
; a 4 bit paddle in memory address 83h will move either right or left
;
; ASSEMBLY INSTRUCTION      ; DECRIPTION
main:
  CALL SETUP;               ; SetUp Function to set initial regiester values
  CALL PaddleControl        ; Run main paddle control loop indefinitely 
  END





SETUP:                      ; Set up paddle function
  MOVDPTR 000Ah             ; move hex address Ah to SFR15
  XOR R3,R3,R3              ; good pratice to clear the register before using them for the first time
  MOVSFRR R3, SFR15         ; move hex value Ah from sfr15 to R3this will be the paddle row address
  XOR R2,R2,R2              ; good pratice to clear the register before using them for the first time
  SETBR R2, 6               ; Set bit at index 6 in R2 to 1 this is creating the initial 4 bit paddle
  SETBR R2, 7               ; Set bit at index 7 in R2 to 1 this is creating the initial 4 bit paddle
  SETBR R2, 8               ; Set bit at index 8 in R2 to 1 this is creating the initial 4 bit paddle
  SETBR R2, 9               ; Set bit at index 9 in R2 to 1 this is creating the initial 4 bit paddle
  MOVBAMEM @R3, R2          ; This writes the paddle value in R2(03C0h) to memory address 10 in stack memory

  INV R0, R0                ; Inverts R0 from all 0s to 1s 
  CLRBR R0, 15              ; Change bit at index 15 to 0
  CLRBR R0, 4               ; Change bit at index 4 to 0
  CLRBR R0, 0               ; Change bitat index  0 to 0 the value in r0 is now (7FEEh)

  MOVDPTR 17Ch              ; Move the hex value 17Ch to SFR15
  MOVSFRR R1, SFR15         ; Then move the value(17Ch) in SFR15 to R1
RET;



PaddleControl:
NOP
PaddleControlLoop:          ; This paddlecontrol loop will run infinitly
  CALL TimerCount           ; CALL TimerCount subroutine
  CALL IncrementNumber      ; Increment the second count in memory
  CALL MovePaddle           ; Check if the input port (R4) is asserted high and if so move paddle
  XOR R7,R7,R7              ; Clear the R7 value to all zeros

  JZ R7, PaddleControlLoop  ; Since the R7 value will be 0 it will jump back to the begining of the loop

  RET;


TimerCount:                 ; TimerCount Function label
  MOVRR R6, R1              ; Sets initial count value 17Ch from R1 to R6
OuterLoop:                  ; Enter the outer count loop
  DEC R6, R6                ; Decrement R(6) by 1
  MOVRR R5, R0              ; Sets initial count value 7FEEh from R0 to R6
InnerLoop:                  ; Enter inner count loop
  DEC R5, R5                ; Decrement R(5) by 1

  JNZ R5, InnerLoop 	     ; Jump back to InnerLoop if R(5) > 0(Counts 32767 times each time) 

  JNZ R6, OuterLoop         ; Jump back to OuterLoop if R(6) > 0(counts 381 times)

  RET                       ; END program/return


IncrementNumber:            ; IncrementNumber Function label 
  SETBSFR SFR5, 0           ; Set bit 0 in SFR to 1 this will turn on the first LED
  MOVDPTR 0083h             ; I used hex address 83h to store the memory count value
  MOVSFRR R5, SFR15         ; Since R5 has counted to 0 store the memory address in it
  MOVAMEMR R6, @R5          ; R6 has also counted to 0 and can hold the current count value of the system read from memory
  INC R6, R6                ; Increment R6 count value by 1
  MOVBAMEM @R5, R6          ; Write the new count value back to memory address(83h) in R5
  MOVRSFR SFR4, R6          ; Output the new count value to the 7 segment display
  CLRBSFR SFR5, 0           ; Deassert the 0 index in the LED display
  RET

MovePaddle:                 ; MovePaddle Function label
  MOVSFRR R4, SFR12         ; Move the input from user into R4

  JNZ R4, ShiftPaddle       ; If input value has been entered by the user R7 will not be zero and jump to Shift paddle 

  RET                       ; Return
  
ShiftPaddle:                ; ShiftPaddle Function label
  XOR R7,R7,R7              ; Make sure R7 value is 0
  SETBR R7, 10              ; Set bit 10(Right shift) in R7 to one
  AND R7,R4,R7              ; Check if input from R4 and R7 match will return 1 if it does

  JNZ R7,CheckShiftRightWall; If R7 not zero, this means right shift bit is set and jump to CheckShiftRightWall
  
  XOR R7,R7,R7              ; Make sure R7 value is 0
  SETBR R7, 11              ; Set bit 10(left shift) in R7 to one
  AND R7,R4,R7              ; Check if input from R4 and R7 match will return 1 if it does

  JNZ R7,CheckShiftLeftWall ; If R7 not zero, this means right shift bit is set and jump to CheckShiftLeftWall

RET;

CheckShiftRightWall:        ; CheckShiftRightWall Function label(checks if paddle is touching the right wall)
  XOR R7,R7,R7              ; Make sure R7 value is 0
  SETBR R7, 0               ; Set bit at index 0 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
  SETBR R7, 1               ; Set bit at index 1 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
  SETBR R7, 2               ; Set bit at index 2 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
  SETBR R7, 3               ; Set bit at index 3 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
  XOR R7,R2,R7              ; If values match R7 will be 0 else R7 value will not be 0 meaning its not touching the right edge

  JNZ R7,ShiftRight         ; If R7 not 0 jump to ShiftRight

  XOR R4,R4,R4              ; Since right shift has priority clear the input Register R4 as action is complete
RET;

CheckShiftLeftWall:         ; CheckShiftLeftWall Function label 
  XOR R7,R7,R7              ; Make sure R7 value is 0
  SETBR R7, 15              ; Set bit at index 15 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
  SETBR R7, 14              ; Set bit at index 14 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
  SETBR R7, 13              ; Set bit at index 13 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
  SETBR R7, 12              ; Set bit at index 12 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
  XOR R7,R2,R7              ; If values match R7 will be 0 else R7 value will not be 0 meaning its not touching the left edge

  JNZ R7,ShiftLeft          ; If R7 not 0 jump to ShiftLeft

RET;

ShiftRight:                 ; ShiftRight Function label
  SHRL R2, 1                ; Logical shift the paddle 1 bit right
  MOVBAMEM @R3, R2          ; Set the new paddle value in R2 to memory address in R3
RET;

ShiftLeft:                  ; ShiftLeft Function label
  SHLL R2, 1;               ; Logical shift the paddle 1 bit left
  MOVBAMEM @R3, R2          ; Set the new paddle value in R2 to memory address in R3
RET;