###########################################################################
# SDC files for DE2-115 board
###########################################################################

# Clock in input pin (50 MHz)
create_clock -period 20 [get_ports clk]

set_clock_groups -asynchronous -group [get_clocks {clk}]


# Create generated clocks based on PLLs
derive_pll_clocks

derive_clock_uncertainty

# ** Input/Output Delays

# Use FPGA-centric constraints (general pins)
# Tsu 5 ns
set_max_delay -from [all_inputs] -to [all_registers] 5
set_min_delay -from [all_inputs] -to [all_registers] 0
# Tco 10 ns
set_max_delay -from [all_registers] -to [all_outputs] 10
set_min_delay -from [all_registers] -to [all_outputs] 0

# Use FPGA-centric constraints (SRAM pins)
# Tsu 3 ns
set_max_delay -from [get_ports *RAM*] -to [get_registers {*}] 3
# Tco 5.5 ns
set_max_delay -from [get_registers *] -to [get_ports {*RAM*}] 5.5

# Reset handler
set_max_delay -from [get_registers "res_reg*"] -to [get_registers {speed_reg*}] 2
set_max_delay -from [get_registers "int_res"] -to [get_registers {speed_reg*}] 2

set_false_path -from [get_ports ENET0_INT_N] -to *
set_false_path -from * -to [get_ports ENET0_RST_N]

set_false_path -from [get_ports ENET1_INT_N] -to *
set_false_path -from * -to [get_ports ENET1_RST_N]

#set_false_path -from [get_ports {int_res}] -to [all_registers]

source ../../WiresharkMAC/fpga/lib/eth/syn/quartus/eth_mac_1g_rgmii.sdc
source ../../WiresharkMAC/fpga/lib/eth/syn/quartus/rgmii_phy_if.sdc
source ../../WiresharkMAC/fpga/lib/eth/syn/quartus/rgmii_io.sdc
source ../../WiresharkMAC/fpga/lib/eth/lib/axis/syn/quartus/axis_async_fifo.sdc


# clocking infrastructure
set_false_path -from * -to [get_registers "res_reg*"]

# ENET0 RGMII MAC
constrain_eth_mac_1g_rgmii_inst "patmos_inst|FShark|ethmac1g|eth_mac_1g_rgmii_inst"
constrain_axis_async_fifo_inst "patmos_inst|FShark|ethmac1g|rx_fifo|fifo_inst"
constrain_axis_async_fifo_inst "patmos_inst|FShark|ethmac1g|tx_fifo|fifo_inst"

# ENET0 RGMII interface
constrain_rgmii_input_pins "enet0" "ENET0_RX_CLK" "ENET0_RX_DV ENET0_RX_D*"
constrain_rgmii_output_pins "enet0" "cyc4_pll_all_inst|altpll_component|auto_generated|pll1|clk[1]" "ENET0_GTX_CLK" "ENET0_TX_EN ENET0_TX_D*"

# ENET1 RGMII interface
constrain_rgmii_input_pins "enet1" "ENET1_RX_CLK" "ENET1_RX_DV ENET1_RX_D*"
constrain_rgmii_output_pins "enet1" "cyc4_pll_all_inst|altpll_component|auto_generated|pll1|clk[1]" "ENET1_GTX_CLK" "ENET1_TX_EN ENET1_TX_D*"
