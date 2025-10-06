SUMMARY = "U-boot boot environment for Altera SoCFPGA devices"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/env:"

DEPENDS = "u-boot-mkenvimage-native"

inherit deploy nopackages
PACKAGE_ARCH = "${MACHINE_ARCH}"

SRC_URI = "file://u-boot-env.txt"

S = "${WORKDIR}/sources-unpack"

do_install[noexec] = "1"

do_compile() {
	mkenvimage -s 0x2000 -o "${WORKDIR}/sources-unpack/uboot.env" ${WORKDIR}/sources-unpack/u-boot-env.txt
}

do_deploy() {
	install -d ${DEPLOYDIR}
	install -m 0755 ${WORKDIR}/sources-unpack/u-boot-env.txt ${DEPLOYDIR}/u-boot-env.txt
	install -m 0644 ${WORKDIR}/sources-unpack/uboot.env ${DEPLOYDIR}/uboot.env
}

addtask do_deploy after do_compile before do_build
