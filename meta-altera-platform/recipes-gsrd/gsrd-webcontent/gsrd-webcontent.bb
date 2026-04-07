DESCRIPTION = "Altera SoCFPGA GSRD web content"
AUTHOR = "Tien Hock Loh <tien.hock.loh@intel.com>"
SECTION = "gsrd"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

PR = "r0"

SRC_URI:append = " \
	    file://blinkled.gif \
	    file://favicon.ico \
	    file://helper_script.js \
	    file://index.sh \
	    file://intel-logo.jpg \
	    file://not_found.html \
	    file://offled.jpg \
	    file://onled.jpg \
	    file://progress.js \
	    file://runningled.gif \
	    file://style.css \
	    file://validation_script.js \
	    "

S = "${UNPACKDIR}"

do_install() {
	install -d ${D}/www/pages/cgi-bin
	install -d ${D}/home/root/alteraFPGA
	install -m 0755 ${UNPACKDIR}/intel-logo.jpg ${D}/www/pages/
	install -m 0755 ${UNPACKDIR}/blinkled.gif ${D}/www/pages/
	install -m 0755 ${UNPACKDIR}/favicon.ico ${D}/www/pages/
	install -m 0755 ${UNPACKDIR}/helper_script.js ${D}/www/pages/
	install -m 0755 ${UNPACKDIR}/not_found.html ${D}/www/pages/
	install -m 0755 ${UNPACKDIR}/offled.jpg ${D}/www/pages/
	install -m 0755 ${UNPACKDIR}/onled.jpg ${D}/www/pages/
	install -m 0755 ${UNPACKDIR}/progress.js ${D}/www/pages/
	install -m 0755 ${UNPACKDIR}/runningled.gif ${D}/www/pages/
	install -m 0755 ${UNPACKDIR}/style.css ${D}/www/pages/
	install -m 0755 ${UNPACKDIR}/validation_script.js ${D}/www/pages/
	install -m 0755 ${UNPACKDIR}/index.sh ${D}/www/pages/cgi-bin
}

FILES:${PN} = "/www/pages/* /home/*"
