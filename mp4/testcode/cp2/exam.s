exam.s:
.align 4
.section .text
.globl _start
_start:
	la	x1, data1
	lh	x2, 2(x1)

	#la	x3, data2
	#sb	x2, 1(x3)

	#lw	x4, 0(x3)

	jal x0, deadloop

deadloop:
	beq x0, x0, deadloop

.section .rodata
data1:	.word 0xddccbbaa
data2:	.word 0x00eeff00

