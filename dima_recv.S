# UART RECV

#ifndef UART_RECV
#define UART_RECV

#define CCU_BASE_ADDR       0x01C20000
#define UART_BASE_ADDR      0x01C28000

#define UART_OFFSET         0x0800

#define UART0_BIT           16
#define UART1_BIT           17
#define UART2_BIT           18
#define UART3_BIT           19

#define BUS_CLOCK_GATE      0x006C
#define BUS_RESET           0x02D8

#define DLAB_ON             0b10000011
#define DLAB_OFF            0b01111111

#define UART_RECV_BUF       0x0000
#define UART_DIV_LOW        0x0000
#define UART_DIV_HIGH       0x0004
#define UART_LINE_CTRL      0x000C
#define UART_LINE_STATUS    0x0014

#define STDIN               0
#define STDOUT              1
#define STDERR              2

.global main
.text

#################################################

.ltorg

main:
    push    {r0-r7, lr}

    ldr     r0, =CCU_BASE_ADDR
    bl      do_mmap
    ldr     r1, =ccu_mem
    str     r0, [r1]

    ldr     r0, =UART_BASE_ADDR
    bl      do_mmap
    ldr     r1, =uart_mem
    str     r0, [r1]


receive_loop:
    ldr     r0, =uart_mem
ldr_stop:
    ldr     r0, [r0]
    mov     r2, #UART_OFFSET
    add     r2, r2, #UART_LINE_STATUS
    ldr     r1, [r0, r2]
and_stop:
    and     r1, r1, #1
    cmp     r1, #0
    beq     receive_loop

    ldr     r0, =uart_mem
    ldr     r0, [r0]
    mov     r1, #UART_OFFSET
    add     r1, r1, #UART_RECV_BUF
    ldr     r1, [r0, r1]

    cmp     r0, #0
    beq     1f

    bl      putchar
stop:
    bl      receive_loop

1:
    pop     {r0-r7, pc}

#################################################

do_mmap:
    push    {r1-r8, lr}

    mov     r8, r0
    @ open  /dev/mem
    ldr     r0, =dev_mem
    movw    r1, #4098
    movw    r7, #5
    svc     #0

    cmp     r0, #-1
    beq     2f

    sub     sp, sp, #8
    add     r6, sp, #8

    str     r0, [sp]
    mov     r1, r8
    str     r1, [sp, #4]

    mov     r3, #1      @ MAP_SHARED (by gcc -O3)
    mov     r2, #3      @ PROT_READ | PROT_WRITE
    mov     r1, #0x1000
    mov     r0, #0
    bl      mmap

    mov     sp, r6

2:
    pop     {r1-r8, pc}

#################################################


.data

ccu_mem:    .word   0
uart_mem:   .word   0
dev_mem:    .asciz  "/dev/mem"

#endif
