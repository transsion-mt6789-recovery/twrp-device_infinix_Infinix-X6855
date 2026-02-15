#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from mt6789-common
$(call inherit-product, device/transsion/mt6789-common/common.mk)

# some OrangeFox-specific settings
$(call inherit-product, $(LOCAL_PATH)/fox_X6855.mk)
