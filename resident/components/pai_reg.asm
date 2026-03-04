.model tiny
.code
org 100h

; old_MeM [off, seg, st_pose, l, h, flag]

Start:

            mov ax, 0b800h
            mov es, ax          ; psp

            mov ax, 1A4Fh       ; value for printf
            mov dx, 720         ; start pose

            push ax
            push dx

            call reg_out


            jmp return_0



;===============reg_out===============================

;   func:       reg in vidmem
;   Entry:      znachenie, where
;   Exit:       vid mem
;   Expected:   PSP segment in es = 0b800h
;   Destr:      nothing, all save, but in use

;=====================================================

    reg_out     proc
;{
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push di
    push dx
    push si

    mov ax, [bp + 6]        ; value / always save
    mov bx, ax

    mov dx, [bp + 4]        ; start pose

    xor cx, cx              ; sch for L or R of half_reg
    mov di, 1

    mov si, 10              ; for RAM

 ;__________________________

  right_of:
        and bl, 0Fh 
        cmp bl, 0Ah

        jb num_metka        ; bl < 0Ah => number

        add bl, 'A'         ; letter
        sub bl, 10          ; to ASCIII

        call paint_s
        jmp next_al_l

    num_metka:
        add bl, '0'         ; number
        call paint_s
        jmp next_al_l


  next_al_l:
        mov bx, ax          ; renessans of start reg
        shr bx, 4           ; 10 = bl ---> 01 = bl 
        inc cx              ; sch that al is been ready
        cmp cx, di
        je right_of         ; di = 1 for start

        mov cx, word ptr cs:old_MeM[si]  ; in initialisation time flag is zero
        cmp cx, di              ; in start its not equal (cx = 0 |    di = 1 = const)

        mov word ptr cs:old_MeM[si], 1
        mov bl, ah 
        mov al, bl              ; for last operation (when obrabativaem left og ah)

        jne right_of            ; if equal => in memory already 1 = di => uge obrabotali ah (al early ah)


    mov word ptr cs:old_MeM[si], 0
 ;__________________________
    
    pop si
    pop dx
    pop di
    pop cx
    pop bx
    pop ax

    pop bp

    ret 4
    reg_out     endp
;}  



;===============paint_s=============================

;   func:       reg in vidmem
;   Entry:      Expected
;   Exit:       vid mem               |DRAW|
;   Expected:   ES = 0b800h, DX = where, BX = what
;   Destr:      dx UP its good

;=====================================================

    paint_s   proc
;{         
    push di
    mov di, dx

    mov byte ptr es:[di], bl
    mov byte ptr es:[di + 1], 047h  ; white text in red fon

    sub dx, 2


    pop di

    ret

    paint_s   endp
;}



;_____________________________________________________
return_0:
			mov ax, 4C00h
			int 21h


old_MeM    DB 480 DUP(0)


Fin:

end			Start