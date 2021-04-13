jump.s:
.align 4
.section .text
.globl _start
_start:

pa:	
	jal	x1, pb		
	jal x0, deadloop	
	lw	x2, bad
pb:
	lw	x2, good
	jalr x0, 0(x1)	
	lw	x2, bad

deadloop:
	beq x0, x0, deadloop

.section .rodata

zero:		.word 0x00000000
bad:        .word 0xdeadbeef
good:       .word 0x600d600d
