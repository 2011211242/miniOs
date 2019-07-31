#include <protect.h>
#include <const.h>
#include <message.h>

static  char    gdt_ptr[6];
static  GDT_DESCRIPTOR gdt[GDT_SIZE];

void GDT_INIT(GDT_DESCRIPTOR * GDT, int Base, int Limit, int Attr) {
    GDT -> limit_low    =   Limit & 0xFFFF;
    GDT -> base_low     =   Base & 0xFFFF;
    GDT -> base_mid     =   (Base >> 16) & 0xFF;
    GDT -> attr1        =   Attr & 0x0FF;
    GDT -> limit_high_attr2 = ((Limit >> 16) & 0x0F) | ((Attr >> 8) & 0xF0);
    GDT -> base_high       =   (Base >> 24) & 0x0FF;
}


void gdt_init() {
    GDT_INIT(&gdt[0], 0x0, 0x0, 0x0);
    GDT_INIT(&gdt[1], 0x0, 0xfffff, DA_CR|DA_32|DA_LIMIT_4K);
    GDT_INIT(&gdt[2], 0x0, 0xfffff, DA_DRW|DA_32|DA_LIMIT_4K);
    GDT_INIT(&gdt[3], 0x0B8000, 0xffff, DA_DRW|DA_DPL3);

    /* gdt_ptr[6] 共 6 个字节：0~15:Limit  16~47:Base。用作 sgdt/lgdt 的参数。*/
    short* p_gdt_limit = (short*)(&gdt_ptr[0]);
    int* p_gdt_base  = (int*)(&gdt_ptr[2]);
    *p_gdt_limit = GDT_SIZE * sizeof(GDT_DESCRIPTOR) - 1;
    *p_gdt_base  = (int)(gdt);

    asm ("lgdt (,%0,1)"::"r"(gdt_ptr):);
}

static void out_byte(short port, char value)
{
    asm("mov %0, %%dx; \
            mov %1, %%al; \
            out %%al, %%dx;\
            nop; nop;"
            :
            :"r"(port), "r"(value)
            :"%al", "%dx"
    );
}

static char in_byte(short port)
{
    char ret;
    asm("mov %1, %%dx; \
            xor %%al, %%al; \
            in %%dx, %%al; \
            mov %%al, %0; \
            nop; nop;" 
            :"=r"(ret)
            :"r"(port)
            :"%al", "%dx"
    );
    return ret;
}

void init_8295A()
{
    /* Master 8259, ICW1. */
    out_byte(INT_M_CTL, 0x11);

    /* Slave  8259, ICW1. */
    out_byte(INT_S_CTL, 0x11);

    /* Master 8259, ICW2. 设置 '主8259' 的中断入口地址为 0x20. */
    out_byte(INT_M_CTLMASK, INT_VECTOR_IRQ0);

    /* Slave  8259, ICW2. 设置 '从8259' 的中断入口地址为 0x28 */
    out_byte(INT_S_CTLMASK, INT_VECTOR_IRQ8);

    /* Master 8259, ICW3. IR2 对应 '从8259'. */
    out_byte(INT_M_CTLMASK, 0x4);

    /* Slave  8259, ICW3. 对应 '主8259' 的 IR2. */
    out_byte(INT_S_CTLMASK, 0x2);

    /* Master 8259, ICW4. */
    out_byte(INT_M_CTLMASK, 0x1);

    /* Slave  8259, ICW4. */
    out_byte(INT_S_CTLMASK, 0x1);

    /* Master 8259, OCW1.  */
    out_byte(INT_M_CTLMASK, 0xFD);

    /* Slave  8259, OCW1.  */
    out_byte(INT_S_CTLMASK, 0xFF);
}


