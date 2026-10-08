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

	dec si
	mov byte [si], 0x00

	push si
	call keyboard_backspace
	pop si

	jmp .loop

.save_exit_file:
	mov si, dx
	call efs_save_file
	call clear_screen
	ret
