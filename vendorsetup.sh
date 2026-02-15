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

FOX_BUILD_DEVICE="$FDEVICE"

if [ "$1" = "$FDEVICE" -o "$FOX_BUILD_DEVICE" = "$FDEVICE" ]; then
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
	export FOX_MAINTAINER_PATCH_VERSION=$(date +"%Y%m%d")
	export FOX_USE_BASH_SHELL=1
	export FOX_USE_NANO_EDITOR=1
else
    exit 1
fi
#
