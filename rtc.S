@ rtc.S
#ifndef RTC_S
#define RTC_S

.global main

#include "macro.S"
#include "bufferedoutput.S"
#include "console.S"
#include "rtc1.S"
#include "size.S"
#include "buffer.S"

#define  RTC_SS   0b00000000000000000000000000111111
#define  RTC_MM   0b00000000000000000011111100000000
#define  RTC_HH   0b00000000000111110000000000000000
#define  RTC_WK   0b11100000000000000000000000000000


.text
main:
    push    {lr}


    bl      get_rtc
    mov     r8, #0
    mov     r7, r0
    mov     r6, #100

    putstr  push_display

    set_attr    #CS_BOLD()
    set_attr    #13

        mainloop:

        putstr  cls_h
        bl      getsize
        lsr     r0, r0, #1
        sub     r0, r0, #2
        lsr     r1, r1, #1
        move_cursor_to r1, r0

        ldr         r0, [r7, #0x14]
        bl          extract_hhmmss
        mov         r5, r3
        cmp         r5, r6
        movne       r8, #0

        set_attr    #32
        putz        r1, #2
        cmp         r8, #25
        blt         .1
        set_attr    #30
        .1:
        putstring   ":"

        set_attr    #32
        putz        r2, #2
        cmp         r8, #25
        blt         .2
        set_attr    #30
        .2:
        putstring   ":"

        mov         r0, r3
        mov         r1, #6
        bl          div
        add         r1, r1, #31
        set_attr    r1
        putz        r3, #2
        putstring   "\n"

        add         r8, r8, #1


        bl          getsize
        move_cursor_to r1, #0

        mov         r0, #1 

        cmp     r5, r6
        mov     r6, r5

        bl      b_flush

        movw    r0, #20000
        bl      usleep
        b       mainloop

    putstr  pop_display
    pop     {pc}


.ltorg



extract_hhmmss:
@   r1, r2, r3 &lt;- r0 (RTC)
    ldr     r1, =RTC_HH
    ldr     r2, =RTC_MM
    ldr     r3, =RTC_SS

    and     r1, r1, r0
    lsr     r1, r1, #16
    cmp     r1, #24
    movge   r1, #23

    and     r2, r2, r0
    lsr     r2, r2, #8
    cmp     r2, #60
    movge   r2, #59

    and     r3, r3, r0
    cmp     r3, #60
    movge   r3, #59

    mov     pc, lr

.ltorg

#endif
