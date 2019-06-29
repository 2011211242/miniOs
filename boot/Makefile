BOOTDIR:=$(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)
BOOT:=$(BOOTDIR)/boot.bin

LOADER:=$(BOOTDIR)/loader.bin
BOOTASMBFLAGS = -I $(BOOTDIR)/include/ 

BOOT_SRC:=$(BOOTDIR)/boot.asm 
LOADER_SRC:=$(BOOTDIR)/loader.asm

all: $(BOOT) $(LOADER)

$(BOOT) : $(BOOT_SRC)
	nasm $(BOOTASMBFLAGS) $^ -o $@

$(LOADER) : $(LOADER_SRC)
	nasm $(BOOTASMBFLAGS) $^ -o $@

bclean:
	rm -rf $(BOOTDIR)/*.bin


.PHONY : all bclean 


