-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    29/12/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_add_sub_TB
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.common_pack.all;

entity cpu_cmc_add_sub_TB is
end cpu_cmc_add_sub_TB;

architecture cpu_cmc_add_sub_TB of cpu_cmc_add_sub_TB is

	constant c_lfsr										: boolean := true;
	constant c_addr_width								: natural := 9;

	constant c_my_size_cnt								: natural := 5;
	constant c_other_size_cnt							: natural := 3;

	constant c_delay										: natural := (c_my_size_cnt * c_other_size_cnt) + 10;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;

	signal r_my_size_cnt									: natural;
	signal r_other_size_cnt								: natural;

	signal r_delay											: natural;

	signal r_cmc_start									: std_logic;

	signal s_my_size										: std_logic_vector(c_addr_width-1 downto 0);
	signal s_my_last										: std_logic_vector(2 downto 0);
	signal s_other_size									: std_logic_vector(c_addr_width-1 downto 0);
	signal s_other_last									: std_logic_vector(2 downto 0);

	signal s_cmc_data_cycle								: std_logic;
	signal s_cmc_data_last								: std_logic_vector(1 downto 0);
	signal s_cmc_data_last_both						: std_logic;

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


	CPU_CMC_ADD_SUB_INST: entity work.cpu_cmc_add_sub generic map (
		g_lfsr								=> c_lfsr,							--: boolean := true;
		g_addr_width						=> c_addr_width					--: natural := 9
	)
	port map (
		pi_clk								=> r_clk,							--: in std_logic;
		pi_rst								=> r_rst,							--: in std_logic;
		pi_cmc_add_sub_start				=> r_cmc_start,					--: in std_logic;
		pi_my_size							=> s_my_size,						--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_my_last							=> s_my_last,						--: in std_logic_vector(2 downto 0);
		pi_other_size						=> s_other_size,					--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_other_last						=> s_other_last,					--: in std_logic_vector(2 downto 0);
		po_cmc_data_cycle					=> s_cmc_data_cycle,				--: out std_logic;
		po_cmc_data_last					=> s_cmc_data_last,				--: out std_logic_vector(1 downto 0);
		po_cmc_data_last_both			=> s_cmc_data_last_both			--: out std_logic
	);


	LFSR_TRUE_GEN: if(c_lfsr = true) generate
		s_my_size <= to_lfsr(r_my_size_cnt, s_my_size'length);
		s_other_size <= to_lfsr(r_other_size_cnt, s_other_size'length);
	end generate;

	LFSR_FALSE_GEN: if(c_lfsr = false) generate
		s_my_size <= to_std_logic_vector(r_my_size_cnt, s_my_size'length);
		s_other_size <= to_std_logic_vector(r_other_size_cnt, s_other_size'length);
	end generate;


	s_my_last <=	"001" when r_my_size_cnt = 1 else
						"010" when r_my_size_cnt = 2 else
						"100" when r_my_size_cnt = 3 else
						"000";

	s_other_last <=	"001" when r_other_size_cnt = 1 else
							"010" when r_other_size_cnt = 2 else
							"100" when r_other_size_cnt = 3 else
							"000";


	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			r_cmc_start <= '0';

			if(r_rst = '1') then
				r_my_size_cnt <= c_my_size_cnt;
				r_other_size_cnt <= c_other_size_cnt;
				r_delay <= c_delay;
			else

				r_delay <= r_delay - 1;

				--if(r_delay = 0) then
				--	r_delay <= c_delay;
				--elsif(r_delay = c_delay-2) then
				if(r_delay = c_delay-2) then
					r_cmc_start <= '1';
				end if;

			end if;

		end if;
	end process;

end architecture;
