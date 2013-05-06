;Routine: os_string_copy
;Copy string SI into DI
os_string_copy:
	pusha

.more:
	mov al, [si]			; Transfer contents (at least one byte terminator)
	mov [di], al
	inc si
	inc di
	cmp byte al, 0			; If source string is empty, quit out
	jne .more

.done:
	popa
	ret
  
; Routine:os_string_length
; Puts length of String in AX into AX
os_string_length:
	pusha
  mov bx, ax			; Move location of string to BX
  mov cx, 0			; Counter

.more:
	cmp byte [bx], 0		; Zero (end of string) yet?
	je .done
	inc bx				; If not, keep adding
	inc cx
	jmp .more

.done:
	mov word [.tmp_counter], cx	; Store count before restoring other registers
	popa
  mov ax, [.tmp_counter]		; Put count back into AX before returning
	ret
  
  .tmp_counter	dw 0
 
;Routine: os_string_join
;CX = AX + BX 
os_string_join:
	pusha

	mov si, ax			; Put first string into CX
	mov di, cx
	call os_string_copy

	call os_string_length		; Get length of first string

	add cx, ax			; Position at end of first string

	mov si, bx			; Add second string onto it
	mov di, cx
	call os_string_copy

	popa
	ret