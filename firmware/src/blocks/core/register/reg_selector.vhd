-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    reg_selector
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

entity reg_selector is
generic (
	g_data_width						: natural := 64
);
port(
	pi_clk								: in std_logic;

	pi_data_shutter					: in std_logic;

	pi_data								: in std_logic_vector(g_data_width-1 downto 0);
	po_data								: out std_logic_vector(g_data_width-1 downto 0)
);
end reg_selector;

architecture reg_selector of reg_selector is

	signal s_data_shutter									: std_logic;

begin

	-- IN
	DATA_ZERO_A_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,								--: natural := 1;
		g_delay					=> 2								--: natural := 3
	)
	port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_data(0)				=> pi_data_shutter,			--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_data_shutter				--: out std_logic_vector(g_data_width-1 downto 0)
	);


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			-------------
			-- PO_DATA --
			-------------
			if(s_data_shutter = '0') then
				po_data <= (others=>'0');
			else
				po_data <= pi_data;
			end if;

		end if;
	end process;

end architecture;
