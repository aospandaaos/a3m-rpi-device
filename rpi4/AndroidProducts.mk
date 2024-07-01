# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2019 The Android Open-Source Project
# Copyright (C) 2020 Roman Stratiienko (r.stratiienko@gmail.com)

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/rpi4.mk $(LOCAL_DIR)/rpi4car.mk

COMMON_LUNCH_CHOICES := \
    rpi4-userdebug rpi4car-userdebug
