-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    21/5/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_switch
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--		- limit r_sm_last input signals from 7 to 6 in SIZE_CONVERTER
--		- remove last_both? data_last could generate proper, individual data_last signals
--
-------------------------------------------
-------------------------------------------


entity cpu_cmc_switch is
generic (
	g_lfsr									: boolean := true;
	g_addr_width							: natural := 9
);
port(
	pi_clk									: in std_logic;
	pi_rst									: in std_logic;

	pi_cmc_start							: in std_logic;
	pi_cmc_oper								: in std_logic_vector(1 downto 0);

	pi_cmc_channel							: in std_logic;

	pi_cmc_add_sub_data_cycle			: in std_logic;
	pi_cmc_add_sub_data_valid			: in std_logic;
	pi_cmc_add_sub_data_last			: in std_logic_vector(1 downto 0);
	pi_cmc_add_sub_data_last_both		: in std_logic;

	pi_cmc_mult_addr_init_up			: in std_logic_vector(1 downto 0);
	pi_cmc_mult_data_cycle				: in std_logic;
	pi_cmc_mult_data_valid				: in std_logic;
	pi_cmc_mult_data_last_both			: in std_logic;

	pi_cmc_unload_data_cycle			: in std_logic;
	pi_cmc_unload_data_valid			: in std_logic;
	pi_cmc_unload_data_last				: in std_logic;

	po_cmc_busy								: out std_logic_vector(1 downto 0);

	po_cmc_addr_init_up_A				: out std_logic_vector(1 downto 0);
	po_cmc_data_cycle_A					: out std_logic;
	po_cmc_data_valid_A					: out std_logic;
	po_cmc_data_last_A					: out std_logic_vector(2 downto 0);

	po_cmc_addr_init_up_B				: out std_logic_vector(1 downto 0);
	po_cmc_data_cycle_B					: out std_logic;
	po_cmc_data_valid_B					: out std_logic;
	po_cmc_data_last_B					: out std_logic_vector(2 downto 0)
);
end cpu_cmc_switch;

architecture cpu_cmc_switch of cpu_cmc_switch is

	signal r_en_A												: std_logic;
	signal r_en_B												: std_logic;

	signal r_oper_A											: std_logic_vector(1 downto 0);
	signal r_oper_B											: std_logic_vector(1 downto 0);

	signal r_cmc_addr_init_up_A							: std_logic_vector(1 downto 0);
	signal r_cmc_data_cycle_A								: std_logic;
	signal r_cmc_data_valid_A								: std_logic;
	signal r_cmc_data_last_A								: std_logic_vector(2 downto 0);

	signal r_cmc_addr_init_up_B							: std_logic_vector(1 downto 0);
	signal r_cmc_data_cycle_B								: std_logic;
	signal r_cmc_data_valid_B								: std_logic;
	signal r_cmc_data_last_B								: std_logic_vector(2 downto 0);

begin

	po_cmc_busy <= r_en_B & r_en_A;

	po_cmc_addr_init_up_A <= r_cmc_addr_init_up_A;
	po_cmc_data_cycle_A <= r_cmc_data_cycle_A;
	po_cmc_data_valid_A <= r_cmc_data_valid_A;
	po_cmc_data_last_A <= r_cmc_data_last_A;

	po_cmc_addr_init_up_B <= r_cmc_addr_init_up_B;
	po_cmc_data_cycle_B <= r_cmc_data_cycle_B;
	po_cmc_data_valid_B <= r_cmc_data_valid_B;
	po_cmc_data_last_B <= r_cmc_data_last_B;


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

---------------
-- CHANNEL A --
---------------


			--------------
			-- R_OPER_A --
			--------------
			if(pi_cmc_channel = '0') then			-- CE

				if(pi_cmc_start = '1') then
					r_oper_A <= pi_cmc_oper;
				end if;

			end if;


			------------
			-- R_EN_A --
			------------
			if(pi_rst = '1') then
				r_en_A <= '0';
			else

				if(pi_cmc_start = '1' and pi_cmc_channel = '0') then
					r_en_A <= '1';
				elsif(r_cmc_data_last_A(2) = '1') then
					r_en_A <= '0';
				end if;

			end if;


			----------------------------------------------------------------------------------------------------
			-- R_CMC_ADDR_INIT_UP_A   &   R_CMC_DATA_CYCLE_A   &   R_CMC_DATA_VALID_A   &   R_CMC_DATA_LAST_A --
			----------------------------------------------------------------------------------------------------
			if(r_en_A = '0') then			-- RST
				r_cmc_addr_init_up_A <= (others=>'0');
				r_cmc_data_cycle_A <= '0';
				r_cmc_data_valid_A <= '0';
				r_cmc_data_last_A <= (others=>'0');
			else

				case r_oper_A is
					when "00" =>
						r_cmc_addr_init_up_A <= (others=>'0');
						r_cmc_data_cycle_A <= pi_cmc_add_sub_data_cycle;
						r_cmc_data_valid_A <= pi_cmc_add_sub_data_valid;
						r_cmc_data_last_A <= pi_cmc_add_sub_data_last_both & pi_cmc_add_sub_data_last;
					when "01" =>
						r_cmc_addr_init_up_A <= pi_cmc_mult_addr_init_up;
						r_cmc_data_cycle_A <= pi_cmc_mult_data_cycle;
						r_cmc_data_valid_A <= pi_cmc_mult_data_valid;
						r_cmc_data_last_A <= pi_cmc_mult_data_last_both & pi_cmc_mult_data_last_both & pi_cmc_mult_data_last_both;
					when "10" =>
						r_cmc_addr_init_up_A <= (others=>'0');
						r_cmc_data_cycle_A <= pi_cmc_unload_data_cycle;
						r_cmc_data_valid_A <= pi_cmc_unload_data_valid;
						r_cmc_data_last_A <= pi_cmc_unload_data_last & pi_cmc_unload_data_last & pi_cmc_unload_data_last;
					when others =>
						r_cmc_addr_init_up_A <= (others=>'0');
						r_cmc_data_cycle_A <= '0';
						r_cmc_data_valid_A <= '0';
						r_cmc_data_last_A <= (others=>'0');
				end case;

			end if;


---------------
-- CHANNEL B --
---------------

			--------------
			-- R_OPER_B --
			--------------
			if(pi_cmc_channel = '1') then			-- CE

				if(pi_cmc_start = '1') then
					r_oper_B <= pi_cmc_oper;
				end if;

			end if;


			------------
			-- R_EN_B --
			------------
			if(pi_rst = '1') then
				r_en_B <= '0';
			else

				if(pi_cmc_start = '1' and pi_cmc_channel = '1') then
					r_en_B <= '1';
				elsif(r_cmc_data_last_B(2) = '1') then
					r_en_B <= '0';
				end if;

			end if;


			----------------------------------------------------------------------------------------------------
			-- R_CMC_ADDR_INIT_UP_B   &   R_CMC_DATA_CYCLE_   &   R_CMC_DATA_VALID_B   &   R_CMC_DATA_LAST_B --
			----------------------------------------------------------------------------------------------------
			if(r_en_B = '0') then			-- RST
				r_cmc_addr_init_up_B <= (others=>'0');
				r_cmc_data_cycle_B <= '0';
				r_cmc_data_valid_B <= '0';
				r_cmc_data_last_B <= (others=>'0');
			else

				case r_oper_B is
					when "00" =>
						r_cmc_addr_init_up_B <= (others=>'0');
						r_cmc_data_cycle_B <= pi_cmc_add_sub_data_cycle;
						r_cmc_data_valid_B <= pi_cmc_add_sub_data_valid;
						r_cmc_data_last_B <= pi_cmc_add_sub_data_last_both & pi_cmc_add_sub_data_last;
					when "01" =>
						r_cmc_addr_init_up_B <= pi_cmc_mult_addr_init_up;
						r_cmc_data_cycle_B <= pi_cmc_mult_data_cycle;
						r_cmc_data_valid_B <= pi_cmc_mult_data_valid;
						r_cmc_data_last_B <= pi_cmc_mult_data_last_both & pi_cmc_mult_data_last_both & pi_cmc_mult_data_last_both;
					when "10" =>
						r_cmc_addr_init_up_B <= (others=>'0');
						r_cmc_data_cycle_B <= pi_cmc_unload_data_cycle;
						r_cmc_data_valid_B <= pi_cmc_unload_data_valid;
						r_cmc_data_last_B <= pi_cmc_unload_data_last & pi_cmc_unload_data_last & pi_cmc_unload_data_last;
					when others =>
						r_cmc_addr_init_up_B <= (others=>'0');
						r_cmc_data_cycle_B <= '0';
						r_cmc_data_valid_B <= '0';
						r_cmc_data_last_B <= (others=>'0');
				end case;

			end if;

--			--------------
--			-- R_OPER_B --
--			--------------
--			if(pi_cmc_channel = '0' and pi_cmc_add_sub_start = '1') then
--				r_oper_B <= '0';
--			elsif(pi_cmc_channel = '0' and pi_cmc_mult_start = '1') then
--				r_oper_B <= '1';
--			end if;
--
--
--			------------
--			-- R_EN_B --
--			------------
--			if(pi_rst = '1') then
--				r_en_B <= '0';
--			else
--
--				if((pi_cmc_add_sub_start  = '1' or pi_cmc_mult_start = '1') and pi_cmc_channel = '1') then
--					r_en_B <= '1';
--				elsif((r_oper_B = '0' and pi_cmc_add_sub_data_last_both = '1') or
--				(r_oper_B = '1' and pi_cmc_mult_data_last_both = '1'))then
--					r_en_B <= '0';
--				end if;
--
--			end if;
--
--
--			----------------------------------------------------------------------------------------------------
--			-- R_CMC_ADDR_INIT_UP_B   &   R_CMC_DATA_CYCLE_B   &   R_CMC_DATA_VALID_B   &   R_CMC_DATA_LAST_B --
--			----------------------------------------------------------------------------------------------------
--			if(r_en_B = '1') then
--				case r_oper_B is
--					when '0' =>
--						r_cmc_addr_init_up_B <= (others=>'0');
--						r_cmc_data_cycle_B <= pi_cmc_add_sub_data_cycle;
--						r_cmc_data_valid_B <= pi_cmc_add_sub_data_valid;
--						r_cmc_data_last_B <= pi_cmc_add_sub_data_last_both & pi_cmc_add_sub_data_last;
--					when others =>
--						r_cmc_addr_init_up_B <= pi_cmc_mult_addr_init_up;
--						r_cmc_data_cycle_B <= pi_cmc_mult_data_cycle;
--						r_cmc_data_valid_B <= pi_cmc_mult_data_valid;
--						r_cmc_data_last_B <= pi_cmc_mult_data_last_both & pi_cmc_mult_data_last_both & pi_cmc_mult_data_last_both;
--				end case;
--			end if;

		end if;
	end process;

end architecture;
