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

python __anonymous() {
    import os

    dts_path = d.getVar("KERNEL_DEVICE_TREE_SRC_PATH")
    if not os.path.isdir(dts_path):
        bb.fatal("KERNEL_DEVICE_TREE_SRC_PATH does not exist: " + dts_path)
    d.setVar("DEVICE_TREE_PATH", dts_path)

    dts_file = None
    dtsi_file = None

    # Find .dts file (excluding .dtsi)
    for fname in os.listdir(dts_path):
        if fname.lower().endswith(".dts") and not fname.lower().endswith(".dtsi"):
            dts_file = fname
            break

    if dts_file:
        d.setVar("CUSTOM_DTS_FILE", dts_file)

    # Find .dtsi file
    for fname in os.listdir(dts_path):
        if fname.lower().endswith(".dtsi"):
            dtsi_file = fname
            break

    if dtsi_file:
        d.setVar("GHRD_DTSI_FILE", dtsi_file)
}

do_configure:append () {
    if [ "${FPGA_CORE_PGM_ENABLE}" = "1" ] && [ "${CUSTOM_LINUX_DT}" = "1" ]; then
        if [ -f "${DEVICE_TREE_PATH}/${CUSTOM_DTS_FILE}" ] && [ -f "${DEVICE_TREE_PATH}/${GHRD_DTSI_FILE}" ] ; then
            # Overwrite default device tree with custom device tree
            cp ${DEVICE_TREE_PATH}/${CUSTOM_DTS_FILE} ${WORKDIR}/sources/socfpga_agilex5_vanilla.dts
            cp ${DEVICE_TREE_PATH}/${CUSTOM_DTS_FILE} ${WORKDIR}/sources/socfpga_agilex5_socdk.dts
            cp ${DEVICE_TREE_PATH}/${GHRD_DTSI_FILE} ${WORKDIR}/sources/${GHRD_DTSI_FILE}
            sed -i "\$a #include \"${GHRD_DTSI_FILE}\"" ${WORKDIR}/sources/socfpga_agilex5_socdk.dts
        else
            bbfatal "${DEVICE_TREE_PATH}/${CUSTOM_DTS_FILE} file not found, add in recipe files directory!"
        fi
    elif [ "${FPGA_CORE_PGM_ENABLE}" = "1" ] && [ "${CUSTOM_LINUX_DT}" = "0" ]; then
        cp ${STAGING_KERNEL_DIR}/arch/${ARCH}/boot/dts/intel/socfpga_agilex5_socdk_a0.dts ${WORKDIR}/sources/socfpga_agilex5_vanilla.dts
        cp ${STAGING_KERNEL_DIR}/arch/${ARCH}/boot/dts/intel/socfpga_agilex5_socdk_a0.dts ${WORKDIR}/sources/socfpga_agilex5_socdk.dts
        if [ -f "${DEVICE_TREE_PATH}/${GHRD_DTSI_FILE}" ] ; then
            cp ${DEVICE_TREE_PATH}/${GHRD_DTSI_FILE} ${WORKDIR}/sources/${GHRD_DTSI_FILE}
            sed -i "\$a #include \"${GHRD_DTSI_FILE}\"" ${WORKDIR}/sources/socfpga_agilex5_socdk.dts
        else
            bbfatal "${DEVICE_TREE_PATH}/${GHRD_DTSI_FILE} file not found, add in recipe files directory!"
        fi
    else
        cp ${STAGING_KERNEL_DIR}/arch/${ARCH}/boot/dts/intel/socfpga_agilex5_socdk_a0.dts ${WORKDIR}/sources/socfpga_agilex5_vanilla.dts
        cp ${STAGING_KERNEL_DIR}/arch/${ARCH}/boot/dts/intel/socfpga_agilex5_socdk_a0.dts ${WORKDIR}/sources/socfpga_agilex5_socdk.dts
    fi
}
