.model tiny
.code

org 100h

Start:

			mov ah, 09h			; AH = 9h		
			mov dx, offset	Hello		; DX = &Hello

			int 21h				; intera\ptor
							; *int_t[0x21]
			mov ax, 4c00h

			int 21h

Hello			db 0dh, 'Sky pa\nther$'


end			Start
