@ global.S
#ifndef GLOBAL_S
#define GLOBAL_S

.macro g_add label, value 
    push {r11}

    ldr  r11, =\label
    ldr  r0,  [r11]
    add  r0,  r0, \value
    str  r0,  [r11]

    pop  {r11}
.endm


.macro g_sub label, value
    push {r11}

    ldr  r11, =\label
    ldr  r0,  [r11]
    sub  r0,  r0, \value
    str  r0,  [r11]

    pop  {r11}
.endm


.macro g_set label, value
    push {r11}

    ldr  r11, =\label
    mov  r0,  \value
    str  r0,  [r11]

    pop  {r11}
.endm


.macro g_get label
    push {r11}

    ldr  r11, =\label
    ldr  r0,  [r11]

    pop  {r11}
.endm

#endif
