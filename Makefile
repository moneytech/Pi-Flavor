# Distributed under the terms of the GNU General Public License v2

ARMGNU ?= arm-none-eabi
ARMLD  ?= $(ARMGNU)-ld
ARMAS  ?= $(ARMGNU)-as

BUILD  = build
SOURCE = src
TARGET = kernel.img
LIST   = kernel.list
MAP    = kernel.map
LINKER = kernel.ld

OBJECTS := $(patsubst $(SOURCE)/%.s,$(BUILD)/%.o,$(wildcard $(SOURCE)/*.s))

all: $(TARGET) $(LIST)

$(LIST): $(BUILD)/output.elf
	$(ARMGNU)-objdump -d $< > $@

$(TARGET): $(BUILD)/output.elf
	$(ARMGNU)-objcopy $< -O binary $@

$(BUILD)/output.elf: $(OBJECTS) $(LINKER)
	$(ARMLD) --no-undefined $(OBJECTS) -Map $(MAP) -o $@ -T $(LINKER)

$(BUILD)/%.o: $(SOURCE)/%.s
	$(ARMAS) -I $(SOURCE)/ $< -o $@

install: $(TARGET)
	mount $(DEVICE) $(MNT)
	cp $< $(MNT)
	sync
	umount $(MNT)

clean:
	rm -f $(BUILD)/*.o

mrproper: clean
	rm -f $(TARGET)
	rm -f $(LIST)
	rm -f $(MAP)
