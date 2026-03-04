.model tiny
.code
org 100h

; old_MeM [off, seg, st_pose, l, h, flag]

Start:
            jmp Main

Main:

            xor ax, ax
			mov es, ax

            ; offs segm
            ; 0000 0000
            mov bx, 4 * 09h             ; sdvig 09h^ inter = 4b

 ;          save old interrupt in old_MeM
            xor si, si

            mov ax, es:[bx]
            mov word ptr cs:old_MeM[si], ax

            mov ax, es:[bx + 2]
            mov word ptr cs:old_MeM[si + 2], ax
 ;

            ; replace int09h to func irritator9 <=> its change offset ot new segment
            cli                         

            mov es:[bx], offset irritator9    ; mine offset
            mov es:[bx + 2], cs               ; start of mine segment

            sti


            mov dx, offset Fin          ; smeschenie 
            add dx, 480                 ; S for save ramka in mem // 14 * 11 * 2 + N / 16 ==0 = 320
            shr dx, 4                   ; byte -> paragraph
            inc dx                      ; +1 for not zero div

            mov ax, 3100h               ; interrpt for save in memory code // unlimited use 
            int 21h                     ; need sixe of programm in dx in paragraph

;_____________________________________________________




;===============irritator9============================

;   func:       hook 6 and than show window of registors
;   Entry:      void
;   Exit:       vid mem
;   Expected:   void
;   Destr:      nothing, all save, but in use  //ax, bx, dx, es//

;=====================================================

    irritator9      proc
;{

            push ax                     ; save regs for use
            push bx
            push dx
            push es
            push si

            mov ax, 0b800h
			mov es, ax

            xor ax, ax
            in al, 60h                  ; al = scan from klava

            mov dx, 07h                 ; dx = 6 ?
            mov si, 0Ah                 ; si = 9 ? 

            cmp dx, ax
            je  half_true               ; if press ___6___ drawing

            cmp si, ax 
            je  clear_wind              ; if prtss ___9___ clear

            jmp retern_dominion_int9


    half_true:
    ;{
            push 320
            push 14
            push 11

            call Save_mem   ; s l h 

            push 9          ; h
            push 320        ; start pose
            push 12         ; len

            call rama_po_xy
            add sp, 6


            jmp Next_irri
    ;}

    clear_wind:
    ;{
            cmp byte ptr es:[1118], 0bah
            jne clean_black

            call Renessans

            jmp Next_irri

        clean_black:
            call destroy_memory
            jmp Next_irri
    ;}

    retern_dominion_int9:
    ;{
            ; int succes
            in al, 61h
            or al, 80h                  ; 10000000b
            out 61h, al
            and al, not 80h
            out 61h, al


            mov al, 20h                 ; End Of Interrpt
            out 20h, al

            pop si
            pop es
            pop dx
            pop bx
            pop ax

            push si

        ;
            xor si, si

            mov bx, word ptr cs:old_MeM[si]             ; offset = bx
            mov dx, word ptr cs:old_MeM[si + 2]         ; segment = dx

            pop si

            push dx
            push bx
            retf                        ; jmp to real int9
        ;
            iret
    ;}

    Next_irri:
    ;{
            ; int succes
            in al, 61h
            or al, 80h                  ; 10000000b
            out 61h, al
            and al, not 80h
            out 61h, al


            mov al, 20h                 ; End Of Interrpt
            out 20h, al

            pop si
            pop es
            pop dx
            pop bx
            pop ax

            iret
    ;}

    irritator9      endp    
;}
;_____________________________________________________



;===============Save_mem======pascal==================

;   Entry:      start pose, len of str, hight
;   Exit:       void
;   Expected:   void
;   Destr:      void
;   Dscrpt:     save memory for destroy and renessans

;=====================================================

    Save_mem    proc ;( s pose, len , hight )
;{
            push bp             ; save regs
            mov bp, sp
                            
            push ax             
            push bx
            push dx
            push es
            push di
            push cx
            push si

            mov ax, 0b800h
            mov es, ax          ; ES = VM

            mov ax, [bp + 4]    ; AX = h
            mov dx, [bp + 6]    ; dx = l
            mov bx, [bp + 8]    ; BX = s
            shl dx, 1

            xor cx, cx          ; CX = free
            xor di, di          ; di = frfr
            xor bp, bp

            xor si, si
            mov word ptr cs:old_MeM[si + 4], bx ; s
            mov word ptr cs:old_MeM[si + 6], dx ; l*2
            mov word ptr cs:old_MeM[si + 8], ax ; h

            add si, 12
 ;_____________________

            jmp while_len

    while_hight:

            add bx, 160
            sub bx, dx

            xor di, di      ; zero schetchik

        while_len:
            
                mov cl, byte ptr es:[bx]
                mov byte ptr cs:old_MeM[si], cl

                mov ch, byte ptr es:[bx + 1]     
                mov byte ptr cs:old_MeM[si + 1], ch


                add bx, 2
                add si, 2

                add di, 2             ; iterr for len

                cmp di, dx
                jb while_len          ; jump if di < dx

                inc bp                ; bp ++ < ax = h 

                cmp bp, ax
                jb while_hight        ; jump if cx < ax

 ;_____________________
            pop si
            pop cx
            pop di
            pop es              ; cashback regs
            pop dx
            pop bx
            pop ax

            pop bp

            ret 6               ; 3 param * 2

    Save_mem    endp
;}
;_____________________________________________________



;===============Renessans======style==================

;   Entry:      void
;   Exit:       void
;   Expected:   old_MeM [off, seg, st_pose, l, h, flag]
;   Destr:      void
;   Dscrpt:     paint saved okno from mem

;=====================================================

    Renessans   proc
;{
            push bp                          
            push ax             
            push bx
            push dx
            push es
            push di
            push cx
            push si          

            mov ax, 0b800h
            mov es, ax              ; ES = VM

            xor si, si
            mov bx, word ptr cs:old_MeM[si + 4]     ; bx = s
            mov dx, word ptr cs:old_MeM[si + 6]     ; dx = l*2
            mov ax, word ptr cs:old_MeM[si + 8]     ; ax = h

            add si, 12

            xor bp, bp
            xor di, di
            
            jmp while_len_ren
 ;_____________________

    while_hight_ren:

            add bx, 160
            sub bx, dx

            xor di, di      ; zero schetchik

        while_len_ren:
            
                mov cl, byte ptr cs:old_MeM[si]
                mov byte ptr es:[bx], cl

                mov ch, byte ptr cs:old_MeM[si + 1]
                mov byte ptr es:[bx + 1], ch


                add bx, 2
                add si, 2

                add di, 2             ; iterr for len

                cmp di, dx
                jb while_len_ren          ; jump if di < dx

                inc bp                ; bp ++ < ax = h 

                cmp bp, ax
                jb while_hight_ren        ; jump if cx < ax

 ;_____________________

            pop si
            pop cx
            pop di
            pop es              ; cashback regs
            pop dx
            pop bx
            pop ax

            pop bp

            ret

    Renessans      endp 
;}
;_____________________________________________________



;===============destroy_memory======void===============

;   Entry:      void
;   Exit:       void
;   Expected:   PSP segment in es = 0b800h
;   Destr:      none
;   Dscrpt:     black screen

;======================================================

destroy_memory:
;{
            push ax bx

            mov ax , 3680
            xor bx, bx

    while_wonka:

            mov byte ptr es:[bx], 020h    ; space
	    	mov byte ptr es:[bx + 1], 00h ; black

            add bx, 2

            cmp bx, ax
			jb while_wonka       ; jump if bx < ax

            pop bx ax

            ret
;}
;_____________________________________________________



;===============rama_po_xy======cdecle================

;   Entry:      start pose, len of str, hight
;   Exit:       void
;   Expected:   PSP segment in es = 0b800h
;   Destr:      void
;   Dscrpt:     paint okno // SAVE BX PLEASE

;=====================================================

rama_po_xy:
;{
            push bp
            mov  bp, sp 

            push bx
            push dx
            push cx
            push ax
            push si

 ;_______________________pro_log

            mov dx, [bp + 4]    ; first  param == len of str
            mov bx, [bp + 6]    ; second param == start pose
            mov ax, [bp + 8]    ; h

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

    ;----fon----
            xor si, si
 while_hight_rama:

            add bx, 160
            mov cx, bx
            sub bx, dx

            sub bx, 2
            mov byte ptr es:[bx], 06h       ;pikmis
			mov byte ptr es:[bx + 1], 04Fh    
            add bx, 2  

    while_fon:

            mov byte ptr es:[bx], 00h       
			mov byte ptr es:[bx + 1], 0C0h  ; color fon

            add bx, 2

            cmp bx, cx
			jb while_fon       ; jump if bx < cx 

            
            mov byte ptr es:[bx], 06h       
			mov byte ptr es:[bx + 1], 04Fh   

            inc si

            cmp si, ax 
            jb while_hight_rama

    ;----pyramid----
            add bx, 160
            mov cx, bx
            sub bx, dx

            sub bx, 2
            mov byte ptr es:[bx], 0C0h       
			mov byte ptr es:[bx + 1], 0Fh    
            add bx, 2  
    
    lhw_rama:

			mov byte ptr es:[bx], 01Eh		    ;piramyd up
			mov byte ptr es:[bx + 1], 0Eh		;yellow

			add bx, 2
			
			cmp bx, cx
			jb lhw_rama				; jump if bx > cx

            mov byte ptr es:[bx], 0D9h       ; right low
			mov byte ptr es:[bx+1], 0Fh      ; white

 ;_______________________epi_log

            pop si
            pop ax
            pop cx
            pop dx
            pop bx

            pop bp
            ret
;}
;_____________________________________________________



old_MeM    DB 480 DUP(0)


Fin:

end			Start