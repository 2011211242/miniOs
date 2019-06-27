org	0100h
jmp start

BootMessage             db  "Loader started successful", 0AH,0DH
BootMessageLen          equ  $-BootMessage             

start:
    mov     ax, cs
    mov     ds, ax

    mov     cx, BootMessageLen
    mov     bp, word BootMessage
    mov     ax, 01301h
    mov     bx, 000fh
    mov     dx, cs
    mov     es, dx
    mov     dx, 000h
    int     10h

	jmp	$		
