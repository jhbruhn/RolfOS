%include "rolfos.inc"

start:
  push si
  mov si, hello_world_string
  call os_screen_print_string
  pop si

  mov di, 0
  call os_string_compare
  jc .exit
  call os_screen_print_string
  call os_screen_print_newline

.exit:
  ret

hello_world_string: db "Hello, world!", 0x0a, 0x0d, 0