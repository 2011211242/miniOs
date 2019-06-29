; ------------------------------------------------------------------------
; 关于loader kernel 的常量定义
; ------------------------------------------------------------------------
BaseOfLoader        equ     09000h                  ;loader 的加载位置 (段地址)
OffsetOfLoader      equ     0100h                   ;loader 的加载位置（偏移地址）

BaseOfLoaderPhyAddr equ     BaseOfLoader * 10h;

BaseOfKernelFile    equ     08000h                  ;kernel 的加载位置 (段地址)
OffsetOfKernelFile  equ     0000h                   ;kernel 的加载位置（偏移地址）

