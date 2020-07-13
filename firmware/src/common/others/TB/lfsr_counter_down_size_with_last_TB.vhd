
library IEEE;
use IEEE.std_logic_1164.all;

use work.my_pack.all;
use work.common_pack.all;

entity lfsr_counter_down_size_with_last_TB is
end lfsr_counter_down_size_with_last_TB;

architecture lfsr_counter_down_size_with_last_TB of lfsr_counter_down_size_with_last_TB is

	constant c_lfsr										: boolean := true;
	constant c_n											: natural := 9;

	constant c_delay_min									: natural := 10;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;

	signal r_load											: std_logic;
	signal r_change										: std_logic;
	signal s_data											: std_logic_vector(c_n-1 downto 0);
	signal s_last											: std_logic_vector(4 downto 0);

	signal s_size_out										: std_logic;
	signal s_last_out										: std_logic_vector(2 downto 0);

	signal r_cnt											: natural;

	signal r_delay											: natural;

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
		wait for 555ns;
		r_rst <= '0';
		wait;
	end process;


	LFSR_COUNTER_DOWN_SIZE_WITH_LAST_INST: entity work.lfsr_counter_down_size_with_last generic map (
		g_lfsr					=> c_lfsr,						--: boolean := false;
		g_n						=> c_n							--: natural := 9
	)
	port map (
		pi_clk					=> r_clk,						--: in std_logic;
		pi_rst					=> r_rst,						--: in std_logic;
		pi_load					=> r_load,						--: in std_logic;
		pi_data_minus_two		=> s_data,						--: in std_logic_vector(g_n-1 downto 0);
		pi_last					=> s_last,						--: in std_logic_vector(4 downto 0);
		pi_change				=> r_change,					--: in std_logic;
		po_size					=> s_size_out,					--: out std_logic;
		po_last					=> s_last_out					--: out std_logic_vector(2 downto 0)
	);

	LFSR_GEN: if(c_lfsr = true) generate
		s_data <= to_lfsr(r_cnt-2, c_n);
	end generate;

	REG_GEN: if(c_lfsr = false) generate
		s_data <= to_std_logic_vector(r_cnt-2, c_n);
	end generate;


	SI_LAST_GEN: for i in 0 to 4 generate
		s_last(i) <=	'1' when r_cnt = i+1 else
							'0';
	end generate;


	process(r_clk)
	begin
		if(r_clk'event and r_clk = '1') then

			r_load <= '0';

			if(r_rst = '1') then
				r_delay <= c_delay_min;
				r_cnt <= 1;
			else

				r_delay <= r_delay - 1;

				if(r_delay = c_delay_min + r_cnt - 2) then
					r_load <= '1';
				elsif(r_delay = 0) then
					r_cnt <= r_cnt + 1;
					r_delay <= c_delay_min + r_cnt + 1;
				end if;

			end if;


			if(r_rst = '1') then
				r_change <= '0';
			else
				if(r_load = '1') then
					r_change <= '1';
				elsif(s_last_out(0) = '1') then
					r_change <= '0';
				end if;
			end if;

		end if;
	end process;

end lfsr_counter_down_size_with_last_TB;
