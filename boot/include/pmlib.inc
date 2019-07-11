[SECTION .data]
pm_disp_pos        dw      00h

ALIGN   32      ;变量的对齐方式
[BITS   32]     ;选择32位指令
PM_DispRet:                    ;换行
    push    ebp
    mov     ebp, esp

    push    ax
    push    bx

    mov     ax, [pm_disp_pos]
    mov     bl, 0a0h
    div     bl
    inc     al
    cmp     al, 25
    jnae    .PM_DispRet_handle_pm_disp_pos
    mov     al, 0

.PM_DispRet_handle_pm_disp_pos:
    mul     bl
    mov     [pm_disp_pos], ax

    pop     bx
    pop     ax
    pop     ebp
    ret

;stack resb 32
;打印一个字符
PM_DispChar:
    push    ebp
    mov     ebp, esp

    push    ax
    push    bx

    mov	    ax, [ss:ebp + 8]
    cmp     al, 0ah         ;换行
    jz      .PM_DispChar_handle_Ret

    cmp     al, 0dh         ;回车
    jnz     .PM_disp_norm_char

    mov     ax, [pm_disp_pos]
    mov     bl, 0a0h
    div     bl
    mul     bl
    mov     [pm_disp_pos], ax
    jmp     .PM_DispChar_handle_restore

.PM_disp_norm_char:
    mov	    ah, 0Fh				; 0000: 黑底    1111: 白字
    mov     bx, [pm_disp_pos]

    cmp     bx, 160 * 25
    jnae    .PM_DispChar_handle_pm_disp_pos
    mov     bx, 0
.PM_DispChar_handle_pm_disp_pos:
    mov	    [gs:bx], ax	        ;屏幕第 0 行, 第 39 列。
    add     bx, 02h
    mov     [pm_disp_pos], bx
    jmp     .PM_DispChar_handle_restore

.PM_DispChar_handle_Ret:
    call  PM_DispRet

.PM_DispChar_handle_restore:
    pop     bx
    pop     ax
    pop     ebp
    ret
; end of 打印一个字符

PM_DispStr:
    push    ebp
    mov     ebp, esp

    push    esi
    push    ecx
    push    ax

    mov     ecx, [ebp + 12]
    mov     esi, [ebp + 8]

    xor     ah, ah
.PM_DispStr_loop:
    mov     al, [ds:esi]
    push    ax
    call    PM_DispChar
    pop     ax
    inc     esi
    loop    .PM_DispStr_loop

    pop     ax
    pop     ecx
    pop     esi
    pop     ebp
    ret
; end of DispStr

; 打印Word的十六进制数字串
PM_DispDW:
    push    ebp
    mov     ebp, esp
    push    eax
    push    cx

    mov     cl, 020h
.PM_DispW_loop:
    ;cmp     cl, 010h
    ;jnz     .PM_DispDW_word

    ;push    word ' '
    ;call    PM_DispChar
    ;pop     ax

.PM_DispDW_word:
    cmp     cl, 0
    jz      .PM_DispW_handle_end
    sub     cl, 4

    mov     eax, [ss:ebp + 8]
    shr     eax, cl
    and     ax, 00fh

    cmp     al, 09h
    ja      .PM_DispW_loop_Digit_handle_greaer_9

    add     al, '0'
    jmp     .PM_DispW_loop_Digit_handle_print

.PM_DispW_loop_Digit_handle_greaer_9:
    sub     al, 0ah
    add     al, 'a'

.PM_DispW_loop_Digit_handle_print:
    push    ax
    call    PM_DispChar
    pop     ax
    jmp     .PM_DispW_loop

.PM_DispW_handle_end:
    push    word ' '
    call    PM_DispChar
    call    PM_DispChar
    pop     ax

    pop     cx
    pop     eax
    pop     ebp
    ret
;end of 打印dw的十六进制数字串

PM_Clear_Screen:
    push    ebp
    mov     ebp, esp

    push    ax
    push    ecx

    mov     ax, ' ' ;空格
    sub     esp, 2
    mov     [esp], ax

    mov     ecx, 80 * 25

PM_Clear_Screen_loop:          
    call    PM_DispChar
    loop    PM_Clear_Screen_loop

    add     esp, 2

    pop     ecx
    pop     ax
    pop     ebp
    ret
;end of Clear_Screen
