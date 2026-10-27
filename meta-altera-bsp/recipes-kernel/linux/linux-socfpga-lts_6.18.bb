LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

LINUX_VERSION ?= "6.18.37"
LINUX_VERSION_SUFFIX = "-lts"
LINUX_SRCREV ?= "0c0e456cdde08783d0a56ef593af45899f5d11af"
SRCREV = "${LINUX_SRCREV}"

do_kernel_configcheck[noexec] = "1"

include linux-socfpga.inc
