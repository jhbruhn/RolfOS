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
	mov ah, 1	
	int 16h

	jz .nokey		

	mov ax, 0		
	int 16h

	mov [.tmp_buf], ax

	popa
	mov ax, [.tmp_buf]
	ret

.nokey:
	popa
	mov ax, 0	
	ret


	.tmp_buf	dw 0