; Single Cycle Computer (SCC) Final Assignment: SCC Game
; Created by <Bryan Tyrrell>
; Creation date: <01/03/2019>
; viciLogic Single Cycle Computer: https://www.vicilogic.com/static/ext/SCC/
; Description
; This game is modelled on space invaders the game.
;The user has the option to place 2 rows of 4,5 or 6 aliens into the game
; the aliens will then move from side to side an drop down one row each time they hit a wall
; the spaceship located in the bottom row will shoot bullets at the aliens and try to kill them
; the goal of the game is to kill the aliens before they reach the row above the spaceship

;
; ASSEMBLY INSTRUCTION      ; DECRIPTION
main:
  CALL SetUp;                      ; SetUp Function to set initial regiester values
  CALL CheckBattleshipMoved        ; Run main loop of the game
  END

SetUp:                             ; Set up function
; alien 2 rows creation this loop will decide the amount of aliens to use in the game
NOP
AlienAmount:                    
  XOR R7,R7,R7                     ; Clear the R7 register
  SETBR R7,15                      ; Set bit 15 in Register 7
  MOVSFRR R6,SFR12                 ; Move SFR 12(Inport register) into R6
  AND R7,R6,R7                     ; AND R6 and R7 to check if the MSB is set in the inPort
  JNZ R7,SixAliensInARow           ; If it is set then the R7 register will not be 0 and six aliens should be used
  SETBR R7,14
  AND R7,R6,R7
  JNZ R7,FiveAliensInARow          ; In this case 5 aliens should be used
  SETBR R7,13
  AND R7,R6,R7
  JNZ R7,FourAliensInARow          ; In this case 4 aliens should be used
  JZ R7,AlienAmount                ; If none of the bits have been set then the system will jump backt ot he start of the loop




SixAliensInARow:                   ; This will set six aliens in each row(2 rows) 
  MOVDPTR 07E0h                    ; LOAD 07E0 into row SFR 15
  MOVSFRR R6, SFR15                ; Move 07E0 into R6
  MOVDPTR 001Fh                    ; LOAD 1Fh(31) the memory address into row sfr 15
  MOVSFRR R7, SFR15                ; Move 1Fh into R7
  MOVBAMEM @R7, R6                 ; Move the top row of into row 1Fh in memory
  DEC R7,R7                        ; decrement the row one place
  MOVRR R2,R7                      ; this register will remember the aliens row address
  MOVRR R5,R6                      ; Move the aliens into R5 from R6
  MOVBAMEM @R7, R5                 ; second row of aliens
  JNZ R7,SpaceshipSetUp            ; Once finsihed jump to SpaceShipSetUp

FiveAliensInARow:
  MOVDPTR 03E0h             
  MOVSFRR R6, SFR15         
  MOVDPTR 001Fh
  MOVSFRR R7, SFR15
  MOVBAMEM @R7, R6
  DEC R7,R7
  MOVRR R2,R7
  MOVRR R5,R6
  MOVBAMEM @R7, R5
  JNZ R7,SpaceshipSetUp

FourAliensInARow:
  MOVDPTR 01E0h
  MOVSFRR R6, SFR15
  MOVDPTR 001Fh
  MOVSFRR R7, SFR15
  MOVBAMEM @R7, R6
  DEC R7,R7
  MOVRR R2,R7
  MOVRR R5,R6
  MOVBAMEM @R7, R5
  JNZ R7,SpaceshipSetUp

SpaceshipSetUp:
; Now set up the space ship
  MOVDPTR 000Ch             ; LOAD Ch the memory address into row sfr 15
  MOVSFRR R7, SFR15         ; Move C into R7
  SETBR R4,8                ; sets the spaceship
  MOVBAMEM @R7, R4          ; Moves spaceship to memory
; and finally the interrupt
  INV R0, R0                ; Inverts R0 from all 0s to 1s

  MOVDPTR 180h              ; Move the hex value 180h to SFR15
  MOVSFRR R1, SFR15         ; Then move the value(180h) in SFR15 to R1


  MOVRSFR SFR9, R1         ; Then move the value(17Ch) in R1 to SFR9(TMRH_LDVAL)
  MOVRSFR SFR8, R0         ; Then move the value(17Ch) in R0 to SFR8(TMRL_LDVAL)
  MOVRSFR SFR2, R1         ; Then move the value(17Ch) in R1 to SFR2(TMRH)
  MOVRSFR SFR1, R0         ; Then move the value(17Ch) in R0 to SFR1(TMRL)


  MOVDPTR 79h              ; Move the hex value 79h(1111001) to SFR15
  MOVSFRR R7, SFR15        ; Then move the value(79h) in SFR15 to R7
  MOVRSFR SFR0, R7         ; Then move the value(79h) in R7 to SFR0

; R3: sets the direction of the aliens 1 moves them left 0 moves them right
  SETBR R3, 0              ; The index 0 is set to 1 which will move the aliens left to start with

  XOR R7,R7,R7             ; set up is finsihed clear the registers for first use
  XOR R1,R1,R1
  XOR R0,R0,R0
  RET                      ; Set up loop finished jump back to call function




InterruptLoop:          ; This will run the interrupt loop
  NOP
ORG 116;
  CALL MoveAliens      ; Moves the aliens
  RETI;

  RET;

MoveAliens:
  NOP
CheckIfbulletInAliensFlagSet:
  XOR R7,R7,R7 
  SETBR R7,7
  AND R7,R3,R7
  JNZ R7,CheckIfBulletHitAliensSecondRow
  JZ R7,CheckIfAliensShiftedDown
  ; else the bullet is in the first row of the aliens
CheckIfBulletHitAliensSecondRow:

       XOR R7,R7,R7                 ; clears R7
       ; get bullet out of first row
          MOVDPTR 0021h             ; LOAD 21h the memory address into row sfr 15(this is where bullet position in the row address is kept)
          MOVSFRR R7, SFR15         ; Move 21h into R7
          MOVAMEMR R6,@R7           ; gives the position in the row the bullet is stored in from memory
          MOVAMEMR R7,@R2           ; moves first row of aliens into register R2
          XOR R7,R6,R7              ; XOR R6 and R7 to to remove the bullet from the first row of aliens
          MOVBAMEM @R2,R7           ; Move the first row of aliens back to memory with the bullet removed
          XOR R7,R7,R7              ; Clear R7 for its next use
       ; check if the row is shifting left,right or down 
       RightWallCheckForSecondRow:  ; Checks if the aliens are touching the right wall for the second row
         MOVAMEMR R6,@R2            ; Moves the alien row into R6
         SETBR R7, 0                ; Sets bit 0 of R7
         AND R7,R6,R7               ; AND the value R6 and R7 to check ifthe aliens are touching the wall
         JZ R7,LeftWallCheckForSecondRow  ; if its 0 then they are not touching the right wall and switch to left wall check
         JNZ R7,TouchingRightWallDropDown ; else they are touching the right wall and jump to the right wall aliens drop down code

      LeftWallCheckForSecondRow:    ; checks if the alien rows like above touching the wall but in the case the leftside wall
        SETBR R7, 15                
        MOVAMEMR R6,@R2
        AND R7,R6,R7
        JZ R7,NoWallsShiftRightOrLeft;  
        JNZ R7,TouchingLeftWallDropDown
     
      NoWallsShiftRightOrLeft:     ; if it reaches this point in the code then its not touching either wall and the aliens need to be shifted left or right
        SETBR R7, 0                ; Set bit 0 of R7
        AND R7,R3,R7               ; AND it with r3 to see which was the aliens are moving  
        JZ R7,MoveAliensRightSecondRow  ; if R7 is 0 then aliens are moving Right
        JNZ R7,MoveAliensLeftSecondRow  ; if R7 is 1 then aliens are moving left
        
      MoveAliensRightSecondRow:     ; this label move sthe aliens right 
          MOVRR R4,R2               ; moves the address of the bottom row of aliens from R2 to R4
          INC R4,R4                 ; increments R4 once so that the second row of aliens is being referenced
          MOVAMEMR R6,@R4           ; gets aliens second row from memory
          MOVDPTR 0021h             ; LOAD 21h the memory address into row sfr 15
          MOVSFRR R7, SFR15         ; Move 21 into R4
          MOVAMEMR R5,@R7           ; gives the position in the row the bullet is stored in
          ROTR R6,1                 ; rotates the aliens right one position
          AND R7,R6,R5              ; ANDs the bullet and the shifted row to check for collision
          JZ R7,NoCollision         ; 0 means no collision
          JNZ R7,Collision          ; 1 means a collision
         
      MoveAliensLeftSecondRow:      ; just like above but the aliens are rotated left one place
          MOVRR R4,R2
          INC R4,R4
          MOVAMEMR R6,@R4
          MOVDPTR 0021h
          MOVSFRR R7, SFR15
          MOVAMEMR R5,@R7
          ROTL R6,1
          AND R7,R6,R5
          JZ R7,NoCollision
          JNZ R7,Collision
     
      Collision:        ; this is the collision label for the bullet and aliens in the second row
      CLRBR R3,5        ; clear fire flag in R3(index 5)
      CLRBR R3,7        ; clear second row flag(Index 7) as bullet is no longer in the first row    
      MOVSFRR R7,SFR4   ; move the count value into R7 from SFR4
      INC R7,R7         ; increment it once
      MOVRSFR SFR4,R7   ; Mve the new value back to SFR4
      XOR R6,R5,R6      ; clear both registers for next action
      XOR R7,R7,R7
      SETBR R7,0        ; now check the direction the row was moving
      AND R7,R3,R7      ; AND R3 and R7 to get the value of the movement flag
      JZ R7,MoveAliensBackRightSecondRow  ; if aliens have been moved right then shift them one place back left
      JNZ R7,MoveAliensBackLeftSecondRow  ; if aliens have been moved left then shift them one place back right
      MoveAliensBackRightSecondRow:        ; this method rotates the second row of aliens back right one position
            ROTL R6,1                      ; Rotate R6 which contains the second row of aliens right left one place
            MOVBAMEM @R4,R6                ; write the value back to memory
            JNZ R4,OriginalAlienPosition   ; Since its finished just to the original alien position method 
      MoveAliensBackLeftSecondRow:         ; Same as above but rotating back right one position
            ROTR R6,1
            MOVBAMEM @R4,R6
            JNZ R4,OriginalAlienPosition
      
      OriginalAlienPosition:               ; this label sets the index 12 in R3 to say that a second row check has just occured
      SETBR R3,12                          ; set bit 12 in R3
      JNZ R3,CheckIfAliensShiftedDown      ; just to the move functon for the aliens

      NoCollision:                         ; this is the label for no collision occuring
        CLRBR R3,7                         ; clear the second row flag as the bullet is no longer in the second row
        INC R4,R4                          ; this puts the row address for the bullet as one row past the aliens
        MOVBAMEM @R4,R5                    ; writes bullets new position to screen
        MOVDPTR 0020h                      ; LOAD 20h the memory address into row sfr 15
        MOVSFRR R7, SFR15                  ; Move 20 into R4
        MOVBAMEM @R7,R4                    ; gives the row the bullet is stored in
        SETBR R3,12                        ; sets the index 12 in R3 so the system knows to exit after movesing the aliens once
        JNZ R3,CheckIfAliensShiftedDown

     TouchingRightWallDropDown:           ; this label runs if the aliens are toching a right wall
       SETBR R3,12                        ; sets the index 12 in R3 so the system knows to exit after movesing the aliens once
       CLRBR R3,7                         ; clear the second row flag as the bullet is no longer in the second row
       MOVRR R4,R2                        ; moves the aliens bottom row address to R4 from R2
       INC R4,R4                          ; Increments R4 by one position to reference the top row of aliens
       MOVAMEMR R6,@R4                    ; gets aliens second row
       MOVDPTR 0021h                      ; LOAD 21h the memory address into row sfr 15
       MOVSFRR R7, SFR15                  ; Move 21 into R4
       MOVAMEMR R5,@R7                    ; gives the bullet psotion in the row its stored in
       AND R7,R6,R5                       ; AND The aliens second row and bullet to chekc if a collision has occured
       JZ R7,NoCollisionDropDown          ; Jump to no collision
       JNZ R7,CollisionDropDown           ; Jump to collision
      
       
       ;JNZ R3,CheckIfAliensShiftedDown
     TouchingLeftWallDropDown:           ; Same as above but with right row
       SETBR R3,12
       CLRBR R3,7
       MOVRR R4,R2
       INC R4,R4
       MOVAMEMR R6,@R4 
       MOVDPTR 0021h
       MOVSFRR R7, SFR15
       MOVAMEMR R5,@R7
       AND R7,R6,R5
       JZ R7,NoCollisionDropDown
       JNZ R7,CollisionDropDown

     CollisionDropDown:            ; this label is run if a collision occurs when aliens are dropping down a single row
      CLRBR R3,5                   ; clear fire flag 
      CLRBR R3,7                   ; clear second row flag
      MOVSFRR R7,SFR4              ; Increment the counter by moving its current value into R7
      INC R7,R7                    ; Increment the counter one position
      MOVRSFR SFR4,R7              ; Move the new count value back to SFR4
      XOR R6,R5,R6                 ; XOR the aliens and the bullet 
      XOR R7,R7,R7
      MOVBAMEM @R4,R6              ; write aliens back to memory
      MOVDPTR 0020h                ; LOAD 20h the memory address into row sfr 15 this is the bullet row address
      MOVSFRR R4, SFR15            ; Move 20 into R4
       MOVAMEMR R7,@R4             ; gives the row the bullet is stored in
      XOR R0,R0,R0                 ; Clear R0
      MOVBAMEM @R7,R0              ; Move R0 into where the bullet row was as the bullet is finished
      SETBR R3,12                  ; put flag so it will exit after moving the system
      JNZ R3,CheckIfAliensShiftedDown  ; run the move aliens label


     NoCollisionDropDown:
        CLRBR R3,7                ; clear second row flag
        INC R4,R4                 ; this puts the row address past the alien rows
        MOVBAMEM @R4,R5           ; writes bullets new position to screen
        MOVDPTR 0020h             ; LOAD 20h the memory address into row sfr 15
        MOVSFRR R7, SFR15         ; Move 20 into R4
        MOVBAMEM @R7,R4           ; gives the row the bullet is now stored in
        SETBR R3,12               ; put flag so it will exit after moving the system
        JNZ R3,CheckIfAliensShiftedDown ; jumps to the alien move label
       

     


CheckIfAliensShiftedDown:   ; this method checks if the alien ros have been shifted down last cycle
  XOR R7,R7,R7              ; clear r7 for use
  SETBR R7,2                ; set bit 2 of r7
  AND R7,R3,R7              ; AND R3 and R7 to check if the ALiens have just been shifted down one row
  JZ R7,LeftWallCheck       ; if false it will jump to the check wall command
  CLRBR R3,2                ;else its true and clear the move flag bit in direction vector R2
  JNZ R7,MoveAliensLeft     ; jump directly to the move command

LeftWallCheck:              ; this label checks if the aliens are touching the left wall
  SETBR R7, 15              ; set bit at index 15
  MOVAMEMR R6,@R2           ; Move the aliens row to R6
  AND R7,R6,R7              ;AND R7 and R6 to check if one of the alien rows is touching the edge
  JNZ R7,ShiftAliensDownLeftWall ;If it is then jump to the shift aliens down label
  SETBR R7, 15              ;else set bit at index 15
  MOVRR R4,R2               ; Move the Aliens row address to R4 from R2
  INC R4,R4                 ; increment the address by one to access the second row
  MOVAMEMR R6,@R4           ; Move the second alien row to R6
  AND R7,R6,R7              ; check if r6 the top alien rows is touching the edge
  JZ R7,RightWallCheck      ; if no then jump to right wall check

ShiftAliensDownLeftWall:     ;if its not 0 then its on the aliens are on right wall and drop the rows by one and clear register R3 alien direction
  XOR R7,R7,R7              ; clears r7 for use
  INC R2,R2                 ; Incrments the row addres of the aliens in R2
  MOVAMEMR R6,@R2           ; Moves the aliens row into R6
  MOVBAMEM @R2, R7          ; clears the second row of aliens from the screen
  DEC R2,R2                 ; decrements the row address to write the next row of aliens
  MOVAMEMR R5,@R2           ; moves the next row of aliens into R5
  MOVBAMEM @R2, R6          ; Moves second row of aliens back to memory but down a row
  DEC R2,R2                 ; decrements the row address one place futher to write the next row of aliens
  MOVBAMEM @R2, R5          ; Moves first row of aliens back to memory
  CLRBR R3,0                ; CLears the direction the aliens was moving now moving the oppisite direction
  SETBR R3,2                ;SET BIT IN r3 to change direction of the aliens
  XOR R7,R7,R7              ; 
  SETBR R7,12               ; Sets bit 12 in R7
  AND R7,R3,R7              ; ANDS R7 with R3 to check if the second row was just checked for bullet collision
  JNZ R7,GameSpeedCheck     ; If true just to the end label(end of interrupt)
  JZ R3,CheckIfBulletBelowAliensFirstRow ; if not related then check if the bullet is below the first row fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff JNZ- jz

RightWallCheck:   ;Same as above but with right wall check
  SETBR R7, 0
  MOVAMEMR R6,@R2
  AND R7,R6,R7
  JNZ R7,ShiftAliensDownRightWall
  SETBR R7, 0 
  MOVRR R4,R2
  INC R4,R4
  MOVAMEMR R6,@R4
  AND R7,R6,R7 
  JZ R7,MoveAliensLeft;

ShiftAliensDownRightWall:
  XOR R7,R7,R7  
  INC R2,R2
  MOVAMEMR R6,@R2
  MOVBAMEM @R2, R7  
  DEC R2,R2 
  MOVAMEMR R5,@R2
  MOVBAMEM @R2, R6
  DEC R2,R2   
  MOVBAMEM @R2, R5 
  SETBR R3,0 
  SETBR R3,2
  XOR R7,R7,R7
  SETBR R7,12
  AND R7,R3,R7
  JNZ R7,GameSpeedCheck
  JZ R3,CheckIfBulletBelowAliensFirstRow ; if not related then check if the bullet is below the first row fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff JNZ- jz
  RET                       ;  RETURNS FROM THE FUNCTION


MoveAliensLeft:             ; this label moves the two rows of aliens one place to the left
  XOR R7,R7,R7              ; Clear R7 for use
  SETBR R7,0                ; Sets index 0 of R7 to 1
  AND R7,R3,R7              ; And R3 and R7 to check if the direction is moving left or right
  JZ R7,MoveAliensRight     ; if the result is 0 then moe aliens right else below move aliens left
  MOVAMEMR R6,@R2           ; move the first row of aliens into R6
  ROTL R6,1                 ; moves aliens right one place
  MOVBAMEM @R2, R6          ; Moves rotated aliens back to memory
  INC R2,R2                 ; increment the row address to write the next row of aliens into the registers
  MOVAMEMR R5,@R2           ; Moves the aliens from memory into row 5
  ROTL R5,1                 ; rotates the second row of aliens right one place
  MOVBAMEM @R2, R5          ; Moves the second row of aliens back to memory
  DEC R2,R2                 ; moves row address back to starting place
  XOR R5,R5,R5              ; clears bothe registers for next use
  XOR R6,R6,R6
  XOR R7,R7,R7
  SETBR R7,12               ; checks if flag at index 12 was set
  AND R7,R3,R7
  JNZ R7,GameSpeedCheck                ; if it was just to end of interrupt label
  JZ R6,CheckIfBulletBelowAliensFirstRow ;else check if bullet below aliens 

MoveAliensRight:            ; same as above but moves aliens right one place
  MOVAMEMR R6,@R2
  ROTR R6,1
  MOVBAMEM @R2, R6  
  INC R2,R2  
  MOVAMEMR R5,@R2
  ROTR R5,1      
  MOVBAMEM @R2, R5 
  DEC R2,R2    
  XOR R5,R5,R5
  XOR R6,R6,R6
  XOR R7,R7,R7
  SETBR R7,12
  AND R7,R3,R7
  JNZ R7,GameSpeedCheck
  JZ R6,CheckIfBulletBelowAliensFirstRow
  RET;

CheckIfBulletBelowAliensFirstRow: ; this label checks if the bullet is below the aliens this means a collision might happen and needs to be checked

       MOVDPTR 0020h             ; LOAD 20h the memory address into row sfr 15
       MOVSFRR R4, SFR15         ; Move 20 into R4
       MOVAMEMR R7,@R4           ; gives the row the bullet is stored in
       MOVRR R4,R2               ; move the current row the aliens is stored in into R4
       XOR R5,R7,R4              ; XOR the bullet row and the Aaliens row 
       JZ R5,CheckForBulletCollisionFirstRow  ; might be zero as the could be on the samr row after aliens dropped down one row


       MOVDPTR 0020h             ; LOAD 20h the memory address into row sfr 15
       MOVSFRR R4, SFR15         ; Move 20 into R4
       MOVAMEMR R7,@R4           ; gives the row the bullet is stored in
       MOVRR R4,R2               ; move the current row the aliens is stored in into R4
       DEC R4,R4                 ; decrement the row address of the aliens one place to check if bullet is below
       XOR R5,R7,R4              ; XOR the values
       JNZ R5,GameSpeedCheck     ; if its not 0 then the bullet is not below the aliens and jump to end of interrupt loop
       
        CheckForBulletCollisionFirstRow:        ; else bullet is below aliens and check for collision
          MOVDPTR 0021h             ; LOAD 21h the memory address into row sfr 15
          MOVSFRR R4, SFR15         ; Move 21 into R4
          MOVAMEMR R5,@R4           ; moves the bullet position in its row into R5
          MOVAMEMR R4,@R2           ; Moves bottom row of aliens into R4
          AND R0,R4,R5              ; will tell us if a collision has occured between the aliens and the bullet
          JZ R0, NoCollisionFirstRow ; if its zero no collision occured and just to the label
          ;else collision has occured         
          XOR R4,R4,R5              ; XOR the bullet and the aliens together to get the alien wiped
          MOVBAMEM @R2,R4           ; write the new alien row back to memory
          MOVDPTR 0020h             ; LOAD 20h the memory address into row sfr 15
          MOVSFRR R4, SFR15         ; Move 20 into R4
          MOVAMEMR R7,@R4           ; gives the row the bullet is stored in
          MOVRR R4,R2               ; move the aliens row into the register
          XOR R5,R7,R4              ; check if the bullet row and the aliens row are the same 
          CLRBR R3,5                ; clear the firre flag
          JZ R5,GameSpeedCheck      ; if the are then jump to the end

            MOVDPTR 0020h             ; LOAD 20h the memory address into row sfr 15
            MOVSFRR R4, SFR15         ; Move 20 into R4
            MOVAMEMR R7,@R4           ; gives the row the bullet is stored in
            XOR R0,R0,R0              ; clear R0
            MOVBAMEM @R7,R0           ; since the bullet has collided wipe its row in memory
            MOVBAMEM @R4,R0           ; clear the bullet form the screen
            ;CLRBR R3,5
            MOVSFRR R7,SFR4           ; move the count value from sfr4 into R7
            INC R7,R7                 ; increment r7 once
            MOVRSFR SFR4,R7           ; write the new value back to memory
            JNZ R7,GameSpeedCheck     ; jump to the end of the interrupt

           NoCollisionFirstRow:       ; this label run if the bullet is below the aliens but no collision occured
            XOR R4,R4,R5              ; get the new aliens value with the bullet in the row
            MOVBAMEM @R2,R4           ; write the alien row back tomemory
            SETBR R3,7                ; set the bullet in row 1 flag index 7 R3
            MOVDPTR 0020h             ; LOAD 20h the memory address into row sfr 15
            MOVSFRR R4, SFR15         ; Move 20 into R4
            MOVAMEMR R7,@R4           ; gives the row the bullet is stored in
            MOVRR R4,R2               ; moves the row of the aliens to R4 from R2
            XOR R5,R7,R4              ; checks if aliens and bullet on the same row by XORing it
            JZ R5,GameSpeedCheck                 ; If true jump to the end else continue

            MOVDPTR 0020h             ; LOAD 20h the memory address into row sfr 15
            MOVSFRR R4, SFR15         ; Move 20 into R4
            MOVAMEMR R7,@R4           ; gives the row the bullet is stored in
            XOR R0,R0,R0              ; clears R0 to 0
            MOVBAMEM @R7,R0           ; Moves R0 into the bullets old row to wipe it from the screen
            SETBR R3,7                ; set bit to say bullet is in first row
            JNZ R7,GameSpeedCheck     ; jump to the end label 

        

GameSpeedCheck:
   CLRBR R3,12     ;clear bit 12 because interrupt is finished
   CheckIfSpeedUp:     ; this label will check if the aliens should speed up in the game
      XOR R6,R6,R6     ; clear R6 for use
      MOVSFRR R7,SFR4  ; Moves the current score into R7
      SETBR R6,0       ; set bit 0 of R6
      SETBR R6,1       ; Set bit 1 of R6 to give a value of 3
      XOR R6,R7,R6     ; XOR R6 and R7 to check if its 0 then the score is 3 and needs to be speeded up  
      JNZ R6, SECONDCHECK ; ifthe score was not 3 jump to the second check
      MOVDPTR 0190h             ; LOAD 190h the memory address into row sfr 15
      MOVSFRR R1, SFR15         ; Move 190 into R1
      MOVRSFR SFR9, R1          ; Then move the value(190h) in R1 to SFR9(TMRH_LDVAL)
      SECONDCHECK:              ; same as above but for the value 6
      XOR R6,R6,R6
      SETBR R6,0
      SETBR R6,1
      XOR R6,R7,R6
      JNZ R6, THIRDCHECK   
      MOVDPTR 0180h             ; LOAD 180h the memory address into row sfr 15
      MOVSFRR R4, SFR15
      MOVRSFR SFR9, R1
      THIRDCHECK:               ; same as above but for the value 9
      XOR R6,R6,R6
      SETBR R6,0
      SETBR R6,3
      XOR R6,R7,R6
      JNZ R6, IsGameOver 
      MOVDPTR 0179h             ; LOAD 179h the memory address into row sfr 15
      MOVSFRR R4, SFR15 
      MOVRSFR SFR9, R1  

   IsGameOver:                  ; has the user killed all the aliens and won or has the aliens touched the row above the spaceship
      XOR R6,R6,R6              ; clear R6 for use
      INV R6,R6                 ; invert all the bits in R6 to 1s
      MOVAMEMR R7,@R2           ; Move the first  aliens into R7
      AND R6,R7,R6              ; AND the two values together
      JNZ R6,IsGameLost         ; If the aliens not are gone from the first row jump to check if game is lost
      XOR R6,R6,R6              ; same check as above but with second row of aliens
      INV R6,R6
      MOVRR R4,R2
      INC R4,R4
      MOVAMEMR R7,@R4
      AND R6,R7,R6
      JZ R6,GameWon             ; if this row is also 0 then jump to gameWon label
      JNZ R6,IsGameLost         ; else there are aliens remaining and jump to the isGameLost label
   
   GameWon:
     MOVDPTR 0AAAh             ; LOAD 0AAAh the memory address into row sfr 15
     MOVSFRR R6, SFR15         ; Move AAAh into R6
     MOVRSFR SFR4,R6           ; Move R6 into seven segment display
     END                       ; ENd the game


   IsGameLost:                 ; checks if the game is lost
     XOR R6,R6,R6              ; clears the R6
     INV R6,R6                 ; inverts all bits to 1s
     MOVAMEMR R5,@R2           ; move first row of aliens to R5
     AND R6,R5,R6              ; check if any aliens are alive on first row
     JNZ R6,GameLossCheckBottomRow  ; if true then check if bottom row is touching the row above the spaceship
     JZ R6,GameLossCheckTopRow      ; else check if top alien row is touching the row above the spaceship
   
     GameLossCheckBottomRow:
       XOR R6,R6,R6           ; clear R6
       SETBR R6,0             ; Set bit 0 of R6
       SETBR R6,2             ; Set bit 2 of R6
       SETBR R6,3             ; Set bit 3 of R6 this give a value of D in Hex
       XOR R6,R2,R6           ; XOR the value with R2 to check if R2(address of the aliens) is above the spaceship row
       JZ R6,GameLost         ; if true then the game is lost
       JNZ R6,Finished        ; else not true and the game continues

     GameLossCheckTopRow:     ; same as abve but checks for top row of aliens
       MOVRR R4,R2
       INC R4,R4
       XOR R6,R6,R6
       SETBR R6,0
       SETBR R6,2
       SETBR R6,3
       XOR R6,R4,R6
       JZ R6,GameLost
       JNZ R6,Finished

     GameLost:
       INV R6,R6            ; invert all bits of R6
       MOVRSFR SFR4,R6      ; Display FFFF on 7 seg display
     END                    ; End the game

     Finished:              ; this label returns to the call inside the interrupt
     RET;






CheckBattleshipMoved:     ; this is the method thats called from main
  NOP
MovesBattleShip:          ; this loops for infinity between interrupt calls
  NOP
ShootBitAsserted:         ; checks if a bullet has been fired
  XOR R7,R7,R7
  SETBR R7,9              ; sets the index 9 in R3
  MOVSFRR R1,SFR12        ; Moves the value in SFR12(input register) into R1
  AND R7,R1,R7            ; AND R1 and R7 to check if the shoot bit is asserted
  JZ R7,RightOrLeftBitMoveSpaceShipAsserted ; if its 0 then not asserted and move the spaceship 
  JNZ R7,CheckIfBulletFired               ; else shoot a bullet


RightOrLeftBitMoveSpaceShipAsserted:  ; checks if the player wants to move the spaceship right or left 
  XOR R7,R7,R7
  SETBR R7,10                ; set bit 10 in R7
  MOVSFRR R1,SFR12           ; move the value of input sfr into R1
  AND R7,R1,R7               ; AND R1 and R7 to check if bit 10 is asserted
  JNZ R7,CheckRightWall      ; if it is then check the right wall
  XOR R7,R7,R7
  SETBR R7,11                ; else set bit 11 to check if its asserted
  MOVSFRR R1,SFR12           ; move sfr12 into r1
  AND R7,R1,R7               ; AND R1 and R7 to chekc if the bit is asserted
  JNZ R7,CheckLeftWall       ; if true then jump to check left wall
  JZ R7, LoopSection         ; else jump to the loop section 

CheckRightWall:             ; checks if the spaceship is touching the right wall
  MOVDPTR 000Ch             ; LOAD Ch the memory address into row sfr 15
  MOVSFRR R7, SFR15         ; Move C into R7
  MOVAMEMR R4,@R7           ; move the location of the paceship into R4
  SHLL R4,15                ; shift the position L 15 bits
  JZ R4,MoveShipRight       ; if its zero that means its not touching the wall
  JNZ R4,LoopSection        ; else it is touching the right wall and jump to the loop section

CheckLeftWall:              ; same as above for right wall check
  MOVDPTR 000Ch
  MOVSFRR R7, SFR15
  MOVAMEMR R4,@R7
  SHRL R4,15
  JZ R4 ,MoveShipLeft
  JNZ R4,LoopSection

MoveShipRight:              ; this moves the spaceship right
  MOVDPTR 000Ch             ; LOAD Ch the memory address into row sfr 15
  MOVSFRR R7, SFR15         ; Move C into R7
  MOVAMEMR R4,@R7           ; move the spaceship from memory in row C into R4
  ROTR R4,1                 ; rotate the spaceship right 1 position
  MOVBAMEM @R7, R4          ; Moves spaceship back to memory
  JNZ R7,LoopSection        ; jump to loop section

MoveShipLeft:               ; same as above but moving the spaceship left
  MOVDPTR 000Ch         
  MOVSFRR R7, SFR15  
  MOVAMEMR R4,@R7
  ROTL R4,1
  MOVBAMEM @R7, R4    
  JNZ R7,LoopSection

LoopSection:                ; this loop section will loop for a interval of 2000h by 400h and then jump back to the begining of the section
  XOR R1,R1,R1
  XOR R0,R0,R0
  SETBR R1,10               ; 400h
OuterLoop:                  ; Enter the outer count loop
  DEC R1, R1                ; Decrement R1 by 1
  SETBR R0,13               ; sets inner loop to 2000h
InnerLoop:                  ; Enter inner count loop
  DEC R0, R0                ; Decrement R(5) by
  JNZ R0, InnerLoop 	     ; Jump back to InnerLoop if R(5) > 0
  JNZ R1, OuterLoop         ; Jump back to OuterLoop if R(6) > 0
  JZ R1,MovesBattleShip     ; jumps back to top of the loop

  RET;



CheckIfBulletFired:                 ; this label checks if a bullet needs to be shot or moved
  NOP
CheckBulletFired:            ; checks if a bullet needs to be fired 
  XOR R7,R7,R7               ; clear all registers being used
  XOR R4,R4,R4
  XOR R5,R5,R5               
  SETBR R7,5                 ; set bullet fired bit in r7
  AND R7,R3,R7               ; and it with the flag row to check if its set
  JNZ R7,MoveBullet          ; if the bullet flag has been set means a bullet has been fired and move the bullet
  FireBullet:
  MOVDPTR 000Ch             ; LOAD Ch the memory address into row sfr 15
  MOVSFRR R7, SFR15         ; Move C into R7
  MOVAMEMR R4,@R7           ; gets the spaceship point in its row this will be position bullet is fired from
  MOVDPTR 0021h             ; LOAD 21h the memory address into row sfr 15
  MOVSFRR R7, SFR15         ; Move 21h into R7
  MOVBAMEM @R7,R4           ; store bullet row into 21h
  MOVDPTR 000Ch             ; LOAD Ch the memory address into row sfr 15
  MOVSFRR R7, SFR15         ; Move C into R7
  MOVAMEMR R4,@R7           ; gets the spaceship point
  SETBR R3,5                ; set the bit fired flag
  INC R7,R7                 ; Increment the address of row to write to
  MOVBAMEM @R7,R4           ; write bullet to memeory shows on screen
  MOVDPTR 0020h             ; LOAD Dh the memory address into row sfr 15
  MOVSFRR R4, SFR15         ; Move D into R7
  MOVBAMEM @R4,R7           ; store bullet into 20H

MoveBullet:
  NOP
  ; this will loop until the bullet reaches the row below the blocks
  BulletMoveLoop: 
    NOP   
    CheckBulletTopRow:           ; this label checks if the bullet has reached row 31h and wipes it if true
       MOVDPTR 0020h             ; LOAD 20h the memory address into row sfr 15
       MOVSFRR R4, SFR15         ; Move 20 into R4
       MOVAMEMR R7,@R4           ; gives the row the bullet is stored in
       MOVDPTR 001Fh             ; LOAD 1Fh the memory address into row sfr 15
       MOVSFRR R4, SFR15         ; Move 1F into R4
       XOR R1,R4,R7              ; XOR 1F and bullet row address
       JNZ R1,CheckBulletBelowAliens ;if not 0 then not on row 31 and jump to checkBelow aliens
       MOVBAMEM @R4,R1            ; else clear the bullet row
       CLRBR R3,5                 ; clear the bullet fire lag
       JZ R1,CheckBulletFired     ; and jump back to star tloop to fire a new bullet


    CheckBulletBelowAliens:
       MOVDPTR 0020h             ; LOAD 20h the memory address into row sfr 15
       MOVSFRR R4, SFR15         ; Move 20 into R4
       MOVAMEMR R7,@R4           ; gives the row the bullet is stored in
       MOVRR R4,R2               ; moves the aliens row address from R2 to R4
       XOR R7,R7,R4              ; checks if they are on the same row by XOR
       JZ R7,RightOrLeftBitMoveSpaceShipAsserted ; if true then it will jump back to the move paddle section
       MOVDPTR 0020h             ; else LOAD 20h the memory address into row sfr 15
       MOVSFRR R4, SFR15         ; Move 20 into R4
       MOVAMEMR R7,@R4           ; gives the row the bullet is stored in
       MOVRR R4,R2               ;
       DEC R4,R4
       XOR R7,R7,R4              ; checks if the bullet is in the row under the aliens
       JZ R7,RightOrLeftBitMoveSpaceShipAsserted ; if true then it will jump back to the move paddle section


    MoveALiens:               ; this label moves the bullet up one place
    MOVDPTR 0020h             ; LOAD 20h the memory address into row sfr 15
    MOVSFRR R4, SFR15         ; Move 20 into R4
    MOVAMEMR R7,@R4           ; gives the row the bullet is stored in
    MOVAMEMR R5,@R7           ; gets the bullet location
    XOR R1,R1,R1              ; clears R1
    MOVBAMEM @R7,R1           ; clears the bullets last row
    INC R7,R7                 ; increment the row
    MOVBAMEM @R7,R5          ; writes the bullets to the row
    MOVBAMEM @R4,R7          ; writes the new row back to memory
    XOR R7,R7,R7
    JZ R7,RightOrLeftBitMoveSpaceShipAsserted ; this jumps back to check if the spaceship needs to be moved




