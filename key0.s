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
	.file	"key0.c"
	.comm	term1,60,4
	.comm	term2,60,4
	.text
	.align	1
	.global	canon
	.syntax unified
	.thumb
	.thumb_func
	.fpu neon
	.type	canon, %function
canon:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r5, r7, lr}
	add	r7, sp, #0
	ldr	r1, .L2
	movs	r0, #0
	bl	tcgetattr
	ldr	r2, .L2+4
	ldr	r3, .L2
	mov	r4, r2
	mov	r5, r3
	ldmia	r5!, {r0, r1, r2, r3}
	stmia	r4!, {r0, r1, r2, r3}
	ldmia	r5!, {r0, r1, r2, r3}
	stmia	r4!, {r0, r1, r2, r3}
	ldmia	r5!, {r0, r1, r2, r3}
	stmia	r4!, {r0, r1, r2, r3}
	ldm	r5, {r0, r1, r2}
	stm	r4, {r0, r1, r2}
	ldr	r3, .L2
	ldr	r3, [r3, #12]
	bic	r3, r3, #10
	ldr	r2, .L2
	str	r3, [r2, #12]
	ldr	r2, .L2
	movs	r1, #0
	movs	r0, #0
	bl	tcsetattr
	nop
	pop	{r4, r5, r7, pc}
.L3:
	.align	2
.L2:
	.word	term1
	.word	term2
	.size	canon, .-canon
	.align	1
	.global	decanon
	.syntax unified
	.thumb
	.thumb_func
	.fpu neon
	.type	decanon, %function
decanon:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	ldr	r2, .L5
	movs	r1, #0
	movs	r0, #0
	bl	tcsetattr
	nop
	pop	{r7, pc}
.L6:
	.align	2
.L5:
	.word	term2
	.size	decanon, .-decanon
	.align	1
	.global	kbhit
	.syntax unified
	.thumb
	.thumb_func
	.fpu neon
	.type	kbhit, %function
kbhit:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	adds	r3, r7, #4
	mov	r2, r3
	movw	r1, #21531
	movs	r0, #0
	bl	ioctl
	ldr	r3, [r7, #4]
	mov	r0, r3
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, pc}
	.size	kbhit, .-kbhit
	.ident	"GCC: (Linaro GCC 6.3-2017.05) 6.3.1 20170404"
	.section	.note.GNU-stack,"",%progbits
