org 0x7C00

jmp code

boot_drive db 0

code:
mov [boot_drive], dl

mov ax, 0800h
mov es, ax
mov bx, 0000h

mov ah, 0x02
mov al, 0x01

mov dl, [boot_drive]
mov cl, 0x02
mov ch, 0
mov dh, 0

int 0x13

jc .disk_error

jmp 0x0800:0x0000

.disk_error:

times 510-($-$$) db 0

dw 0xAA55
