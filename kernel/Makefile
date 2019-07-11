KERNELDIR :=$(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)

KERNELBINDIR=$(KERNELDIR)/bin
KERNELSRC:=$(KERNELDIR)/kernel.asm 

KERNELOBJ=$(KERNELBINDIR)/kernel.o
KERNEL=$(KERNELBINDIR)/kernel.bin
MESSAGEOBJ=$(KERNELBINDIR)/message.o
MESSAGESRC=$(KERNELDIR)/src/message.c

ASMBFLAGS= -f elf32 \
		   -I $(KERNELDIR)/include/ 

SRCS=$(shell find $(KERNELDIR)/src/ -name "*.c")
OBJS=$(SRCS:%.c=%.o)

CC:=gcc
CCFLAGS:= -fstack-protector-all \
	-fno-stack-protector \
	-m32

all: path \
	$(KERNEL)

path: $(KERNELBINDIR)

$(KERNELBINDIR):
	@echo $(SRCS)
	@echo $(OBJS)
	mkdir $@

$(OBJS): %.o : %.c
	$(CC) $(CCFLAGS) $^ -c -o $@

$(KERNEL) : $(KERNELOBJ) $(OBJS) 	
	ld -s -m elf_i386 -Ttext 0x30400 $^ -o $@

$(KERNELOBJ) : $(KERNELSRC)
	nasm $(ASMBFLAGS) $^ -o $@

$(MESSAGEOBJ) : $(MESSAGESRC)
	gcc -fstack-protector-all -fno-stack-protector $^ -m32 -c -o $@

#$(KERNEL) : $(KERNELSRC)
#	nasm -I $(KERNELDIR)/include/ $^ -o $@


kclean:
	rm -rf $(KERNELBINDIR) $(OBJS)

.PHONY : all kclean

