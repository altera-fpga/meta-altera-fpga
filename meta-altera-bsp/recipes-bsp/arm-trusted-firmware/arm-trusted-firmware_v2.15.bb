require arm-trusted-firmware.inc

LIC_FILES_CHKSUM = "file://docs/license.rst;md5=6ed7bace7b0bc63021c6eba7b524039e"

ATF_VERSION ?= "v2.15.0"
ATF_BRANCH ?= "socfpga_${ATF_VERSION}"
ATF_SRCREV ?= "09c4dc6628810d8570af69db43918d344f9e80e9"

SRCREV = "${ATF_SRCREV}"
