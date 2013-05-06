jmp kernel_start

os_calls:
  jmp os_keys_wait_char
  jmp os_keys_check_pressed
  jmp os_screen_clear
  jmp os_screen_print_string
  jmp os_screen_print_char


kernel_start:
  jmp os_main 

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

  mov si, starting_string
  call os_screen_print_string

  mov si, done_string
  call os_screen_print_string 
  
  jmp os_cli_main

  %DEFINE VERSION "0.1"

  %INCLUDE "features/cli.asm"
  %INCLUDE "features/screen.asm"  
  %INCLUDE "features/keyboard.asm"  
  %INCLUDE "features/string.asm"  
  
  
;======
;Strings:
;======
starting_string: db "RolfOS v",VERSION," starting...", 0
done_string: db "done!", 0
