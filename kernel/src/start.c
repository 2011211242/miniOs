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

