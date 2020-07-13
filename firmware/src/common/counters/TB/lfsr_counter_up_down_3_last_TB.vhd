-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    29/12/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    lfsr_counter_up_down_3_last_TB
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.pro_pack.all;
use work.common_pack.all;

entity lfsr_counter_up_down_3_last_TB is generic (
	g_data_dir_path		: string
);
end lfsr_counter_up_down_3_last_TB;

architecture lfsr_counter_up_down_3_last_TB of lfsr_counter_up_down_3_last_TB is

	constant c_lfsr										: boolean := false;
	constant c_n											: natural := 9;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;

	signal r_cnt											: natural;

	signal r_change_en									: std_logic;
	signal r_change_up									: std_logic;
	signal r_change_down_n								: std_logic;

	signal s_data											: std_logic_vector(c_n-1 downto 0);
	signal s_data_last									: std_logic_vector(2 downto 0);
	signal s_cascade_last								: std_logic := '0';
	signal s_cascade_last_vec							: std_logic_vector(c_n/C_MAX_NUM_OF_IN_PER_MUX-1 downto 0) := (others=>'0');

begin

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
		wait for 200ns;
		r_rst <= '0';
		wait;
	end process;


	LFSR_COUNTER_UP_DOWN_3_LAST_INST: entity work.lfsr_counter_up_down_3_last generic map (
		g_lfsr						=> c_lfsr,								--: boolean := false;
		g_n							=> c_n									--: natural := 16
	)
	port map (
		pi_clk						=> r_clk,								--: in std_logic;
		pi_rst						=> r_rst,								--: in std_logic;
		pi_change_en				=> r_change_en,						--: in std_logic;
		pi_change_up				=> r_change_up,						--: in std_logic;
		pi_change_down_n			=> r_change_down_n,					--: in std_logic;
		pi_change_down_n_last	=> '0',									--: in std_logic;
		po_data						=> s_data,								--: out std_logic_vector(g_n-1 downto 0);
		po_data_last				=> s_data_last,						--: out std_logic_vector(2 downto 0);
		po_cascade_last			=> s_cascade_last,					--: out std_logic := '0';
		po_cascade_last_vec		=> s_cascade_last_vec				--: out std_logic_vector(g_n/C_MAX_NUM_OF_IN_PER_MUX-1 downto 0) := (others=>'0')
	);


	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			if(r_rst = '1') then
				r_change_en <= '0';
				r_change_up <= '1';
				r_change_down_n <= '1';
				r_cnt <= 0;
			else

				r_cnt <= r_cnt + 1;

				if(r_cnt = 5) then
					r_change_en <= '1';
				elsif(r_cnt = 10) then
					r_change_up <= '0';
				elsif(r_cnt = 15) then
					r_change_down_n <= '0';
				elsif(r_cnt = 20) then
					r_change_en <= '0';
				end if;
			end if;

		end if;
	end process;



end architecture;
