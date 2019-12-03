;[SECTION .data]
;extern KernelMessage             db  "I am Kernel started ...", 0AH
;extern KernelMessageLen          equ  $-KernelMessage             

extern system_call_message
extern helloword
extern disp_str
extern clean_screen
;extern disp_pos
extern start
extern gdt_ptr
extern gdt_init
extern cs_start
extern disp_char
extern clock_handle
extern disp_int
extern sleep
extern dec_disp_pos
extern disp_ret


SELECTOR_KERNEL_CS  equ 0x08

;times 1024 db 0
[SECTION .bss]
StackSpace      resb    2 * 1024
StackTop:       ; 栈顶

;StackSpaceOfA   resb    1 * 1024
;StackTopOfA:       ;任务A的栈顶

;StackSpaceOfB   resb    1 * 1024
;StackTopOfB:       ; 任务B的栈顶

global StackTop

[section .text]
global _start
global clock
global system_call
global task_a

_start:
    call    gdt_init
    jmp     SELECTOR_KERNEL_CS:init

init:
    ;mov     ax, 0x10
    ;mov     ds, ax
    ;mov     fs, ax
    mov     ax, 0x18
    mov     gs, ax
    mov     ax, 0x10
    mov     ss, ax
    mov     ds, ax
    mov     fs, ax
    mov     esp, StackTop

    call    clean_screen

    ;push    helloword
    ;call    disp_str
    ;add     esp, 4

    push    esp
    call    disp_int
    add     esp, 4

    push    0ah
    call    disp_char
    add     esp, 4

    cli
    call    cs_start
    mov     ax, 0x38
    ltr     ax
    sti

;HLT:
;    hlt
;    jmp HLT

    ;mov     ax, 0x20
    ;ltr     ax

go_ring3:
    push    0x2b
    push    esp
    pushf
    push    0x23
    push    task_b
    iretd

    ;jmp     task_a
    ;mov     eax, 'B'
    ;mov     ebx, 0x0A
    ;int     0x80

;HLT:
;    hlt
;    jmp HLT

clock:
    ;push    0Ah
    ;push    'B'
    ;call    disp_char
    ;add     esp, 8
    call    clock_handle
    mov     al, 20h
    out     20h, al
    iretd

system_call:
    ;push    ebx
    ;push    eax
    ;call    disp_char
    ;add     esp, 8
    ;call    dec_disp_pos
    ;hlt
    xor     eax, eax
    mov     ax,  ss
    push    eax
    call    disp_int
    add     esp, 4
    call    disp_ret

    xor     eax, eax
    mov     ax, cs
    push    eax
    call    disp_int
    add     esp, 4
    call    disp_ret


    ;call    dec_disp_pos
    ;call    dec_disp_pos
    ;call    dec_disp_pos
    ;call    dec_disp_pos
    ;call    dec_disp_pos
    ;call    dec_disp_pos
    iretd


task_a:
    mov     eax, 'A'
    mov     ebx, 0x0f
    cli
    int     0x80
    sti

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

task_b:
    mov     ax, 0x2b
    mov     ds, ax
    ;mov     fs, ax
    ;mov     es, ax

    mov     ax,  0x33
    mov     gs, ax
    mov     edi, (80 * 14 + 0) * 2
    mov     ah, 0Ch
    mov     al, '3'
    mov     [gs:edi], ax


;task_b_loop:
;    add     edi, 2
;    mov     [gs:edi], ax
;    cmp     edi, 80 * 15 * 2
;    jz      task_b_end
;
;    jmp     task_b_loop

task_b_end:
    ;mov     ax, disp_pos
    xor     eax, eax
    mov     ax, ss
    push    eax
    call    disp_int
    add     esp, 4
    call    disp_ret

    xor     eax, eax
    mov     ax, cs
    push    eax
    call    disp_int
    add     esp, 4
    call    disp_ret

    mov     eax, 'B'
    mov     ebx, 0x0A
    int     0x80
    jmp     $
    ;jmp     task_b_end


