.global main


.text
main:
    push    {lr}

    bl try_overflow

    ldr r0, =longint
    mov r1, #0          @block ptr

    loop:



    pop     {pc}


try_overflow:
    push    {lr}

    ldr  r0, =format_sum
    mov  r1, #4294967295
    mov  r2, #0
    adds r3, r1, r2
    ldrcs r0, =overflow
    bl  printf

    ldr  r0, =format_sum
    mov  r1, #4294967295
    mov  r2, #2
    adds r3, r1, r2
    ldrcs r0, =overflow
    bl  printf

    ldr  r0, =format_mul
    mov  r1, #4294967295
    mov  r2, #4
    muls r3, r1, r2
    ldrcs r0, =overflow
    bl  printf

    pop     {pc}

.data

longint:   .word   0, 0, 0, 0

format_sum:    .asciz  "%u + %u = %u\n"
format_mul:    .asciz  "%u * %u = %u\n"
overflow:  .asciz  "WARNING[overflow]: %u + %u = %u\n"

