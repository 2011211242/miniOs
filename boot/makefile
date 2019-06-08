SRC:=boot.asm
BIN:=$(subst .asm,.com,$(SRC))

.PHONY : everything

everything : $(BIN)
	sudo mount -o loop boot.img /mnt/floppy/
	sudo cp $(BIN) /mnt/floppy/ -v
	sudo umount /mnt/floppy/

$(BIN) : $(SRC)
	nasm $< -o $@

