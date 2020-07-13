-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    01/12/2016
-- Project Name:   MPALU
-- Design Name:    core_wrapper
-- Module Name:    core_wrapper
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

entity core_wrapper is
generic (
	g_sim									: boolean := false;
	g_num_of_bram						: natural := 1;
	g_lfsr								: boolean := true;
	g_num_of_logic_registers		: natural := C_NUM_OF_REGISTERS;
	g_num_of_phys_registers			: natural := C_NUM_OF_ALL_REGISTERS;
	g_data_width						: natural := C_STD_DATA_WIDTH;
	g_addr_width						: natural := C_STD_ADDR_WIDTH;
	g_ctrl_width						: natural := C_STD_CTRL_WIDTH
);
port(
	pi_clk_ext							: in std_logic;
	pi_rst_ext							: in std_logic;

	s00a_axis_tdata					: in std_logic_vector(g_data_width-1 downto 0);
	s00a_axis_tvalid					: in std_logic;
	s00a_axis_tready					: out std_logic;

	s00b_axis_tdata					: in std_logic_vector(g_data_width-1 downto 0);
	s00b_axis_tvalid					: in std_logic;
	s00b_axis_tready					: out std_logic;

	s00_ctrl_axis_tdata				: in std_logic_vector(g_ctrl_width-1 downto 0);
	s00_ctrl_axis_tlast				: in std_logic;
	s00_ctrl_axis_tvalid				: in std_logic;
	s00_ctrl_axis_tready				: out std_logic;

	m00_axis_tdata						: out std_logic_vector(g_data_width-1 downto 0);
	m00_axis_tvalid					: out std_logic;
	m00_axis_tready					: in std_logic
);
end core_wrapper;

architecture core_wrapper of core_wrapper is

	signal s_clk			: std_logic;
	signal s_rst			: std_logic;

	signal si_s00a_axis_tdata						: std_logic_vector(g_data_width-1 downto 0);
	signal si_s00a_axis_tvalid						: std_logic;
	signal so_s00a_axis_tready						: std_logic;
	signal si_s00b_axis_tdata						: std_logic_vector(g_data_width-1 downto 0);
	signal si_s00b_axis_tvalid						: std_logic;
	signal so_s00b_axis_tready						: std_logic;
	signal si_s00_ctrl_axis_tdata					: std_logic_vector(g_ctrl_width-1 downto 0);
	signal si_s00_ctrl_axis_tlast					: std_logic;
	signal si_s00_ctrl_axis_tvalid				: std_logic;
	signal so_s00_ctrl_axis_tready				: std_logic;
	signal so_m00_axis_tdata						: std_logic_vector(g_data_width-1 downto 0);
	signal so_m00_axis_tvalid						: std_logic;
	signal si_m00_axis_tready						: std_logic;

begin

	MY_PLL_INST: entity work.my_pll port map (
		pi_clk_ext		=> pi_clk_ext,		--: in std_logic;
		pi_rst_ext		=> pi_rst_ext,		--: in std_logic;
		po_clk			=> s_clk,			--: out std_logic;
		po_rst			=> s_rst				--: out std_logic;
	);


	CORE_INST: entity work.core generic map (
		g_sim								=> g_sim,								--: boolean := false;
		g_num_of_bram					=> g_num_of_bram,						--: natural := 1;
		g_lfsr							=> g_lfsr,								--: boolean := true;
		g_num_of_logic_registers	=> g_num_of_logic_registers,		--: natural := C_NUM_OF_REGISTERS;
		g_num_of_phys_registers		=> g_num_of_phys_registers,		--: natural := C_NUM_OF_ALL_REGISTERS;
		g_data_width					=> g_data_width,						--: natural := C_STD_DATA_WIDTH;
		g_addr_width					=> g_addr_width,						--: natural := C_STD_ADDR_WIDTH;
		g_ctrl_width					=> g_ctrl_width						--: natural := C_STD_CTRL_WIDTH
	)
	port map (
		pi_clk							=> s_clk,								--: in std_logic;
		pi_rst							=> s_rst,								--: in std_logic;
		s00a_axis_tdata				=> si_s00a_axis_tdata,				--: in std_logic_vector(g_data_width-1 downto 0);
		s00a_axis_tvalid				=> si_s00a_axis_tvalid,				--: in std_logic;
		s00a_axis_tready				=> so_s00a_axis_tready,				--: out std_logic;
		s00b_axis_tdata				=> si_s00b_axis_tdata,				--: in std_logic_vector(g_data_width-1 downto 0);
		s00b_axis_tvalid				=> si_s00b_axis_tvalid,				--: in std_logic;
		s00b_axis_tready				=> so_s00b_axis_tready,				--: out std_logic;
		s00_ctrl_axis_tdata			=> si_s00_ctrl_axis_tdata,			--: in std_logic_vector(g_ctrl_width-1 downto 0);
		s00_ctrl_axis_tlast			=> si_s00_ctrl_axis_tlast,			--: in std_logic;
		s00_ctrl_axis_tvalid			=> si_s00_ctrl_axis_tvalid,		--: in std_logic;
		s00_ctrl_axis_tready			=> so_s00_ctrl_axis_tready,		--: out std_logic;
		m00_axis_tdata					=> so_m00_axis_tdata,				--: out std_logic_vector(g_data_width-1 downto 0);
		m00_axis_tvalid				=> so_m00_axis_tvalid,				--: out std_logic;
		m00_axis_tready				=> si_m00_axis_tready				--: in std_logic
	);




	IN_OUT_REGS: process(s_clk)
	begin
		if(rising_edge(s_clk)) then

			si_s00a_axis_tdata		<= s00a_axis_tdata				;	--: in std_logic_vector(g_data_width-1 downto 0);
			si_s00a_axis_tvalid		<= s00a_axis_tvalid				;	--: in std_logic;
			s00a_axis_tready			<= so_s00a_axis_tready			;	--: out std_logic;
			si_s00b_axis_tdata		<= s00b_axis_tdata				;	--: in std_logic_vector(g_data_width-1 downto 0);
			si_s00b_axis_tvalid		<= s00b_axis_tvalid				;	--: in std_logic;
			s00b_axis_tready			<= so_s00b_axis_tready			;	--: out std_logic;
			si_s00_ctrl_axis_tdata	<= s00_ctrl_axis_tdata			;	--: in std_logic_vector(g_ctrl_width-1 downto 0);
			si_s00_ctrl_axis_tlast	<= s00_ctrl_axis_tlast			;	--: in std_logic;
			si_s00_ctrl_axis_tvalid	<= s00_ctrl_axis_tvalid			;	--: in std_logic;
			s00_ctrl_axis_tready		<= so_s00_ctrl_axis_tready		;	--: out std_logic;
			m00_axis_tdata				<= so_m00_axis_tdata				;	--: out std_logic_vector(g_data_width-1 downto 0);
			m00_axis_tvalid			<= so_m00_axis_tvalid			;	--: out std_logic;
			si_m00_axis_tready		<= m00_axis_tready				;	--: in std_logic;

		end if;
	end process;

end architecture;
