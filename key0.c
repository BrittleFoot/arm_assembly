#include <stdio.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <stdbool.h>


struct termios term1, term2;

void canon() {
    tcgetattr(0, &term1);
    term2 = term1;
    term1.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(0, TCSANOW, &term1);
}

void decanon() {
    tcsetattr(0, TCSANOW, &term2);
}

int kbhit() {
    int n;
    ioctl(0, FIONREAD, &n);
    return n;
}