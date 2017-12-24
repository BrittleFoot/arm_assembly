@ log.S
#ifndef LOG_S
#define LOG_S


#include "global.S"


.macro log_str label
    ldr r0, =\label
    ldr r0, [r0]
.endm

.macro log_pos label
    ldr r0, =\label
    ldr r0, [r0, #4]
.endm

.macro log_data label
    ldr r0, =\label
    add r0, r0, #8
.endm

.macro log_last_record label
@ r0 -> line number
@ r1 -> char *
    push    {r2}

    ldr     r1, =\label

    add     r2, r1, #log_str_ofst
    ldr     r0, [r2]
    mov     r2, #log_rec_size
    mul     r2, r2, r0

    add     r1, r1, #log_dta_ofst
    add     r1, r1, r2

    pop     {r2}
.endm

.macro log_getline label, N
@ r0 -> char *
    push    {r1-r3}

    ldr     r1, =\label
    mov     r2, #log_rec_size
    mov     r3, \N
    mul     r2, r2, r3
    add     r1, #log_dta_ofst
    add     r0, r1, r2

    pop     {r1-r3}
.endm

.text

log_write_byte:
@ r0 - log_obj
@ r1 - byte
    push    {r0-r6, lr}

    mov     r6, r1

    add     r1, r0, #log_str_ofst
    add     r2, r0, #log_pos_ofst
    add     r3, r0, #log_dta_ofst


    @ newline == new log record
    cmp     r6, #10
    bne     1f

    mov     r4, #0
    str     r4, [r2]

    ldr     r4, [r1]
    add     r4, r4, #1
    str     r4, [r1]

    b       99f

1:  ldr     r0, [r1]
    ldr     r1, =log_rec_size
    mul     r1, r1, r0 

    add     r3, r1

    ldr     r0, [r2]
    strb    r6, [r3, r0]

    add     r0, r0, #1
    str     r0, [r2]

    99:     pop     {r0-r6, pc}

.ltorg


log_write_bytes:
@ r0 - log obj
@ r1 - char *
@ r2 - length
    push    {r0-r4, lr}

    cmp     r2, #0
    beq     99f

    mov     r4, r1

    1:  ldrb    r1, [r4], #1
        bl      log_write_byte
        subs    r2, r2, #1
        bne     1b

99: pop     {r0-r4, pc}

.ltorg

    log_str_ofst = 0
    log_pos_ofst = 4
    log_dta_ofst = 8
    log_rec_size = 0x400

#endif
