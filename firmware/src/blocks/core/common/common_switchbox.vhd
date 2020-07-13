-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    common_switchbox
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

entity common_switchbox is
generic (
	g_data_width						: natural := 64;
	g_select_width						: natural := 4
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_select							: in std_logic_vector(g_select_width-1 downto 0);
	pi_start								: in std_logic;

	pi_data								: in t_data_x1;
	pi_data_last						: in std_logic;
	pi_data_wr_en						: in std_logic;

	po_data								: out std_logic_vector(g_data_width-1 downto 0);
	po_data_last						: out std_logic;
	po_data_wr_en						: out std_logic
);
end common_switchbox;

architecture common_switchbox of common_switchbox is

begin

	REG_SWITCHBOX_INST: entity work.oper_switchbox generic map (
		g_output_data_last		=> true,											--: boolean := false;
		g_data_width				=> g_data_width,								--: natural := 64
		g_select_width				=> g_select_width								--: natural := 4
	)
	port map (
		pi_clk						=> pi_clk,										--: in std_logic;
		pi_rst						=> pi_rst,										--: in std_logic;
		pi_select					=> pi_select,									--: in std_logic_vector(g_select_width-1 downto 0);
		pi_start						=> pi_start,									--: in std_logic;
		pi_data						=> pi_data,										--: in t_data_x1;
		pi_data_last				=> pi_data_last,								--: in std_logic;
		po_data						=> po_data,										--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last				=> po_data_last								--: out std_logic;
	);


	WR_EN_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,								--: natural := 1;
		g_delay					=> 2								--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_data(0)				=> pi_data_wr_en,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> po_data_wr_en				--: out std_logic_vector(g_data_width-1 downto 0)
	);

end architecture;
