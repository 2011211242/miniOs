KERNELDIR :=$(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)
KERNELSRC:=$(KERNELDIR)/kernel.asm 
KERNELOBJ=$(KERNELDIR)/kernel.o
KERNEL=$(KERNELDIR)/kernel.bin

ASMBFLAGS= -f elf64 \
		   -I $(KERNELDIR)/include/ 

all: $(KERNEL)


$(KERNEL) : $(KERNELOBJ)
	ld -s -Ttext 0x30400 $^ -o $@

$(KERNELOBJ) : $(KERNELSRC)
	nasm $(ASMBFLAGS) $^ -o $@

kclean:
	rm -rf $(KERNELDIR)/*.bin $(KERNELDIR)/*.o

.PHONY : all kclean

