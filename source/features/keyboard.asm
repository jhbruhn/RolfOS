;Routine: get_ch
;waits for Key-Input and puts the pressed key into al
os_keys_wait_char:
  pusha
  mov ah, 00
  int 16h
  mov [temp], al 
  popa
  mov al, [temp]
  ret
  
os_keys_check_pressed:
	pusha

	mov ax, 0
	mov ah, 1			; BIOS call to check for key
	int 16h

	jz .nokey			; If no key, skip to end

	mov ax, 0			; Otherwise get it from buffer
	int 16h

	mov [.tmp_buf], ax		; Store resulting keypress

	popa				; But restore all other regs
	mov ax, [.tmp_buf]
	ret

.nokey:
	popa
	mov ax, 0			; Zero result if no key pressed
	ret


	.tmp_buf	dw 0