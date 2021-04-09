factorial.s:
.align 4
.section .text
.globl factorial
#.global _start

# REMOVE ME
#_start:
#	li		a0, 5
#	j		factorial

factorial:
	# Register a0 holds the input value
	# Register t0-t6 are caller-save, so you may use them without saving
	# Return value need to be put in register a0
	# Your code starts here
	
	# initialize result and num
	la	t2, num	
	la	t3, result
	sw	a0, 0(t2)

fact:
	lw	t4, result
	lw	t5, num	
	li	t6, 0
# multiplication takes t4 = intermediate factorial result, t5 = current num, t6 = result of mult
mul:
	add		t6, t6, t4
	addi	t5, t5, -1
	bgt		t5,	x0, mul
	
	# once done with mul, update num and result
	lw		t5, num
	addi	t5, t5, -1
	sw		t5, 0(t2)
	sw		t6, 0(t3)
	
	# decide whether to jump back to fact
	bgt		t5, x0, fact

# factorial calculation done
end:
	lw	a0, result

# REMOVE ME: infinite loop
#loop:
#	beq	x0, x0, loop
	
ret:
	jr ra # Register ra holds the return address

.section .rodata

num:		.word 0x00000000
result:		.word 0x00000001
