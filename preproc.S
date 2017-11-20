#define BUFFER_SIZE 400000
.globl main
.text

main:
    push    {lr}

    ldr     r0, =megabyte
    ldr     r1, =megab
    mov     r2, #X

    mov     r7, #1
    svc     #0
    
    pop     {pc}
    


@ 
.bss
megabyte:   .space 1000000, 0
.comm       megab, 1000000, 4