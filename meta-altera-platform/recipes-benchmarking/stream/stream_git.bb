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
NO_GENERIC_LICENSE[STREAM] = "stream_license.txt"

LIC_FILES_CHKSUM = "file://stream_license.txt;md5=9c9fd8c5e9b6e9f7516783072fa35261"

SRC_URI = "https://www.cs.virginia.edu/stream/FTP/Code/stream.c;name=stream \
           file://stream_license.txt"

SRC_URI[stream.md5sum] = "dd2941e3a28ff90a79b571273c10aacf"
SRC_URI[stream.sha256sum] = "a52bae5e175bea3f7832112af9c085adab47117f7d2ce219165379849231692b"

S = "${WORKDIR}"

do_compile () {
    ${CC} ${CFLAGS} ${LDFLAGS} -O3 -fopenmp -static -o stream stream.c
}

do_install () {
    install -Dm 0755 stream ${D}${bindir}/stream.mccalpin
}
