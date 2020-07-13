-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    adder_ctrl
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

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

entity adder_ctrl is
generic (
	g_ctrl_width						: natural := 8;
	g_select_width						: natural := 4;
	g_id									: natural := 2
);
port(
	pi_clk								: in std_logic;

	pi_ctrl_ch_A						: in std_logic_vector(g_ctrl_width-1 downto 0);
	pi_ctrl_ch_B						: in std_logic_vector(g_ctrl_width-1 downto 0);
	pi_ctrl_valid_n					: in std_logic;

	po_select_A							: out std_logic_vector(g_select_width-1 downto 0);
	po_select_B							: out std_logic_vector(g_select_width-1 downto 0);
	po_start								: out std_logic;
	po_sub								: out std_logic
);
end adder_ctrl;

architecture adder_ctrl of adder_ctrl is

	signal s_id_ch_1_recognized						: std_logic;
	signal r_id_ch_1_recognized						: std_logic;
	signal s_id_ch_2_recognized						: std_logic;
	signal r_id_ch_2_recognized						: std_logic;
	signal s_sub_stream									: std_logic;
	signal r_sub_stream									: std_logic;
	signal r_sub											: std_logic;

	signal r_start											: std_logic;

	signal s_select_A										: std_logic_vector(g_select_width-1 downto 0);
	signal r_select_A										: std_logic_vector(g_select_width-1 downto 0);
	signal s_select_B										: std_logic_vector(g_select_width-1 downto 0);
	signal r_select_B										: std_logic_vector(g_select_width-1 downto 0);

begin

	po_select_A <= r_select_A;
	po_select_B <= r_select_B;
	po_start <= r_start;
	po_sub <= r_sub;

	s_id_ch_1_recognized <= '1' when pi_ctrl_ch_A(C_STD_ID_ADDR_HI downto C_STD_ID_ADDR_LO) = to_std_logic_vector(g_id, C_STD_ID_SIZE) else '0';
	s_id_ch_2_recognized <= '1' when pi_ctrl_ch_B(C_STD_ID_ADDR_HI downto C_STD_ID_ADDR_LO) = to_std_logic_vector(g_id, C_STD_ID_SIZE) else '0';

	s_sub_stream <= pi_ctrl_ch_A(C_STD_ADD_SUB_ADDR);

	s_select_A <= pi_ctrl_ch_A(C_STD_REG_SELECT_ADDR+g_select_width-1 downto C_STD_REG_SELECT_ADDR);
	s_select_B <= pi_ctrl_ch_B(C_STD_REG_SELECT_ADDR+g_select_width-1 downto C_STD_REG_SELECT_ADDR);

	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			------------
			-- STREAM --
			------------
			r_sub_stream <= s_sub_stream;


			--------------------------
			-- R_ID_CH_1_RECOGNIZED --
			--------------------------
			if(pi_ctrl_valid_n = '1') then
				r_id_ch_1_recognized <= '0';
			else
				r_id_ch_1_recognized <= s_id_ch_1_recognized;
			end if;


			--------------------------
			-- R_ID_CH_2_RECOGNIZED --
			--------------------------
			if(pi_ctrl_valid_n = '1') then
				r_id_ch_2_recognized <= '0';
			else
				r_id_ch_2_recognized <= s_id_ch_2_recognized;
			end if;


			-----------------
			-- PO_SELECT_A --
			-----------------
			if(r_id_ch_1_recognized = '1') then
				r_select_A <= s_select_A;
			end if;


			-----------------
			-- PO_SELECT_B --
			-----------------
			if(r_id_ch_2_recognized = '1') then
				r_select_B <= s_select_B;
			end if;


			-------------
			-- R_START --
			-------------
			r_start <= r_id_ch_2_recognized;


			-----------
			-- R_ADD --
			-----------
			if(r_id_ch_1_recognized = '1') then
				r_sub <= r_sub_stream;
			end if;


		end if;
	end process;

end architecture;
