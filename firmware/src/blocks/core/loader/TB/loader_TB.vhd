-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    29/12/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    loader_TB
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.pro_pack.all;
use work.common_pack.all;

entity loader_TB is
end loader_TB;

architecture loader_TB of loader_TB is

	constant c_sim											: boolean := false;
	constant c_num_of_bram								: natural := 1;
	constant c_lfsr										: boolean := true;
	constant c_num_of_registers						: natural := C_NUM_OF_REGISTERS;
	constant c_data_width								: natural := C_STD_DATA_WIDTH;
	constant c_addr_width								: natural := C_STD_ADDR_WIDTH;
	constant c_ctrl_width								: natural := C_STD_CTRL_WIDTH;

	constant c_id_A										: natural := 10;
	constant c_id_B										: natural := 13;

	constant c_filepath									: string := "loader_test.bin";

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;

	signal r_cnt											: natural;

	signal s00a_axis_tdata								: std_logic_vector(c_data_width-1 downto 0);
	signal s00a_axis_tvalid								: std_logic;
	signal s00a_axis_tready								: std_logic;

	signal r_ctrl_ch_1									: std_logic_vector(c_ctrl_width-1 downto 0);
	signal s_ctrl_ch_1									: std_logic_vector(c_ctrl_width-1 downto 0);
	signal r_ctrl_ch_1_valid							: std_logic;
	signal s_ctrl_ch_1_valid							: std_logic;
	signal s_data_A										: std_logic_vector(c_data_width-1 downto 0);
	signal s_data_last_A									: std_logic;
	signal s_wr_en_A										: std_logic;
	signal s_ctrl_ch_2									: std_logic_vector(c_ctrl_width-1 downto 0);
	signal s_data_B										: std_logic_vector(c_data_width-1 downto 0);
	signal s_data_last_B									: std_logic;
	signal s_wr_B											: std_logic;

	signal s1												: std_logic_vector(c_addr_width-1 downto 0);
	signal s2												: std_logic_vector(c_addr_width-1 downto 0);
	signal s3												: std_logic_vector(c_addr_width-1 downto 0);
	signal s4												: std_logic_vector(c_addr_width-1 downto 0);




begin

	s1 <= to_lfsr(1, 9);
	s2 <= to_lfsr(2, 9);
	s3 <= to_lfsr(3, 9);
	s4 <= to_lfsr(4, 9);



	process
	begin
		r_clk <= '1';
		wait for 5ns;
		r_clk <= '0';
		wait for 5ns;
	end process;

	process
	begin
		r_rst <= '1';
		wait for 555ns;
		r_rst <= '0';
		wait;
	end process;


	BUS_A_FORCER_INST: entity work.forcer_data generic map (
		g_filepath						=> c_filepath,						--: string := "i.txt";
		g_data_width					=> c_data_width					--: natural := 64
	)
	port map (
		pi_clk							=> r_clk,							--: in std_logic;
		pi_rst							=> r_rst,							--: in std_logic;
		po_m00_tdata					=> s00a_axis_tdata,				--: out std_logic_vector(g_data_width-1 downto 0);
		po_m00_tvalid					=> s00a_axis_tvalid,				--: out std_logic;
		pi_m00_tready					=> s00a_axis_tready				--: in std_logic
	);



	LOADER_INST: entity work.loader_bay generic map (
		g_lfsr							=> c_lfsr,							--: boolean := false;
		g_addr_width					=> c_addr_width,					--: natural := 9;
		g_data_width					=> c_data_width,					--: natural := 64;
		g_ctrl_width					=> c_ctrl_width,					--: natural := 8;
		g_id_A							=> c_id_A,							--: natural := 10;
		g_id_B							=> c_id_B							--: natural := 11
	)
	port map (
		pi_clk							=> r_clk,							--: in std_logic;
		pi_rst							=> r_rst,							--: in std_logic;
		pi_ctrl_ch_1					=> r_ctrl_ch_1,					--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_ch_1_valid			=> r_ctrl_ch_1_valid,			--: in std_logic;
		pi_ctrl_ch_2					=> (others=>'0'),					--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_ch_2_valid			=> '0',								--: in std_logic;
		s00a_axis_tdata				=> s00a_axis_tdata,				--: in std_logic_vector(g_data_width-1 downto 0);
		s00a_axis_tvalid				=> s00a_axis_tvalid,				--: in std_logic;
		s00a_axis_tready				=> s00a_axis_tready,				--: out std_logic;
		s00b_axis_tdata				=> (others=>'0'),					--: in std_logic_vector(g_data_width-1 downto 0);
		s00b_axis_tvalid				=> '0',								--: in std_logic;
		s00b_axis_tready				=> open,								--: out std_logic;
		po_ctrl_ch_1					=> s_ctrl_ch_1,					--: out std_logic_vector(g_ctrl_width-1 downto 0);
		po_ctrl_ch_1_valid			=> s_ctrl_ch_1_valid,			--: out std_logic;
		po_data_A						=> s_data_A,						--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last_A					=> s_data_last_A,					--: out std_logic;
		po_wr_en_A						=> s_wr_en_A,						--: out std_logic;
		po_ctrl_ch_2					=> open,								--: out std_logic_vector(g_ctrl_width-1 downto 0);
		po_ctrl_ch_2_valid			=> open,								--: out std_logic;
		po_data_B						=> open,								--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last_B					=> open,								--: out std_logic;
		po_wr_en_B						=> open								--: out std_logic
	);


	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			-----------
			-- R_CNT --
			-----------
			if(r_rst = '1') then
				r_cnt <= 0;
			else

				r_cnt <= r_cnt + 1;

			end if;


			case r_cnt is
				when 8 => 			r_ctrl_ch_1 <= to_std_logic_vector(c_id_A, 8);			r_ctrl_ch_1_valid <= '1';
				when 48 => 			r_ctrl_ch_1 <= to_std_logic_vector(c_id_A, 8);			r_ctrl_ch_1_valid <= '1';
				when 88 => 			r_ctrl_ch_1 <= to_std_logic_vector(c_id_A, 8);			r_ctrl_ch_1_valid <= '1';
				when 128 => 		r_ctrl_ch_1 <= to_std_logic_vector(c_id_A, 8);			r_ctrl_ch_1_valid <= '1';
				when others =>		r_ctrl_ch_1 <= x"00";											r_ctrl_ch_1_valid <= '0';

			end case;

		end if;
	end process;



end architecture;
