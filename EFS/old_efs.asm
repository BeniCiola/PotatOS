bits 16

DIR_ERROR_OVERFLOW equ 0x2
MSG_DIR_OVERFLOW db 10, 13, "Error [Directory Overflow]: The files number has exceeded the main directory size", 10, 13, 0

efs_create_file:
mov bp, si
mov di, bytemap
mov si, di

.byte_loop:
    cmp [si], 0x00
    je .create

    inc si
    jmp .byte_loop

.create:
    mov [si], 0xFF
    sub si, di

    mov cx, si
    mov al, 1
    mov dh, 00h

    mov dl, 00h
    mov ah, 03h
    int 13h

    mov di, root_dir
    mov si, di

.dir_loop:
    cmp [si], 0
    je .meta

    mov ax, si
    sub ax, di

    cmp ax, 512
    jge .overflow

    add si, 32
    jmp .dir_loop

.meta:
    mov di, si
    mov [si], 0xFF
    inc si
    add bp, 1

.meta_name_loop:
    mov al, [bp]
    cmp al, '.'
    je .filler_loop

    mov [si], al
    inc si
    add bp, 1
    jmp .meta_name_loop

.filler_loop:
    mov ax, si
    sub ax, di
    cmp ax, 9
    je .fuck_you_point

    mov byte [si], 0x20
    inc si
    jmp .filler_loop

.fuck_you_point:
    add bp, 1

.meta_exten_loop:
    mov al, [bp]
    mov [si], al

    inc si
    add bp, 1

    mov ax, si
    sub ax, di
    cmp ax, 12
    je .end

    jmp .meta_exten_loop

.end:
    mov ax, cs
    mov es, ax
    mov bx, bytemap

    mov ah, 03h
    mov al, 2
    mov cl, 6
    mov ch, 0
    mov dh, 0
    mov dl, 00h
    int 13h

    mov bx, root_dir
    
    mov ah, 03h
    mov al, 1
    mov cl, 5
    mov ch, 0
    mov dh, 0
    mov dl, 00h
    int 13h

    ret

.overflow:
    mov di, DIR_ERROR_OVERFLOW
    mov si, MSG_DIR_OVERFLOW
    call print_str
    
    ret

bytemap:
incbin "EFS/bytemap.dat"

root_dir:
incbin "EFS/directory.dat"