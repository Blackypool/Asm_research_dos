.model tiny
.code
org 100h

Start:

			mov ax, 0b800h
			mov es, ax
			mov bx, 3680

			mov ax, 2080

            mov di, 1920

whl:

            mov al, byte ptr es:[bx]
            mov dl, 03Fh

            mov byte ptr es:[di], al
            mov byte ptr es:[di + 1], dl

            add di, 2
            add bx, 2

            cmp di, ax
			jb whl


			mov ax, 4C00h
			int 21h

end			Start
