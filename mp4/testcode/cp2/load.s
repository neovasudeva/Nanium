load.s:
.align 4
.section .text
.globl _start
_start:

	lw	x1, b4		# 79abcdef

	lh	x2, b4		# ffffcdef
	lh	x3, b2		# 000079ab
	#lh	x4, b3		# same as x2

	lhu x5, b4		# 0000cdef
	lhu x6, b2		# 000079ab
	#lhu x7, b3		# i have no idea

	lb	x8, b4		# FFFFFFEF
	lb	x9, b3		# FFFFFFCD
	lb	x10, b2		# FFFFFFAB
	lb	x11, b1		# 00000079

	lbu	x12, b4		# 000000EF
	lbu	x13, b3		# 000000CD
	lbu	x14, b2		# 000000AB
	lbu	x15, b1		# 00000079

	jal x0, deadloop


deadloop:
	beq x0, x0, deadloop

.section .rodata

b4:		.byte 0xEF
b3:		.byte 0xCD
b2:		.byte 0xAB
b1:		.byte 0x79
