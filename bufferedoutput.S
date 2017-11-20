@ bufferedoutput.S
#ifndef BUFFEREDOUTPUT_S
#define BUFFEREDOUTPUT_S

@ to prevent non-buffered output
#define PRINTLIB_S

#include "buffer.S"

.macro putstr a
    push {r0-r1}
    
    ldr r0, =\a
    ldr r1, =l\a
    bl  b_write
    pop {r0-r1}
.endm


.macro putstring s
    push    {r0-r1}
    b       1f
    2:     .ascii "\s"
    x =  (. - 2b)
    .if x % 4 != 0
        .space 4 - x % 4, 0
    .endif
    1:
    ldr     r0, =2b
    ldr     r1, =x
    bl      b_write
    pop     {r0-r1}
.endm


.text

print_int:
@r0 -- target
@r1 -- minimum width of result (filled with zeroes)
    push    {r0-r8, lr}
    mov r8, r1
    bl  _clear_buffer

    mov r6, #0
    ldr r4, =bo_buffer
    ldr r5, =lbuffer
    add r4, r4, r5

    1:
        sub  r4, r4, #1
        add  r6, r6, #1
        
        mov  r1, #10
        bl   div
        
        add  r1, r1, #48
        strb r1, [r4]

        cmp  r0, #0
        bne  1b

    1:
        cmp   r6, r8
        addlt r6, r6, #1
        sublt r4, r4, #1
        blt   1b 

    mov r0, r4
    mov r1, r6
    bl  b_write

    pop     {r0-r8, pc}


print_int_ns:
@r0 -- target
@r1 -- minimum width of result (filled with zeroes)
@r2 -- numeral system
    push    {r0-r9, lr}
    mov     r8, r1
    mov     r9, r2
    bl      _clear_buffer

    mov     r6, #0
    ldr     r4, =bo_buffer
    ldr     r5, =lbuffer
    add     r4, r4, r5

    1:
        sub  r4, r4, #1
        add  r6, r6, #1
        
        mov  r1, r9
        bl   div
        
        add  r1, r1, #48
        cmp  r1, #58
        addge r1, r1, #7
        strb r1, [r4]

        cmp  r0, #0
        bne  1b

    1:
        cmp   r6, r8
        addlt r6, r6, #1
        sublt r4, r4, #1
        blt   1b 

    mov r0, r4
    mov r1, r6
    bl  b_write

    pop     {r0-r9, pc}


_clear_buffer:
    push    {r0-r3, lr}

    ldr     r3, =lbuffer
    ldr     r1, =fillchar
    ldr     r1, [r1]
    ldr     r2, =bo_buffer
    1:
        subs    r3, #1
        strb    r1, [r2]
        add     r2, #1
        bne     1b

    pop     {r0-r3, pc}


.macro put a
    push { r0-r2 }
    mov  r0, \a
    mov  r1, #1
    bl   print_int
    pop  { r0-r2 }
.endm

.macro putz a, z
    push { r0-r2 }
    mov  r0, \a
    mov  r1, \z
    bl   print_int
    pop  { r0-r2 }
.endm

.macro putz_ns a, z, ns
    push { r0-r2 }
    mov  r0, \a
    mov  r1, \z
    mov  r2, \ns
    bl   print_int_ns
    pop  { r0-r2 }
.endm

.macro flush 
    mov     r0, #1
    bl      b_flush
.endm



div:
@ r0 = r0 // r1; r1 = r0 % r1
    push    {r2, lr}

    mov     r2, r0          @ r2 = r0
    udiv    r0, r0, r1      @ r0 = r0 // r1
    mls     r1, r0, r1, r2  @ r1 = r2 - r0 * r1

    pop     {r2, pc}




.data

fillchar: .word 48
bo_buffer: .word 65, 65, 65, 65
lbuffer = . - bo_buffer
endl:   .ascii "\n"
space:  .ascii " "


#endif

