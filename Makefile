NAME     := kfs
BIN      := $(NAME).bin
ISO      := $(NAME).iso
ISO_DIR  := iso

CC       := gcc
LD       := ld
NASM     := nasm
RM       := rm -f

CFLAGS   := -Wall -Wextra -Werror \
            -ffreestanding -fno-builtin -fno-stack-protector \
            -nostdlib \
            -g3 -m32 \
            -Iboot/source/include

LDFLAGS  := -m elf_i386 -T boot/linker.ld

CFILES   := boot/source/kernel.c boot/source/string.c
BOOT_ASM := boot/boot.asm
CFG      := boot/grub/grub.cfg

C_OBJS   := $(CFILES:.c=.o)
BOOT_OBJ := $(BOOT_ASM:.asm=.o)
OBJS     := $(C_OBJS) $(BOOT_OBJ)

.PHONY: all clean fclean re run kernel gdb

all: $(ISO)

%.o: %.c
	@echo "[CC] $<"
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.asm
	@echo "[AS] $<"
	$(NASM) -f elf32 -g -F dwarf $< -o $@

$(BIN): $(OBJS)
	@echo "[LD] $@"
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

$(ISO): $(BIN) $(CFG)
	@echo "[ISO] $@"
	@mkdir -p $(ISO_DIR)/boot/grub
	cp $(BIN) $(ISO_DIR)/boot/
	cp $(CFG) $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $@ $(ISO_DIR) >/dev/null 2>&1
	@echo "ISO image ready → $@"

clean:
	@echo "Cleaning object files"
	$(RM) $(OBJS)

fclean: clean
	@echo "Removing binaries and ISO"
	$(RM) $(BIN) $(ISO)
	$(RM) -r $(ISO_DIR)

re: fclean all

run: $(ISO)
	qemu-system-i386 -cdrom $(ISO)

kernel: $(BIN)
	qemu-system-i386 -kernel $(BIN)

gdb: $(BIN)
	qemu-system-i386 -S -s -kernel $(BIN)
