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
    push    0Ah
    push    'B'
    call    disp_char
    add     esp, 8

    mov     al, 20h
    out     20h, al
    iretd

;static char c = 'b';
;void clock()
;{
;    int disp_pos = 100;
;    disp_char_int(disp_pos, c, 0x0f);
;    c = c + 1;
;    //if (c >= 'z') c = 'a';

;    for(int i = 0; i < 1000; i++)
;    {
;        asm("nop":::);
;    }
;    disp_pos += 100;
;    disp_char_int(disp_pos, c, 0x0f);
;  //while(1);
;   //if (c == 'b') asm("jmp $":::);
;    asm("hlt":::);
;}
;push    0x0f
;push         
;disp_pos = 100;
;call disp_char_int(c, 0x0f);
;hlt
;retf

