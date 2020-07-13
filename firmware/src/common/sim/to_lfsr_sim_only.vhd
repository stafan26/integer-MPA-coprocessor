-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    21/5/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    to_lfsr_sim_only
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.common_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------


entity to_lfsr_sim_only is
generic (
	g_lfsr						: boolean := true;
	g_addr_width				: natural := 9;
	g_last_width				: natural := 5
);
port(
	pi_clk						: in std_logic;
	pi_data						: in std_logic_vector(g_addr_width-1 downto 0);
	po_data						: out std_logic_vector(g_addr_width-1 downto 0);
	po_last						: out std_logic_vector(g_last_width-1 downto 0)
);
end to_lfsr_sim_only;

architecture to_lfsr_sim_only of to_lfsr_sim_only is

	signal s_data				: std_logic_vector(g_addr_width-1 downto 0);

begin

	process(pi_clk)
	begin

		if(rising_edge(pi_clk)) then
			po_data <= s_data;
		end if;

	end process;


	s_data <= to_lfsr(to_natural(pi_data), g_addr_width) when g_lfsr = true else pi_data;


	process(pi_data)
	begin

		if(pi_data >= 0 and pi_data < g_last_width) then
			po_last <= (others=>'0');
			po_last(to_natural(pi_data)) <= '1';
		else
			po_last <= (others=>'0');
		end if;

	end process;

end architecture;
