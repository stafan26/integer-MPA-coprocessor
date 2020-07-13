-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    01/12/2016
-- Project Name:   MPALU
-- Design Name:    multiplier
-- Module Name:    mux
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;

use work.my_pack.all;

entity mux is
generic (
	g_word_width					: natural := 17;
	g_num_of_words					: natural := 18;
	g_addr_width					: natural := 5
);
port(
	pi_clk							: in std_logic;
	pi_addr							: in std_logic_vector(g_addr_width-1 downto 0);
	pi_data							: in std_logic_vector(g_num_of_words*g_word_width-1 downto 0);
	po_data							: out std_logic_vector(g_word_width-1 downto 0)
);
end mux;

architecture mux of mux is

	type t_data is array (0 to g_word_width-1) of std_logic_vector(g_num_of_words-1 downto 0);
	signal s_data						: t_data;

begin

--	process(pi_clk)
--	begin
--		if(rising_edge(pi_clk)) then
--
--			po_data <= pi_data(to_natural(pi_addr)*g_word_width+g_word_width-1 downto to_natural(pi_addr)*g_word_width);
--
--		end if;
--	end process;

	MUX_X_1_GEN: for i in 0 to g_word_width-1 generate			-- mnoznik

		MAIN_GEN: for j in 0 to g_num_of_words-1 generate
			s_data(i)(j) <= pi_data(j*g_word_width+i);
		end generate;


		MUX_AUTO_INST: entity work.mux_auto_phys generic map (
			g_latency					=> 2				--: natural := 2
		)
		port map (
			pi_clk						=> pi_clk,		--: in std_logic;
			pi_addr						=> pi_addr,		--: in std_logic_vector(3 downto 0);
			pi_data						=> s_data(i),	--: in std_logic_vector(15 downto 0);
			po_data						=> po_data(i)	--: out std_logic
		);

	end generate;

end architecture;

