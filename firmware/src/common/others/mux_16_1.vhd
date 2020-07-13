-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    01/12/2016
-- Project Name:   MPALU
-- Design Name:    common
-- Module Name:    mux_16_1
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;

use work.my_pack.all;

entity mux_16_1 is
generic (
	g_registered_output			: boolean := true
);
port(
	pi_clk							: in std_logic;
	pi_addr							: in std_logic_vector(3 downto 0);
	pi_data							: in std_logic_vector(15 downto 0);
	po_data							: out std_logic
);
end mux_16_1;

architecture mux_16_1 of mux_16_1 is

	signal s_int_lut6										: std_logic_vector(3 downto 0);
	signal s_int_mux7										: std_logic_vector(1 downto 0);
	signal s_int_mux8										: std_logic;

begin

	LUT6_GEN: for i in 0 to 3 generate
		LUT6_D_inst : LUT6_D generic map (
			INIT => X"FF00F0F0CCCCAAAA"
		) -- Specify LUT contents
		port map (
			LO		=> s_int_lut6(i),		-- LUT local output
			O		=> open,					-- LUT general output
			I0		=> pi_data(4*i+0),	-- LUT input
			I1		=> pi_data(4*i+1),	-- LUT input
			I2		=> pi_data(4*i+2),	-- LUT input
			I3		=> pi_data(4*i+3),	-- LUT input
			I4		=> pi_addr(0),			-- LUT input
			I5		=> pi_addr(1)			-- LUT input
		);
	end generate;



	MUXF7_L_LO_INST: MUXF7_L port map (
		LO		=> s_int_mux7(0),		-- Output of MUX to local routing
		I0		=> s_int_lut6(0),		-- Input (tie to LUT6 O6 pin)
		I1		=> s_int_lut6(1),		-- Input (tie to LUT6 O6 pin)
		S		=> pi_addr(2)			-- Input select to MUX
	);

	MUXF7_L_HI_INST: MUXF7_L port map (
		LO		=> s_int_mux7(1),		-- Output of MUX to local routing
		I0		=> s_int_lut6(2),		-- Input (tie to LUT6 O6 pin)
		I1		=> s_int_lut6(3),		-- Input (tie to LUT6 O6 pin)
		S		=> pi_addr(2)			-- Input select to MUX
	);

	MUXF8_L_INST: MUXF8_L port map (
		LO		=> s_int_mux8,			-- Output of MUX to local routing
		I0		=> s_int_mux7(0),		-- Input (tie to MUXF7 L/LO out)
		I1		=> s_int_mux7(1),		-- Input (tie to MUXF7 L/LO out)
		S		=> pi_addr(3)			-- Input select to MUX
	);


	process(pi_clk)
	begin

		if(rising_edge(pi_clk)) then
			po_data <= s_int_mux8;
		end if;

	end process;

end architecture;

