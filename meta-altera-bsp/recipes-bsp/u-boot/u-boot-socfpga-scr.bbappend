SUMMARY = "U-boot boot scripts for Altera SoCFPGA devices - XEN Support"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DEPENDS += "u-boot-mkimage-native dtc-native"

HYP_BUILD ??= "0"

# Append XEN boot script files when HYP_BUILD is enabled (machine-specific via MACHINE variable)
SRC_URI:append = " ${@bb.utils.contains('HYP_BUILD', '1', 'file://uboot_xen_${MACHINE}.txt file://uboot_script_xen.its', '', d)}"

# Override do_compile to add XEN boot script generation
do_compile:append() {
    export HYP_BUILD="${@bb.utils.contains('HYP_BUILD', '1', '1', '0', d)}"
    if [[ "${HYP_BUILD}" = "1" ]]; then
        bbdebug 1 "Building XEN boot script for ${MACHINE}"
        # Substitute UBOOT_DEVICE_TREE and MACHINE in files
        sed -i "s/@UBOOT_DEVICE_TREE@/${UBOOT_DEVICE_TREE}/g" "${UNPACKDIR}/uboot_xen_${MACHINE}.txt"
        sed -i "s/@MACHINE@/${MACHINE}/g" "${UNPACKDIR}/uboot_script_xen.its"
        mkimage -f "${UNPACKDIR}/uboot_script_xen.its" ${WORKDIR}/boot.scr.xen.uimg
    fi
}

# Override do_deploy to install XEN boot scripts when HYP_BUILD is enabled
do_deploy:append() {
    export HYP_BUILD="${@bb.utils.contains('HYP_BUILD', '1', '1', '0', d)}"
    if [[ "${HYP_BUILD}" = "1" ]]; then
        bbdebug 1 "Deploying XEN boot script for ${MACHINE}"
        install -m 0755 ${UNPACKDIR}/uboot_xen_${MACHINE}.txt ${DEPLOYDIR}/u-boot_xen_${MACHINE}.txt
        install -m 0644 ${WORKDIR}/boot.scr.xen.uimg ${DEPLOYDIR}/boot.scr.xen.uimg
    fi
}
