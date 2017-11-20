#define F F(F)


.global main

.text

main:
    push    {lr}

    sub     sp, sp, #8

    mov     r1, sp

    mov     r0, #65; strb    r0, [sp], #1
    mov     r0, #66; strb    r0, [sp], #1
    mov     r0, #67; strb    r0, [sp], #1
    mov     r0, #68; strb    r0, [sp], #1
    mov     r0, #69; strb    r0, [sp], #1
    mov     r0, #70; strb    r0, [sp], #1
    mov     r0, #71; strb    r0, [sp], #1
    mov     r0, #72; strb    r0, [sp], #1

    mov     r0, #1
    mov     r2, #8
    mov     r7, #4
    @ add     sp, sp, #8
    svc     #0

    pop     {pc}

.ltorg
