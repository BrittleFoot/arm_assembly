.global main

.include "size.s"
.include "factorial.s"
.include "printlib.s"


.macro puststr a
    push {r0-r2, r7}
    mov r7, #4
    mov r0, #1  
    ldr r1, =\a
    ldr r2, =l\a
    svc #0
    pop {r0-r2, r7}
.endm


.macro move_cursor_to x, y
    puststr csi
    put     \x
    puststr big_H
    puststr csi
    put     \y
    puststr big_G
.endm


.macro set_attribute x
    puststr csi
    put     \x
    puststr little_m

.endm


.text
main:
    push    {lr}


    mov r0, #12
    cmp r0, #13
    bge err

    push {r0}

    puststr push_display
    set_attribute #49
    puststr cls_h

    set_attribute #1
    bl  getsize
    mov  r2, #2
    udiv r1, r1, r2
    udiv r0, r0, r2
    sub  r0, r0, #5
    move_cursor_to r1, r0

    pop {r0}
    bl print_fact

    puststr pop_display
    move_cursor_to #0, #0
    pop     {pc}

err:
    set_attribute #49
    puststr cls_h
    puststr pop_display
    move_cursor_to #0, #0
    puststr err_msg
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

.macro string s, v
    \s:    .ascii "\v"
    l\s  = . - \s
.endm

string csi,          "\033["
string big_H,        "H"
string big_G,        "G"
string little_m      "m"

string push_display, "\0337"
string pop_display,  "\0338"
string prompt, "Please, give me a number (<13): "

cls_h:          .ascii  "\x1B[2J\x1B[H"
lcls_h =        . - cls_h

string err_msg, "ERROR: value must be less than 13\n"


msg: .ascii "Hi, Arm!\n"
lmsg = . - msg
