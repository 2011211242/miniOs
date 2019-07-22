#include <protect.h>
#include <const.h>
#include <message.h>

char    gdt_ptr[6];
static  GDT_DESCRIPTOR gdt[GDT_SIZE];

void memcpy(void* p_dst, void* p_src, int size)
{
    for(int i = 0; i < size; i++)
    {

    }
}




//typedef struct s_descriptor     /* 共 8 个字节 */
//{
//    short limit_low;      /* Limit */
//    short base_low;       /* Base */
//    char base_mid;       /* Base */
//    char attr1;          /* P(1) DPL(2) DT(1) TYPE(4) */
//    char limit_high_attr2;   /* G(1) D(1) 0(1) AVL(1) LimitHigh(4) */
//    char base_high;     /* Base */
//} GDT_DESCRIPTOR;




/*
#define GDT_INIT(GDT, Base, Limit, Attr) \
    GDT.limit_low       =   Limit & 0x0FFFF, \
    GDT.base_low        =   Base & 0x0FFFF,  \
    GDT.base_mid        =   (Base >> 16) & 0x0FF, \
    GDT.limit_high_attr =   ((Limit >> 8) & 0x0F00 | (Attr & 0xF0FF)), \
    GDT.base_high       =   (Base >> 24) & 0x0FF
*/

void GDT_INIT(GDT_DESCRIPTOR * GDT, int Base, int Limit, int Attr) {
    GDT -> limit_low    =   Limit & 0xFFFF;
    GDT -> base_low     =   Base & 0xFFFF;
    GDT -> base_mid     =   (Base >> 16) & 0xFF;
    GDT -> attr1        =   Attr & 0x0FF;
    GDT -> limit_high_attr2 = ((Limit >> 16) & 0x0F) | ((Attr >> 8) & 0xF0);
    GDT -> base_high       =   (Base >> 24) & 0x0FF;

    //GDT -> limit_high_attr =   ((Limit >> 8) & 0x0F00) | (Attr & 0x0F0FF)
}



static void gdt_init() {
    GDT_INIT(&gdt[0], 0x0, 0x0, 0x0);
    //GDT_INIT(&gdt[1], 0x0, 0x0, DA_CR|DA_32|DA_LIMIT_4K);

    GDT_INIT(&gdt[1], 0x0, 0xfffff, DA_CR|DA_32|DA_LIMIT_4K);
    GDT_INIT(&gdt[2], 0x0, 0xfffff, DA_DRW|DA_32|DA_LIMIT_4K);
    GDT_INIT(&gdt[3], 0x0B8000, 0xffff, DA_DRW|DA_DPL3);

     //memcpy(&gdt,                  /* New GDT */
     //      (void*)(*((int*)(&gdt_ptr[2]))),   /* Base  of Old GDT */
     //     *((short*)(&gdt_ptr[0])) + 1      /* Limit of Old GDT */
     //   );

    /* gdt_ptr[6] 共 6 个字节：0~15:Limit  16~47:Base。用作 sgdt/lgdt 的参数。*/
    short* p_gdt_limit = (short*)(&gdt_ptr[0]);
    int* p_gdt_base  = (int*)(&gdt_ptr[2]);
    *p_gdt_limit = GDT_SIZE * sizeof(GDT_DESCRIPTOR) - 1;
    *p_gdt_base  = (int)(&gdt);


    //*(short *)(&gdt_ptr[0]) = sizeof(GDT_DESCRIPTOR) * GDT_SIZE - 1;
    //*(int *)(&gdt_ptr[2]) = (int)gdt;
    //asm ("lgdt (,%0,1)"::"r"(gdt_ptr):);
}

void start()
{
    clean_screen();
    disp_char('\n', '0xf0');
    disp_int(sizeof(int));


    disp_char('\n', '0xf0');
    disp_int(sizeof(short));

    //disp_str("\n");
    disp_char('\n', '0xf0');
    disp_int(sizeof(char));

    disp_char('\n', '0xf0');
    disp_int(sizeof(GDT_DESCRIPTOR));
    disp_char('\n', '0xf0');

    //gdt_init();
}

void init()
{

}
