#ifndef _CONST_H_
#define _CONST_H_

#define     GDT_SIZE    128
#define     IDT_SIZE    256
#define     LDT_SIZE    3
#define     TSK_NUM     2

/* 权限 */
#define PRIVILEGE_KRNL  0
#define PRIVILEGE_TASK  1
#define PRIVILEGE_USER  3

#endif
