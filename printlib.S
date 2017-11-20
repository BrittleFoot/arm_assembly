@ printlib.S
#ifndef PRINTLIB_S
#define PRINTLIB_S

#include "console.S"
#include "strings.S"
#include "color.S"
#include "macro.S"

.global print_int



.macro putstr label
    push {r0-r2, r7}
    mov r7, #4
    mov r0, #1  
    ldr r1, =\label
    ldr r2, =l\label
    svc #0
    pop {r0-r2, r7}
.endm


.macro putstring literal
    push    {r0-r12}
    b       1f
    2:     .ascii "\literal"
    x =  (. - 2b)
    .if x % 4 != 0
        .space 4 - x % 4, 0
    .endif
    1:
    mov     r0, #1
    ldr     r1, =2b
    ldr     r2, =x
    mov     r7, #4
    svc     #0
    pop    {r0-r12}
.endm



.text

print_int:
@r0 -- target
@r1 -- minimum width of result (filled with zeroes)
    push    {r0-r8, lr}
    mov r8, r1
    bl  _clear_buffer

    mov r6, #0
    ldr r4, =buffer
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

    mov r7, #4
    mov r0, #1  
    mov r1, r4
    mov r2, r6
    svc #0

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
    ldr     r4, =buffer
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

    mov r7, #4
    mov r0, #1  
    mov r1, r4
    mov r2, r6
    svc #0

    pop     {r0-r9, pc}


_clear_buffer:
    push    {r0-r3, lr}

    ldr     r3, =lbuffer
    ldr     r1, =fillchar
    ldr     r1, [r1]
    ldr     r2, =buffer
    1:
        subs    r3, #1
        strb    r1, [r2]
        add     r2, #1
        bne     1b

    pop     {r0-r3, pc}


.macro put a
    push { r0-r12 }
    mov  r0, \a
    mov  r1, #1
    bl   print_int
    pop  { r0-r12 }
.endm

.macro putz a, z
    push { r0-r12 }
    mov  r0, \a
    mov  r1, \z
    bl   print_int
    pop  { r0-r12 }
.endm

.macro putz_ns a, z, ns
    push { r0-r12 }
    mov  r0, \a
    mov  r1, \z
    mov  r2, \ns
    bl   print_int_ns
    pop  { r0-r12 }
.endm



div:
@ r0 = r0 // r1; r1 = r0 % r1
    push    {r2, lr}

    mov     r2, r0          @ r2 = r0
    udiv    r0, r0, r1      @ r0 = r0 // r1
    mls     r1, r0, r1, r2  @ r1 = r2 - r0 * r1

    pop     {r2, pc}


print_endl:
    push    {r0-r2, r7, lr}

    mov r7, #4
    mov r0, #1  
    ldr r1, =endl
    mov r2, #1
    svc #0

    pop     {r0-r2, r7, pc}


print_space:
    push    {r0-r7, lr}

    mov r7, #4
    mov r0, #1  
    ldr r1, =space
    mov r2, #1
    svc #0

    pop     {r0-r7, pc}


print_highlited:
@ r0, r1 str*, size
@ r2, r3, hilight position and length
    push    {r0-r6, lr}
    mov     r7, #4

    push    {r0-r2}
        mov     r2, r2
        mov     r1, r0
        mov     r0, #1
        svc     #0
    pop     {r0-r2}

    putstring xst(CSI()CS_BOLD();FG_GREEN()m)

    push    {r0-r2}
        add     r0, r0, r2
        mov     r2, r3
        mov     r1, r0
        mov     r0, #1
        svc     #0
    pop     {r0-r2}

    putstring xst(CSI()CS_NORM();FG_WHITE()m)

    push    {r0-r2}
        add     r0, r0, r2
        add     r0, r0, r3
        sub     r1, r1, r2
        sub     r1, r1, r3
        mov     r2, r1 
        mov     r1, r0
        mov     r0, #1
        svc     #0
    pop     {r0-r2}
    

    pop     {r0-r6, pc}

.ltorg

.data

fillchar: .word 48
buffer: .space 64, 0
lbuffer = . - buffer
endl:   .ascii "\n"
space:  .ascii " "


#endif

