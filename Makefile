ARCHS = armv7
TARGET = iphone:clang:6.1:5.1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = iPad1DOCXReader

iPad1DOCXReader_FILES = \
	main.m \
	AppDelegate.m \
	DocumentReaderViewController.m \
	DocumentRichTextView.m \
	DOCXReader.m

iPad1DOCXReader_FRAMEWORKS = UIKit Foundation CoreGraphics CoreText
iPad1DOCXReader_LIBRARIES = z
iPad1DOCXReader_CFLAGS = -fno-objc-arc -Wall
iPad1DOCXReader_RESOURCE_DIRS = Resources
iPad1DOCXReader_INSTALL_PATH = /Applications

include $(THEOS_MAKE_PATH)/application.mk
