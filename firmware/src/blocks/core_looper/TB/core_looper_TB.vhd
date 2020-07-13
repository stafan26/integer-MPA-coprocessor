-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    29/12/2017
-- Project Name:   MPALU
-- Design Name:    core_looper
-- Module Name:    core_looper_TB
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.pro_pack.all;
use work.common_pack.all;

entity core_looper_TB is
end core_looper_TB;

architecture core_looper_TB of core_looper_TB is

	constant c_sim											: boolean := true;
	constant c_num_of_bram								: natural := 1;
	constant c_lfsr										: boolean := false;
	constant c_num_of_registers						: natural := C_NUM_OF_REGISTERS;
	constant c_data_width								: natural := C_STD_DATA_WIDTH;
	constant c_addr_width								: natural := C_STD_ADDR_WIDTH;
	constant c_ctrl_width								: natural := C_STD_CTRL_WIDTH;

	constant c_bus_A_filepath							: string := "busA.bin";

	signal r_clk_ext										: std_logic;
	signal r_rst_ext										: std_logic;

	signal s_clk											: std_logic;
	signal s_rst											: std_logic;
	signal r_rst											: std_logic_vector(9 downto 0);

	signal s00a_axis_tdata								: std_logic_vector(c_data_width-1 downto 0);
	signal s00a_axis_tvalid								: std_logic;
	signal s00a_axis_tready								: std_logic;

	signal s00_ctrl_axis_tdata							: std_logic_vector(c_ctrl_width-1 downto 0);
	signal s00_ctrl_axis_tlast							: std_logic;
	signal s00_ctrl_axis_tvalid						: std_logic;
	signal s00_ctrl_axis_tready						: std_logic;

	signal m00_axis_tdata								: std_logic_vector(c_data_width-1 downto 0);
	signal m00_axis_tvalid								: std_logic;
	signal m00_axis_tready								: std_logic;

begin

	m00_axis_tready <= '1';

	process
	begin
		r_clk_ext <= '1';
		wait for 5ns;
		r_clk_ext <= '0';
		wait for 5ns;
	end process;

	process
	begin
		r_rst_ext <= '1';
		wait for 500ns;
		r_rst_ext <= '0';
		wait;
	end process;


	BUS_A_FORCER_INST: entity work.forcer_data generic map (
		g_filepath						=> c_bus_A_filepath,				--: string := "i.txt";
		g_data_width					=> c_data_width					--: natural := 64
	)
	port map (
		pi_clk							=> s_clk,							--: in std_logic;
		pi_rst							=> r_rst(r_rst'length-1),		--: in std_logic;
		po_m00_tdata					=> s00a_axis_tdata,				--: out std_logic_vector(g_data_width-1 downto 0);
		po_m00_tvalid					=> s00a_axis_tvalid,				--: out std_logic;
		pi_m00_tready					=> s00a_axis_tready				--: in std_logic
	);




	process(s_clk)
	begin
		if(rising_edge(s_clk)) then

			-----------
			-- R_RST --
			-----------
			r_rst <= r_rst(r_rst'length-2 downto 0) & s_rst;

		end if;
	end process;




	CORE_INST: entity work.core generic map (
		g_sim							=> c_sim,								--: boolean := false;
		g_num_of_bram				=> c_num_of_bram,						--: natural := 1;
		g_lfsr						=> c_lfsr,								--: boolean := true;
		g_num_of_registers		=> c_num_of_registers,				--: natural := C_NUM_OF_REGISTERS;
		g_data_width				=> c_data_width,						--: natural := C_STD_DATA_WIDTH;
		g_addr_width				=> c_addr_width,						--: natural := C_STD_ADDR_WIDTH;
		g_ctrl_width				=> c_ctrl_width						--: natural := C_STD_CTRL_WIDTH
	)
	port map (
		pi_clk						=> s_clk,								--: in std_logic;
		pi_rst						=> s_rst,								--: in std_logic;
		s00a_axis_tdata			=> s00a_axis_tdata,					--: in std_logic_vector(g_data_width-1 downto 0);
		s00a_axis_tvalid			=> s00a_axis_tvalid,					--: in std_logic;
		s00a_axis_tready			=> s00a_axis_tready,					--: out std_logic;
		s00b_axis_tdata			=> (others=>'0'),						--: in std_logic_vector(g_data_width-1 downto 0);
		s00b_axis_tvalid			=> '0',									--: in std_logic;
		s00b_axis_tready			=> open,									--: out std_logic;
		s00_ctrl_axis_tdata		=> s00_ctrl_axis_tdata,				--: in std_logic_vector(g_ctrl_width-1 downto 0);
		s00_ctrl_axis_tlast		=> s00_ctrl_axis_tlast,				--: in std_logic;
		s00_ctrl_axis_tvalid		=> s00_ctrl_axis_tvalid,			--: in std_logic;
		s00_ctrl_axis_tready		=> s00_ctrl_axis_tready,			--: out std_logic;
		m00_axis_tdata				=> m00_axis_tdata,					--: out std_logic_vector(g_data_width-1 downto 0);
		m00_axis_tvalid			=> m00_axis_tvalid,					--: out std_logic;
		m00_axis_tready			=> m00_axis_tready					--: in std_logic
	);


	PROG_LOADER_INST: entity work.prog_loader port map (
		pi_clk						=> s_clk,								--: in std_logic;
		pi_rst						=> r_rst(r_rst'length-1),			--: in std_logic;
		s00_ctrl_axis_tdata		=> s00_ctrl_axis_tdata,				--: out std_logic_vector(g_ctrl_width-1 downto 0);
		s00_ctrl_axis_tlast		=> s00_ctrl_axis_tlast,				--: out std_logic;
		s00_ctrl_axis_tvalid		=> s00_ctrl_axis_tvalid,			--: out std_logic;
		s00_ctrl_axis_tready		=> s00_ctrl_axis_tready				--: in std_logic;
	);

end architecture;
