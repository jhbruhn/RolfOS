%include "rolfos.inc"

start:
  mov ax, si
  call os_disk_create_file
  jnc .exit
  mov si, invalid_filename
  call os_screen_print_string
  call os_screen_print_newline
.exit:
  call os_disk_reset_floppy
  ret
  
invalid_filename  db "There was an error creating your file!" 