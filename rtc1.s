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
	.file	"rtc1.c"
	.comm	databuf,4,4
	.section	.rodata
	.align	2
.LC0:
	.ascii	"/dev/mem\000"
	.text
	.align	1
	.global	fill_databuf
	.syntax unified
	.thumb
	.thumb_func
	.fpu vfpv3-d16
	.type	fill_databuf, %function
fill_databuf:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #8
	movw	r1, #4098
	movw	r0, #:lower16:.LC0
	movt	r0, #:upper16:.LC0
	bl	open
	mov	r2, r0
	mov	r3, #32505856
	str	r3, [sp, #4]
	str	r2, [sp]
	movs	r3, #1
	movs	r2, #3
	mov	r1, #4096
	movs	r0, #0
	bl	mmap
	mov	r3, r0
	mov	r0, r3
	mov	sp, r7
	@ sp needed
	pop	{r7, pc}
	.size	fill_databuf, .-fill_databuf
	.ident	"GCC: (Linaro GCC 6.3-2017.05) 6.3.1 20170404"
	.section	.note.GNU-stack,"",%progbits
