DESCRIPTION = "Linux Kernel for Altera SoCFPGA"
LICENSE = "GPL-2.0-only"

KERNEL_REPO ?= "git://github.com/altera-fpga/linux-socfpga.git"
KERNEL_PROT ?= "https"

# Kernel CONFIG_LOCALVERSION
LINUX_VERSION_EXTENSION ?= "-altera"

# Build branch name
LINUX_VERSION_PREFIX ?= "socfpga-"
LINUX_VERSION_SUFFIX ?= ""
LINUX_VERSION ?= "4.0"

SRCREV ?= "${AUTOREV}"
SRCREV_machine ?= "${SRCREV}"
PV = "${LINUX_VERSION}${LINUX_VERSION_SUFFIX}"
PV:append = "+git${SRCPV}"

KBRANCH ?= "${LINUX_VERSION_PREFIX}${LINUX_VERSION}${LINUX_VERSION_SUFFIX}"

SRC_URI = "${KERNEL_REPO};protocol=${KERNEL_PROT};branch=${KBRANCH}"

require recipes-kernel/linux/linux-yocto.inc

KBUILD_DEFCONFIG ?= "socfpga_defconfig"
KCONFIG_MODE ?= "--alldefconfig"

FILESEXTRAPATHS:prepend := "${THISDIR}/linux-socfpga-lts/configs:"

INSANE_SKIP:${PN}-src = "buildpaths"

SRC_URI:append = " file://gpio_sys.scc file://usb_adapter.scc "
