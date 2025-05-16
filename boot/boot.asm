;───────────────────────────────────────────────────────────────────────────────
; boot/boot.asm  —  minimal 32-bit multiboot stub
;───────────────────────────────────────────────────────────────────────────────
BITS 32
GLOBAL  start
EXTERN  kernel_main            ; from kernel.c

; ── Multiboot header ──────────────────────────────────────────────────────────
MAGIC     equ 0x1BADB002
FLAGS     equ 1<<0 | 1<<1          ; ALIGN | MEMINFO
CHECKSUM  equ -(MAGIC + FLAGS)

section .multiboot
    dd MAGIC
    dd FLAGS
    dd CHECKSUM

; ── Code ──────────────────────────────────────────────────────────────────────
section .text
start:
    cli
    mov esp, stack_top          ; <── stack_top now defined below
    call kernel_main
.hang:
    hlt
    jmp .hang

; ── Simple 16 KiB stack ───────────────────────────────────────────────────────
section .bss
align 16
stack_bottom:
    resb 16384                  ; 16 KiB
stack_top:                      ; <── label the linker/assembler can see
