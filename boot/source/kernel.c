#include "include/stdint.h"
#include "include/string.h"

static uint16_t *const VIDEO = (uint16_t *)0xB8000;
static uint8_t  row = 0, col = 0;

/* Very small console ------------------------------------------------------- */
static void putc(char c)
{
    if (c == '\n') { col = 0; ++row; return; }
    VIDEO[row * 80 + col] = (uint16_t)c | 0x0F00;   /* white on black */
    if (++col >= 80) { col = 0; ++row; }
}

void print(const char *s) { while (*s) putc(*s++); }

/* Kernel entry from boot.asm ----------------------------------------------- */
void kernel_main(void)
{
    print("42               * A Lolilol kernel by hspriet & rpol");
    for (;;)
        __asm__ __volatile__("hlt");
}
