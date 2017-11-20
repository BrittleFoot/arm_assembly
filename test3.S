@ test3.S
#ifndef TEST3_S
#define TEST3_S

#include "printlib.S"
#include "macro.S"


.global main
.text

main:
    push    {lr}

    bl        get_answer        
    put       r0
    putstring "\n"

    pop     {pc}

.ltorg

#endif
