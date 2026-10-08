keyboard_wait:
    xor ah, ah
    int 0x16
    ret

keyboard_backspace:
    mov al, 0x8
    call print_char
    mov al, 0x20
    call print_char
    mov al, 0x8
    call print_char

    ret
