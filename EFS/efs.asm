bits 16

FILE_ERROR_UNEXIST equ 0x03
DIR_ERROR_OVERFLOW equ 0x02

EFS_DATA_START equ 10
EFS_ENTRY_SIZE equ 32
EFS_ENTRY_SECTOR equ 12

file_buffer equ 0xA000

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

    mov bx, bytemap
    mov di, EFS_DATA_START

.byte_loop:
    cmp di, 512
    jae .bytemap_full

    cmp byte [bx + di], 0x00
    je .create

    inc di
    jmp .byte_loop


.bytemap_full:
    ret


.create:
    mov byte [bx + di], 0xFF

	push di
	mov ax, di
	call efs_clear_sector

	pop di

    push di

    mov di, root_dir
    mov si, di


.dir_loop:
    mov ax, si
    sub ax, di

    cmp ax, 512
    jae .overflow

    cmp byte [si], 0x00
    je .meta

    add si, EFS_ENTRY_SIZE
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
    pop ax
    mov word [di + EFS_ENTRY_SECTOR], ax

    push ax
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
    pop ax

    jmp efs_write_metadata


.invalid_extension:
    pop cx
    pop ax

    mov bx, bytemap
    add bx, ax
    mov byte [bx], 0x00

    mov si, MSG_EXTENSION_INVALID
    call print_str

    ret


.overflow:
    pop ax

    mov bx, bytemap
    add bx, ax
    mov byte [bx], 0x00

    mov di, DIR_ERROR_OVERFLOW
    mov si, MSG_DIR_OVERFLOW

    call print_str

    ret

efs_clear_sector:
	push ax
	push bx
	push cx
	push di
	push es

	push ds
	pop es

	mov di, sector_buffer
	xor ax, ax
	mov cx, 256
	cld
	rep stosw

	pop es
	pop di
	pop cx
	pop bx
	pop ax

	mov bx, sector_buffer
	call efs_write_sector
	ret

sector_buffer:
	times 512 db 0


efs_write_metadata:
    call efs_write_bytemap
    jc .disk_error

    call efs_write_root_dir
    jc .disk_error

    clc
    ret

.disk_error:
    stc
    ret


efs_write_bytemap:
    mov bx, bytemap
    mov ax, 6
    call efs_write_sector
    ret


efs_write_root_dir:
    mov bx, root_dir
    mov ax, 5
    call efs_write_sector
    ret


efs_delete_file:
    mov bp, si

    call efs_file_finder
    jc .file_unexist

    mov ax, [si + EFS_ENTRY_SECTOR]

    mov bx, bytemap
    add bx, ax
    mov byte [bx], 0x00

    mov byte [si], 0x00

    call efs_write_metadata

    ret


.file_unexist:
    mov di, FILE_ERROR_UNEXIST
    mov si, MSG_FILE_UNEXIST
    call print_str
    ret


efs_file_finder:
    mov bx, current_filename
    mov bp, bx


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
    add si, EFS_ENTRY_SIZE
    add di, EFS_ENTRY_SIZE

    jmp .dir_loop


.file_unexist:
    stc
    ret


efs_load_file:
    call efs_file_finder
    jc .file_unexist

    mov ax, [si + EFS_ENTRY_SECTOR]

    mov bx, file_buffer
    call efs_read_sector
    jc .disk_error

    mov si, file_buffer
    clc
    ret


.file_unexist:
    mov si, MSG_FILE_UNEXIST
    call print_str
    stc
    ret


.disk_error:
    stc
    ret


efs_save_file:
    call efs_file_finder
    jc .file_unexist

    mov ax, [si + EFS_ENTRY_SECTOR]

    mov bx, file_buffer
    call efs_write_sector
    jc .disk_error

    clc
    ret


.file_unexist:
    mov si, MSG_FILE_UNEXIST
    call print_str
    stc
    ret


.disk_error:
    stc
    ret


efs_read_sector:
    mov word [dap.sector_count], 1

    mov word [dap.buffer_offset], bx
    mov word [dap.buffer_segment], cs

    mov word [dap.lba_low], ax
    mov word [dap.lba_high], 0
    mov word [dap.lba_high2], 0
    mov word [dap.lba_high3], 0

    mov si, dap

    mov ah, 0x42
    mov dl, [boot_drive]

    int 13h
    jc .error

    clc
    ret

.error:
    stc
    ret


efs_write_sector:
    mov word [dap.sector_count], 1

    mov word [dap.buffer_offset], bx
    mov word [dap.buffer_segment], cs

    mov word [dap.lba_low], ax
    mov word [dap.lba_high], 0
    mov word [dap.lba_high2], 0
    mov word [dap.lba_high3], 0

    mov si, dap

    mov ah, 0x43
    mov dl, [boot_drive]

    int 13h
    jc .error

    clc
    ret

.error:
    stc
    ret


dap:
    db 0x10
    db 0x00

.sector_count:
    dw 0x0001

.buffer_offset:
    dw 0x0000

.buffer_segment:
    dw 0x0000

.lba_low:
    dw 0x0000

.lba_high:
    dw 0x0000

.lba_high2:
    dw 0x0000

.lba_high3:
    dw 0x0000


current_filename:
	times 12 db 0

;file_buffer:
;    times 512 db 0

bytemap:
    incbin "EFS/bytemap.dat"

root_dir:
    incbin "EFS/directory.dat"
