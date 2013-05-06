;Routine: os_string_copy
;Copy string SI into DI
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
  
; Routine:os_string_length
; Puts length of String in AX into AX
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
 
;Routine: os_string_join
;CX = AX + BX 
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
  
;Routine: os_string_uppercase
;Makes AX uppercase
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
  
;Routine: os_string_compare
;compares SI and DI
;Carry=1 if same, clear if different
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
  
;Routine: os_string_parse
;Split SI by " "
;Output: AX, BX, CX, DX
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
  
;Routine: os_string_chomp
;Trim string
;In/out: AX
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

;Routine: os_string_to_int
;Converts a string to an integer
;In: SI, Out: AX
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


;Routine: os_int_to_string
;Converts unsigned int to string
;In=AX, Out=AX
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
  
;Routine: os_sint_to_string
;converts a signed int to string
;In=AX, Out=AX
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
  
;Routine: os_find_char_in_string
;Finds AL ind SI
;AX = Location. 0=notfound
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