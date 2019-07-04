org	0100h
jmp start

%define LOADER_BIN
%include "loader.inc"
%include "pm.inc"
%include "lib.inc"
%include "fat12hdr.inc"

;                                   段基址                  段界限                              属性
LABEL_GDT:              Descriptor  0,                      0,                                  0       ;空描述符   
LABEL_DESC_FLAT_C:      Descriptor  0,                      0fffffh,                            DA_CR|DA_32|DA_LIMIT_4K 
LABEL_DESC_FLAT_RW:     Descriptor  0,                      0fffffh,                            DA_DRW|DA_32|DA_LIMIT_4K    ;

LABEL_DESC_LOADER_C:    Descriptor  BaseOfLoaderPhyAddr,    0fffffh - BaseOfLoaderPhyAddr,      DA_CR|DA_32|DA_LIMIT_4K     ;
LABEL_DESC_LOADER_RW:   Descriptor  BaseOfLoaderPhyAddr,    0fffffh - BaseOfLoaderPhyAddr,      DA_DRW|DA_32|DA_LIMIT_4K    ;

LABEL_DESC_STACK:       Descriptor  0,                      StackSize,                              DA_DRW|DA_32|DA_LIMIT_4K    ; 
LABEL_DESC_VIDEO:       Descriptor  0B8000h,                0ffffh,                             DA_DRW|DA_DPL3              ;显存首地址

GdtLen                  equ     $ - LABEL_GDT
GdtPtr                  dw      GdtLen  - 1
                        dd      BaseOfLoaderPhyAddr + LABEL_GDT

SelectorFlatC           equ     LABEL_DESC_FLAT_C       - LABEL_GDT
SelectorFlatRW          equ     LABEL_DESC_FLAT_RW      - LABEL_GDT
SelectorLoaderC         equ     LABEL_DESC_LOADER_C     - LABEL_GDT
SelectorLoaderRW        equ     LABEL_DESC_LOADER_RW    - LABEL_GDT
SelectorStack           equ     LABEL_DESC_STACK        - LABEL_GDT
SelectorVideo           equ     LABEL_DESC_VIDEO        - LABEL_GDT + SA_RPL3

ReadSec:
    push    ebp
    mov     ebp, esp

    push    bx
    push    cx
    push    dx
    push    es

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

    pop     es
    pop     dx
    pop     cx
    pop     bx

    pop     ebp
    ret

;加载根目录区
;ReadDir:
;    sub     esp, 8
;    mov     [esp + 6], word SectorNoOfRootDirectory
;    mov     [esp + 4], word RootDirSectors		
;    mov     [esp + 2], word BaseOfLoader        
;    mov     [esp],     word OffsetOfLoader      
;    call    ReadSec
;    add     esp, 8
;    ret

GetFATEntry:
    push    ebp
    mov     ebp, esp
    push    bx

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

    pop     bx
    pop     ebp
    ret


start:
    mov     ax, cs
    mov     ds, ax
    mov     es, ax
    mov     ss, ax
    mov     esp, OffsetOfLoader      

ReadDir:
    sub     esp, 8
    mov     [esp + 6], word SectorNoOfRootDirectory
    mov     [esp + 4], word RootDirSectors		
    mov     [esp + 2], word BaseOfKernel
    mov     [esp],     word OffsetOfKernel
    call    ReadSec
    add     esp, 8

FindLoader:
    mov     cx, [BPB_RootEntCnt]
    mov     ax, word BaseOfKernel
    mov     es, ax
.loop_next_ent:
;begining of CmpStr:
    push    cx
    push    ax
    mov     si, word KernelFileName
    mov     cx, 0bh

    mov     di, word OffsetOfKernel
.loop_cmp_str:
    lodsb
    cmp     al, byte [es:di]
    jnz     .return_1_cmp_str

    inc     di
    loop    .loop_cmp_str

    mov     [IsStrEqu], byte 00h            
    jmp     .end_cmp_str
.return_1_cmp_str:
    mov     [IsStrEqu], byte 01h            
.end_cmp_str:
    pop     ax
    pop     cx
;end of CmpStr

    cmp     [IsStrEqu], byte 00h
    jz      .entry_founded
    
    add     ax, word 002h
    mov     es, ax
    loop    .loop_next_ent
    jmp     .findloader_end
.entry_founded:                 ;目录条目已经找到
    mov     di, word OffsetOfKernel + 0x1A
    mov     ax, [es:di]
    mov     [Loader_DIR_FstClus], ax    ;获取开始簇号
.findloader_end:
    ;ret
;end of FindLoader
    
    cmp     [Loader_DIR_FstClus], word 0
    jnz     LoadLoader

    push    ax
    push    NoKernelMessageLen    
    push    ds
    push    NoKernelMessage       
    call    DispStr
    pop     ax
    pop     ax
    pop     ax
    pop     ax

LoadLoader:
    push    ax
    push    KernelFindMessageLen    
    push    ds
    push    KernelFindMessage       
    call    DispStr
    pop     ax
    pop     ax
    pop     ax
    pop     ax
    
    mov     ax, [Loader_DIR_FstClus]
    mov     bx, word BaseOfKernel
.loop_LoadLoader:
    push    ax

    add     ax, SectorNoOfData
    sub     esp, 8
    mov     [esp + 6], ax ;+ SectorNoOfData
    mov     [esp + 4], word 001h
    mov     [esp + 2], bx
    mov     [esp], word OffsetOfKernel
    call    ReadSec
    add     esp, 8

    pop     ax
    sub     esp, 4
    mov     [esp], ax
    call    GetFATEntry
    mov     ax, [esp + 2]
    add     esp, 4

    add     bx, 20h
    cmp     ax, 0fffh
    jnz     .loop_LoadLoader


    push    ax
    push    word 20h
    push    BaseOfKernel
    push    OffsetOfKernel
    call    DispStr
    pop     ax
    pop     ax
    pop     ax
    pop     ax


GO_TO_PM_MODE:
    xor     eax, eax                            ;初始化栈区
    mov     ax,  cs
    shl     eax, 4
    add     eax, StackSpace
    mov     [LABEL_DESC_STACK + 2], ax
    shr     eax, 16
    mov     byte [LABEL_DESC_STACK + 4], al
    mov     byte [LABEL_DESC_STACK + 7], ah

    ;LABEL_DESC_STACK
	lgdt	[GdtPtr]
	cli                     ; 关中断

	in	al, 92h             ; 打开地址线A20
	or	al, 00000010b
	out	92h, al

	mov	eax, cr0            ; 准备切换到保护模式
	or	eax, 1
	mov	cr0, eax
	jmp	dword SelectorFlatC:(BaseOfLoaderPhyAddr+LABEL_PM_START)    ; 真正进入保护模式


;[SECTION .s32]
ALIGN   32      ;变量的对齐方式
[BITS   32]     ;选择32位指令
%include "pmlib.inc"

LABEL_PM_START:
    mov     ax, SelectorVideo
    mov     gs, ax
    mov     ax, SelectorLoaderRW
    mov     ds, ax
    mov     es, ax
    mov     fs, ax

    mov     eax, SelectorStack           
    mov     ss,  eax
    mov     esp, StackSize               

    ;mov     [POS], dword 10
    push    BootMessageLen
    push    BootMessage
    call    PM_DispStr
    call    PM_DispStr
    call    PM_DispStr
    call    PM_DispStr

    ;push    word 'P'
    ;call    PM_DispChar
    ;jmp     $

    push    esp
    call    PM_DispRet

    push    word ' '
    push    esp
    call    PM_DispDW
    jmp     $

    ;ret
    ;call    LoadLoader
    ;jmp BaseOfLoader:OffsetOfLoader


[SECTION .data]
ALIGN   8
BootMessage             db  "Loader loaded", 0AH, "Loding Kernel ...", 0AH
BootMessageLen          equ  $ - BootMessage             

StackSize               equ     1024
StackSpace:             times   StackSize   db  0

KernelFileName          db  "KERNEL  BIN", 0 ;LOADER.COM文件名
Loader_DIR_FstClus      dw  0
IsOdd                   db  0
IsStrEqu                db  0
NoKernelMessage         db  "No kernel", 0AH,0DH
NoKernelMessageLen      equ $ - NoKernelMessage         

KernelFindMessage       db "Kernel find", 0AH
KernelFindMessageLen    equ $ - KernelFindMessage       

