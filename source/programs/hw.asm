BITS 16
%include "rolfos.inc"
ORG 32768

mov si, hello_world_string
call os_screen_print_string
ret

hello_world_string: db "Hello, world!", 0x0a, 0x0d, 0