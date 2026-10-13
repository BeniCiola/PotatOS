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

keyboard_command_backspace:
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
    call keyboard_command_backspace
    jmp .loop

.overflow:
    call buffer_clear

    mov si, MSG_BUFF_OVERFLOW
    call print_str

    mov di, COMMAND_BUFF_ERR_OVERFLOW

    ret


TXT_NOT_FOUND db "Error [commands]: This command doesn't exist.", 10, 13, 0

TXT_COMMAND_HELP db "help", 0
TXT_COMMAND_CLEAR db "clear", 0
TXT_COMMAND_TOUCH db "touch ", 0
TXT_COMMAND_RM db "rm ", 0
TXT_COMMAND_LS db "ls", 0
TXT_COMMAND_ONAN db "onan ", 0
TXT_COMMAND_RESTART db "restart", 0

command_table:
	dw TXT_COMMAND_HELP, command_help
	dw TXT_COMMAND_CLEAR, command_clear
    dw TXT_COMMAND_TOUCH, command_touch
	dw TXT_COMMAND_RM, command_remove
	dw TXT_COMMAND_LS, command_ls
	dw TXT_COMMAND_ONAN, command_onan
	dw TXT_COMMAND_RESTART, command_restart
	dw 0

command_compare:
    cmp di, 1
	je .overflow_detector

	push bp
	mov bp, si

    mov di, command_table
	mov bx, [di]

.loop:
    cmp bx, 0
    je .not_found

    mov al, [si]
    mov dl, [bx]

    cmp al, dl
    jne .different

    cmp al, 0x20
    je .equal

    cmp al, 0
    je .equal

	inc si
	inc bx

    jmp .loop

.equal:
	add di, 2
	mov bx, [di]

	call bx

	mov si, bp
	pop bp
    ret

.different:
    add di, 4
	mov bx, [di]

	mov si, bp

    jmp .loop

.not_found:
	mov si, TXT_NOT_FOUND
	call print_str

	mov si, bp
	pop bp
	mov di, 0x02
	ret

.overflow_detector:
    ret

%include "lib/commands/help.asm"
%include "lib/commands/clear.asm"
%include "lib/commands/touch.asm"
%include "lib/commands/remove.asm"
%include "lib/commands/ls.asm"
%include "lib/commands/onan.asm"
%include "lib/commands/restart.asm"
