KERNELDIR :=$(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)
KERNEL_SRC:=$(KERNELDIR)/kernel.asm 
KERNEL=$(KERNELDIR)/kernel.bin

ASMBFLAGS=-I $(KERNELDIR)/include/ 

all: $(KERNEL)

$(KERNEL) : $(KERNEL_SRC)
	nasm $(ASMBFLAGS) $^ -o $@

kclean:
	rm -rf $(KERNELDIR)/*.bin

.PHONY : all kclean

