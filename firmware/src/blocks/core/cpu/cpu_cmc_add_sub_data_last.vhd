-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    21/5/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_add_sub_data_last
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;

entity cpu_cmc_add_sub_data_last is
generic (
	g_lfsr						: boolean := true;
	g_addr_width				: natural := 9
);
port(
	pi_clk						: in std_logic;
	pi_rst						: in std_logic;

	pi_start						: in std_logic;

	pi_my_size					: in std_logic_vector(g_addr_width-1 downto 0);
	pi_my_last					: in std_logic_vector(3 downto 0);
	pi_other_size				: in std_logic_vector(g_addr_width-1 downto 0);
	pi_other_last				: in std_logic_vector(3 downto 0);

	po_data_valid				: out std_logic;
	po_last						: out std_logic_vector(1 downto 0);
	po_last_both				: out std_logic
);
end cpu_cmc_add_sub_data_last;

architecture cpu_cmc_add_sub_data_last of cpu_cmc_add_sub_data_last is

	signal r_data_valid				: std_logic;
	signal r_last_both				: std_logic;

	signal r_last_first				: std_logic;

	signal r_my_change				: std_logic;
	signal s_my_last					: std_logic;
	signal s_my_last_but_one		: std_logic;

	signal r_other_change			: std_logic;
	signal s_other_last				: std_logic;
	signal s_other_last_but_one	: std_logic;

begin

	po_data_valid <= r_data_valid;
	po_last <= s_other_last & s_my_last;
	po_last_both <= r_last_both;

	MY_LFSR_COUNTER_DOWN_LAST_INST: entity work.lfsr_counter_down_4_last_2 generic map (
		g_lfsr						=> g_lfsr,						--: boolean := false;
		g_n							=> g_addr_width				--: natural := 9
	)
	port map (
		pi_clk						=> pi_clk,						--: in std_logic;
		pi_rst						=> pi_rst,						--: in std_logic;
		pi_load						=> pi_start,					--: in std_logic;
		pi_data						=> pi_my_size,					--: in std_logic_vector(g_n-1 downto 0);
		pi_last						=> pi_my_last,					--: in std_logic_vector(3 downto 0);
		pi_change					=> r_my_change,				--: in std_logic;
		po_last_but_one			=> s_my_last_but_one,		--: out std_logic
		po_last						=> s_my_last					--: out std_logic
	);


	OTHER_LFSR_COUNTER_DOWN_LAST_INST: entity work.lfsr_counter_down_4_last_2 generic map (
		g_lfsr						=> g_lfsr,						--: boolean := false;
		g_n							=> g_addr_width				--: natural := 9
	)
	port map (
		pi_clk						=> pi_clk,						--: in std_logic;
		pi_rst						=> pi_rst,						--: in std_logic;
		pi_load						=> pi_start,					--: in std_logic;
		pi_data						=> pi_other_size,				--: in std_logic_vector(g_n-1 downto 0);
		pi_last						=> pi_other_last,				--: in std_logic_vector(3 downto 0);
		pi_change					=> r_other_change,			--: in std_logic;
		po_last_but_one			=> s_other_last_but_one,	--: out std_logic
		po_last						=> s_other_last				--: out std_logic
	);


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			------------------
			-- R_DATA_VALID --
			------------------
			if(pi_rst = '1') then
				r_data_valid <= '0';
			else
				if(pi_start = '1') then
					r_data_valid <= '1';
				elsif(r_last_both = '1') then
					r_data_valid <= '0';
				end if;
			end if;


			-----------------
			-- R_MY_CHANGE --
			-----------------
			if(pi_rst = '1') then
				r_my_change <= '0';
			else

				if(pi_start = '1') then
					r_my_change <= '1';
				elsif(s_my_last = '1') then
					r_my_change <= '0';
				end if;

			end if;


			--------------------
			-- R_OTHER_CHANGE --
			--------------------
			if(pi_rst = '1') then
				r_other_change <= '0';
			else

				if(pi_start = '1') then
					r_other_change <= '1';
				elsif(s_other_last = '1') then
					r_other_change <= '0';
				end if;

			end if;

		end if;
	end process;



	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			-----------------
			-- R_LAST_BOTH --				6
			-----------------
			if((pi_start = '1' and pi_my_last(0) = '1' and pi_other_last(0) = '1') or					-- when both are single limb data
			(s_my_last_but_one = '1' and s_other_last_but_one = '1') or										-- when both are the same length
			(r_last_first = '1' and (s_my_last_but_one = '1' or s_other_last_but_one = '1'))) then	-- when of different lengths
				r_last_both <= '1';
			else
				r_last_both <= '0';
			end if;


			------------------
			-- R_LAST_FIRST --			8
			------------------
			if(pi_rst = '1') then
				r_last_first <= '0';
			else

--				if(pi_start = '1' and (pi_my_last(0) = '1' xor pi_other_last(0) = '1')) then
--					r_last_first <= '1';
--				elsif(pi_start = '1' or (s_my_last_but_one = '1' and s_other_last_but_one = '1')) then
--					r_last_first <= '0';
--				elsif(s_my_last /= s_other_last) then
--					r_last_first <= not r_last_first;
--				end if;

				if(pi_start = '1' and (pi_my_last(0) = '1' xor pi_other_last(0) = '1')) then						-- when of different length and either is 1
					r_last_first <= '1';
				elsif(pi_start = '1' or (s_my_last_but_one = '1' and s_other_last_but_one = '1')) then			-- when of the same length
					r_last_first <= '0';
				elsif(s_my_last_but_one = '1' xor s_other_last_but_one = '1') then									-- when of different length
					r_last_first <= not r_last_first;
				end if;


			end if;

		end if;
	end process;

end architecture;
