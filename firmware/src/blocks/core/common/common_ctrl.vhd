-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    common_ctrl
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

entity common_ctrl is
generic (
	g_id									: natural := 10;
	g_ctrl_width						: natural := 8;
	g_select_width						: natural := 4
);
port(
	pi_clk								: in std_logic;

	pi_ctrl								: in std_logic_vector(g_ctrl_width-1 downto 0);
	pi_ctrl_valid_n					: in std_logic;

	po_start								: out std_logic;
	po_select							: out std_logic_vector(g_select_width-1 downto 0)
);
end common_ctrl;

architecture common_ctrl of common_ctrl is

	constant c_cnt_start_delay							: natural := 1;

	signal s_select_stream								: std_logic_vector(g_select_width-1 downto 0);

	signal r_start											: std_logic;
	signal r_select										: std_logic_vector(g_select_width-1 downto 0);

	signal r_id_recognized								: std_logic;

begin

	po_start <= r_start;
	po_select <= r_select;


	SELECT_STREAM_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width		=> g_select_width,					--: natural := 64;
		g_delay				=> 1										--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,								--: in std_logic;
		pi_data				=> pi_ctrl(C_STD_REG_SELECT_ADDR+g_select_width-1 downto C_STD_REG_SELECT_ADDR),				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data				=> s_select_stream					--: out std_logic_vector(g_data_width-1 downto 0)
	);


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			----------------------------
			-- R_CTRL_CH_1_RECOGNIZED --
			----------------------------
			if(pi_ctrl_valid_n = '1') then
				r_id_recognized <= '0';
			else

				if(pi_ctrl(C_STD_ID_ADDR_HI downto C_STD_ID_ADDR_LO) = to_std_logic_vector(g_id, C_STD_ID_SIZE)) then
					r_id_recognized <= '1';
				else
					r_id_recognized <= '0';
				end if;

			end if;


			r_start <= r_id_recognized;
			--------------
			-- R_SELECT --
			--------------
			if(r_id_recognized = '1') then
				r_select <= s_select_stream;
			end if;

		end if;
	end process;

end architecture;
