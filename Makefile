# **************************************************************************** #
#                                                                              #
#                Minimal 32-bit kernel build (freestanding, GRUB)              #
# **************************************************************************** #

NAME     := kfs
BIN      := $(NAME).bin
ISO_DIR  := iso
ISO      := $(NAME).iso

# Pick host tools by default; allow CROSS=… override, e.g. CROSS=i686-elf-
CROSS    ?=
CC       ?= $(CROSS)gcc
LD       ?= $(CROSS)ld
NASM     ?= nasm
RM       ?= rm -f

# -----------------------------------------------------------------------------#
# Flags
# -----------------------------------------------------------------------------#
CFLAGS   := -std=c11 -Wall -Wextra                            \
            -ffreestanding -nostdlib -nodefaultlibs           \
            -fno-builtin -fno-stack-protector                 \
            -m32 -g                                           \
            -Iboot/source/include

LDFLAGS  := -m elf_i386 -T boot/linker.ld

# -----------------------------------------------------------------------------#
# Sources & objects
# -----------------------------------------------------------------------------#
CFILES   := boot/source/kernel.c \
            boot/source/string.c

BOOT_ASM := boot/boot.asm

CFG      := boot/grub/grub.cfg

BOOT_OBJ := $(BOOT_ASM:.asm=.o)
C_OBJS   := $(CFILES:.c=.o)

OBJS     := $(BOOT_OBJ) $(C_OBJS)

# -----------------------------------------------------------------------------#
# Phony targets
# -----------------------------------------------------------------------------#
.PHONY: all clean fclean re run kernel gdb

# -----------------------------------------------------------------------------#
# Default target
# -----------------------------------------------------------------------------#
all: $(ISO)

# -----------------------------------------------------------------------------#
# Build rules
# -----------------------------------------------------------------------------#
%.o: %.c
	@echo "\033[0;33m[CC] $<\033[0m"
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.asm
	@echo "\033[0;33m[AS] $<\033[0m"
	$(NASM) -f elf32 -g -F dwarf $< -o $@

$(BIN): $(OBJS)
	@echo "\033[0;33m[LD] $@\033[0m"
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

$(ISO): $(BIN) $(CFG)
	@echo "\033[0;33m[ISO] $@\033[0m"
	@mkdir -p $(ISO_DIR)/boot/grub
	cp $(BIN)                $(ISO_DIR)/boot/
	cp $(CFG)                $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $@ $(ISO_DIR) >/dev/null 2>&1
	@echo "\033[0;32mISO image ready → $(ISO)\033[0m"

# -----------------------------------------------------------------------------#
# House-keeping
# -----------------------------------------------------------------------------#
clean:
	@echo "\033[0;31mCleaning object files\033[0m"
	$(RM) $(OBJS)

fclean: clean
	@echo "\033[0;31mRemoving binaries and ISO\033[0m"
	$(RM) $(BIN) $(ISO)
	$(RM) -r $(ISO_DIR)

re: fclean all

# -----------------------------------------------------------------------------#
# Convenience targets
# -----------------------------------------------------------------------------#
run: $(ISO)
	qemu-system-i386 -cdrom $(ISO)

kernel: $(BIN)
	qemu-system-i386 -kernel $(BIN)

gdb: $(BIN)
	qemu-system-i386 -S -s -kernel $(BIN)
