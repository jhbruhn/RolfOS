BITS 16
%include "rolfos.inc"
ORG 32768

start:

  mov ax, dirlist
  call os_disk_get_file_list
  mov si, ax
  call os_screen_print_string
  call os_screen_print_newline
  
	ret
  
dirlist			times 1024 db 0