;Routine: get_ch
;waits for Key-Input and puts the pressed key into al
os_get_ch:
  mov ah, 00
  int 16h
  ret
  
;Routine: print_char
;prints the char stored in al 
os_print_char:
  mov ah, 0x0e
  int 10h
  ret
  
;Routine: clear whole screen using BIOS
;moves cursor to upper left
;clear-function: 6 (10h)
;move-cursor-function: 2 (10h)
os_clear_screen:
  
  ;clear the screen
  mov	ah, 6
	mov	al, 0
	mov	bh, 7
	mov	cx, 0
	mov	dl, 79
	mov	dh, 24
	int	10h

  ;move the cursor to the top 
  mov	ah, 2
  mov	bh, 0
  mov	dh, 0
  mov	dl, 0
  int	10h
  
  ret
  
; Routine: print string stored in si via BIOS-Interrupts
; interrupt: 10h, AH = 0x0e
os_print_string:
	mov ah, 0x0e
.repeat:
	lodsb
	cmp al, 0
	je .done
	int 10h
	jmp .repeat

.done:
	ret