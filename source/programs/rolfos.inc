BITS 16

os_main equ 0000h

;Keys
os_keys_wait_char equ 3h
os_keys_check_pressed equ 6h

;Screen
os_screen_clear equ 9h
os_screen_print_string equ 0ch
os_screen_print_char equ 0fh

;Strings
os_string_join equ 12h
os_string_length equ 15h
os_string_uppercase equ 18h
os_string_compare equ 1bh
os_string_parse equ 1eh
os_string_tokenize equ 21h
os_string_chomp equ 24h
os_string_to_int equ 27h
os_int_to_string equ 2ah
os_sint_to_string equ 2dh
os_find_char_in_string equ 30h

;Disk
os_disk_reset_floppy equ 33h
os_disk_get_file_list equ 36h
os_disk_load_file equ 39h
os_disk_file_exists equ 3ch
os_disk_create_file equ 3fh
os_disk_remove_file equ 42h 
os_disk_rename_file equ 45h
os_disk_get_file_size equ 48h

;Screen 2
os_screen_print_newline equ 4bh

;String 2
os_string_copy equ 4eh

ORG 32768
