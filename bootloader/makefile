BUILD_DIR = ../build/bootloader

BOOTLOADER_SRCS := $(wildcard *.asm)
BOOTLOADER_OBJS := $(patsubst %.asm, $(BUILD_DIR)/%.o, $(BOOTLOADER_SRCS))

all: $(BOOTLOADER_OBJS)

$(BUILD_DIR)/%.o: %.asm
	@mkdir -p $(BUILD_DIR)
	nasm -f bin $< -o $@

clean:
	rm -rf $(BUILD_DIR)/*
