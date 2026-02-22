.model tiny
.code
org 100h

Start:

			mov ax, 0b800h
			mov es, ax

            mov bx, 1632
            mov si, 082h


            mov al, byte ptr [si]


            mov byte ptr es:[bx], al
			mov byte ptr es:[bx+1], 04Fh



			mov ax, 4C00h
			int 21h

end			Start