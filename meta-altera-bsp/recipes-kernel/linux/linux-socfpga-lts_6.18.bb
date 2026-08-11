LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

LINUX_VERSION ?= "6.18.20"
LINUX_VERSION_SUFFIX = "-lts"
LINUX_SRCREV ?= "d8e46bd82a1e1dbbc641db7f0f57d7ddeb2621b1"
SRCREV = "${LINUX_SRCREV}"

do_kernel_configcheck[noexec] = "1"

include linux-socfpga.inc
