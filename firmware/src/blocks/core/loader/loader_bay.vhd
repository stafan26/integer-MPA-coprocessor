-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    loader_bay
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.pro_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--		- check if asynchronous data arrival from CPU works fine
--
-------------------------------------------
-------------------------------------------

entity loader_bay is
generic (
	g_lfsr								: boolean := false;
	g_addr_width						: natural := 9;
	g_data_width						: natural := 64
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_start								: in std_logic_vector(1 downto 0);

	s00a_axis_tdata					: in std_logic_vector(g_data_width-1 downto 0);
	s00a_axis_tvalid					: in std_logic;
	s00a_axis_tready					: out std_logic;

	s00b_axis_tdata					: in std_logic_vector(g_data_width-1 downto 0);
	s00b_axis_tvalid					: in std_logic;
	s00b_axis_tready					: out std_logic;

	po_data_A							: out std_logic_vector(g_data_width-1 downto 0);
	po_data_last_A						: out std_logic;
	po_data_sign_A						: out std_logic;
	po_wr_en_A							: out std_logic;

	po_data_B							: out std_logic_vector(g_data_width-1 downto 0);
	po_data_last_B						: out std_logic;
	po_data_sign_B						: out std_logic;
	po_wr_en_B							: out std_logic
);
end loader_bay;

architecture loader_bay of loader_bay is

	signal s_rst_1											: std_logic;
	signal s_rst_2											: std_logic;

	signal s_load_ch_1									: std_logic;
	signal s_load_ch_2									: std_logic;

	signal s_change_ch_1									: std_logic;
	signal s_change_ch_2									: std_logic;

	signal s_last_ch_1									: std_logic;
	signal s_last_ch_2									: std_logic;

begin

	LFSR_COUNTER_DOWN_LAST_CH_1_INST: entity work.lfsr_counter_down_3_last_1 generic map (
		g_lfsr							=> g_lfsr,														--: boolean := false;
		g_n								=> g_addr_width												--: natural := 9
	)
	port map (
		pi_clk							=> pi_clk,														--: in std_logic;
		pi_rst							=> s_rst_1,														--: in std_logic;
		pi_load							=> s_load_ch_1,												--: in std_logic;
		pi_data							=> s00a_axis_tdata(g_addr_width-1 downto 0),			--: in std_logic_vector(g_n-1 downto 0);
		pi_last							=> s00a_axis_tdata(18 downto 16),						--: in std_logic_vector(2 downto 0);
		pi_change						=> s_change_ch_1,												--: in std_logic;
		po_last							=> s_last_ch_1													--: out std_logic
	);


	LFSR_COUNTER_DOWN_LAST_CH_2_INST: entity work.lfsr_counter_down_3_last_1 generic map (
		g_lfsr							=> g_lfsr,														--: boolean := false;
		g_n								=> g_addr_width												--: natural := 9
	)
	port map (
		pi_clk							=> pi_clk,														--: in std_logic;
		pi_rst							=> s_rst_2,														--: in std_logic;
		pi_load							=> s_load_ch_2,												--: in std_logic;
		pi_data							=> s00b_axis_tdata(g_addr_width-1 downto 0),			--: in std_logic_vector(g_n-1 downto 0);
		pi_last							=> s00b_axis_tdata(18 downto 16),						--: in std_logic_vector(2 downto 0);
		pi_change						=> s_change_ch_2,												--: in std_logic;
		po_last							=> s_last_ch_2													--: out std_logic
	);


	LOADER_A_INST: entity work.loader generic map (
		g_data_width					=> g_data_width						--: natural := 64
	)
	port map (
		pi_clk							=> pi_clk,								--: in std_logic;
		pi_rst							=> pi_rst,								--: in std_logic;
		pi_start							=> pi_start(0),						--: in std_logic;
		s00_axis_tdata					=> s00a_axis_tdata,					--: in std_logic_vector(g_data_width-1 downto 0);
		s00_axis_tvalid				=> s00a_axis_tvalid,					--: in std_logic;
		s00_axis_tready				=> s00a_axis_tready,					--: out std_logic;
		po_rst							=> s_rst_1,								--: out std_logic;
		po_load							=> s_load_ch_1,						--: out std_logic;
		po_change						=> s_change_ch_1,						--: out std_logic;
		pi_last							=> s_last_ch_1,						--: in std_logic;
		po_data							=> po_data_A,							--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last					=> po_data_last_A,					--: out std_logic;
		po_data_sign					=> po_data_sign_A,					--: out std_logic;
		po_wr_en							=> po_wr_en_A							--: out std_logic
	);


	LOADER_B_INST: entity work.loader generic map (
		g_data_width					=> g_data_width						--: natural := 64
	)
	port map (
		pi_clk							=> pi_clk,								--: in std_logic;
		pi_rst							=> pi_rst,								--: in std_logic;
		pi_start							=> pi_start(1),						--: in std_logic;
		s00_axis_tdata					=> s00b_axis_tdata,					--: in std_logic_vector(g_data_width-1 downto 0);
		s00_axis_tvalid				=> s00b_axis_tvalid,					--: in std_logic;
		s00_axis_tready				=> s00b_axis_tready,					--: out std_logic;
		po_rst							=> s_rst_2,								--: out std_logic;
		po_load							=> s_load_ch_2,						--: out std_logic;
		po_change						=> s_change_ch_2,						--: out std_logic;
		pi_last							=> s_last_ch_2,						--: in std_logic;
		po_data							=> po_data_B,							--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last					=> po_data_last_B,					--: out std_logic;
		po_data_sign					=> po_data_sign_B,					--: out std_logic;
		po_wr_en							=> po_wr_en_B							--: out std_logic
	);



end architecture;
