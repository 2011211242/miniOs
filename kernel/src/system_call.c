#include "system_call.h"
#include <stdarg.h>

void print(char fmt[], ...) {
    static char message[1024];
    
    int idx = 0;
    message[0] = '\0';

    char * ptr = fmt;
    while(*ptr) {
        if (*ptr = '%') {
            switch(*(ptr + 1)) {
                case '\0':
                    return;
                    break;
                case 'd':
                    break;
                case 's':
                    break;
                case 'x':
                    break;
                case 'X':
                    break;
                case '%':
                    message[idx++] = '%';
                default:
                    break;
            }
            ptr += 2;
        }
        else {
            message[idx++] = *ptr;
            ptr ++;
        }
    }

    __asm__ ("int $0x80");
}
