command_remove:
    inc si
    mov di, current_filename

.copy_name:
    mov al, [si]
    cmp al, '.'
    je .pad_name
    mov [di], al
    inc si
    inc di
    jmp .copy_name

.pad_name:
    mov ax, di
    sub ax, current_filename
    cmp ax, 8
    jae .copy_ext
    mov byte [di], 0x20
    inc di
    jmp .pad_name

.copy_ext:
    inc si
    
    mov al, [si]
    mov [di], al
    mov al, [si+1]
    mov [di+1], al
    mov al, [si+2]
    mov [di+2], al
    
    mov byte [di+3], 0

    call efs_delete_file
    ret
