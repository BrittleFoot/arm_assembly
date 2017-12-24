@ uart.S
#ifndef UART_S
#define UART_S


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

#define  DLAB_ON             0b10000011
#define  DLAB_OFF            0b10000000

#define  UART_RECV_BUF       0x0000
#define  UART_DIV_LOW        0x0000
#define  UART_DIV_HIGH       0x0004
#define  UART_LINE_CTRL      0x000C
#define  UART_LINE_STATUS    0x0014



.text


uart_init:
    push    {r0-r1, lr}

    ldr     r0, =UART_BASE_ADDR
    bl      mem_mmap
    cmp     r0, #-1
    beq     mmap_error
    ldr     r1, =uart_mem
    str     r0, [r1]

    ldr     r0, =CCU_BASE_ADDR
    bl      mem_mmap
    cmp     r0, #-1
    beq     mmap_error
    ldr     r1, =ccu_mem
    str     r0, [r1]


    pop     {r0-r1, pc}

.ltorg



uart_hit:
@ r0 - uart number
    push    {r1-r3, lr}

    ldr     r1, =uart_mem
    ldr     r1, [r1]

    ldr     r2, =UART_LINE_STATUS
    add     r2, r2, r0

    ldr     r3, [r1, r2]

    and     r3, r3, #1
    cmp     r3, #0

    pop     {r1-r3, pc}

.ltorg


uart_read:
@ r0 - uart_number
    push    {r1-r3, lr}

    ldr     r1, =uart_mem
    ldr     r1, [r1]

    ldr     r0, [r1, r0]

    pop     {r1-r3, pc}


.ltorg


uart_sent_available:
@ r0 - uart number
    push    {r1-r3, lr}

    ldr     r1, =uart_mem
    ldr     r1, [r1]
    
    add     r1, r1, r0

    ldr     r2, =UART_LINE_STATUS

    ldr     r3, [r1, r2]

    ands    r3, r3, #0b100000
    pop     {r1-r3, pc}

.ltorg


uart_write:
@ r0 - uart_number
@ r1 - char
    push    {r2, lr}

    ldr     r2, =uart_mem
    ldr     r2, [r2]
    str     r1, [r2, r0]

    pop     {r2, pc}


init_uart:
@ r0 - uart number
    push    {r0-r4, lr}

    ldr     r1, =uart_mem
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

    ldr     r1, =ccu_mem
    ldr     r1, [r1]

    ldr     r2, [r1, #BUS_CLOCK_GATING3]
    orr     r2, r2, r0
    str     r2, [r1, #BUS_CLOCK_GATING3]

    ldr     r2, [r1, #BUS_SOFT_REG4]
    orr     r2, r2, r0
    str     r2, [r1, #BUS_SOFT_REG4]

    pop     {r0-r2, pc}

.ltorg

uart_close:
    push    {lr}
    bl      mem_close
    pop     {pc}

.ltorg



setup_uart:
@ r0 - uart number
        push    {r0-r4,lr}

        
        mov     r1, r0
        lsr     r0, r0, #10
        add     r4, r0, #UART0_BIT

        mov     r0, #1
        lsl     r0, r0, r1

        ldr     r1, =ccu_mem
        ldr     r1, [r1]

        ldr     r2, [r1, #0x006C]
        orr     r2, r2, r0
        str     r2, [r1, #0x006C]

        ldr     r2, [r1, #0x02D8]
        orr     r2, r2, r0
        str     r2, [r1, #0x02D8]

        ldr     r1, =uart_mem
        ldr     r1, [r1]
        add     r1, r1, r4

DLAB_SET        = 0b10000000
PARITY_EVEN     = 0b00010000
PARITY_ENABLED  = 0b00001000
DATA_8_BIT      = 0b00000011

        eor     r0, r0
        orr     r0, r0, #DLAB_SET
        orr     r0, r0, #DATA_8_BIT
        orr     r0, r0, #PARITY_ENABLED
        orr     r0, r0, #PARITY_EVEN
        ldrb    r2, [r1, #0x0C]
        orr     r2, r2, r0
        strb    r2, [r1, #0x0C]

        mov     r0, #13
        strb    r0, [r1, #0x00]

        eor     r0, r0, r0
        strb    r0, [r1, #0x04]

FIFO_ENABLED    = 0b00000001

        ldr     r0, [r1, #0x08]
        orr     r0, r0, #FIFO_ENABLED
        str     r0, [r1, #0x08]

DLAB_UNSET      = 0b01111111

        ldr     r0, =DLAB_UNSET
        ldrb    r2, [r1, #0x0C]
        and     r2, r2, r0
        strb    r2, [r1, #0x0C]

        pop     {r0-r4,pc}



.data

    uart_mem:  .word 0
    ccu_mem:   .word 0

#endif
