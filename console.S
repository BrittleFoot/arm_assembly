@ console.S
#ifndef CONSOLE_S
#define CONSOLE_S

#include "strings.S"
#include "macro.S"
#include "printlib.S"


#define ESC() \033
#define CSI() ESC()[
#define CS_BOLD() 1
#define CS_NORM() 22


.macro move_cursor_to x, y
    putstring "\033["
    put       \x
    putstring "H"
    putstring "\033["
    put       \y
    putstring "G"
.endm


.macro set_attr x
    putstring "\033["
    put       \x
    putstring "m"
.endm


.data 

.comm   term1, 60, 4
.comm   term2, 60, 4

.text


canon:
@ turn on canonic console mode
    push    {r4, r5, r7, lr}
    add r7, sp, #0
    ldr r1, terms
    movs    r0, #0
    bl  tcgetattr
    ldr r2, terms+4
    ldr r3, terms
    mov r4, r2
    mov r5, r3
    ldmia   r5!, {r0, r1, r2, r3}
    stmia   r4!, {r0, r1, r2, r3}
    ldmia   r5!, {r0, r1, r2, r3}
    stmia   r4!, {r0, r1, r2, r3}
    ldmia   r5!, {r0, r1, r2, r3}
    stmia   r4!, {r0, r1, r2, r3}
    ldm r5, {r0, r1, r2}
    stm r4, {r0, r1, r2}
    ldr r3, terms
    ldr r3, [r3, #12]
    bic r3, r3, #10
    ldr r2, terms
    str r3, [r2, #12]
    ldr r2, terms
    movs    r1, #0
    movs    r0, #0
    bl  tcsetattr
    nop
    pop {r4, r5, r7, pc}

terms:
    .word   term1
    .word   term2

decanon:
@ turn off canonic mode
    push    {r7, lr}
    add r7, sp, #0
    ldr r2, dec_terms
    movs    r1, #0
    movs    r0, #0
    bl  tcsetattr
    nop
    pop {r7, pc}

dec_terms:
    .word   term2

kbhit:
@ r0 -> count of available symbols in stdin
    push    {r7, lr}
    sub sp, sp, #8
    add r7, sp, #0
    adds    r3, r7, #4
    mov r2, r3
    movw    r1, #21531
    movs    r0, #0
    bl  ioctl
    ldr r3, [r7, #4]
    mov r0, r3
    adds    r7, r7, #8
    mov sp, r7
    pop {r7, pc}

.ltorg


.data

string push_display,    "\0337"
string pop_display,     "\0338"
string save_cursor,     "\033[s"
string restore_cursor,  "\033[u"

string cls_h,           "\x1B[2J\x1B[H"


#endif
