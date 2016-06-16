#
# Copyright (c) 2015 The Linux Foundation. All rights reserved.
#

define Profile/QSDK_IoE_Device
	NAME:=Qualcomm-Atheros SDK IoE Device Profile
	PACKAGES:=luci uhttpd kmod-ipt-nathelper-extra luci-app-upnp \
	  tftp-hpa mcproxy kmod-ipt-nathelper-rtsp kmod-ipv6 \
	  -dnsmasq dnsmasq-dhcpv6 radvd wide-dhcpv6-client bridge \
	  sysstat iperf devmem2 ip ethtool ip6tables -swconfig

	PACKAGES+= kmod-ath9k -kmod-ath5k kmod-ath -wpad-mini \
	  alljoyn alljoyn-about alljoyn-c alljoyn-config alljoyn-controlpanel \
	  alljoyn-notification alljoyn-services_common \
	  hostapd hostapd-utils iwinfo  wpa-supplicant-p2p wpa-cli wireless-tools \
	  kmod-qca-ath10k -kmod-qca-ath9k -kmod-qca-ath kmod-usb2 kmod-i2c-gpio-custom kmod-button-hotplug \
	  qca-legacy-uboot-ap143-16M qca-legacy-uboot-ap143-32M \
	  qca-legacy-uboot-cus531-16M qca-legacy-uboot-cus531-dual \
	  qca-legacy-uboot-cus531-nand qca-legacy-uboot-cus531-32M \
	  qca-legacy-uboot-cus532k qca-legacy-uboot-cus531mp3-nand \
	  mtd-utils mtd-utils-nandwrite mtd-utils-ubiattach mtd-utils-ubidetach
endef

define Profile/QSDK_IoE_Device/Description
	QSDK IoE Device package set configuration.
	This profile is designed to fit in a 16M flash and supports the following features:
	- QCA-WiFi driver configuration
	- IPv4/IPv6
	- AllJoyn
endef
$(eval $(call Profile,QSDK_IoE_Device))
