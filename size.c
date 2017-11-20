#include <sys/ioctl.h>
#include <stdio.h>
#include <unistd.h>

int main (int argc, char **argv)
{
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);

    char* str = "Hello, darkness, my old friend!";
    str[0] = 0x20;

    printf ("lines %d\n", w.ws_row);
    printf ("columns %d\n", w.ws_col);
    return 0;
}