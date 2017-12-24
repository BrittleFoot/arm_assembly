@ setup_uart.S
#ifndef SETUP_UART_S
#define SETUP_UART_S


.text


do_setup_uart:
@ r1 - uart N bit
@ r4 - uart N offset
        push    {r0-r4,lr}

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


#endif
