.MODEL SMALL
.STACK 64

.DATA
    UPPER_WALL_START_ROW DW 30
    UPPER_WALL_START_COL DW 20
    UPPER_WALL_END_ROW DW 35
    UPPER_WALL_END_COL DW 280

    LEFT_WALL_START_ROW DW 35
    LEFT_WALL_START_COL DW 20
    LEFT_WALL_END_ROW DW 190
    LEFT_WALL_END_COL DW 25

    LOWER_WALL_START_ROW DW 185
    LOWER_WALL_START_COL DW 25
    LOWER_WALL_END_ROW DW 190
    LOWER_WALL_END_COL DW 280

    ROCKET_INIT_START_ROW DW 95
    ROCKET_INIT_START_COL DW 281
    ROCKET_INIT_END_ROW DW 125
    ROCKET_INIT_END_COL DW 285

    BALL_INIT_START_ROW DW 120
    BALL_INIT_START_COL DW 260
    BALL_INIT_END_ROW DW 130
    BALL_INIT_END_COL DW 270

    BALL_STATE DW 0                         ; 0:LL  1:UL    2:UR    3:LR
    BALL_COLOR DB 0FH
    DELETE_BALL DB 0

    CIRCLE_BALL_INIT_COL_CENTER dw 125
    CIRCLE_BALL_INIT_ROW_CENTER dw 265
    CIRCLE_BALL_Y_VALUE dw 0
    CIRCLE_BALL_INIT_RADIUS dw 5
    CIRCLE_BALL_DECISION dw 1

    INIT_SCORE DB 0
    INIT_SCORE_LD DB '0'
    INIT_SCORE_HD DB '0'

    MSG_WON DW "You won the game!"
    MSG_LOSE DW "You lost the game!"

.CODE

MAIN PROC FAR
        MOV AX, @DATA
        MOV DS, AX

        CALL CLEAR_SCREEN
        CALL SET_GRAPHIC_MODE

        CALL SET_CURSOR_POSITION_LD
        CALL DRAW_INIT_SCORE_LD
        CALL SET_CURSOR_POSITION_HD
        CALL DRAW_INIT_SCORE_HD

        CALL DRAW_INIT_ROCKET
        CALL DRAW_WALLS
        CALL DRAW_INIT_BALL

    MAIN_KEYPRESS_LOOP:
        MOV AH, 01
        INT 16H                             ; WAIT FOR FIRST KEY PRESS
        JZ MAIN_KEYPRESS_LOOP

        MOV AH, 00                          ; IF USER WANT TO QUIT LET HIM DO THAT
        INT 16H
        CMP AL, 'Q'                         ; Q KEY PRESSED
        JE MAIN_DONE
        CMP AL, 'q'                         ; q KEY PRESSED
        JE MAIN_DONE

        CALL RANDOM_START                   ; MAKE START OF THE GAME RANDOM

    MAIN_LOOP:
        CALL BALL_MOVEMENT

        CMP BALL_STATE, 4                   ; CHECK IF USER WON THE GAME
        JE MAIN_WON
        CMP BALL_STATE, 5                   ; CHECK IF USER LOSE THE GAME
        JE MAIN_LOSE

        MOV AH, 01
        INT 16H                             ; CHECK THE KEY PRESS
        JZ MAIN_LOOP
        CALL CHECK_INPUT
        CMP AL, 'Q'                         ; Q KEY PRESSED
        JE MAIN_DONE
        CMP AL, 'q'                         ; q KEY PRESSED
        JE MAIN_DONE
        JMP MAIN_LOOP

    MAIN_WON:
        MOV AL, 1
        MOV BH, 0
        MOV BL, 0000_1010B                  ; GREEN ON DOS
        MOV CX, 17                          ; MSG LENGTH
        MOV DH, 12
        MOV DL, 12
        PUSH DS
        POP ES
        MOV BP, OFFSET MSG_WON
        MOV AH, 13H
        INT 10H

        MOV AH, 7
        INT 21H                             ; WAIT FOR USER TO SEE MESSAGE
        JMP MAIN_DONE

    MAIN_LOSE:
        MOV AL, 1
        MOV BH, 0
        MOV BL, 0000_0100B                  ; RED ON DOS
        MOV CX, 18                          ; MSG LENGTH
        MOV DH, 12
        MOV DL, 12
        PUSH DS
        POP ES
        MOV BP, OFFSET MSG_LOSE
        MOV AH, 13H
        INT 10H

        MOV AH, 7
        INT 21H                             ; WAIT FOR USER TO SEE MESSAGE
        JMP MAIN_DONE

    MAIN_DONE:
        MOV AX, 4C00H                       ; EXIT TO OPERATING SYSTEM
        INT 21H

MAIN ENDP

CLEAR_SCREEN PROC
        MOV AX, 0600H                       ; SCROLL DOWN
        MOV BH, 07H                         ; SCREEN COLOR
        MOV CX, 0000H                       ; FROM TOP LEFT
        MOV DX, 184FH                       ; TO THE BOTTOM RIGHT
        INT 10H

        RET
ENDP CLEAR_SCREEN

SET_GRAPHIC_MODE PROC
        MOV AH, 00H
        MOV AL, 13H
        INT 10H

        RET
ENDP SET_GRAPHIC_MODE

SET_CURSOR_POSITION_HD PROC
        MOV DH, 2
        MOV DL, 19
        MOV BH, 0
        MOV AH, 2
        INT 10H

        RET
ENDP SET_CURSOR_POSITION_HD

DRAW_INIT_SCORE_HD PROC
        MOV DL, INIT_SCORE_HD
        MOV AH, 2
        INT 21H

        MOV AL, INIT_SCORE
        OUT 199, AL

        RET
ENDP DRAW_INIT_SCORE_HD

SET_CURSOR_POSITION_LD PROC
        MOV DH, 2
        MOV DL, 20
        MOV BH, 0
        MOV AH, 2
        INT 10H

        RET
ENDP SET_CURSOR_POSITION_LD

DRAW_INIT_SCORE_LD PROC
        MOV DL, INIT_SCORE_LD
        MOV AH, 2
        INT 21H

        RET
ENDP DRAW_INIT_SCORE_LD

DRAW_WALLS PROC
        MOV AH, 0CH
        MOV AL, 1111B                       ; WHITE COLOR

    UPPER_WALL:
        MOV DX, UPPER_WALL_START_ROW
    UW_LOOP1:
        MOV CX, UPPER_WALL_START_COL

    UW_LOOP2:
        INT 10H
        INC CX
        CMP CX, UPPER_WALL_END_COL
        JNZ UW_LOOP2
        INC DX
        CMP DX, UPPER_WALL_END_ROW
        JNZ UW_LOOP1

    LEFT_WALL:
        MOV DX, LEFT_WALL_START_ROW
    LW_LOOP1:
        MOV CX, LEFT_WALL_START_COL

    LW_LOOP2:
        INT 10H
        INC CX
        CMP CX, LEFT_WALL_END_COL
        JNZ LW_LOOP2
        INC DX
        CMP DX, LEFT_WALL_END_ROW
        JNZ LW_LOOP1

    LOWER_WALL:
        MOV DX, LOWER_WALL_START_ROW
    LOW_LOOP1:
        MOV CX, LOWER_WALL_START_COL

    LOW_LOOP2:
        INT 10H
        INC CX
        CMP CX, LOWER_WALL_END_COL
        JNZ LOW_LOOP2
        INC DX
        CMP DX, LOWER_WALL_END_ROW
        JNZ LOW_LOOP1

        RET
ENDP DRAW_WALLS

DRAW_INIT_BALL PROC
        mov bx, CIRCLE_BALL_INIT_RADIUS
        sub CIRCLE_BALL_DECISION, bx

    drawcircle:
        mov ah,0ch
        CMP DELETE_BALL, 0
        JE NORMAL_COLOR
        CMP DELETE_BALL, 1
        JE BLACK_COLOR

    NORMAL_COLOR:
        MOV AL, BALL_COLOR                  ; WHITE COLOR
        JMP START_DRAW_CIRCLE

    BLACK_COLOR:
        MOV AL, 0                           ; WHITE COLOR

    START_DRAW_CIRCLE:
        mov cx, CIRCLE_BALL_INIT_RADIUS     ; Octant 1
        add cx, CIRCLE_BALL_INIT_ROW_CENTER ; ( CIRCLE_BALL_INIT_RADIUS + CIRCLE_BALL_INIT_ROW_CENTER,  CIRCLE_BALL_Y_VALUE + CIRCLE_BALL_INIT_COL_CENTER)
        mov dx, CIRCLE_BALL_Y_VALUE
        add dx, CIRCLE_BALL_INIT_COL_CENTER
        int 10h

        mov cx, CIRCLE_BALL_INIT_RADIUS     ; Octant 4
        neg cx
        add cx, CIRCLE_BALL_INIT_ROW_CENTER ; ( -CIRCLE_BALL_INIT_RADIUS + CIRCLE_BALL_INIT_ROW_CENTER,  CIRCLE_BALL_Y_VALUE + CIRCLE_BALL_INIT_COL_CENTER)
        int 10h

        mov cx, CIRCLE_BALL_Y_VALUE         ; Octant 2
        add cx, CIRCLE_BALL_INIT_ROW_CENTER ; ( CIRCLE_BALL_Y_VALUE + CIRCLE_BALL_INIT_ROW_CENTER,  CIRCLE_BALL_INIT_RADIUS + CIRCLE_BALL_INIT_COL_CENTER)
        mov dx, CIRCLE_BALL_INIT_RADIUS
        add dx, CIRCLE_BALL_INIT_COL_CENTER
        int 10h

        mov cx, CIRCLE_BALL_Y_VALUE         ; Octant 3
        neg cx
        add cx, CIRCLE_BALL_INIT_ROW_CENTER ; ( -CIRCLE_BALL_Y_VALUE + CIRCLE_BALL_INIT_ROW_CENTER,  CIRCLE_BALL_INIT_RADIUS + CIRCLE_BALL_INIT_COL_CENTER)
        int 10h

        mov cx, CIRCLE_BALL_INIT_RADIUS     ; Octant 7
        add cx, CIRCLE_BALL_INIT_ROW_CENTER ; ( CIRCLE_BALL_INIT_RADIUS + CIRCLE_BALL_INIT_ROW_CENTER,  -CIRCLE_BALL_Y_VALUE + CIRCLE_BALL_INIT_COL_CENTER)
        mov dx, CIRCLE_BALL_Y_VALUE
        neg dx
        add dx, CIRCLE_BALL_INIT_COL_CENTER
        int 10h

        mov cx, CIRCLE_BALL_INIT_RADIUS     ; Octant 5
        neg cx
        add cx, CIRCLE_BALL_INIT_ROW_CENTER ; ( -CIRCLE_BALL_INIT_RADIUS + CIRCLE_BALL_INIT_ROW_CENTER,  -CIRCLE_BALL_Y_VALUE + CIRCLE_BALL_INIT_COL_CENTER)
        int 10h

        mov cx, CIRCLE_BALL_Y_VALUE         ; Octant 8
        add cx, CIRCLE_BALL_INIT_ROW_CENTER ; ( CIRCLE_BALL_Y_VALUE + CIRCLE_BALL_INIT_ROW_CENTER,  -CIRCLE_BALL_INIT_RADIUS + CIRCLE_BALL_INIT_COL_CENTER)
        mov dx, CIRCLE_BALL_INIT_RADIUS
        neg dx
        add dx, CIRCLE_BALL_INIT_COL_CENTER
        int 10h

        mov cx, CIRCLE_BALL_Y_VALUE         ; Octant 6
        neg cx
        add cx, CIRCLE_BALL_INIT_ROW_CENTER ; ( -CIRCLE_BALL_Y_VALUE + CIRCLE_BALL_INIT_ROW_CENTER,  -CIRCLE_BALL_INIT_RADIUS + CIRCLE_BALL_INIT_COL_CENTER)
        int 10h

        inc CIRCLE_BALL_Y_VALUE

    condition1:
        cmp CIRCLE_BALL_DECISION,0
        jg condition2
        mov cx, CIRCLE_BALL_Y_VALUE
        mov ax, 2
        imul cx
        add cx, 1
        inc cx
        add CIRCLE_BALL_DECISION, cx
        mov bx, CIRCLE_BALL_Y_VALUE
        mov dx, CIRCLE_BALL_INIT_RADIUS
        cmp bx, dx
        ja readkey
        jmp drawcircle

    condition2:
        dec CIRCLE_BALL_INIT_RADIUS
        mov cx, CIRCLE_BALL_Y_VALUE
        sub cx, CIRCLE_BALL_INIT_RADIUS
        mov ax, 2
        imul cx
        inc cx
        add CIRCLE_BALL_DECISION, cx
        mov bx, CIRCLE_BALL_Y_VALUE
        mov dx, CIRCLE_BALL_INIT_RADIUS
        cmp bx, dx
        ja readkey
        jmp drawcircle

    readkey:
        RET
ENDP DRAW_INIT_BALL

DRAW_INIT_ROCKET PROC
        MOV AH, 0CH
        MOV AL, 1111B                       ; WHITE COLOR

    INIT_ROCKET:
        MOV DX, ROCKET_INIT_START_ROW
    IR_LOOP1:
        MOV CX, ROCKET_INIT_START_COL

    IR_LOOP2:
        INT 10H
        INC CX
        CMP CX, ROCKET_INIT_END_COL
        JNZ IR_LOOP2
        INC DX
        CMP DX, ROCKET_INIT_END_ROW
        JNZ IR_LOOP1

        RET
ENDP DRAW_INIT_ROCKET

RANDOM_START PROC
        MOV AH, 00H                         ; interrupts to get system time
        INT 1AH                             ; CX:DX now hold number of clock ticks since midnight

        MOV AX, DX
        XOR DX, DX                          ; MAKE DX ZERO
        MOV CX, 2
        DIV CX                              ; DX CONTAINS A NUMBER BETWEEN 0-8

        MOV BALL_STATE, DX

        RET
ENDP RANDOM_START

CHECK_INPUT PROC
        MOV AH, 0
        INT 16H
        CMP AL, 30D                         ; UP KEY PRESSED
        JE UP_KEYSTROKE
        CMP AL, 'W'                         ; W KEY PRESSED
        JE UP_KEYSTROKE
        CMP AL, 'w'                         ; w KEY PRESSED
        JE UP_KEYSTROKE
        CMP AL, 31D                         ; DOWN KEY PRESSED
        JE DOWN_KEYSTROKE
        CMP AL, 'S'                         ; S KEY PRESSED
        JE DOWN_KEYSTROKE
        CMP AL, 's'                         ; s KEY PRESSED
        JE DOWN_KEYSTROKE
        JMP CI_DONE

    UP_KEYSTROKE:
        CALL SHIFT_UP_ROCKET
        JMP CI_DONE
    DOWN_KEYSTROKE:
        CALL SHIFT_DOWN_ROCKET
        JMP CI_DONE

    CI_DONE:
        RET
ENDP CHECK_INPUT

SHIFT_UP_ROCKET PROC
        MOV AH, 0CH
        MOV BX, 3                           ; WITH ONE INPUT, SHIFT 3 PIXELS

    SUR:
        MOV AL, 0
        MOV DX, ROCKET_INIT_START_ROW
        CMP DX, UPPER_WALL_END_ROW          ; CHECK IF WE REACHED UPPER LIMIT
        JE SUR_DONE

        MOV DX, ROCKET_INIT_END_ROW
        MOV CX, ROCKET_INIT_START_COL
    SUR_LOOP1:
        INT 10H
        INC CX
        CMP CX, ROCKET_INIT_END_COL
        JNZ SUR_LOOP1

        MOV AL, 1111B

        MOV DX, ROCKET_INIT_START_ROW
        MOV CX, ROCKET_INIT_START_COL
    SUR_LOOP2:
        INT 10H
        INC CX
        CMP CX, ROCKET_INIT_END_COL
        JNZ SUR_LOOP2

        DEC ROCKET_INIT_START_ROW
        DEC ROCKET_INIT_END_ROW

        SUB BX, 1
        JNZ SUR

    SUR_DONE:
        RET
ENDP SHIFT_UP_ROCKET

SHIFT_DOWN_ROCKET PROC
        MOV AH, 0CH
        MOV BX, 3                           ; WITH ONE INPUT, SHIFT 3 PIXELS

    SDR:
        MOV AL, 0
        MOV DX, ROCKET_INIT_END_ROW
        CMP DX, LOWER_WALL_START_ROW        ; CHECK IF WE REACHED LOWER LIMIT
        JE SDR_DONE

        MOV DX, ROCKET_INIT_START_ROW
        MOV CX, ROCKET_INIT_START_COL
    SDR_LOOP1:
        INT 10H
        INC CX
        CMP CX, ROCKET_INIT_END_COL
        JNZ SDR_LOOP1

        MOV AL, 1111B

        MOV DX, ROCKET_INIT_END_ROW
        MOV CX, ROCKET_INIT_START_COL
    SDR_LOOP2:
        INT 10H
        INC CX
        CMP CX, ROCKET_INIT_END_COL
        JNZ SDR_LOOP2

        INC ROCKET_INIT_START_ROW
        INC ROCKET_INIT_END_ROW

        SUB BX, 1
        JNZ SDR

    SDR_DONE:
        RET
ENDP SHIFT_DOWN_ROCKET

BALL_MOVEMENT PROC
        MOV CX, BALL_STATE
        CMP CX, 0
        JE CALL_BMLL
        CMP CX, 1
        JE CALL_BMUL
        CMP CX, 2
        JE CALL_BMUR
        CMP CX, 3
        JE CALL_BMLR
        JMP BM_DONE

    CALL_BMLL:
        CALL BMLL
        JMP BM_DONE
    CALL_BMUL:
        CALL BMUL
        JMP BM_DONE
    CALL_BMUR:
        CALL BMUR
        JMP BM_DONE
    CALL_BMLR:
        CALL BMLR

    BM_DONE:
        RET
ENDP BALL_MOVEMENT

BMLL PROC
        MOV DX, CIRCLE_BALL_INIT_COL_CENTER
        MOV CX, 7
        ADD DX, CX
        CMP DX, LOWER_WALL_START_ROW        ; CHECK IF WE HIT LOWER WALL
        JE BMLL_CM_UL                       ; CHANGE MOVEMENT TO UL
        MOV DX, CIRCLE_BALL_INIT_ROW_CENTER
        MOV CX, 7
        SUB DX, CX
        CMP DX, LEFT_WALL_END_COL           ; CHECK IF WE HIT LEFT WALL
        JE BMLL_CM_LR

        MOV DELETE_BALL, 1
        MOV CIRCLE_BALL_INIT_RADIUS, 5
        MOV CIRCLE_BALL_Y_VALUE, 0
        MOV CIRCLE_BALL_DECISION, 1
        CALL DRAW_INIT_BALL

        MOV DELETE_BALL, 0
        MOV CIRCLE_BALL_INIT_RADIUS, 5
        MOV CIRCLE_BALL_Y_VALUE, 0
        MOV CIRCLE_BALL_DECISION, 1
        ADD CIRCLE_BALL_INIT_COL_CENTER, 1
        SUB CIRCLE_BALL_INIT_ROW_CENTER, 1
        CALL DRAW_INIT_BALL

        CALL BM_DELAY
        JMP BMLL_DONE

    BMLL_CM_UL:
        MOV BALL_STATE, 1                   ; CHANGE DIRECTION TO UL
        JMP BMLL_DONE
    BMLL_CM_LR:
        MOV BALL_STATE, 3                   ; CHANGE DIRECTION TO LR
        JMP BMLL_DONE

    BMLL_DONE:
        RET
ENDP BMLL

BMUL PROC
        MOV DX, CIRCLE_BALL_INIT_ROW_CENTER
        MOV CX, 7
        SUB DX, CX
        CMP DX, LEFT_WALL_END_COL           ; CHECK IF WE HIT LEFT WALL
        JE BMUL_CM_UR
        MOV DX, CIRCLE_BALL_INIT_COL_CENTER
        MOV CX, 7
        SUB DX, CX
        CMP DX, UPPER_WALL_END_ROW          ; CHECK IF WE HIT UPPER WALL
        JE BMUL_CM_LL

        MOV DELETE_BALL, 1
        MOV CIRCLE_BALL_INIT_RADIUS, 5
        MOV CIRCLE_BALL_Y_VALUE, 0
        MOV CIRCLE_BALL_DECISION, 1
        CALL DRAW_INIT_BALL

        MOV DELETE_BALL, 0
        MOV CIRCLE_BALL_INIT_RADIUS, 5
        MOV CIRCLE_BALL_Y_VALUE, 0
        MOV CIRCLE_BALL_DECISION, 1
        SUB CIRCLE_BALL_INIT_COL_CENTER, 1
        SUB CIRCLE_BALL_INIT_ROW_CENTER, 1
        CALL DRAW_INIT_BALL

        CALL BM_DELAY
        JMP BMUL_DONE

    BMUL_CM_UR:
        MOV BALL_STATE, 2                   ; CHANGE DIRECTION TO UR
        JMP BMUL_DONE
    BMUL_CM_LL:
        MOV BALL_STATE, 0                   ; CHANGE DIRECTION TO LL
        JMP BMUL_DONE

    BMUL_DONE:
        RET
ENDP BMUL

BMUR PROC
        MOV DX, CIRCLE_BALL_INIT_COL_CENTER
        MOV CX, 7
        SUB DX, CX
        CMP DX, UPPER_WALL_END_ROW          ; CHECK IF WE HIT UPPER WALL
        JE BMUR_CM_LR                       ; CHANGE MOVEMENT TO LR
        MOV DX, CIRCLE_BALL_INIT_ROW_CENTER
        MOV CX, 7
        ADD DX, CX
        CMP DX, ROCKET_INIT_START_COL       ; CHECK IF WE ARE GOING TO HIT ROCKET OR NOT
        JE BMUR_ROCKET_CHECK

        MOV DELETE_BALL, 1
        MOV CIRCLE_BALL_INIT_RADIUS, 5
        MOV CIRCLE_BALL_Y_VALUE, 0
        MOV CIRCLE_BALL_DECISION, 1
        CALL DRAW_INIT_BALL

        MOV DELETE_BALL, 0
        MOV CIRCLE_BALL_INIT_RADIUS, 5
        MOV CIRCLE_BALL_Y_VALUE, 0
        MOV CIRCLE_BALL_DECISION, 1
        SUB CIRCLE_BALL_INIT_COL_CENTER, 1
        ADD CIRCLE_BALL_INIT_ROW_CENTER, 1
        CALL DRAW_INIT_BALL

        CALL BM_DELAY
        JMP BMUR_DONE

    BMUR_CM_LR:
        MOV BALL_STATE, 3                   ; CHANGE DIRECTION TO LR
        JMP BMUR_DONE

    BMUR_ROCKET_CHECK:
        MOV DX, CIRCLE_BALL_INIT_COL_CENTER
        MOV CX, 7
        SUB DX, CX
        CMP DX, ROCKET_INIT_START_ROW
        JNGE BMUR_FAILED
        MOV DX, CIRCLE_BALL_INIT_COL_CENTER
        MOV CX, 7
        ADD DX, CX
        CMP DX, ROCKET_INIT_END_ROW
        JNLE BMUR_FAILED
        JMP BMUR_BALL_HIT

    BMUR_BALL_HIT:
        CALL CHANGE_BALL_COLOR
        CALL INC_AND_PRINT_SCORE
        CMP INIT_SCORE, 30
        JE BMUR_WON
        MOV BALL_STATE, 1                   ; CHANGE DIRECTION TO UL
        JMP BMUR_DONE

    BMUR_WON:
        MOV BALL_STATE, 4                   ; WON THE GAME
        JMP BMUR_DONE

    BMUR_FAILED:
        MOV BALL_STATE, 5
        JMP BMUR_DONE

    BMUR_DONE:
        RET
ENDP BMUR

BMLR PROC
        MOV DX, CIRCLE_BALL_INIT_COL_CENTER
        MOV CX, 7
        ADD DX, CX
        CMP DX, LOWER_WALL_START_ROW        ; CHECK IF WE HIT LOWER WALL
        JE BMLR_CM_UR                       ; CHANGE MOVEMENT TO UR
        MOV DX, CIRCLE_BALL_INIT_ROW_CENTER
        MOV CX, 7
        ADD DX, CX
        CMP DX, ROCKET_INIT_START_COL       ; CHECK IF WE ARE GOING TO HIT ROCKET OR NOT
        JE BMLR_ROCKET_CHECK

        MOV DELETE_BALL, 1
        MOV CIRCLE_BALL_INIT_RADIUS, 5
        MOV CIRCLE_BALL_Y_VALUE, 0
        MOV CIRCLE_BALL_DECISION, 1
        CALL DRAW_INIT_BALL

        MOV DELETE_BALL, 0
        MOV CIRCLE_BALL_INIT_RADIUS, 5
        MOV CIRCLE_BALL_Y_VALUE, 0
        MOV CIRCLE_BALL_DECISION, 1
        ADD CIRCLE_BALL_INIT_COL_CENTER, 1
        ADD CIRCLE_BALL_INIT_ROW_CENTER, 1
        CALL DRAW_INIT_BALL

        CALL BM_DELAY
        JMP BMLR_DONE

    BMLR_CM_UR:
        MOV BALL_STATE, 2                   ; CHANGE DIRECTION TO UR
        JMP BMLR_DONE

    BMLR_ROCKET_CHECK:
        MOV DX, CIRCLE_BALL_INIT_COL_CENTER
        MOV CX, 7
        SUB DX, CX
        CMP DX, ROCKET_INIT_START_ROW
        JNGE BMLR_FAILED
        MOV DX, CIRCLE_BALL_INIT_COL_CENTER
        MOV CX, 7
        ADD DX, CX
        CMP DX, ROCKET_INIT_END_ROW
        JNLE BMLR_FAILED
        JMP BMLR_BALL_HIT

    BMLR_BALL_HIT:
        CALL CHANGE_BALL_COLOR
        CALL INC_AND_PRINT_SCORE
        CMP INIT_SCORE, 30
        JE BMLR_WON
        MOV BALL_STATE, 0                   ; CHANGE DIRECTION TO LL
        JMP BMLR_DONE

    BMLR_WON:
        MOV BALL_STATE, 4                   ; WON THE GAME
        JMP BMLR_DONE

    BMLR_FAILED:
        MOV BALL_STATE, 5
        JMP BMLR_DONE

    BMLR_DONE:
        RET
ENDP BMLR

CHANGE_BALL_COLOR PROC
        MOV AH, 00H                         ; interrupts to get system time
        INT 1AH                             ; CX:DX now hold number of clock ticks since midnight

        MOV AX, DX
        XOR DX, DX                          ; MAKE DX ZERO
        MOV CX, 9
        DIV CX                              ; DX CONTAINS A NUMBER BETWEEN 0-8
        INC DL

        MOV BALL_COLOR, DL

        RET
ENDP CHANGE_BALL_COLOR

INC_AND_PRINT_SCORE PROC
        CMP INIT_SCORE_LD, '9'
        JE IAPS_INC_HD
        INC INIT_SCORE_LD
        CALL SET_CURSOR_POSITION_LD
        CALL DRAW_INIT_SCORE_LD
        JMP IAPS_END

    IAPS_INC_HD:
        INC INIT_SCORE_HD
        MOV INIT_SCORE_LD, '0'
        CALL SET_CURSOR_POSITION_HD
        CALL DRAW_INIT_SCORE_HD
        CALL SET_CURSOR_POSITION_LD
        CALL DRAW_INIT_SCORE_LD

    IAPS_END:
        INC INIT_SCORE
        MOV AL, INIT_SCORE
        OUT 199, AL
        RET
ENDP INC_AND_PRINT_SCORE

BM_DELAY PROC
        MOV CX, 5FFFH

    BM_DELAY_LOOP:
        LOOP BM_DELAY_LOOP

        RET
ENDP BM_DELAY

END MAIN