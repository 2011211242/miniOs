sudo mount -o loop a.img /mnt/floppy/

cnt=100
i=0
while [ $i -lt $cnt ]
do
    pre=$i
    i=`expr $i + 1`
    echo $i

    sudo cp $pre.txt /mnt/floppy/ -v

    mv $pre.txt $i.txt
    
done
#sudo cp $(BIN) /mnt/floppy/ -v
sudo umount /mnt/floppy/


