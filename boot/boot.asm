bits 16
org 0x7C00

jmp short code
nop

boot_drive db 0

code:
    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    sti

    mov [boot_drive], dl

	;DON'T TOUCH THIS BLOCK OF CODE
	;Only god knows how it make run the Kernel
	mov ax, 0xB800
	mov es, ax
	mov byte [es:0], 'C'
	mov byte [es:1], 0x07	

    xor ax, ax
    mov ds, ax
    mov si, dap

    mov ah, 0x42
    mov dl, [boot_drive]

    int 0x13

    jc .disk_error

    jmp 0x0800:0x0000

.disk_error:
    mov ax, 0xB800
    mov es, ax
    mov byte [es:0], 'K'
    mov byte [es:1], 0x07

.idle:
    cli
    hlt
    jmp .idle

dap:
    db 0x10
    db 0x00
    dw 0x0014
    dw 0x0000
    dw 0x0800
    dq 0x0000000000000001

times 510-($-$$) db 0
dw 0xAA55
