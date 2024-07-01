# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2020 Roman Stratiienko (r.stratiienko@gmail.com)

#$(call inherit-product, device/glodroid/rpi4/device.mk)

# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2020 Roman Stratiienko (r.stratiienko@gmail.com)

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)


# Exclude features that are not available on AOSP devices.
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/aosp_excluded_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/aosp_excluded_hardware.xml

$(call inherit-product, device/glodroid/common/device-common.mk)
$(call inherit-product, device/glodroid/common/bluetooth/bluetooth.mk)


#### Build Automotive
# Reference: aosp-13/device/google/cuttlefish/vsoc_x86/auto/aosp_cf.mk
# and 

#
# All components inherited here go to system image
#
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_system.mk)

# FIXME: generic_system.mk sets 'PRODUCT_ENFORCE_RRO_TARGETS := *'
#        but this breaks phone_car. So undo it here.
PRODUCT_ENFORCE_RRO_TARGETS := frameworks-res

# FIXME: Disable mainline path checks
PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := false

#
# All components inherited here go to system_ext image
#
$(call inherit-product, $(SRC_TARGET_DIR)/product/base_system_ext.mk)

#
# All components inherited here go to product image
#
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_product.mk)

#
# All components inherited here go to vendor image
#
# Reference: aosp-13/device/google/cuttlefish/shared/auto/device_vendor.mk

# TBD:
#DEVICE_MANIFEST_FILE += device/google/cuttlefish/shared/auto/manifest.xml
#PRODUCT_MANIFEST_FILES += device/google/cuttlefish/shared/config/product_manifest.xml
#SYSTEM_EXT_MANIFEST_FILES += device/google/cuttlefish/shared/config/system_ext_manifest.xml

$(call inherit-product, $(SRC_TARGET_DIR)/product/handheld_vendor.mk)
$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)
$(call inherit-product, packages/services/Car/car_product/build/car.mk)
# TBD:
# $(call inherit-product, device/google/cuttlefish/shared/device.mk)

PRODUCT_VENDOR_PROPERTIES += \
    keyguard.no_require_sim=true \
    ro.cdma.home.operator.alpha=Android \
    ro.cdma.home.operator.numeric=302780 \
    ro.com.android.dataroaming=true \
    ro.telephony.default_network=9 \

# RIL support
TARGET_NO_TELEPHONY := true

# Extend cuttlefish common sepolicy with auto-specific functionality
# TBD:
# BOARD_SEPOLICY_DIRS += device/google/cuttlefish/shared/auto/sepolicy/vendor

################################################
# Begin general Android Auto Embedded configurations

PRODUCT_COPY_FILES += \
    packages/services/Car/car_product/init/init.bootstat.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.bootstat.rc \
    packages/services/Car/car_product/init/init.car.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.car.rc

ifneq ($(LOCAL_SENSOR_FILE_OVERRIDES),true)
    PRODUCT_COPY_FILES += \
        frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
        frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml
endif

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/car_core_hardware.xml:system/etc/permissions/car_core_hardware.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.broadcastradio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.broadcastradio.xml \
    frameworks/native/data/etc/android.hardware.faketouch.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.faketouch.xml \
    frameworks/native/data/etc/android.hardware.screen.landscape.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.landscape.xml \
    frameworks/native/data/etc/android.software.activities_on_secondary_displays.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.activities_on_secondary_displays.xml \

# Preinstalled packages per user type
# TBD:
#PRODUCT_COPY_FILES += \
    device/google/cuttlefish/shared/auto/preinstalled-packages-product-car-cuttlefish.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/preinstalled-packages-product-car-cuttlefish.xml

# TBD:
#ifndef LOCAL_AUDIO_PRODUCT_COPY_FILES
#LOCAL_AUDIO_PRODUCT_COPY_FILES := \
    device/google/cuttlefish/shared/auto/car_audio_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/car_audio_configuration.xml \
    device/google/cuttlefish/shared/auto/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml
#endif

# Broadcast Radio
PRODUCT_PACKAGES += android.hardware.broadcastradio@2.0-service

# AudioControl HAL
#ifeq ($(LOCAL_AUDIOCONTROL_HAL_PRODUCT_PACKAGE),)
    LOCAL_AUDIOCONTROL_HAL_PRODUCT_PACKAGE := android.hardware.automotive.audiocontrol-service.example
    BOARD_SEPOLICY_DIRS += device/google/cuttlefish/shared/auto/sepolicy/audio
#endif
#PRODUCT_PACKAGES += $(LOCAL_AUDIOCONTROL_HAL_PRODUCT_PACKAGE)

# CAN bus HAL
PRODUCT_PACKAGES += android.hardware.automotive.can@1.0-service
PRODUCT_PACKAGES_DEBUG += canhalctrl \
    canhaldump \
    canhalsend

# VHAL
PRODUCT_PACKAGES += android.hardware.automotive.vehicle@2.0-default-service 

# EVS
# By default, we enable EvsManager, a sample EVS app, and a mock EVS HAL implementation.
# If you want to use your own EVS HAL implementation, please set ENABLE_MOCK_EVSHAL as false
# and add your HAL implementation to the product.  Please also check init.evs.rc and see how
# you can configure EvsManager to use your EVS HAL implementation.  Similarly, please set
# ENABLE_SAMPLE_EVS_APP as false if you want to use your own EVS app configuration or own EVS
# app implementation.
#ENABLE_EVS_SERVICE ?= true
#ENABLE_MOCK_EVSHAL ?= true
#ENABLE_CAREVSSERVICE_SAMPLE ?= true
#ENABLE_SAMPLE_EVS_APP ?= true
#ENABLE_CARTELEMETRY_SERVICE ?= true

#ifeq ($(ENABLE_MOCK_EVSHAL), true)
#CUSTOMIZE_EVS_SERVICE_PARAMETER := true
#PRODUCT_PACKAGES += android.hardware.automotive.evs@1.1-service \
    android.frameworks.automotive.display@1.0-service
#PRODUCT_COPY_FILES += \
    device/google/cuttlefish/shared/auto/evs/init.evs.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.evs.rc
#BOARD_SEPOLICY_DIRS += device/google/cuttlefish/shared/auto/sepolicy/evs
#endif

#ifeq ($(ENABLE_SAMPLE_EVS_APP), true)
#PRODUCT_PACKAGES += evs_app
#PRODUCT_COPY_FILES += \
    device/google/cuttlefish/shared/auto/evs/evs_app_config.json:$(TARGET_COPY_OUT_SYSTEM)/etc/automotive/evs/config_override.json
#BOARD_SEPOLICY_DIRS += packages/services/Car/cpp/evs/apps/sepolicy/private
#ifeq ($(ENABLE_CARTELEMETRY_SERVICE), true)
#BOARD_SEPOLICY_DIRS += packages/services/Car/cpp/evs/apps/sepolicy/cartelemetry
#endif
#endif

BOARD_IS_AUTOMOTIVE := true

#DEVICE_PACKAGE_OVERLAYS += device/google/cuttlefish/shared/auto/overlay

#PRODUCT_PACKAGES += CarServiceOverlayCuttleFish
#GOOGLE_CAR_SERVICE_OVERLAY += CarServiceOverlayCuttleFishGoogle

#TARGET_BOARD_INFO_FILE ?= device/google/cuttlefish/shared/auto/android-info.txt



# Firmware
PRODUCT_COPY_FILES += \
        vendor/raspberry/firmware-nonfree/brcm/brcmfmac43455-sdio.clm_blob:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/brcmfmac43455-sdio.clm_blob \
        vendor/raspberry/firmware-nonfree/brcm/brcmfmac43455-sdio.bin:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/brcmfmac43455-sdio.bin \
        vendor/raspberry/firmware-nonfree/brcm/brcmfmac43455-sdio.txt:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/brcmfmac43455-sdio.txt \
        vendor/raspberry/firmware-nonfree/brcm/brcmfmac43456-sdio.clm_blob:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/brcmfmac43456-sdio.clm_blob \
        vendor/raspberry/firmware-nonfree/brcm/brcmfmac43456-sdio.bin:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/brcmfmac43456-sdio.bin \
        vendor/raspberry/firmware-nonfree/brcm/brcmfmac43456-sdio.txt:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/brcmfmac43456-sdio.txt \
        device/glodroid/rpi4/BCM4345C0.hcd:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/BCM4345C0.hcd \
        device/glodroid/rpi4/BCM4345C5.hcd:$(TARGET_COPY_OUT_VENDOR)/etc/firmware/brcm/BCM4345C5.hcd \

PRODUCT_COPY_FILES += \
    device/glodroid/rpi4/audio.rpi4.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio.rpi4.xml \

# Disable suspend. During running some VTS device suspends, which sometimed causes kernel to crash in WIFI driver and reboot.
PRODUCT_COPY_FILES += \
    device/glodroid/common/no_suspend.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/no_suspend.rpi4.rc \

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/power.rpi4.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/power.rpi4.rc \
    $(LOCAL_PATH)/snd.rpi4.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/snd.rpi4.rc     \

# Checked by android.opengl.cts.OpenGlEsVersionTest#testOpenGlEsVersion. Required to run correct set of dEQP tests.
# 196609 == 0x00030001 == GLES v3.1
PRODUCT_VENDOR_PROPERTIES += \
    ro.opengles.version=196609

# Camera
PRODUCT_PACKAGES += ipa_rpi ipa_rpi.so.sign

LIBCAMERA_CFGS := \
    imx219.json imx219_noir.json imx290.json imx378.json imx477.json imx477_noir.json \
    meson.build ov5647.json ov5647_noir.json ov9281.json se327m12.json uncalibrated.json

PRODUCT_COPY_FILES += $(foreach cfg,$(LIBCAMERA_CFGS),external/libcamera/src/ipa/raspberrypi/data/$(cfg):$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/raspberrypi/$(cfg)$(space))

# Vulkan
PRODUCT_PACKAGES += \
    vulkan.broadcom

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.vulkan.level-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_0_3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2022-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml \

PRODUCT_VENDOR_PROPERTIES +=    \
    ro.hardware.vulkan=broadcom \

# It is the only way to set ro.hwui.use_vulkan=true
#TARGET_USES_VULKAN = true




PRODUCT_BOARD_PLATFORM := broadcom
PRODUCT_NAME := rpi4
PRODUCT_DEVICE := rpi4
PRODUCT_BRAND := RaspberryPI
PRODUCT_MODEL := rpi4
PRODUCT_MANUFACTURER := RaspberryPiFoundation

UBOOT_DEFCONFIG := rpi_4_defconfig
ATF_PLAT        := rpi4

KERNEL_DEFCONFIG := kernel/glodroid-broadcom/arch/arm64/configs/bcm2711_defconfig

KERNEL_FRAGMENTS := \
    $(LOCAL_PATH)/kernel.config \

KERNEL_DTB_FILE := broadcom/bcm2711-rpi-4-b.dtb

SYSFS_MMC0_PATH := emmc2bus/fe340000.mmc

RPI_CONFIG := $(LOCAL_PATH)/config.txt
