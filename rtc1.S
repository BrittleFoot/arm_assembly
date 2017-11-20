@ rtc1.S
#ifndef RTC1_S
#define RTC1_S

#define RTC_BASE_ADDR 0x1f00000

.global get_rtc
.text

get_rtc:
    push    {r1-r7, lr}


    @ open  /dev/mem
    ldr     r0, =dev_mem
    movw    r1, #4098
    movw    r7, #5
    svc     #0

    cmp     r0, #-1
    beq     1f


    sub     sp, sp, #8
    add     r6, sp, #8

    str     r0, [sp]
    mov     r1, #RTC_BASE_ADDR
    str     r1, [sp, #4]

    mov     r3, #1      @ MAP_SHARED (by gcc -O3)
    mov     r2, #3      @ PROT_READ | PROT_WRITE
    mov     r1, #0x1000
    mov     r0, #0
    bl      mmap

    mov     sp, r6

    1:      pop     {r1-r7, pc}

.ltorg


.data

dev_mem:    .asciz  "/dev/mem"



#endif
