org	0100h
jmp start
times 	1024-($-$$)	db	0	; 填充剩下的空间，使生成的二进制代码恰好为512字节

msg db "this is loader"

start                   ; Start
	mov	ax, 0B800h
	mov	gs, ax
	mov	ah, 0Fh				; 0000: 黑底    1111: 白字
	mov	al, 'L'
	mov	[gs:((80 * 0 + 39) * 2)], ax	; 屏幕第 0 行, 第 39 列。

	jmp	$		

;dw 	    0xaa55				; 结束标志
