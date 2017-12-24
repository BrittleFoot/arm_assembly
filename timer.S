@ timer.S
#ifndef TIMER_S
#define TIMER_S

#include "global.S"


.macro each value_holder, N, next

    g_add \value_holder, #1
    cmp   r0, \N
    ble   \next
    g_set \value_holder, #0

.endm

#endif
