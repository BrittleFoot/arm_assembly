#ifndef STRINGS_S
#define STRINGS_S


#include "macro.S"

@ https://gcc.gnu.org/onlinedocs/cpp/Stringizing.html#Stringizing
#define xst(s) st(s)
#define st(s) #s


.global find_first
.text


find_first:
@r0: search target *
@r1: target length
@r2: search pattern *
@r3: pattern length
@note: \0 anyway counts as end of string 
@      put 0xFFFF in length arg if string is .asciz
@ -> r4 - pattern position
    push    {r0-r3, r5-r8, lr}

    mov     r5, #0

    1:

        bl      starts_with
        cmp     r4, #1
        moveq   r4, r5
        beq     1f

        add     r0, r0, #1
        add     r5, r5, #1
        sub     r1, r1, #1

        cmp     r4, #-1
        bne     1b

    1:

    pop     {r0-r3, r5-r8, pc}

.ltorg



starts_with:
@r0: search target *
@r1: target length
@r2: search pattern *
@r3: pattern length
@note: \0 anyway counts as end of string 
@      put 0xFFFF in length arg if string is .asciz
@ -> r4 - bool
    push    {r5-r8, lr}
       
    mov     r4, #0

    1: @loop
        ldrb    r5, [r0, r4]
        ldrb    r6, [r2, r4]

        @put     r5
        @bl print_space
        @put     r6
        @bl print_space

        cmp     r6, #0
        @ pattern ends
        beq     1f

        cmp     r5, #0
        @ target ends
        moveq   r4, #-1
        beq     2f
        
        cmp     r5, r6
        @ mismatch
        movne   r4, #0
        bne     2f

        add     r4, r4, #1

        cmp     r4, r3
        @ pattern ends
        bge     1f

        cmp     r4, r1
        @ target ends
        movge   r4, #-1
        bge     2f

        b       1b

    1: @ success
    mov     r4, #1

    2: @ return
    pop     {r5-r8, pc}

.ltorg


asciz_len:
@r0 - asciz*
@r0 -> int
    push    {r1-r3, lr}

    mov r3, #0
    1:
        ldrb    r2, [r0, r3]
        cmp     r2, #0
        addne   r3, r3, #1
        bne     1b

    mov     r0, r3
    pop     {r1-r3, pc}

.ltorg

asciz_print:
@ r0 - asciz*
    push    {r1-r3, r7, lr}

    mov     r1, r0
    invoke  asciz_len, r1

    mov     r7, #4
    mov     r2, r1
    mov     r1, r0
    mov     r0, #1
    svc     #0

    pop     {r1-r3, r7, pc}

.ltorg


asciz_cpy:
@ r0  target
@ r1  destination
    push    {r0-r2, lr}

    1:  ldrb    r2, [r0], #1
        strb    r2, [r1], #1

        cmp     r2, #0
        bne     1b
    

    pop     {r0-r2, pc}

.ltorg


#endif
