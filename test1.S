.global main

#include "macro.S"
#include "buffer.S"


.text

main:
    push    {lr}

    pop     {pc}


.data
    string hello, "hello\n\000"
    string hallo, " im robot\n\000"

.ltorg
