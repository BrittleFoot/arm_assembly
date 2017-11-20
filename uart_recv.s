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
	.file	"uart_recv.c"
	.comm	ccu_regs,4,4
	.comm	uart_regs,4,4
	.section	.rodata
	.align	2
.LC0:
	.ascii	"/dev/mem\000"
	.align	2
.LC1:
	.ascii	"Error (open)\000"
	.text
	.align	1
	.global	main
	.syntax unified
	.thumb
	.thumb_func
	.fpu neon
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #8
	movw	r1, #4098
	ldr	r0, .L10
	bl	open
	str	r0, [r7, #4]
	ldr	r3, [r7, #4]
	cmp	r3, #-1
	bne	.L2
	ldr	r0, .L10+4
	bl	puts
	movs	r3, #1
	b	.L3
.L2:
	mov	r3, #29491200
	str	r3, [sp, #4]
	ldr	r3, [r7, #4]
	str	r3, [sp]
	movs	r3, #1
	movs	r2, #3
	mov	r1, #4096
	movs	r0, #0
	bl	mmap
	mov	r2, r0
	ldr	r3, .L10+8
	str	r2, [r3]
	ldr	r3, .L10+12
	str	r3, [sp, #4]
	ldr	r3, [r7, #4]
	str	r3, [sp]
	movs	r3, #1
	movs	r2, #3
	mov	r1, #4096
	movs	r0, #0
	bl	mmap
	mov	r2, r0
	ldr	r3, .L10+16
	str	r2, [r3]
	ldr	r3, .L10+8
	ldr	r3, [r3]
	adds	r3, r3, #108
	ldr	r2, .L10+8
	ldr	r2, [r2]
	adds	r2, r2, #108
	ldr	r2, [r2]
	orr	r2, r2, #262144
	str	r2, [r3]
	ldr	r3, .L10+8
	ldr	r3, [r3]
	add	r3, r3, #728
	ldr	r2, .L10+8
	ldr	r2, [r2]
	add	r2, r2, #728
	ldr	r2, [r2]
	orr	r2, r2, #262144
	str	r2, [r3]
	ldr	r3, .L10+16
	ldr	r3, [r3]
	addw	r3, r3, #2060
	ldr	r2, .L10+16
	ldr	r2, [r2]
	addw	r2, r2, #2060
	ldr	r2, [r2]
	orr	r2, r2, #131
	str	r2, [r3]
	ldr	r3, .L10+16
	ldr	r3, [r3]
	add	r3, r3, #2048
	movs	r2, #13
	str	r2, [r3]
	ldr	r3, .L10+16
	ldr	r3, [r3]
	addw	r3, r3, #2052
	movs	r2, #0
	str	r2, [r3]
	ldr	r3, .L10+16
	ldr	r3, [r3]
	addw	r3, r3, #2060
	ldr	r2, .L10+16
	ldr	r2, [r2]
	addw	r2, r2, #2060
	ldr	r2, [r2]
	bic	r2, r2, #128
	str	r2, [r3]
.L7:
	ldr	r3, .L10+16
	ldr	r3, [r3]
	addw	r3, r3, #2068
	ldr	r3, [r3]
	and	r3, r3, #1
	cmp	r3, #0
	beq	.L7
	ldr	r3, .L10+16
	ldr	r3, [r3]
	add	r3, r3, #2048
	ldr	r3, [r3]
	strb	r3, [r7, #3]
	ldrb	r3, [r7, #3]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L9
	ldrb	r3, [r7, #3]	@ zero_extendqisi2
	mov	r0, r3
	bl	putchar
	ldr	r3, .L10+20
	ldr	r3, [r3]
	mov	r0, r3
	bl	fflush
	b	.L7
.L9:
	nop
	movs	r3, #0
.L3:
	mov	r0, r3
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, pc}
.L11:
	.align	2
.L10:
	.word	.LC0
	.word	.LC1
	.word	ccu_regs
	.word	29523968
	.word	uart_regs
	.word	stdout
	.size	main, .-main
	.align	1
	.global	wait_busy
	.syntax unified
	.thumb
	.thumb_func
	.fpu neon
	.type	wait_busy, %function
wait_busy:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r7}
	add	r7, sp, #0
	nop
.L13:
	ldr	r3, .L14
	ldr	r3, [r3]
	addw	r3, r3, #2172
	ldr	r3, [r3]
	and	r3, r3, #1
	cmp	r3, #0
	bne	.L13
	nop
	mov	sp, r7
	@ sp needed
	ldr	r7, [sp], #4
	bx	lr
.L15:
	.align	2
.L14:
	.word	uart_regs
	.size	wait_busy, .-wait_busy
	.ident	"GCC: (Linaro GCC 6.3-2017.05) 6.3.1 20170404"
	.section	.note.GNU-stack,"",%progbits
