FWIMAGE            = raspberrypi1.fw

NO_CLEAN          ?= 0
BR_PATH           ?= ./toolchain
ROOT_ARCHIVE      ?= $(BR_PATH)/output/images/rootfs.tar.gz
UBOOT_BIN         ?= u-boot/u-boot.bin
UBOOT_DEFCONF     ?= rpi_defconfig
TOOLCHAIN_DEFCONF ?= northwoodlogic_armv6_defconfig

HERE    := $(shell pwd)
TC_PATH := $(shell realpath $(BR_PATH)/output/host/bin)

all: $(UBOOT_BIN)
#
#$(FWIMAGE) : $(ROOT_ARCHIVE)
#	NO_CLEAN=$(NO_CLEAN) BR_PATH=$(BR_PATH) $(BR_PATH)/output/host/bin/fakeroot ./buildfw.sh
#

$(UBOOT_BIN) : $(ROOT_ARCHIVE)
	ARCH=arm CROSS_COMPILE=$(TC_PATH)/arm-northwoodlogic-linux-gnueabihf- $(MAKE) -C u-boot $(UBOOT_DEFCONF)
	ARCH=arm CROSS_COMPILE=$(TC_PATH)/arm-northwoodlogic-linux-gnueabihf- $(MAKE) -C u-boot -j`nproc`

$(ROOT_ARCHIVE) :
	$(MAKE) -C toolchain $(TOOLCHAIN_DEFCONF)
	$(MAKE) -C toolchain

clean :
	make -C u-boot clean

clobber :
	make -C toolchain clean
