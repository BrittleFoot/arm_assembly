@ chat.S
#ifndef CHAT_S
#define CHAT_S

#include "printlib.S"
#include "console.S"
#include "macro.S"
#include "mem.S"

#define  UART_BASE_ADDR 0x01C28000
#define  CCU_BASE_ADDR  0x01C20000

#define  UART0_OFFSET   0x000
#define  UART1_OFFSET   0x400
#define  UART2_OFFSET   0x800
#define  UART3_OFFSET   0xC00

#define  UART0_BIT      16
#define  UART1_BIT      17
#define  UART2_BIT      18
#define  UART3_BIT      19

#define  BUS_CLOCK_GATING3  0x006C
#define  BUS_SOFT_REG4      0x02D8

#define DLAB_ON             0b10000011
#define DLAB_OFF            0b10000000

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

main:
    push    {lr}

    cmp     r0, #3
    bne     usage

    mov     r0, r1

    @ sender = (int) args[1][0] * 0x400
    ldr     r1, [r0, #4]
    ldrb    r2, [r1]
    sub     r2, r2, #48
    cmp     r2, #3
    bgt     uart_out_of_range
    ldr     r3, =sender
    ldr     r1, =UART1_OFFSET
    mul     r2, r2, r1
    str     r2, [r3]


    @ reciver = (int) args[2][0] * 0x400
    ldr     r1, [r0, #8]
    ldrb    r2, [r1]
    sub     r2, r2, #48
    cmp     r2, #3
    bgt     uart_out_of_range
    ldr     r3, =reciver
    ldr     r1, =UART1_OFFSET
    mul     r2, r2, r1
    str     r2, [r3]


    ldr     r0, =UART_BASE_ADDR
    bl      mem_mmap
    cmp     r0, #-1
    beq     mmap_error
    ldr     r1, =uart_regs
    str     r0, [r1]

    ldr     r0, =CCU_BASE_ADDR
    bl      mem_mmap
    cmp     r0, #-1
    beq     mmap_error
    ldr     r1, =ccu_regs
    str     r0, [r1]


    ldr     r0, =sender
    ldr     r0, [r0]

    bl      init_ccu
    bl      init_uart


    ldr     r4, =hello

    loop:

        ldr r2, =sender
        ldr r2, [r2]

        mov r0, r2
        bl  uart_sent_available
        beq loop

        mov     r0, r2
        ldrb    r1, [r4], #1
        bl      uart_write
        cmp     r1, #0
        beq     break

        bl      putchar

        b       loop

    break:


    bl      mem_close
    pop     {pc}

.ltorg


uart_sent_available:
@ r0 - uart number
    push    {r1-r3, lr}

    ldr     r1, =uart_regs
    ldr     r1, [r1]

    ldr     r2, =UART_LINE_STATUS
    add     r2, r2, r0

    ldr     r3, [r1, r2]

    and     r3, r3, #0b100000
    cmp     r3, #0

    pop     {r1-r3, pc}

.ltorg


uart_write:
@ r0 - uart_number
@ r1 - char
    push    {r2, lr}

    ldr     r2, =uart_regs
    ldr     r2, [r2]
    str     r1, [r2, r0]

    pop     {r2, pc}


init_uart:
@ r0 - uart number
    push    {r0-r4, lr}

    ldr     r1, =uart_regs
    ldr     r1, [r1]

    ldr     r2, =UART_LINE_CTRL
    add     r2, r2, r0
    ldr     r3, [r1, r2]
    ldr     r4, =DLAB_ON
    orr     r3, r3, r4
    str     r3, [r1, r2]

    ldr     r2, =UART_DIV_LOW
    add     r2, r2, r0
    mov     r3, #13
    str     r3, [r1, r2]

    ldr     r2, =UART_DIV_HIGH
    add     r2, r2, r0
    mov     r3, #0
    str     r3, [r1, r2]

    ldr     r2, =UART_LINE_CTRL
    add     r2, r2, r0
    ldr     r3, [r1, r2]
    ldr     r4, =DLAB_OFF
    bic     r3, r3, r4
    str     r3, [r1, r2]

    pop     {r0-r4, pc}

.ltorg


init_ccu:
@ r0 - uart_number
    push    {r0-r2, lr}
    lsl     r0, r0, #10
    add     r0, r0, #UART0_BIT

    mov     r1, #1
    lsl     r0, r1, r0

    ldr     r1, =ccu_regs
    ldr     r1, [r1]

    ldr     r2, [r1, #BUS_CLOCK_GATING3]
    orr     r2, r2, r0
    str     r2, [r1, #BUS_CLOCK_GATING3]

    ldr     r2, [r1, #BUS_SOFT_REG4]
    orr     r2, r2, r0
    str     r2, [r1, #BUS_SOFT_REG4]

    pop     {r0-r2, pc}

.ltorg


mmap_error:
    putstring   "mmap_error\n"
    pop         {pc}


usage:
    putstring   "Usage: chat.S <sender_uart> <reciver_uart>\n"
    pop         {pc}


uart_out_of_range:
    putstring   "ERROR: uart number must be in range [0-3]\n"
    pop         {pc}



.data

    sender:     .word 0
    reciver:    .word 0

    uart_regs:  .word 0
    ccu_regs:   .word 0

    hello:      .asciz "Hello, World!\nAnd somebody else!\n"

#endif
