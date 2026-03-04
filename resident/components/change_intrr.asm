.model tiny
.code
org 100h

Start:
            jmp Main

Main:

            xor ax, ax
			mov es, ax

            ; offs segm
            ; 0000 0000
            mov bx, 4 * 09h             ; sdvig 09h^ inter = 4b
            

            cli                         ; change offset ot new segment

            mov es:[bx], offset New09   ; mine offset
            mov es:[bx + 2], cs         ; start of mine segment

            sti


            pushf                       ; savr flags
            push cs                     ; code segment

            call New09

            mov dx, offset EOPPP        ; smeschenie 
            shr dx, 4                   ; byte -> paragraph
            inc dx                      ; +1 for not zero div

            mov ax, 3100h               ; interrpt for save in memory code // unlimited use 
            int 21h                     ; need sixe of programm in dx in paragraph

;_____________________________________________________


New09       proc

            push ax                     ; save regs
            push bx
            push es

            mov ax, 0b800h
			mov es, ax
            mov bx, (80d * 5 + 40d) * 2 ; mem

            mov ah, 40h                 ; for atribut
            in  al, 60h                 ; al = scan from klava

            mov es:[bx], ax

            ; int succes
            in al, 61h
            or al, 80h                  ; 10000000b
            out 61h, al
            and al, not 80h
            out 61h, al


            mov al, 20h                 ; End Of Interrpt
            out 20h, al

            pop es
            pop bx
            pop ax

            iret

New09       endp      

;_____________________________________________________

EOPPP:

end			Start