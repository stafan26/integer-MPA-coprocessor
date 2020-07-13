-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    common
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.pro_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity common is
generic (
	g_id									: natural := 10;
	g_ctrl_width						: natural := 8;
	g_data_width						: natural := 64;
	g_select_width						: natural := 4
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_ctrl								: in std_logic_vector(g_ctrl_width-1 downto 0);
	pi_ctrl_valid_n					: in std_logic;

	pi_data								: in t_data_x1;
	pi_data_last						: in std_logic;
	pi_data_wr_en						: in std_logic;

	po_data								: out std_logic_vector(g_data_width-1 downto 0);
	po_data_last						: out std_logic;
	po_data_wr_en						: out std_logic
);
end common;

architecture common of common is

	signal s_start											: std_logic;
	signal s_select										: std_logic_vector(g_select_width-1 downto 0);

	signal s_data_last									: std_logic;
	signal s_data_wr_en									: std_logic;

begin

	DATA_LAST_INPUT_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,									--: natural := 1;
		g_delay					=> 4									--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_data(0)				=> pi_data_last,					--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_data_last						--: out std_logic_vector(g_data_width-1 downto 0)
	);


	DATA_WR_EN_INPUT_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,									--: natural := 1;
		g_delay					=> 4									--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_data(0)				=> pi_data_wr_en,					--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_data_wr_en					--: out std_logic_vector(g_data_width-1 downto 0)
	);


	COMMON_CTRL_INST: entity work.common_ctrl generic map (
		g_id									=> g_id,									--: natural := 23;
		g_ctrl_width						=> g_ctrl_width,						--: natural := 64;
		g_select_width						=> g_select_width						--: natural := 4;
	)
	port map (
		pi_clk								=> pi_clk,								--: in std_logic;

		pi_ctrl								=> pi_ctrl,								--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_valid_n					=> pi_ctrl_valid_n,					--: in std_logic;

		po_start								=> s_start,								--: in std_logic;
		po_select							=> s_select								--: in std_logic_vector(g_select_width-1 downto 0);
	);


	COMMON_SWITCHBOX_INST: entity work.common_switchbox generic map (
		g_data_width						=> g_data_width,						--: natural := 64;
		g_select_width						=> g_select_width						--: natural := 4;
	)
	port map (
		pi_clk								=> pi_clk,								--: in std_logic;
		pi_rst								=> pi_rst,								--: in std_logic;
		pi_start								=> s_start,								--: in std_logic;
		pi_select							=> s_select,							--: in std_logic_vector(g_select_width-1 downto 0);
		pi_data								=> pi_data,								--: in t_data_x1;
		pi_data_last						=> s_data_last,						--: in std_logic;
		pi_data_wr_en						=> s_data_wr_en,						--: in std_logic;
		po_data								=> po_data,								--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last						=> po_data_last,						--: out std_logic;
		po_data_wr_en						=> po_data_wr_en						--: out std_logic
	);

end architecture;
