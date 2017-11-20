.global main

#include "macro.S"
#include "printlib.S"
#include "parse.S"
#include "file.S"
#include "strings.S"
#include "color.S"
#include "console.S"

.text
main:
    push    {lr}
    cmp     r0, #3
    bne     err_args

    mov     r5, r1
    ldr     r9, [r5, #8]
    
    mov     r10, #0
    mov     r11, #0

    @r5 argv
    @r6 char *search_substr
    @r1 char *filename

    ldr     r0, [r5, #4]
    bl      f_open_read
    cmp     r0, #0
    blt     err_open
    b1:
        bl      f_readline    
        cmp     r1, #0
        beq     f1
        add     r10, r10, #1

        mov     r2, r9
        mov     r3, #0x100
        bl      find_first

        cmp     r4, #-1
        beq     b1

        putstring xst(CSI()FG_GREEN()m)
        putstr  hex_prefix
        putz_ns r10, #8, #16
        putstr  colons
        putstring xst(CSI()FG_WHITE()m)
        add     r11, r11, #1

        mov     r2, r4
        mov     r3, r9
        invoke  asciz_len, r3
        bl      print_highlited

        b       b1

    f1:
    bl      f_close

    cmp     r0, #0
    bne     err_close

    putstring "\nTotal "
    putstring xst(CSI()CS_BOLD()m)
    put       r11
    putstring xst(CSI()CS_NORM()m)
    putstring " lines matches '"
    putstring xst(CSI()CS_BOLD()m)
    mov       r0, r9
    bl        asciz_print
    putstring xst(CSI()CS_NORM()m)

    putstring "'.\n"

    mov     r0, #0
    pop     {pc}


err_args:
    putstr  usage
    mov     r0, #1
    pop     {pc}


err_open:
    putstr  error_open
    mov     r0, #3
    pop     {pc}


err_close:
    
    putstr  error_close
    mov     r0, #6
    pop     {pc}


.data

    string error_close, "Closing failed\n"
    string error_open,  "Can't open file\n"
    string usage,       "Usage: grip <file> <search substring>\n"
    string colons,      ": "
    string hex_prefix,  "0x"

