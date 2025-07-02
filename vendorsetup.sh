#
#	This file is part of the OrangeFox Recovery Project
# 	Copyright (C) 2024-2025 The OrangeFox Recovery Project
#
#	OrangeFox is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	any later version.
#
#	OrangeFox is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
# 	This software is released under GPL version 3 or any later version.
#	See <http://www.gnu.org/licenses/>.
#
# 	Please maintain this if you use this script or any part of it
#

#set -o xtrace
FDEVICE="X6855"

# Shell compatibility detection
if [ -n "$ZSH_VERSION" ]; then
	# Running in ZSH
	THIS_DEVICE="${@: -1}"
	SCRIPT_SOURCE="${(%):-%x}"
	IS_ZSH=1
elif [ -n "$BASH_VERSION" ]; then
	# Running in BASH
	THIS_DEVICE=${BASH_ARGV[2]}
	SCRIPT_SOURCE="$BASH_SOURCE"
	IS_ZSH=0
else
	echo "ERROR! This script requires bash or zsh."
	exit 1
fi

fetch_mt6789_common_repo() {
	local URL=https://github.com/transsion-mt6789/twrp-device_transsion_mt6789-common.git
	local common=device/transsion/mt6789-common
	if [ ! -d $common ]; then
		echo "Cloning $URL ... to $common"
		git clone $URL -b fox_12.1-tranos15 $common
	else
		echo "Device common repository: \"$common\" found ..."
	fi
}

fox_get_target_device() {
	if [ "$IS_ZSH" -eq 1 ]; then
		# ZSH implementation
		local chkdev=$(echo "$SCRIPT_SOURCE" | grep -w "$FDEVICE")
		if [ -n "$chkdev" ]; then 
			FOX_BUILD_DEVICE="$FDEVICE"
		else
			chkdev=$(set | grep -E "(argv|@)" | grep -w "$FDEVICE")
			[ -n "$chkdev" ] && FOX_BUILD_DEVICE="$FDEVICE"
		fi
	else
		# BASH implementation
		local chkdev=$(echo "$SCRIPT_SOURCE" | grep -w "$FDEVICE")
		if [ -n "$chkdev" ]; then 
			FOX_BUILD_DEVICE="$FDEVICE"
		else
			chkdev=$(set | grep BASH_ARGV | grep -w "$FDEVICE")
			[ -n "$chkdev" ] && FOX_BUILD_DEVICE="$FDEVICE"
		fi
	fi
}

if [ -z "$1" -a -z "$FOX_BUILD_DEVICE" ]; then
	fox_get_target_device
fi

if [ "$1" = "$FDEVICE" -o "$FOX_BUILD_DEVICE" = "$FDEVICE" ]; then
	if [ -z "$THIS_DEVICE" ]; then
		if [ "$IS_ZSH" -eq 1 ]; then
			echo "NOTE: Running in ZSH mode"
		else
			echo "ERROR! This script couldn't detect the device properly. Make sure you're using bash or zsh."
			exit 1
		fi
	fi

	# Clone to fix build on minimal manifest
	git clone https://android.googlesource.com/platform/external/gflags/ -b android-12.1.0_r4 external/gflags

	# Patches
	RET=0
	cd bootable/recovery
	git apply ../../device/infinix/Infinix-X6855/patches/0001-Change-haptics-activation-file-path.patch > /dev/null 2>&1 || RET=$?
	cd ../../
	if [ $RET -ne 0 ]; then
		echo "ERROR: Patch is not applied! Maybe it's already patched?"
	else
		echo "OK: All patched"
	fi

	# mt6789-common
	fetch_mt6789_common_repo

	export FOX_USE_SPECIFIC_MAGISK_ZIP=~/Magisk/Magisk-v28.1.zip
	export FOX_VIRTUAL_AB_DEVICE=1
	export FOX_VANILLA_BUILD=1
	export FOX_ENABLE_APP_MANAGER=1
	export FOX_RECOVERY_SYSTEM_PARTITION="/dev/block/mapper/system"
	export FOX_RECOVERY_VENDOR_PARTITION="/dev/block/mapper/vendor"
	export FOX_USE_BASH_SHELL=1
	export FOX_ASH_IS_BASH=1
	export FOX_USE_TAR_BINARY=1
	export FOX_USE_LZ4_BINARY=1
	export FOX_USE_SED_BINARY=1
	export FOX_USE_XZ_UTILS=1
	export FOX_USE_ZSTD_BINARY=1
	export FOX_USE_NANO_EDITOR=1
	export FOX_DELETE_AROMAFM=1
	export OF_DEFAULT_KEYMASTER_VERSION=4.1

	# screen settings
	export OF_SCREEN_H=2400
	export OF_STATUS_H=95
	export OF_STATUS_INDENT_LEFT=48
	export OF_STATUS_INDENT_RIGHT=48
	export OF_ALLOW_DISABLE_NAVBAR=0
	export OF_CLOCK_POS=1

	# other stuff
	export OF_QUICK_BACKUP_LIST="/boot:/data"
	export OF_ENABLE_LPTOOLS=1
	export OF_NO_TREBLE_COMPATIBILITY_CHECK=1
	export FOX_USE_BASH_SHELL=1
	export FOX_USE_NANO_EDITOR=1

	# number of list options before scrollbar creation
	export OF_OPTIONS_LIST_NUM=9

	# ----- data format stuff -----
	# ensure that /sdcard is bind-unmounted before f2fs data repair or format
	export OF_UNBIND_SDCARD_F2FS=1

	# automatically wipe /metadata after data format
	export OF_WIPE_METADATA_AFTER_DATAFORMAT=1

	# avoid MTP issues after data format
	export OF_BIND_MOUNT_SDCARD_ON_FORMAT=1

	# don't spam the console with loop errors
	export OF_LOOP_DEVICE_ERRORS_TO_LOG=1

	# lz4 compression
	export OF_USE_LZ4_COMPRESSION=1

	# build all the partition tools
	export OF_ENABLE_ALL_PARTITION_TOOLS=1

	# variant
	export OF_MAINTAINER="rama982"
	#export FOX_VARIANT="R11.2-A12_ramabondanp"

	# no flashlight
	export OF_FLASHLIGHT_ENABLE=0

        # ccache
	export USE_CCACHE=1
	export CCACHE_EXEC=/usr/bin/ccache
	export CCACHE_MAXSIZE="5G"
	export CCACHE_DIR=".ccache"

	if [ ! -d ${CCACHE_DIR} ]; then
		mkdir $CCACHE_DIR
	fi
else
	if [ -z "$FOX_BUILD_DEVICE" -a -z "$SCRIPT_SOURCE" ]; then
		echo "I: This script requires bash or zsh. Not processing the $FDEVICE $(basename $0)"
	fi
fi
#
