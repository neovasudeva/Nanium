.align 4
.section .text
.globl _start
_start:

	#add x1, x0, -1
	lw x1, neg
	slti x2, x1, 0

halt:
	beq x0, x0, halt


.section .rodata

zero:		.word 0x00000000
two:		.word 0x00000002
three:		.word 0x00000003
neg:		.word 0xFFFFFFFF
bad:        .word 0xdeadbeef
good:       .word 0x600d600d
