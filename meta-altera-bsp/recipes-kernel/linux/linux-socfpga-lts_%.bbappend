# Append GSRD SoCFPGA device tree source include files
# As this is custom to Altera SoCFPGA GSRD, hence it is not suitable to be upstreamed to meta-intel-fpga

FILESEXTRAPATHS:prepend := "${THISDIR}/linux-socfpga-lts:"

DEPENDS = "u-boot-mkimage-native dtc-native"

FPGA_CORE_PGM_ENABLE ?= "1"

SRC_URI += "${@'file://fit_agilex5_kernel.its' if d.getVar('FPGA_CORE_PGM_ENABLE') == '1' else 'file://fit_agilex5_kernel_no_rbf.its'}"

inherit deploy

LINUXDEPLOYDIR = "${WORKDIR}/deploy-${PN}"
DTBDEPLOYDIR = "${DEPLOY_DIR_IMAGE}/devicetree"

INSANE_SKIP:${PN}-src = "buildpaths"

do_deploy[depends] += "fpga-bitstream:do_deploy device-tree:do_deploy"

do_deploy:append() {
	if [[ "${MACHINE}" == *"agilex5"* ]]; then
		# linux.dtb
		cp ${DTBDEPLOYDIR}/socfpga_agilex5_socdk.dtb ${B}

		# core.rbf
		if [[ "${FPGA_CORE_PGM_ENABLE}" == "1" ]]; then
			cp ${DTBDEPLOYDIR}/socfpga_agilex5_vanilla.dtb ${B}
			cp ${DEPLOY_DIR_IMAGE}/top.core.rbf ${B}
		fi

		#
		# Generate and deploy kernel.itb
		#
		# kernel.its
		if [[ "${FPGA_CORE_PGM_ENABLE}" == "1" ]]; then
			cp ${WORKDIR}/sources-unpack/fit_agilex5_kernel.its ${B}
		else
			cp ${WORKDIR}/sources-unpack/fit_agilex5_kernel_no_rbf.its ${B}
		fi

		# Image
		cp ${LINUXDEPLOYDIR}/Image ${B}
		# Compress Image to lzma format
		xz -f --format=lzma ${B}/Image

		# Generate kernel.itb
		if [[ "${FPGA_CORE_PGM_ENABLE}" == "1" ]]; then
			mkimage -f ${B}/fit_agilex5_kernel.its ${B}/kernel.itb
		else
			mkimage -f ${B}/fit_agilex5_kernel_no_rbf.its ${B}/kernel.itb
		fi

		# Deploy kernel.its, kernel.itb and Image.lzma
		if [[ "${FPGA_CORE_PGM_ENABLE}" == "1" ]]; then
			install -m 744 ${B}/fit_agilex5_kernel.its ${DEPLOYDIR}
		else
			install -m 744 ${B}/fit_agilex5_kernel_no_rbf.its ${DEPLOYDIR}
		fi
		install -m 744 ${B}/kernel.itb ${DEPLOYDIR}
		install -m 744 ${B}/Image.lzma ${DEPLOYDIR}
	fi
}
