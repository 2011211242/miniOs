org	0100h
jmp start

times 	210-($-$$)	db	0	; 填充剩下的空间，使生成的二进制代码恰好为512字节
start:
	mov	ax, 0B800h
	mov	gs, ax
	mov	ah, 0Fh				; 0000: 黑底    1111: 白字
	mov	al, 'A'
	mov	[gs:((80 * 0 + 0) * 2)], ax	; 屏幕第 0 行, 第 39 列。
	jmp	$		
