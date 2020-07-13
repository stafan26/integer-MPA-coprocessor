-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    01/12/2016
-- Project Name:   MPALU
-- Design Name:    common
-- Module Name:    mux_1_1
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;

use work.my_pack.all;

entity mux_1_1 is
generic (
	g_registered_output			: boolean := true
);
port(
	pi_clk							: in std_logic;
	pi_data							: in std_logic_vector(0 downto 0);
	po_data							: out std_logic
);
end mux_1_1;

architecture mux_1_1 of mux_1_1 is
begin

	process(pi_clk)
	begin

		if(rising_edge(pi_clk)) then
			po_data <= pi_data(0);
		end if;

	end process;

end architecture;

