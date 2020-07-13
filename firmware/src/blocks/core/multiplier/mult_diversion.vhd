-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    mult_diversion
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
--use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity mult_diversion is
generic (
	g_data_width						: natural := 64
);
port(
	pi_clk								: in std_logic;

	pi_switch							: in std_logic;

	pi_data								: in std_logic_vector(2*g_data_width-1 downto 0);

	po_data_1							: out std_logic_vector(g_data_width-1 downto 0);
	po_data_2							: out std_logic_vector(g_data_width-1 downto 0)
);
end mult_diversion;

architecture mult_diversion of mult_diversion is

begin

	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			if(pi_switch = '0') then
				po_data_2 <= pi_data(2*g_data_width-1 downto g_data_width);
				po_data_1 <= pi_data(g_data_width-1 downto 0);
			else
				po_data_2 <= pi_data(g_data_width-1 downto 0);
				po_data_1 <= pi_data(2*g_data_width-1 downto g_data_width);
			end if;

		end if;
	end process;

end architecture;
