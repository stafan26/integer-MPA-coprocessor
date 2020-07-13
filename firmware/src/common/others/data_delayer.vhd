-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    15/5/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    data_delayer
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;

entity data_delayer is
generic (
	g_data_width			: natural := 64;
	g_delay					: natural := 4
);
port(
	pi_clk					: in std_logic;
	pi_data					: in std_logic_vector(g_data_width-1 downto 0);
	po_data					: out std_logic_vector(g_data_width-1 downto 0)
);
end data_delayer;

architecture data_delayer of data_delayer is

	type t_data is array (0 to g_delay-1) of std_logic_vector(g_data_width-1 downto 0);
	signal r_data			: t_data;

begin

	DELAY_0_GEN: if(g_delay = 0) generate
		po_data <= pi_data;
	end generate;

	REG_DELAY_GEN: if(g_delay > 0) generate
		po_data <= r_data(g_delay-1);

		DATA_0_STAGE_PROC: process(pi_clk)
		begin
			if(rising_edge(pi_clk)) then
				r_data(0) <= pi_data;
			end if;
		end process;

		DATA_STAGES_GEN: for i in 1 to g_delay-1 generate
			DATA_STAGES_PROC: process(pi_clk)
			begin
				if(rising_edge(pi_clk)) then
					r_data(i) <= r_data(i-1);
				end if;
			end process;
		end generate;

	end generate;

end architecture;
