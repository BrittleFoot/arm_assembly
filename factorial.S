@ factorial.s
#ifndef FACTORIAL_S
#define FACTORIAL_S


.global factorial


.text
factorial:
    push    {r1, lr}

    cmp r0, #0
    movle r0, #1
    pople {r1, pc}

    mov     r1, r0
    mov     r0, #1

    _fact:
        mul     r0, r1, r0
        subs    r1, #1
        bne     _fact

    pop     {r1, pc}

#endif

