#include <protect.h>
#include <const.h>
#include <message.h>

extern int StackTop;
char c_pos; 
void clock();
void system_call();
void task_a();
void disp_char_int(int disp_pos, char c, char font)
{
    //asm("mov %1, %%al; \
    //            mov $0xef, %%ah; \
    //            mov %2, %%esi; \
    //            mov %%ax, %%gs:(, %%esi, 2); \
    //            add $0x01, %%esi; \
    //            mov %%esi, %0;"
    //            :"=r"(disp_pos)
    //            :"r"(c), "r"(disp_pos)      /*输出部*/
    //            :"%eax", "%esi"             /*毁坏部*/
    //       );

    switch (c)
    {
        case '\0':  
            return;
        case '\n':
            disp_pos = (disp_pos / 80 + 1) * 80; 
            break;

        default:
            asm("mov %0, %%al; \
                    mov %1, %%ah; \
                    mov %2, %%esi; \
                    mov %%ax, %%gs:(, %%esi, 2);"
                    :
                    :"r"(c), "r"(font), "r"(disp_pos)      /*输出部*/
                    :"%eax", "%esi"             /*毁坏部*/
               );

            disp_pos ++;
            break;
    }

    if (disp_pos > 25 * 80)
        disp_pos = 25 * 80;
}

/*
void clock()
{
    int disp_pos = 100;
    disp_char_int(disp_pos, c, 0x0f);
    c = c + 1;
    //if (c >= 'z') c = 'a';

    for(int i = 0; i < 1000; i++)
    {
        asm("nop":::);
    }
    disp_pos += 100;
    disp_char_int(disp_pos, c, 0x0f);
    //while(1);
    //if (c == 'b') asm("jmp $":::);
    asm("hlt":::);

}
*/

static  char    gdt_ptr[6];
static  GDT_DESCRIPTOR gdt[GDT_SIZE];

static  char    idt_ptr[6];
static  GATE    idt[IDT_SIZE];
static  PROCESS process[TSK_NUM];

void GDT_INIT(GDT_DESCRIPTOR * GDT, int Base, int Limit, int Attr) {
    GDT -> limit_low    =   Limit & 0xFFFF;
    GDT -> base_low     =   Base & 0xFFFF;
    GDT -> base_mid     =   (Base >> 16) & 0xFF;
    GDT -> attr1        =   Attr & 0x0FF;
    GDT -> limit_high_attr2 = ((Limit >> 16) & 0x0F) | ((Attr >> 8) & 0xF0);
    GDT -> base_high       =   (Base >> 24) & 0x0FF;
}

#define TSS0_SEL    0x20
#define LDT0_SEL    0x28
#define TSS1_SEL    0x30
#define LDT1_SEL    0x38

TSS tss_test;

void gdt_init() {
    GDT_INIT(&gdt[0], 0x0, 0x0, 0x0); //0x00
    GDT_INIT(&gdt[1], 0x0, 0xfffff, DA_CR|DA_32|DA_LIMIT_4K); //0x08
    GDT_INIT(&gdt[2], 0x0, 0xfffff, DA_DRW|DA_32|DA_LIMIT_4K); //0x10
    GDT_INIT(&gdt[3], 0x0B8000, 0xffff, DA_DRW|DA_DPL3); //0x18

    //GDT_INIT(&gdt[4], 0x0, 0xfffff, DA_CR|DA_32|DA_LIMIT_4K|DA_DPL3); //0x20
    GDT_INIT(&gdt[4], 0x0, 0xfffff, DA_C|DA_32|DA_LIMIT_4K|DA_DPL3);    //0x23
    GDT_INIT(&gdt[5], 0x0, 0xfffff, DA_DRW|DA_32|DA_LIMIT_4K|DA_DPL3);  //0x2b
    GDT_INIT(&gdt[6], 0x0B8000, 0xffff, DA_DRW|DA_DPL3);                //0x33

    GDT_INIT(&gdt[7], (int)&tss_test, sizeof(tss_test), DA_386TSS);          //0x38 tss

    //GDT_INIT(&gdt[4], (int)&process[0].tss, sizeof(process[0].tss), DA_386TSS); //TSS0 0x20
    //GDT_INIT(&gdt[5], (int)process[0].ldts, sizeof(process[0].ldts), DA_LDT);   //LDT0 0x28

    //GDT_INIT(&gdt[6], (int)&process[1].tss, sizeof(process[1].tss), DA_386TSS); //TSS1 0x30
    //GDT_INIT(&gdt[7], (int)process[1].ldts, sizeof(process[1].ldts), DA_LDT);   //LDT1 0x38
    //GDT_INT(&)

    /* gdt_ptr[6] 共 6 个字节：0~15:Limit  16~47:Base。用作 sgdt/lgdt 的参数。*/
    short* p_gdt_limit = (short*)(&gdt_ptr[0]);
    int* p_gdt_base  = (int*)(&gdt_ptr[2]);
    *p_gdt_limit = GDT_SIZE * sizeof(GDT_DESCRIPTOR) - 1;
    *p_gdt_base  = (int)(gdt);

    asm ("lgdt (,%0,1)"::"r"(gdt_ptr):);
}

void task0() {
    for(int i = 0; i < 10; i++)
    {

    }
}

void task1() {
}


void tss_init () {
    tss_test.ss0 = 0x10;
    tss_test.ss2 = 0x2b;
    tss_test.esp0 = &StackTop;
    tss_test.esp2 = &StackTop;
    tss_test.iobase = 0xffff;

    //int a = &StackTop;
    //disp_int(a);

    //memset(&process[0].tss, sizeof(process[0].tss), 0);
    //memset(&process[1].tss, sizeof(process[0].tss), 0);

    /*
    process[0].tss.ss0 = 16;
    process[1].tss.ss0 = 16;

    process[0].tss.esp0 = (u32)process[0].stack_kernel + sizeof(process[0].stack_kernel);
    process[1].tss.esp0 = (u32)process[1].stack_kernel + sizeof(process[1].stack_kernel);

    process[0].tss.eip = (int)task_a;
    process[0].tss.es = 0x17;
    process[0].tss.cs = 0x07;
    process[0].tss.ss = 0x17;
    process[0].tss.ds = 0x17;
    process[0].tss.fs = 0x17;
    process[0].tss.gs = 0x17;
    process[0].tss.ldt = LDT0_SEL;
    process[0].tss.iobase = sizeof(TSS);


    process[1].tss.eip = (int)task1;
    process[1].tss.es = 0x17;
    process[1].tss.cs = 0x07;
    process[1].tss.ss = 0x17;
    process[1].tss.ds = 0x17;
    process[1].tss.fs = 0x17;
    process[1].tss.gs = 0x17;
    process[1].tss.ldt = LDT1_SEL;
    process[1].tss.iobase = sizeof(TSS);
    */
}

typedef void (*int_handler) ();

static void init_idt_desc(unsigned char idx, unsigned char desc_type, int_handler handler, unsigned char privilege)
{
    GATE * p_gate           = &idt[idx];
    unsigned int base       = (unsigned int) handler;
    p_gate -> offset_low    = base & 0xFFFF;
    p_gate -> selector      = SELECTOR_KERNEL_CS;
    p_gate -> dcount        = 0;
    p_gate -> attr          = desc_type | (privilege << 5);
    p_gate -> offset_high   = (base >> 16) & 0xFFFF;
}

void idt_init() {
    init_idt_desc(0x20, DA_386IGate, clock, PRIVILEGE_KRNL);
    //init_idt_desc(0x80, DA_386IGate, system_call, PRIVILEGE_KRNL);
    //init_idt_desc(0x20, DA_386IGate, clock, PRIVILEGE_USER);

    init_idt_desc(0x80, DA_386IGate, system_call, PRIVILEGE_USER);

    //GDT_INIT(&gdt[5], (int)process[0].ldts, sizeof(process[0].ldts), DA_LDT);   //LDT0 0x28
    //GDT_INIT(&gdt[6], (int)&process[1].tss, sizeof(process[1].tss), DA_386TSS); //TSS1 0x30
    //GDT_INIT(&gdt[7], (int)process[1].ldts, sizeof(process[1].ldts), DA_LDT);   //LDT1 0x38

    short* p_idt_limit = (short*)(&idt_ptr[0]);
    int* p_idt_base  = (int*)(&idt_ptr[2]);
    *p_idt_limit = IDT_SIZE * sizeof(GATE) - 1;
    *p_idt_base  = (int)(idt);
    asm ("lidt (,%0,1)"::"r"(idt_ptr):);
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
    out_byte(INT_M_CTLMASK, 0xFE);  //仅打开时钟中断

    /* Slave  8259, OCW1.  */
    out_byte(INT_S_CTLMASK, 0xFF);
}

void init_8253A()
{
    out_byte(INT_T_CTL, 0x36);
    out_byte(INT_T_DEVIDER, INT_T_FREQ_DEVIDR & 0xff);
    out_byte(INT_T_DEVIDER, (INT_T_FREQ_DEVIDR >> 8) & 0xff);
}

void cs_start(){
    tss_init();
    init_8253A();
    init_8295A();
    idt_init();
}
