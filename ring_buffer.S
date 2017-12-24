@ ring_buffer.S
#ifndef RING_BUFFER_S
#define RING_BUFFER_S


#include "macro.S"
#include "global.S"

.text


rb_get:
@ r0 -&gt; byte
    push    {r1-r4, lr}

    ldr     r1, =rb_head
    ldr     r2, =rb_tail
    ldr     r3, [r1]
    ldr     r4, [r2]
    cmp     r4, r3
    bge     _rb_clear

    ldr     r1, =rb_buffer
    ldrb    r0, [r1, r4]
    add     r4, r4, #1
    str     r4, [r2]

    cmp     r0, #0x0A
    bne     1f

    push    {r0}
    g_sub   rb_lr, #1
    pop     {r0}

    1: pop     {r1-r4, pc}

_rb_clear:
    mov     r3, #0
    str     r3, [r1]
    str     r3, [r2]
    mov     r0, #-1
    pop     {r1-r4, pc}

.ltorg


rb_put:
@ r0 - byte
    push    {r1-r3, lr}

    cmp     r0, #0x0A
    bne     1f

    push    {r0}
    g_add   rb_lr, #1
    pop     {r0}

1:  ldr     r1, =rb_buffer
    ldr     r2, =rb_head
    ldr     r3, [r2]
    strb    r0, [r1, r3]
    add     r3, r3, #1
    str     r3, [r2]

    pop     {r1-r3, pc}
.ltorg


rb_put_n:
@ r0 - char *
@ r1 - length
    push {r0-r2, lr}

    1:  ldrb    r2, [r0], #1
        invoke  rb_put, r2
        subs    r1, r1, #1
        bne     1b

    pop {r0-r2, pc}


rb_line_ready:
    ldr     r0, =rb_lr
    ldr     r0, [r0]
    mov     pc, lr


.ltorg

.data

rb_lr:      .word   0
rb_head:    .word   0
rb_tail:    .word   0

.bss

rb_buffer:  .space  0x1000, 0
lrb_buffer  = 0x1000

#endif
