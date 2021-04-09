arithmetic.s:
.align 4
.section .text
.globl _start
_start:
	# add/sub
	lw	x1, two		# x1 <- 2
	lw	x2, three	# x2 <- 3	
	lw	x3, zero	# x3 <- 0
	add x3, x1, x2	# x3 = 5
	add x3, x1, x3	# x3 = 7
	sub x3,	x3, x2	# x3 = 4

	# xor/and/or
	lw	x4, zero
	xor	x4, x3, x2	# x4 = 7	
	xor x4, x4, x1	# x4 = 5
	and x4, x4, x2	# x4 = 1
	or	x4, x4, x1	# x4 = 3
	and x4, x4, x2	# x4 = 3

	# sll/sra/srl
	lw	x5, neg		# x5 = 0xFFFFFFF0
	sll	x5, x5, x2	# x5 = 0xFFFFFF80	
	sra x5, x5, x1	# x5 = 0xFFFFFFE0
	srl x5, x5, x1	# x5 = 0x3FFFFFF8

	# slt/sltu
	lw	x6, neg		# x6 = 0xFFFFFFF0
	lw	x7, two		# x7 = 2
	slt	x8, x6, x7	# x8 = 1 (?)
	sltu x9, x6, x7	# x8 = 0 (?)

	# end code here

deadloop:
	beq x0, x0, deadloop

.section .rodata

zero:		.word 0x00000000
two:		.word 0x00000002
three:		.word 0x00000003
neg:		.word 0xFFFFFFF0
bad:        .word 0xdeadbeef
good:       .word 0x600d600d
