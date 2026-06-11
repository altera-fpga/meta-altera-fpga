SUMMARY = "Synthetic benchmark to measure sustainable memory bandwidth"
DESCRIPTION = "\
The STREAM benchmark is a simple synthetic benchmark program that measures \
sustainable memory bandwidth (in MB/s) and the corresponding computation rate \
for simple vector kernels. STREAM measures performance using a sequential \
data stream of memory writes and reads. \
\
N.B. This is the standalone version by John McCalpin; another version is \
included in LMBench."
SECTION = "console/utils"

LICENSE = "STREAM"
NO_GENERIC_LICENSE[STREAM] = "LICENSE.txt"

LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=bca8cbe07976fe64c8946378d08314b0"

SRC_URI = "git://github.com/jeffhammond/STREAM.git;protocol=https;branch=master"

SRCREV = "6703f7504a38a8da96b353cadafa64d3c2d7a2d3"
PV = "1.0+git${SRCPV}"
S = "${WORKDIR}/git"

do_compile () {
    ${CC} ${CFLAGS} ${LDFLAGS} -O3 -fopenmp -static -o stream ${S}/stream.c
}

do_install () {
    install -Dm 0755 stream ${D}${bindir}/stream.mccalpin
}
