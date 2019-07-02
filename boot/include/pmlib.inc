[SECTION .data]
disp_pos        dw      00h

ALIGN   32      ;变量的对齐方式
[BITS   32]     ;选择32位指令
DispRet:                    ;换行
    push    ebp
    mov     ebp, esp

    push    ax
    push    bx

    mov     ax, [disp_pos]
    mov     bl, 0a0h
    div     bl
    inc     al
    cmp     al, 25
    jnae    .DispRet_handle_disp_pos
    mov     al, 0

.DispRet_handle_disp_pos:
    mul     bl
    mov     [disp_pos], ax

    pop     bx
    pop     ax
    pop     ebp
    ret

;stack resb 32
;打印一个字符
DispChar:
    push    ebp
    mov     ebp, esp

    push    ax
    push    bx

    mov	    ax, [ebp + 8]
    cmp     al, 0ah         ;换行
    jz      .DispChar_handle_Ret

    cmp     al, 0dh         ;回车
    jnz     .disp_norm_char

    mov     ax, [disp_pos]
    mov     bl, 0a0h
    div     bl
    mul     bl
    mov     [disp_pos], ax
    jmp     .DispChar_handle_restore

.disp_norm_char:
    mov	    ah, 0Fh				; 0000: 黑底    1111: 白字
    mov     bx, [disp_pos]

    cmp     bx, 160 * 25
    jnae    .DispChar_handle_disp_pos
    mov     bx, 0
.DispChar_handle_disp_pos:
    mov	    [gs:bx], ax	        ;屏幕第 0 行, 第 39 列。
    add     bx, 02h
    mov     [disp_pos], bx
    jmp     .DispChar_handle_restore

.DispChar_handle_Ret:
    call  DispRet

.DispChar_handle_restore:
    pop     bx
    pop     ax
    pop     ebp
    ret
; end of 打印一个字符

DispStr:
    push    ebp
    mov     ebp, esp

    push    esi
    push    ecx
    push    ax

    mov     ecx, [ebp + 12]
    mov     esi, [ebp + 8]

    xor     ah, ah
.DispStr_loop:
    mov     al, [ds:esi]
    push    ax
    call    DispChar
    pop     ax
    inc     esi
    loop    .DispStr_loop

    pop     ax
    pop     ecx
    pop     esi
    pop     ebp
    ret
; end of DispStr

; 打印Word的十六进制数字串
DispW:
    push    ebp
    mov     ebp, esp
    push    ax
    push    cx

    mov     cl, 010h
.DispW_loop:
    mov     ax, [ebp + 8]
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
    push    ecx

    mov     ax, ' ' ;空格
    sub     esp, 2
    mov     [esp], ax

    mov     ecx, 80 * 25

Clear_Screen_loop:          
    call    DispChar
    loop    Clear_Screen_loop

    add     esp, 2

    pop     ecx
    pop     ax
    pop     ebp
    ret
;end of Clear_Screen
