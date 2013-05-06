; Screen-features for the terminal stuff with bios etc. bla

;Routine: print_char
;prints the char stored in al 
os_screen_print_char:
  pusha
  mov ah, 0x0e
  int 10h
  popa
  ret
  
;Routine: clear whole screen using BIOS
;moves cursor to upper left
;clear-function: 6 (10h)
;move-cursor-function: 2 (10h)
os_screen_clear:
  pusha
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
  popa
  ret
  
os_screen_get_cursor:
  push cx
  mov ah, 03h
  int 10h
  pop cx
  ret

os_screen_set_cursor:
  pusha
  mov ah, 02h
  int 10h
  popa
  ret
  
os_screen_print_newline:
  mov si, newline_string
  call os_screen_print_string
  ret
  
; Routine: print string stored in si via BIOS-Interrupts
; interrupt: 10h, AH = 0x0e
os_screen_print_string:
	mov ah, 0x0e
.repeat:
	lodsb
	cmp al, 0
	je .done
	int 10h
	jmp .repeat

.done:
	ret
  
  temp db 0
  
newline_string db 0x0a, 0x0d, 0  