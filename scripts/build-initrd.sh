#!/bin/sh

# This script should be run with fakeroot from the makefile, CROSS_COMPILE and
# ARCH should be set in the calling environment.

set -e
set -x

: ${INITRD_FS="initrd-fs"}
: ${ROOT_ARCHIVE="toolchain/output/images/rootfs.tar.gz"}
: ${CROSS_COMPILE="/dev/null"}

INITRD_FS=$(realpath ${INITRD_FS})
ROOT_ARCHIVE=$(realpath ${ROOT_ARCHIVE})
HERE=$(pwd)

rm   -Rf ${INITRD_FS}
mkdir -p ${INITRD_FS}

(
	cd ${INITRD_FS}
	tar -xf ${ROOT_ARCHIVE}
	tar -cf - -C ${HERE}/overlay/ . | tar -xvf - --no-same-owner --no-overwrite-dir

	make -C ${HERE}/kernel \
		ARCH=${ARCH} \
		CROSS_COMPILE=${CROSS_COMPILE} \
		INSTALL_MOD_PATH=${INITRD_FS} modules_install

	MODULES="$(find lib/modules -name *.ko)"
	for m in ${MODULES} ; do
		${CROSS_COMPILE}strip --strip-debug ${m} || true
	done

	# install user application code here...

	find . | cpio -o -H newc | gzip > ../initrd.gz
)

