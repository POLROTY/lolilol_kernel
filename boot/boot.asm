; ───────────────────────────────────────────────
; boot.asm — 32-bit Multiboot boot stub
; ───────────────────────────────────────────────

BITS 32

GLOBAL  start             ; Entry point defined in linker.ld
EXTERN  kernel_main       ; C function from kernel.c

; ── Multiboot Header ───────────────────────────
MAGIC     equ 0x1BADB002
FLAGS     equ 1<<0 | 1<<1         ; ALIGN | MEMINFO
CHECKSUM  equ -(MAGIC + FLAGS)    ; Must sum to 0

section .multiboot
    dd MAGIC
    dd FLAGS
    dd CHECKSUM

; ── Code Section ───────────────────────────────
section .text
start:
    cli                     ; Disable interrupts
    mov esp, stack_top      ; Set stack pointer
    call kernel_main        ; Jump to C entry point

.hang:
    hlt                     ; Halt CPU
    jmp .hang               ; Infinite loop if kernel_main returns

; ── Simple 16 KiB Stack ────────────────────────
section .bss
align 16
stack_bottom:
    resb 16384              ; Reserve 16 KiB for stack
stack_top:
