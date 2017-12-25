@ protocol.S
#ifndef PROTOCOL_S
#define PROTOCOL_S


.text



.data


CMD_MSG:        .asciz "/msg "
CMD_MSG_LEN     = . - CMD_MSG - 1

CMD_NAME:       .asciz "/name "
CMD_NAME_LEN    = . - CMD_NAME - 1

CMD_SYNC:       .asciz "/sync"
CMD_SYNC_LEN    = . - CMD_SYNC - 1

CMD_OK:         .asciz "/ok"
CMD_OK_LEN =    = . - CMD_OK - 1



#endif
