.global parse_int


.text

parse_int:
@r0 .asciz char*
    push    {r1, lr}
    mov     r1, #10
    bl      parse_int_ns
    pop     {r1, pc}

.ltorg


parse_int_ns:
@r0 .asciz char*
@r1 numeric system
    push    {r1-r3, lr}

    mov r2, #0
    mov r3, r1
    1:
        ldrb    r1, [r0], #1
        cmp     r1, #0
        beq     1f

        sub     r1, r1, #48
        cmp     r1, #10
        subge   r1, r1, #7
        mla     r2, r2, r3, r1 
        b       1b

    1:

    mov     r0, r2

    pop     {r1-r3, pc}
