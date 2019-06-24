SRC:=boot.asm \
	loader.asm

#BIN:=$(subst .asm,.com,$(SRC))

BIN:=boot.com \
	loader.bin

ASMBFLAGS   = -I include/

.PHONY : everything clean

everything : $(BIN)
	dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc
	sudo mount -o loop boot.img /mnt/floppy/
	sudo cp loader.bin /mnt/floppy/ -v
	#sudo cp boot.com /mnt/floppy/ -v
	sudo umount /mnt/floppy/

$(BIN) : $(SRC)
	nasm $(ASMBFLAGS) boot.asm -o boot.bin
	nasm $(ASMBFLAGS) loader.asm -o loader.bin

clean:
	rm -rf *.com *.bin

