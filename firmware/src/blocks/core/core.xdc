create_clock -name ext_clock -period 10.0 [get_ports {pi_clk_ext}]

startgroup
create_pblock srup_pblock
resize_pblock srup_pblock -add CLOCKREGION_X0Y1:CLOCKREGION_X0Y1
add_cells_to_pblock srup_pblock [get_cells [list CORE_INST]]
endgroup

set_multicycle_path -setup -from [get_pins "MY_PLL_INST/r_rst_main_reg*/C"] -to [get_pins -hierarchical "*r_*_reg*/R*"] 250
set_multicycle_path -setup -from [get_pins "MY_PLL_INST/r_rst_main_reg*/C"] -to [get_pins -hierarchical "*r_*_reg*/S*"] 250
set_multicycle_path -setup -from [get_pins "MY_PLL_INST/r_rst_main_reg*/C"] -to [get_pins -hierarchical "*r_*_reg*/D*"] 250

set_multicycle_path -hold -from [get_pins "MY_PLL_INST/r_rst_main_reg*/C"] -to [get_pins -hierarchical "*r_*_reg*/R*"] 250
set_multicycle_path -hold -from [get_pins "MY_PLL_INST/r_rst_main_reg*/C"] -to [get_pins -hierarchical "*r_*_reg*/S*"] 250
set_multicycle_path -hold -from [get_pins "MY_PLL_INST/r_rst_main_reg*/C"] -to [get_pins -hierarchical "*r_*_reg*/D*"] 250



#set_property PACKAGE_PIN AE2   [get_ports pi_rst_ext             ]; set_property IOSTANDARD LVCMOS18 [get_ports pi_rst_ext];
#set_property PACKAGE_PIN V4    [get_ports pi_clk_ext             ]; set_property IOSTANDARD LVCMOS18 [get_ports pi_clk_ext];
#
#
#
#set_property PACKAGE_PIN T9    [get_ports s00_ctrl_axis_tready   ]; set_property IOSTANDARD LVCMOS18 [get_ports s00_ctrl_axis_tready];
#set_property PACKAGE_PIN AH2   [get_ports s00_ctrl_axis_tvalid   ]; set_property IOSTANDARD LVCMOS18 [get_ports s00_ctrl_axis_tvalid];
#set_property PACKAGE_PIN AJ1   [get_ports s00_ctrl_axis_tlast    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00_ctrl_axis_tlast];
#set_property PACKAGE_PIN AD4   [get_ports s00_ctrl_axis_tdata[0] ]; set_property IOSTANDARD LVCMOS18 [get_ports s00_ctrl_axis_tdata[0]];
#set_property PACKAGE_PIN AD5   [get_ports s00_ctrl_axis_tdata[1] ]; set_property IOSTANDARD LVCMOS18 [get_ports s00_ctrl_axis_tdata[1]];
#set_property PACKAGE_PIN AG4   [get_ports s00_ctrl_axis_tdata[2] ]; set_property IOSTANDARD LVCMOS18 [get_ports s00_ctrl_axis_tdata[2]];
#set_property PACKAGE_PIN AF4   [get_ports s00_ctrl_axis_tdata[3] ]; set_property IOSTANDARD LVCMOS18 [get_ports s00_ctrl_axis_tdata[3]];
#set_property PACKAGE_PIN AJ3   [get_ports s00_ctrl_axis_tdata[4] ]; set_property IOSTANDARD LVCMOS18 [get_ports s00_ctrl_axis_tdata[4]];
#set_property PACKAGE_PIN AH3   [get_ports s00_ctrl_axis_tdata[5] ]; set_property IOSTANDARD LVCMOS18 [get_ports s00_ctrl_axis_tdata[5]];
#set_property PACKAGE_PIN AG2   [get_ports s00_ctrl_axis_tdata[6] ]; set_property IOSTANDARD LVCMOS18 [get_ports s00_ctrl_axis_tdata[6]];
#set_property PACKAGE_PIN AF3   [get_ports s00_ctrl_axis_tdata[7] ]; set_property IOSTANDARD LVCMOS18 [get_ports s00_ctrl_axis_tdata[7]];
#
#
#
#set_property PACKAGE_PIN U9    [get_ports s00a_axis_tready       ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tready];
#set_property PACKAGE_PIN AE1   [get_ports s00a_axis_tvalid       ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tvalid];
#set_property PACKAGE_PIN AB11  [get_ports s00a_axis_tdata[0]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[0]];
#set_property PACKAGE_PIN AF10  [get_ports s00a_axis_tdata[1]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[1]];
#set_property PACKAGE_PIN AB9   [get_ports s00a_axis_tdata[2]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[2]];
#set_property PACKAGE_PIN AB10  [get_ports s00a_axis_tdata[3]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[3]];
#set_property PACKAGE_PIN AA9   [get_ports s00a_axis_tdata[4]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[4]];
#set_property PACKAGE_PIN AA10  [get_ports s00a_axis_tdata[5]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[5]];
#set_property PACKAGE_PIN AE10  [get_ports s00a_axis_tdata[6]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[6]];
#set_property PACKAGE_PIN AD10  [get_ports s00a_axis_tdata[7]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[7]];
#set_property PACKAGE_PIN AH11  [get_ports s00a_axis_tdata[8]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[8]];
#set_property PACKAGE_PIN AG11  [get_ports s00a_axis_tdata[9]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[9]];
#set_property PACKAGE_PIN AE11  [get_ports s00a_axis_tdata[10]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[10]];
#set_property PACKAGE_PIN AD11  [get_ports s00a_axis_tdata[11]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[11]];
#set_property PACKAGE_PIN AG9   [get_ports s00a_axis_tdata[12]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[12]];
#set_property PACKAGE_PIN AG10  [get_ports s00a_axis_tdata[13]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[13]];
#set_property PACKAGE_PIN AC8   [get_ports s00a_axis_tdata[14]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[14]];
#set_property PACKAGE_PIN T8    [get_ports s00a_axis_tdata[15]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[15]];
#set_property PACKAGE_PIN U6    [get_ports s00a_axis_tdata[16]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[16]];
#set_property PACKAGE_PIN AC9   [get_ports s00a_axis_tdata[17]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[17]];
#set_property PACKAGE_PIN U7    [get_ports s00a_axis_tdata[18]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[18]];
#set_property PACKAGE_PIN AB6   [get_ports s00a_axis_tdata[19]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[19]];
#set_property PACKAGE_PIN T10   [get_ports s00a_axis_tdata[20]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[20]];
#set_property PACKAGE_PIN U10   [get_ports s00a_axis_tdata[21]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[21]];
#set_property PACKAGE_PIN P10   [get_ports s00a_axis_tdata[22]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[22]];
#set_property PACKAGE_PIN R10   [get_ports s00a_axis_tdata[23]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[23]];
#set_property PACKAGE_PIN R7    [get_ports s00a_axis_tdata[24]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[24]];
#set_property PACKAGE_PIN R8    [get_ports s00a_axis_tdata[25]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[25]];
#set_property PACKAGE_PIN U4    [get_ports s00a_axis_tdata[26]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[26]];
#set_property PACKAGE_PIN U5    [get_ports s00a_axis_tdata[27]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[27]];
#set_property PACKAGE_PIN T2    [get_ports s00a_axis_tdata[28]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[28]];
#set_property PACKAGE_PIN T3    [get_ports s00a_axis_tdata[29]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[29]];
#set_property PACKAGE_PIN U1    [get_ports s00a_axis_tdata[30]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[30]];
#set_property PACKAGE_PIN U2    [get_ports s00a_axis_tdata[31]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[31]];
#set_property PACKAGE_PIN R2    [get_ports s00a_axis_tdata[32]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[32]];
#set_property PACKAGE_PIN R3    [get_ports s00a_axis_tdata[33]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[33]];
#set_property PACKAGE_PIN T4    [get_ports s00a_axis_tdata[34]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[34]];
#set_property PACKAGE_PIN T5    [get_ports s00a_axis_tdata[35]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[35]];
#set_property PACKAGE_PIN R5    [get_ports s00a_axis_tdata[36]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[36]];
#set_property PACKAGE_PIN R6    [get_ports s00a_axis_tdata[37]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[37]];
#set_property PACKAGE_PIN N4    [get_ports s00a_axis_tdata[38]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[38]];
#set_property PACKAGE_PIN P5    [get_ports s00a_axis_tdata[39]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[39]];
#set_property PACKAGE_PIN P3    [get_ports s00a_axis_tdata[40]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[40]];
#set_property PACKAGE_PIN P4    [get_ports s00a_axis_tdata[41]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[41]];
#set_property PACKAGE_PIN N2    [get_ports s00a_axis_tdata[42]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[42]];
#set_property PACKAGE_PIN N3    [get_ports s00a_axis_tdata[43]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[43]];
#set_property PACKAGE_PIN P1    [get_ports s00a_axis_tdata[44]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[44]];
#set_property PACKAGE_PIN R1    [get_ports s00a_axis_tdata[45]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[45]];
#set_property PACKAGE_PIN M4    [get_ports s00a_axis_tdata[46]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[46]];
#set_property PACKAGE_PIN M5    [get_ports s00a_axis_tdata[47]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[47]];
#set_property PACKAGE_PIN M1    [get_ports s00a_axis_tdata[48]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[48]];
#set_property PACKAGE_PIN N1    [get_ports s00a_axis_tdata[49]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[49]];
#set_property PACKAGE_PIN N6    [get_ports s00a_axis_tdata[50]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[50]];
#set_property PACKAGE_PIN P6    [get_ports s00a_axis_tdata[51]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[51]];
#set_property PACKAGE_PIN P8    [get_ports s00a_axis_tdata[52]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[52]];
#set_property PACKAGE_PIN P9    [get_ports s00a_axis_tdata[53]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[53]];
#set_property PACKAGE_PIN M10   [get_ports s00a_axis_tdata[54]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[54]];
#set_property PACKAGE_PIN M11   [get_ports s00a_axis_tdata[55]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[55]];
#set_property PACKAGE_PIN AB7   [get_ports s00a_axis_tdata[56]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[56]];
#set_property PACKAGE_PIN N7    [get_ports s00a_axis_tdata[57]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[57]];
#set_property PACKAGE_PIN N8    [get_ports s00a_axis_tdata[58]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[58]];
#set_property PACKAGE_PIN M9    [get_ports s00a_axis_tdata[59]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[59]];
#set_property PACKAGE_PIN N9    [get_ports s00a_axis_tdata[60]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[60]];
#set_property PACKAGE_PIN M6    [get_ports s00a_axis_tdata[61]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[61]];
#set_property PACKAGE_PIN M7    [get_ports s00a_axis_tdata[62]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[62]];
#set_property PACKAGE_PIN R11   [get_ports s00a_axis_tdata[63]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00a_axis_tdata[63]];
#
#
#
#set_property PACKAGE_PIN T7    [get_ports s00b_axis_tready       ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tready];
#set_property PACKAGE_PIN AD1   [get_ports s00b_axis_tvalid       ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tvalid];
#set_property PACKAGE_PIN AG12  [get_ports s00b_axis_tdata[0]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[0]];
#set_property PACKAGE_PIN AF12  [get_ports s00b_axis_tdata[1]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[1]];
#set_property PACKAGE_PIN AH8   [get_ports s00b_axis_tdata[2]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[2]];
#set_property PACKAGE_PIN AH9   [get_ports s00b_axis_tdata[3]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[3]];
#set_property PACKAGE_PIN AF8   [get_ports s00b_axis_tdata[4]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[4]];
#set_property PACKAGE_PIN AF9   [get_ports s00b_axis_tdata[5]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[5]];
#set_property PACKAGE_PIN AH6   [get_ports s00b_axis_tdata[6]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[6]];
#set_property PACKAGE_PIN AH7   [get_ports s00b_axis_tdata[7]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[7]];
#set_property PACKAGE_PIN AE7   [get_ports s00b_axis_tdata[8]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[8]];
#set_property PACKAGE_PIN AE8   [get_ports s00b_axis_tdata[9]     ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[9]];
#set_property PACKAGE_PIN AD8   [get_ports s00b_axis_tdata[10]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[10]];
#set_property PACKAGE_PIN AD9   [get_ports s00b_axis_tdata[11]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[11]];
#set_property PACKAGE_PIN AG7   [get_ports s00b_axis_tdata[12]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[12]];
#set_property PACKAGE_PIN AF7   [get_ports s00b_axis_tdata[13]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[13]];
#set_property PACKAGE_PIN AC6   [get_ports s00b_axis_tdata[14]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[14]];
#set_property PACKAGE_PIN AC7   [get_ports s00b_axis_tdata[15]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[15]];
#set_property PACKAGE_PIN AA7   [get_ports s00b_axis_tdata[16]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[16]];
#set_property PACKAGE_PIN AA8   [get_ports s00b_axis_tdata[17]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[17]];
#set_property PACKAGE_PIN AC3   [get_ports s00b_axis_tdata[18]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[18]];
#set_property PACKAGE_PIN AC4   [get_ports s00b_axis_tdata[19]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[19]];
#set_property PACKAGE_PIN AC1   [get_ports s00b_axis_tdata[20]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[20]];
#set_property PACKAGE_PIN AC2   [get_ports s00b_axis_tdata[21]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[21]];
#set_property PACKAGE_PIN AA2   [get_ports s00b_axis_tdata[22]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[22]];
#set_property PACKAGE_PIN AA3   [get_ports s00b_axis_tdata[23]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[23]];
#set_property PACKAGE_PIN AB1   [get_ports s00b_axis_tdata[24]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[24]];
#set_property PACKAGE_PIN AB2   [get_ports s00b_axis_tdata[25]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[25]];
#set_property PACKAGE_PIN AB4   [get_ports s00b_axis_tdata[26]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[26]];
#set_property PACKAGE_PIN AB5   [get_ports s00b_axis_tdata[27]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[27]];
#set_property PACKAGE_PIN AA4   [get_ports s00b_axis_tdata[28]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[28]];
#set_property PACKAGE_PIN AA5   [get_ports s00b_axis_tdata[29]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[29]];
#set_property PACKAGE_PIN Y5    [get_ports s00b_axis_tdata[30]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[30]];
#set_property PACKAGE_PIN W5    [get_ports s00b_axis_tdata[31]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[31]];
#set_property PACKAGE_PIN W4    [get_ports s00b_axis_tdata[32]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[32]];
#set_property PACKAGE_PIN W3    [get_ports s00b_axis_tdata[33]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[33]];
#set_property PACKAGE_PIN V3    [get_ports s00b_axis_tdata[34]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[34]];
#set_property PACKAGE_PIN Y2    [get_ports s00b_axis_tdata[35]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[35]];
#set_property PACKAGE_PIN Y3    [get_ports s00b_axis_tdata[36]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[36]];
#set_property PACKAGE_PIN V1    [get_ports s00b_axis_tdata[37]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[37]];
#set_property PACKAGE_PIN V2    [get_ports s00b_axis_tdata[38]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[38]];
#set_property PACKAGE_PIN Y1    [get_ports s00b_axis_tdata[39]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[39]];
#set_property PACKAGE_PIN W1    [get_ports s00b_axis_tdata[40]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[40]];
#set_property PACKAGE_PIN Y6    [get_ports s00b_axis_tdata[41]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[41]];
#set_property PACKAGE_PIN W6    [get_ports s00b_axis_tdata[42]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[42]];
#set_property PACKAGE_PIN Y7    [get_ports s00b_axis_tdata[43]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[43]];
#set_property PACKAGE_PIN Y8    [get_ports s00b_axis_tdata[44]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[44]];
#set_property PACKAGE_PIN V6    [get_ports s00b_axis_tdata[45]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[45]];
#set_property PACKAGE_PIN V7    [get_ports s00b_axis_tdata[46]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[46]];
#set_property PACKAGE_PIN W8    [get_ports s00b_axis_tdata[47]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[47]];
#set_property PACKAGE_PIN W9    [get_ports s00b_axis_tdata[48]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[48]];
#set_property PACKAGE_PIN V8    [get_ports s00b_axis_tdata[49]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[49]];
#set_property PACKAGE_PIN AE6   [get_ports s00b_axis_tdata[50]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[50]];
#set_property PACKAGE_PIN V9    [get_ports s00b_axis_tdata[51]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[51]];
#set_property PACKAGE_PIN Y10   [get_ports s00b_axis_tdata[52]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[52]];
#set_property PACKAGE_PIN W10   [get_ports s00b_axis_tdata[53]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[53]];
#set_property PACKAGE_PIN Y11   [get_ports s00b_axis_tdata[54]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[54]];
#set_property PACKAGE_PIN AD6   [get_ports s00b_axis_tdata[55]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[55]];
#set_property PACKAGE_PIN AF5   [get_ports s00b_axis_tdata[56]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[56]];
#set_property PACKAGE_PIN AE5   [get_ports s00b_axis_tdata[57]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[57]];
#set_property PACKAGE_PIN AG5   [get_ports s00b_axis_tdata[58]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[58]];
#set_property PACKAGE_PIN AG6   [get_ports s00b_axis_tdata[59]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[59]];
#set_property PACKAGE_PIN AE3   [get_ports s00b_axis_tdata[60]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[60]];
#set_property PACKAGE_PIN AD3   [get_ports s00b_axis_tdata[61]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[61]];
#set_property PACKAGE_PIN AJ4   [get_ports s00b_axis_tdata[62]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[62]];
#set_property PACKAGE_PIN AH4   [get_ports s00b_axis_tdata[63]    ]; set_property IOSTANDARD LVCMOS18 [get_ports s00b_axis_tdata[63]];
#
#
#
#set_property PACKAGE_PIN AF2   [get_ports m00_axis_tready        ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tready];
#set_property PACKAGE_PIN U11   [get_ports m00_axis_tvalid        ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tvalid];
#set_property PACKAGE_PIN U24   [get_ports m00_axis_tdata[0]      ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[0]];
#set_property PACKAGE_PIN P34   [get_ports m00_axis_tdata[1]      ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[1]];
#set_property PACKAGE_PIN P33   [get_ports m00_axis_tdata[2]      ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[2]];
#set_property PACKAGE_PIN T34   [get_ports m00_axis_tdata[3]      ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[3]];
#set_property PACKAGE_PIN U34   [get_ports m00_axis_tdata[4]      ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[4]];
#set_property PACKAGE_PIN M34   [get_ports m00_axis_tdata[5]      ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[5]];
#set_property PACKAGE_PIN N34   [get_ports m00_axis_tdata[6]      ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[6]];
#set_property PACKAGE_PIN R33   [get_ports m00_axis_tdata[7]      ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[7]];
#set_property PACKAGE_PIN T33   [get_ports m00_axis_tdata[8]      ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[8]];
#set_property PACKAGE_PIN N33   [get_ports m00_axis_tdata[9]      ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[9]];
#set_property PACKAGE_PIN N32   [get_ports m00_axis_tdata[10]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[10]];
#set_property PACKAGE_PIN W24   [get_ports m00_axis_tdata[11]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[11]];
#set_property PACKAGE_PIN AB25  [get_ports m00_axis_tdata[12]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[12]];
#set_property PACKAGE_PIN R32   [get_ports m00_axis_tdata[13]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[13]];
#set_property PACKAGE_PIN T32   [get_ports m00_axis_tdata[14]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[14]];
#set_property PACKAGE_PIN U32   [get_ports m00_axis_tdata[15]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[15]];
#set_property PACKAGE_PIN AB24  [get_ports m00_axis_tdata[16]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[16]];
#set_property PACKAGE_PIN AA25  [get_ports m00_axis_tdata[17]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[17]];
#set_property PACKAGE_PIN AA24  [get_ports m00_axis_tdata[18]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[18]];
#set_property PACKAGE_PIN AB29  [get_ports m00_axis_tdata[19]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[19]];
#set_property PACKAGE_PIN AA29  [get_ports m00_axis_tdata[20]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[20]];
#set_property PACKAGE_PIN AB27  [get_ports m00_axis_tdata[21]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[21]];
#set_property PACKAGE_PIN AB26  [get_ports m00_axis_tdata[22]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[22]];
#set_property PACKAGE_PIN AA28  [get_ports m00_axis_tdata[23]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[23]];
#set_property PACKAGE_PIN AA27  [get_ports m00_axis_tdata[24]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[24]];
#set_property PACKAGE_PIN AC29  [get_ports m00_axis_tdata[25]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[25]];
#set_property PACKAGE_PIN AC28  [get_ports m00_axis_tdata[26]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[26]];
#set_property PACKAGE_PIN AB34  [get_ports m00_axis_tdata[27]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[27]];
#set_property PACKAGE_PIN AA34  [get_ports m00_axis_tdata[28]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[28]];
#set_property PACKAGE_PIN AC32  [get_ports m00_axis_tdata[29]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[29]];
#set_property PACKAGE_PIN AC31  [get_ports m00_axis_tdata[30]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[30]];
#set_property PACKAGE_PIN AA33  [get_ports m00_axis_tdata[31]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[31]];
#set_property PACKAGE_PIN AA32  [get_ports m00_axis_tdata[32]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[32]];
#set_property PACKAGE_PIN AC34  [get_ports m00_axis_tdata[33]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[33]];
#set_property PACKAGE_PIN AC33  [get_ports m00_axis_tdata[34]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[34]];
#set_property PACKAGE_PIN AB32  [get_ports m00_axis_tdata[35]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[35]];
#set_property PACKAGE_PIN AB31  [get_ports m00_axis_tdata[36]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[36]];
#set_property PACKAGE_PIN AB30  [get_ports m00_axis_tdata[37]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[37]];
#set_property PACKAGE_PIN AA30  [get_ports m00_axis_tdata[38]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[38]];
#set_property PACKAGE_PIN Y31   [get_ports m00_axis_tdata[39]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[39]];
#set_property PACKAGE_PIN Y30   [get_ports m00_axis_tdata[40]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[40]];
#set_property PACKAGE_PIN W31   [get_ports m00_axis_tdata[41]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[41]];
#set_property PACKAGE_PIN W30   [get_ports m00_axis_tdata[42]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[42]];
#set_property PACKAGE_PIN Y33   [get_ports m00_axis_tdata[43]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[43]];
#set_property PACKAGE_PIN Y32   [get_ports m00_axis_tdata[44]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[44]];
#set_property PACKAGE_PIN V34   [get_ports m00_axis_tdata[45]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[45]];
#set_property PACKAGE_PIN V33   [get_ports m00_axis_tdata[46]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[46]];
#set_property PACKAGE_PIN W34   [get_ports m00_axis_tdata[47]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[47]];
#set_property PACKAGE_PIN W33   [get_ports m00_axis_tdata[48]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[48]];
#set_property PACKAGE_PIN V32   [get_ports m00_axis_tdata[49]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[49]];
#set_property PACKAGE_PIN V31   [get_ports m00_axis_tdata[50]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[50]];
#set_property PACKAGE_PIN Y28   [get_ports m00_axis_tdata[51]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[51]];
#set_property PACKAGE_PIN Y27   [get_ports m00_axis_tdata[52]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[52]];
#set_property PACKAGE_PIN Y25   [get_ports m00_axis_tdata[53]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[53]];
#set_property PACKAGE_PIN W25   [get_ports m00_axis_tdata[54]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[54]];
#set_property PACKAGE_PIN W29   [get_ports m00_axis_tdata[55]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[55]];
#set_property PACKAGE_PIN W28   [get_ports m00_axis_tdata[56]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[56]];
#set_property PACKAGE_PIN Y26   [get_ports m00_axis_tdata[57]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[57]];
#set_property PACKAGE_PIN W26   [get_ports m00_axis_tdata[58]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[58]];
#set_property PACKAGE_PIN V27   [get_ports m00_axis_tdata[59]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[59]];
#set_property PACKAGE_PIN V26   [get_ports m00_axis_tdata[60]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[60]];
#set_property PACKAGE_PIN V29   [get_ports m00_axis_tdata[61]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[61]];
#set_property PACKAGE_PIN V28   [get_ports m00_axis_tdata[62]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[62]];
#set_property PACKAGE_PIN V24   [get_ports m00_axis_tdata[63]     ]; set_property IOSTANDARD LVCMOS18 [get_ports m00_axis_tdata[63]];
#
