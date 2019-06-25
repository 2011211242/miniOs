PROJECT := $(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)

SRC:=$(PROJECT)/boot.asm \
	$(PROJECT)/loader.asm

#BIN:=$(subst .asm,.com,$(SRC))

BIN:=$(PROJECT)/boot.bin \
	$(PROJECT)/loader.bin

ASMBFLAGS   = -I $(PROJECT)/include/

.PHONY : everything clean

everything : $(BIN)
	dd if=$(PROJECT)/boot.bin of=$(PROJECT)/boot.img bs=512 count=1 conv=notrunc
	sudo mount -o loop $(PROJECT)/boot.img /mnt/floppy/
	sudo cp $(PROJECT)/loader.bin /mnt/floppy/ -v
	#sudo cp boot.com /mnt/floppy/ -v
	sudo umount /mnt/floppy/

$(BIN) : $(SRC)
	nasm $(ASMBFLAGS) $(PROJECT)/boot.asm -o $(PROJECT)/boot.bin
	nasm $(ASMBFLAGS) $(PROJECT)/loader.asm -o $(PROJECT)/loader.bin

clean:
	rm -rf *.com *.bin

