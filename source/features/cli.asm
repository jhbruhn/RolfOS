;;
; RolfOS Commandline
;;

os_cli_main:
  call os_screen_clear

  mov si, welcome_message_string
  call os_screen_print_string

  call os_screen_print_newline
  
command_input:

  mov si, commandline_thing_string
  call os_screen_print_string
  
  mov ax, input
  call os_cli_input_string
  
  call os_screen_print_newline
  
  mov ax, input
  jmp handle_command
  
handle_command:
  mov si, input			; Separate out the individual command
  mov al, ' '
  call os_string_tokenize

  mov word [param_list], di	; Store location of full parameters

  mov si, input			; Store copy of command for later modifications
  mov di, command
  call os_string_copy

	mov ax, command
	call os_string_uppercase
	call os_string_length
  
	mov si, command
	add si, ax

	sub si, 4
  
  mov di, rex_ext
  call os_string_compare
  jc start_program
  
	mov ax, command
	call os_string_length

	mov si, command
	add si, ax

	mov byte [si], '.'
	mov byte [si+1], 'R'
	mov byte [si+2], 'E'
	mov byte [si+3], 'X'
	mov byte [si+4], 0
    
start_program:  

  mov ax, command
  mov bx, 0
  mov cx, APP_LOCATION
  
  call os_disk_load_file
  jc .not_found
  
	mov ax, 0			; Clear all registers
	mov bx, 0
	mov cx, 0
	mov word si, [param_list] 
  mov di, 0
  
  call APP_LOCATION
  
  jmp command_input
  
.not_found:
  mov si, program_not_found_string
  call os_screen_print_string
  
  call os_screen_print_newline
  
  jmp command_input
 
;;
; Read a String from the console, ends with the press of 'Enter'
; @param AX - location of input-string
; @return AX - location of the string the user entered
;; 
os_cli_input_string:

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
rex_ext db ".REX", 0

dirlist	times 1024 db 0
input			times 256 db 0
command			times 32 db 0
param_list		dw 0

