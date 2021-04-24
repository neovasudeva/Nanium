store.s:
.align 4
.section .text
.globl _start
_start:
	la	x1, b1
	la	x2, b2
	la	x3, b3
	la	x4, b4

	# sw
	#lw	x5, w4
	#sw	x5, 0(x4)
	#lw	x6, b4

	# sh
	#lw	x5, w4
	#sh	x5, 0(x4)
	#sh	x5, 0(x2)
	#lw	x6, b4		# cdefcdef

	# sb
	lw	x5, w4
	sb	x5, 0(x4)
	sb	x5, 0(x3)
	sb	x5, 0(x2)
	sb	x5, 0(x1)
	lw	x6, b4		# 79abcdef

	jal x0, deadloop

deadloop:
	beq x0, x0, deadloop

.section .rodata

b4:		.byte 0x00
b3:		.byte 0x00
b2:		.byte 0x00
b1:		.byte 0x00
w4:		.byte 0xef
w3:		.byte 0xcd
w2:		.byte 0xab
w1:		.byte 0x79
zero:	.word 0x00000000
