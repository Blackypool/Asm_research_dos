.model tiny
.code
org 100h

;           0       2       4     6  8        10        12     14          16
; old_MeM [off09, seg09, st_pose, l, h, flag_reg_pant, off1C, seg1C, flag_ramka_out ... 48 = second_ saved mem ... 544 = first_ with ramka]
;                                                                           ax bx cx dx si di bp sp     add to regs
;                                                                           18 20 22 24 26 28 30 32          34

Start:
            jmp Main

Main:

            xor ax, ax
			mov es, ax
            
;_______________________change int09h  seg
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
;_______________________

;_______________________change int01Ch seg
            ; offs segm
            ; 0000 0000
            mov bx, 4 * 01Ch             ; sdvig 09h^ inter = 4b

 ;          save old interrupt in old_MeM
            mov si, 12

            mov ax, es:[bx]
            mov word ptr cs:old_MeM[si], ax

            mov ax, es:[bx + 2]
            mov word ptr cs:old_MeM[si + 2], ax
 ;

            ; replace int01Ch to func trio_buff_1C <=> its change offset ot new segment
            cli                         

            mov es:[bx], offset trio_buff_1C  ; mine offset
            mov es:[bx + 2], cs               ; start of mine segment

            sti
;_______________________

            ; mov bx, 34
            ; mov word ptr cs:old_MeM[bx], 1


            mov dx, offset Fin          ; smeschenie 
            add dx, 1252                ; size of double buff
            shr dx, 4                   ; byte -> paragraph
            inc dx                      ; +1 for not zero div

            mov ax, 3100h               ; interrpt for save in memory code // unlimited use 
            int 21h                     ; need sixe of programm in dx in paragraph

;_____________________________________________________



;===============trio_buff_1C==========================

;   func:       sit on time08h and doing trio_buff
;   Entry:      void
;   Exit:       tiki-tiki-tiki-tiki
;   Expected:   old_MeM [off09, seg09, st_pose, l, h, flag_reg_pant, off1C, seg1C, flag_ramka_out ... 48 = second_ saved mem ... 544 = first_ with ramka]
;   Destr:     

;=====================================================

    trio_buff_1C    proc
;{
            push bp                          
            push ax             
            push bx
            push dx
            push es
            push di
            push cx
            push si          


            mov si, 16
            mov ax, word ptr cs:old_MeM[si]     ; AX = flag of est li ramka now in vmem /// in start flag is zero
            xor si,si

            cmp ax, si      
            je endIk_tb_12  ; frame is otsutstvuet


            mov ax, 0b800h
            mov es, ax                              ; ES = VM

            xor si, si
            mov bx, word ptr cs:old_MeM[si + 4]     ; bx = s
            mov dx, word ptr cs:old_MeM[si + 6]     ; dx = l*2
            mov ax, word ptr cs:old_MeM[si + 8]     ; ax = h

            add si, 544  ; no 48!!! a 544 -- need cmp vmem with first buff, where live frame

            xor bp, bp
            xor di, di
            
            jmp while_len_ren_tb
   ;_____________________

    while_hight_ren_tb:

            add bx, 160
            sub bx, dx

            xor di, di      ; zero schetchik

        while_len_ren_tb:
                mov cl, byte ptr cs:old_MeM[si]
                mov ch, byte ptr es:[bx]
                ; cmp vmem with frame from first buffer
                cmp cl, ch

                jne need_swap_tb_123

                add bx, 2
                add si, 2

                add di, 2                    ; iterr for len

                cmp di, dx
                jb while_len_ren_tb          ; jump if di < dx

            next_ikik_tb:
                inc bp                       ; bp ++ < ax = h 

                cmp bp, ax
                jb while_hight_ren_tb        ; jump if cx < ax

   ;_____________________]

        mov si, 16                          ; flag is update (= 0) if found difference //
        mov ax, word ptr cs:old_MeM[si]
        xor si,si

        cmp ax, si
        je need_update_frame

        jmp endIk_tb      ; with frame all good

   ;________________poooor jmp
    need_swap_tb_123:
        jmp need_swap_tb

    endIk_tb_12:
        jmp endIk_tb

    while_hight_ren_tb_1:
        jmp while_len_ren_tb
   ;_________________

    need_update_frame:

        ;____________paint again

            push 9          ; h
            push 320        ; start posi
            push 12         ; len

            call rama_po_xy
            add sp, 6
        ;

        ;____________first_buff update
            push 320
            push 14
            push 11
            push 544

            call Save_mem   ; s l h s_buff
        ;

        mov bx, 16
        mov word ptr cs:old_MeM[bx], 2      ; paint succes

    endIk_tb:
            pop si
            pop cx
            pop di
            pop es              ; cashback regs
            pop dx
            pop bx
            pop ax

            pop bp

            iret

    while_hight_ren_tb_123:
        jmp while_hight_ren_tb_1

 need_swap_tb:

    sub si, 496     ; write in second buff 
    mov cx, word ptr es:[bx]
    mov word ptr cs:old_MeM[si], cx     ;  faster not new reg, a sub si, 496 ... add si 496
    add si, 496         
    
    push bx
    mov bx, 16
    mov word ptr cs:old_MeM[bx], 0      ; need paint again, because found difference
    pop bx

    add bx, 2
    add si, 2

    add di, 2                           ; iterr for len


    cmp di, dx
    jb while_hight_ren_tb_123           ; jump if di < dx
    jmp next_ikik_tb
    

    trio_buff_1C    endp
;}
;_____________________________________________________



;===============irritator9============================

;   func:       hook 6 and than show window of registors and save ramka in first seg of buffer
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

            mov si, 18
    ;___________________regs_to mem
            ; call swap_er
            mov word ptr cs:old_MeM[si], ax
            mov word ptr cs:old_MeM[si + 2], bx
            mov word ptr cs:old_MeM[si + 4], cx
            mov word ptr cs:old_MeM[si + 6], dx
            mov word ptr cs:old_MeM[si + 10], di
            mov word ptr cs:old_MeM[si + 12], bp
            mov word ptr cs:old_MeM[si + 14], sp

            pop ax          ; ax = old si
            push ax         ; cashback si
            mov si, 26
            mov word ptr cs:old_MeM[si], ax

    ;_____________________
    ;           ax bx cx dx si di bp sp
    ;           18 20 22 24 26 28 30 32


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

            mov si, 16
            mov ax ,word ptr cs:old_MeM[si]
            xor si, si
            cmp ax, si
            jne next_step_chik


        ;____________second_buff for renessans
            push 320
            push 14
            push 11
            push 48

            call Save_mem   ; s l h
        ; 
            push 9          ; h
            push 320        ; start pose
            push 12         ; len

            call rama_po_xy
            add sp, 6

            mov si, 16
            mov bx, 2
            mov word ptr cs:old_MeM[si], bx     ; in 16 = flag of est li ramka now in vmem

            jmp nnnn_
        next_step_chik:
            jmp Next_irri

            jmp nnnn_
        clear_wind:
            jmp clear_wind_2

            nnnn_:

        ;____________first_buff for compare
            push 320
            push 14
            push 11
            push 544

            call Save_mem   ; s l h 
        ;

            jmp Next_irri
    ;}

    clear_wind_2:
    ;{
            call Renessans

            mov si, 16
            mov ax, 0
            mov word ptr cs:old_MeM[si], ax     ; ramku sterli

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

;   Entry:      start pose, len of str, hight, start of RAM
;   Exit:       void
;   Expected:   void
;   Destr:      void
;   Dscrpt:     save memory for destroy and renessans

;=====================================================

    Save_mem    proc
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

            mov ax, [bp + 6]    ; AX = h
            mov dx, [bp + 8]    ; dx = l
            mov bx, [bp + 10]   ; BX = s
            shl dx, 1

            xor cx, cx          ; CX = free
            xor di, di          ; di = frfr

            xor si, si
            mov word ptr cs:old_MeM[si + 4], bx ; s
            mov word ptr cs:old_MeM[si + 6], dx ; l*2
            mov word ptr cs:old_MeM[si + 8], ax ; h

            mov si, [bp + 4]    ; SI = s of RAM

            xor bp, bp
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

            ret 8               ; 3 param * 2

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

            add si, 48

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

            push dx
            push cx
            push ax
            push si
            push bx

 ;_______________________pro_log

            mov dx, [bp + 4]    ; first  param == len of str
            mov bx, [bp + 6]    ; second param == start pose
            push bx             ; save start pose for futurre
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

            pop bx
            push bx
            call paint_all_regs

            pop bx
            pop si
            pop ax
            pop cx
            pop dx

            pop bp
            ret
;}
;_____________________________________________________



;===============paint_all_regs======pascal============

;   Entry:      start pose
;   Exit:       regs in vmem
;   Expected:   PSP segment in es = 0b800h
;   Destr:      void
;   Dscrpt:     paint regs

;=====================================================

    paint_all_regs  proc
;{
        push bp
        mov bp, sp

        push bx     ; where raw
        push si     ; from take
        push cx     ; first letter
        push dx     ; second letter
        push di     ; save ret


        mov si, 18              ; start of regs

        mov bx, [bp + 4]        ; start pose of ramka
        add bx, 164             ; start of buty paint

    ;___________copy_pasta
        push 'A'
        push 'X'
        call go_args_topai

        push 'B'
        push 'X'
        call go_args_topai

        push 'C'
        push 'X'
        call go_args_topai

        push 'D'
        push 'X'
        call go_args_topai

        push 'S'
        push 'I'
        call go_args_topai

        push 'D'
        push 'I'
        call go_args_topai

        push 'B'
        push 'P'
        call go_args_topai

        push 'S'
        push 'P'
        call go_args_topai
    ;_____________________

        pop di
        pop dx
        pop cx
        pop si
        pop bx
        pop bp

        ret 2

    paint_all_regs  endp
;}
;_____________________________________________________



;===============go_args_topai=============pascal======

;   func:       param to paint
;   Entry:      first second letter
;   Exit:       vid mem
;   Expected:   PSP segment in es = 0b800h  // bx = where start // si = from
;   Destr:      bx, si but its all right    // cx but it save

;=====================================================

    go_args_topai   proc
;{
        pop di      ; for ret
        pop cx                  
        pop dx


        mov byte ptr es:[bx], dl
        mov byte ptr es:[bx + 1], 47h

        mov byte ptr es:[bx + 2], cl
        mov byte ptr es:[bx + 3], 47h

        add bx, 8

        mov byte ptr es:[bx], '='
        mov byte ptr es:[bx + 1], 47h

        add bx, 10
        mov ax, word ptr cs:old_MeM[si]
        add si, 2

        push ax
        push bx
        call reg_out
        add bx, 142


        push di
        ret

    go_args_topai   endp
;}



;===============reg_out==================pascal=======

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


old_MeM    DB 1252 DUP(0)


Fin:

end			Start