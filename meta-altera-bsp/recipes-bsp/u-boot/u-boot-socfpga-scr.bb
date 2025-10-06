SUMMARY = "U-boot boot scripts for Altera SoCFPGA devices"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/bootscr:"

DEPENDS = "u-boot-mkimage-native dtc-native"

inherit deploy nopackages
PACKAGE_ARCH = "${MACHINE_ARCH}"

SRC_URI = "file://uboot.txt file://uboot_script.its"

S = "${WORKDIR}/sources-unpack"

do_configure[noexec] = "1"
do_install[noexec] = "1"

do_compile() {
	mkimage -f "${WORKDIR}/sources-unpack/uboot_script.its" ${WORKDIR}/sources-unpack/boot.scr.uimg
}

do_deploy() {
	install -d ${DEPLOYDIR}
	install -m 0755 ${WORKDIR}/sources-unpack/uboot.txt ${DEPLOYDIR}/u-boot.txt
	install -m 0644 ${WORKDIR}/sources-unpack/boot.scr.uimg ${DEPLOYDIR}/boot.scr.uimg
}

addtask do_deploy after do_compile before do_build
