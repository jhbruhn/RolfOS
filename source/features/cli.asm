os_cli_main:
  call os_screen_clear

  mov si, welcome_message_string
  call os_screen_print_string

  call os_screen_print_newline
  
command_input:

  mov si, commandline_thing_string
  call os_screen_print_string
  
  call os_input_string
  
  call os_screen_print_newline
  
  jmp handle_command
  
;Routine: handle_command
;AX: Location of Command-String
handle_command:
  mov si, ax
  call os_string_parse
  mov si, ax
  mov di, command
  
  call os_string_copy
  call os_string_uppercase

  mov bx, 0
  mov cx, APP_LOCATION
  
  call os_disk_load_file
  jc .not_found
  
	mov ax, 0			; Clear all registers
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov si, 0
	mov di, 0

  call APP_LOCATION
  
  jmp command_input
  
.not_found:
  mov si, program_not_found_string
  call os_screen_print_string
  
  call os_screen_print_newline
  
  jmp command_input
 
;Routine: os_input_string
;Puts location of resulting string into AX 
os_input_string:

  pusha
  
  mov di, ax
  mov cx, 0
  
.moar:
  call os_keys_wait_char
  
  cmp al, 13
  je .done
  
  cmp al, 8
  je .backspace
  
  cmp al, ' '
  jb .moar
  
  cmp al, '~'
  ja .moar
  
  jmp .ascii
.backspace:
  cmp cx, 0
  je .moar
  
  call os_screen_get_cursor
  cmp dl, 0
  je .backspace_linestart

  mov al, 8
  call os_screen_print_char
  
  mov al, 32
  call os_screen_print_char
  
  mov al, 8
  call os_screen_print_char  
  
  dec cx
  dec di
  

  jmp .moar
  
.backspace_linestart:
  dec dh
  mov dl, 79
  call os_screen_set_cursor
  
  mov al, ' '
  call os_screen_print_char
  
  mov dl, 79
  call os_screen_set_cursor
  
  dec cx
  dec di
  jmp .moar
  
.ascii:
  pusha
  call os_screen_print_char
  popa
  
  stosb
  inc cx
  cmp cx, 254
  jae near .done
  
  jmp near .moar

.done:
  mov ax, 0
  stosb

  popa
  ret
  
welcome_message_string db "Welcome to RolfOS v",VERSION,". Please enter a command!", 0
commandline_thing_string db ">", 0
invalid_program_string db "The program is invalid!", 0
program_not_found_string db "Couldn't find that program!", 0
loading_string db "Loading program...", 0

dirlist	times 1024 db 0
input			times 256 db 0
command			times 32 db 0
param_list		dw 0

