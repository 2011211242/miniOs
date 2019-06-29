org	0100h

jmp start

%include "pm.inc"
%include "loader.inc"


;                                   段基址      段界限      属性
LABEL_GDT:              Descriptor  0,          0,          0       ;空描述符   
LABEL_DESC_FLAT_C:      Descriptor  0,          0fffffh,  DA_CR|DA_32|DA_LIMIT_4K 
LABEL_DESC_FLAT_RW:     Descriptor  0,          0fffffh,  DA_DRW|DA_32|DA_LIMIT_4K    ;
LABEL_DESC_VIDEO:       Descriptor  0B8000h,    0ffffh,   DA_DRW|DA_DPL3              ;显存首地址

GdtLen                  equ     $ - LABEL_GDT
GdtPtr                  dw      GdtLen  - 1
                        dd      BaseOfLoaderPhyAddr + LABEL_GDT

SelectorFlatC           equ     LABEL_DESC_FLAT_C   - LABEL_GDT
SelectorFlatRW          equ     LABEL_DESC_FLAT_RW  - LABEL_GDT
SelectorVideo           equ     LABEL_DESC_VIDEO    - LABEL_GDT + SA_RPL3

BootMessage             db  "Loader started ...", 0AH,0DH
BootMessageLen          equ  $-BootMessage             

start:
    mov     ax, cs
    mov     ds, ax
    mov     es, ax
    mov     ss, ax


    ;mov     cx, BootMessageLen
    ;mov     bp, word BootMessage
    ;mov     ax, 01301h
    ;mov     bx, 000fh
    ;mov     dx, cs
    ;mov     es, dx
    ;mov     dx, 000h
    ;int     10h

GO_TO_PM_MODE:
    
	lgdt	[GdtPtr]

; 关中断
	cli

; 打开地址线A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al

; 准备切换到保护模式
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax

; 真正进入保护模式
	jmp	dword SelectorFlatC:(BaseOfLoaderPhyAddr+LABEL_PM_START)


    ;lgdt    [GdtPtr]

    ;cli

    ;in      al, 92h
    ;or      al, 002h
    ;out     92h, al

    ;mov     eax, cr0
    ;or      eax, 1
    ;mov     cr0, eax
    ;jmp     dword SelectorFlatC:(BaseOfLoaderPhyAddr + LABEL_PM_START)
    

[SECTION .s32]
ALIGN   32
[BITS   32]

LABEL_PM_START:
    mov     ax, SelectorVideo
    mov     gs, ax
    mov     ax, SelectorFlatRW
    mov     ds, ax
    mov     es, ax
    mov     fs, ax
    mov     ss, ax

    mov     ah, 0Fh
    mov     al, 'P'
    mov     [gs:((80 * 0 + 4) * 2)], ax
    jmp     $

