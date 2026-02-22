.model tiny
.code
org 100h

Start:

			mov ax, 0b800h
			mov es, ax
			mov bx, 0h


			mov ax, 950		


whl:

			mov byte ptr es:[bx], 03h
			mov byte ptr es:[bx+1], 08ch

			add bx, 2
			
			cmp bx, ax
			jb whl				; jump if ax > bx



			mov ax, 4C00h
			int 21h

end			Start