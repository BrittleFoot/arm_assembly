	.cpu cortex-a7
	.eabi_attribute 28, 1
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 6
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"size.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"Hello, darkness, my old friend!\000"
	.align	2
.LC1:
	.ascii	"lines %d\012\000"
	.align	2
.LC2:
	.ascii	"columns %d\012\000"
	.text
	.align	1
	.global	main
	.syntax unified
	.thumb
	.thumb_func
	.fpu neon
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #24
	add	r7, sp, #0
	str	r0, [r7, #4]
	str	r1, [r7]
	add	r3, r7, #12
	mov	r2, r3
	movw	r1, #21523
	movs	r0, #1
	bl	ioctl
	ldr	r3, .L3
	str	r3, [r7, #20]
	ldr	r3, [r7, #20]
	movs	r2, #32
	strb	r2, [r3]
	ldrh	r3, [r7, #12]
	mov	r1, r3
	ldr	r0, .L3+4
	bl	printf
	ldrh	r3, [r7, #14]
	mov	r1, r3
	ldr	r0, .L3+8
	bl	printf
	movs	r3, #0
	mov	r0, r3
	adds	r7, r7, #24
	mov	sp, r7
	@ sp needed
	pop	{r7, pc}
.L4:
	.align	2
.L3:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.size	main, .-main
	.ident	"GCC: (Linaro GCC 6.3-2017.05) 6.3.1 20170404"
	.section	.note.GNU-stack,"",%progbits
