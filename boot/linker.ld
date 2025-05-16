ENTRY(start)

SECTIONS
{
    .  = 1M;                  /* Load kernel at 0x0010 0000 */

    .text  ALIGN(4K) : {
        *(.multiboot)
        *(.text*)
    }

    .rodata ALIGN(4K) : { *(.rodata*) }
    .data   ALIGN(4K) : { *(.data*)    }

    .bss    ALIGN(4K) : {
        *(COMMON)
        *(.bss*)
    }
}
