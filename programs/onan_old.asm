bits 16

onan:
	movzx ax, dh
	push ax
	movzx ax, dl
	push ax

	mov dx, si
	call clear_screen

	mov si, dx
	call efs_load_file

	mov dl, [file_buffer + 500]
	mov dh, [file_buffer + 501] 

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

	cmp si, file_buffer + 499
	jge .loop

	cmp al, 0x00
	je .loop

	mov [si], al
	inc si
	mov byte [si], 0x00

	inc dl

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

	dec dl

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
	mov bx, si

.find_line_start:
	cmp di, file_buffer
	je .line_start_found

	cmp byte [di - 1], 0x0A
	je .line_start_found

	dec di
	jmp .find_line_start

.line_start_found:
	mov ax, bx
	sub ax, di
	dec ax
	mov cl, al

	mov ah, 0x03
	mov bh, 0x00
	int 0x10

	cmp dh, 0
	je .loop

	dec dh
	mov dl, cl

	mov ah, 0x02
	mov bh, 0x00
	int 0x10

	jmp .loop

.enter:
	cmp si, file_buffer + 498
	je .loop

	mov byte [si], 0x0D
	inc si
	mov byte [si], 0x0A
	inc si

	inc dh
	xor dl, dl

	push si
	call print_newline
	pop si

	jmp .loop

.save_exit_file:
	mov si, file_buffer + 500
	mov byte [si], dl
	inc si
	mov byte [si], dh

	pop ax
	mov dl, al
	pop ax
	mov dh, al

	mov si, dx
	call efs_save_file
	call clear_screen
	ret
