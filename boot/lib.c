void DespStr(char * str, int strlen) {
    asm ("  mov     8(%ebp), %bp;\
            mov     12(%ebp), %cx; \
            mov     $0x1301, %ax; \
            mov     $0x07, %bx; \
            mov     $0x00, %dl; \
            int     $10; 
        );
}

