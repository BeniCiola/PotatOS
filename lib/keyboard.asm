bits 16


COMMAND_BUFF_ERR_OVERFLOW equ 0x1

MSG_BUFF_OVERFLOW db 10, 13, "Error [Buffer Overflow]: The command is too long.", 10, 13, 0

COMMAND_BUFFER_SIZE equ 64
command_buffer:
	times COMMAND_BUFFER_SIZE db 0


buffer_clear:
push si
mov si, command_buffer
.loop:
	cmp si, command_buffer + COMMAND_BUFFER_SIZE
	jae .end

	mov byte [si], 0
	inc si

	jmp .loop

.end:
	pop si
	ret


keyboard_wait:
	xor ah, ah
	int 0x16
	ret


keyboard_backspace:
	cmp si, di
	je .end

	mov al, 0x8	
	call print_char
	mov al, 0x20
	call print_char
	mov al, 0x8
	call print_char

	dec si
	mov byte [si], 0

.end:
	ret

keyboard_command_str:
mov di, command_buffer
mov si, di
call buffer_clear

.loop:
	call keyboard_wait

	cmp al, 0x0D
	je .end

	cmp al, 0x08
	je .delete

	cmp al, 0
	je .loop

	cmp si, command_buffer + COMMAND_BUFFER_SIZE - 1
	jae .overflow

	mov [si], al
	inc si

	call print_char

	jmp .loop

.end:
	mov [si], 0
	mov si, di

	call print_newline

	xor di, di

	ret

.delete:
	call keyboard_backspace
	jmp .loop

.overflow:
	call buffer_clear

	mov si, MSG_BUFF_OVERFLOW
	call print_str

	mov di, COMMAND_BUFF_ERR_OVERFLOW

	ret


; %include "lib/print.asm"
