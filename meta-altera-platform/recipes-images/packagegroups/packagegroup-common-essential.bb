DESCRIPTION = "List of packages that are commonly used in all image types"
LICENSE = "MIT"
PR = "r1"

PACKAGE_ARCH = "${TUNE_PKGARCH}"
inherit packagegroup

PACKAGES = "packagegroup-common-essential"

RDEPENDS:packagegroup-common-essential = "\
	i2c-tools \
	mtd-utils \
	mtd-utils-ubifs \
	libgpiod-tools \
	dosfstools \
	init-ifupdown \
	gsrd-initscripts \
	gsrd-intel-fcs-lib \
	gsrd-unilibrsu-lib \
	"

SYSCHK_APP ??= "false"
LED_CTRL_APP ??= "false"
RDEPENDS:packagegroup-common-essential:append = "${@' gsrd-apps gsrd-webcontent' if d.getVar('SYSCHK_APP') == 'true' or d.getVar('LED_CTRL_APP') == 'true' else ''}"

GPIO_INT_TEST ??= "false"
RDEPENDS:packagegroup-common-essential:append = "${@' gsrd-pio-interrupt' if d.getVar('GPIO_INT_TEST') == 'true' else ''}"

RDEPENDS:packagegroup-common-essential:append= "\
	gsrd-intel-fcs-client \
	gsrd-unilibrsu-client \
	"
