DESCRIPTION = "Coremark: CPU performance benchmarking tool"
HOMEPAGE = "https://www.eembc.org/coremark/"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"
AUTHOR = "Michael Mo <michael.mo@altera.com>"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
 
SRC_URI = "git://github.com/eembc/coremark.git;protocol=https;branch=main \
	   file://0001-compile-coremark-for-linux-with-gnu-hash-style.patch \
	  "

PV = "1.0+git"
SRCREV = "1f483d5b8316753a742cbf5590caf5bd0a4e4777"

do_compile () {
	export CC="${CC}"
	oe_runmake compile link XCFLAGS="-O3" EXE=""
}

do_install () {
	install -d ${D}${bindir}
	install -m 0755 coremark ${D}${bindir}/coremark
}

