SUMMARY = "SOC FPGA Xen passthrough example"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRCREV = "bdb3cd3da3f8973afb8f39fbfb729a50fdd68740"
XEN_DTB_BRANCH ?= "master"
XEN_DTB_REPO ?= "git://github.com/altera-fpga/xen-passthrough-examples.git"
XEN_DTB_PROT ?= "https"

SRC_URI = "${XEN_DTB_REPO};protocol=${XEN_DTB_PROT};branch=${XEN_DTB_BRANCH}"

# Add dtc-native to the build dependencies
DEPENDS += "dtc-native"

# Use MACHINE_STRIP for xen-passthrough example directories
# (e.g., agilex5e_013b, agilex5e -> agilex5; agilex3 -> agilex3)
XEN_PASSTHROUGH_DIR = "${MACHINE_STRIP}"

do_compile() {
    if [ -d "${S}/${XEN_PASSTHROUGH_DIR}" ]; then
        for dts_file in ${S}/${XEN_PASSTHROUGH_DIR}/*.dts; do
            [ -e "${dts_file}" ] && dtc -O dtb -I dts -o ${B}/$(basename ${dts_file} .dts).dtb ${dts_file}
        done
    else
        bbwarn "XEN passthrough examples not found for ${MACHINE} (looking in ${S}/${XEN_PASSTHROUGH_DIR})"
    fi
}

FILES:${PN} = "/home/root/xen"

do_install() {
    install -d ${D}/home/root/xen

    # Install compiled DTB files
    for dtb_file in ${B}/*.dtb; do
        [ -e "${dtb_file}" ] && install -m 0644 ${dtb_file} ${D}/home/root/xen/$(basename ${dtb_file})
    done

    # Install configuration files from machine-specific subdirectory
    if [ -d "${S}/${XEN_PASSTHROUGH_DIR}" ]; then
        for cfg_file in ${S}/${XEN_PASSTHROUGH_DIR}/*.cfg; do
            [ -e "${cfg_file}" ] && install -m 0644 ${cfg_file} ${D}/home/root/xen/$(basename ${cfg_file})
        done
    fi
}
