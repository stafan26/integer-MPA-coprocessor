	-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    01/12/2016
-- Project Name:   MPALU
-- Design Name:    prog_loader_TB
-- Module Name:    prog_loader_TB
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;


use work.pro_pack.all;
use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity prog_loader_TB is
end prog_loader_TB;

architecture prog_loader_TB of prog_loader_TB is

	constant c_ctrl_width			: natural := 8;

	signal r_clk						: std_logic;
	signal r_rst						: std_logic;

	signal s00_ctrl_axis_tdata		: std_logic_vector(c_ctrl_width-1 downto 0);
	signal s00_ctrl_axis_tlast		: std_logic;
	signal s00_ctrl_axis_tvalid	: std_logic;

begin

	process
	begin
		r_clk <= '1';
		wait for PLL_SIM_HALF_PERIOD_TIME;
		r_clk <= '0';
		wait for PLL_SIM_HALF_PERIOD_TIME;
	end process;

	process
	begin
		r_rst <= '1';
		wait for 100 * PLL_SIM_HALF_PERIOD_TIME;
		r_rst <= '0';
		wait;
	end process;


	PROG_LOADER_TB_INST: entity work.prog_loader generic map (
		g_ctrl_width				=> c_ctrl_width				--: natural := 8
	)
	port map (
		pi_clk						=> r_clk,						--: in std_logic;
		pi_rst						=> r_rst,						--: in std_logic;
		s00_ctrl_axis_tdata		=> s00_ctrl_axis_tdata,		--: out std_logic_vector(g_ctrl_width-1 downto 0);
		s00_ctrl_axis_tlast		=> s00_ctrl_axis_tlast,		--: out std_logic;
		s00_ctrl_axis_tvalid		=> s00_ctrl_axis_tvalid,	--: out std_logic;
		s00_ctrl_axis_tready		=> '1'							--: in std_logic
	);

end architecture;




