-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    20/07/2019
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    mult_cycle_cropper
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

entity mult_cycle_cropper is
port(
	pi_clk								: in std_logic;
	pi_shutter							: in std_logic;
	pi_cycle								: in std_logic;
	po_cycle								: out std_logic
);
end mult_cycle_cropper;

architecture mult_cycle_cropper of mult_cycle_cropper is

begin

	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			if(pi_shutter = '1') then
				po_cycle <= pi_cycle;
			else
				po_cycle <= '0';
			end if;

		end if;
	end process;

end architecture;
