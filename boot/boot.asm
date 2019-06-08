%define _BOOT_DEBUG_

%ifdef _BOOT_DEBUG_
    LOADBASE equ 0100h
%else
    LOADBASE equ 07c00h
%endif

BaseOfStack equ LOADBASE 
org    LOADBASE 
jmp start

start:  
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, BaseOfStack 
    mov ebp, esp

    mov cx, 0ffh
    xor ax, ax

    push 00ah
    call DispChar
    add esp, 2
    
    push 0008h
    call DispDw
    add esp, 2

    push 0ah
    call DispChar
    add esp, 2

    push 0009h
    call DispDw
    add esp, 2

    push 0ah
    call DispChar
    add esp, 2

    push 000ah
    call DispDw
    add esp, 2

    push 0ah
    call DispChar
    add esp, 2

    push 000bh
    call DispDw
    add esp, 2

    push 0ah
    call DispChar
    add esp, 2
    jmp end

loop_begin:
    push 'A'
    call DispChar
    add esp, 2

    push 0ah
    call DispChar
    add esp, 2
    inc ax
    loop loop_begin
    
end:
    jmp $


;stack resb 32

;打印一个字符
DispChar:
    push    ebp
    mov     ebp, esp

    push    ax
    push    bx
    push    dx
    push    cx

    mov	ax, [ebp + 6]
    cmp al, 0ah 
    jz DispChar_handle_Ret

    mov	dx, 0B800h
    mov	gs, dx
    mov	ah, 0Fh				; 0000: 黑底    1111: 白字
    mov bx, [cursor]

    cmp bx, 160 * 25
    jnae DispChar_handle_cursor
    mov bx, 0
DispChar_handle_cursor:
    mov	[gs:bx], ax	        ;屏幕第 0 行, 第 39 列。
    add bx, 02h
    mov [cursor], bx
    jmp DispChar_handle_restore

DispChar_handle_Ret:
    call  DispRet

DispChar_handle_restore:
    pop cx
    pop dx
    pop bx
    pop ax
    pop ebp
    ret
; end of 打印一个字符

DispRet:       ;换行
    push    ebp
    mov     ebp, esp

    push ax
    push bx

    mov ax, [cursor]
    mov bl, 0a0h
    div bl
    inc al
    cmp al, 25
    jnae DispRet_handle_cursor
    mov al, 0

DispRet_handle_cursor:
    mul bl
    mov [cursor], ax

    pop bx
    pop ax
    pop ebp
    ret

;打印dw的十六进制数字串
DispDw:
    push    ebp
    mov     ebp, esp
    push ax
    push cx

    mov cl, 010h
DispDw_loop:
    mov ax, [ebp + 6]
    cmp cl, 0
    jz DispDw_handle_end
    sub cl, 4
    shr ax, cl

    cmp al, 09h
    ja DispDw_loop_Digit_handle_greaer_9

    add al, '0'
    jmp DispDw_loop_Digit_handle_print

DispDw_loop_Digit_handle_greaer_9:
    sub al, 0ah
    add al, 'a'

DispDw_loop_Digit_handle_print:
    push ax
    call DispChar
    pop ax
    jmp DispDw_loop

DispDw_handle_end:
    pop cx
    pop ax
    pop ebp
    ret
;end of 打印dw的十六进制数字串

cursor  dw 160 * 0
row equ 0ah
;times 	2510-($-$$)	db	0	; 填充剩下的空间，使生成的二进制代码恰好为512字节
dw 	0xaa55				; 结束标志
