@ chat.S
#ifndef CHAT_S
#define CHAT_S

#include "bufferedoutput.S"
#include "ring_buffer.S"
#include "console.S"
#include "macro.S"
#include "uart.S"
#include "size.S"
#include "mem.S"

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

    bl      canon
    bl      uart_init

    ldr     r0, =sender
    ldr     r0, [r0]

    bl      init_ccu
    bl      init_uart

    ldr     r0, =reciver
    ldr     r0, [r0]

    bl      init_ccu
    bl      init_uart

    ldr     r2, =reciver
    ldr     r2, [r2]
    mov     r0, r2
    bl      uart_read


    loop:

        bl  handle_stdin
        bl  handle_sending
        bl  handle_reciving

        bl  draw_gui
        mov r0, #STDIN
        bl  b_flush
        ldr r0, =1000
        bl  usleep

        b   loop

    break:


    bl      uart_close
    bl      decanon

    pop     {pc}

.ltorg


handle_stdin:
    push    {lr}

    bl      kbhit
    cmp     r0, #0
    beq     dont_read

    mov     r0, #STDIN
    ldr     r1, =in_buffer
    mov     r2, #0x100
    mov     r7, #3
    svc     #0

    mov     r1, r0
    ldr     r0, =in_buffer
    bl      rb_put_n


    dont_read:
    pop     {pc}

.ltorg


handle_sending:
    push    {lr}
    
    ldr     r2, =sender
    ldr     r2, [r2]

    mov     r0, r2
    bl      uart_sent_available
    beq     1f

    invoke  rb_get, r1
    cmp     r1, #-1
    beq     1f

    mov     r0, r2
    bl      uart_write

    1: pop  {pc}

.ltorg


handle_reciving:
    push    {r0, lr}

    ldr     r2, =reciver
    ldr     r2, [r2]
    mov     r0, r2
    bl      uart_hit
    beq     1f

    mov     r0, r2
    bl      uart_read

    ldr     r1, =letter_slot
    strb    r0, [r1]
    putstr  letter_slot

    1: pop  {r0, pc}

.ltorg


draw_gui:
    push    {lr}

    putstr  push_display

    bl      getsize
    mov     r5, r0
    mov     r6, r1

    sub     r1, r1, #2
    move_cursor_to r1, #0
    set_attr #33
    mov     r1, r5
    mov     r0, #42
    bl      fill

    sub     r1, r6, #1
    move_cursor_to r1, #0
    set_attr #1
    putstring "# <send> # > "
    set_attr #0

    putstr  pop_display
    

    pop     {pc}

.ltorg



fill:
    push    {lr}

    mov     r3, r1
    ldr     r2, =letter_slot
    strb    r0, [r2]
    mov     r0, r2
    mov     r1, #1
    1:
        bl      b_write
        subs    r3, r3, #1
        bne     1b

    pop     {pc}

.ltorg



mmap_error:
    putstring   "mmap_error\n"
    pop         {pc}


usage:
    putstring   "Usage: chat.S <sender_interface_num> <reciver_interface_num>\n"
    putstring   "\t<*_interface_num> must be 0, 1, 2 or 3 -- uart number\n"
    pop         {pc}


uart_out_of_range:
    putstring   "ERROR: uart number must be in range [0-3]\n"
    pop         {pc}



.data

    sender:         .word 0
    reciver:        .word 0
    letter_slot:    .word 0
    lletter_slot    = 1

    in_buffer:      .space  0x100, 0
    lin_buffer      = 0x100

    input_length:   .word  0
    input_line:     .space 0x1000, 0

    hello:          .asciz "Hello, World!\nAnd somebody else!\n"

#endif
