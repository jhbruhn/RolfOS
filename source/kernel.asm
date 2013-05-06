jmp kernel_start

kernel_start:
  jmp os_main 

;Routine: main_loop 
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
  
  mov si, newline_string
  call os_screen_print_string
.loop:
  call os_keys_get_char
  call os_screen_print_char
  jmp .loop

  %INCLUDE "features/screen.asm"  
  %INCLUDE "features/keyboard.asm"  
  
;======
;Strings:
;======
starting_string: db "RolfOS v0.0.1 starting...", 0
done_string: db "done!", 0
newline_string: db  0x0a, 0x0d, 0
