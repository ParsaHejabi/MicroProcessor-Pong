.MODEL small
.STACK 256

.DATA
 CIRCLE_BALL_INIT_ROW_CENTER dw 150
 CIRCLE_BALL_INIT_COL_CENTER dw 100
 CIRCLE_BALL_Y_VALUE dw 0
 CIRCLE_BALL_INIT_RADIUS dw 50
 CIRCLE_BALL_DECISION dw 1
.CODE

jmp start
; =========================================
; Basic program to draw a circle
; =========================================
; =========================================
start:
mov ax,@data
mov ds,ax
 mov ah,00                           ; subfunction 0
 mov al,13h                          ; select mode 18
 int 10h                             ; call graphics interrupt
                                     ; ==========================
 mov bx, CIRCLE_BALL_INIT_RADIUS
 sub CIRCLE_BALL_DECISION, bx

drawcircle:
 mov al,1111B
 mov ah,0ch

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
 mov ah,00
 int 16h
 mov AX,4c00h
 int 21h

END Start