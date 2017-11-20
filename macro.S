@ macro.s
#ifndef MACRO_S
#define MACRO_S


.macro string s, v 
    \s:    .ascii "\v"
    l\s  = . - \s
.endm


.macro invoke proc, arg0
@ invokes proc with redirect of in and out registers from r0[TODO:, r1...] to presented.
    .if \arg0 == r0
        bl \proc
    .else
        push    {r0}
        mov     r0, \arg0
        bl      \proc
        mov     \arg0, r0
        pop     {r0}
    .endif
.endm

#endif
