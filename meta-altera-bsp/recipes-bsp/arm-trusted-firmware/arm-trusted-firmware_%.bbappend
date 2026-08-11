# Machine-specific ATF override for agilex5e_de25_nano
# Append SOCFPGA_UART_CONFIG=1 to EXTRA_OEMAKE only for this board
EXTRA_OEMAKE:append:agilex5e_de25_nano = " SOCFPGA_UART_CONFIG=${SOCFPGA_UART_CONFIG}"
