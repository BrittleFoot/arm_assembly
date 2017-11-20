@ size.s
#ifndef SIZE_S
#define SIZE_S

.global  getsize

.text
@rerurns: width in r0, height in r1
getsize:
    push    {r2, lr}

    ldr     r0, =1       @STDOUT_FILENO
    ldr     r1, =21523   @TIOCGWINSZ
    ldr     r2, =winsize
    bl      ioctl

    ldr     r1, =winsize
    ldrh    r0, [r1, #2]
    ldrh    r1, [r1]

    pop     {r2, pc}

.data

winsize: .word 0, 0

#endif
