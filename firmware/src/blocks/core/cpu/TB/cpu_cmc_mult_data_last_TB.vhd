-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    29/12/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_mult_data_last_TB
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.common_pack.all;

entity cpu_cmc_mult_data_last_TB is
generic (
	g_data_dir_path							: string
);
end cpu_cmc_mult_data_last_TB;

architecture cpu_cmc_mult_data_last_TB of cpu_cmc_mult_data_last_TB is

	constant c_lfsr										: boolean := true;
	constant c_addr_width								: natural := 9;

	constant c_my_size_cnt								: natural := 10;
	constant c_other_size_cnt							: natural := 10;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;

	signal s_last											: std_logic;
	signal s_data_valid									: std_logic;

	signal r_my_size_cnt									: natural;
	signal r_other_size_cnt								: natural;

	signal r_delay											: natural;
	signal r_delat_ref									: natural;

	signal r_add_sub										: std_logic;
	signal r_data_last_start							: std_logic;
	signal r_my_size										: std_logic_vector(c_addr_width-1 downto 0);
	signal s_my_last										: std_logic_vector(4 downto 0);
	signal r_other_size									: std_logic_vector(c_addr_width-1 downto 0);
	signal s_other_last									: std_logic_vector(4 downto 0);

	signal r_ref_start									: std_logic;
	signal r_ref_valid									: std_logic;
	signal r_ref_data_last								: std_logic;
	signal r_ref_cnt										: natural;

	signal r_error											: std_logic;

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

	CPU_CMC_MULT_DATA_LAST_INST: entity work.cpu_cmc_mult_data_last generic map (
		g_lfsr						=> c_lfsr,						--: boolean := true;
		g_addr_width				=> c_addr_width				--: natural := 9
	)
	port map (
		pi_clk						=> r_clk,						--: in std_logic;
		pi_rst						=> r_rst,						--: in std_logic;
		pi_data_last_start		=> r_data_last_start,		--: in std_logic;
		pi_my_size					=> r_my_size,					--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_my_last					=> s_my_last,					--: in std_logic_vector(4 downto 0);
		pi_other_size				=> r_other_size,				--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_other_last				=> s_other_last,				--: in std_logic_vector(4 downto 0);
		po_data_valid				=> s_data_valid,				--: out std_logic;
		po_last						=> s_last						--: out std_logic
	);



	LFSR_TRUE_GEN: if(c_lfsr = true) generate
		r_my_size <= to_lfsr(r_my_size_cnt-1, r_my_size'length);
		r_other_size <= to_lfsr(r_other_size_cnt-1, r_other_size'length);
	end generate;

	LFSR_FALSE_GEN: if(c_lfsr = false) generate
		r_my_size <= to_std_logic_vector(r_my_size_cnt-1, r_my_size'length);
		r_other_size <= to_std_logic_vector(r_other_size_cnt-1, r_other_size'length);
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

			r_add_sub <= '0';
			r_data_last_start <= '0';

			if(r_rst = '1') then
				r_my_size_cnt <= 1;
				r_other_size_cnt <= 1;
				r_delay <= 10;
				r_delat_ref <= 10;
			else

				r_delay <= r_delay - 1;

				if(r_delay = 0) then
					if(r_my_size_cnt = c_my_size_cnt) then
						r_my_size_cnt <= 1;
						r_other_size_cnt <= r_other_size_cnt + 1;
					else
						r_my_size_cnt <= r_my_size_cnt + 1;
					end if;
					r_delay <= (r_my_size_cnt + 1) * (r_other_size_cnt + 1) + 10;
					r_delat_ref <= (r_my_size_cnt + 1) * (r_other_size_cnt + 1) + 10;
				elsif(r_delay = r_delat_ref-2) then
					r_data_last_start <= '1';
				end if;

			end if;

		end if;
	end process;


	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			r_ref_start <= r_data_last_start;

			---------------
			-- R_REF_CNT --
			---------------
			if(r_data_last_start = '1') then
				r_ref_cnt <= r_my_size_cnt * r_other_size_cnt;
			elsif(r_ref_start = '1' or r_ref_valid = '1') then
				r_ref_cnt <= r_ref_cnt - 1;
			end if;


			-----------------
			-- R_REF_VALID --
			-----------------
			if(r_rst = '1') then
				r_ref_valid <= '0';
			else
				if(r_ref_start = '1') then
					r_ref_valid <= '1';
				elsif(r_ref_data_last = '1') then
					r_ref_valid <= '0';
				end if;
			end if;


			---------------------
			-- R_REF_DATA_LAST --
			---------------------
			if(r_rst = '1') then
				r_ref_data_last <= '0';
			else

				if(r_ref_cnt = 1) then
					r_ref_data_last <= '1';
				else
					r_ref_data_last <= '0';
				end if;

			end if;


			-------------
			-- R_ERROR --
			-------------
			if(r_rst = '1') then
				r_error <= '0';
			else

				if((r_ref_data_last /= s_last) or (r_ref_valid /= s_data_valid) )then
					r_error <= '1';
				end if;

			end if;

		end if;
	end process;

end architecture;
