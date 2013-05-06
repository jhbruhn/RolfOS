os_main equ 0000h

;Keys
os_keys_wait_char equ 0003h
os_keys_check_pressed equ 0006h
;Screen
os_screen_clear equ 0009h
os_screen_print_string equ 000ch
os_screen_print_char equ 000fh
;Strings
os_string_join equ 12h
os_string_length equ 15h
os_string_uppercase equ 18h
os_string_compare equ 1bh
os_string_parse equ 1eh
;os_string_compare equ 21eh
