-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    21/5/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_mult_data_last
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;

entity cpu_cmc_mult_data_last is
generic (
	g_lfsr						: boolean := true;
	g_addr_width				: natural := 9
);
port(
	pi_clk						: in std_logic;
	pi_rst						: in std_logic;

	pi_data_last_start		: in std_logic;

	pi_my_size					: in std_logic_vector(g_addr_width-1 downto 0);
	pi_my_last					: in std_logic_vector(4 downto 0);
	pi_other_size				: in std_logic_vector(g_addr_width-1 downto 0);
	pi_other_last				: in std_logic_vector(4 downto 0);

	po_data_valid				: out std_logic;
	po_last						: out std_logic
);
end cpu_cmc_mult_data_last;

architecture cpu_cmc_mult_data_last of cpu_cmc_mult_data_last is

	signal r_rst											: std_logic;
	signal r_data_last_start							: std_logic;

	signal r_data_valid									: std_logic;
	signal r_last											: std_logic;
	signal r_last_shreg									: std_logic_vector(1 downto 0);
	signal r_short_last									: std_logic;
	signal r_short_my_last								: std_logic;
	signal r_short_other_last							: std_logic;
	signal r_my_keep_changing							: std_logic;


	signal r_my_size										: std_logic_vector(g_addr_width-1 downto 0);
	signal r_my_last										: std_logic_vector(4 downto 0);
	signal r_my_load										: std_logic;
	signal r_my_change									: std_logic;
	signal s_my_last										: std_logic;
	signal s_my_last_but_one							: std_logic;

	signal r_other_size									: std_logic_vector(g_addr_width-1 downto 0);
	signal r_other_last									: std_logic_vector(4 downto 0);
	signal r_other_load									: std_logic;
	signal r_other_change								: std_logic;
	signal s_other_last									: std_logic;
	signal s_other_last_but_one						: std_logic;

begin

	po_data_valid <= r_data_valid;
	po_last <= r_last;


	MY_LFSR_COUNTER_DOWN_LAST_INST: entity work.lfsr_counter_down_5_last_2 generic map (
		g_lfsr						=> g_lfsr,						--: boolean := false;
		g_n							=> g_addr_width				--: natural := 9
	)
	port map (
		pi_clk						=> pi_clk,						--: in std_logic;
		pi_rst						=> pi_rst,						--: in std_logic;
		pi_load						=> r_my_load,					--: in std_logic;
		pi_data						=> r_my_size,					--: in std_logic_vector(g_n-1 downto 0);
		pi_last						=> r_my_last,					--: in std_logic_vector(2 downto 0);
		pi_change					=> r_my_change,				--: in std_logic;
		po_last_but_one			=> s_my_last_but_one,		--: out std_logic
		po_last						=> s_my_last					--: out std_logic
	);


	OTHER_LFSR_COUNTER_DOWN_LAST_INST: entity work.lfsr_counter_down_5_last_2 generic map (
		g_lfsr						=> g_lfsr,						--: boolean := false;
		g_n							=> g_addr_width				--: natural := 9
	)
	port map (
		pi_clk						=> pi_clk,						--: in std_logic;
		pi_rst						=> pi_rst,						--: in std_logic;
		pi_load						=> r_other_load,				--: in std_logic;
		pi_data						=> r_other_size,				--: in std_logic_vector(g_n-1 downto 0);
		pi_last						=> r_other_last,				--: in std_logic_vector(2 downto 0);
		pi_change					=> r_other_change,			--: in std_logic;
		po_last_but_one			=> s_other_last_but_one,	--: out std_logic
		po_last						=> s_other_last				--: out std_logic
	);


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			------------
			-- INPUTS --
			------------
			if(pi_data_last_start = '1') then
				r_my_size <= pi_my_size;
				r_other_size <= pi_other_size;
			end if;


			r_rst <= pi_rst or r_last;

			if(r_rst = '1') then
				r_my_last <= (others=>'0');
				r_other_last <= (others=>'0');
			else
				if(pi_data_last_start = '1') then			-- CE
					r_my_last <= pi_my_last;
					r_other_last <= pi_other_last;
				end if;
			end if;


			------------------
			-- R_LAST_SHREG --
			------------------
			if(pi_rst = '1') then
				r_last_shreg <= (others=>'0');
			else
				if(r_last = '1') then
					r_last_shreg <= (others=>'1');
				else
					r_last_shreg <= '0' & r_last_shreg(r_last_shreg'length-1 downto 1);
				end if;
			end if;


			------------------------
			-- R_MY_KEEP_CHANGING --
			------------------------
			if(pi_rst = '1') then
				r_my_keep_changing <= '0';
			else

				if(pi_data_last_start = '1') then
					r_my_keep_changing <= '1';
				elsif(r_last = '1') then
					r_my_keep_changing <= '0';
				end if;

			end if;


			---------------
			-- R_MY_LOAD --			5
			---------------
			if(pi_rst = '1') then
				r_my_load <= '0';
			else

				if((pi_data_last_start = '1') or																-- OPERATION VALID
				(s_my_last_but_one = '1' and r_short_other_last = '0' and s_other_last = '0') ) then						-- MULT - RELOAD
					r_my_load <= '1';
				else
					r_my_load <= '0';
				end if;

			end if;


			-----------------
			-- R_MY_CHANGE --
			-----------------
			if(pi_rst = '1') then
				r_my_change <= '0';
			else

				if(r_my_load = '1' or
				(r_my_keep_changing = '1' or r_last_shreg(0) = '1') ) then
					r_my_change <= '1';
				else
					r_my_change <= '0';
				end if;

			end if;


			------------------
			-- R_OTHER_LOAD --
			------------------
			if(pi_rst = '1') then
				r_other_load <= '0';
			else

				if(pi_data_last_start = '1') then
					r_other_load <= '1';
				else
					r_other_load <= '0';
				end if;

			end if;


			--------------------
			-- R_OTHER_CHANGE --
			--------------------
			if(pi_rst = '1') then
				r_other_change <= '0';
			else

				if((r_other_load = '1' and r_short_other_last = '1') or
				(s_my_last_but_one = '1' and r_short_my_last = '0') or
				r_short_my_last = '1' or
				r_last_shreg(0) = '1') then
					r_other_change <= '1';
				else
					r_other_change <= '0';
				end if;

			end if;

		end if;
	end process;



	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			------------------
			-- R_SHORT_LAST --
			------------------
			if(pi_rst = '1') then
				r_short_last <= '0';
			else
				if(pi_data_last_start = '1') then
					r_short_last <= pi_my_last(0) and pi_other_last(0);
				else
					r_short_last <= '0';
				end if;
			end if;


			---------------------
			-- R_SHORT_MY_LAST --
			---------------------
			if(pi_rst = '1') then
				r_short_my_last <= '0';
			else

				if(pi_data_last_start = '1') then
					r_short_my_last <= pi_my_last(0);
				elsif(s_other_last_but_one = '1' or r_short_other_last = '1') then
					r_short_my_last <= '0';
				end if;
			end if;



			------------------------
			-- R_SHORT_OTHER_LAST --
			------------------------
			if(pi_rst = '1') then
				r_short_other_last <= '0';
			else

				if(pi_data_last_start = '1') then
					r_short_other_last <= pi_other_last(0);
				elsif(s_my_last_but_one = '1' or r_short_my_last = '1') then
					r_short_other_last <= '0';
				end if;
			end if;



			r_data_last_start <= pi_data_last_start;

			------------------
			-- R_DATA_VALID --
			------------------
			if(pi_rst = '1') then
				r_data_valid <= '0';
			else
				if(r_data_last_start = '1') then
					r_data_valid <= '1';
				elsif(r_last = '1') then
					r_data_valid <= '0';
				end if;
			end if;


			-----------------
			-- R_LAST_BOTH --				6
			-----------------
			if(r_short_last = '1' or
			(s_other_last_but_one = '1' and r_short_my_last = '1') or		-- for short R_MY_LAST
			(s_my_last_but_one = '1' and r_short_other_last = '1') or		-- for long R_MY_LAST but short R_OTHER_LAST
			(s_my_last_but_one = '1' and s_other_last = '1') ) then			-- for long R_MY_LAST
				r_last <= '1';
			else
				r_last <= '0';
			end if;

		end if;
	end process;

end architecture;
