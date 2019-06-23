%define _BOOT_DEBUG_

%ifdef _BOOT_DEBUG_
    BOOTBASE equ 0100h
%else
    BOOTBASE equ 07c00h
%endif

BaseOfStack equ BOOTBASE 
org    BOOTBASE 

jmp start
nop

%include "fat12hdr.inc"


;stack resb 32
;打印一个字符
;DispChar:
;    push    ebp
;    mov     ebp, esp
;
;    push    ax
;    push    bx
;    push    dx
;    push    cx
;
;    mov	ax, [ebp + 6]
;    cmp al, 0ah 
;    jz .DispChar_handle_Ret
;
;    mov	dx, 0B800h
;    mov	gs, dx
;    mov	ah, 0Fh				; 0000: 黑底    1111: 白字
;    mov bx, [cursor]
;
;    cmp bx, 160 * 25
;    jnae .DispChar_handle_cursor
;    mov bx, 0
;.DispChar_handle_cursor:
;    mov	[gs:bx], ax	        ;屏幕第 0 行, 第 39 列。
;    add bx, 02h
;    mov [cursor], bx
;    jmp .DispChar_handle_restore
;
;.DispChar_handle_Ret:
;    call  DispRet
;
;.DispChar_handle_restore:
;    pop cx
;    pop dx
;    pop bx
;    pop ax
;    pop ebp
;    ret
;; end of 打印一个字符

;DispRet:       ;换行
;    push    ebp
;    mov     ebp, esp
;
;    push ax
;    push bx
;
;    mov ax, [cursor]
;    mov bl, 0a0h
;    div bl
;    inc al
;    cmp al, 25
;    jnae .DispRet_handle_cursor
;    mov al, 0
;
;.DispRet_handle_cursor:
;    mul bl
;    mov [cursor], ax
;
;    pop bx
;    pop ax
;    pop ebp
;    ret

;打印Word的十六进制数字串
;DispW:
;    push    ebp
;    mov     ebp, esp
;    push    ax
;    push    cx
;
;    mov     cl, 010h
;.DispW_loop:
;    mov     ax, [ebp + 6]
;    cmp     cl, 0
;    jz      .DispW_handle_end
;    sub     cl, 4
;    shr     ax, cl
;    and     ax, 00fh
;
;    cmp     al, 09h
;    ja      .DispW_loop_Digit_handle_greaer_9
;
;    add     al, '0'
;    jmp     .DispW_loop_Digit_handle_print
;
;.DispW_loop_Digit_handle_greaer_9:
;    sub     al, 0ah
;    add     al, 'a'
;
;.DispW_loop_Digit_handle_print:
;    push    ax
;    call    DispChar
;    pop     ax
;    jmp     .DispW_loop
;
;.DispW_handle_end:
;    pop     cx
;    pop     ax
;    pop     ebp
;    ret
;;end of 打印dw的十六进制数字串

;Clear_Screen:
;    push    ebp
;    mov     ebp, esp
;
;    push    ax
;    push    cx
;
;    mov     ax, ' ' ;空格
;    sub     esp, 2
;    mov     [esp], ax
;
;    mov     cx, 80 * 25
;
;Clear_Screen_loop:          
;    call    DispChar
;    loop    Clear_Screen_loop
;
;    add     esp, 2
;
;    pop     cx
;    pop     ax
;    pop     ebp
;    ret
;;end of Clear_Screen

;DispStr:
;    push    ebp
;    mov     ebp, esp
;
;    push    si
;    push    cx
;    push    bx
;    push    es
;
;    mov     cx, [ebp + 10] 
;    mov     es, [ebp + 8]
;    mov     si, [ebp + 6]
;
;    xor     bh, bh
;.DispStr_loop:
;    mov     bl, [es:si]
;    push    bx
;    call    DispChar
;    pop     bx
;    inc     si
;    loop    .DispStr_loop
;
;    pop     es
;    pop     bx
;    pop     cx
;    pop     si 
;    pop     ebp 
;    ret
;; end of DispStr
;ResetDisk:
;    xor     ah, ah
;    xor     dl, dl
;    int     13h
;    ret
;------------------------------------
;dw      起始扇区号
;dw      要读的扇区数, <= 256
;es:bx   目的缓冲区地址
;------------------------------------
ReadSec:
    push    ebp
    mov     ebp, esp

    push    cx
    push    dx

    ;push    ax
    ;push    cx
    ;push    dx
    ;push    es
    ;push    bx
    
    mov     ax, word [ebp + 12]          ;起始扇区
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
    mov     bx, [ebp + 6]
.GoOnReading:
    mov     ah, 2
    int     13h

    jc      .GoOnReading

    pop     dx
    pop     cx

    ;pop     bx
    ;pop     es
    ;pop     ax

    pop     ebp
    ret

;加载根目录区
ReadDir:
    ;push    ebp
    ;mov     ebp, esp

    sub     esp, 8
    mov     [esp + 6], word SectorNoOfRootDirectory
    mov     [esp + 4], word RootDirSectors		
    mov     [esp + 2], word BaseOfLoader        
    mov     [esp],     word OffsetOfLoader      
    call    ReadSec
    add     esp, 8

    ;pop     ebp
    ret

GetFATEntry:
    push    ebp
    mov     ebp, esp
    ;push    ax
    push    bx
    ;push    dx
    ;push    es

    mov     ax, [ebp + 6]
    mov     [IsOdd], byte 0
    mov     bx, 3
    mul     bx
    mov     bx, 2
    mov     dx, 0               ;被除数32位,高位存在dx中
    div     bx
    mov     byte [IsOdd], dl    ;余数是否为0
                                ;ax为FATEntry 在FAT中的偏移量
    mov     dx,  0
    mov     bx, [BPB_BytsPerSec]
    div     bx                  
    add     ax, SectorNoOfFAT1  ;ax为扇区号
                                ;dx存储偏移

    sub     esp, 8
    mov     [esp + 6], ax
    mov     [esp + 4], word 2
    mov     [esp + 2], word BaseOfFAT
    mov     [esp],     word OffsetOfFAT
    call    ReadSec
    add     esp, 8
    
    mov     ax, word BaseOfFAT
    mov     es, ax
    mov     si, dx
    mov     ax, [es:si]     ;ax为对应数据的扇区号

    cmp     byte [IsOdd], 1
    jnz     .FATEntry_even
    shr     ax, 4
.FATEntry_even:
    and     ax, 0FFFh
    mov     [ebp + 8], ax

    ;pop     es
    ;pop     dx
    pop     bx
    ;pop     ax
    pop     ebp
    ret

;DispBootMessage:
;    push    ebp
;    mov     ebp, esp
;    push    ax
;
;    sub     esp, 6 
;    mov     ax, [boot_message_len] 
;    mov     [esp + 4], ax
;    mov     [esp + 2], ds
;    mov     ax, boot_message 
;    mov     [esp], ax
;
;    call    DispStr
;    add     esp, 6
;    call    DispRet
;    
;    pop     ax
;    pop     ebp
;    ret
;end of DispDebugMessage


; 比较字符串是否相等
; ret       +16 +10   0 equal 1 not equal
; es        +14 +8
; di        +12 +6
; len1 2W   +10 +4
; si        +8  +2
; len2      +6  0
CmpStr:
    push    ebp
    mov     ebp, esp

    ;push    ax
    ;push    bx
    ;push    cx
    ;push    es
    ;push    di
    ;push    si

    mov     es, [ebp + 14]
    mov     di, [ebp + 12]
    mov     bx, [ebp + 10]
    mov     si, [ebp + 8]
    mov     ax, [ebp + 6] 

    cmp     ax, bx 
    jnz     .return_1_cmp_str
    mov     cx, ax
.loop_cmp_str:
    lodsb
    cmp     al, byte [es:di]
    jnz     .return_1_cmp_str

    inc     di
    loop    .loop_cmp_str

    mov     [ebp + 16], word 00h
    jmp     .end_cmp_str
.return_1_cmp_str:
    mov     [ebp + 16], word 01h
.end_cmp_str:
    ;pop     si
    ;pop     di
    ;pop     es
    ;pop     cx
    ;pop     bx
    ;pop     ax

    pop     ebp
    ret
;end of CmpStr

FindLoader:
;    push    ebp
;    mov     ebp, esp

;    push    cx
;    push    ax
;    push    es
;    push    di

    mov     cx, [BPB_RootEntCnt]
    sub     esp, 12
    mov     [esp + 8], word BaseOfLoader
    mov     [esp + 6], word OffsetOfLoader
    mov     [esp + 4], word 0bh
    mov     [esp + 2], word LoaderFileName
    mov     [esp], word 0bh
.loop_next_ent:
    call    CmpStr

;;;;;;;;;;;;;;;;;
    cmp     [esp + 10], word 000h
    jz      .entry_founded
    
    add     [esp + 8], word 002h
    loop    .loop_next_ent
    jmp     .findloader_end
.entry_founded:                 ;目录条目已经找到
    mov     es, [esp + 8]
    mov     di, [esp + 6]
    add     di, 0x1A            ;偏移量
    mov     ax, [es:di]
    mov     [Loader_DIR_FstClus], ax    ;获取开始簇号
.findloader_end:
    add     esp, 12
;    pop     di
;    pop     es
;    pop     ax
;    pop     cx

;    pop     ebp
    ret
;end of FindLoader

LoadLoader:
    ;push    ebp
    ;mov     ebp, esp
    ;push    ax
    ;push    bx 

    mov     ax, [Loader_DIR_FstClus]
    mov     bx, word BaseOfLoader
.loop_LoadLoader:
    push    ax
    add     ax, SectorNoOfData
    push    bx
    sub     esp, 8
    mov     [esp + 6], ax
    mov     [esp + 4], word 001h
    mov     [esp + 2], bx
    mov     [esp], word OffsetOfLoader      
    call    ReadSec
    add     esp, 8
    pop     bx
    pop     ax
    sub     esp, 4
    mov     [esp], ax
    call    GetFATEntry
    mov     ax, [esp + 2]
    add     esp, 4

    add     bx, 20h
    cmp     ax, 0fffh
    jnz     .loop_LoadLoader

    ;pop     bx
    ;pop     ax
    ;pop     ebp
    ret

;end of LoadLoader
;cursor                  dw 160 * 0
;boot_message            dw "boot ..."
;boot_message_len        dw $ - boot_message

;debug_message           dw "loader founded..."
;debug_message_len       dw $ - debug_message

LoaderFileName          db  "LOADER  BIN", 0 ;LOADER.COM文件名
Loader_DIR_FstClus      dw  0
IsOdd                   db 0


start:
    mov ax, cs
    mov ds, ax
    ;mov es, ax
    mov ss, ax
    mov esp, BaseOfStack 
    mov ebp, esp

    call    ReadDir
    call    FindLoader
    call    LoadLoader

    jmp BaseOfLoader:OffsetOfLoader

;times 	2510-($-$$)	db	0	; 填充剩下的空间，使生成的二进制代码恰好为512字节
;dw 	0xaa55				; 结束标志
