os_cli_main:
  call os_screen_clear
  
  mov si, welcome_message_string
  call os_screen_print_string
  
command_input:
  mov si, newline_string
  call os_screen_print_string
   
  mov si, commandline_thing_string
  call os_screen_print_string
  
  call os_input_string
  
.handle_command:
  mov si, newline_string
  call os_screen_print_string
  
  mov si, ax
  call os_screen_print_string
  

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
  
newline_string db 0x0a, 0x0d, 0
welcome_message_string db "Welcome to RolfOS v",VERSION,". Please enter a command!", 0
commandline_thing_string db "> ", 0