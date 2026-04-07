SUMMARY = "Altera SoCFPGA Development Kit devicetrees"
DESCRIPTION = "Devicetree addons for Altera SoCFPGA Development Kit examples"
SECTION = "bsp"

LICENSE = "MIT & GPL-2.0-only"

KERNEL_INCLUDE = " \
        ${STAGING_KERNEL_DIR}/arch/${ARCH}/boot/dts \
        ${STAGING_KERNEL_DIR}/arch/${ARCH}/boot/dts/* \
        ${STAGING_KERNEL_DIR}/scripts/dtc/include-prefixes \
        "
inherit devicetree

PROVIDES = "virtual/dtb"

COMPATIBLE_MACHINE = "${MACHINE}"

do_configure[depends] += "virtual/kernel:do_configure"

FPGA_CORE_PGM_ENABLE ?= "0"

# False - In-tree device tree
# True - Custom device tree
CUSTOM_LINUX_DT ?= "0"
CUSTOM_DTS_FILE = ""
GHRD_DTSI_FILE = ""

# Kernel DTS name from kas.yml (with revision suffix, without .dts extension)
DTS_NAME ?= ""

# DTB name from kas.yml (base name without revision, without .dtb extension)
DTB_NAME ?= ""

# These will be computed
DTS_BASE_NAME ?= ""
DTS_VANILLA_NAME ?= ""

do_install() {
    :
}
