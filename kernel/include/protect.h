#ifndef _PROTECT_H_
#define _PROTECT_H_
#include <const.h>

#define u32 unsigned int
#define u16 unsigned short


typedef struct s_descriptor     /* �� 8 ���ֽ� */
{
    short limit_low;      /* Limit */
    short base_low;       /* Base */

    char base_mid;       /* Base */

    char attr1;          /* P(1) DPL(2) DT(1) TYPE(4) */
    char limit_high_attr2;   /* G(1) D(1) 0(1) AVL(1) LimitHigh(4) */
    char base_high;     /* Base */
} __attribute__ ((packed)) GDT_DESCRIPTOR;

/* �������� */
typedef struct s_gate
{
	short	offset_low;	/* Offset Low */
	short	selector;	/* Selector */
	char	dcount;		/* ���ֶ�ֻ�ڵ���������������Ч�����������
				   �����ŵ����ӳ���ʱ������Ȩ����ת���Ͷ�ջ
				   �ĸı䣬��Ҫ������ջ�еĲ������Ƶ��ڲ�
				   ��ջ����˫�ּ����ֶξ�������˵���������
				   ����ʱ��Ҫ���Ƶ�˫�ֲ�����������*/
	char	attr;		/* P(1) DPL(2) DT(1) TYPE(4) */
	short	offset_high;	/* Offset High */
} __attribute__ ((packed)) GATE;

typedef struct s_tss {
    u32 backlink;
    u32 esp0;   /* stack pointer to use during interrupt */
    u32 ss0;    /*   "   segment  "  "    "        "     */
    u32 esp1;
    u32 ss1;
    u32 esp2;
    u32 ss2;
    u32 cr3;
    u32 eip;
    u32 flags;
    u32 eax;
    u32 ecx;
    u32 edx;
    u32 ebx;
    u32 esp;
    u32 ebp;
    u32 esi;
    u32 edi;
    u32 es;
    u32 cs;
    u32 ss;
    u32 ds;
    u32 fs;
    u32 gs;
    u32 ldt;
    u16 trap;
    u16 iobase; /* I/Oλͼ��ַ���ڻ����TSS�ν��ޣ��ͱ�ʾû��I/O���λͼ */
} __attribute__ ((packed)) TSS;

typedef struct s_stackframe {
    u32 gs;     /* \                                    */
    u32 fs;     /* |                                    */
    u32 es;     /* |                                    */
    u32 ds;     /* |                                    */
    u32 edi;        /* |                                    */
    u32 esi;        /* | pushed by save()                   */
    u32 ebp;        /* |                                    */
    u32 kernel_esp; /* <- 'popad' will ignore it            */
    u32 ebx;        /* |                                    */
    u32 edx;        /* |                                    */
    u32 ecx;        /* |                                    */
    u32 eax;        /* /                                    */
    u32 retaddr;    /* return addr for kernel.asm::save()   */
    u32 eip;        /* \                                    */
    u32 cs;     /* |                                    */
    u32 eflags;     /* | pushed by CPU during interrupt     */
    u32 esp;        /* |                                    */
    u32 ss;     /* /                                    */
}STACK_FRAME;


typedef struct s_proc {
    STACK_FRAME regs;          /* process registers saved in stack frame */

    u16 ldt_sel;               /* gdt selector giving ldt base and limit */
    GDT_DESCRIPTOR ldts[LDT_SIZE]; /* local descriptors for code and data */
    u32 pid;                   /* process id passed in from MM */
    char p_name[16];           /* name of the process */
    TSS tss;
} PROCESS;


/* GDT */
/* ���������� */
#define	INDEX_DUMMY		0	// ��
#define	INDEX_FLAT_C		1	// �� LOADER �����Ѿ�ȷ���˵�.
#define	INDEX_FLAT_RW		2	// ��
#define	INDEX_VIDEO		3	// ��
/* ѡ���� */
#define	SELECTOR_DUMMY		   0		// ��
#define	SELECTOR_FLAT_C		0x08		// �� LOADER �����Ѿ�ȷ���˵�.
#define	SELECTOR_FLAT_RW	0x10		// ��
#define	SELECTOR_VIDEO		(0x18+3)	// ��<-- RPL=3

#define	SELECTOR_KERNEL_CS	SELECTOR_FLAT_C
#define	SELECTOR_KERNEL_DS	SELECTOR_FLAT_RW


/* ����������ֵ˵�� */
#define	DA_32			0x4000	/* 32 λ��				*/
#define	DA_LIMIT_4K		0x8000	/* �ν�������Ϊ 4K �ֽ�			*/
#define	DA_DPL0			0x00	/* DPL = 0				*/
#define	DA_DPL1			0x20	/* DPL = 1				*/
#define	DA_DPL2			0x40	/* DPL = 2				*/
#define	DA_DPL3			0x60	/* DPL = 3				*/
/* �洢������������ֵ˵�� */
#define	DA_DR			0x90	/* ���ڵ�ֻ�����ݶ�����ֵ		*/
#define	DA_DRW			0x92	/* ���ڵĿɶ�д���ݶ�����ֵ		*/
#define	DA_DRWA			0x93	/* ���ڵ��ѷ��ʿɶ�д���ݶ�����ֵ	*/
#define	DA_C			0x98	/* ���ڵ�ִֻ�д��������ֵ		*/
#define	DA_CR			0x9A	/* ���ڵĿ�ִ�пɶ����������ֵ		*/
#define	DA_CCO			0x9C	/* ���ڵ�ִֻ��һ�´��������ֵ		*/
#define	DA_CCOR			0x9E	/* ���ڵĿ�ִ�пɶ�һ�´��������ֵ	*/
/* ϵͳ������������ֵ˵�� */
#define	DA_LDT			0x82	/* �ֲ��������������ֵ			*/
#define	DA_TaskGate		0x85	/* ����������ֵ				*/
#define	DA_386TSS		0x89	/* ���� 386 ����״̬������ֵ		*/
#define	DA_386CGate		0x8C	/* 386 ����������ֵ			*/
#define	DA_386IGate		0x8E	/* 386 �ж�������ֵ			*/
#define	DA_386TGate		0x8F	/* 386 ����������ֵ			*/

/* �ж����� */
#define	INT_VECTOR_DIVIDE		0x0
#define	INT_VECTOR_DEBUG		0x1
#define	INT_VECTOR_NMI			0x2
#define	INT_VECTOR_BREAKPOINT		0x3
#define	INT_VECTOR_OVERFLOW		0x4
#define	INT_VECTOR_BOUNDS		0x5
#define	INT_VECTOR_INVAL_OP		0x6
#define	INT_VECTOR_COPROC_NOT		0x7
#define	INT_VECTOR_DOUBLE_FAULT		0x8
#define	INT_VECTOR_COPROC_SEG		0x9
#define	INT_VECTOR_INVAL_TSS		0xA
#define	INT_VECTOR_SEG_NOT		0xB
#define	INT_VECTOR_STACK_FAULT		0xC
#define	INT_VECTOR_PROTECTION		0xD
#define	INT_VECTOR_PAGE_FAULT		0xE
#define	INT_VECTOR_COPROC_ERR		0x10

/* �ж����� */
#define	INT_VECTOR_IRQ0			0x20
#define	INT_VECTOR_IRQ8			0x28

/* 8259A interrupt controller ports. */
#define INT_M_CTL     0x20 /* I/O port for interrupt controller       <Master> */
#define INT_M_CTLMASK 0x21 /* setting bits in this port disables ints <Master> */
#define INT_S_CTL     0xA0 /* I/O port for second interrupt controller<Slave>  */
#define INT_S_CTLMASK 0xA1 /* setting bits in this port disables ints <Slave>  */

/* 8253 controller port and frequency divider para */
#define INT_T_CTL       0x43 /* port for timer work mode controller */
#define INT_T_DEVIDER   0x40 /* port for timer divider */
#define INT_T_FREQ_DEVIDR      0xFFFF /* value for timer frequency devider */

#endif
