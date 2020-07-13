-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    29/12/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    lfsr_counter_down_3_last_2_cas_TB
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.pro_pack.all;
use work.common_pack.all;

entity lfsr_counter_down_3_last_2_cas_TB is generic (
	g_data_dir_path		: string
);
end lfsr_counter_down_3_last_2_cas_TB;

architecture lfsr_counter_down_3_last_2_cas_TB of lfsr_counter_down_3_last_2_cas_TB is

	constant c_lfsr										: boolean := false;
	constant c_n											: natural := 9;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;

	signal r_first											: std_logic;

	signal r_cnt											: natural;

	signal r_load											: std_logic;
	signal r_data											: std_logic_vector(c_n-1 downto 0);
	signal r_last											: std_logic_vector(2 downto 0);
	signal r_cascade_last								: std_logic := '0';
	signal r_cascade_last_vec							: std_logic_vector(c_n/C_MAX_NUM_OF_IN_PER_MUX-1 downto 0) := (others=>'0');
	signal r_change										: std_logic;
	signal s_last											: std_logic;
	signal s_last_but_one								: std_logic;

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


	LFSR_COUNTER_DOWN_3_LAST_2_CAS_INST: entity work.lfsr_counter_down_3_last_2_cas generic map (
		g_lfsr					=> c_lfsr,					--: boolean := false;
		g_n						=> c_n						--: natural := 9
	)
	port map (
		pi_clk					=> r_clk,					--: in std_logic;
		pi_rst					=> r_rst,					--: in std_logic;
		pi_load					=> r_load,					--: in std_logic;
		pi_data					=> r_data,					--: in std_logic_vector(g_n-1 downto 0);
		pi_last					=> r_last,					--: in std_logic_vector(2 downto 0);
		pi_cascade_last		=> r_cascade_last,		--: in std_logic := '0';
		pi_cascade_last_vec	=> r_cascade_last_vec,	--: in std_logic_vector(g_n/C_MAX_NUM_OF_IN_PER_MUX-1 downto 0) := (others=>'0');
		pi_change				=> r_change,				--: in std_logic;
		po_last					=> s_last,					--: out std_logic;
		po_last_but_one		=> s_last_but_one			--: out std_logic
	);


	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			r_load <= '0';

			if(r_rst = '1') then
				r_cnt <= 10;
				r_data <= (others=>'0');
				r_last <= (0=>'1',others=>'0');
				r_cascade_last <= '0';
				r_cascade_last_vec <= (others=>'0');
				r_change <= '0';
				r_first <= '1';
			else

				if(r_cnt /= 0) then
					r_cnt <= r_cnt - 1;
				end if;


				if(r_cnt = 1) then
					r_change <= '1';
					r_load <= '1';
					r_first <= '0';
				elsif(s_last = '1') then
					r_change <= '0';
					r_cnt <= 10;
				end if;



				if(r_first = '0' and r_cnt = 9) then
					r_data <= r_data + 1;
					r_last <= r_last(r_last'length-2 downto 0) & '0';
					r_cascade_last <= r_last(r_last'length-1);
					if(r_cascade_last = '1') then
						r_cascade_last_vec <= (others=>'1');
					else
						r_cascade_last_vec <= (others=>'0');
					end if;

				end if;
			end if;

		end if;
	end process;

end architecture;
