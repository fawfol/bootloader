#include "kernel.h"

void print(const char *str) {
    char *video_memory = (char *)0xB8000;
    while (*str) {
        *video_memory++ = *str++;
        *video_memory++ = 0x0F; // White text on black background
    }
}

void kernel_main() {
    print("Kernel Mode!");
}
