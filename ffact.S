.global main

#include "size.S"
#include "factorial.S"
#include "printlib.S"
#include "parse.S"
#include "macro.S"



.macro move_cursor_to x, y
    putstr csi
    put     \x
    putstr big_H
    putstr csi
    put     \y
    putstr big_G
.endm


.macro set_attribute x
    putstr csi
    put     \x
    putstr little_m
.endm


.text
main:
    push    {lr}

    cmp r0, #2
    blt err

    ldr r0, [r1, #4]
    bl  atoi
    bl  print_endl

    cmp r0, #13
    bge err

    push {r0}

    putstr push_display
    set_attribute #49
    putstr cls_h

    set_attribute #1
    bl  getsize
    mov  r2, #2
    udiv r1, r1, r2
    udiv r0, r0, r2
    sub  r0, r0, #5
    move_cursor_to r1, r0

    pop {r0}
    bl print_fact

    putstr pop_display
    move_cursor_to #0, #0
    pop     {pc}

err:
    set_attribute #49
    putstr cls_h
    putstr pop_display
    move_cursor_to #0, #0
    putstr err_msg

    mov r0, #1
    pop {pc}


print_fact:
    push    {lr}

    push {r0}
    mov r1, #5
    bl  div
    pop {r0}

    mov r4, r1
    add r4, r4, #31

    bl  factorial

    ldr  r2, =0xDEAD
    push {r2}
    cunking1000:
        mov  r1, #1000

        bl   div
        push {r1}

        cmp  r0, #0
        bne  cunking1000

    pop {r1}

    mov r3, #1
    printchunks:
        set_attribute r4
        add     r4, r4, #1

        putz    r1, r3
        bl      print_space

        cmp     r3, #3
        movne   r3, #3

        pop     {r0}
        ldr     r2, =0xDEAD
        cmp     r0, r2
        movne   r1, r0
        bne     printchunks

    bl print_endl

    pop     {pc}


.data

string csi,          "\033["
string big_H,        "H"
string big_G,        "G"
string little_m      "m"

string push_display, "\0337"
string pop_display,  "\0338"
string prompt, "Please, give me a number (<13): "

cls_h:          .ascii  "\x1B[2J\x1B[H"
lcls_h =        . - cls_h

string err_msg, "ERROR: value must be presented and less than 13\n"


msg: .ascii "Hi, Arm!\n"
lmsg = . - msg
