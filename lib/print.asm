bits 16

print_str:
cld

.loop:
	lodsb

	test al, al
	jz .done

	call print_char

	jmp .loop

.done:
	ret


print_space:
	mov al, ' '
	call print_char
	ret

print_tab:
	call print_space
	call print_space
	call print_space
	call print_space
	ret

print_newline:
	mov al, 13
	call print_char

	mov al, 10
	call print_char
	ret

print_char:
	mov ah, 0x0E
	int 0x10
	ret
