%define _BOOT_DEBUG_

%ifdef _BOOT_DEBUG_
    LOADBASE equ 0100h
%else
    LOADBASE equ 07c00h
%endif

BaseOfStack equ LOADBASE 
org    LOADBASE 

jmp start
nop

%include "fat12hdr.inc"


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

;打印dw的十六进制数字串
DispW:
    push    ebp
    mov     ebp, esp
    push    ax
    push    cx

    mov     cl, 010h
.DispDw_loop:
    mov     ax, [ebp + 6]
    cmp     cl, 0
    jz      .DispDw_handle_end
    sub     cl, 4
    shr     ax, cl
    and     ax, 00fh

    cmp     al, 09h
    ja      .DispDw_loop_Digit_handle_greaer_9

    add     al, '0'
    jmp     .DispDw_loop_Digit_handle_print

.DispDw_loop_Digit_handle_greaer_9:
    sub     al, 0ah
    add     al, 'a'

.DispDw_loop_Digit_handle_print:
    push    ax
    call    DispChar
    pop     ax
    jmp     .DispDw_loop

.DispDw_handle_end:
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

    mov     cx, [ebp + 12] 
    mov     es, [ebp + 8]
    mov     si, [ebp + 6]

.DispStr_loop:
    mov     bx, [si]
    push    bx
    call    DispChar
    pop     bx
    inc     si
    loop    .DispStr_loop

    pop     bx
    pop     cx
    pop     si 
    pop     ebp 
    ret
; end of DispStr


ResetDisk:
    xor     ah, ah
    xor     dl, dl
    int     13h
    ret

;------------------------------------
;dw      起始扇区号
;dw      要读的扇区数, <= 256
;es:bx   目的缓冲区地址
;------------------------------------
ReadSec:
    push    ebp
    mov     ebp, esp
    push    ax
    push    cx
    push    dx
    push    es
    push    bx
    
    mov     ax, [ebp + 12]          ;起始扇区
    mov     bl, [BPB_SecPerTrk]
    div     bl

    inc     ah
    mov     cl, ah
    mov     dh, al

    shr     al, 1
    mov     ch, al
    and     dh, 1
    mov     dl, [BS_DrvNum]

    mov     es, [ebp + 8]
    mov     ax, [ebp + 10]
    xor     ah, ah
    mov     bx, [ebp + 6]
.GoOnReading:
    mov     ah, 2
    int     13h

    jc      .GoOnReading
    pop     bx
    pop     es
    pop     dx
    pop     cx
    pop     ax
    pop     ebp
    ret

;加载根目录区
ReadDir:
    push    ebp
    mov     ebp, esp
    push    ax

    sub     esp, 8
    mov     ax, SectorNoOfRootDirectory
    mov     [esp + 6], ax

    mov     ax, RootDirSectors		
    mov     [esp + 4], ax

    mov     ax, BaseOfLoader        
    mov     [esp + 2], ax

    mov     ax, OffsetOfLoader      
    mov     [esp], ax

    call    ReadSec
    add     esp, 8

    ;mov     ci, OffsetOfLoader
    ;sub     esp, 18
    ;mov     [esp + 12], es 
    ;mov     [esp + 10], word boot_message        
    ;mov     ax, [boot_message_len]
    ;mov     [esp + 8], ax

    ;mov     [esp + 4], es
    ;mov     [esp + 2], word test_message
    ;mov     ax, [test_message_len]
    ;mov     [esp], ax
    ;call    CmpStr

    pop     ax
    pop     ebp
    ret

DispTestMessage:
    push    ebp
    mov     ebp, esp
    push    ax

    sub     esp, 4 
    mov     ax, [test_message_len] 

    mov     [esp + 2], ax
    mov     ax, test_message 

    mov     [esp], ax

    call    DispStr
    add     esp, 4

    call    DispRet

    pop     ax
    pop     ebp
    ret
;end of DispTestMessage

DispDebugMessage:
    push    ebp
    mov     ebp, esp
    push    ax

    sub     esp, 8 
    mov     ax, [debug_message_len] 
    mov     [esp + 6], ax
    mov     [esp + 2], es
    mov     ax, debug_message 
    mov     [esp], ax

    call    DispStr
    add     esp, 8
    call    DispRet

    pop     ax
    pop     ebp
    ret
;end of DispDebugMessage


; 比较字符串是否相等
; ret       +22 +16    0 equal 1 not equal
; es        +18 +12
; di        +16 +10
; len1 2W   +14 +8
; ds        +10 +4
; si        +8  +2
; len2      +6  0
CmpStr:
    push    ebp
    mov     ebp, esp
    push    ax
    push    bx

    push    es
    push    di
    push    ds
    push    si

    mov     es, [ebp + 18]
    mov     di, [ebp + 16]
    mov     ds, [ebp + 10]
    mov     si, [ebp + 8]

    mov     ax, [ebp + 6] 
    mov     bx, [ebp + 14]

    cmp     ax, bx 
    jnz     .return_1_cmp_str
    mov     cx, ax
.loop_cmp_str:
    lodsb
    cmp     al, byte [es:di]
    jnz     .return_1_cmp_str

    inc     di
    loop    .loop_cmp_str

    mov     [ebp + 22], word 00h
    jmp     .end_cmp_str
.return_1_cmp_str:
    mov     [ebp + 22], word 01h
.end_cmp_str:
    pop     si
    pop     ds
    pop     di
    pop     es
    pop     bx
    pop     ax
    pop     ebp
    ret
;end of CmpStr


cursor              dw 160 * 0
boot_message        dw "boot ..."
boot_message_len    dw $ - boot_message

test_message        dw "boot ..."
test_message_len    dw $ - test_message

debug_message        dw "debug ..."
debug_message_len    dw $ - debug_message

load_file_name       dw "loader.com"
load_file_name_len   dw $ - load_file_name       

start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, BaseOfStack 
    mov ebp, esp

    call Clear_Screen
    call    DispDebugMessage

    call    ReadDir

    sub     esp, 18
    mov     [esp + 12], es 
    mov     [esp + 10], word boot_message        
    mov     ax, [boot_message_len]
    mov     [esp + 8], ax

    mov     [esp + 4], es
    mov     [esp + 2], word test_message
    mov     ax, [test_message_len]
    mov     [esp], ax
    call    CmpStr

    ;call    DispDebugMessage
    add     esp, 16
    ;call    DispDebugMessage

    call    DispW
    call    DispRet

    ;push    esp
    ;call    DispW
    ;call    DispRet

    ;pop     ax
    ;push    ds
    ;push    esp
    ;call    DispW
    ;call    DispRet
end:
    mov ax, 4c00h
    int 21h
    jmp $

;times 	2510-($-$$)	db	0	; 填充剩下的空间，使生成的二进制代码恰好为512字节
;dw 	0xaa55				; 结束标志

