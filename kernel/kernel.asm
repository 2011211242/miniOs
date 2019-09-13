;[SECTION .data]
;extern KernelMessage             db  "I am Kernel started ...", 0AH
;extern KernelMessageLen          equ  $-KernelMessage             

extern system_call_message
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
global system_call

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
    add     esp, 4
    cli
    call    cs_start
    sti

    jmp     task_a

    ;mov     eax, 'B'
    ;mov     ebx, 0x0A
    ;int     0x80

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

system_call:
    push    ebx
    push    eax
    call    disp_char
    add     esp, 8
    iretd


task_a:
    mov     eax, 'A'
    mov     ebx, 0x0f
    int     0x80
 

    mov     ecx, 0xF
loop_wait:
    push    ecx

    mov     ecx, 0xFFFFFFFF
loop_wait_1:
    nop
    loop    loop_wait_1

    pop     ecx
    loop    loop_wait

    jmp task_a

StackSpaceOfA   resb    1 * 1024
StackTopOfA:       ;任务A的栈顶

task_b:
    mov     eax, 'B'
    mov     ebx, 0x0A
    int     0x80
    jmp     task_b

StackSpaceOfB   resb    1 * 1024
StackTopOfB:       ; 任务B的栈顶
