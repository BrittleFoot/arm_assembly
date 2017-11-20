@ file.s
@ Work with single global file 
#ifndef FILE_S
#define FILE_S

BUFFER_SIZE = 400000
LINE_BUFFER_SIZE = 400000
.global f_open_read, f_close, f_readline
.text


.macro f_get label, dest
   ldr  \dest, =\label
   ldr  \dest, [\dest] 
.endm

f_open_read:
@r0 -- .asciz file name
    push    {r1-r2, r7, lr}

    mov     r7, #5  @ open
    mov     r1, #0
    mov     r2, #0
    svc     #0
    ldr     r1, =f_opened_fd
    str     r0, [r1]

    pop     {r1-r2, r7, pc}

f_close:
    push    {r7, lr}

    f_get   f_opened_fd, r0
    mov     r7, #6  @ close
    svc     #0
    
    pop     {r7, pc}

.ltorg

f_read_buffer:
    push    {r1-r2, r7, lr}

    f_get   f_opened_fd, r0
    ldr     r1, =f_filebuffer
    ldr     r2, =BUFFER_SIZE
    mov     r7, #3  @ read
    svc     #0

    ldr     r2, =f_total_read
    str     r0, [r2]
    ldr     r2, =f_cursor
    mov     r1, #0
    str     r1, [r2]

    pop     {r1-r2, r7, pc}

.ltorg


f_readline:
    push    {r2-r9, lr}

    mov     r9, #0  @ line length

    f_get   f_cursor, r2
    f_get   f_total_read, r3
    ldr     r4, =f_filebuffer
    ldr     r5, =f_linebuffer 

    1: @collect line
        cmp     r2, r3
        bge     1f

        2: @ continue collect line

        ldrb    r0, [r4, r2]
        strb    r0, [r5, r9]
        add     r2, r2, #1
        add     r9, r9, #1

        cmp     r0, #10
        beq     3f        

        b       1b

    1: @ load file buffer
        bl      f_read_buffer
        cmp     r0, #0
        beq     1f
        f_get   f_cursor, r2
        f_get   f_total_read, r3
        b       2b

    1: @ file ends
        ldr     r0, =f_linebuffer
        mov     r1, r9
        b       2f

    3: @ yield line
        ldr     r3, =f_cursor
        str     r2, [r3]

        ldr     r0, =f_linebuffer
        mov     r1, r9
        b       2f

2:
    pop     {r2-r9, pc}

.ltorg


.data
    f_opened_fd:  .word 0
    f_total_read: .word 0
    f_cursor:     .word 0

.bss
    f_filebuffer: .space BUFFER_SIZE, 0
    f_linebuffer: .space LINE_BUFFER_SIZE, 0


#endif

