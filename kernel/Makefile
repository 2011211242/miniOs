KERNELDIR :=$(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)

KERNELBINDIR=$(KERNELDIR)/bin
KERNELSRC:=$(KERNELDIR)/kernel.asm 
KERNELOBJ=$(KERNELBINDIR)/kernel.o
KERNEL=$(KERNELBINDIR)/kernel.bin

ASMBFLAGS= -f elf32 \
		   -I $(KERNELDIR)/include/ 

SRCFILES=$(shell find $(KERNELDIR)/src/ -name "*.c" -type f)
OBJFILES=$(SRCFILES:%.c=%.o)

CC:=gcc
CCFLAGS:= -fstack-protector-all \
	-fno-stack-protector \
	-m32

INCFLAGS:= -I $(KERNELDIR)/include

all: path \
	$(KERNEL) 

path: $(KERNELBINDIR)

$(KERNELBINDIR):
	mkdir $@

$(OBJFILES): %.o : %.c 
	$(CC) $(CCFLAGS) $(INCFLAGS) $< -c -o $@

$(KERNEL) : $(KERNELOBJ) $(OBJFILES) 
	ld -s -m elf_i386 -Ttext 0x30400 $^ -o $@

$(KERNELOBJ) : $(KERNELSRC)
	nasm $(ASMBFLAGS) $^ -o $@

kclean:
	rm -rf $(KERNELBINDIR)
	rm -rf $(OBJFILES)

.PHONY : all kclean 
