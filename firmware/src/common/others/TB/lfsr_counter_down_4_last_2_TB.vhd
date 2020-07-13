
library IEEE;
use IEEE.std_logic_1164.all;

use work.my_pack.all;
use work.common_pack.all;

entity lfsr_counter_down_4_last_2_TB is
end lfsr_counter_down_4_last_2_TB;

architecture lfsr_counter_down_4_last_2_TB of lfsr_counter_down_4_last_2_TB is

	constant c_lfsr										: boolean := true;
	constant c_n											: natural := 9;
	constant c_last_width								: natural := 4;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;

	signal r_load											: std_logic;
	signal r_change										: std_logic;
	signal si_last											: std_logic_vector(c_last_width-1 downto 0);
	signal s_last_but_one								: std_logic;
	signal s_last											: std_logic;

	signal r_data											: std_logic_vector(c_n-1 downto 0);
	signal r_data_init									: std_logic_vector(c_n-1 downto 0);
	signal r_data_init_preload							: std_logic;
	signal r_cnt											: natural;

	signal r_delay											: natural;
	signal r_delay_on										: std_logic;

	signal s_one											: natural;
	signal s_two											: natural;
	signal s_three											: natural;
	signal s_four											: natural;
	signal s_five											: natural;

begin

	s_one <= to_lfsr(1, c_n);
	s_two <= to_lfsr(2, c_n);
	s_three <= to_lfsr(3, c_n);
	s_four <= to_lfsr(4, c_n);
	s_five <= to_lfsr(5, c_n);

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


	LFSR_COUNTER_DOWN_LAST_INST: entity work.lfsr_counter_down_4_last_2 generic map (
		g_lfsr				=> c_lfsr,					--: boolean := false;
		g_n					=> c_n						--: natural := 16;
	)
	port map (
		pi_clk				=> r_clk,					--: in std_logic;
		pi_rst				=> r_rst,					--: in std_logic;
		pi_load				=> r_load,					--: in std_logic;
		pi_data				=> r_data,					--: in std_logic_vector(g_n-1 downto 0);
		pi_last				=> si_last,					--: in std_logic_vector(4 downto 0);
		pi_change			=> r_change,				--: in std_logic;
		po_last_but_one	=> s_last_but_one,		--: out std_logic
		po_last				=> s_last					--: out std_logic
	);


	SI_LAST_GEN: for i in 0 to c_last_width-1 generate
		si_last(i) <=	'1' when r_data = i+1 and c_lfsr = false else
							'1' when r_data = 2**(i+1) and c_lfsr = true else
							'0';
	end generate;


	process(r_clk)
	begin
		if(r_clk'event and r_clk = '1') then

			r_load <= '0';

			if(r_rst = '1') then
				r_change <= '0';
				r_data_init <= (0=>'1',others=>'0');
				r_data_init_preload <= '1';
				r_delay_on <= '0';
				r_change <= '0';
			else

				r_data_init_preload <= '0';

				if(r_data_init_preload = '1') then
					r_data_init <= r_data_init + 1;
					r_load <= '1';
					r_change <= '1';
				end if;

				if(r_data_init_preload = '1' and c_lfsr = true) then
					r_data <= to_lfsr(to_natural(r_data_init), c_n);
				elsif(r_data_init_preload = '1' and c_lfsr = false) then
					r_data <= r_data_init;
				end if;

				if(s_last = '1') then
					r_delay_on <= '1';
				elsif(r_delay = 10) then
					r_delay_on <= '0';
					r_delay <= 0;
					r_data_init_preload <= '1';
				elsif(r_delay_on = '1') then
					r_delay <= r_delay + 1;
				end if;

			end if;
		end if;
	end process;

end lfsr_counter_down_4_last_2_TB;
