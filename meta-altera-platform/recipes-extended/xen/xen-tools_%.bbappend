# Prevent QEMU and libxenmanage from being pulled in by xen-tools
RDEPENDS:${PN}:remove = "qemu-system-i386 qemu ${PN}-libxenmanage"
