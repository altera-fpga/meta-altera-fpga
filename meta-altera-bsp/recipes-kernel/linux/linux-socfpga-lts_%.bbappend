# Append GSRD SoCFPGA device tree source include files
# As this is custom to Altera SoCFPGA GSRD, hence it is not suitable to be upstreamed to meta-intel-fpga

FILESEXTRAPATHS:prepend := "${THISDIR}/linux-socfpga-lts:"

DEPENDS = "u-boot-mkimage-native dtc-native"

FPGA_CORE_PGM_ENABLE ?= "1"

SRC_URI += "${@'file://fit_' + d.getVar('MACHINE_STRIP') + '_kernel.its' if d.getVar('FPGA_CORE_PGM_ENABLE') == '1' else 'file://fit_' + d.getVar('MACHINE_STRIP') + '_kernel_no_rbf.its'}"

inherit deploy

LINUXDEPLOYDIR = "${WORKDIR}/deploy-${PN}"
DTBDEPLOYDIR = "${DEPLOY_DIR_IMAGE}"

INSANE_SKIP:${PN}-src = "buildpaths"


do_deploy[depends] += "fpga-bitstream:do_deploy"

do_deploy:append() {
	# linux.dtb
	cp ${LINUXDEPLOYDIR}/${LINUX_DTB_FILE} ${B}

	# Copy FPGA_LINUX_DTB_FILE only if it is NOT empty
	if [[ -n "${FPGA_LINUX_DTB_FILE}" ]]; then
		cp ${LINUXDEPLOYDIR}/${FPGA_LINUX_DTB_FILE} ${B}
	fi

	# core.rbf
	if [[ "${FPGA_CORE_PGM_ENABLE}" == "1" ]]; then
		cp ${DEPLOY_DIR_IMAGE}/top.core.rbf ${B}
	fi

	if [[ "${FPGA_CORE_PGM_ENABLE}" == "1" ]]; then
	    sed -e "s#SOCFPGA_SOCDK_DTB_FILE#${FPGA_LINUX_DTB_FILE}#g" \
            -e "s#SOCFPGA_VANILLA_DTB_FILE#${LINUX_DTB_FILE}#g" \
		    ${UNPACKDIR}/fit_${MACHINE_STRIP}_kernel.its > ${B}/fit_${MACHINE_STRIP}_kernel.its
	else
		# Decide which DTB to use in the else section
		if [[ -n "${FPGA_LINUX_DTB_FILE}" ]]; then
			DTB_TO_USE="${FPGA_LINUX_DTB_FILE}"
		else
			DTB_TO_USE="${LINUX_DTB_FILE}"
		fi

		sed -e "s#SOCFPGA_SOCDK_DTB_FILE#${DTB_TO_USE}#g" \
			${UNPACKDIR}/fit_${MACHINE_STRIP}_kernel_no_rbf.its \
			> ${B}/fit_${MACHINE_STRIP}_kernel_no_rbf.its

	fi

	# Image
	cp ${LINUXDEPLOYDIR}/Image ${B}
	# Compress Image to lzma format
	xz -f --format=lzma ${B}/Image

	# Generate kernel.itb
	if [[ "${FPGA_CORE_PGM_ENABLE}" == "1" ]]; then
		mkimage -f ${B}/fit_${MACHINE_STRIP}_kernel.its ${B}/kernel.itb
	else
		mkimage -f ${B}/fit_${MACHINE_STRIP}_kernel_no_rbf.its ${B}/kernel.itb
	fi

	# Deploy kernel.its, kernel.itb and Image.lzma
	if [[ "${FPGA_CORE_PGM_ENABLE}" == "1" ]]; then
		install -m 744 ${B}/fit_${MACHINE_STRIP}_kernel.its ${DEPLOYDIR}
	else
		install -m 744 ${B}/fit_${MACHINE_STRIP}_kernel_no_rbf.its ${DEPLOYDIR}
	fi
	install -m 744 ${B}/kernel.itb ${DEPLOYDIR}
	install -m 744 ${B}/Image.lzma ${DEPLOYDIR}
}




