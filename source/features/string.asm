;;Routine: os_string_copy
; copies a string
; @param SI - input
; @param DI - target
;;
os_string_copy:
	pusha

.more:
	mov al, [si]		
	mov [di], al
	inc si
	inc di
	cmp byte al, 0		
	jne .more

.done:
	popa
	ret
  
;;
; Gets the length of a string
; @param AX - in-string
; @return AX - the length of the string
;;
os_string_length:
	pusha
  mov bx, ax		
  mov cx, 0		

.more:
	cmp byte [bx], 0		
	je .done
	inc bx			
	inc cx
	jmp .more

.done:
	mov word [.tmp_counter], cx	
	popa
  mov ax, [.tmp_counter]		
	ret
  
  .tmp_counter	dw 0
 
;;Routine: os_string_join
; Joins two strings
; @param AX - string 1
; @param BX - string 2
; @return CX - string 1 + string 2
;;
os_string_join:
	pusha

	mov si, ax		
	mov di, cx
	call os_string_copy

	call os_string_length		

	add cx, ax		

	mov si, bx		
	mov di, cx
	call os_string_copy

	popa
	ret
  
;;
; Makes a string uppercase
; @param AX - the input-string
; @return AX - the uppercased string
;;
os_string_uppercase:
	pusha

	mov si, ax			

.more:
	cmp byte [si], 0		
	je .done			

	cmp byte [si], 'a'	
	jb .noatoz
	cmp byte [si], 'z'
	ja .noatoz

	sub byte [si], 20h		

	inc si
	jmp .more

.noatoz:
	inc si
	jmp .more

.done:
	popa
	ret
  
;;Routine: os_string_compare
; compares two strings
; @param SI - string 1
; @param DI - string 2
; @return CARRY - set if same, clear if different
;;
os_string_compare:
	pusha

.more:
	mov al, [si]		
	mov bl, [di]

	cmp al, bl			
	jne .not_same

	cmp al, 0		
	je .terminated

	inc si
	inc di
	jmp .more


.not_same:		
	popa			
	clc			
	ret


.terminated:			
	popa
	stc				
	ret
  
;;
; Split the string by " "
; @param SI - the input
; @return AX, BX, CX, DX - the results
;;
os_string_parse:
	push si

	mov ax, si		

	mov bx, 0		
	mov cx, 0
	mov dx, 0

	push ax

.loop1:
	lodsb			
	cmp al, 0			
	je .finish
	cmp al, ' '		
	jne .loop1
	dec si
	mov byte [si], 0		

	inc si				
	mov bx, si

.loop2:				
	lodsb
	cmp al, 0
	je .finish
	cmp al, ' '
	jne .loop2
	dec si
	mov byte [si], 0

	inc si
	mov cx, si

.loop3:
	lodsb
	cmp al, 0
	je .finish
	cmp al, ' '
	jne .loop3
	dec si
	mov byte [si], 0

	inc si
	mov dx, si

.finish:
	pop ax

	pop si
	ret

;;Routine: os_string_tokenize
; splits a string with a char
; @param SI - the input-string
; @param AL - the input-token
; @return DI - next token or 0 if none
;; 
os_string_tokenize:
	push si

.next_char:
	cmp byte [si], al
	je .return_token
	cmp byte [si], 0
	jz .no_more
	inc si
	jmp .next_char

.return_token:
	mov byte [si], 0
	inc si
	mov di, si
	pop si
	ret

.no_more:
	mov di, 0
	pop si
	ret
  
;;
;Trim a string
; @param AX - string
; @return AX - string
;;
os_string_chomp:
	pusha

	mov dx, ax		

	mov di, ax		
	mov cx, 0			

.keepcounting:				
	cmp byte [di], ' '
	jne .counted
	inc cx
	inc di
	jmp .keepcounting

.counted:
	cmp cx, 0		
	je .finished_copy

	mov si, di			
	mov di, dx		

.keep_copying:
	mov al, [si]		
	mov [di], al		
	cmp al, 0
	je .finished_copy
	inc si
	inc di
	jmp .keep_copying

.finished_copy:
	mov ax, dx		

	call os_string_length
	cmp ax, 0		
	je .done

	mov si, dx
	add si, ax		

.more:
	dec si
	cmp byte [si], ' '
	jne .done
	mov byte [si], 0	
	jmp .more			

.done:
	popa
	ret

;;
; Converts a string to an integer
; @param SI - string
; @return AX - integer
;;
os_string_to_int:
	pusha

	mov ax, si	
	call os_string_length

	add si, ax		
	dec si

	mov cx, ax		

	mov bx, 0		
	mov ax, 0

	mov word [.multiplier], 1

.loop:
	mov ax, 0
	mov byte al, [si]		
	sub al, 48			

	mul word [.multiplier]	

	add bx, ax	

	push ax			
	mov word ax, [.multiplier]
	mov dx, 10
	mul dx
	mov word [.multiplier], ax
	pop ax

	dec cx			
	cmp cx, 0
	je .finish
	dec si				
	jmp .loop

.finish:
	mov word [.tmp], bx
	popa
	mov word ax, [.tmp]

	ret


	.multiplier	dw 0
	.tmp		dw 0


;;
;Converts unsigned int to string
; @param AX - Integer
; @return AX - String
os_int_to_string:
	pusha

	mov cx, 0
	mov bx, 10		
	mov di, .t		

.push:
	mov dx, 0
	div bx			
	inc cx			
	push dx			
	test ax, ax		
	jnz .push			
.pop:
	pop dx			
	add dl, '0'		
	mov [di], dl
	inc di
	dec cx
	jnz .pop

	mov byte [di], 0	

	popa
	mov ax, .t			
	ret


	.t times 7 db 0
  
;;Routine: os_sint_to_string
; converts a signed int to string
; @param AX - signed int
; @return AX - string
;;
os_sint_to_string:
	pusha

	mov cx, 0
	mov bx, 10		
	mov di, .t		

	test ax, ax		
	js .neg				
	jmp .push			
.neg:
	neg ax			
	mov byte [.t], '-'		
	inc di				
.push:
	mov dx, 0
	div bx		
	inc cx			
	push dx		
	test ax, ax		
	jnz .push		
.pop:
	pop dx				
	add dl, '0'		
	mov [di], dl
	inc di
	dec cx
	jnz .pop

	mov byte [di], 0	

	popa
	mov ax, .t	
	ret


	.t times 7 db 0
  
;;
; location of a char in a string
; @param SI - input-string
; @param AX - Location. 0 = notfound
;;
os_find_char_in_string:
	pusha

	mov cx, 1

.more:
	cmp byte [si], al
	je .done
	cmp byte [si], 0
	je .notfound
	inc si
	inc cx
	jmp .more

.done:
	mov [.tmp], cx
	popa
	mov ax, [.tmp]
	ret

.notfound:
	popa
	mov ax, 0
	ret


	.tmp	dw 0