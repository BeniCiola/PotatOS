command_help:
mov di, command_table

.loop:
	mov bx, [di]

	cmp bx, 0
	je .end

	mov si, [di]

	call print_str
	call print_newline

	add di, 4

	jmp .loop

.end:
	ret
