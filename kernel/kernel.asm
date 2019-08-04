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
extern cs_start
extern disp_char
extern clock_handle

SELECTOR_KERNEL_CS  equ 0x08

;times 1024 db 0
[SECTION .bss]
StackSpace      resb    2 * 1024
StackTop:       ; 栈顶

[section .text]
global _start
global clock

_start: 
    call    gdt_init
    jmp     SELECTOR_KERNEL_CS:init

init:
    call    clean_screen
    mov     ax, 16
    mov     ss, ax
    mov     esp, StackTop
    push    helloword
    call    disp_str
    cli
    call    cs_start
    sti

HLT:
    hlt 
    jmp HLT

clock:
    ;push    0Ah
    ;push    'B'
    ;call    disp_char
    ;add     esp, 8
    call clock_handle

    mov     al, 20h
    out     20h, al
    iretd

