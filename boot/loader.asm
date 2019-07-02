org	0100h
jmp start

%define LOADER_BIN
%include "loader.inc"
%include "pm.inc"

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

start:
    mov     ax, cs
    mov     ds, ax
    mov     es, ax
    mov     ss, ax

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

    call    DispStr
    jmp     $

[SECTION .data]
ALIGN   8
BootMessage             db  "Loader loaded", 0DH, 0AH, "Loding Kernel ..."
BootMessageLen          equ  $ - BootMessage             

StackSize               equ     1024
StackSpace:             times   StackSize   db  0
