command_restart:
	mov al, 0xFE
	out 0x64, al
	ret
