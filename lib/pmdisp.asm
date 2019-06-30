
[SECTION .data]
disp_pos    db  0

[SECTION .text]
global  DispRet
global  DispChar

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
    cmp     al, 0ah 
    jz      .DispChar_handle_Ret

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
