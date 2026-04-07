DESCRIPTION = "Example script to run all hps-benchmarks"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
AUTHOR = "Michael Mo <michael.mo@altera.com>"

SRC_URI = "file://run-hps-benchmarks.sh"

S = "${UNPACKDIR}"

do_compile() {
    :
}

do_install() {
    install -Dm 0755 ${UNPACKDIR}/run-hps-benchmarks.sh ${D}${bindir}/run-hps-benchmarks
}

RDEPENDS:${PN} = "bash util-linux"