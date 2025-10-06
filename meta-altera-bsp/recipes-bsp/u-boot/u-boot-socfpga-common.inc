HOMEPAGE = "http://www.denx.de/wiki/U-Boot/WebHome"
SECTION = "bootloaders"

DEPENDS = "coreutils-native bc-native bison-native dtc-native flex-native"
DEPENDS:append = " python3-setuptools-native swig-native u-boot-mkimage-native"
DEPENDS:append = " u-boot-tools virtual/kernel"

DEPENDS:append = " arm-trusted-firmware bash"
COMPILE_PREPEND_FILES = " bl31.bin "
DEPLOY_APPEND_FILES = ""

LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM ?= "file://Licenses/README;md5=30503fd321432fc713238f582193b78e"
PE = "1"

UBOOT_REPO ?= "git://github.com/altera-fpga/u-boot-socfpga.git"
UBOOT_PROT ?= "https"

UBOOT_VERSION_PREFIX ?= "socfpga_"
UBOOT_VERSION ?= "v2020.07"
UBOOT_BRANCH ?= "${UBOOT_VERSION_PREFIX}${UBOOT_VERSION}"

SRCREV ?= "${AUTOREV}"
PV:append = "+git${SRCPV}"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

RPROVIDES:${PN} = "u-boot"

SRC_URI = "${UBOOT_REPO};protocol=${UBOOT_PROT};branch=${UBOOT_BRANCH}"

require ${COREBASE}/meta/recipes-bsp/u-boot/u-boot.inc
