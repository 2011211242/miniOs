org	0100h
jmp start

%define LOADER_BIN
%include "loader.inc"
%include "lib.inc"
%include "fat12hdr.inc"
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

ReadSec:
    push    ebp
    mov     ebp, esp

    push    bx
    push    cx
    push    dx
    push    es
    push    ax

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

    pop     ax
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
    push    ax
    push    es
    push    si
    push    dx

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

    pop     dx
    pop     si
    pop     es
    pop     ax
    pop     bx
    pop     ebp
    ret


start:
    mov     ax, cs
    mov     ds, ax
    mov     es, ax
    mov     ss, ax
    mov     esp, TopOfStack


ReadDir:
    sub     esp, 8
    mov     [esp + 6], word SectorNoOfRootDirectory
    mov     [esp + 4], word RootDirSectors		
    mov     [esp + 2], word BaseOfKernel
    mov     [esp],     word OffsetOfKernel
    call    ReadSec
    add     esp, 8

FindKernel:
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

    ;;;;;;;;;;;;;;;;;;
    ;push    ax
    ;call    DispChar
    ;pop     ax
    ;;;;;;;;;;;;;;;;;

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
    mov     [Kernel_DIR_FstClus], ax    ;获取开始簇号
    ;=====================================
    ;push    ax
    ;call    DispRet
    ;call    DispW
    ;call    DispRet
    ;pop     ax
    ;====================================
.findloader_end:
    ;ret
;end of FindLoader
    
    cmp     [Kernel_DIR_FstClus], word 0
    jnz     LoadKernel

    push    ax
    push    NoKernelMessageLen    
    push    ds
    push    NoKernelMessage       
    call    DispStr
    pop     ax
    pop     ax
    pop     ax
    pop     ax
    jmp     $

LoadKernel:
    push    ax
    push    KernelFindMessageLen    
    push    ds
    push    KernelFindMessage       
    call    DispStr
    pop     ax
    pop     ax
    pop     ax
    pop     ax
    
    mov     ax, [Kernel_DIR_FstClus]
    mov     bx, word BaseOfKernel
.loop_LoadKernel:
    push    ax

;;;;;;;;;;;;;;;;;;;;
;    call    DispW
;    call    DispRet
;;;;;;;;;;;;;;;;;;;;

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
    jnz     .loop_LoadKernel

    ;;;;;;;;;;;;;;;;;;;
    ;push    ax
    ;call    DispW
    ;call    DispRet
    ;;;;;;;;;;;;;;;;;;

    ;jmp     BaseOfKernel:OffsetOfKernel
    ;push    ax         ;调试信息
    ;push    word 20h
    ;push    BaseOfKernel
    ;push    OffsetOfKernel
    ;call    DispStr
    ;pop     ax
    ;pop     ax
    ;pop     ax
    ;pop     ax

    push    ax
    push    KernelFindMessageLen    
    push    ds
    push    KernelFindMessage       
    call    DispStr
    pop     ax
    pop     ax
    pop     ax
    pop     ax
 

GetMemInfo:
    mov     ax, cs
    mov     es, ax

    mov     ebx, 0
    mov     di, MemChkBuf
.MemChkLoop:
    mov     eax, 0E820h
    mov     ecx, 20
    mov     edx, 0534D4150h
    int     15h
    jc      .MemChkFail
    add     di, 20
    inc     dword [dwMCRNumber]
    cmp     ebx, 0
    jne     .MemChkLoop
    jmp     .MemChkOK
.MemChkFail:
    mov     dword [dwMCRNumber], 0 
.MemChkOK:
    
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
    mov eax, [cursor]
    mov [pm_disp_pos], eax
	jmp	dword SelectorFlatC:(BaseOfLoaderPhyAddr+LABEL_PM_START)    ; 真正进入保护模式


;[SECTION .s32]
ALIGN   32      ;变量的对齐方式
[BITS   32]     ;选择32位指令
%include "pmlib.inc"

DispMemInfo:
    push    esi
    push    edi
    push    ecx

    push    30h
    push    szMemChkTitle
    call    PM_DispStr
    add     esp, 8

    mov     esi, MemChkBuf
    mov     ecx, [dwMCRNumber]
.loop:
    mov     edx, 5
    mov     edi, ARDStruct
.loop1:
    push    dword [esi]
    call    PM_DispDW
    pop     eax
    stosd
    add     esi, 4
    dec     edx
    cmp     edx, 0
    jnz     .loop1
    call    PM_DispRet
    cmp     dword [dwType], 1
    jne     .2
    mov     eax, [dwBaseAddrLow]
    add     eax, [dwLengthLow]
    cmp     eax, [dwMemSize]
    jb      .2
    mov     [dwMemSize], eax
.2:
    loop    .loop
    push    dword 0009h
    push    dword szRAMSize
    call    PM_DispStr
    add     esp, 8

    push    dword [dwMemSize]
    call    PM_DispDW
    add     esp, 4
    pop     ecx
    pop     edi
    pop     esi
    ret

MemCpy:
    push    ebp
    mov ebp, esp

    push    esi
    push    edi
    push    ecx

    mov edi, [ebp + 8]  ; Destination
    mov esi, [ebp + 12] ; Source
    mov ecx, [ebp + 16] ; Counter

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;push    ax
    ;mov     eax, ds
    ;push    eax

    ;mov     ax, SelectorLoaderRW
    ;mov     ds, ax
    ;call    PM_DispRet
    ;call    PM_DispRet

    ;call    PM_DispDW
    ;call    PM_DispRet
    ;pop     eax

    ;mov     eax, es
    ;push    eax
    ;call    PM_DispDW
    ;call    PM_DispRet
    ;pop     eax

    ;push    esi
    ;call    PM_DispDW
    ;pop     esi

    ;push    edi
    ;call    PM_DispRet
    ;call    PM_DispDW
    ;pop     edi

    ;mov	    ax, SelectorFlatRW
    ;mov	    ds, ax
    ;pop     ax
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.mem_cpy_1:
    cmp ecx, 0      ; 判断计数器
    jz  .mem_cpy_2  ; 计数器为零时跳出

    mov al, [ds:esi]        ; ┓
    inc esi         ; ┃
                    ; ┣ 逐字节移动
    mov byte [es:edi], al   ; ┃ 
    inc edi         ; ┛

    dec ecx         ; 计数器减一
    jmp .mem_cpy_1  ; 循环
.mem_cpy_2:
    mov eax, [ebp + 8]  ; 返回值
    pop ecx 
    pop edi 
    pop esi 
    mov esp, ebp 
    pop ebp 
    ret

; 启动分页机制 --------------------------------------------------------------
SetupPaging:
	; 根据内存大小计算应初始化多少PDE以及多少页表
	xor	edx, edx
	mov	eax, [dwMemSize]
	mov	ebx, 400000h	; 400000h = 4M = 4096 * 1024, 一个页表对应的内存大小
	div	ebx
	mov	ecx, eax	; 此时 ecx 为页表的个数，也即 PDE 应该的个数
	test	edx, edx
	jz	.no_remainder
	inc	ecx		; 如果余数不为 0 就需增加一个页表
.no_remainder:
	push	ecx		; 暂存页表个数

	; 为简化处理, 所有线性地址对应相等的物理地址. 并且不考虑内存空洞.

	; 首先初始化页目录

    mov     ax, SelectorFlatRW
    mov     ds, ax

	mov	ax, SelectorFlatRW
	mov	es, ax
	mov	edi, PageDirBase	; 此段首地址为 PageDirBase
	xor	eax, eax
	mov	eax, PageTblBase | PG_P  | PG_USU | PG_RWW
.1:
	stosd
	add	eax, 4096		; 为了简化, 所有页表在内存中是连续的.
	loop	.1

	; 再初始化所有页表
	pop	eax			; 页表个数
	mov	ebx, 1024		; 每个页表 1024 个 PTE
	mul	ebx
	mov	ecx, eax		; PTE个数 = 页表个数 * 1024
	mov	edi, PageTblBase	; 此段首地址为 PageTblBase
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.2:
	stosd
	add	eax, 4096		; 每一页指向 4K 的空间
	loop	.2

	mov	eax, PageDirBase
	mov	cr3, eax
	mov	eax, cr0
	or	eax, 80000000h
	mov	cr0, eax
	jmp	short .3
.3:
	nop

	ret
; 分页机制启动完毕 ----------------------------------------------------------



; InitKernel ---------------------------------------------------------------------------------
; 将 KERNEL.BIN 的内容经过整理对齐后放到新的位置
; --------------------------------------------------------------------------------------------
InitKernel:	; 遍历每一个 Program Header，根据 Program Header 中的信息来确定把什么放进内存，放到什么位置，以及放多少。
	mov	    ax, SelectorFlatRW
	mov	    ds, ax
    mov     es, ax
	
	xor	    esi, esi
	mov	    cx, word [BaseOfKernelFilePhyAddr + 2Ch]; ┓ ecx <- pELFHdr->e_phnum
	movzx	ecx, cx					; ┛

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;push    ax
    ;mov     ax, SelectorLoaderRW
    ;mov     ds, ax
    ;push    ecx
    ;call    PM_DispRet
    ;call    PM_DispDW
    ;mov	    ax, SelectorFlatRW
    ;mov	    ds, ax
    ;pop     ecx
    ;pop     ax
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    
	mov	    esi, [BaseOfKernelFilePhyAddr + 1Ch]	; esi <- pELFHdr->e_phoff
	add	    esi, BaseOfKernelFilePhyAddr		    ; esi <- OffsetOfKernel + pELFHdr->e_phoff
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;push    ax
    ;mov     ax, SelectorLoaderRW
    ;mov     ds, ax
    ;push    esi
    ;call    PM_DispRet
    ;call    PM_DispDW
    ;mov	    ax, SelectorFlatRW
    ;mov	    ds, ax
    ;pop     esi
    ;pop     ax
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.Begin:
	mov	    eax, [esi + 0]
	cmp	    eax, 0				; PT_NULL
	jz	    .NoAction
	push	dword [esi + 010h]		; size	┓
	mov	    eax, [esi + 04h]		;	┃
	add	    eax, BaseOfKernelFilePhyAddr	;	┣ ::memcpy(	(void*)(pPHdr->p_vaddr),
	push	eax				; src	┃		uchCode + pPHdr->p_offset,
	push	dword [esi + 08h]		; dst	┃		pPHdr->p_filesz;
	call	MemCpy				;	┃
	add	    esp, 12				;	┛
.NoAction:
	add	esi, 020h			; esi += pELFHdr->e_phentsize
	dec	ecx
	jnz	.Begin
	ret
; InitKernel ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


LABEL_PM_START:
    mov     ax, SelectorVideo
    mov     gs, ax
    mov     ax, SelectorLoaderRW
    mov     ds, ax
    mov     es, ax
    mov     fs, ax

    mov     ax, SelectorStack           
    mov     ss,  ax
    mov     esp, StackSize               

    ;mov     [POS], dword 10
    push    BootMessageLen
    push    BootMessage
    call    PM_DispStr
    add     esp, 8

    call    DispMemInfo

    ;mov     ax, SelectorFlatC           
    ;mov     ds, ax

    call    SetupPaging
    call    InitKernel
    jmp     SelectorFlatC:KernelEntryPointPhyAddr
    jmp     $


[SECTION .data]
ALIGN   8
BootMessage             db  "Kernel loaded", 0AH
BootMessageLen          equ  $ - BootMessage             

StackSize               equ     1024
StackSpace:             times   StackSize   db  0
TopOfStack              equ $

KernelFileName          db  "KERNEL  BIN", 0 ;LOADER.COM文件名
Kernel_DIR_FstClus      dw  0
IsOdd                   db  0
IsStrEqu                db  0
NoKernelMessage         db  "No kernel", 0AH,0DH
NoKernelMessageLen      equ $ - NoKernelMessage         

KernelFindMessage       db "Kernel find", 0AH
KernelFindMessageLen    equ $ - KernelFindMessage       

LABEL_DATA:
; 保护模式下使用这些符号
; 字符串
szMemChkTitle:         db  "BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0
szRAMSize:         db  "RAM size:", 0
szReturn:          db  0Ah, 0
;; 变量
dwMCRNumber:       dd   0; Memory Check Result
dwDispPos:         dd  (80 * 6 + 0) * 2    ; 屏幕第 6 行, 第 0 列。
dwMemSize:         dd  0
ARDStruct:         ; Address Range Descriptor Structure
    dwBaseAddrLow:     dd  0
    dwBaseAddrHigh:    dd  0
    dwLengthLow:       dd  0
    dwLengthHigh:      dd  0
    dwType:        dd  0
MemChkBuf: times   256 db  0
