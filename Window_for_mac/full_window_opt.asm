.model tiny
.code
org 100h

Start:

            jmp Main

Main:

            mov ax, 0b800h
			mov es, ax

            call destroy_memory

            mov si, 082h

            call eat_str

            jmp return_0

;_____________________________________________________



;===============scan_x_y======_style==================

;   func:       from terminal eat x y, then pose = 16x + 160y
;   Entry:      void
;   Exit:       bx = start pose of okno &and& cx == X dx == Y
;   Expected:   PSP segment in si = 082h
;   Destr:      si, bx, cx, ax, dx

;=====================================================

scan_x_y:                         ; space X space Y space
;{
            pop di                ; adreres

            mov cl, byte ptr [si] ; == X
            sub cl, '0'           ; cx == X
            xor ch, ch
            shl cx, 4             ; x = 16x


            inc si
            inc si
            mov dl, byte ptr [si] ; == Y
            sub dl, '0'
            xor dh, dh

            mov bx, dx

            mov ax, bx
            shl ax, 7
            shl bx, 5
            add bx, ax

            add bx, cx

            push di
            ret
;}

;_____________________________________________________



;===============eat_str======_style===================

;   func:       from terminal eat str and if x = 0 y = 0 ==> centr
;   Entry:      void
;   Exit:       void
;   Expected:   PSP segment in si = 082h &and& es = 0b800h
;   Destr:      cx, dx, bx, ax, si

;=====================================================

eat_str:
;{
            pop bp          ; adress

            call scan_x_y

            cmp cx, 0
            je zero_x       ; jump if cx == 0

            jmp skip_zero   ; cx != 0

    zero_x:

            cmp dx, 0       ; jump if dx == 0
            je zero_y

            jmp skip_zero   ; dx != 0

    zero_y:

            push 1632       ; start pose
            push 44         ; len

            call rama_po_xy
            add sp, 4

            mov bx, 1954

            jmp next_p


    skip_zero:

            mov si, 080h

            mov al, byte ptr [si]   ; al == strlen()
            sub al, 5               ; space + X + space + Y + space
            xor ah, ah

            push bx                 ; save registor
            push bx                 ; bx == from scan_x_y
            push ax
            call rama_po_xy

            add sp, 4

            pop bx 

            add bx, 322             ; not need calculate later


    next_p:

            mov si, 080h

            mov al, byte ptr [si]   ; al == strlen()
            sub al, 5               ; space + X + space + Y + space
            xor ah, ah

            shl ax, 1               ; ax = len * 2

            add si, 6               ; on first symbol of str

            mov cx, bx 
            add cx, ax              ; cx > bx for while cycle->

    wheelee:

            mov al, byte ptr [si]
            add si, 1

            mov byte ptr es:[bx], al
			mov byte ptr es:[bx + 1], 03Fh      ; atribut == CONST = cyan (poka chto)

            add bx, 2

            cmp bx, cx
			jb wheelee				; jump if cx > bx

            push bp
            ret 
;}

;_____________________________________________________



;===============rama_po_xy======cdecle=================

;   Entry:      start pose, len of str    
;   Exit:       void
;   Expected:   PSP segment in es = 0b800h
;   Destr:      bx, dx, cx
;   Dscrpt:     paint okno // SAVE BX PLEASE

;======================================================

rama_po_xy:
;{
            push bp
            mov  bp, sp 
 ;_______________________pro_log

            mov dx, [bp + 4]    ; first  param == len of str
            mov bx, [bp + 6]    ; second param == start pose


            mov byte ptr es:[bx], 0DAh    ; left hight
			mov byte ptr es:[bx + 1], 0Fh ; white

            add bx, 2

            shl dx, 1           ; DX = len*2     

            mov cx, dx          ; CX = BX + 2len  
            add cx, bx

    ;----serdechki----
    while_rama:

            mov byte ptr es:[bx], 03h       
			mov byte ptr es:[bx + 1], 08ch

			add bx, 2

			cmp bx, cx
			jb while_rama       ; jump if bx < cx


            mov byte ptr es:[bx], 0BFh       ; right hight
			mov byte ptr es:[bx + 1], 0Fh      ; white


            add bx, 638
            sub bx, dx


            mov byte ptr es:[bx], 0C0h         ; left low
			mov byte ptr es:[bx + 1], 0Fh      ; white

            add bx, 2


            mov cx, bx
            add cx, dx

    ;----pyramid----
    lhw_rama:

			mov byte ptr es:[bx], 01Eh		    ;piramyd up
			mov byte ptr es:[bx + 1], 0Eh		;yellow

			add bx, 2
			
			cmp bx, cx
			jb lhw_rama				; jump if bx > cx

            mov byte ptr es:[bx], 0D9h       ; right low
			mov byte ptr es:[bx+1], 0Fh      ; white

    ;----pikises----

            mov bx, [bp + 6]

            add bx, 160

            mov byte ptr es:[bx], 06h       ; left hight
			mov byte ptr es:[bx+1], 04Fh

            add bx, 2
            add bx, dx

            mov byte ptr es:[bx], 06h       ; right hight
			mov byte ptr es:[bx+1], 04Fh

            add bx, 320

            mov byte ptr es:[bx], 06h       ; right low
			mov byte ptr es:[bx+1], 04Fh

            sub bx, dx
            sub bx, 2

            mov byte ptr es:[bx], 06h       ; left low
			mov byte ptr es:[bx+1], 04Fh

 ;_______________________epi_log
            pop bp
            ret
;}
;_____________________________________________________



;===============destroy_memory======void===============

;   Entry:      void
;   Exit:       void
;   Expected:   PSP segment in es = 0b800h
;   Destr:      ax, bx
;   Dscrpt:     total black screen

;======================================================

destroy_memory:
;{
            mov ax , 3840
            xor bx, bx

    while_wonka:

            mov byte ptr es:[bx], 020h    ; space
	    	mov byte ptr es:[bx + 1], 00h ; black

            add bx, 2

            cmp bx, ax
			jb while_wonka       ; jump if bx < ax

            ret
;}
;_____________________________________________________



;_____________________________________________________
return_0:
			mov ax, 4C00h
			int 21h


end			Start