
#ifndef RTC1_C
#define RTC1_C

#include <stdio.h>
#include <assert.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>

#define rtc_base_addr 	0x01f00000

volatile unsigned *databuf;

int fill_databuf() {
    int memfd = open("/dev/mem", O_RDWR | O_DSYNC);
    assert(-1 != memfd);
    zz = (volatile unsigned *) mmap(NULL, 4096,
		    PROT_READ | PROT_WRITE, MAP_SHARED,
		    memfd, rtc_base_addr);
    
    //printf("RTC Year-Month-Day Register     (0x10) : %08x\n", databuf[4]);
    //printf("RTC Hour-Minute-Second Register (0x14) : %08x\n", databuf[5]);
    int close_res = close(memfd);
    assert(-1 != close_res);
    return 0;
}

#endif
