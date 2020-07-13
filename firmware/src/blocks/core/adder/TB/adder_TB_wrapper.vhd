-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    adder_TB_wrapper
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

entity adder_TB_wrapper is
generic (
	g_data_width						: natural := 64;
	g_addr_width						: natural := 9;
	g_ctrl_width						: natural := 8;
	g_select_width						: natural := 5;
	g_id									: natural := 2
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_ctrl_ch_A						: in std_logic_vector(C_STD_CTRL_WIDTH-1 downto 0);
	pi_ctrl_ch_B						: in std_logic_vector(C_STD_CTRL_WIDTH-1 downto 0);
	pi_ctrl_valid_n					: in std_logic;



	pi_data_0										: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_1										: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_2										: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_3										: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_4										: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_5										: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_6										: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_7										: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_8										: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_9										: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_10										: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_11										: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_12										: in std_logic_vector(g_data_width-1 downto 0);

	pi_data_last						: in std_logic;
	pi_data_wr_en						: in std_logic;

	po_data_up							: out std_logic_vector(g_data_width-1 downto 0);
	po_data_lo							: out std_logic_vector(g_data_width-1 downto 0);
	po_data_last						: out std_logic;
	po_data_wr_en						: out std_logic;
	po_data_all_ones					: out std_logic;
	po_data_zero						: out std_logic_vector(1 downto 0)
);
end adder_TB_wrapper;

architecture adder_TB_wrapper of adder_TB_wrapper is

	signal s_data								: t_data_x1;

begin

	s_data(0)				<= pi_data_0		;
	s_data(1)				<= pi_data_1		;
	s_data(2)				<= pi_data_2		;
	s_data(3)				<= pi_data_3		;
	s_data(4)				<= pi_data_4		;
	s_data(5)				<= pi_data_5		;
	s_data(6)				<= pi_data_6		;
	s_data(7)				<= pi_data_7		;
	s_data(8)				<= pi_data_8		;
	s_data(9)				<= pi_data_9		;
	s_data(10)				<= pi_data_10		;
	s_data(11)				<= pi_data_11		;
	s_data(12)				<= pi_data_12		;






	ADDER_INST: entity work.adder generic map (
		g_data_width				=> g_data_width,					--: natural := 64;
		g_addr_width				=> g_addr_width,					--: natural := 9;
		g_ctrl_width				=> g_ctrl_width,					--: natural := 8;
		g_select_width				=> g_select_width,				--: natural := 4;
		g_id							=> g_id								--: natural := 2
	)
	port map (
		pi_clk						=> pi_clk,							--: in std_logic;
		pi_rst						=> pi_rst,							--: in std_logic;
		pi_ctrl_ch_A				=> pi_ctrl_ch_A,					--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_ch_B				=> pi_ctrl_ch_B,					--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_valid_n			=> pi_ctrl_valid_n,				--: in std_logic;
		pi_data						=> s_data,							--: in t_data_x1;
		pi_data_last				=> pi_data_last,					--: in std_logic;
		pi_data_wr_en				=> pi_data_wr_en,					--: in std_logic;
		po_data_up					=> po_data_up,						--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_lo					=> po_data_lo,						--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last				=> po_data_last,					--: out std_logic;
		po_data_wr_en				=> po_data_wr_en,					--: out std_logic;
		po_data_all_ones			=> po_data_all_ones,				--: out std_logic;
		po_data_zero				=> po_data_zero					--: out std_logic_vector(1 downto 0);
	);


end architecture;
