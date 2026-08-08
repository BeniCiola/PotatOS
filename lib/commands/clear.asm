command_clear:
	mov ah, 0x00
	mov al, 0x03

	int 0x10

	ret
