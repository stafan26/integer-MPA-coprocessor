-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    29/12/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_size_converter_TB
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.common_pack.all;

entity cpu_cmc_size_converter_TB is
end cpu_cmc_size_converter_TB;

architecture cpu_cmc_size_converter_TB of cpu_cmc_size_converter_TB is

	constant c_lfsr										: boolean := true;
	constant c_addr_width								: natural := 9;

	constant c_my_size_cnt_lo							: natural := 1;
	constant c_my_size_cnt_hi							: natural := 8;
	constant c_other_size_cnt_lo						: natural := 1;
	constant c_other_size_cnt_hi						: natural := 8;

	signal s_delay											: natural;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;

	signal r_end											: std_logic := '0';

	signal r_my_size_cnt									: natural;
	signal r_other_size_cnt								: natural;

	signal r_delay											: natural;
	signal r_delay_sp										: natural;

	signal r_start											: std_logic;
	signal r_my_size_minus_two							: std_logic_vector(c_addr_width-1 downto 0);
	signal s_my_last										: std_logic_vector(4 downto 0);
	signal r_other_size_minus_two						: std_logic_vector(c_addr_width-1 downto 0);
	signal s_other_last									: std_logic_vector(4 downto 0);
	signal r_taken											: std_logic;
	signal s_sm_size										: std_logic;
	signal s_sm_last										: std_logic_vector(2 downto 0);
	signal s_sm_last_ish									: std_logic;
	signal s_gr_size										: std_logic;
	signal s_gr_last										: std_logic_vector(2 downto 0);

	signal r_stobe_on										: std_logic;

	-----------------------
	-- REFERENCE SIGNALS --
	-----------------------
	signal r_start_dly									: std_logic;

	signal r_correct										: std_logic;

	signal r_sm_size_ref									: std_logic;
	signal r_gr_size_ref									: std_logic;

	signal r_sm_last_ish_ref							: std_logic;
	signal r_sm_last_ref									: std_logic_vector(2 downto 0);
	signal r_gr_last_ref									: std_logic_vector(2 downto 0);

	signal r_my_size_cnt_ref							: natural;
	signal r_other_size_cnt_ref						: natural;

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


	s_delay <= (2 * (r_my_size_cnt+1) * (r_other_size_cnt+1)) + 10;


	CPU_CMC_SIZE_CONVERTER_INST: entity work.cpu_cmc_mult_size_converter generic map (
		g_lfsr						=> c_lfsr,									--: boolean := true;
		g_addr_width				=> c_addr_width							--: natural := 10
	)
	port map (
		pi_clk						=> r_clk,									--: in std_logic;
		pi_rst						=> r_rst,									--: in std_logic;
		pi_start						=> r_start,									--: in std_logic;
		pi_my_size_minus_two		=> r_my_size_minus_two,					--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_my_last					=> s_my_last,								--: in std_logic_vector(4 downto 0);
		pi_other_size_minus_two	=> r_other_size_minus_two,				--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_other_last				=> s_other_last,							--: in std_logic_vector(4 downto 0);
		pi_taken						=> r_taken,									--: in std_logic;
		po_sm_size					=> s_sm_size,								--: out std_logic;
		po_sm_last					=> s_sm_last,								--: out std_logic_vector(2 downto 0);
		po_sm_last_ish				=> s_sm_last_ish,							--: out std_logic;
		po_gr_size					=> s_gr_size,								--: out std_logic;
		po_gr_last					=> s_gr_last								--: out std_logic_vector(2 downto 0)
	);


	s_my_last <=		"00001" when r_my_size_cnt = 1 else
							"00010" when r_my_size_cnt = 2 else
							"00100" when r_my_size_cnt = 3 else
							"01000" when r_my_size_cnt = 4 else
							"10000" when r_my_size_cnt = 5 else
							"00000";


	s_other_last <=	"00001" when r_other_size_cnt = 1 else
							"00010" when r_other_size_cnt = 2 else
							"00100" when r_other_size_cnt = 3 else
							"01000" when r_other_size_cnt = 4 else
							"10000" when r_other_size_cnt = 5 else
							"00000";


	LFSR_TRUE_GEN: if(c_lfsr = true) generate
		r_my_size_minus_two <= to_lfsr(r_my_size_cnt-2, r_my_size_minus_two'length);
		r_other_size_minus_two <= to_lfsr(r_other_size_cnt-2, r_other_size_minus_two'length);
	end generate;

	LFSR_FALSE_GEN: if(c_lfsr = false) generate
		r_my_size_minus_two <= to_std_logic_vector(r_my_size_cnt-2, r_my_size_minus_two'length);
		r_other_size_minus_two <= to_std_logic_vector(r_other_size_cnt-2, r_other_size_minus_two'length);
	end generate;


	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			r_start <= '0';

			if(r_rst = '1' or r_end = '1') then
				r_my_size_cnt <= c_my_size_cnt_lo;
				r_other_size_cnt <= c_other_size_cnt_lo;
				r_delay <= s_delay;
				r_delay_sp <= s_delay;
				r_stobe_on <= '0';
				r_taken <= '0';
			else

				r_delay <= r_delay - 1;

				if(r_delay = 0) then
					if(r_my_size_cnt < c_my_size_cnt_hi) then
						r_my_size_cnt <= r_my_size_cnt + 1;
					else
						r_my_size_cnt <= c_my_size_cnt_lo;
						if(r_other_size_cnt < c_other_size_cnt_hi) then
							r_other_size_cnt <= r_other_size_cnt + 1;
						else
							r_end <= '1';
						end if;
					end if;
					r_delay <= s_delay;
					r_delay_sp <= s_delay;
				elsif(r_delay = 2) then
					r_stobe_on <= '0';
				elsif(r_delay = r_delay_sp-2) then
					r_start <= '1';
				elsif(r_delay = r_delay_sp-4) then
					r_stobe_on <= '1';
				end if;

				if(r_stobe_on = '1') then
					r_taken <= not r_taken;
				else
					r_taken <= '0';
				end if;

			end if;

		end if;
	end process;


	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			---------------
			-- R_SM_SIZE --
			---------------
			if(r_rst = '1') then
				r_sm_size_ref <= '0';
				r_gr_size_ref <= '0';
				r_sm_last_ish_ref <= '0';
				r_sm_last_ref <= (others=>'0');
				r_gr_last_ref <= (others=>'0');
			else

				r_start_dly <= r_start;


				if(r_start = '1') then
					r_my_size_cnt_ref <= r_my_size_cnt;
					r_other_size_cnt_ref <= r_other_size_cnt;

				elsif(r_start_dly = '1') then
					r_sm_size_ref <= '1';
					r_gr_size_ref <= '1';

					if(r_my_size_cnt < r_other_size_cnt) then
						if(r_my_size_cnt_ref = 3) then
							r_sm_last_ref <= "100";
							r_sm_last_ish_ref <= '0';
						elsif(r_my_size_cnt_ref = 2) then
							r_sm_last_ref <= "010";
							r_sm_last_ish_ref <= '1';
						elsif(r_my_size_cnt_ref = 1) then
							r_sm_last_ref <= "001";
							r_sm_last_ish_ref <= '1';
						else
							r_sm_last_ref <= "000";
							r_sm_last_ish_ref <= '0';
						end if;

						if(r_other_size_cnt_ref = 3) then
							r_gr_last_ref <= "100";
						elsif(r_other_size_cnt_ref = 2) then
							r_gr_last_ref <= "010";
						elsif(r_other_size_cnt_ref = 1) then
							r_gr_last_ref <= "001";
						else
							r_gr_last_ref <= "000";
						end if;

					else
						if(r_other_size_cnt_ref = 3) then
							r_sm_last_ref <= "100";
							r_sm_last_ish_ref <= '0';
						elsif(r_other_size_cnt_ref = 2) then
							r_sm_last_ref <= "010";
							r_sm_last_ish_ref <= '1';
						elsif(r_other_size_cnt_ref = 1) then
							r_sm_last_ref <= "001";
							r_sm_last_ish_ref <= '1';
						else
							r_sm_last_ref <= "000";
							r_sm_last_ish_ref <= '0';
						end if;

						if(r_my_size_cnt_ref = 3) then
							r_gr_last_ref <= "100";
						elsif(r_my_size_cnt_ref = 2) then
							r_gr_last_ref <= "010";
						elsif(r_my_size_cnt_ref = 1) then
							r_gr_last_ref <= "001";
						else
							r_gr_last_ref <= "000";
						end if;

					end if;


				elsif(r_taken = '1') then

					if(r_my_size_cnt < r_other_size_cnt) then
						if(r_my_size_cnt_ref = 1) then
							r_sm_size_ref <= '0';
							r_sm_last_ref <= "000";
							r_sm_last_ish_ref <= '0';
						else
							r_my_size_cnt_ref <= r_my_size_cnt_ref - 1;
							if(r_my_size_cnt_ref = 4) then
								r_sm_last_ref <= "100";
								r_sm_last_ish_ref <= '0';
							elsif(r_my_size_cnt_ref = 3) then
								r_sm_last_ref <= "010";
								r_sm_last_ish_ref <= '1';
							elsif(r_my_size_cnt_ref = 2) then
								r_sm_last_ref <= "001";
								r_sm_last_ish_ref <= '1';
							else
								r_sm_last_ref <= "000";
								r_sm_last_ish_ref <= '0';
							end if;
						end if;

						if(r_other_size_cnt_ref = 1) then
							r_gr_size_ref <= '0';
							r_gr_last_ref <= "000";
						else
							r_other_size_cnt_ref <= r_other_size_cnt_ref - 1;
							if(r_other_size_cnt_ref = 4) then
								r_gr_last_ref <= "100";
							elsif(r_other_size_cnt_ref = 3) then
								r_gr_last_ref <= "010";
							elsif(r_other_size_cnt_ref = 2) then
								r_gr_last_ref <= "001";
							else
								r_gr_last_ref <= "000";
							end if;
						end if;
					else
						if(r_other_size_cnt_ref = 1) then
							r_sm_size_ref <= '0';
							r_sm_last_ref <= "000";
							r_sm_last_ish_ref <= '0';
						else
							r_other_size_cnt_ref <= r_other_size_cnt_ref - 1;
							if(r_other_size_cnt_ref = 4) then
								r_sm_last_ref <= "100";
								r_sm_last_ish_ref <= '0';
							elsif(r_other_size_cnt_ref = 3) then
								r_sm_last_ref <= "010";
								r_sm_last_ish_ref <= '1';
							elsif(r_other_size_cnt_ref = 2) then
								r_sm_last_ref <= "001";
								r_sm_last_ish_ref <= '1';
							else
								r_sm_last_ref <= "000";
								r_sm_last_ish_ref <= '0';
							end if;

						end if;

						if(r_my_size_cnt_ref = 1) then
							r_gr_size_ref <= '0';
							r_gr_last_ref <= "000";
						else
							r_my_size_cnt_ref <= r_my_size_cnt_ref - 1;
							if(r_my_size_cnt_ref = 4) then
								r_gr_last_ref <= "100";
							elsif(r_my_size_cnt_ref = 3) then
								r_gr_last_ref <= "010";
							elsif(r_my_size_cnt_ref = 2) then
								r_gr_last_ref <= "001";
							else
								r_gr_last_ref <= "000";
							end if;
						end if;
					end if;

				end if;

			end if;

		end if;
	end process;


	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			---------------
			-- R_CORRECT --
			---------------
			if(r_rst = '1') then
				r_correct <= '1';
			else

				if(r_sm_size_ref /= s_sm_size or
					r_gr_size_ref /= s_gr_size or
					r_sm_last_ref /= s_sm_last or
					r_gr_last_ref /= s_gr_last or
					r_sm_last_ish_ref /= s_sm_last_ish ) then
					r_correct <= '0';
				end if;

			end if;

		end if;
	end process;

end architecture;
