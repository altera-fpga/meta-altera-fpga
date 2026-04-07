SUMMARY = "U-boot boot environment for Altera SoCFPGA devices"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/env:"

DEPENDS = "u-boot-mkenvimage-native"

inherit deploy nopackages
PACKAGE_ARCH = "${MACHINE_ARCH}"

SRC_URI = "file://u-boot-env.txt"

S = "${UNPACKDIR}"

do_install[noexec] = "1"

do_compile() {
	# Substitute MACHINE_STRIP placeholder in u-boot-env.txt
	sed -e "s/@@MACHINE_STRIP@@/${MACHINE_STRIP}/g" \
	    ${UNPACKDIR}/u-boot-env.txt > ${UNPACKDIR}/u-boot-env-subst.txt
	mkenvimage -s 0x2000 -o "${UNPACKDIR}/uboot.env" ${UNPACKDIR}/u-boot-env-subst.txt
}

do_deploy() {
	install -d ${DEPLOYDIR}
	install -m 0755 ${UNPACKDIR}/u-boot-env.txt ${DEPLOYDIR}/u-boot-env.txt
	install -m 0644 ${UNPACKDIR}/uboot.env ${DEPLOYDIR}/uboot.env
}

addtask do_deploy after do_compile before do_build
