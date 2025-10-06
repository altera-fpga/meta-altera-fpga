DESCRIPTION = "Intel SoCFPGA GSRD custom applications"
AUTHOR = "Tien Hock Loh <tien.hock.loh@intel.com>"
SECTION = "gsrd"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM="file://${COMMON_LICENSE_DIR}/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

S = "${WORKDIR}/git"

DEPENDS = "ncurses"

REFDES_REPO ?= "git://github.com/altera-fpga/linux-refdesigns.git"
REFDES_PROT ?= "http"
REFDES_BRANCH ?= "master"

INSANE_SKIP:${PN} = "ldflags"
INSANE_SKIP:${PN}-dev = "ldflags"

SRC_URI = " \
		${REFDES_REPO};protocol=${REFDES_PROT};branch=${REFDES_BRANCH} \
		file://README \
		"

SRCREV = "57b44fdf88bb344491118db066142938344ee3c3"

FILES:${PN} = "/www/pages/* \
	       /home/root/intelFPGA/* \
	       /home/root/README \
	      "

FILES:${PN}-dbg = "/www/pages/cgi-bin/.debug/ /usr /home/root/intelFPGA/.debug"
INSANE_SKIP:${PN}-dbg = "buildpaths"

SYSCHK_APP ??= "false"
LED_CTRL_APP ??= "false"

do_compile() {

    apps=""
    if [ "${SYSCHK_APP}" = "true" ]; then
        apps="${apps} syschk"
    fi
    if [ "${LED_CTRL_APP}" = "true" ]; then
        apps="$apps blink toggle scroll_server scroll_client"
    fi
    if [ -n "$apps" ]; then
        apps="led_control $apps"
    fi

    cd ${S}
    for app in $apps; do
        oe_runmake -C $app
    done
}

do_install() {
    cd ${S}
    if [ "${SYSCHK_APP}" = "true" ] || [ "${LED_CTRL_APP}" = "true" ]; then
        install -d ${D}/www/pages/cgi-bin
        install -d ${D}/home/root/intelFPGA
        install -m 0755 ${WORKDIR}/sources-unpack/README ${D}/home/root/README
    fi
    if [ "${SYSCHK_APP}" = "true" ]; then
        install -m 0755 syschk/syschk ${D}/home/root/intelFPGA/syschk
    fi

    if [ "${LED_CTRL_APP}" = "true" ]; then
        install -m 0755 blink/blink ${D}/www/pages/cgi-bin/blink
        install -m 0755 blink/blink ${D}/home/root/intelFPGA/blink
        install -m 0755 toggle/toggle ${D}/www/pages/cgi-bin/toggle
        install -m 0755 toggle/toggle ${D}/home/root/intelFPGA/toggle
        install -m 0755 scroll_server/scroll_server ${D}/www/pages/cgi-bin/scroll_server
        install -m 0755 scroll_client/scroll_client ${D}/www/pages/cgi-bin/scroll_client
        install -m 0755 scroll_client/scroll_client ${D}/home/root/intelFPGA/scroll_client
    fi
}
