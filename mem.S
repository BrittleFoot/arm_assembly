@ mem.S
#ifndef MEM_S
#define MEM_S


#include "macro.S"

.text

mem_open:
@ r0 -&gt; memory offset to open
    push    {r1, r7, lr}

    ldr     r0, =mem_fd
    ldr     r0, [r0]

    cmp     r0, #-1
    bne     1f

    ldr     r0, =dev_mem
    ldr     r1, =4098
    mov     r7, #5
    svc     #0

    ldr     r1, =mem_fd
    str     r0, [r1]

    1:
    pop     {r1, r7, pc}


.ltorg


mem_close:
    push    {r0, r7, lr}

    ldr     r0, =mem_fd
    ldr     r0, [r0]

    mov     r7, #6 
    svc     #0

    1:
    pop     {r0, r7, pc}

.ltorg


mem_mmap:
@ r0 - base to mmap
    push    {r1-r7, lr}
    sub     sp, sp, #8
    add     r6, sp, #8

    str     r0, [sp, #4]

    bl      mem_open 
    cmp     r0, #-1
    beq     2f

    str     r0, [sp]

    mov     r3, #1      @ MAP_SHARED
    mov     r2, #3      @ PROT_READ | PROT_WRITE
    mov     r1, #0x1000
    mov     r0, #0
    bl      mmap

    mov     sp, r6

    2:
    pop     {r1-r7, pc}

.ltorg

.data
    dev_mem:  .asciz  "/dev/mem"
    mem_fd:  .word   -1

#endif
