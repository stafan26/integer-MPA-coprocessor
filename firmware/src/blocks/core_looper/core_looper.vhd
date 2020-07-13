-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    01/12/2016
-- Project Name:   MPALU
-- Design Name:    core_looper
-- Module Name:    core_looper
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

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

entity core_looper is
generic (
	g_sim									: boolean := false;
	g_num_of_bram						: natural := 1;
	g_lfsr								: boolean := true;
	g_num_of_registers				: natural := C_NUM_OF_REGISTERS;
	g_data_width						: natural := C_STD_DATA_WIDTH;
	g_addr_width						: natural := C_STD_ADDR_WIDTH;
	g_ctrl_width						: natural := C_STD_CTRL_WIDTH
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	s00a_axis_tdata					: in std_logic_vector(g_data_width-1 downto 0);
	s00a_axis_tvalid					: in std_logic;
	s00a_axis_tready					: out std_logic;

	s00b_axis_tdata					: in std_logic_vector(g_data_width-1 downto 0);
	s00b_axis_tvalid					: in std_logic;
	s00b_axis_tready					: out std_logic;

	m00_axis_tdata						: out std_logic_vector(g_data_width-1 downto 0);
	m00_axis_tvalid					: out std_logic;
	m00_axis_tready					: in std_logic
);
end core_looper;

architecture core_looper of core_looper is

	signal r_rst			: std_logic_vector(9 downto 0);

	signal s00_ctrl_axis_tdata					: std_logic_vector(g_ctrl_width-1 downto 0);
	signal s00_ctrl_axis_tlast					: std_logic;
	signal s00_ctrl_axis_tvalid				: std_logic;
	signal s00_ctrl_axis_tready				: std_logic;

begin

	process(s_clk)
	begin
		if(rising_edge(s_clk)) then

			-----------
			-- R_RST --
			-----------
			r_rst <= r_rst(r_rst'length-2 downto 0) & pi_rst;

		end if;
	end process;


	CORE_INST: entity work.core generic map (
		g_sim							=> g_sim,								--: boolean := false;
		g_num_of_bram				=> g_num_of_bram,						--: natural := 1;
		g_lfsr						=> g_lfsr,								--: boolean := true;
		g_num_of_registers		=> g_num_of_registers,				--: natural := C_NUM_OF_REGISTERS;
		g_data_width				=> g_data_width,						--: natural := C_STD_DATA_WIDTH;
		g_addr_width				=> g_addr_width,						--: natural := C_STD_ADDR_WIDTH;
		g_ctrl_width				=> g_ctrl_width						--: natural := C_STD_CTRL_WIDTH
	)
	port map (
		pi_clk						=> pi_clk,								--: in std_logic;
		pi_rst						=> pi_rst,								--: in std_logic;
		s00a_axis_tdata			=> s00a_axis_tdata,					--: in std_logic_vector(g_data_width-1 downto 0);
		s00a_axis_tvalid			=> s00a_axis_tvalid,					--: in std_logic;
		s00a_axis_tready			=> s00a_axis_tready,					--: out std_logic;
		s00b_axis_tdata			=> s00b_axis_tdata,					--: in std_logic_vector(g_data_width-1 downto 0);
		s00b_axis_tvalid			=> s00b_axis_tvalid,					--: in std_logic;
		s00b_axis_tready			=> s00b_axis_tready,					--: out std_logic;
		s00_ctrl_axis_tdata		=> s00_ctrl_axis_tdata,				--: in std_logic_vector(g_ctrl_width-1 downto 0);
		s00_ctrl_axis_tlast		=> s00_ctrl_axis_tlast,				--: in std_logic;
		s00_ctrl_axis_tvalid		=> s00_ctrl_axis_tvalid,			--: in std_logic;
		s00_ctrl_axis_tready		=> s00_ctrl_axis_tready,			--: out std_logic;
		m00_axis_tdata				=> m00_axis_tdata,					--: out std_logic_vector(g_data_width-1 downto 0);
		m00_axis_tvalid			=> m00_axis_tvalid,					--: out std_logic;
		m00_axis_tready			=> m00_axis_tready					--: in std_logic
	);


	PROG_LOADER_INST: entity work.prog_loader port map (
		pi_clk						=> pi_clk,								--: in std_logic;
		pi_rst						=> r_rst(r_rst'length-1),			--: in std_logic;
		s00_ctrl_axis_tdata		=> s00_ctrl_axis_tdata,				--: out std_logic_vector(g_ctrl_width-1 downto 0);
		s00_ctrl_axis_tlast		=> s00_ctrl_axis_tlast,				--: out std_logic;
		s00_ctrl_axis_tvalid		=> s00_ctrl_axis_tvalid,			--: out std_logic;
		s00_ctrl_axis_tready		=> s00_ctrl_axis_tready				--: in std_logic;
	);

end architecture;
