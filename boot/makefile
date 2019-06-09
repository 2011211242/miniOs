SRC:=boot.asm \
	loader.asm

BIN:=$(subst .asm,.com,$(SRC))

ASMBFLAGS   = -I include/

.PHONY : everything clean

everything : $(BIN)
	sudo mount -o loop boot.img /mnt/floppy/
	sudo cp $(BIN) /mnt/floppy/ -v
	sudo umount /mnt/floppy/

$(BIN) : $(SRC)
	nasm $(ASMBFLAGS) $< -o $@

clean:
	rm -rf *.com *.bin

