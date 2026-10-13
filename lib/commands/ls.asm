command_ls:
	mov si, root_dir

.loop:
	cmp si, root_dir + 512
	jge .end

	cmp byte [si], 0x00
	je .filent

	call print_newline
	xor di, di

.file_name_loop:
	cmp di, 8
	jge .file_ext

	inc di
	inc si

	mov al, [si]
	call print_char

	jmp .file_name_loop

.file_ext:
	mov al, '.'
	call print_char

.file_ext_loop:
	cmp di, 11
	jge .file_finality

	inc di
	inc si

	mov al, [si]
	call print_char

	jmp .file_ext_loop

.file_finality:
	add si, 21
	jmp .loop

.filent:
	add si, 32
	jmp .loop

.end:
	call print_newline
	call print_newline	
	ret
