@ key.S
#ifndef KEY_S
#define KEY_S


#include "printlib.S"
#include "macro.S"
#include "console.S"

.global main
.text

main:
    push    {lr}

    bl      canon

    loop:

        bl      kbhit
        cmp     r0, #0
        beq     loopend
        putstring " "

        bl      getchar
        cmp     r0, #120
        beq     break
        ldr     r1, =chb
        str     r0, [r1]
        put     r0


        putstring " "
        loopend:
        putstring "."
        ldr r0, =100000
        bl  usleep
        bl  loop

    break:
        putstring "x\n"

    @ bl      b_flush
    bl      decanon

    pop     {pc}

.ltorg

.data

string  chb, " "

#endif
