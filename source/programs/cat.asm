%include "rolfos.inc"

start:
  mov ax, si
  call os_disk_file_exists
  jc .file_not_found
  mov cx, file_content
  call os_disk_load_file
  mov si, file_content
  mov cx, bx  ;file size into loop counter
  ; Have to implement own print_string, as OS function stops by '0' byte, this might cut data
  mov ah, 0x0E  
.repeat:
  lodsb
  int 10h
  loop .repeat


  call os_screen_print_newline
  jmp .exit

.file_not_found:
  mov si, file_not_found
  call os_screen_print_string
  call os_screen_print_newline
  ret
.exit:
  call os_disk_reset_floppy
  ret
  
file_not_found  db "**The specified file was not found!", 0x0a, 0x0d, 0 
file_content db "**File is empty!", 0x0a, 0x0d, 0
