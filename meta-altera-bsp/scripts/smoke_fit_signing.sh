#!/usr/bin/env bash
# Standalone ES-14537 FIT signing smoke — no full Yocto build required.
#
# Proves against a local u-boot-socfpga tools tree + board dtb:
#   1) boot.scr ITS signs with mkimage -k -r
#   2) kernel no-rbf ITS signs; rbf ITS hashes fpga via sign-images
#   3) fdt_add_pubkey embeds required trust anchor into board dtb
#   4) fit_check_sign accepts good images and rejects a tampered payload
#
# Usage:
#   UBOOT_TOOLS_DIR=/path/to/u-boot-socfpga bash meta-altera-bsp/scripts/smoke_fit_signing.sh
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
BSP_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
KEYDIR="${BSP_DIR}/files/keys"
BOOTSCR_ITS="${BSP_DIR}/recipes-bsp/u-boot/bootscr/uboot_script.its"
KERNEL_ITS="${BSP_DIR}/recipes-kernel/linux/linux-socfpga-lts/fit_agilex5_kernel_no_rbf.its"
KERNEL_RBF_ITS="${BSP_DIR}/recipes-kernel/linux/linux-socfpga-lts/fit_agilex5_kernel.its"

UBOOT_TOOLS_DIR=${UBOOT_TOOLS_DIR:-/nfs/site/disks/swuser_work_dmaniyam/altera/applications.fpga.soc.uboot-socfpga-dev}
MKIMAGE=${MKIMAGE:-${UBOOT_TOOLS_DIR}/tools/mkimage}
FDT_ADD_PUBKEY=${FDT_ADD_PUBKEY:-${UBOOT_TOOLS_DIR}/tools/fdt_add_pubkey}
FIT_CHECK_SIGN=${FIT_CHECK_SIGN:-${UBOOT_TOOLS_DIR}/tools/fit_check_sign}
BOARD_DTB=${BOARD_DTB:-${UBOOT_TOOLS_DIR}/arch/arm/dts/socfpga_agilex5_socdk.dtb}
# mkimage shells out to dtc; prefer the in-tree build if host dtc is absent.
if [ -x "${UBOOT_TOOLS_DIR}/scripts/dtc/dtc" ]; then
	PATH="${UBOOT_TOOLS_DIR}/scripts/dtc:${PATH}"
	export PATH
fi

for t in "$MKIMAGE" "$FDT_ADD_PUBKEY" "$FIT_CHECK_SIGN"; do
	if [ ! -x "$t" ]; then
		echo "FAIL: missing executable $t (set UBOOT_TOOLS_DIR)" >&2
		exit 1
	fi
done
if ! command -v dtc >/dev/null 2>&1; then
	echo "FAIL: dtc not on PATH (needed by mkimage -f)" >&2
	exit 1
fi
if [ ! -f "$BOARD_DTB" ]; then
	echo "FAIL: missing board dtb $BOARD_DTB (set BOARD_DTB)" >&2
	exit 1
fi
if [ ! -f "${KEYDIR}/dev.key" ] || [ ! -f "${KEYDIR}/dev.crt" ]; then
	echo "FAIL: missing ${KEYDIR}/dev.{key,crt}" >&2
	exit 1
fi

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
cd "$WORK"

echo "==> workdir $WORK"
echo "==> tools from $UBOOT_TOOLS_DIR"
echo "==> board dtb $BOARD_DTB"

# --- 1) Sign boot.scr FIT ---
printf 'echo smoke-bootscr\n' > uboot.txt
cp "$BOOTSCR_ITS" .
"$MKIMAGE" -f uboot_script.its -k "$KEYDIR" -r boot.scr.uimg
echo "OK: signed boot.scr.uimg ($(wc -c < boot.scr.uimg) bytes)"

# --- 2) Embed pubkey into a copy of the board dtb (fdt-0 source) ---
# Start from a DTS without a top-level /signature so we prove the inject path
# (the in-tree .dtb may already carry a prior smoke key; size can stay flat
# due to FDT padding).
DTC=$(command -v dtc)
"$DTC" -I dtb -O dts -o board-plain.dts "$BOARD_DTB" 2>/dev/null
# Drop any existing top-level signature { ... }; block (brace-balanced).
python3 - <<'PY'
import re
text = open('board-plain.dts').read()
# Remove top-level signature node(s) only (indent starts at one tab or spaces).
text2 = re.sub(
    r'\n\tsignature \{.*?\n\t\};',
    '',
    text,
    flags=re.S,
)
open('board-plain.dts', 'w').write(text2)
PY
"$DTC" -I dts -O dtb -o board-plain.dtb board-plain.dts 2>/dev/null
cp board-plain.dtb board-keyed.dtb
before=$("$DTC" -I dtb -O dts board-keyed.dtb 2>/dev/null)
if echo "$before" | grep -qE '^\tsignature \{'; then
	echo "FAIL: could not strip existing /signature from board dtb" >&2
	exit 1
fi
"$FDT_ADD_PUBKEY" -a sha256,rsa2048 -k "$KEYDIR" -n dev -r conf board-keyed.dtb
after=$("$DTC" -I dtb -O dts board-keyed.dtb 2>/dev/null)
if ! echo "$after" | grep -q 'required = "conf"'; then
	echo "FAIL: fdt_add_pubkey did not add required=conf trust anchor" >&2
	echo "$after" | head -40 >&2
	exit 1
fi
if ! echo "$after" | grep -q 'key-name-hint = "dev"'; then
	echo "FAIL: fdt_add_pubkey missing key-name-hint=dev" >&2
	exit 1
fi
echo "OK: fdt_add_pubkey embedded required conf trust anchor (dev) into board dtb"

# --- 3) Sign kernel FIT (no-rbf) with placeholders filled ---
# Minimal lzma Image + DTB payload
dd if=/dev/zero of=Image bs=1024 count=64 status=none
if command -v xz >/dev/null 2>&1; then
	xz -f --format=lzma Image
else
	echo "FAIL: xz required to build Image.lzma" >&2
	exit 1
fi
cp board-keyed.dtb SOCFPGA_SOCDK_DTB_FILE
sed -e 's#SOCFPGA_SOCDK_DTB_FILE#SOCFPGA_SOCDK_DTB_FILE#g' \
	"$KERNEL_ITS" > fit_kernel.its
# ITS uses /incbin/("./SOCFPGA_SOCDK_DTB_FILE") literally — file name is the placeholder
"$MKIMAGE" -f fit_kernel.its -k "$KEYDIR" -r kernel.itb
echo "OK: signed kernel.itb ($(wc -c < kernel.itb) bytes)"

# mkimage 2026.04 does not hash type=fpga unless sign-images lists it.
# Require explicit sign-images on both ITS families (caught GSRD default rbf).
if ! grep -q 'sign-images = "kernel", "fdt"' "$KERNEL_ITS"; then
	echo "FAIL: no-rbf kernel ITS missing sign-images kernel,fdt" >&2
	exit 1
fi
echo "OK: no-rbf kernel ITS lists sign-images kernel,fdt"
if ! grep -q 'sign-images = "kernel", "fdt", "fpga"' "$KERNEL_RBF_ITS"; then
	echo "FAIL: rbf kernel ITS missing sign-images kernel,fdt,fpga" >&2
	exit 1
fi
echo "OK: rbf kernel ITS lists sign-images kernel,fdt,fpga"

# Sign the rbf ITS too (dummy bitstream) — this is the default GSRD path.
dd if=/dev/zero of=top.core.rbf bs=1024 count=4 status=none
cp board-keyed.dtb SOCFPGA_VANILLA_DTB_FILE
sed -e 's#SOCFPGA_SOCDK_DTB_FILE#SOCFPGA_SOCDK_DTB_FILE#g' \
    -e 's#SOCFPGA_VANILLA_DTB_FILE#SOCFPGA_VANILLA_DTB_FILE#g' \
	"$KERNEL_RBF_ITS" > fit_kernel_rbf.its
"$MKIMAGE" -f fit_kernel_rbf.its -k "$KEYDIR" -r kernel-rbf.itb
echo "OK: signed kernel-rbf.itb ($(wc -c < kernel-rbf.itb) bytes)"

# --- 4) fit_check_sign: good image passes, tamper fails ---
if "$FIT_CHECK_SIGN" -f kernel.itb -k board-keyed.dtb >/tmp/fit_check_ok.log 2>&1; then
	echo "OK: fit_check_sign accepts signed kernel.itb against keyed board dtb"
else
	echo "FAIL: fit_check_sign rejected good kernel.itb" >&2
	cat /tmp/fit_check_ok.log >&2 || true
	exit 1
fi
if "$FIT_CHECK_SIGN" -f kernel-rbf.itb -k board-keyed.dtb >/tmp/fit_check_rbf_ok.log 2>&1; then
	echo "OK: fit_check_sign accepts signed kernel-rbf.itb against keyed board dtb"
else
	echo "FAIL: fit_check_sign rejected good kernel-rbf.itb" >&2
	cat /tmp/fit_check_rbf_ok.log >&2 || true
	exit 1
fi

cp kernel.itb kernel-tampered.itb
# Flip one byte in the middle of the FIT (past header)
python3 - <<'PY'
p = 'kernel-tampered.itb'
with open(p, 'rb') as f:
    data = bytearray(f.read())
idx = max(256, len(data) // 2)
data[idx] ^= 0x5A
with open(p, 'wb') as f:
    f.write(data)
print(f'tampered byte at offset {idx}')
PY
if "$FIT_CHECK_SIGN" -f kernel-tampered.itb -k board-keyed.dtb >/tmp/fit_check_bad.log 2>&1; then
	echo "FAIL: fit_check_sign accepted tampered kernel.itb" >&2
	cat /tmp/fit_check_bad.log >&2 || true
	exit 1
fi
echo "OK: fit_check_sign rejects tampered kernel.itb"

# --- 5) board dtb path discovery used by the recipe ---
dt=socfpga_agilex5_socdk
config_dir=$UBOOT_TOOLS_DIR
found=""
for cand in \
	"${config_dir}/arch/arm/dts/${dt}.dtb" \
	"${config_dir}/dts/upstream/src/arm64/intel/${dt}.dtb" \
	"${config_dir}/dts/upstream/src/arm/intel/${dt}.dtb" \
	"${config_dir}/${dt}.dtb"
do
	if [ -f "$cand" ]; then
		found=$cand
		break
	fi
done
if [ -z "$found" ]; then
	echo "FAIL: socfpga_find_board_dtb candidates miss ${dt}.dtb under $config_dir" >&2
	exit 1
fi
echo "OK: board dtb discovery finds $found"

echo
echo "PASS: ES-14537 FIT signing smoke"
