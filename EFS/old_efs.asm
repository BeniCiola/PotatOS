bits 16

FILE_ERROR_UNEXIST equ 0x03
DIR_ERROR_OVERFLOW equ 0x02

MSG_FILE_UNEXIST db 10, 13, \
    "Error [File Unexist]: The file doesn't exist in the directory", \
    10, 13, 0

MSG_DIR_OVERFLOW db 10, 13, \
    "Error [Directory Overflow]: The files number has exceeded the main directory size", \
    10, 13, 0

MSG_EXTENSION_INVALID db 10, 13, \
    "Error [Invalid Extension]: The file extension is invalid", \
    10, 13, 0


efs_create_file:
    mov bp, si

    mov si, bytemap
    xor di, di

.byte_loop:
    cmp di, 512
    jae .bytemap_full

    cmp byte [si], 0x00
    je .create

    inc si
    inc di

    jmp .byte_loop

.bytemap_full:
    ret

.create:
    mov byte [si], 0xFF

    mov cx, di

    mov di, root_dir
    mov si, di

.dir_loop:
    mov ax, si
    sub ax, di

    cmp ax, 512
    jae .overflow

    cmp byte [si], 0x00
    je .meta

    add si, 32

    jmp .dir_loop

.meta:
    mov di, si

    mov byte [si], 0xFF
    inc si

.meta_name_loop:
    mov al, [ds:bp]

    cmp al, 0
    je .filler_loop

    cmp al, '.'
    je .filler_loop

    mov [si], al
    inc si
    inc bp

    jmp .meta_name_loop

.filler_loop:
    mov ax, si
    sub ax, di

    cmp ax, 9
    jae .skip_filler

    mov byte [si], 0x20
    inc si

    jmp .filler_loop

.skip_filler:
    push cx
    xor cx, cx

    mov al, [ds:bp]

    cmp al, '.'
    jne .meta_exten_loop

    inc bp

.meta_exten_loop:
    mov al, [ds:bp]

    cmp al, 0
    je .check_extension

    mov [si], al

    inc si
    inc bp
    inc cx

    mov ax, si
    sub ax, di

    cmp ax, 12
    jb .meta_exten_loop

.check_extension:
    cmp cx, 3
    jb .invalid_extension

    pop cx
    jmp efs_write_disk

.invalid_extension:
    pop cx

    mov si, bytemap
    add si, cx
    mov byte [si], 0x00

    mov si, MSG_EXTENSION_INVALID
    call print_str

    ret

.overflow:
    mov byte [si], 0x00

    mov di, DIR_ERROR_OVERFLOW
    mov si, MSG_DIR_OVERFLOW

    call print_str

    ret


efs_write_disk:
    pusha
    push ds

    mov ax, cs
    mov ds, ax
    mov es, ax

    mov bx, bytemap
    mov ah, 03h
    mov al, 1
    mov ch, 0
    mov cl, 6
    mov dh, 0
    mov dl, 0
    int 13h
    jc .disk_error

    mov bx, root_dir
    mov ah, 03h
    mov al, 1
    mov ch, 0
    mov cl, 5
    mov dh, 0
    mov dl, 0
    int 13h
    jc .disk_error

    pop ds
    popa
    clc
    ret

.disk_error:
    pop ds
    popa
    stc
    ret


efs_delete_file:
    mov bp, si

    call efs_file_finder
    jc .file_unexist

    mov byte [si], 0x00
    ret

.file_unexist:
    mov di, FILE_ERROR_UNEXIST
    mov si, MSG_FILE_UNEXIST
    call print_str
    ret


efs_file_finder:
    mov bp, si

    mov si, root_dir
    xor di, di

.dir_loop:
    cmp di, 512
    jae .file_unexist

    cmp byte [si], 0x00
    je .next_entry

    push si
    inc si
    mov bx, bp

.verify_file_loop:
    mov al, [bx]

    cmp al, 0
    je .file_found

    cmp al, '.'
    je .verify_extension

    cmp al, [si]
    jne .not_match

    inc si
    inc bx

    jmp .verify_file_loop

.verify_extension:
    inc bx

.skip_name:
    cmp byte [si], 0x20
    jne .extension_loop

    inc si
    jmp .skip_name

.extension_loop:
    mov al, [bx]

    cmp al, 0
    je .file_found

    cmp al, [si]
    jne .not_match

    inc si
    inc bx

    jmp .extension_loop

.file_found:
    pop si
    clc
    ret

.not_match:
    pop si

.next_entry:
    add si, 32
    add di, 32
    jmp .dir_loop

.file_unexist:
    stc
    ret


efs_load_file:


bytemap:
    incbin "EFS/bytemap.dat"

root_dir:
    incbin "EFS/directory.dat"
