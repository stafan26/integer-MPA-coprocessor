-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    01/12/2016
-- Project Name:   MPALU
-- Design Name:    common
-- Module Name:    mux_2_1
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;

use work.my_pack.all;

entity mux_2_1 is
generic (
	g_registered_output			: boolean := true
);
port(
	pi_clk							: in std_logic;
	pi_addr							: in std_logic_vector(0 downto 0);
	pi_data							: in std_logic_vector(1 downto 0);
	po_data							: out std_logic
);
end mux_2_1;

architecture mux_2_1 of mux_2_1 is

	signal s_int_lut3										: std_logic;

begin

	LUT3_D_inst : LUT3_L generic map (
		INIT => X"CA"
	) -- Specify LUT contents
	port map (
		LO		=> s_int_lut3,			-- LUT local output
		I0		=> pi_data(0),			-- LUT input
		I1		=> pi_data(1),			-- LUT input
		I2		=> pi_addr(0)			-- LUT input
	);


	process(pi_clk)
	begin

		if(rising_edge(pi_clk)) then
			po_data <= s_int_lut3;
		end if;

	end process;

end architecture;

