;[SECTION .data]
;extern KernelMessage             db  "I am Kernel started ...", 0AH
;extern KernelMessageLen          equ  $-KernelMessage             

extern helloword
extern disp_str
extern clean_screen
extern disp_pos

times 1024 db 0
[SECTION .bss]
StackSpace      resb    2 * 1024
StackTop:       ; 栈顶

[section .text]
global _start

_start: 
    mov     ax, cs
    ;mov     ds, ax
    ;mov     ss, ax
    ;mov     esp, StackTop

    call    clean_screen
    push    helloword
    mov     [disp_pos], dword 192 + 80 * 7;
    call    disp_str
    ;mov	gs, dx
    ;mov	ah, 08Dh				; 0000: 黑底    1111: 白字
    ;mov al, '$'
    
    mov bx, 100
    mov	[gs:bx], ax	        ;屏幕第 0 行, 第 39 列。

    jmp $
 
