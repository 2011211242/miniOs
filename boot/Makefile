PROJECT := $(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)

BOOT_SRC:=$(PROJECT)/boot.asm 
LOADER_SRC:=$(PROJECT)/loader.asm
BOOTIMG:=$(PROJECT)/boot.img

BOOT:=$(PROJECT)/boot.bin
LOADER:=$(PROJECT)/loader.bin


all: BIN 


ASMBFLAGS   = -I $(PROJECT)/include/

.PHONY : clean all

BIN: $(BOOT) $(LOADER)
	dd if=$(BOOT) of=$(BOOTIMG) bs=512 count=1 conv=notrunc
	sudo mount -o loop $(BOOTIMG) /mnt/floppy/
	sudo cp $(LOADER) /mnt/floppy/ -v
	sudo umount /mnt/floppy/

$(BOOT) : $(BOOT_SRC)
	nasm $(ASMBFLAGS) $^ -o $@

$(LOADER) : $(LOADER_SRC)
	nasm $(ASMBFLAGS) $^ -o $@

clean:
	rm -rf *.bin

