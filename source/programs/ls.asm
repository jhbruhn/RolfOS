BITS 16
%include "rolfos.inc"
ORG 32768

start:
	mov ax, dirlist			; Get list of files on disk
	call os_disk_get_file_list
	mov si, dirlist
  call os_screen_print_string
	
dirlist	times 1024 db 0
  
