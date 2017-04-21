#!/bin/bash

#
#  Build Script for Helix Kernel for HTC 10!
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
VARIANT="HelixKernel-EAS-HTC10"

# Vars
export LOCALVERSION=~`echo $VARIANT-$VER`
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=ZeroInfinity
export KBUILD_BUILD_HOST=elementaryOS
export CCACHE=ccache

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="${HOME}/Documents/kernel-installers/AnyKernel2"
PATCH_DIR="${HOME}/Documents/kernel-installers/AnyKernel2/patch"
RAMDISK_DIR="${HOME}/Documents/kernel-installers/AnyKernel2/ramdisk"
MODULES_DIR="${HOME}/Documents/kernel-installers/AnyKernel2/modules"
AROMA_DIR="${HOME}/Documents/kernel-installers/AROMA"
ZIP_MOVE="${HOME}/Documents/kernel-builds"
ZIMAGE_DIR="${HOME}/Documents/HelixKernel-PME-EAS/out/arch/arm64/boot"

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

function make_aroma {	
	cd $AROMA_DIR
	zip -r9 "$VARIANT"-"$VER".zip *
	mv "$VARIANT"-"$VER".zip $ZIP_MOVE/"$VARIANT"-"$VER".zip
	cd $KERNEL_DIR
}

function make_zip {
	cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
	cd $REPACK_DIR
	zip -r9 kernel.zip *
	mv kernel.zip $AROMA_DIR/kernel/kernel.zip
}


function toolchain {
	echo "Select Toolchain:"
	select choice in Google-Android-4.9-Default LINARO-aarch64-linux-gnu-6.3.1-170217
	do
	case "$choice" in
		"Google-Android-4.9-Default")
			export TOOLCHAIN=/home/augustine/Android/Sdk/ndk-bundle/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/aarch64-linux-android-
			break;;
		"LINARO-aarch64-linux-gnu-6.3.1-170217")
			export TOOLCHAIN=/home/augustine/Documents/toolchains/gcc-linaro-6.3.1-2017.02-i686_aarch64-linux-gnu/bin/aarch64-linux-gnu-
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
			make_aroma
			break;;
		"No")
			make_zip
			make_aroma
			break;;
	esac
	done
}


DATE_START=$(date +"%s")

echo -e "${green}"
echo "Helix Kernel Creation Script:"
echo -e "${restore}"

echo "Main Menu"
select choice in Compile_Kernel Clean_Compile Make_AROMA_zip Exit
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
	"Make_AROMA_zip")
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
