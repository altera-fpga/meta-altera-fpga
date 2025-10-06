DESCRIPTION = "Altera SoCFPGA GSRD web content"
AUTHOR = "Tien Hock Loh <tien.hock.loh@intel.com>"
SECTION = "gsrd"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM="file://${COMMON_LICENSE_DIR}/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

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

S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

do_install() {
	install -d ${D}/www/pages/cgi-bin
	install -d ${D}/home/root/intelFPGA
	install -m 0755 intel-logo.jpg ${D}/www/pages/
	install -m 0755 blinkled.gif ${D}/www/pages/
	install -m 0755 favicon.ico ${D}/www/pages/
	install -m 0755 helper_script.js ${D}/www/pages/
	install -m 0755 not_found.html ${D}/www/pages/
	install -m 0755 offled.jpg ${D}/www/pages/
	install -m 0755 onled.jpg ${D}/www/pages/
	install -m 0755 progress.js ${D}/www/pages/
	install -m 0755 runningled.gif ${D}/www/pages/
	install -m 0755 style.css ${D}/www/pages/
	install -m 0755 validation_script.js ${D}/www/pages/
	install -m 0755 index.sh ${D}/www/pages/cgi-bin
}

FILES:${PN} = "/www/pages/* /home/*"
