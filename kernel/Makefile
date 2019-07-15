KERNELDIR :=$(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)

KERNELBINDIR=$(KERNELDIR)/bin
KERNELSRCDIR=$(KERNELDIR)/src

KERNELSRC:=$(KERNELDIR)/kernel.asm 

KERNELOBJ=$(KERNELBINDIR)/kernel.o
KERNEL=$(KERNELBINDIR)/kernel.bin
MESSAGEOBJ=$(KERNELBINDIR)/message.o
MESSAGESRC=$(KERNELDIR)/src/message.c

ASMBFLAGS= -f elf32 \
		   -I $(KERNELDIR)/include/ 

SRCNAMES=$(shell find $(KERNELDIR)/src/ -name "*.c" -exec basename {} \; -type f)
OBJNAMES=$(SRCNAMES:%.c=%.o)
OBJFILES=$(OBJNAMES:%=$(KERNELBINDIR)/%)

CC:=gcc
CCFLAGS:= -fstack-protector-all \
	-fno-stack-protector \
	-m32

all: path \
	$(KERNEL)

path: $(KERNELBINDIR)

$(KERNELBINDIR):
	mkdir $@

$(OBJFILES):$(OBJNAMES)

$(OBJNAMES): %.o : $(KERNELSRCDIR)/%.c
	$(CC) $(CCFLAGS) $< -c -o $(KERNELBINDIR)/$@

$(KERNEL) : $(KERNELOBJ) $(OBJFILES) 
	ld -s -m elf_i386 -Ttext 0x30400 $^ -o $@

$(KERNELOBJ) : $(KERNELSRC)
	nasm $(ASMBFLAGS) $^ -o $@

kclean:
	rm -rf $(KERNELBINDIR)

.PHONY : all kclean

