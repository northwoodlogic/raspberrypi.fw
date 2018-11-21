
# Default to building RPI1
RPI_VERSION ?= 1

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
TOOLCHAIN_DEFCONF ?= northwoodlogic_armv6_defconfig
KERNEL_BIN        ?= kernel/arch/arm/boot/zImage

# RPI 1, 2, & 3 use different configs for uboot & kernel.
ifeq ($(RPI_VERSION),1)
UBOOT_DEFCONF     ?= rpi_defconfig
KERNEL_DEFCONF    ?= northwoodlogic_bcmrpi_defconfig
endif

# My RPI2 kernel config isn't customized yet. bcm2709 is the default
# from the raspberry pi foundation
ifeq ($(RPI_VERSION),2)
UBOOT_DEFCONF     ?= rpi_2_defconfig
KERNEL_DEFCONF    ?= bcm2709_defconfig
#KERNEL_DEFCONF    ?= northwoodlogic_bcmrpi2_defconfig
endif

# RPI3 kernel in 32bit mode (which we're using) is the same kernel
# config as the RPI2.
ifeq ($(RPI_VERSION),3)
UBOOT_DEFCONF     ?= rpi_3_defconfig
KERNEL_DEFCONF    ?= bcm2709_defconfig
endif

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
