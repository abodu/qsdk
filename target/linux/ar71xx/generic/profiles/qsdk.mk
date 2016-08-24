#
# Copyright (c) 2013 The Linux Foundation. All rights reserved.
#

STORAGE:=kmod-fs-ext4 kmod-usb-storage kmod-usb2 kmod-fs-msdos kmod-fs-ntfs \
	kmod-fs-vfat ntfs-3g kmod-nls-cp437 kmod-nls-iso8859-1

define Profile/QSDK_Base
	PACKAGES:=luci uhttpd kmod-ipt-nathelper-extra luci-app-upnp mcproxy \
	  kmod-ipt-nathelper-rtsp kmod-ipv6 \
	  quagga quagga-ripd quagga-zebra quagga-watchquagga rp-pppoe-relay \
	  -dnsmasq dnsmasq-dhcpv6 radvd wide-dhcpv6-client bridge \
	  luci-app-ddns ddns-scripts
endef

define Profile/QSDK_Test
	PACKAGES+=dosfsck e2fsprogs fdisk mkdosfs sysstat iperf devmem2 ip \
	  ethtool ip6tables iputils-tracepath iputils-tracepath6 iozone
endef

PACKAGES_WIFI_10_2:=kmod-qca-wifi-perf kmod-art2 qca-hostap-10.4 qca-hostapd-cli-10.4 \
	  qca-wpa-supplicant-10.4 qca-wpa-cli-10.4 qca-spectral qca-wapid sigma-dut-10.4 \
	  qca-acfg qca-wrapd whc whc-ui qca-wifi-fw-hw1-10.2 qca-wifi-fw-hw1-10.2-lteu \
	  qca-wifi-fw-hw1-10.2-maxclients qca-wifi-fw-hw2-10.2

PACKAGES_WIFI_10_4:=kmod-qca-wifi-10.4-unified-perf kmod-art2 \
	qca-hostap-10.4 qca-hostapd-cli-10.4 qca-wpa-supplicant-10.4 \
	qca-wpa-cli-10.4 qca-wapid sigma-dut-10.4 qca-wpc-10.4 \
	qca-acfg-10.4 qca-wrapd-10.4 qca-spectral-10.4 qcmbr-10.4 whc whc-ui \
	qca-wifi-fw-hw3-10.4-asic qca-wifi-fw-hw7-10.4-asic \
	qca-wifi-fw-hw6-10.4-asic qca-wifi-fw-hw10-10.4-asic \
	qca-wifi-fw-hw9-10.4-asic

define Profile/QSDK_Open_Router
	$(Profile/QSDK_Base)
	$(Profile/QSDK_Test)
	NAME:=Qualcomm-Atheros SDK Open Router Profile
	PACKAGES+= -kmod-ath9k -kmod-ath5k -kmod-ath -wpad-mini $(STORAGE) \
	  hostapd hostapd-utils iwinfo kmod-qca-ath10k kmod-qca-ath9k kmod-qca-ath \
	  kmod-fast-classifier kmod-usb2 luci-app-qos wireless-tools \
	  wpa-supplicant-p2p wpa-cli qca-legacy-uboot-ap121 qca-legacy-uboot-ap143-16M \
	  qca-legacy-uboot-ap152-16M
endef

define Profile/QSDK_Open_Router/Description
  QSDK Open Router package set configuration.
  This profile includes only open source packages and is designed to fit in a 16M flash. It supports:
  - Bridging and routing networking
  - LuCI web configuration interface
  - USB hard drive support
  - Samba
  - IPv4/IPv6
  - DynDns
  - Integrated 11abgn support using the ath9k driver
endef
$(eval $(call Profile,QSDK_Open_Router))

define Profile/Upstream
	$(Profile/Default)
	NAME:=Upstream Profile
	PACKAGES:=-kmod-ath9k -wpad-mini hostapd hostapd-utils kmod-qca-ath9k kmod-qca-ath \
	  wpa-supplicant-p2p wpa-cli dnsmasq-dhcpv6 wide-dhcpv6-client qca-ssdk-shell \
	  kmod-qca-ssdk-nohnat iwinfo wireless-tools uhttpd
endef

define Profile/Upstream/Description
  Upstream package set configuration.
  This profile includes only default source packages and is designed to fit in a 8M flash. It supports:
  - Default packages
  - IPv4/IPv6
  - Integrated 11abgn support using the ath9k driver
endef
$(eval $(call Profile,Upstream))

define Profile/QSDK_Wireless_Router
	NAME:=Qualcomm-Atheros SDK Wireless Router Profile
	PACKAGES+=-kmod-ath9k -kmod-ath5k -kmod-ath -wpad-mini uhttpd kmod-ipv6 \
	  kmod-ipt-nathelper-rtsp -dnsmasq dnsmasq-dhcpv6 wide-dhcpv6-client bridge \
	  kmod-qca-wifi-10.4-unified-perf qca-wpa-cli-10.4 kmod-usb-storage \
	  kmod-fs-ntfs kmod-fuse qca-hostap-10.4 qca-hostapd-cli-10.4 qca-wpa-supplicant-10.4 \
	  kmod-qca-ssdk-nohnat qca-legacy-uboot-ap136 qca-legacy-uboot-ap152-8M \
	  qca-legacy-uboot-ap151-8M qca-legacy-uboot-ap147-8M qca-legacy-uboot-db12x
endef

define Profile/QSDK_Wireless_Router/Description
  QSDK Wireless Router package set configuration.
  This profile is designed to fit in a 8M flash and supports the following features:
  - Bridging and routing networking
  - LuCI web configuration interface
  - USB hard drive support
  - Samba
  - IPv4/IPv6
  - DynDns
  - qca-wifi driver
endef
$(eval $(call Profile,QSDK_Wireless_Router))

define Profile/QSDK_Premium_Router
	$(Profile/QSDK_Base)
	$(Profile/QSDK_Test)
	NAME:=Qualcomm-Atheros SDK Premium Router Profile
	PACKAGES+= -kmod-ath9k -kmod-ath5k -kmod-ath -wpad-mini luci-app-samba \
	  streamboost kmod-fast-classifier $(STORAGE) $(PACKAGES_WIFI_10_2) \
	  qca-legacy-uboot-ap135 qca-legacy-uboot-ap152-16M kmod-qca-ssdk-hnat \
	  qca-ssdk-shell qca-legacy-uboot-ap147-16M qca-legacy-uboot-ap151-16M \
	  mtd-utils mtd-utils-nandwrite qca-legacy-uboot-ap135-nand \
	  qca-legacy-uboot-ap137-16M
endef

define Profile/QSDK_Premium_Router/Description
  QSDK Premium Router package set configuration.
  This profile is designed to fit in a 16M flash and supports the following features:
  - Bridging and routing networking
  - QCA-WiFi driver configuration
  - LuCI web configuration interface
  - Streamboost
  - USB hard drive support
  - Samba
  - IPv4/IPv6
  - DynDns
endef
$(eval $(call Profile,QSDK_Premium_Router))

define Profile/QSDK_Premium_Beeliner_Router
	$(Profile/QSDK_Base)
	NAME:=Qualcomm-Atheros SDK Premium Beeliner Router Profile
	PACKAGES+= -kmod-ath9k -kmod-ath5k -kmod-ath -wpad-mini luci-app-samba \
	  streamboost kmod-fast-classifier $(STORAGE) $(PACKAGES_WIFI_10_4) \
	  qca-legacy-uboot-ap135 qca-legacy-uboot-ap152-16M kmod-qca-ssdk-nohnat \
	  qca-ssdk-shell qca-legacy-uboot-ap147-16M qca-legacy-uboot-ap151-16M \
	  mtd-utils mtd-utils-nandwrite qca-legacy-uboot-ap135-nand \
	  qca-legacy-uboot-db12x-16M qca-legacy-uboot-ap152-dual
endef

define Profile/QSDK_Premium_Beeliner_Router/Description
  QSDK Premium Router package set configuration.
  This profile is designed to fit in a 16M flash and supports the following features:
  - Bridging and routing networking
  - QCA-WiFi driver 10.4 configuration
  - LuCI web configuration interface
  - Streamboost
  - USB hard drive support
  - Samba
  - IPv4/IPv6
  - DynDns
endef
$(eval $(call Profile,QSDK_Premium_Beeliner_Router))

define Profile/QSDK_IoE_Device
	NAME:=Qualcomm-Atheros SDK IoE Device Profile
	PACKAGES:=luci uhttpd kmod-ipt-nathelper-extra luci-app-upnp \
	  tftp-hpa mcproxy kmod-ipt-nathelper-rtsp kmod-ipv6 \
	  -dnsmasq dnsmasq-dhcpv6 radvd wide-dhcpv6-client bridge \
	  sysstat iperf devmem2 ip ethtool ip6tables

	PACKAGES+= -kmod-ath9k -kmod-ath5k -kmod-ath -wpad-mini \
	  alljoyn alljoyn-about alljoyn-c alljoyn-config alljoyn-controlpanel \
	  alljoyn-notification alljoyn-services_common \
	  hostapd hostapd-utils iwinfo  wpa-supplicant-p2p wpa-cli wireless-tools \
	  kmod-qca-ath10k kmod-qca-ath9k kmod-qca-ath \
	  kmod-fast-classifier kmod-usb2 kmod-i2c-gpio-custom \
	  qca-legacy-uboot-ap143-16M qca-legacy-uboot-ap143-32M \
	  qca-legacy-uboot-cus531-16M qca-legacy-uboot-cus531-dual \
	  qca-legacy-uboot-cus531-nand qca-legacy-uboot-cus531-32M \
	  mtd-utils mtd-utils-nandwrite
endef

define Profile/QSDK_IoE_Device/Description
	QSDK IoE Device package set configuration.
	This profile is designed to fit in a 16M flash and supports the following features:
	- QCA-WiFi driver configuration
	- IPv4/IPv6
	- AllJoyn
endef
$(eval $(call Profile,QSDK_IoE_Device))
