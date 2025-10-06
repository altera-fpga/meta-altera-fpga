DESCRIPTION = "List of packages that are commonly needed for development purposes"
LICENSE = "MIT"
PR = "r1"

PACKAGE_ARCH = "${TUNE_PKGARCH}"
inherit packagegroup

PACKAGES = "packagegroup-dev-tools-essential"

RDEPENDS:packagegroup-dev-tools-essential = "\
	bash \
	devmem2 \
	e2fsprogs \
	ethtool \
	gcc \
	gcc-symlinks \
	gdb \
	gdbserver \
	git \
	iperf3 \
	iproute2-tc \
	iproute2-ip \
	netcat-openbsd \
	openssh-sftp-server \
	pciutils \
	tcpdump \
	perf \
	wireshark \
	python3-scapy \
	bc \
	tcpreplay \
	spidev-test \
	"
LINUXPTP_APP ??= "false"
RDEPENDS:packagegroup-dev-tools-essential:append = "${@' linuxptp' if d.getVar('LINUXPTP_APP') == 'true' else ''}"

OPEN62541_LIB ??= "false"
RDEPENDS:packagegroup-dev-tools-essential:append = "${@' open62541' if d.getVar('OPEN62541_LIB') == 'true' else ''}"
