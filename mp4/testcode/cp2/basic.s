.align 4
.section .text
.globl _start
_start:
	lw	x1, one
	lw	x3, addr
	lw	x1, 0(x3)

	
	

.section .rodata

one:		.word 0x00000001
two:		.word 0x00000002
three:		.word 0x00000003
four:		.word 0x00000004
addr:		.word 0x0000008c
bad:        .word 0xdeadbeef
good:       .word 0x600d600d
