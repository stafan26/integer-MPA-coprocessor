-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    29/12/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_mult_cycler_ctrl
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.pro_pack.all;
use work.common_pack.all;

entity cpu_cmc_mult_cycler_ctrl is port (
	pi_clk							: in std_logic;
	pi_rst							: in std_logic;

	pi_mult_pre_start				: in std_logic;
	pi_mult_start					: in std_logic;
	pi_ultimate_last				: in std_logic;
	pi_one_limb						: in std_logic;
	pi_change_A						: in std_logic;

	pi_last_but_one				: in std_logic;

	po_rst_cycler					: out std_logic;
	po_cmc_on						: out std_logic;
	po_addr_init					: out std_logic_vector(1 downto 0);
	po_change_en					: out std_logic
);
end cpu_cmc_mult_cycler_ctrl;

architecture cpu_cmc_mult_cycler_ctrl of cpu_cmc_mult_cycler_ctrl is

	signal r_rst_cycler									: std_logic;
	signal r_cmc_on										: std_logic;
	signal r_change_en									: std_logic;
	signal f_change_en									: natural;
	signal r_first											: std_logic;
	signal r_one_limb										: std_logic;

	signal r_init_down									: std_logic;
	signal r_init_up										: std_logic;

	signal r_ultimate_last								: std_logic;
	signal r_cycle											: std_logic;

begin

	po_rst_cycler <= r_rst_cycler;
	po_cmc_on <= r_cmc_on;
	po_change_en <= r_change_en;


	process(pi_clk)
	begin

		if(rising_edge(pi_clk)) then

			------------------
			-- R_RST_CYCLER --
			------------------
			if(pi_rst = '1') then
				r_rst_cycler <= '1';
			else

				if(pi_mult_pre_start = '1') then
					r_rst_cycler <= '0';
				elsif(pi_ultimate_last = '1') then
					r_rst_cycler <= '1';
				end if;

			end if;




			--------------
			-- R_CMC_ON --
			--------------
			if(pi_rst = '1') then
				r_cmc_on <= '0';
			else

				if(pi_mult_start = '1') then
					r_cmc_on <= '1';
				elsif(pi_ultimate_last = '1') then
					r_cmc_on <= '0';
				end if;

			end if;


			----------------
			-- R_ONE_LIMB --
			----------------
			if(pi_rst = '1') then
				r_one_limb <= '0';
			else

				if(pi_mult_start = '1' and pi_one_limb = '1') then
					r_one_limb <= '1';
				elsif(pi_ultimate_last = '1') then
					r_one_limb <= '0';
				end if;

			end if;


			-------------
			-- R_FIRST --
			-------------
			if(pi_rst = '1') then
				r_first <= '0';
			else

				if(pi_mult_start = '1') then
					r_first <= '1';
				elsif(r_change_en = '1') then
					r_first <= '0';
				end if;

			end if;


			-----------------
			-- R_CHANGE_EN --
			-----------------
--			if(pi_mult_start = '1' or					-- start
--			r_one_limb = '1' or							-- for 1 limb
--			r_first = '1' or							-- ??
--			pi_last_but_one = '1') then				-- for 2 or more limbs
--				r_change_en <= '1';


			r_ultimate_last <= pi_ultimate_last;

			if(pi_mult_start = '1') then -- or					-- start
				r_change_en <= '1';
				f_change_en <= 2;
			elsif(pi_ultimate_last = '1') then -- or					-- last
				r_change_en <= '1';
				f_change_en <= 6;
			elsif(r_ultimate_last = '1') then -- or					-- last
				r_change_en <= '0';
				f_change_en <= 9;
			elsif(r_one_limb = '1') then	-- or							-- for 1 limb
				r_change_en <= '1';
				f_change_en <= 3;
			elsif(r_first = '1') then --or							-- ??
				r_change_en <= '1';
				f_change_en <= 4;
			elsif(pi_last_but_one = '1') then				-- for 2 or more limbs
				r_change_en <= '1';
				f_change_en <= 5;
			else
				r_change_en <= '0';
				f_change_en <= 0;
			end if;


			---------------
			-- R_INIT_UP --
			---------------
			if(r_change_en = '1' and pi_change_A = '1' and r_first = '0') then
				r_init_up <= '1';
			else
				r_init_up <= '0';
			end if;


			-----------------
			-- R_INIT_DOWN --
			-----------------
			if(r_change_en = '1' and pi_change_A = '0' and r_first = '0') then
				r_init_down <= '1';
			else
				r_init_down <= '0';
			end if;

			r_cycle <= r_change_en;

		end if;

	end process;

	po_addr_init <= r_init_down & r_init_up;

end architecture;
