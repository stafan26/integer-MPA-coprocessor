-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    29/12/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_TB
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.common_pack.all;

entity cpu_cmc_TB is
end cpu_cmc_TB;

architecture cpu_cmc_TB of cpu_cmc_TB is

	constant c_lfsr										: boolean := true;
	constant c_addr_width								: natural := 9;

	constant c_my_size_cnt								: natural := 1;
	constant c_other_size_cnt							: natural := 1;

	constant c_delay										: natural := (c_my_size_cnt * c_other_size_cnt) + 10;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;

	signal r_my_size_cnt									: natural;
	signal r_other_size_cnt								: natural;

	signal r_delay											: natural;

	signal r_cmc_start									: std_logic;

	signal s_my_size										: std_logic_vector(c_addr_width-1 downto 0);
	signal s_my_last										: std_logic_vector(4 downto 0);
	signal s_other_size									: std_logic_vector(c_addr_width-1 downto 0);
	signal s_other_last									: std_logic_vector(4 downto 0);

	signal s_cmc_addr_init_up_A						: std_logic_vector(1 downto 0);
	signal s_cmc_data_cycle_A							: std_logic;
	signal s_cmc_data_valid_A							: std_logic;
	signal s_cmc_data_last_A							: std_logic_vector(1 downto 0);

	signal s_cmc_addr_init_up_B						: std_logic_vector(1 downto 0);
	signal s_cmc_data_cycle_B							: std_logic;
	signal s_cmc_data_valid_B							: std_logic;
	signal s_cmc_data_last_B							: std_logic_vector(1 downto 0);

	signal s_cmc_add_sub_last							: std_logic;
	signal s_cmc_mult_last								: std_logic;

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


	CPU_CMC_INST: entity work.cpu_cmc generic map (
		g_lfsr						=> c_lfsr,										--: boolean := true;
		g_addr_width				=> c_addr_width								--: natural := 9
	)
	port map (
		pi_clk						=> r_clk,										--: in std_logic;
		pi_rst						=> r_rst,										--: in std_logic;
		pi_cmc_add_sub_start		=> '0',											--: in std_logic;
		pi_cmc_mult_start			=> r_cmc_start,								--: in std_logic;
		pi_cmc_channel				=> '0',											--: in std_logic;
		pi_my_size					=> s_my_size,									--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_my_last					=> s_my_last,									--: in std_logic_vector(4 downto 0);
		pi_other_size				=> s_other_size,								--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_other_last				=> s_other_last,								--: in std_logic_vector(4 downto 0);

		po_cmc_addr_init_up_A	=> s_cmc_addr_init_up_A	,					--: out std_logic_vector(1 downto 0);
		po_cmc_data_cycle_A		=> s_cmc_data_cycle_A	,					--: out std_logic;
		po_cmc_data_valid_A		=> s_cmc_data_valid_A	,					--: out std_logic;
		po_cmc_data_last_A		=> s_cmc_data_last_A		,					--: out std_logic_vector(1 downto 0);

		po_cmc_addr_init_up_B	=> s_cmc_addr_init_up_B	,					--: out std_logic_vector(1 downto 0);
		po_cmc_data_cycle_B		=> s_cmc_data_cycle_B	,					--: out std_logic;
		po_cmc_data_valid_B		=> s_cmc_data_valid_B	,					--: out std_logic;
		po_cmc_data_last_B		=> s_cmc_data_last_B		,					--: out std_logic_vector(1 downto 0);

		po_cmc_add_sub_last		=> s_cmc_add_sub_last	,					--: out std_logic;
		po_cmc_mult_last			=> s_cmc_mult_last							--: out std_logic
	);


	LFSR_TRUE_GEN: if(c_lfsr = true) generate
		s_my_size <= to_lfsr(r_my_size_cnt, s_my_size'length);
		s_other_size <= to_lfsr(r_other_size_cnt, s_other_size'length);
	end generate;

	LFSR_FALSE_GEN: if(c_lfsr = false) generate
		s_my_size <= to_std_logic_vector(r_my_size_cnt, s_my_size'length);
		s_other_size <= to_std_logic_vector(r_other_size_cnt, s_other_size'length);
	end generate;


	s_my_last <=	"00001" when r_my_size_cnt = 1 else
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
