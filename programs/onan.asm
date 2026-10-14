bits 16

onan:
	mov dx, si
	call clear_screen

	mov si, dx
	call efs_load_file

	push si
	mov si, file_buffer
	call print_str
	pop si

	mov si, file_buffer

.find_null_loop:
	cmp byte [si], 0x00
	je .ready_to_write
	inc si
	jmp .find_null_loop

.ready_to_write:

.loop:
	call keyboard_wait

	cmp ax, 0x1F13
	je .save_exit_file

	cmp al, 0x08
	je .delete_char

	cmp al, 0x0D
	je .enter

	cmp si, file_buffer + 511
	jge .loop

	cmp al, 0x00
	je .loop

	mov [si], al
	inc si
	mov byte [si], 0x00

	push si
	call print_char
	pop si

	jmp .loop

.delete_char:
	cmp si, file_buffer
	je .loop

	cmp [si - 1], 0x0A
	je .delete_enter

	dec si
	mov byte [si], 0x00

	push si
	call keyboard_backspace
	pop si

	jmp .loop

.delete_enter:
	dec si
	mov byte [si], 0x00
	dec si
	mov byte [si], 0x00

	mov di, si

.find_line_start:
	cmp di, file_buffer
	je .line_start_found

	cmp byte [di - 1], 0x0A
	je .line_start_found

	dec di
	jmp .find_line_start

.line_start_found:
	mov bx, si
	sub bx, di
	push bx

	mov ah, 0x03
	mov bh, 0x00
	int 0x10

	cmp dh, 0
	je .cursor_done

	dec dh
	pop bx
	mov dl, bl

	mov ah, 0x02
	mov bh, 0x00
	int 0x10
	jmp .loop

.cursor_done:
	pop bx
	jmp .loop

.enter:
	cmp si, file_buffer + 510
	je .loop

	mov byte [si], 0x0D
	inc si
	mov byte [si], 0x0A
	inc si

	push si
	call print_newline
	pop si

	jmp .loop

.save_exit_file:
	mov si, dx
	call efs_save_file
	call clear_screen
	ret
