[SECTION .data]

%ifdef LOADER_BIN
POS             equ     BaseOfLoaderPhyAddr + $
disp_pos        dw      100h
%else
POS     equ disp_pos 
%endif


[SECTION .text]
global  DispRet
global  DispChar
global  DispStr

ALIGN   32      ;变量的对齐方式
[BITS   32]     ;选择32位指令
DispRet:                    ;换行
    push    ebp
    mov     ebp, esp

    push    ax
    push    bx

    mov     ax, [POS]
    mov     bl, 0a0h
    div     bl
    inc     al
    cmp     al, 25
    jnae    .DispRet_handle_disp_pos
    mov     al, 0

.DispRet_handle_disp_pos:
    mul     bl
    mov     [POS], ax

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
    mov     bx, [POS]

    cmp     bx, 160 * 25
    jnae    .DispChar_handle_disp_pos
    mov     bx, 0
.DispChar_handle_disp_pos:
    mov	    [gs:bx], ax	        ;屏幕第 0 行, 第 39 列。
    add     bx, 02h
    mov     [POS], bx
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

