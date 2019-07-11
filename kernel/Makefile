KERNELDIR :=$(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)
KERNELSRC:=$(KERNELDIR)/kernel.asm 
KERNELOBJ=$(KERNELDIR)/kernel.o
KERNEL=$(KERNELDIR)/kernel.bin
MESSAGEOBJ=$(KERNELDIR)/message.o
MESSAGESRC=$(KERNELDIR)/src/message.c

ASMBFLAGS= -f elf32 \
		   -I $(KERNELDIR)/include/ 

all: $(KERNEL)


$(KERNEL) : $(KERNELOBJ) $(MESSAGEOBJ)
	ld -s -m elf_i386 -Ttext 0x30400 $^ -o $@

$(KERNELOBJ) : $(KERNELSRC)
	nasm $(ASMBFLAGS) $^ -o $@

$(MESSAGEOBJ) : $(MESSAGESRC)
	gcc -fstack-protector-all -fno-stack-protector $^ -m32 -c -o $@

#$(KERNEL) : $(KERNELSRC)
#	nasm -I $(KERNELDIR)/include/ $^ -o $@


kclean:
	rm -rf $(KERNELDIR)/*.bin $(KERNELDIR)/*.o

.PHONY : all kclean

