
;[section .bss]
;KernelMessage             db  "Kernel started ...", 0AH,0DH
;KernelMessageLen          equ  $-KernelMessage             


[section .text]
global _start

_start: 
    mov     ax, cs
    mov     ds, ax

    ;mov     cx, KernelMessageLen
    ;mov     bp, word KernelMessage
    mov     ax, 01301h
    mov     bx, 000fh
    mov     dx, cs
    mov     es, dx
    mov     dx, 000h
    int     10h

	jmp	$		
