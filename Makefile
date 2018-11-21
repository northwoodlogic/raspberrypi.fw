
ifeq ($(WITH_PURPLE_BOARD),1)
BOARD = purple
else
BOARD = vanilla
endif

FWIMAGE            = rpi-$(BOARD).fw
FWIMAGE_SRC        = rpi-$(BOARD).its

NO_CLEAN          ?= 0
BR_PATH           ?= ./toolchain
ROOT_ARCHIVE      ?= $(BR_PATH)/output/images/rootfs.tar.gz
UBOOT_BIN         ?= u-boot/u-boot.bin
UBOOT_DEFCONF     ?= rpi_defconfig
TOOLCHAIN_DEFCONF ?= northwoodlogic_armv6_defconfig
KERNEL_DEFCONF    ?= northwoodlogic_bcmrpi_defconfig
KERNEL_BIN        ?= kernel/arch/arm/boot/zImage

INITRD            ?= initrd.gz

HERE    := $(shell pwd)
TC_PATH := $(shell realpath $(BR_PATH)/output/host/bin)

CROSS_ARCH    ?=arm
CROSS_COMPILE ?=$(TC_PATH)/arm-northwoodlogic-linux-gnueabihf-

all: $(FWIMAGE) $(UBOOT_BIN)
#
$(FWIMAGE) : $(INITRD) $(KERNEL_BIN)
	PATH=$(TC_PATH):$(PATH) $(TC_PATH)/mkimage -f $(FWIMAGE_SRC) $(FWIMAGE)


$(UBOOT_BIN) : $(ROOT_ARCHIVE)
	ARCH=$(CROSS_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C u-boot $(UBOOT_DEFCONF)
	ARCH=$(CROSS_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C u-boot -j`nproc`

$(KERNEL_BIN) : $(ROOT_ARCHIVE)
	ARCH=$(CROSS_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C kernel $(KERNEL_DEFCONF)
	ARCH=$(CROSS_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C kernel -j`nproc` zImage
	ARCH=$(CROSS_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C kernel -j`nproc` modules
	ARCH=$(CROSS_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C kernel -j`nproc` dtbs

$(INITRD) : $(ROOT_ARCHIVE) $(KERNEL_BIN)
	ARCH=$(CROSS_ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(TC_PATH)/fakeroot ./scripts/build-initrd.sh

$(ROOT_ARCHIVE) :
	$(MAKE) -C toolchain $(TOOLCHAIN_DEFCONF)
	$(MAKE) -C toolchain

clean :
	make -C u-boot clean

clobber :
	make -C toolchain clean
