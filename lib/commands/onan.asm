bits 16

command_onan:
	inc si

	push si
	push di

	mov di, current_filename

.copy_name:
    lodsb
    stosb
    cmp al, 0
    jne .copy_name
    pop di
    pop si


	call onan
	ret
