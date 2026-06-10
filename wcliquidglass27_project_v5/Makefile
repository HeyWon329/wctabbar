ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = WeChat
THEOS_PACKAGE_SCHEME ?= rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = wcliquidglass27
wcliquidglass27_FILES = Tweak.xm
wcliquidglass27_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-arc-performSelector-leaks -Wno-error -Wno-error=unused-function -Wno-error=unused-variable -Wno-error=unused-value -Wno-error=deprecated-declarations -Wno-error=unguarded-availability-new -Wno-unused-function -Wno-unused-variable -Wno-unused-value
wcliquidglass27_FRAMEWORKS = UIKit Foundation QuartzCore CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk
