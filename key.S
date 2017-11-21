@ key.S
#ifndef KEY_S
#define KEY_S


#include "printlib.S"
#include "macro.S"
#include "console.S"
#include "ring_buffer.S"

.global main
.text

main:
    push    {lr}

    bl      canon

    loop:

        bl      kbhit
        cmp     r0, #0
        beq     dont_read

        mov     r0, #0
        ldr     r1, =in_buffer
        mov     r2, #0x10
        mov     r7, #3
        svc     #0



        mov     r2, r0
        mov     r0, #1
        ldr     r1, =in_buffer
        mov     r7, #4
        svc     #0

        dont_read:
        putstring "."

        @ putstring " "

        @ resolve_input:
        @     bl      rb_get
        @     cmp     r0, #-1
        @     beq     loopend
        @     cmp     r0, #120
        @     beq     break
        @     ldr     r1, =rb_head
        @     ldr     r1, [r1]
        @     put     r1
        @     putstring "_"
        @     put     r0
        @     putstring " "
        @     b resolve_input
        @ loopend:
        @ putstring "."
        ldr r0, =100000
        bl  usleep
        bl  loop

    break:
        putstring "x\n"

    @ bl      b_flush
    bl      decanon

    pop     {pc}

.ltorg

.data

in_buffer:  .space  0x100, 0

#endif
