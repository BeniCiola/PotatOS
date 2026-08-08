bits 16
org 0

jmp start

MSG_BOOT db "Welcome to PotatOS", 13, 10, "Kernel 0.1.0v", 13, 10, 0
TERMINAL_PROMPT db ">", 0

start:
	mov ax, cs
	mov ds, ax
	mov es, ax

	mov si, MSG_BOOT
	call print_str


.main_loop:
	mov si, TERMINAL_PROMPT
	call print_str

	call keyboard_command_str
	call command_compare

	jmp .main_loop

%include "lib/commands/commands.asm"
%include "lib/print.asm"
%include "lib/keyboard.asm"
