bits 16

; If you're here, let me say to you something: I really don't known wtf is this.
; I create this, obviously, but I never use it in the system.
; So... do whathever you want. After all, this OS don't deprive you to do it with anything.


global panic
extern print_str

ANTIFINAL_MESSAGE db 13, 10, "=============", 13, 10, "Rotten Potato", 13, 10, "=============", 13, 10, 10, 0
FINAL_MESSAGE db 13, 10, 10, "Thanks for choosing PotatOS. Please reset/shutdown your PC, I can't do it by myself :)", 0


ERR_DISK_READ equ 0x001
TXT_ERR_DISK_READ db "Error while reading a disk sector.", 13, 10, "Error code: ", 0


TXT_ERR_UNKNOWN db "An unknown error has occurred.", 0


err_table:
	dw ERR_DISK_READ, TXT_ERR_DISK_READ
	dw 0


panic:
	mov si, ANTIFINAL_MESSAGE
	call print_str

	mov si, err_table

.err_search:
	mov cx, [si]
	jcxz err_unknown

	cmp cx, di
	je .err_known

	add si, 4
	jmp .err_search


.err_unknown:
	mov si, TXT_ERR_UNKNOWN
	call print_str
	jmp .close

.err_known:
	mov ax, si

	add si, 2
	mov si, [si]
	call print_str

	mov si, [ax]
	call print_str

	jmp .close

.close:
	mov si, FINAL_MESSAGE
	call print_str
	jmp .hang


.hang:
	cli
	hlt
	jmp .hang
