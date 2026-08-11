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
	# Find the actual build config directory (includes machine name in Whinlatter)
	config_dir=$(ls -d ${B}/*${UBOOT_DEFCONFIG}* 2>/dev/null | head -1)
	if [ -z "$config_dir" ]; then
		config_dir="${B}/${UBOOT_DEFCONFIG}"
	fi
	config_name=$(basename $config_dir)
	
	cp ${B}/${config_name}/spl/u-boot-spl-dtb.bin ${DEPLOYDIR}/u-boot-spl-dtb.bin
	cp ${B}/${config_name}/spl/u-boot-spl.dtb ${DEPLOYDIR}/u-boot-spl.dtb
	cp ${B}/${config_name}/spl/u-boot-spl.map ${DEPLOYDIR}/u-boot-spl.map
	cp ${B}/${config_name}/spl/u-boot-spl ${DEPLOYDIR}/u-boot-spl
	cp ${B}/${config_name}/u-boot ${DEPLOYDIR}/u-boot
	cp ${B}/${config_name}/u-boot.dtb ${DEPLOYDIR}/u-boot.dtb
}

require u-boot-socfpga-device-tree.inc
