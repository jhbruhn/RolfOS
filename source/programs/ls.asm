%include "rolfos.inc"

start:
  mov ax, dirlist
  call os_disk_get_file_list
  mov si, ax
  
	mov ah, 0x0e
.repeat:
	lodsb
  
	cmp al, 0
	je .done
  
  cmp al, ','
  je .newline
  pusha
  call os_screen_print_char
	popa
  jmp .repeat
.newline:
  pusha
  call os_screen_print_newline  
  popa
  jmp .repeat
.done:
  call os_screen_print_newline  

	ret

  
dirlist			times 1024 db 0
dir dw 0