/* 
 * Linker script for 32-bit freestanding kernel
 * Load address: 1 MiB (0x00100000)
 */

ENTRY(start)  /* Kernel entry point symbol */

SECTIONS
{
    /* Start loading the kernel at 1 MiB in memory */
    . = 1M;

    /* Text/code section (aligned to 4 KiB) */
    .text ALIGN(4K) : {
        *(.multiboot)   /* Multiboot header must come first */
        *(.text*)       /* All code sections */
    }

    /* Read-only data (constants, strings) */
    .rodata ALIGN(4K) : {
        *(.rodata*)     /* All read-only data */
    }

    /* Writable data */
    .data ALIGN(4K) : {
        *(.data*)       /* Initialized global/static variables */
    }

    /* Uninitialized data (zeroed at runtime) */
    .bss ALIGN(4K) : {
        *(COMMON)       /* Common symbols */
        *(.bss*)        /* Uninitialized global/static variables */
    }
}
