PROJECT:=$(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)
include boot/Makefile
include kernel/Makefile

BOOTIMG:=$(PROJECT)/boot.img
all : $(BOOTIMG)

$(BOOTIMG) : $(BOOT) $(LOADER) $(KERNEL)
	dd if=$(BOOT) of=$(BOOTIMG) bs=512 count=1 conv=notrunc
	sudo mount -o loop $(BOOTIMG) /mnt/floppy/
	sudo cp $(LOADER) /mnt/floppy/ -v
	sudo cp $(KERNEL) /mnt/floppy/ -v
	sudo umount /mnt/floppy/

clean:
	make kclean bclean

.PHONY : all clean

