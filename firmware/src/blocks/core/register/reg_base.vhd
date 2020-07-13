-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    reg_base
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
--use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity reg_base is
generic (
	g_sim									: boolean := false;
	g_lfsr								: boolean := false;
	g_data_width						: natural := 64;
	g_addr_width						: natural := 9;
	g_ctrl_width						: natural := 8;
	g_id									: natural := 2
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_ctrl_ch_1						: in std_logic_vector(g_ctrl_width-1 downto 0);
	pi_ctrl_ch_1_valid_n				: in std_logic;
	pi_ctrl_ch_2						: in std_logic_vector(g_ctrl_width-1 downto 0);
	pi_ctrl_ch_2_valid_n				: in std_logic;

	po_cmc_channel						: out std_logic;
	po_operand_B						: out std_logic;
	po_select							: out std_logic_vector(2 downto 0);
	po_start_rd							: out std_logic;
	po_start_wr							: out std_logic;
	po_select_hi_lo					: out std_logic;
	po_set_zero							: out std_logic;
	po_set_one							: out std_logic;

	pi_cpu_addr_init_up				: in std_logic;
	pi_cpu_data_cycle					: in std_logic;
	pi_cpu_data_valid					: in std_logic;
	pi_cpu_data_last_my				: in std_logic;
	pi_cpu_data_last_other			: in std_logic;

	pi_data								: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_last						: in std_logic;
	pi_data_wr_en						: in std_logic;

	po_data								: out std_logic_vector(g_data_width-1 downto 0)
);
end reg_base;

architecture reg_base of reg_base is

	signal s_data											: std_logic_vector(g_data_width-1 downto 0);

	signal s_read_addr									: std_logic_vector(g_addr_width-1 downto 0);
	signal s_write_addr									: std_logic_vector(g_addr_width-1 downto 0);

	signal s_addr_up_down								: std_logic;

begin

	MY_BRAM_INST: entity work.my_bram generic map (
		g_sim				=> g_sim,						--: boolean := false;
		g_data_width	=> g_data_width,				--: natural := 64;
		g_addr_width	=> g_addr_width				--: natural := 9
	)
	port map (
		pi_clk			=> pi_clk,						--: in std_logic;
		pi_we_A			=> pi_data_wr_en,				--: in std_logic;
		pi_addr_A		=> s_write_addr,				--: in std_logic_vector(g_addr_port_width-1 downto 0);
		pi_data_A		=> pi_data,						--: in std_logic_vector(g_data_port_width-1 downto 0);
		pi_addr_B		=> s_read_addr,				--: in std_logic_vector(g_addr_port_width-1 downto 0);
		po_data_B		=> s_data						--: out std_logic_vector(g_data_port_width-1 downto 0)
	);


	REG_SELECTOR_INST: entity work.reg_selector generic map (
		g_data_width				=> g_data_width				--: natural := 64;
	)
	port map (
		pi_clk						=> pi_clk,						--: in std_logic;

		pi_data_shutter			=> pi_cpu_data_valid,			--: in std_logic;

		pi_data						=> s_data,						--: in std_logic_vector(g_data_width-1 downto 0);
		po_data						=> po_data						--: out std_logic_vector(g_data_width-1 downto 0);
	);


	REG_WRITE_ADDR_INST: entity work.reg_write_addr generic map (
		g_lfsr			=> g_lfsr,						--: string := "YES";
		g_addr_width	=> g_addr_width				--: natural := 9
	)
	port map (
		pi_clk			=> pi_clk,						--: in std_logic;
		pi_rst			=> pi_rst,						--: in std_logic;
		pi_data_wr_en	=> pi_data_wr_en,				--: in std_logic;
		pi_data_last	=> pi_data_last,				--: in std_logic;
		po_write_addr	=> s_write_addr				--: out std_logic_vector(g_addr_width-1 downto 0)
	);


	REG_ADDRESSING_UNIT_A_INST: entity work.reg_addressing_unit generic map (
		g_lfsr					=> g_lfsr,						--: string := "NO";
		g_addr_width			=> g_addr_width				--: natural := 9
	)
	port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_rst					=> pi_rst,						--: in std_logic;
		pi_addr_init_up		=> pi_cpu_addr_init_up,		--: in std_logic;
		pi_data_cycle			=> pi_cpu_data_cycle,		--: in std_logic;
		pi_data_valid			=> pi_cpu_data_valid,		--: in std_logic;
		pi_data_last_my		=> pi_cpu_data_last_my,		--: in std_logic;
		pi_data_last_other	=> pi_cpu_data_last_other,	--: in std_logic;
		pi_addr_up_down		=> s_addr_up_down,			--: in std_logic;
		po_read_addr			=> s_read_addr					--: out std_logic_vector(g_addr_width-1 downto 0);
	);


	REG_CTRL_INST: entity work.reg_ctrl generic map (
		g_id						=> g_id,							--: natural := 10;
		g_addr_width			=> g_addr_width,				--: natural := 11;
		g_ctrl_width			=> g_ctrl_width				--: natural := 8
	)
	port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_rst					=> pi_rst,						--: in std_logic;
		pi_ctrl_ch_1			=> pi_ctrl_ch_1,				--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_ch_1_valid_n	=> pi_ctrl_ch_1_valid_n,	--: in std_logic;
		pi_ctrl_ch_2			=> pi_ctrl_ch_2,				--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_ch_2_valid_n	=> pi_ctrl_ch_2_valid_n,	--: in std_logic;
		po_cmc_channel			=> po_cmc_channel,			--: out std_logic;
		po_operand_B			=> po_operand_B,				--: out std_logic;
		po_addr_up_down		=> s_addr_up_down,			--: out std_logic;
		po_select				=> po_select,					--: out std_logic_vector(2 downto 0);
		po_start_rd				=> po_start_rd,				--: out std_logic;
		po_start_wr				=> po_start_wr,				--: out std_logic;
		po_select_hi_lo		=> po_select_hi_lo,			--: out std_logic;
		po_set_zero				=> po_set_zero,				--: out std_logic;
		po_set_one				=> po_set_one					--: out std_logic
	);

end architecture;
