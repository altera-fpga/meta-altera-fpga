FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DEPENDS:append = " arm-trusted-firmware bash u-boot-socfpga-scr u-boot-tools-native"

inherit deploy

do_compile[deptask] = "do_deploy"

do_compile:prepend() {
	# Copy bl31.bin into source and build directories of u-boot for
	# creating u-boot.itb FIT image
	for file in ${COMPILE_PREPEND_FILES}; do
		if [ "${file}" = "bl31.bin" ]; then
			cp ${DEPLOY_DIR_IMAGE}/${file} ${B}/${config}/${file}
			cp ${DEPLOY_DIR_IMAGE}/${file} ${S}/${file}
		fi
	done
}

# Embed the FIT verification public key into U-Boot's control device tree so
# that U-Boot proper (CONFIG_FIT_SIGNATURE / CONFIG_BOOTSCR_FIT_SIGNATURE) has
# a 'required' trust anchor to verify the signed kernel FIT and boot.scr. The
# key defaults to the development key in meta-altera-bsp
# (UBOOT_SIGN_KEYDIR/UBOOT_SIGN_KEYNAME, see files/keys/README.md); override it
# with a private key for production.
#
# For SoC64 the runtime control FDT is the "fdt-0" image packaged *inside*
# u-boot.itb (SPL loads it via CONFIG_SPL_LOAD_FIT). binman builds that image
# from the board device tree named by CONFIG_DEFAULT_DEVICE_TREE
# - NOT from the standalone u-boot.dtb. The key must therefore be injected
# into that board dtb and u-boot.itb repackaged by re-running binman.
socfpga_warn_if_dev_fit_key() {
	if [ "${UBOOT_SIGN_KEYDIR%/}" = "${SOCFPGA_BSP_DEV_KEYDIR%/}" ]; then
		bbwarn "UBOOT_SIGN_KEYDIR is the committed GSRD development key (${UBOOT_SIGN_KEYDIR}/${UBOOT_SIGN_KEYNAME}). This is NOT a security boundary — override UBOOT_SIGN_KEYDIR/UBOOT_SIGN_KEYNAME for production (see files/keys/README.md)."
	fi
}

# Resolve the board dtb that becomes fdt-0. Prefer the classic out-of-tree
# path, then common OF_UPSTREAM / multi-dir layouts used by recent U-Boot.
#
# CONFIG_DEFAULT_DEVICE_TREE may be a bare name (socfpga_agilex5_socdk) or a
# vendor-qualified path (intel/socfpga_agilex_socdk). OF_UPSTREAM trees live at
# dts/upstream/src/arm64/<vendor>/<board>.dtb — do not prepend an extra
# "intel/" when ${dt} already includes the vendor segment (FM Agilex CI).
socfpga_find_board_dtb() {
	config_dir="$1"
	dt="$2"
	dt_base="${dt##*/}"
	for cand in \
		"${config_dir}/dts/upstream/src/arm64/${dt}.dtb" \
		"${config_dir}/dts/upstream/src/arm/${dt}.dtb" \
		"${config_dir}/arch/arm/dts/${dt_base}.dtb" \
		"${config_dir}/arch/arm/dts/${dt}.dtb" \
		"${config_dir}/dts/upstream/src/arm64/intel/${dt_base}.dtb" \
		"${config_dir}/dts/upstream/src/arm/intel/${dt_base}.dtb" \
		"${config_dir}/${dt}.dtb" \
		"${config_dir}/${dt_base}.dtb"
	do
		if [ -f "${cand}" ]; then
			printf '%s' "${cand}"
			return 0
		fi
	done
	# Last resort: unique basename match under the build dir.
	found=$(find "${config_dir}" -type f -name "${dt_base}.dtb" 2>/dev/null | head -1)
	if [ -n "${found}" ] && [ -f "${found}" ]; then
		printf '%s' "${found}"
		return 0
	fi
	return 1
}

socfpga_embed_fit_pubkey() {
	if [ ! -f "${UBOOT_SIGN_KEYDIR}/${UBOOT_SIGN_KEYNAME}.crt" ]; then
		bbwarn "FIT signing key ${UBOOT_SIGN_KEYNAME} not found in ${UBOOT_SIGN_KEYDIR}; control dtb left without a trust anchor"
		return
	fi

	socfpga_warn_if_dev_fit_key

	# Find the actual build config directory (includes machine name in Whinlatter)
	config_dir=$(ls -d ${B}/*${UBOOT_DEFCONFIG}* 2>/dev/null | head -1)
	if [ -z "$config_dir" ]; then
		config_dir="${B}/${UBOOT_DEFCONFIG}"
	fi

	embeds=0
	if [ ! -f "${config_dir}/u-boot.itb" ]; then
		bbwarn "socfpga_embed_fit_pubkey: skip: missing ${config_dir}/u-boot.itb"
	else
		dt=$(sed -n 's/^CONFIG_DEFAULT_DEVICE_TREE="\(.*\)"/\1/p' "${config_dir}/.config")
		if [ -z "${dt}" ]; then
			bbwarn "socfpga_embed_fit_pubkey: skip: CONFIG_DEFAULT_DEVICE_TREE empty in ${config_dir}/.config"
		else
			boarddtb=$(socfpga_find_board_dtb "${config_dir}" "${dt}") || boarddtb=""
			if [ -z "${boarddtb}" ]; then
				bbwarn "socfpga_embed_fit_pubkey: skip: missing board dtb for ${dt} under ${config_dir}"
			else
				# fdt_add_pubkey is a U-Boot host tool (not dtc). Stock
				# u-boot-tools-native often does not install it, so a bare
				# PATH lookup fails in BitBake ("command not found"). Prefer
				# the binary from this recipe's just-finished build.
				fdt_add_pubkey_bin=""
				for cand in \
					"${config_dir}/tools/fdt_add_pubkey" \
					"${B}/tools/fdt_add_pubkey" \
					"${STAGING_BINDIR_NATIVE}/fdt_add_pubkey"
				do
					if [ -x "${cand}" ]; then
						fdt_add_pubkey_bin="${cand}"
						break
					fi
				done
				if [ -z "${fdt_add_pubkey_bin}" ]; then
					bbfatal "socfpga_embed_fit_pubkey: fdt_add_pubkey not found under ${config_dir}/tools, ${B}/tools, or ${STAGING_BINDIR_NATIVE} (CONFIG_TOOLS_LIBCRYPTO host tool)"
				fi
				bbnote "socfpga_embed_fit_pubkey: embedding ${UBOOT_SIGN_KEYNAME} into ${boarddtb} via ${fdt_add_pubkey_bin}"
				"${fdt_add_pubkey_bin}" -a sha256,rsa2048 -k "${UBOOT_SIGN_KEYDIR}" \
					-n "${UBOOT_SIGN_KEYNAME}" -r conf "${boarddtb}"

				# Keep the keyed board dtb newer than its .dts source so the
				# rebuild below does not regenerate (and thus wipe) it, then
				# force binman to repackage u-boot.itb from the keyed board dtb.
				touch "${boarddtb}"
				rm -f "${config_dir}/u-boot.itb" "${config_dir}/.binman_stamp"
				oe_runmake -C "${S}" O="${config_dir}" .binman_stamp
				embeds=$(expr "${embeds}" + 1)
			fi
		fi
	fi

	if [ "${embeds}" -eq 0 ]; then
		bbfatal "socfpga_embed_fit_pubkey: embedded zero FIT pubkeys (key ${UBOOT_SIGN_KEYNAME} was present in ${UBOOT_SIGN_KEYDIR}). SoC64 machines that produce u-boot.itb must embed a trust anchor into fdt-0."
	fi
}

do_compile:append() {
	socfpga_embed_fit_pubkey
}

do_deploy:append() {
	# Find the actual build config directory (includes machine name in Whinlatter)
	config_dir=$(ls -d ${B}/*${UBOOT_DEFCONFIG}* 2>/dev/null | head -1)
	if [ -z "$config_dir" ]; then
		config_dir="${B}/${UBOOT_DEFCONFIG}"
	fi
	config_name=$(basename $config_dir)

	cp ${B}/${config_name}/spl/u-boot-spl-dtb.bin ${DEPLOYDIR}/u-boot-spl-dtb.bin
	cp ${B}/${config_name}/spl/u-boot-spl.dtb ${DEPLOYDIR}/u-boot-spl.dtb
	cp ${B}/${config_name}/spl/u-boot-spl.map ${DEPLOYDIR}/u-boot-spl.map
	cp ${B}/${config_name}/spl/u-boot-spl ${DEPLOYDIR}/u-boot-spl
	cp ${B}/${config_name}/u-boot ${DEPLOYDIR}/u-boot
	cp ${B}/${config_name}/u-boot.dtb ${DEPLOYDIR}/u-boot.dtb
}

require u-boot-socfpga-device-tree.inc
