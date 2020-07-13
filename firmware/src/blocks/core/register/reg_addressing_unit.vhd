-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    21/5/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    reg_addressing_unit
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;

entity reg_addressing_unit is
generic (
	g_lfsr					: boolean := false;
	g_addr_width			: natural := 9
);
port(
	pi_clk					: in std_logic;
	pi_rst					: in std_logic;

	pi_addr_init_up		: in std_logic;
	pi_data_cycle			: in std_logic;
	pi_data_valid			: in std_logic;
	pi_data_last_my		: in std_logic;
	pi_data_last_other	: in std_logic;
	pi_addr_up_down		: in std_logic;

	po_read_addr			: out std_logic_vector(g_addr_width-1 downto 0)
);
end reg_addressing_unit;

architecture reg_addressing_unit of reg_addressing_unit is

	signal r_rst											: std_logic;
	signal r_data_last									: std_logic;
	signal s_addr_init									: std_logic_vector(g_addr_width-1 downto 0);

begin

	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			--r_rst <= pi_rst or not pi_data_valid;

			if(pi_rst = '1') then
				r_rst <= '1';
			elsif((pi_data_last_my = '1' and pi_data_last_other = '1') or
					(r_data_last = '1' and (pi_data_last_my = '1' or pi_data_last_other = '1'))) then
				r_rst <= '1';
			else
				r_rst <= '0';
			end if;


			-----------------
			-- R_DATA_LAST --
			-----------------
			if(pi_rst = '1') then
				r_data_last <= '0';
			else

				if((pi_data_last_my = '1' and pi_data_last_other = '0') or
					(pi_data_last_my = '0' and pi_data_last_other = '1')) then
					r_data_last <= not r_data_last;
				end if;

			end if;

		end if;
	end process;


	ADDR_INIT_LFSR_COUNTER_INST: entity work.lfsr_counter_up generic map (
		g_lfsr			=> g_lfsr,				--: boolean := false;
		g_n				=> g_addr_width		--: natural := 60
	)
	port map (
		pi_clk			=> pi_clk,				--: in std_logic;												-- OK
		pi_rst			=> r_rst,				--: in std_logic;												-- OK
		pi_change		=> pi_addr_init_up,	--: in std_logic;												-- OK
		po_data			=> s_addr_init			--: out std_logic_vector(g_n-1 downto 0)				-- OK
	);


	ADDR_OUT_LFSR_COUNTER_INST: entity work.lfsr_counter generic map (
		g_lfsr			=> g_lfsr,				--: boolean := false;
		g_n				=> g_addr_width		--: natural := 60
	)
	port map (
		pi_clk			=> pi_clk,				--: in std_logic;												-- OK
		pi_load			=> pi_data_cycle,		--: in std_logic;												-- OK
		pi_data			=> s_addr_init,		--: in std_logic_vector(g_n-1 downto 0);				--
		pi_change		=> pi_data_valid,		--: in std_logic;												-- OK
		pi_direction	=> pi_addr_up_down,	--: in std_logic;												-- OK
		po_data			=> po_read_addr		--: out std_logic_vector(g_n-1 downto 0)				-- OK
	);

end architecture;
