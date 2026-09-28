TXT_NOT_FOUND db "Error [commands]: This command doesn't exist.", 10, 13, 0

TXT_COMMAND_CLEAR db "clear", 0
TXT_COMMAND_HELP db "help", 0
TXT_COMMAND_TOUCH db "touch "
TXT_COMMAND_RM db "rm "

command_table:
	dw TXT_COMMAND_CLEAR, command_clear
	dw TXT_COMMAND_HELP, command_help
    dw TXT_COMMAND_TOUCH, command_touch
	dw TXT_COMMAND_RM, command_remove
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

%include "lib/commands/clear.asm"
%include "lib/commands/help.asm"
%include "lib/commands/touch.asm"
%include "lib/commands/remove.asm"