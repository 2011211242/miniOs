;[SECTION .data]
;extern KernelMessage             db  "I am Kernel started ...", 0AH
;extern KernelMessageLen          equ  $-KernelMessage             

extern helloword
extern disp_str
extern clean_screen
extern disp_pos
extern start
extern gdt_ptr
;extern init
     

times 1024 db 0
[SECTION .bss]
StackSpace      resb    2 * 1024
StackTop:       ; 栈顶

[section .text]
global _start

_start: 
    sgdt    [gdt_ptr]
    ;call    start 
    lgdt    [gdt_ptr]
    jmp     8:init

init:
    call   clean_screen
    ;jmp     $
    push    helloword
    ;mov     [disp_pos], dword 192 + 80 * 7;
    call    disp_str

    mov bx, 100
    mov	[gs:bx], ax	        ;屏幕第 0 行, 第 39 列。

    jmp $
