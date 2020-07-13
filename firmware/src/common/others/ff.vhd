-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    01/12/2016
-- Project Name:   MPALU
-- Design Name:    common
-- Module Name:    ff
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

use work.my_pack.all;
use work.common_pack.all;
use work.pro_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
-------------------------------------------
-------------------------------------------

entity ff is
generic (
	g_data_width					: natural := 10
);
port (
	pi_clk							: in std_logic;
	pi_load							: in std_logic;
	pi_data							: in std_logic_vector(g_data_width-1 downto 0);
	po_data							: out std_logic_vector(g_data_width-1 downto 0)
);
end ff;

architecture ff of ff is
begin

	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			if(pi_load = '1') then			-- CE
				po_data <= pi_data;
			end if;

		end if;
	end process;

end architecture;
