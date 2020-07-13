-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    29/12/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_shutter_former_TB
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.common_pack.all;

entity cpu_cmc_shutter_former_TB is
end cpu_cmc_shutter_former_TB;

architecture cpu_cmc_shutter_former_TB of cpu_cmc_shutter_former_TB is

	constant c_addr_width								: natural := 9;

	constant c_my_size_cnt								: natural := 3;
	constant c_other_size_cnt							: natural := 5;

	constant c_delay										: natural := (c_my_size_cnt * c_other_size_cnt) + 10;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;

	signal r_my_size_cnt									: natural;
	signal r_other_size_cnt								: natural;

	signal r_delay											: natural;
	signal r_mult_delay									: natural;

	signal r_add_sub										: std_logic;
	signal r_add_sub_dly									: std_logic;
	signal r_mult											: std_logic;
	signal r_mult_dly										: std_logic;

	signal r_cycle											: std_logic;
	signal r_cycle_on										: std_logic;

	signal r_last											: std_logic_vector(1 downto 0);
	signal r_last_both									: std_logic;


	signal s_my_size										: std_logic;
	signal s_my_last										: std_logic_vector(2 downto 0);
	signal s_my_ootf										: std_logic;
	signal s_my_take										: std_logic;
	signal s_other_size									: std_logic;
	signal s_other_last									: std_logic_vector(2 downto 0);
	signal s_other_take									: std_logic;

	signal s_cmc_addr_init_up							: std_logic_vector(1 downto 0);
	signal s_cmc_data_cycle								: std_logic;
	signal s_cmc_data_last								: std_logic_vector(1 downto 0);

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


	CPU_CMC_SHUTTER_FORMER_INST: entity work.cpu_cmc_shutter_former port map (
		pi_clk						=> r_clk,									--: in std_logic;
		pi_rst						=> r_rst,									--: in std_logic;
		pi_add_sub					=> r_add_sub,								--: in std_logic;
		pi_mult						=> r_mult,									--: in std_logic;

		pi_my_size					=> s_my_size,								--: in std_logic;
		pi_my_ootf					=> s_my_ootf,								--: in std_logic;
		pi_my_last					=> s_my_last,								--: in std_logic_vector(2 downto 0);
		po_my_take					=> s_my_take,								--: out std_logic;

		pi_other_size				=> s_other_size,							--: in std_logic;
		pi_other_last				=> s_other_last,							--: in std_logic_vector(2 downto 0);
		po_other_take				=> s_other_take,							--: out std_logic;

		pi_cycle						=> r_cycle,									--: in std_logic;
		pi_last						=> r_last,									--: in std_logic_vector(1 downto 0);
		pi_last_both				=> r_last_both,							--: in std_logic;

		po_cmc_addr_init_up		=> s_cmc_addr_init_up,					--: out std_logic_vector(1 downto 0);
		po_cmc_data_cycle			=> s_cmc_data_cycle,						--: out std_logic;
		po_cmc_data_last			=> s_cmc_data_last						--: out std_logic_vector(1 downto 0)
	);



	s_my_ootf <= '1' when r_my_size_cnt = 1 or r_my_size_cnt = 2 else '0';

	s_my_last <=	"001" when r_my_size_cnt = 1 else
						"010" when r_my_size_cnt = 2 else
						"100" when r_my_size_cnt = 3 else
						"000";

	s_other_last <=	"001" when r_other_size_cnt = 1 else
							"010" when r_other_size_cnt = 2 else
							"100" when r_other_size_cnt = 3 else
							"000";


	s_my_size <= '1' when r_my_size_cnt /= 0 else '0';
	s_other_size <= '1' when r_other_size_cnt /= 0 else '0';


	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			r_add_sub <= '0';
			r_mult <= '0';

			if(r_rst = '1') then
				r_my_size_cnt <= c_my_size_cnt;
				r_other_size_cnt <= c_other_size_cnt;
				r_delay <= c_delay;
				r_cycle <= '0';
				r_cycle_on <= '0';
				r_add_sub_dly <= '0';
				r_mult_dly <= '0';
			else

				r_delay <= r_delay - 1;

				if(s_my_take = '1') then
					r_my_size_cnt <= r_my_size_cnt - 1;
				end if;

				if(s_other_take = '1') then
					r_other_size_cnt <= r_other_size_cnt - 1;
				end if;

				--if(r_delay = 0) then
				--	r_delay <= c_delay;
				--elsif(r_delay = c_delay-2) then
				if(r_delay = c_delay-2) then
					--r_add_sub <= '1';
					r_mult <= '1';
				end if;



				if(r_last_both = '1') then
					r_cycle_on <= '0';
				elsif(r_mult_dly = '1') then
					r_cycle_on <= '1';
				end if;

				if(r_cycle_on = '1') then
					r_cycle <= not r_cycle;
				else
					r_cycle <= '0';
				end if;


				if(r_last_both = '1') then
					r_mult_dly <= '0';
				elsif(r_mult = '1') then
					r_mult_dly <= '1';
				end if;

				if(r_mult_dly = '1') then
					if(r_mult_delay /= 0) then
						r_mult_delay <= r_mult_delay - 1;
					end if;

					if(r_mult_delay = 1) then
						r_last_both <= '1';
						r_last(0) <= '1';
						r_last(1) <= '1';
					else
						r_last_both <= '0';
						r_last(0) <= '0';
						r_last(1) <= '0';
					end if;
				elsif(r_add_sub_dly = '1') then
					if(r_my_size_cnt = 1) then
						r_last(0) <= '1';
					else
						r_last(0) <= '0';
					end if;

					if(r_other_size_cnt = 1) then
						r_last(1) <= '1';
					else
						r_last(1) <= '0';
					end if;
				else
					r_last_both <= '0';
					r_last(0) <= '0';
					r_last(1) <= '0';
					r_mult_delay <= (r_my_size_cnt * r_other_size_cnt) - 1;
				end if;

			end if;

		end if;
	end process;

end architecture;
