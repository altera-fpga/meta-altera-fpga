SUMMARY = "Altera SoCFPGA Bitstream"
DESCRIPTION = "Custom FPGA bitstream for SOC Development Kit"
SECTION = "bsp"

inherit deploy

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Proprietary;md5=0557f9d92cf58f2ccdd50f62f8ac0b28"

PROVIDES = "virtual/bitstream"

PACKAGES = "${PN}"

PACKAGE_ARCH = "${MACHINE_ARCH}"

FPGA_CORE_PGM_ENABLE ?= "0"

SRC_URI = "${@'file://${FPGA_RBF_FILE}' if d.getVar('FPGA_CORE_PGM_ENABLE', True) == '1' else ''}"

S = "${WORKDIR}/sources-unpack"

python () {
    if d.getVar('FPGA_CORE_PGM_ENABLE') != '1':
        d.setVarFlag('do_install', 'noexec', '1')
        d.setVarFlag('do_deploy', 'noexec', '1')
}

do_install () {
	install -D -m 0644 ${WORKDIR}/sources-unpack/${FPGA_RBF_FILE} ${D}/boot/top.core.rbf
}

do_deploy () {
	install -D -m 0644 ${WORKDIR}/sources-unpack/${FPGA_RBF_FILE} ${DEPLOYDIR}/top.core.rbf
}

FILES:${PN} = "\
    boot/* \
"

addtask install after do_configure before do_deploy
addtask deploy after do_install
