#!/bin/bash

#
#  Build Script based off Helix Kernel script - thanks!
#  Based off AK'sbuild script - Thanks!
#

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image.gz-dtb"
DEFCONFIG="msm_defconfig"

# Kernel Details
VER=
VARIANT="AtomSplitter"

# Vars
export LOCALVERSION=~`echo $VARIANT-$VER`
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=Cortex
export KBUILD_BUILD_HOST=ubuntu
export CCACHE=ccache

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="${HOME}/AnyKernel2"
PATCH_DIR="${HOME}/AnyKernel2/patch"
RAMDISK_DIR="${HOME}/AnyKernel2/ramdisk"
MODULES_DIR="${HOME}/AnyKernel2/modules"
ZIP_MOVE="${HOME}/Documents/kernel-builds"
ZIMAGE_DIR="${HOME}/kernels/pme/out/arch/arm64/boot"

# Functions
function clean_all {
	cd $REPACK_DIR
	rm -rf $MODULES_DIR/*
	rm -rf zImage
	cd $KERNEL_DIR
	echo
	make clean && make mrproper
	rm -rf $KERNEL_DIR/out
	./clean-junk.sh
}

function make_kernel {
	echo
	make ARCH=arm64 CROSS_COMPILE=$TOOLCHAIN O=out $DEFCONFIG
	make ARCH=arm64 CROSS_COMPILE=$TOOLCHAIN O=out $THREAD
}

function make_modules {
	rm `echo $MODULES_DIR"/*"`
	find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
}

function make_zip {
	cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
	cd $REPACK_DIR
	zip -r9 kernel.zip *
}

function toolchain {
	echo "Select Toolchain:"
	select choice in Google-4.9 gcc-linaro-4.9.4 gcc-linaro-6.4.1 gcc-linaro-7.2.1
	do
	case "$choice" in
		"Google-4.9")
			export TOOLCHAIN=${HOME}/toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-
			break;;
		"gcc-linaro-4.9.4")
			export TOOLCHAIN=${HOME}/toolchains/gcc-linaro-4.9.4/bin/aarch64-linux-gnu-
			break;;
		"gcc-linaro-6.4.1")
			export TOOLCHAIN=${HOME}/toolchains/gcc-linaro-6.4.1/bin/aarch64-linux-gnu-
			break;;
		"gcc-linaro-7.2.1")
			export TOOLCHAIN=${HOME}/toolchains/gcc-linaro-7.2.1/bin/aarch64-linux-gnu-
			break;;
	esac
	done
}

function modules {
	echo "Need modules?"
	select choice in Yes No
	do
	case "$choice" in
		"Yes")
			make_modules
			make_zip
			break;;
		"No")
			make_zip
			break;;
	esac
	done
}


DATE_START=$(date +"%s")

echo -e "${green}"
echo "Kernel Creation Script:"
echo -e "${restore}"

echo "Main Menu"
select choice in Compile_Kernel Clean_Compile Exit
do
case "$choice" in
	"Compile_Kernel")
		toolchain
		make_kernel
		modules
		break;;
	"Clean_Compile")
		clean_all
		echo "All Cleaned now."
		toolchain
		echo "Now Compiling."
		make_kernel
		modules
		break;;
	"Exit")
		echo "Goodbye."
		break;;
esac
done

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
