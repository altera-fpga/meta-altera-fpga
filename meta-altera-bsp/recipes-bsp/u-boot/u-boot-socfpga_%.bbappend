FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DEPENDS:append = " arm-trusted-firmware bash u-boot-socfpga-scr"

inherit deploy

do_compile[deptask] = "do_deploy"

do_compile:prepend() {
	# Copy bl31.bin into source and build directories of u-boot for
	# creating u-boot.itb FIT image
	for file in ${COMPILE_PREPEND_FILES}; do
		if [ "${file}" = "bl31.bin" ]; then
			cp ${DEPLOY_DIR_IMAGE}/${file} ${B}/${config}/${file}
			cp ${DEPLOY_DIR_IMAGE}/${file} ${S}/${file}
		fi
	done
}

do_deploy:append() {
	cp ${B}/${UBOOT_DEFCONFIG}/spl/u-boot-spl-dtb.bin ${DEPLOYDIR}/u-boot-spl-dtb.bin
	cp ${B}/${UBOOT_DEFCONFIG}/spl/u-boot-spl.dtb ${DEPLOYDIR}/u-boot-spl.dtb
	cp ${B}/${UBOOT_DEFCONFIG}/spl/u-boot-spl.map ${DEPLOYDIR}/u-boot-spl.map
	cp ${B}/${UBOOT_DEFCONFIG}/spl/u-boot-spl ${DEPLOYDIR}/u-boot-spl
	cp ${B}/${UBOOT_DEFCONFIG}/u-boot ${DEPLOYDIR}/u-boot
}

require u-boot-socfpga-device-tree.inc
