disk_buffer	equ	24576
os_call_vectors:
  jmp os_main

  ;Keys
  jmp os_keys_wait_char
  jmp os_keys_check_pressed
  
  ;Screen
  jmp os_screen_clear
  jmp os_screen_print_string
  jmp os_screen_print_char
  
  ;Strings
  jmp os_string_join
  jmp os_string_length
  jmp os_string_uppercase
  jmp os_string_compare
  jmp os_string_parse
  jmp os_string_tokenize
  jmp os_string_chomp
  jmp os_string_to_int
  jmp os_int_to_string
  jmp os_sint_to_string
  jmp os_find_char_in_string
  
  ;Disk
  jmp os_disk_reset_floppy
  jmp os_disk_get_file_list
  jmp os_disk_load_file
  jmp os_disk_file_exists
  jmp os_disk_create_file
  jmp os_disk_remove_file
  jmp os_disk_rename_file
  jmp os_disk_get_file_size
  
  ;Screen 2
  jmp os_screen_print_newline
  
  ;String 2
  jmp os_string_copy
  
  ;CLI
  jmp os_cli_input_string

;Routine: os_main 
;The main loop where input is being processed etc.
os_main:
  cli				      ;Clear interrupts
  mov ax, 0
  mov ss, ax			;Set stack segment and pointer
  mov sp, 0FFFFh
  sti				      ;Restore interrupts

  cld				      ;The default direction for string operations
  				        ;will be 'up' - incrementing address in RAM

  mov ax, 2000h		;Set all segments to match where kernel is loaded
  mov ds, ax			;After this, we don't need to bother with
  mov es, ax			;segments ever again, as RolfOS and its programs
  mov fs, ax			;live entirely in 64K
  mov gs, ax
  
  call os_screen_clear
  
	cmp dl, 0
	je no_change
	mov [bootdev], dl		; Save boot device number
	push es
	mov ah, 8			; Get drive parameters
	int 13h
	pop es
	and cx, 3Fh			; Maximum sector number
	mov [SecsPerTrack], cx		; Sector numbers start at 1
	movzx dx, dh			; Maximum head number
	add dx, 1			; Head numbers start at 0 - add 1 for total
	mov [Sides], dx

no_change:
  mov si, starting_string
  call os_screen_print_string

  mov si, done_string
  call os_screen_print_string 
  
  jmp os_cli_main

  %DEFINE VERSION "0.1"
  %DEFINE APP_LOCATION 32768

  %INCLUDE "features/cli.asm"
  %INCLUDE "features/screen.asm"  
  %INCLUDE "features/keyboard.asm"  
  %INCLUDE "features/string.asm"  
  %INCLUDE "features/general.asm"  
  %INCLUDE "features/disk.asm"  
  
  
;======
;Strings:
;======
starting_string: db "RolfOS v",VERSION," starting...", 0
done_string: db "done!", 0
