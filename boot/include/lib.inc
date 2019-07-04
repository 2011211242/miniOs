cursor  db  0

;[section .text]
stack resb 32
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
    jz .DispChar_handle_Ret

    mov	dx, 0B800h
    mov	gs, dx
    mov	ah, 0Fh				; 0000: 黑底    1111: 白字
    mov bx, [cursor]

    cmp bx, 160 * 25
    jnae .DispChar_handle_cursor
    mov bx, 0
.DispChar_handle_cursor:
    mov	[gs:bx], ax	        ;屏幕第 0 行, 第 39 列。
    add bx, 02h
    mov [cursor], bx
    jmp .DispChar_handle_restore

.DispChar_handle_Ret:
    call  DispRet

.DispChar_handle_restore:
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
    jnae .DispRet_handle_cursor
    mov al, 0

.DispRet_handle_cursor:
    mul bl
    mov [cursor], ax

    pop bx
    pop ax
    pop ebp
    ret

;打印Word的十六进制数字串
DispW:
    push    ebp
    mov     ebp, esp
    push    ax
    push    cx

    mov     cl, 010h
.DispW_loop:
    mov     ax, [ebp + 6]
    cmp     cl, 0
    jz      .DispW_handle_end
    sub     cl, 4
    shr     ax, cl
    and     ax, 00fh

    cmp     al, 09h
    ja      .DispW_loop_Digit_handle_greaer_9

    add     al, '0'
    jmp     .DispW_loop_Digit_handle_print

.DispW_loop_Digit_handle_greaer_9:
    sub     al, 0ah
    add     al, 'a'

.DispW_loop_Digit_handle_print:
    push    ax
    call    DispChar
    pop     ax
    jmp     .DispW_loop

.DispW_handle_end:
    pop     cx
    pop     ax
    pop     ebp
    ret
;end of 打印dw的十六进制数字串

Clear_Screen:
    push    ebp
    mov     ebp, esp

    push    ax
    push    cx

    mov     ax, ' ' ;空格
    sub     esp, 2
    mov     [esp], ax

    mov     cx, 80 * 25

Clear_Screen_loop:          
    call    DispChar
    loop    Clear_Screen_loop

    add     esp, 2

    pop     cx
    pop     ax
    pop     ebp
    ret
;end of Clear_Screen

DispStr:
    push    ebp
    mov     ebp, esp

    push    si
    push    cx
    push    bx
    push    es

    mov     cx, [ebp + 10] 
    mov     es, [ebp + 8]
    mov     si, [ebp + 6]

    xor     bh, bh
.DispStr_loop:
    mov     bl, [es:si]
    push    bx
    call    DispChar
    pop     bx
    inc     si
    loop    .DispStr_loop

    pop     es
    pop     bx
    pop     cx
    pop     si 
    pop     ebp 
    ret
; end of DispStr
