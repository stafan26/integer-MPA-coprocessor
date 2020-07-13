-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    15/5/2017
-- Project Name:   MPALU
-- Design Name:    multiplier
-- Module Name:    mult_mux
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;

entity mult_mux is
generic (
	g_reg_output			: string := "YES";
	g_data_width			: natural := 64
);
port(
	pi_clk					: in std_logic;
	pi_switch				: in std_logic;
	pi_data_1				: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_2				: in std_logic_vector(g_data_width-1 downto 0);
	po_data					: out std_logic_vector(g_data_width-1 downto 0)
);
end mult_mux;

architecture mult_mux of mult_mux is

begin

	COMB_GEN: if(g_reg_output = "NO") generate

		po_data <= pi_data_1 when pi_switch = '0' else pi_data_2;

	end generate;


	REG_GEN: if(g_reg_output = "YES") generate

		REG_PROC: process(pi_clk)
		begin
			if(rising_edge(pi_clk)) then
				if(pi_switch = '0') then
					po_data <= pi_data_1;
				else
					po_data <= pi_data_2;
				end if;
			end if;
		end process;

	end generate;

end architecture;
