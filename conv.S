.global main

#include "macro.S"
#include "printlib.S"
#include "parse.S"

.text
main:
    push    {lr}

    cmp     r0, #3
    bne     err_args

    ldr     r0, [r1, #4]
    ldr     r2, [r1, #8]

    invoke  parse_int, r0
    mov     r1, #0
    invoke  parse_int, r2

    bl      print_int_ns
    bl      print_endl

    mov     r0, #0
    pop     {pc}


err_args:

    putstr  usage
    mov     r0, #1
    pop     {pc}


.data


    string usage, "Usage: conv <number> <numeral system>\n"
