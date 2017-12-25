@ chat.S
#ifndef CHAT_S
#define CHAT_S

#include "bufferedoutput.S"
#include "ring_buffer.S"
#include "protocol.S"
#include "console.S"
#include "global.S"
#include "timer.S"
#include "macro.S"
#include "uart.S"
#include "size.S"
#include "mem.S"
#include "log.S"

#define STDIN  0
#define STDOUT 1
#define STDERR 2

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


    @ receiver = (int) args[2][0] * 0x400
    ldr     r1, [r0, #8]
    ldrb    r2, [r1]
    sub     r2, r2, #48
    cmp     r2, #3
    bgt     uart_out_of_range
    ldr     r3, =receiver
    ldr     r1, =UART1_OFFSET
    mul     r2, r2, r1
    str     r2, [r3]

    bl      canon
    bl      uart_init

    ldr     r0, =sender
    ldr     r0, [r0]

    bl      setup_uart

    ldr     r0, =receiver
    ldr     r0, [r0]


    bl      setup_uart

    ldr     r2, =receiver
    ldr     r2, [r2]
    mov     r0, r2
    bl      uart_read

    ldr     r0, =user_init_name
    ldr     r1, =user_name
    bl      asciz_cpy

    ldr     r0, =mate_init_name
    ldr     r1, =mate_name
    bl      asciz_cpy


    loop:

        bl      handle_stdin
        bl      handle_sending
        bl      handle_receiving

        ldr     r1, =80000
        each    flush_timer, r1, 1f

        bl      draw_cui
        mov     r0, #STDIN
        bl      b_flush

    1:  bl      b_clear
        b       loop

    break:


    bl      uart_close
    bl      decanon

    pop     {pc}

.ltorg


handle_stdin:
    push    {lr}

    bl      kbhit
    cmp     r0, #0
    beq     99f

    mov     r0, #STDIN
    ldr     r1, =in_buffer
    mov     r2, #0x100
    mov     r7, #3
    svc     #0

    mov     r1, r0
    ldr     r0, =in_buffer

    mov     r2, r1
    mov     r1, r0

    log_str input_log
    mov     r5, r0

    ldr     r0, =input_log
    bl      log_write_bytes

    log_str input_log
    cmp     r5, r0

    beq     99f

    log_getline     input_log, r5

    mov     r1, r0 
    invoke  asciz_len, r1

    cmp     r1, #0
    beq     99f

    bl      process_ready_input

99: pop     {pc}

.ltorg


process_ready_input:
@ r0 char *input
@ r1 int   input_length
    push    {r0-r1, lr}

    push    {r0-r1}
    ldr     r0, =global_log
    ldr     r1, =user_name
    bl      log_write_asciz

    mov     r1, #58     @ ':'
    bl      log_write_byte
    mov     r1, #0x20   @ ' '
    bl      log_write_byte

    pop     {r0-r1}

    push    {r0, r1}

    ldr     r2, =slash_pattern
    mov     r3, #1
    bl      starts_with
    cmp     r4, #1
    beq     1f

    ldr     r0, =CMD_MSG
    ldr     r1, =CMD_MSG_LEN
    bl      rb_put_n

    mov     r2, r1
    mov     r1, r0
    ldr     r0, =global_log
    bl      log_write_bytes

1:  pop     {r0, r1}
    bl      rb_put_n

    mov     r2, r1
    mov     r1, r0
    ldr     r0, =global_log
    bl      log_write_bytes

    mov     r0, #0x0A
    bl      rb_put

    mov     r1, r0
    ldr     r0, =global_log
    bl      log_write_byte

    mov     r0, #0x00
    bl      rb_put

    g_add   send_button, #4
    

99: pop     {r0-r1, pc}

.ltorg


handle_sending:
    push    {lr}
    
    ldr     r2, =sender
    ldr     r2, [r2]


    1:  mov     r0, r2
        bl      uart_sent_available
        beq     99f

        invoke  rb_get, r1
        cmp     r1, #-1
        beq     99f

        mov     r0, r2
        bl      uart_write
        b       1b

99: pop  {pc}

.ltorg


handle_receiving:
    push    {r0, lr}

    ldr     r2, =receiver
    ldr     r2, [r2]
    mov     r0, r2
    bl      uart_hit
    beq     1f

    mov     r0, r2
    bl      uart_read
    mov     r1, r0

    g_get   line_ready
    cmp     r0, #-1
    beq     3f

    log_getline recv_log, r0
    bl      process_ready_recv
    g_set   line_ready, #-1
    b       4f

3:  ldr     r0, =recv_log
    bl      log_write_byte

4:  cmp     r1, #0x0A
    bne     2f

    log_str recv_log
    sub     r0, r0, #1
    g_set   line_ready, r0

2:  g_add   recv_button, #1

1:  pop     {r0, pc}

.ltorg


process_ready_recv:
@ r0 char *recved_line
    push    {r0-r4, lr}

    mov     r1, r0
    ldr     r0, =global_log

    push    {r1}
    ldr     r1, =mate_name
    bl      log_write_asciz
    mov     r1, #58
    bl      log_write_byte
    mov     r1, #0x20
    bl      log_write_byte
    pop     {r1}

    bl      log_write_asciz
    mov     r1, #0x0A
    bl      log_write_byte

    pop     {r0-r4, pc}

.ltorg
    

draw_cui:
    push            {lr}

    putstr          cls_h

    bl              getsize

    mov             r5, r0
    mov             r6, r1

    move_cursor_to  #0, #0
    bl              write_log

    sub             r1, r6, #2
    move_cursor_to  r1, #0
    set_attr        #33

    @   recv button beep
    g_get           recv_button
    cmp             r0, #0
    ble             12f

    g_sub           recv_button, #1
    set_attr        #31

12: mov             r1, r5
    mov             r0, #42
    bl              fill

    set_attr        #33


    sub             r1, r6, #1
    move_cursor_to  r1, #0

    @   send button beep

    g_get           send_button
    cmp             r0, #0
    ble             11f

    g_sub           send_button, #1
    set_attr        #34

11: set_attr        #1
    putstring       "# <send> # > "

    set_attr        #0

    log_last_record input_log

    mov             r0, r1
    bl              b_writez

99: pop             {pc}

.ltorg


write_log:
    push        {r0-r8, lr}
    log_str     global_log
    mov         r5, r0
    ldr         r6, =log_rec_size
    log_data    global_log

    cmp         r5, #0
    beq         99f     

    98: @ for r0 = char *log_sting in recv_log:
        @ r5     -> counter 

        @ ldr     r1, =0xFFFF
        @ ldr     r2, =slash_pattern
        @ mov     r3, #1
        @ bl      find_first
        @ add     r1, r0, r4
        @ mov     r2, r1

        @ invoke  asciz_len, r2
        @ cmp     r2, #0
        @ beq     42f
        mov     r1, r0
        invoke  b_writez, r1
        putstring   "\n"

    42: ldr         r6, =log_rec_size
        add         r0, r0, r6

        subs        r5, r5, #1
        bne         98b

    putstring   "\n\n\n\n"

99: pop         {r0-r8, pc}

.ltorg


fill:
    push    {lr}

    mov     r3, r1
    ldr     r2, =letter_slot
    strb    r0, [r2]
    mov     r0, r2
    mov     r1, #1

    1:  bl      b_write
        subs    r3, r3, #1
        bne     1b

    pop     {pc}

.ltorg



mmap_error:
    putstring   "mmap_error\n"
    b exit


usage:
    putstring   "Usage: chat.S <sender_num> <receiver_num>\n"
    putstring   "\t`*_num` must be 0, 1, 2 or 3 a.k.a. uart number\n"
    b exit


uart_out_of_range:
    putstring   "ERROR: uart number must be in range [0-3]\n"
    b exit


exit:
    mov     r0, #STDIN
    bl      b_flush
    pop     {pc}


.data

    checksum:       .word 0

    sender:         .word 0
    receiver:       .word 0
    letter_slot:    .word 0
    lletter_slot    = 1

    line_ready:     .word -1

    flush_timer:    .word 0
    blink_timer:    .word 0

    send_button:    .word 0
    recv_button:    .word 0

    slash_pattern:  .ascii "/"


    user_name:      .space  0x100, 0
    mate_name:      .space  0x100, 0


    user_init_name: .asciz "You"
    mate_init_name: .asciz "Mate"

.bss

    in_buffer:      .space  0x100, 0
    lin_buffer      = 0x100

    input_length:   .word  0
    input_line:     .space 0x1000, 0
    
recv_log:
   .word  0
   .word  0
   .space 0x100000, 0

input_log:
   .word  0
   .word  0
   .space 0x100000, 0


global_log:
   .word  0
   .word  0
   .space 0x100000, 0

#endif
