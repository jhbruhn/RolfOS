;Routine: get_ch
;waits for Key-Input and puts the pressed key into al
os_keys_get_char:
  pusha
  mov ah, 00
  int 16h
  mov [temp], al 
  popa
  mov al, [temp]
  ret