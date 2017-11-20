#include <stdio.h>
#include <assert.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <fcntl.h>

#define ccu_base_addr	0x01C20000
#define uart_base_addr	0x01C28000

#define uart_offset	0x0800
#define uart_bit	18

volatile unsigned *ccu_regs;
volatile unsigned *uart_regs;

//assumes little endian
void printBits(size_t const size, void const * const ptr)
{
    unsigned char *b = (unsigned char*) ptr;
    unsigned char byte;
    int i, j;

    for (i=size-1;i>=0;i--)
    {
        for (j=7;j>=0;j--)
        {
            byte = (b[i] >> j) & 1;
            printf("%u", byte);
        }
    }
    puts("\n");
}

int main()
{
	int memfd = open("/dev/mem", O_RDWR | O_DSYNC);
	if(memfd == -1)
	{
		printf("Error (open)\n");
		return 1;
	}

	ccu_regs = (volatile unsigned *)mmap(
				NULL, 4096, PROT_READ | PROT_WRITE,
				MAP_SHARED, memfd, ccu_base_addr);
	uart_regs = (volatile unsigned *)mmap(
				NULL, 4096, PROT_READ | PROT_WRITE,
				MAP_SHARED, memfd, uart_base_addr);

	printf("%x %x\n", ccu_regs, uart_regs);

//	ccu_regs[0x006C/4] &= ~(1<<uart_bit);	// disable clock for uart2
//	ccu_regs[0x02D8/4] &= ~(1<<uart_bit);	// set uart2
	ccu_regs[0x006C/4] |= 1<<uart_bit;	// enable clock for uart2
	ccu_regs[0x02D8/4] |= 1<<uart_bit;	// reset uart2
	printf("%x %x\n", ccu_regs[0x006C/4], ccu_regs[0x006C/4]);

	uart_regs[(uart_offset + 0x0C)/4] |= 0b10000011;	// DLAB, 8bit
	uart_regs[(uart_offset + 0x00)/4] = 13;		// divisor (low)
	uart_regs[(uart_offset + 0x04)/4] = 0;		// divisor (high)
	uart_regs[(uart_offset + 0x0C)/4] &= ~0b10000000;	// DLAB off


	while(1)
		if(uart_regs[(uart_offset + 0x14)/4] & 1)	// received?
		{
			char c = (char)uart_regs[(uart_offset + 0x00)/4];
			if(c == '\0')
				break;
			putchar(c);
			fflush(stdout);
		}
}

void wait_busy()
{
	while(uart_regs[(uart_offset + 0x7C)/4] & 1)
		;
}
