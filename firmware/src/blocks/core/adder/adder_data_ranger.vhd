-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    adder_data_ranger
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

entity adder_data_ranger is
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_data								: in std_logic;
	po_data								: out std_logic
);
end adder_data_ranger;

architecture adder_data_ranger of adder_data_ranger is

	signal r_data									: std_logic;

begin

	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			r_data <= pi_data;

			if(pi_rst = '1') then
				po_data <= '0';
			else
				if(pi_data = '1' or r_data = '1') then
					po_data <= '1';
				else
					po_data <= '0';
				end if;
			end if;

		end if;
	end process;

end architecture;
