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
    mov     r9, #0

    set_attr    #CS_BOLD()
    set_attr    #13

    bl          canon

    mainloop:

        bl      kbhit
        cmp     r0, #0
        beq     drawing

        bl      getchar
        cmp     r0, #120
        beq     break

        cmp     r0, #32
        eor     r9, r9, #1

        b       mainloop
        drawing:

        putstr  cls_h
        bl      getsize
        lsr     r0, r0, #1
        sub     r0, r0, #2
        lsr     r1, r1, #1
        move_cursor_to  r1, r0

        cmp         r9, #0
        bne         1f
        ldr         r0, [r7, #0x14]
        bl          extract_hhmmss
        bl          store_hhmmss


        1: bl       load_hhmmss
        mov         r5, r3
        cmp         r5, r6
        movne       r8, #0

        set_attr    #32
        putz        r1, #2
        cmp         r8, #25
        bge         .1
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

    break:

    @ putstr  pop_display
    mov     r0, #1
    bl      b_flush

    bl      decanon


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


store_hhmmss:
@ hh_mm_ss &lt;- r1, r2, r3
    push    {r0, lr}
    ldr     r0, =hh_mm_ss
    str     r1, [r0], #4
    str     r2, [r0], #4
    str     r3, [r0], #4

    pop     {r0, pc}

.ltorg


load_hhmmss:
@ r1, r2, r3 &lt;- hh_mm_ss
    push    {r0, lr}

    ldr     r0, =hh_mm_ss
    ldr     r1, [r0], #4
    ldr     r2, [r0], #4
    ldr     r3, [r0], #4
    

    pop     {r0, pc}

.ltorg


.data


hh_mm_ss:
    .word 0
    .word 0
    .word 0


#endif
