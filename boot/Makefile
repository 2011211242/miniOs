BOOTDIR:=$(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)
BOOT:=$(BOOTDIR)/boot.bin

LOADER:=$(BOOTDIR)/loader.bin
BOOTASMBFLAGS = -I $(BOOTDIR)/include/ 

BOOT_SRC:=$(BOOTDIR)/boot.asm 		\
	$(BOOTDIR)/include/fat12hdr.inc \
	$(BOOTDIR)/include/loader.inc


LOADER_SRC:=$(BOOTDIR)/loader.asm	\
	$(BOOTDIR)/include/fat12hdr.inc \
	$(BOOTDIR)/include/loader.inc


all: $(BOOT) $(LOADER)

$(BOOT) : $(BOOT_SRC)
	nasm $(BOOTASMBFLAGS) $< -o $@

$(LOADER) : $(LOADER_SRC)
	nasm $(BOOTASMBFLAGS) $< -o $@

bclean:
	rm -rf $(BOOTDIR)/*.bin


.PHONY : all bclean 


