# False - Default device tree
# True - Custom device tree
CUSTOM_UBOOT_DT ?= "0"

DEPENDS += "dtc-native"

python __anonymous() {
    import os

    custom_dt = d.getVar("CUSTOM_UBOOT_DT")
    if custom_dt != "1":
        return

    dts_path = d.getVar("UBOOT_DEVICE_TREE_SRC_PATH")
    if not os.path.isdir(dts_path):
        bb.fatal("UBOOT_DEVICE_TREE_SRC_PATH does not exist: " + dts_path)
    d.setVar("DEVICE_TREE_PATH", dts_path)

    dts_file = None

    # Find .dts file (excluding .dtsi)
    for fname in os.listdir(dts_path):
        if fname.lower().endswith(".dts") and not fname.lower().endswith(".dtsi"):
            dts_file = fname
            break

    if not dts_file:
        bb.fatal("No .dts file found in " + dts_path)

    d.setVar("CUSTOM_DTS_FILE", dts_file)
}

# Custom device tree - overwite default tree source in u-boot source
do_configure:append () {
    if [ "${CUSTOM_UBOOT_DT}" = "1" ]; then
        # Overwite default device tree with custom device tree
        if [ -f "${DEVICE_TREE_PATH}/${CUSTOM_DTS_FILE}" ]; then
            cp ${DEVICE_TREE_PATH}/${CUSTOM_DTS_FILE} ${S}/arch/arm/dts/"${@d.getVar('UBOOT_DEVICE_TREE', True).replace('.dtb', '.dts')}"
        fi
    fi
}
