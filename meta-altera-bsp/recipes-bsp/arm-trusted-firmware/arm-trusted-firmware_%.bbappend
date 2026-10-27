# Machine-specific ATF override for agilex5e_de25
# Append SOCFPGA_UART_CONFIG=1 to EXTRA_OEMAKE only for this board
EXTRA_OEMAKE:append:agilex5e_de25 = " SOCFPGA_UART_CONFIG=${SOCFPGA_UART_CONFIG}"
