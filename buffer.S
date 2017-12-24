@ buffer.S
#ifndef BUFFER_S
#define BUFFER_S

#include "strings.S"
#include "macro.S"

.text


.macro  ldbuffer reg
    movw    \reg, #:lower16:b_buffer
    movt    \reg, #:upper16:b_buffer
.endm


.macro  ldbpos reg
    movw    \reg, #:lower16:b_position
    movt    \reg, #:upper16:b_position
    ldr     \reg, [\reg]
.endm


.macro  stbpos val
    push    {r9, r10}
    movw    r10, #:lower16:b_position
    movt    r10, #:upper16:b_position
    mov     r9, \val
    str     r9, [r10]
    pop     {r9, r10}
.endm


.macro  addbpos val
    push    {r9, r10}
    movw    r9, #:lower16:b_position
    movt    r9, #:upper16:b_position
    ldr     r10, [r9]
    add     r10, r10, \val
    str     r10, [r9]
    pop     {r9, r10}
.endm


.macro  ldwritepos reg
    push     {r10}
    ldbuffer \reg
    ldbpos   r10
    add      \reg, \reg, r10
    pop      {r10}
.endm


b_write:
@ r0 -- char *
@ r1 -- length
    push    {r0-r4, lr}

    ldwritepos r2
    mov        r3, #0

    1:
        ldrb     r4, [r0, r3]
        strb     r4, [r2, r3]

        add      r3, r3, #1
        cmp      r3, r1
        blt      1b

    addbpos  r1

    pop     {r0-r4, pc}

.ltorg


b_writez:
@ r0 -- .asciz char *
    push    {r1, lr}

    mov     r1, r0
    invoke  asciz_len, r1
    bl      b_write

    pop     {r1, pc}

.ltorg


.macro b_putz reg, n
    putz reg, n

.endm


b_flush:
@ r0 -- file descriptor
    push    {r1, r2, r7, lr}

    mov         r7, #4
    ldbuffer    r1
    ldbpos      r2
    stbpos      #0
    svc         #0

    pop     {r1, r2, r7, pc}

.ltorg


b_clear:
    push    {lr}

    stbpos  #0

    pop     {pc}

.ltorg


.data
b_position:     .word   0

.bss
b_buffer:         .space  0x10000000

#endif
