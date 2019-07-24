;[SECTION .data]
;extern KernelMessage             db  "I am Kernel started ...", 0AH
;extern KernelMessageLen          equ  $-KernelMessage             

extern helloword
extern disp_str
extern clean_screen
extern disp_pos
extern start
extern gdt_ptr
extern gdt_init
;extern init
     

times 1024 db 0
[SECTION .bss]
StackSpace      resb    2 * 1024
StackTop:       ; 栈顶

[section .text]
global _start

_start: 
    call    gdt_init
    jmp     8:init

init:
    call    clean_screen
    mov     ax, 16
    mov     ss, ax
    mov     esp, StackTop
    push    helloword
    call    disp_str
    hlt 
