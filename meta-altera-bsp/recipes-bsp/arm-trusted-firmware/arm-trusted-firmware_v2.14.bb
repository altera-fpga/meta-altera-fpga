require arm-trusted-firmware.inc

LIC_FILES_CHKSUM = "file://docs/license.rst;md5=6ed7bace7b0bc63021c6eba7b524039e"

ATF_VERSION ?= "v2.14.1"
ATF_BRANCH ?= "socfpga_${ATF_VERSION}"
ATF_SRCREV ?= "2ea5afda7f34774ddcc677fb3a728fa57f780a1e"

SRCREV = "${ATF_SRCREV}"
