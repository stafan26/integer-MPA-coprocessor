-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    01/12/2016
-- Project Name:   MPALU
-- Design Name:    common
-- Module Name:    mux_5_1
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;

use work.my_pack.all;

entity mux_5_1 is
generic (
	g_registered_output			: boolean := true
);
port(
	pi_clk							: in std_logic;
	pi_addr							: in std_logic_vector(2 downto 0);
	pi_data							: in std_logic_vector(4 downto 0);
	po_data							: out std_logic
);
end mux_5_1;

architecture mux_5_1 of mux_5_1 is

	signal s_int_lut6										: std_logic;
	signal s_int_lut3										: std_logic;
	signal s_int_mux7										: std_logic;

begin

	LUT6_D_LO_INST : LUT6_L generic map (
		INIT => X"FF00F0F0CCCCAAAA"
	) -- Specify LUT contents
	port map (
		LO		=> s_int_lut6,			-- LUT local output
		I0		=> pi_data(0),			-- LUT input
		I1		=> pi_data(1),			-- LUT input
		I2		=> pi_data(2),			-- LUT input
		I3		=> pi_data(3),			-- LUT input
		I4		=> pi_addr(0),			-- LUT input
		I5		=> pi_addr(1)			-- LUT input
	);

	LUT3_D_HI_INST : LUT3_L generic map (
		INIT => X"02"
	) -- Specify LUT contents
	port map (
		LO		=> s_int_lut3,			-- LUT local output
		I0		=> pi_data(4),			-- LUT input
		I1		=> pi_addr(0),			-- LUT input
		I2		=> pi_addr(1)			-- LUT input
	);


	MUXF7_L_INST: MUXF7_L port map (
		LO		=> s_int_mux7,			-- Output of MUX to local routing
		I0		=> s_int_lut6,			-- Input (tie to LUT6 O6 pin)
		I1		=> s_int_lut3,			-- Input (tie to LUT6 O6 pin)
		S		=> pi_addr(2)			-- Input select to MUX
	);


	process(pi_clk)
	begin

		if(rising_edge(pi_clk)) then
			po_data <= s_int_mux7;
		end if;

	end process;

end architecture;

