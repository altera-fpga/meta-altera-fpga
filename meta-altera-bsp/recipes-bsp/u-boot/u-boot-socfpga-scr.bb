SUMMARY = "U-boot boot scripts for Altera SoCFPGA devices"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/bootscr:"

DEPENDS = "u-boot-mkimage-native dtc-native"

# The SoC64 boot script (boot.scr) is packaged as a signed FIT: the .its files
# carry a 'configurations' node with an RSA signature, and mkimage -k <keydir>
# -r signs it and marks the key required. U-Boot proper (built with
# CONFIG_BOOTSCR_FIT_SIGNATURE) then refuses to 'source' an unsigned or
# tampered boot.scr. UBOOT_SIGN_KEYDIR/UBOOT_SIGN_KEYNAME default to the
# development key in this layer (see files/keys/README.md) and must be
# overridden with a private key for production.

inherit deploy nopackages
PACKAGE_ARCH = "${MACHINE_ARCH}"

SRC_URI = "file://uboot.txt file://uboot_script.its"

S = "${UNPACKDIR}"

do_configure[noexec] = "1"
do_install[noexec] = "1"

# Warn when the committed GSRD development key is used. Shared with the
# Xen bbappend (do_compile:append) so every mkimage -k path is covered once.
socfpga_warn_if_dev_fit_key() {
	if [ "${UBOOT_SIGN_KEYDIR%/}" = "${SOCFPGA_BSP_DEV_KEYDIR%/}" ]; then
		bbwarn "UBOOT_SIGN_KEYDIR is the committed GSRD development key (${UBOOT_SIGN_KEYDIR}/${UBOOT_SIGN_KEYNAME}). This is NOT a security boundary — override UBOOT_SIGN_KEYDIR/UBOOT_SIGN_KEYNAME for production (see files/keys/README.md)."
	fi
}

do_compile() {
	socfpga_warn_if_dev_fit_key
	mkimage -f "${UNPACKDIR}/uboot_script.its" -k "${UBOOT_SIGN_KEYDIR}" -r ${UNPACKDIR}/boot.scr.uimg
}

do_deploy() {
	install -d ${DEPLOYDIR}
	install -m 0755 ${UNPACKDIR}/uboot.txt ${DEPLOYDIR}/u-boot.txt
	install -m 0644 ${UNPACKDIR}/boot.scr.uimg ${DEPLOYDIR}/boot.scr.uimg
}

addtask do_deploy after do_compile before do_build
