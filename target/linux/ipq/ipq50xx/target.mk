
SUBTARGET:=ipq50xx
BOARDNAME:=QCA IPQ50XX(32bit) based boards
CPU_TYPE:=cortex-a7

DEFAULT_PACKAGES += \
	uboot-2016-ipq5018 fwupgrade-tools

define Target/Description
	Build firmware image for IPQ50xx SoC devices.
endef
